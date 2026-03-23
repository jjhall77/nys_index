# =============================================================================
# 04 - NYC Crime Harm Index - Gun Violence Index (v2: Substitution Approach)
# =============================================================================
#
# Purpose: Score gun violence incidents for the CHI pipeline.
#
# MAJOR CHANGE FROM v1:
#   v1 was ADDITIVE — shooting CHI was layered on top of arrest-based CHI,
#   intentionally double-scoring fatal incidents (once as Murder in the arrest
#   pipeline, once as Assault 1st in the shooting layer).
#
#   v2 is SUBSTITUTION — shooting CHI REPLACES arrest-based CHI for the
#   same incidents. At the block level, the downstream aggregation script
#   subtracts the arrest-pipeline complaint scores for matching gun violence
#   incidents, then adds the shooting-based scores. This avoids double-counting
#   while correctly scoring each victim at the appropriate harm level.
#
# New data:
#   - NYPD_Shootings_20260217.csv: incident-level (one row per event)
#   - NYPD_Shooting_Victims_20260217.csv: victim-level with STAT_MURDER_FLG
#
# Scoring (per victim):
#   FATAL (STAT_MURDER_FLG == "Y"):
#     → Murder 2nd (PL 125.25, A-I) = 7,300 days
#     Basis: min range 15-25 yrs to life per 70.00(3)(a)(i);
#            midpoint of min = 20 yrs × 365 = 7,300.
#
#   NON-FATAL (STAT_MURDER_FLG == "N"):
#     → Attempted Murder 2nd (A-I → B Violent via PL 110.05(3)) = 5,475 days
#     Basis: 110.05(3) reduces A-I to B for attempted Murder 2nd.
#            B Violent determinate range 5-25 yrs per 70.02;
#            midpoint = 15 yrs × 365 = 5,475.
#     NOTE: The old v1 scored all shootings at Assault 1st (B Violent, 5,475).
#           The non-fatal score is unchanged. But the fatal score is now 7,300
#           (Murder 2nd) instead of 5,475 (Assault 1st), reflecting the actual
#           criminal justice outcome of the event.
#
# Subtraction logic (applied in downstream block-aggregation script):
#   For each block, the aggregation script will:
#     1. Tally shooting victims by type (fatal / non-fatal)
#     2. For fatal: subtract up to N murder complaints' CHI from the block's
#        arrest-based total, where N = number of fatal shooting victims on block
#     3. For non-fatal: subtract up to N felony assault complaints' CHI
#     4. Add the shooting-based CHI scores
#     5. Log mismatches (shooting events with no corresponding complaint)
#
#   The subtraction targets are:
#     Fatal     → "MURDER & NON-NEGL. MANSLAUGHTE" complaints
#     Non-fatal → "FELONY ASSAULT" complaints
#
# Shots fired: UNCHANGED from v1.
#   Classified by pd_desc from complaint data with CPW 2nd (3,376) floor.
#
# Outputs:
#   - shootings_chi:       Victim-level dataset with CHI and coordinates
#   - shots_fired_chi:     Incident-level dataset with CHI
#   - gun_violence_weights: Recommended weights table
#   - shooting_subtraction_map: Defines what arrest categories to displace
#
# =============================================================================

library(tidyverse)
library(here)
library(janitor)
library(scales)
library(lubridate)

