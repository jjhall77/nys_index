# =============================================================================
# 05 - NYC Crime Harm Index: Unified Harm Weights Key (v2)
# =============================================================================
#
# Purpose: Combine all CHI weight sources into a single exportable lookup.
#          This is the ONE object that downstream scripts (block-level
#          aggregation, EBC targeting) should source for harm weights.
#
# Sources:
#   1. PD-level arrest CHI  (from 02_chi_pd_level.R)
#      → one weight per offense_description1 × pd_description
#      → empirical mean of law_code charges within each pd
#
#   2. Shooting victims      (from 04_gun_violence_index.R v2)
#      → victim-level with fatal/non-fatal distinction
#      → fatal:     7,300 days (Murder 2nd, A-I)
#      → non-fatal: 5,475 days (Att. Murder 2nd, B Violent)
#      → SUBSTITUTION: displaces arrest-pipeline complaints at block level
#
#   3. Shots fired           (from 04_gun_violence_index.R)
#      → data-driven pd_desc mix with CPW 2nd (3,376) floor
#      → ADDITIVE: no displacement, added on top of arrest CHI
#
# Output:
#   chi_harm_key — unified tibble with columns:
#     source:             "arrest" | "shooting" | "shots_fired"
#     category:           offense_description1 (arrests) or event type
#     subcategory:        pd_description (arrests) or victim type or pd_desc
#     chi_weight:         integer days
#     n:                  count underlying the weight
#     displaces_category: arrest category this weight replaces (NA if additive)
#     basis:              short text describing the statutory/empirical basis
#
# Change log:
#   v1  Original: flat 5,475 shooting weight, additive
#   v2  Victim-level shooting weights (fatal 7,300 / non-fatal 5,475),
#       substitution approach with displaces_category column
#
# Dependencies: 00_chi_setup_v3.R, 02_chi_pd_level.R, 04_gun_violence_index.R
#
# =============================================================================

library(tidyverse)
library(here)
library(scales)

cat("\n")
cat(strrep("=", 70), "\n")
cat("UNIFIED HARM WEIGHTS KEY v2\n")
cat(strrep("=", 70), "\n\n")

# =============================================================================
# PART 1: LOAD UPSTREAM OBJECTS
# =============================================================================

# --- Arrest-based PD weights (script 02) ---
if (!exists("chi_pd_weights_full")) {
  rds_path <- here("data", "chi_pd_weights.rds")
  if (file.exists(rds_path)) {
    chi_pd_weights_full <- readRDS(rds_path)
    cat(sprintf("  Loaded chi_pd_weights_full from RDS (%d rows)\n", nrow(chi_pd_weights_full)))
  } else {
    cat("  Running 02_chi_pd_level.R to generate PD weights...\n")
    source(here("02_chi_pd_level.R"))
  }
}

# --- Gun violence objects (script 04) ---
# Shootings (now victim-level)
if (!exists("shootings_chi")) {
  rds_path <- here("data", "shootings_chi.rds")
  if (file.exists(rds_path)) {
    shootings_chi <- readRDS(rds_path)
    cat(sprintf("  Loaded shootings_chi from RDS (%s victims)\n", comma(nrow(shootings_chi))))
  } else {
    cat("  Running 04_gun_violence_index.R to generate gun violence data...\n")
    source(here("04_gun_violence_index.R"))
  }
}

# Shots fired
if (!exists("shots_fired_chi")) {
  rds_path <- here("data", "shots_fired_chi.rds")
  if (file.exists(rds_path)) {
    shots_fired_chi <- readRDS(rds_path)
    cat(sprintf("  Loaded shots_fired_chi from RDS (%s incidents)\n", comma(nrow(shots_fired_chi))))
  } else if (!exists("shots_fired_chi")) {
    source(here("04_gun_violence_index.R"))
  }
}

# =============================================================================
# PART 2: BUILD ARREST WEIGHTS LAYER
# =============================================================================

cat("\nBuilding arrest weights layer...\n")

arrest_weights <- chi_pd_weights_full %>%
  transmute(
    source             = "arrest",
    category           = offense_description1,
    subcategory        = pd_description,
    chi_weight         = as.integer(chi_weight),
    n                  = n_arrests,
    displaces_category = NA_character_,
    basis              = paste0("Empirical mean of law_code charges within pd (modal: ",
                                modal_law_code, ", ", round(modal_law_pct * 100), "%)")
  )

cat(sprintf("  Arrest weights: %d rows across %d categories\n",
            nrow(arrest_weights), n_distinct(arrest_weights$category)))

# =============================================================================
# PART 3: BUILD SHOOTING WEIGHT LAYER (v2: victim-level, substitution)
# =============================================================================

cat("Building shooting weight layer...\n")

shooting_weights <- tibble(
  source             = "shooting",
  category           = "SHOOTING (VICTIM HIT)",
  subcategory        = c("FATAL", "NON-FATAL"),
  chi_weight         = c(7300L, 5475L),
  n                  = c(sum(shootings_chi$is_fatal), sum(!shootings_chi$is_fatal)),
  displaces_category = c("MURDER & NON-NEGL. MANSLAUGHTE", "FELONY ASSAULT"),
  basis              = c(
    "Murder 2nd (A-I, PL 125.25); displaces arrest Murder complaint at block level",
    "Att. Murder 2nd (B Violent via 110.05(3)); displaces arrest Felony Assault complaint at block level"
  )
)

cat(sprintf("  Fatal:     %s victims × %s days\n",
            comma(shooting_weights$n[1]), comma(shooting_weights$chi_weight[1])))