# Create output directories
dir.create(here("output", "tables"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("output", "figures"), recursive = TRUE, showWarnings = FALSE)

cat(strrep("=", 70), "\n")
cat("GUN VIOLENCE INDEX v2 (SUBSTITUTION APPROACH)\n")
cat(strrep("=", 70), "\n\n")

# =============================================================================
# PARAMETERS
# =============================================================================

YEAR_START <- 2020
YEAR_END   <- 2024

# NOTE: 2018-2019 excluded because NYPD complaint geocoding in those years
# exhibits systematic fallback to precinct stationhouse coordinates (~38% of
# 2020 murder complaints, worse in earlier years). Shooting victim coordinates
# are accurate across all years. The mismatch between complaint and shooting
# geocoding causes spurious subtraction failures at block level. Quality
# improves dramatically in 2021; 2020 is retained despite residual artifacts
# because the subtraction logic handles unmatched cases correctly (pure
# addition when no complaint exists on block). See diag_2020_fatal_matching.R.

cat(sprintf("Year range: %d - %d\n\n", YEAR_START, YEAR_END))

# =============================================================================
# PART 1: REFERENCE WEIGHTS
# =============================================================================
#
# All weights from the corrected penal_law_chi lookup (v3),
# grounded in PL 70.00/70.02/70.80 sentencing midpoints.
# Convention: 365 days/year, round-half-up to integer days.
# =============================================================================

cat("=== REFERENCE WEIGHTS ===\n\n")

# --- Shooting victim weights (NEW in v2) ---
CHI_MURDER_2ND     <- 7300L   # A-I: min 15-25 to life; midpoint of min = 20 yrs
CHI_ATT_MURDER_2ND <- 5475L   # A-I → B Violent via 110.05(3); 5-25 yrs, midpoint 15

# --- Shots fired charge weights (unchanged from v1) ---
CHI_ATT_ASSAULT_1ST <- 3376L  # B Violent → C Violent via 110.05 attempt
CHI_RE_1ST          <- 608L   # D Non-Violent (PL 70.00(3) min period)
CHI_RE_2ND          <- 182L   # A Misdemeanor (364 days max per 70.15(1-a))

# --- CPW 2nd floor (unchanged) ---
CHI_CPW_2ND         <- 3376L  # C Violent: midpoint 3.5-15 yrs (PL 70.02)

cat("Shooting victim weights:\n")
cat(sprintf("  Fatal (Murder 2nd, PL 125.25):           %s days\n", comma(CHI_MURDER_2ND)))
cat(sprintf("  Non-fatal (Att. Murder 2nd, B Violent):   %s days\n", comma(CHI_ATT_MURDER_2ND)))
cat("\nShots fired charge weights:\n")
cat(sprintf("  Att. Assault 1st (C Violent):             %s days\n", comma(CHI_ATT_ASSAULT_1ST)))
cat(sprintf("  Reckless Endangerment 1st (D Non-V):     %s days\n", comma(CHI_RE_1ST)))
cat(sprintf("  Reckless Endangerment 2nd (A Misd):      %s days\n", comma(CHI_RE_2ND)))
cat(sprintf("  CPW 2nd floor (C Violent):                %s days\n", comma(CHI_CPW_2ND)))

# =============================================================================
# PART 2: LOAD AND SCORE SHOOTINGS (VICTIM-LEVEL)
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("SHOOTINGS (VICTIM-LEVEL)\n")
cat(strrep("=", 70), "\n")

# --- Load incident data ---
new_shootings <- read_csv(
  here("data", "NYPD_Shootings_20260217.csv"),
  show_col_types = FALSE
) %>%
  clean_names() %>%
  distinct(incident_key, .keep_all = TRUE) %>%
  mutate(
    occur_date = mdy(occur_date),
    year = year(occur_date)
  )

cat(sprintf("Incident records loaded: %s\n", comma(nrow(new_shootings))))

# --- Load victim data ---
shooting_vics <- read_csv(
  here("data", "NYPD_Shooting_Victims_20260217.csv"),
  show_col_types = FALSE
) %>%
  clean_names()

cat(sprintf("Victim records loaded: %s\n", comma(nrow(shooting_vics))))

# --- Join: one row per victim with incident geography ---
shootings_victims <- new_shootings %>%
  left_join(shooting_vics, by = "incident_key") %>%
  distinct(victim_id, .keep_all = TRUE)

cat(sprintf("Joined victim-level records: %s\n", comma(nrow(shootings_victims))))

# --- Filter to analysis period and exclude Central Park ---
shootings_filtered <- shootings_victims %>%
  filter(
    year >= YEAR_START,
    year <= YEAR_END,
    precinct != 22  # Central Park
  )

cat(sprintf("After filtering (%d-%d, excl. PCT 22): %s victims\n",
            YEAR_START, YEAR_END, comma(nrow(shootings_filtered))))

# --- Score each victim ---
shootings_chi <- shootings_filtered %>%
  mutate(
    is_fatal = (stat_murder_flg == "Y"),
    chi_days = if_else(is_fatal, CHI_MURDER_2ND, CHI_ATT_MURDER_2ND),
    chi_label = if_else(is_fatal,
                        "Murder 2nd (A-I, 7,300)",
                        "Att. Murder 2nd (B Violent, 5,475)"),
    # What arrest-pipeline category this displaces at block level
    displaces_category = if_else(
      is_fatal,
      "MURDER & NON-NEGL. MANSLAUGHTE",
      "FELONY ASSAULT"
    ),
    incident_type = "shooting"
  )

# --- Summary ---
cat("\n=== SHOOTING VICTIMS BY OUTCOME ===\n")
shootings_chi %>%
  count(is_fatal, chi_label, chi_days) %>%
  mutate(pct = round(100 * n / sum(n), 1)) %>%
  print()

cat(sprintf("\nTotal shooting CHI: %s days\n", comma(sum(shootings_chi$chi_days))))
cat(sprintf("Mean CHI per victim: %s days\n", comma(round(mean(shootings_chi$chi_days)))))

# --- Volume by year ---
shootings_by_year <- shootings_chi %>%
  group_by(year) %>%
  summarise(
    n_victims    = n(),
    n_fatal      = sum(is_fatal),
    n_nonfatal   = sum(!is_fatal),
    fatal_share  = round(mean(is_fatal), 3),
    total_chi    = sum(chi_days),
    mean_chi     = round(mean(chi_days)),
    .groups = "drop"
  )

cat("\n=== SHOOTINGS BY YEAR ===\n")
print(shootings_by_year %>%
        mutate(total_chi = comma(total_chi)))

# --- Volume by borough ---
shootings_by_boro <- shootings_chi %>%
  group_by(boro) %>%
  summarise(
    n_victims   = n(),
    n_fatal     = sum(is_fatal),
    fatal_share = round(mean(is_fatal), 3),
    total_chi   = sum(chi_days),
    mean_chi    = round(mean(chi_days)),
    .groups = "drop"
  ) %>%
  arrange(desc(n_victims))

cat("\n=== SHOOTINGS BY BOROUGH ===\n")
print(shootings_by_boro)

# --- Temporal stability of mean CHI ---
# The mean CHI moves only if the fatal share changes, since there are
# only two possible values (7,300 and 5,475).
cat("\n=== SHOOTING CHI: TEMPORAL STABILITY ===\n")
shooting_stability <- shootings_by_year %>%
  summarise(
    n_years          = n(),
    chi_grand_mean   = mean(mean_chi),
    chi_between_sd   = sd(mean_chi),
    chi_cv_between   = chi_between_sd / chi_grand_mean,
    fatal_share_mean = mean(fatal_share),
    fatal_share_sd   = sd(fatal_share),
    .groups = "drop"
  )
print(shooting_stability %>%
        mutate(chi_cv_between = round(chi_cv_between, 4)))

cat("\nNote: All variation in mean CHI comes from the fatal/non-fatal mix.\n")
cat("  If fatal share is stable across years, mean CHI is stable.\n")

# =============================================================================
# PART 2b: SUBTRACTION MAP
# =============================================================================
#
# This defines, for each shooting victim type, what category of arrest-based
# complaint should be subtracted from the block's arrest CHI total.
#
# The downstream block-aggregation script will use this map to:
#   1. For each block, count shooting victims by displaces_category
#   2. Sort the block's arrest complaints in that category by chi_adjusted (asc)
#   3. Subtract the lowest-CHI complaints first (conservative: remove the
#      least-harmful matches, preserving higher-harm arrest records)
#   4. Add the shooting CHI scores
#   5. Log any shortfall (more shooting victims than matching complaints)
#
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("SUBTRACTION MAP\n")
cat(strrep("=", 70), "\n")

shooting_subtraction_map <- tribble(
  ~victim_type,  ~displaces_category,                    ~chi_days, ~rationale,
  "fatal",       "MURDER & NON-NEGL. MANSLAUGHTE",       7300L,     "Shooting homicide replaces Murder complaint; scored at Murder 2nd (7,300)",
  "non_fatal",   "FELONY ASSAULT",                        5475L,     "Non-fatal shooting replaces Felony Assault complaint; scored at Att. Murder 2nd (5,475)"
)

cat("\n")
print(shooting_subtraction_map)

# Preview: what's the expected net CHI change?
cat("\n=== EXPECTED NET EFFECT AT BLOCK LEVEL ===\n")
cat("Fatal victims:\n")
cat(sprintf("  Shooting CHI: +%s   Arrest subtract: -%s (Murder mean)\n",
            comma(CHI_MURDER_2ND), "~7,300"))
cat("  Net: ~0 if matched (arrest Murder ≈ shooting Murder)\n")
cat("  Net: +7,300 if unmatched (no arrest complaint on block)\n")
cat("\nNon-fatal victims:\n")
cat(sprintf("  Shooting CHI: +%s   Arrest subtract: -%s (Felony Assault mean)\n",
            comma(CHI_ATT_MURDER_2ND), "~1,600-2,000"))
cat("  Net: ~+3,500 to +3,900 if matched (reweights undercharged conduct)\n")
cat("  Net: +5,475 if unmatched (no arrest complaint on block)\n")

# Mismatch expectations
cat("\n=== MISMATCH EXPECTATIONS ===\n")
cat("Fatal mismatches expected to be RARE: most shooting homicides generate\n")
cat("  a murder complaint. Possible if complaint filed in different precinct\n")
cat("  or complaint date doesn't fall in analysis window.\n")
cat("Non-fatal mismatches more common: many non-fatal shootings are\n")
cat("  investigated without an arrest, or the felony assault complaint\n")
cat("  may be filed at a different location.\n")

# =============================================================================
# PART 3: LOAD AND MUNGE SHOTS FIRED DATA (UNCHANGED FROM v1)
# =============================================================================
#
# DATA QUALITY NOTE (2023-2024):
#   The newer shots fired source (shots_fired_new.csv, Oct 2022+) lacks pd_desc
#   and psb fields for 2023-2024 records (~35% of total). Consequences:
#     - CHI scoring UNAFFECTED: all pd_desc categories floor to CPW 2nd (3,376)
#       anyway, so NA pd_desc gets the same weight via the TRUE ~ CPW floor path.
#     - Block-level aggregation UNAFFECTED: uses XY coordinates, not PSB.
#     - Geographic/temporal diagnostic plots INCOMPLETE: borough breakdowns and
#       pd_desc composition plots only cover 2020-2022. The year × borough
#       heatmap and composition stacked area chart are missing 2023-2024.
#   This is a metadata gap in the source extract, not a scoring issue.
#

cat("\n")
cat(strrep("=", 70), "\n")
cat("SHOTS FIRED\n")
cat(strrep("=", 70), "\n")

# Older shots fired data (through Sept 2022)
sf2017 <- read_csv(here("data", "sf_since_2017.csv"), show_col_types = FALSE) %>%
  clean_names() %>%
  mutate(
    date = mdy(cmplnt_fr_dt),
    source = "sf2017"
  ) %>%
  filter(!is.na(date), date <= ymd("2022-09-30"))

# Newer shots fired data (Oct 2022 onward)
shots_fired_new <- read_csv(here("data", "shots_fired_new.csv"), show_col_types = FALSE) %>%
  clean_names() %>%
  mutate(
    date = mdy(cmplnt_fr_dt),
    source = "shots_fired_new"
  ) %>%
  rename(
    pct = cmplnt_pct_cd,
    x_coord_cd = x_coordinate_code,
    y_coord_cd = y_coordinate_code
  ) %>%
  filter(!is.na(date), date >= ymd("2022-10-01"))

# Combine
shots_fired <- bind_rows(sf2017, shots_fired_new) %>%
  filter(!is.na(x_coord_cd), !is.na(y_coord_cd)) %>%
  distinct(cmplnt_key, .keep_all = TRUE) %>%
  mutate(year = year(date)) %>%
  filter(year >= YEAR_START, year <= YEAR_END)

cat(sprintf("Shots fired loaded: %s incidents (%d-%d)\n",
            comma(nrow(shots_fired)), min(shots_fired$year), max(shots_fired$year)))

# pd_desc distribution
cat("\n=== SHOTS FIRED: PD_DESC DISTRIBUTION ===\n")
sf_pd_dist <- shots_fired %>%
  count(pd_desc) %>%
  arrange(desc(n)) %>%
  mutate(pct = round(100 * n / sum(n), 1))
print(sf_pd_dist)

# =============================================================================
# PART 4: ASSIGN CHI TO SHOTS FIRED (UNCHANGED FROM v1)
# =============================================================================
#
# Classification logic (pd_desc → CHI):
#
#   "ASSAULT 2,1,UNCLASSIFIED"
#     → Attempted Assault 1st (C Violent) = 3,376 days
#     Firing a gun at a person = attempted Assault 1st (B Violent → C Violent
#     via PL 110.05 class reduction). Equals CPW floor.
#
#   "RECKLESS ENDANGERMENT 1"
#     → RE 1st (D Non-Violent) = 608 days, floored to CPW 2nd = 3,376
#
#   "RECKLESS ENDANGERMENT OF PROPE"
#     → RE 2nd/Property (A Misd) = 182 days, floored to CPW 2nd = 3,376
#
#   All others (INVESTIGATE, BALLISTICS, etc.)
#     → CPW 2nd floor = 3,376 days
#
# The CPW floor means all categories collapse to 3,376. Variation in the
# weighted average only comes from any pd_descs with charges ABOVE C Violent.
# =============================================================================

shots_fired_chi <- shots_fired %>%
  mutate(
    chi_category = case_when(
      pd_desc == "ASSAULT 2,1,UNCLASSIFIED" ~ "Att. Assault 1st (C Violent)",
      pd_desc == "RECKLESS ENDANGERMENT 1"  ~ "RE 1st (D Non-Violent, floored)",
      str_detect(pd_desc, "RECKLESS ENDANGERMENT.*PROPE") ~ "RE 2nd/Property (A Misd, floored)",
      TRUE ~ "Other/Investigation (CPW floor)"
    ),
    chi_base = case_when(
      pd_desc == "ASSAULT 2,1,UNCLASSIFIED" ~ CHI_ATT_ASSAULT_1ST,
      pd_desc == "RECKLESS ENDANGERMENT 1"  ~ CHI_RE_1ST,
      str_detect(pd_desc, "RECKLESS ENDANGERMENT.*PROPE") ~ CHI_RE_2ND,
      TRUE ~ CHI_CPW_2ND
    ),
    chi_days = pmax(chi_base, CHI_CPW_2ND),
    incident_type = "shots_fired"
  )

# Summary
cat("\n=== SHOTS FIRED: CHI ASSIGNMENT SUMMARY ===\n")
sf_chi_summary <- shots_fired_chi %>%
  group_by(pd_desc, chi_category, chi_base, chi_days) %>%
  summarise(n = n(), .groups = "drop") %>%
  arrange(desc(n)) %>%
  mutate(
    pct = round(100 * n / sum(n), 1),
    floored = chi_base < chi_days
  )
print(sf_chi_summary)

cat(sprintf("\nWeighted mean CHI (shots fired): %s days\n",
            comma(round(mean(shots_fired_chi$chi_days)))))
cat(sprintf("Incidents where CPW floor applied: %s (%.1f%%)\n",
            comma(sum(shots_fired_chi$chi_base < shots_fired_chi$chi_days)),
            100 * mean(shots_fired_chi$chi_base < shots_fired_chi$chi_days)))

# =============================================================================
# PART 5: SHOTS FIRED - TEMPORAL STABILITY (UNCHANGED FROM v1)
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("SHOTS FIRED: TEMPORAL STABILITY\n")
cat(strrep("=", 70), "\n")

# PD_DESC proportions by year
sf_by_year_pd <- shots_fired_chi %>%
  count(year, pd_desc, chi_category, chi_days) %>%
  group_by(year) %>%
  mutate(
    total = sum(n),
    prop = n / total,
    contribution = prop * chi_days
  ) %>%
  ungroup()

cat("\n=== PD_DESC PROPORTIONS BY YEAR ===\n")
sf_by_year_pd %>%
  select(year, pd_desc, prop) %>%
  pivot_wider(names_from = pd_desc, values_from = prop, values_fill = 0) %>%
  print()

# Aggregate CHI by year
sf_chi_by_year <- shots_fired_chi %>%
  group_by(year) %>%
  summarise(
    n = n(),
    chi_mean = mean(chi_days),
    chi_sd = sd(chi_days),
    chi_se = chi_sd / sqrt(n),
    chi_cv = chi_sd / chi_mean,
    .groups = "drop"
  )

cat("\n=== SHOTS FIRED: MEAN CHI BY YEAR ===\n")
print(sf_chi_by_year %>%
        mutate(chi_mean = round(chi_mean, 1),
               chi_se = round(chi_se, 1)))

# YoY changes
sf_yoy <- sf_chi_by_year %>%
  arrange(year) %>%
  mutate(
    chi_lag = lag(chi_mean),
    chi_change = chi_mean - chi_lag,
    chi_pct_change = 100 * (chi_mean - chi_lag) / chi_lag
  )

cat("\n=== SHOTS FIRED: YEAR-OVER-YEAR CHANGES ===\n")
print(sf_yoy %>%
        filter(!is.na(chi_change)) %>%
        mutate(chi_mean = round(chi_mean, 1),
               chi_pct_change = round(chi_pct_change, 2)) %>%
        select(year, n, chi_mean, chi_change, chi_pct_change))

# Stability summary
sf_stability <- sf_chi_by_year %>%
  summarise(
    n_years = n(),
    chi_grand_mean = mean(chi_mean),
    chi_between_year_sd = sd(chi_mean),
    chi_cv_between = chi_between_year_sd / chi_grand_mean,
    chi_min_year = min(chi_mean),
    chi_max_year = max(chi_mean),
    chi_range = chi_max_year - chi_min_year,
    chi_range_pct = 100 * chi_range / chi_grand_mean
  )

cat("\n=== SHOTS FIRED: TEMPORAL STABILITY SUMMARY ===\n")
print(sf_stability %>%
        mutate(chi_grand_mean = round(chi_grand_mean, 1),
               chi_cv_between = round(chi_cv_between, 4),
               chi_range_pct = round(chi_range_pct, 2)))

# =============================================================================
# PART 6: SHOTS FIRED - GEOGRAPHIC VARIATION (UNCHANGED FROM v1)
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("SHOTS FIRED: GEOGRAPHIC VARIATION\n")
cat(strrep("=", 70), "\n")

psb_to_boro <- tribble(
  ~psb, ~borough,
  "PBBN", "Brooklyn",
  "PBBS", "Brooklyn",
  "PBBX", "Bronx",
  "PBMN", "Manhattan",
  "PBMS", "Manhattan",
  "PBQN", "Queens",
  "PBQS", "Queens",
  "PBSI", "Staten Island"
)

shots_fired_chi <- shots_fired_chi %>%
  left_join(psb_to_boro, by = "psb")

n_no_boro <- sum(is.na(shots_fired_chi$borough))
if (n_no_boro > 0) {
  cat(sprintf("\nWARNING: %s incidents (%.1f%%) have no borough match.\n",
              comma(n_no_boro), 100 * n_no_boro / nrow(shots_fired_chi)))
  cat("Unmatched PSB values:\n")
  shots_fired_chi %>%
    filter(is.na(borough)) %>%
    count(psb) %>%
    arrange(desc(n)) %>%
    print()
}

# CHI by borough
sf_chi_by_boro <- shots_fired_chi %>%
  filter(!is.na(borough)) %>%
  group_by(borough) %>%
  summarise(
    n = n(),
    chi_mean = mean(chi_days),
    chi_sd = sd(chi_days),
    chi_se = chi_sd / sqrt(n),
    .groups = "drop"
  ) %>%
  arrange(desc(chi_mean))

cat("\n=== SHOTS FIRED: CHI BY BOROUGH ===\n")
print(sf_chi_by_boro %>%
        mutate(chi_mean = round(chi_mean, 1),
               chi_se = round(chi_se, 1)))

sf_boro_variation <- sf_chi_by_boro %>%
  summarise(
    n_boros = n(),
    chi_grand_mean = mean(chi_mean),
    chi_between_boro_sd = sd(chi_mean),
    chi_cv_between = chi_between_boro_sd / chi_grand_mean,
    chi_min_boro = min(chi_mean),
    chi_max_boro = max(chi_mean),
    chi_range_pct = 100 * (chi_max_boro - chi_min_boro) / chi_grand_mean
  )

cat("\n=== SHOTS FIRED: BOROUGH VARIATION ===\n")
print(sf_boro_variation %>%
        mutate(chi_cv_between = round(chi_cv_between, 4),
               chi_range_pct = round(chi_range_pct, 2)))

# Year × Borough
sf_chi_by_year_boro <- shots_fired_chi %>%
  filter(!is.na(borough)) %>%
  group_by(year, borough) %>%
  summarise(
    n = n(),
    chi_mean = mean(chi_days),
    .groups = "drop"
  )

cat("\n=== SHOTS FIRED: CHI BY YEAR AND BOROUGH ===\n")
sf_chi_by_year_boro %>%
  select(year, borough, chi_mean) %>%
  pivot_wider(names_from = borough, values_from = chi_mean) %>%
  print()

# =============================================================================
# PART 7: RECOMMENDED WEIGHTS
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("RECOMMENDED GUN VIOLENCE CHI WEIGHTS\n")
cat(strrep("=", 70), "\n")

shootings_recommended <- tibble(
  category = c("Shooting victim (fatal)", "Shooting victim (non-fatal)"),
  n = c(sum(shootings_chi$is_fatal), sum(!shootings_chi$is_fatal)),
  chi_recommended = c(CHI_MURDER_2ND, CHI_ATT_MURDER_2ND),
  basis = c(
    "Murder 2nd (A-I, PL 125.25); replaces arrest Murder complaint",
    "Att. Murder 2nd (B Violent via 110.05(3)); replaces arrest Felony Assault complaint"
  )
)

sf_recommended <- shots_fired_chi %>%
  summarise(
    category = "Shots Fired (no victim)",
    n = n(),
    chi_recommended = round(mean(chi_days)),
    basis = sprintf("Data-driven pd_desc mix with CPW 2nd (%s) floor",
                    comma(CHI_CPW_2ND)),
    .groups = "drop"
  )

gun_violence_weights <- bind_rows(shootings_recommended, sf_recommended)

cat("\n=== RECOMMENDED WEIGHTS ===\n")
print(gun_violence_weights)

# =============================================================================
# PART 8: EXPORT RESULTS
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("SAVING RESULTS\n")
cat(strrep("=", 70), "\n")

saveRDS(shootings_chi, here("data", "shootings_chi.rds"))
saveRDS(shots_fired_chi, here("data", "shots_fired_chi.rds"))
saveRDS(shooting_subtraction_map, here("data", "shooting_subtraction_map.rds"))

write_csv(gun_violence_weights, here("output", "tables", "gun_violence_chi_weights.csv"))
write_csv(shootings_by_year, here("output", "tables", "shootings_by_year.csv"))
write_csv(shootings_by_boro, here("output", "tables", "shootings_by_borough.csv"))
write_csv(sf_chi_by_year, here("output", "tables", "sf_chi_by_year.csv"))
write_csv(sf_chi_by_boro, here("output", "tables", "sf_chi_by_borough.csv"))
write_csv(sf_chi_by_year_boro, here("output", "tables", "sf_chi_by_year_borough.csv"))

cat("  Saved: data/shootings_chi.rds\n")
cat("  Saved: data/shots_fired_chi.rds\n")
cat("  Saved: data/shooting_subtraction_map.rds\n")
cat("  Saved: output/tables/gun_violence_chi_weights.csv\n")
cat("  Saved: output/tables/shootings_by_year.csv\n")
cat("  Saved: output/tables/shootings_by_borough.csv\n")
cat("  Saved: output/tables/sf_chi_by_year.csv\n")
cat("  Saved: output/tables/sf_chi_by_borough.csv\n")
cat("  Saved: output/tables/sf_chi_by_year_borough.csv\n")

# =============================================================================
# PART 9: PUBLICATION PLOTS
# =============================================================================

cat("\n=== CREATING PLOTS ===\n")

theme_pub <- function() {
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.line = element_line(color = "black", linewidth = 0.3),
      axis.ticks = element_line(color = "black", linewidth = 0.3),
      axis.ticks.length = unit(0.15, "cm"),
      plot.title = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(size = 10, color = "gray40"),
      plot.caption = element_text(size = 8, color = "gray50"),
      strip.text = element_text(face = "bold")
    )
}

# --- Plot 1: Shooting victims by year (fatal vs non-fatal) ---
p1_data <- shootings_by_year %>%
  pivot_longer(cols = c(n_fatal, n_nonfatal),
               names_to = "outcome", values_to = "count") %>%
  mutate(outcome = if_else(outcome == "n_fatal", "Fatal", "Non-fatal"))

p1 <- ggplot(p1_data, aes(x = year, y = count, fill = outcome)) +
  geom_col(width = 0.6) +
  geom_text(data = shootings_by_year,
            aes(x = year, y = n_victims, label = comma(n_victims), fill = NULL),
            vjust = -0.5, size = 3) +
  scale_x_continuous(breaks = YEAR_START:YEAR_END) +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.1))) +
  scale_fill_manual(values = c("Fatal" = "gray20", "Non-fatal" = "gray60")) +
  labs(
    title = "Shooting Victims Over Time",
    subtitle = sprintf("Fatal = %s days (Murder 2nd) | Non-fatal = %s days (Att. Murder 2nd)",
                       comma(CHI_MURDER_2ND), comma(CHI_ATT_MURDER_2ND)),
    x = "Year",
    y = "Number of Victims",
    fill = NULL,
    caption = "Source: NYPD Shooting Incident Data. One row per victim."
  ) +
  theme_pub() +
  theme(legend.position = "bottom")