cat(sprintf("  Non-fatal: %s victims × %s days\n",
            comma(shooting_weights$n[2]), comma(shooting_weights$chi_weight[2])))

# =============================================================================
# PART 4: BUILD SHOTS FIRED WEIGHTS LAYER (unchanged)
# =============================================================================

cat("Building shots fired weights layer...\n")

# Individual pd_desc weights (before CPW floor, and after)
sf_weights <- shots_fired_chi %>%
  group_by(pd_desc, chi_category, chi_base, chi_days) %>%
  summarise(n = n(), .groups = "drop") %>%
  transmute(
    source             = "shots_fired",
    category           = "SHOTS FIRED (NO VICTIM)",
    subcategory        = pd_desc,
    chi_weight         = as.integer(chi_days),
    n                  = n,
    displaces_category = NA_character_,
    basis              = paste0(chi_category,
                                if_else(chi_base < chi_days,
                                        sprintf("; base %s floored to CPW 2nd %s",
                                                comma(chi_base), comma(chi_days)),
                                        ""))
  )

# Summary row (the recommended flat weight for shots fired)
sf_summary <- tibble(
  source             = "shots_fired",
  category           = "SHOTS FIRED (NO VICTIM)",
  subcategory        = "ALL (weighted mean)",
  chi_weight         = as.integer(round(mean(shots_fired_chi$chi_days))),
  n                  = nrow(shots_fired_chi),
  displaces_category = NA_character_,
  basis              = sprintf("Data-driven pd_desc mix with CPW 2nd (%s) floor",
                               comma(3376))
)

sf_combined <- bind_rows(sf_weights, sf_summary)

cat(sprintf("  Shots fired: %d pd_desc categories + 1 summary row\n",
            nrow(sf_weights)))
cat(sprintf("  Recommended shots fired weight: %s days\n",
            comma(sf_summary$chi_weight)))

# =============================================================================
# PART 5: COMBINE INTO UNIFIED KEY
# =============================================================================

cat("\nCombining into unified key...\n")

chi_harm_key <- bind_rows(
  arrest_weights,
  shooting_weights,
  sf_combined
)

cat(sprintf("\n  Total rows: %d\n", nrow(chi_harm_key)))
cat(sprintf("    Arrest:      %d\n", sum(chi_harm_key$source == "arrest")))
cat(sprintf("    Shooting:    %d\n", sum(chi_harm_key$source == "shooting")))
cat(sprintf("    Shots fired: %d\n", sum(chi_harm_key$source == "shots_fired")))

# =============================================================================
# PART 6: QA SUMMARY
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("SUMMARY BY SOURCE\n")
cat(strrep("=", 70), "\n")

chi_harm_key %>%
  group_by(source) %>%
  summarise(
    n_rows     = n(),
    total_n    = comma(sum(n)),
    chi_range  = paste0(comma(min(chi_weight)), " \u2013 ", comma(max(chi_weight))),
    .groups = "drop"
  ) %>%
  print()

cat("\n=== ARREST WEIGHTS: CATEGORY SUMMARY ===\n")
arrest_weights %>%
  group_by(category) %>%
  summarise(
    n_pds      = n(),
    total_n    = comma(sum(n)),
    chi_wtd_mean = round(weighted.mean(chi_weight, n)),
    chi_range  = paste0(min(chi_weight), " \u2013 ", max(chi_weight)),
    .groups = "drop"
  ) %>%
  arrange(desc(chi_wtd_mean)) %>%
  print(n = 15)

cat("\n=== GUN VIOLENCE WEIGHTS ===\n")
chi_harm_key %>%
  filter(source != "arrest") %>%
  select(source, subcategory, chi_weight, displaces_category, n, basis) %>%
  print(n = 15)

cat("\n=== SUBSTITUTION MAP ===\n")
cat("Rows with displaces_category (non-NA) trigger subtraction at block level:\n")
chi_harm_key %>%
  filter(!is.na(displaces_category)) %>%
  select(source, subcategory, chi_weight, displaces_category) %>%
  print()

# =============================================================================
# PART 7: EXPORT
# =============================================================================

cat("\n=== SAVING ===\n")

dir.create(here("data"), showWarnings = FALSE)
dir.create(here("output", "tables"), showWarnings = FALSE)

# Full key
write_csv(chi_harm_key, here("output", "tables", "chi_harm_key.csv"))
saveRDS(chi_harm_key, here("data", "chi_harm_key.rds"))

# Slim arrest-only key (for quick joins)
chi_pd_key <- arrest_weights %>%
  select(category, subcategory, chi_weight) %>%
  rename(offense_description1 = category, pd_description = subcategory)
write_csv(chi_pd_key, here("output", "tables", "chi_pd_key.csv"))
saveRDS(chi_pd_key, here("data", "chi_pd_key.rds"))

cat(sprintf("  Saved: output/tables/chi_harm_key.csv     (%d rows)\n", nrow(chi_harm_key)))
cat(sprintf("  Saved: data/chi_harm_key.rds\n"))
cat(sprintf("  Saved: output/tables/chi_pd_key.csv       (%d rows)\n", nrow(chi_pd_key)))
cat(sprintf("  Saved: data/chi_pd_key.rds\n"))

cat("\nObjects available:\n")
cat("  chi_harm_key  — full unified key (arrests + shootings + shots fired)\n")
cat("                  displaces_category is non-NA for substitution weights\n")
cat("  chi_pd_key    — slim arrest-only key (offense_description1 × pd_description → chi_weight)\n")

cat("\n")
cat(strrep("=", 70), "\n")
cat("UNIFIED HARM KEY v2 COMPLETE\n")
cat(strrep("=", 70), "\n")