ggsave(here("output", "figures", "fig_gun_shootings_volume.png"), p1,
       width = 8, height = 5, dpi = 300, bg = "white")

# --- Plot 2: Fatal share over time ---
p2 <- ggplot(shootings_by_year, aes(x = year, y = fatal_share)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 3, shape = 21, fill = "white") +
  geom_hline(yintercept = mean(shootings_by_year$fatal_share),
             linetype = "dashed", color = "gray50") +
  scale_x_continuous(breaks = YEAR_START:YEAR_END) +
  scale_y_continuous(labels = percent_format(accuracy = 1),
                     limits = c(0, NA)) +
  labs(
    title = "Shooting Fatality Rate Over Time",
    subtitle = "Proportion of victims killed (drives mean CHI variation)",
    x = "Year",
    y = "Fatal Share",
    caption = "Dashed line = period mean."
  ) +
  theme_pub()

ggsave(here("output", "figures", "fig_gun_fatal_share.png"), p2,
       width = 7, height = 5, dpi = 300, bg = "white")

# --- Plot 3: Shots fired CHI over time (unchanged from v1) ---
p3 <- ggplot(sf_chi_by_year, aes(x = year, y = chi_mean)) +
  geom_ribbon(aes(ymin = chi_mean - 1.96 * chi_se,
                  ymax = chi_mean + 1.96 * chi_se),
              fill = "gray80", alpha = 0.5) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 3, shape = 21, fill = "white") +
  geom_hline(yintercept = CHI_CPW_2ND, linetype = "dashed", color = "gray50") +
  annotate("text", x = YEAR_START + 0.5, y = CHI_CPW_2ND + 30,
           label = sprintf("CPW 2nd floor (%s)", comma(CHI_CPW_2ND)),
           size = 3, hjust = 0, color = "gray40") +
  scale_x_continuous(breaks = YEAR_START:YEAR_END) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Shots Fired: Crime Harm Index Over Time",
    subtitle = "Mean CHI with 95% CI",
    x = "Year",
    y = "Mean CHI (days)",
    caption = sprintf("N = %s incidents. CPW 2nd (PL 265.03) = minimum for any gun discharge.",
                      comma(nrow(shots_fired_chi)))
  ) +
  theme_pub()

ggsave(here("output", "figures", "fig_gun_sf_chi_temporal.png"), p3,
       width = 7, height = 5, dpi = 300, bg = "white")

# --- Plot 4: Shots fired pd_desc composition over time ---
p4_data <- sf_by_year_pd %>%
  mutate(
    pd_clean = case_when(
      str_detect(pd_desc, "ASSAULT") ~ "Assault",
      pd_desc == "RECKLESS ENDANGERMENT 1" ~ "Reckless Endangerment",
      str_detect(pd_desc, "RECKLESS.*PROPE") ~ "RE (Property)",
      TRUE ~ "Other/Investigation"
    ),
    pd_clean = factor(pd_clean,
                      levels = c("Assault", "Reckless Endangerment",
                                 "RE (Property)", "Other/Investigation"))
  ) %>%
  group_by(year, pd_clean) %>%
  summarise(prop = sum(prop), .groups = "drop")

p4 <- ggplot(p4_data, aes(x = year, y = prop, fill = pd_clean)) +
  geom_area(alpha = 0.8, color = "white", linewidth = 0.3) +
  scale_x_continuous(breaks = YEAR_START:YEAR_END) +
  scale_y_continuous(labels = percent, expand = c(0, 0)) +
  scale_fill_manual(values = c("Assault" = "gray20",
                               "Reckless Endangerment" = "gray50",
                               "RE (Property)" = "gray70",
                               "Other/Investigation" = "gray85")) +
  labs(
    title = "Shots Fired: Classification Distribution Over Time",
    subtitle = "Proportion of incidents by PD description category",
    x = "Year",
    y = "Proportion",
    fill = NULL
  ) +
  theme_pub() +
  theme(legend.position = "right")

ggsave(here("output", "figures", "fig_gun_sf_composition.png"), p4,
       width = 8, height = 5, dpi = 300, bg = "white")

# --- Plot 5: Shots fired CHI by borough ---
p5_data <- sf_chi_by_boro %>%
  mutate(
    chi_lower = chi_mean - 1.96 * chi_se,
    chi_upper = chi_mean + 1.96 * chi_se
  )
grand_mean_sf <- weighted.mean(sf_chi_by_boro$chi_mean, sf_chi_by_boro$n)

p5 <- ggplot(p5_data, aes(x = reorder(borough, chi_mean), y = chi_mean)) +
  geom_hline(yintercept = grand_mean_sf, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = chi_lower, ymax = chi_upper),
                width = 0.2, linewidth = 0.5, color = "gray40") +
  geom_point(size = 4) +
  coord_flip() +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Shots Fired: Crime Harm Index by Borough",
    subtitle = "Mean CHI with 95% CI; dashed line = citywide mean",
    x = NULL,
    y = "Mean CHI (days)"
  ) +
  theme_pub() +
  theme(panel.grid.major.y = element_blank())

ggsave(here("output", "figures", "fig_gun_sf_borough.png"), p5,
       width = 6, height = 4, dpi = 300, bg = "white")

# --- Plot 6: Year × Borough heatmap ---
p6 <- ggplot(sf_chi_by_year_boro, aes(x = factor(year), y = borough, fill = chi_mean)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = comma(round(chi_mean))), size = 3, color = "white") +
  scale_fill_gradient(low = "gray70", high = "gray20",
                      labels = comma, name = "Mean CHI") +
  labs(
    title = "Shots Fired: CHI by Year and Borough",
    subtitle = "Darker = higher harm (more assault classifications)",
    x = "Year",
    y = NULL
  ) +
  theme_pub() +
  theme(panel.grid = element_blank())

ggsave(here("output", "figures", "fig_gun_sf_heatmap.png"), p6,
       width = 8, height = 4, dpi = 300, bg = "white")

cat("  Saved: fig_gun_shootings_volume.png\n")
cat("  Saved: fig_gun_fatal_share.png\n")
cat("  Saved: fig_gun_sf_chi_temporal.png\n")
cat("  Saved: fig_gun_sf_composition.png\n")
cat("  Saved: fig_gun_sf_borough.png\n")
cat("  Saved: fig_gun_sf_heatmap.png\n")

# =============================================================================
# FINAL SUMMARY
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("FINAL SUMMARY\n")
cat(strrep("=", 70), "\n")

cat("\nSHOOTINGS (victim-level, SUBSTITUTION approach):\n")
cat(sprintf("  N: %s victims (%d-%d)\n", comma(nrow(shootings_chi)), YEAR_START, YEAR_END))
cat(sprintf("  Fatal:     %s victims × %s days = %s total CHI\n",
            comma(sum(shootings_chi$is_fatal)),
            comma(CHI_MURDER_2ND),
            comma(sum(shootings_chi$is_fatal) * CHI_MURDER_2ND)))
cat(sprintf("  Non-fatal: %s victims × %s days = %s total CHI\n",
            comma(sum(!shootings_chi$is_fatal)),
            comma(CHI_ATT_MURDER_2ND),
            comma(sum(!shootings_chi$is_fatal) * CHI_ATT_MURDER_2ND)))
cat(sprintf("  Total CHI: %s days\n", comma(sum(shootings_chi$chi_days))))
cat("  Replaces (not adds to) arrest-based complaints for matching incidents.\n")

cat("\nSHOTS FIRED (no victim, ADDITIVE, unchanged):\n")
cat(sprintf("  N: %s incidents (%d-%d)\n", comma(nrow(shots_fired_chi)), YEAR_START, YEAR_END))
cat(sprintf("  Recommended CHI: %s days\n", comma(sf_recommended$chi_recommended)))
cat(sprintf("  Temporal CV: %.4f\n", sf_stability$chi_cv_between))
cat(sprintf("  Borough CV: %.4f\n", sf_boro_variation$chi_cv_between))
cat("  Basis: Data-driven pd_desc mix with CPW 2nd (3,376) floor\n")

cat("\nBLOCK-LEVEL AGGREGATION (downstream):\n")
cat("  Total block harm = (arrest CHI − displaced complaints) + shooting CHI + shots fired CHI\n")
cat("  Fatal victims displace MURDER complaints.\n")
cat("  Non-fatal victims displace FELONY ASSAULT complaints.\n")
cat("  Mismatches logged when no matching complaint exists on block.\n")

cat("\nObjects available:\n")
cat("  - shootings_chi:             Victim-level shootings with CHI and coordinates\n")
cat("  - shots_fired_chi:           Incident-level shots fired with CHI\n")
cat("  - shooting_subtraction_map:  Defines what arrest categories to displace\n")
cat("  - gun_violence_weights:      Recommended weights table\n")

cat("\n")
cat(strrep("=", 70), "\n")
cat("GUN VIOLENCE INDEX v2 COMPLETE\n")
cat(strrep("=", 70), "\n")