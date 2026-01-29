# =============================================================================
# NYC Crime Harm Index (CHI) - Rebuild Part 1
# =============================================================================
#
# Purpose: Calculate proportion-weighted CHI scores for serious crimes using
# arrest data with actual penal law charges. Examine temporal and geographic
# stability of these weights.
#
# Key approach:
# - Use arrest data (arrests1) which has actual penal law charges
# - Filter to crimes of interest: Murder, Robbery, Felony Assault (incl. strangulation), 
#   Misd Assault (incl. criminal obstruction of breathing)
# - Calculate proportions of specific charges within broader UCR categories
# - Assign harm scores based on NYS Penal Law sentencing guidelines
# - Handle attempt flag (bumps charge down one class)
# - Keep highest-harm charge per incident (complaint_key)
# - Analyze stability across year, borough, and precinct
#
# =============================================================================

library(tidyverse)
library(here)
library(janitor)

# Create output directory
dir.create(here("output"), showWarnings = FALSE)

# =============================================================================
# PART 1: LOAD DATA
# =============================================================================

# Load arrest data with detailed charge info
arrests1 <- read_csv(here("data", "arrests (13).csv")) %>%
  clean_names() %>%
  #remove central park
  filter(arrest_precinct_code != '022')

# Quick look at structure
glimpse(arrests1)

# =============================================================================
# PART 2: NYS PENAL LAW HARM SCORES (days of imprisonment, midpoint)
# =============================================================================

# Based on NYS Penal Law Article 70 sentencing guidelines
# Using midpoint of determinate sentence range for first-time violent felony offenders
# Violent felony classes (Penal Law 70.02):
#   Class B: 5-25 years → midpoint ~15 years → 5475 days
#   Class C: 3.5-15 years → midpoint ~9.25 years → 3378 days (round to 3380)
#   Class D: 2-7 years → midpoint ~4.5 years → 1643 days
#   Class E (violent): 1.5-4 years → midpoint ~2.75 years → 1004 days
# Non-violent felonies:
#   Class D: 0-7 years (can include probation) → midpoint ~3.5 years → 1278 days
#   Class E: 0-4 years → midpoint ~2 years → 730 days
# Misdemeanors:
#   Class A: 0-1 year → midpoint ~0.5 years → 183 days

# Create lookup table for penal law codes to harm scores
# law_code_trim format is like "PL 12010" (PL + first 5 digits of section)

penal_law_chi <- tribble(
  ~law_code_trim, ~offense_name, ~felony_class, ~is_violent, ~chi_days,
  
  # === MURDER & MANSLAUGHTER (PL 125) ===
  "PL 12527", "Murder 1st", "A-I", TRUE, 7300,      # 20-40 years, midpoint ~20 yrs
  "PL 12525", "Murder 2nd", "A-I", TRUE, 5475,      # 15-25 years to life
  "PL 12520", "Manslaughter 1st", "B", TRUE, 5475,  # 5-25 years
  "PL 12515", "Manslaughter 2nd", "C", FALSE, 1643, # Non-violent C felony
  
  # === ASSAULT (PL 120) ===
  "PL 12010", "Assault 1st", "B", TRUE, 5475,       # B violent: 5-25 years
  "PL 12005", "Assault 2nd", "D", TRUE, 1643,       # D violent: 2-7 years
  "PL 12008", "Assault 2nd (variant)", "D", TRUE, 1643,  # D violent: 2-7 years
  "PL 12000", "Assault 3rd", "A Misd", FALSE, 183,  # A misdemeanor: 0-1 year
  "PL 12011", "Aggravated Assault on Police", "B", TRUE, 7300,  # 10-30 years
  "PL 12007", "Assault on Police/Peace Officer", "D", TRUE, 1643,
  "PL 12006", "Gang Assault 2nd", "C", TRUE, 3380,  # C violent
  
  # === STRANGULATION (PL 121) ===
  "PL 12112", "Strangulation 1st", "C", TRUE, 3380, # C violent: 3.5-15 years
  "PL 12113", "Strangulation 2nd", "D", TRUE, 1643, # D violent: 2-7 years
  "PL 12111", "Crim Obstruction of Breathing", "A Misd", FALSE, 183, # A misd
  
  # === ROBBERY (PL 160) ===
  "PL 16015", "Robbery 1st", "B", TRUE, 5475,       # B violent: 5-25 years
  "PL 16010", "Robbery 2nd", "C", TRUE, 3380,       # C violent: 3.5-15 years
  "PL 16005", "Robbery 3rd", "D", TRUE, 1643,       # D violent: 2-7 years
  
  # === BURGLARY (PL 140) - for reference if needed ===
  "PL 14030", "Burglary 1st", "B", TRUE, 5475,
  "PL 14025", "Burglary 2nd", "C", TRUE, 3380,
  "PL 14020", "Burglary 3rd", "D", FALSE, 1278,
  
  # === LARCENY (PL 155) - for reference ===
  "PL 15542", "Grand Larceny 1st", "B", FALSE, 1825,  # Non-violent B
  "PL 15540", "Grand Larceny 2nd", "C", FALSE, 1095,  # Non-violent C
  "PL 15535", "Grand Larceny 3rd", "D", FALSE, 730,
  "PL 15530", "Grand Larceny 4th", "E", FALSE, 365,
  
  # === AUTO THEFT (PL 165) ===
  "PL 16550", "Unauthorized Use MV 1st", "D", FALSE, 730,
  "PL 16505", "Unauthorized Use MV 2nd", "A Misd", FALSE, 183,
)

# Create attempt adjustment function
# Per PL 110.05: Attempts drop crime one class (B→C, C→D, D→E, E→A Misd)
# This maps to reduced chi_days based on the lower class's range

adjust_for_attempt <- function(chi_days, felony_class) {
  case_when(
    # B violent (5475) → C violent (3380)
    felony_class == "B" & chi_days >= 5000 ~ 3380,
    # C violent (3380) → D violent (1643)
    felony_class == "C" ~ 1643,
    # D violent (1643) → E violent (~1000) or A misd (183)
    felony_class == "D" ~ 1004,
    # E felony → A misdemeanor
    felony_class == "E" ~ 183,
    # A-I special case (attempted murder stays serious)
    felony_class == "A-I" ~ 5475,
    # Misdemeanor attempt → B misdemeanor (minimal change)
    felony_class == "A Misd" ~ 91,
    TRUE ~ chi_days * 0.6  # Default reduction
  )
}

# =============================================================================
# PART 3: DEFINE VALID LAW CODES FOR EACH CATEGORY
# =============================================================================

# These are the ONLY law codes that should be included in each offense category
# Based on actual NYPD arrest data charge distributions

# ASSAULT 3 & RELATED OFFENSES (Misdemeanor)
valid_codes_misd_assault <- c(
  "PL 1200000", "PL 1200001", "PL 1200002", "PL 1200003",
  "PL 1201600",
  "PL 1204500", "PL 1204501", "PL 1204502", "PL 1204503",
  "PL 1211100", "PL 121110A", "PL 121110B", "PL 121110H", "PL 12111AH",
  "PL 2407001"
)

# FELONY ASSAULT (includes strangulation 1st/2nd)
valid_codes_felony_assault <- c(
  # Assault with H suffix (appears to be hate crime or other modifier)
  "PL 120000H", "PL 120001H", "PL 120002H", "PL 120003H",
  # Assault 2nd variants (PL 120.05)
  "PL 1200100", "PL 1200200", "PL 1200201",
  "PL 1200500", "PL 1200501", "PL 1200502", "PL 1200503", "PL 1200504",
  "PL 1200505", "PL 1200506", "PL 1200507", "PL 1200508", "PL 1200509",
  "PL 1200510", "PL 1200511", "PL 1200512", "PL 1200513", "PL 1200514",
  "PL 120051H", "PL 120051T", "PL 120051X",
  "PL 120052H", "PL 120052T", "PL 120052X",
  "PL 120053A", "PL 120053B", "PL 120053C", "PL 120053H", "PL 120053X",
  "PL 120054A", "PL 120054H", "PL 120054X",
  "PL 120055H", "PL 120055X",
  "PL 120056X",
  "PL 120057H", "PL 120057T", "PL 120057X",
  "PL 120058H", "PL 120058X",
  "PL 120059H", "PL 120059T", "PL 120059X",
  "PL 12005A3", "PL 12005BA", "PL 12005BB", "PL 12005BC",
  "PL 12005CH", "PL 12005CX", "PL 12005EH", "PL 12005ET",
  "PL 12005H3", "PL 12005JT", "PL 12005JX", "PL 12005KH", "PL 12005SH",
  "PL 12005VX", "PL 12005WH", "PL 12005WT", "PL 12005WX",
  "PL 12005XA", "PL 12005XB", "PL 12005YH", "PL 12005YX",
  # Gang Assault 2nd (PL 120.06)
  "PL 1200600", "PL 120060T", "PL 120060X",
  # Assault on Police (PL 120.07)
  "PL 1200700", "PL 120070H", "PL 120070T", "PL 120070X",
  # Assault 2nd variant (PL 120.08)
  "PL 1200800", "PL 120080T",
  # Assault 1st (PL 120.10)
  "PL 1201000", "PL 1201001", "PL 1201002", "PL 1201003", "PL 1201004",
  "PL 120101H", "PL 120102H", "PL 120102T", "PL 120102X",
  "PL 120103H", "PL 120104X",
  # Aggravated Assault on Police (PL 120.11)
  "PL 1201100", "PL 120110T",
  # PL 120.12
  "PL 1201200", "PL 120120H",
  # PL 120.14
  "PL 1201400",
  # PL 120.19
  "PL 1201900",
  # Additional assault variants
  "PL 120501H", "PL 120502H", "PL 120503H",
  "PL 1205500", "PL 1205501", "PL 1205502", "PL 1205503", "PL 1205504", "PL 1205505",
  "PL 1206000", "PL 1206001", "PL 1206002", "PL 120600X", "PL 120601H", "PL 120602X",
  # Strangulation 1st (PL 121.12)
  "PL 1211200", "PL 121120H", "PL 121120T", "PL 121120X",
  # Strangulation 2nd (PL 121.13)
  "PL 1211300", "PL 121130H", "PL 121130T", "PL 121130X",
  # Other
  "PL 1213A00", "PL 1251100", "PL 130851A"
)

# MURDER & NON-NEGL. MANSLAUGHTER (both spellings in data)
valid_codes_murder <- c(
  # Manslaughter 2nd (PL 125.15)
  "PL 1251500", "PL 1251501", "PL 125151T", "PL 125151X",
  # Manslaughter 1st (PL 125.20)
  "PL 1252000", "PL 1252001", "PL 1252002", "PL 1252004", "PL 125201H",
  # Murder 2nd (PL 125.25)
  "PL 1252500", "PL 1252501", "PL 1252502", "PL 1252503", "PL 1252504", "PL 1252505",
  "PL 125251H", "PL 125251T", "PL 125252H", "PL 125253H", "PL 125253X",
  "PL 125254H", "PL 125254T", "PL 125255H", "PL 125255X",
  "PL 12526A1", "PL 12526A2", "PL 12526A3", "PL 12526WT",
  # Murder 1st (PL 125.27)
  "PL 125270T",
  "PL 125271A", "PL 125271B", "PL 125271D", "PL 125271E", "PL 125271F",
  "PL 125271G", "PL 125271H", "PL 125271I", "PL 125271J", "PL 125271K", "PL 125271M",
  "PL 125272W", "PL 125277X",
  "PL 12527AT", "PL 12527BT", "PL 12527DT", "PL 12527ET", "PL 12527FT",
  "PL 12527GT", "PL 12527IT", "PL 12527KT", "PL 12527WT"
)

# ROBBERY
valid_codes_robbery <- c(
  # Robbery 3rd (PL 160.05)
  "PL 1600500", "PL 160050H", "PL 160050X",
  # Robbery 2nd (PL 160.10)
  "PL 1601001", "PL 1601002", "PL 1601003",
  "PL 160100X", "PL 160101H", "PL 160101T", "PL 160101X",
  "PL 160102A", "PL 160102B", "PL 160102H", "PL 160102X",
  "PL 160103H", "PL 160103X",
  "PL 16010AH", "PL 16010AX", "PL 16010BH", "PL 16010BX",
  # Robbery 1st (PL 160.15)
  "PL 1601501", "PL 1601502", "PL 1601503", "PL 1601504",
  "PL 160150T", "PL 160150X",
  "PL 160151H", "PL 160151T", "PL 160151X",
  "PL 160152H", "PL 160152X",
  "PL 160153H", "PL 160153T", "PL 160153X",
  "PL 160154H", "PL 160154T", "PL 160154X"
)

# =============================================================================
# PART 4: FILTER AND PREPARE ARREST DATA
# =============================================================================

# Define crimes of interest (UCR Part 1 violent + related)
serious_crimes <- c(
  'ASSAULT 3 & RELATED OFFENSES',
  'FELONY ASSAULT', 
  'MURDER & NON-NEGL. MANSLAUGHTE',
  'ROBBERY'
)

# Filter to crimes of interest
chi_arrests <- arrests1 %>%
  filter(offense_description1 %in% serious_crimes) %>%
  # Remove inappropriate charges that sometimes get tacked on
  filter(!pd_description %in% c('MENACING,PEACE OFFICER', 'MENACING,UNCLASSIFIED')) %>%
  # Keep distinct arrests
  distinct(arrest_key, .keep_all = TRUE) %>%
  # Fix known data issues: 114 Precinct is in Queens, not Manhattan
  mutate(
    arrest_boro_code = if_else(arrest_precinct_code == "114", "Q", arrest_boro_code)
  ) %>%
  # Extract trimmed law code (remove sub-section)
  mutate(
    law_code_trim = str_sub(law_code, 1, 8),  # "PL 12005" format
    arrest_year = arrest_year_number,
    is_attempt = (arrest_charge_attempt_flag == "Y")
  ) %>%
  # CRITICAL: Filter to keep only valid penal law codes for each category
  # This drops charges that don't match the complaint category
  filter(
    (offense_description1 == "MURDER & NON-NEGL. MANSLAUGHTE" & law_code %in% valid_codes_murder) |
      (offense_description1 == "FELONY ASSAULT" & law_code %in% valid_codes_felony_assault) |
      (offense_description1 == "ASSAULT 3 & RELATED OFFENSES" & law_code %in% valid_codes_misd_assault) |
      (offense_description1 == "ROBBERY" & law_code %in% valid_codes_robbery)
  )

cat("Total arrests in serious crime categories:", nrow(chi_arrests), "\n")

# Check what law codes we have
cat("\n=== LAW CODES IN DATA ===\n")
law_codes_in_data <- chi_arrests %>%
  count(offense_description1, law_code_trim) %>%
  arrange(offense_description1, desc(n))
print(law_codes_in_data, n = 50)

# =============================================================================
# PART 5: JOIN HARM SCORES AND ADJUST FOR ATTEMPTS
# =============================================================================

chi_arrests_scored <- chi_arrests %>%
  left_join(penal_law_chi, by = "law_code_trim") %>%
  mutate(
    # Apply attempt adjustment
    chi_final = if_else(
      is_attempt & !is.na(chi_days),
      adjust_for_attempt(chi_days, felony_class),
      chi_days
    ),
    # Flag unmatched codes
    has_chi = !is.na(chi_final)
  )

# Check coverage
cat("\n=== CHI COVERAGE ===\n")
chi_coverage <- chi_arrests_scored %>%
  group_by(offense_description1) %>%
  summarise(
    n_total = n(),
    n_matched = sum(has_chi),
    pct_matched = round(100 * mean(has_chi), 1)
  )
print(chi_coverage)

# What's unmatched?
cat("\n=== UNMATCHED LAW CODES ===\n")
unmatched_codes <- chi_arrests_scored %>%
  filter(!has_chi) %>%
  count(offense_description1, law_code_trim, pd_description) %>%
  arrange(desc(n))
print(unmatched_codes, n = 30)

# =============================================================================
# PART 6: HANDLE UNMATCHED CODES
# =============================================================================

# Add additional mappings for common unmatched codes
additional_mappings <- tribble(
  ~law_code_trim, ~chi_days_manual,
  "PL 12001", 1643,   # Assault 2nd variations
  "PL 12002", 1643,   # Assault 2nd
  "PL 12003", 1643,   # Assault 2nd
  "PL 12014", 1643,   # Assault variations  
  "PL 16000", 1643,   # Robbery 3rd (misclassified)
  "PL 16001", 1643,   # Robbery variants
)

# Update scores with manual mappings
chi_arrests_final <- chi_arrests_scored %>%
  left_join(additional_mappings, by = "law_code_trim") %>%
  mutate(
    chi_final = coalesce(chi_final, chi_days_manual),
    # For remaining unmatched, assign based on offense category
    chi_final = case_when(
      !is.na(chi_final) ~ chi_final,
      offense_description1 == "MURDER & NON-NEGL. MANSLAUGHT" ~ 5475,
      offense_description1 == "ROBBERY" ~ 2500,  # Conservative mid-robbery
      offense_description1 == "FELONY ASSAULT" ~ 1643,
      offense_description1 == "ASSAULT 3 & RELATED OFFENSES" ~ 183,
      TRUE ~ 1000  # Default fallback
    )
  )

cat("\n=== FINAL CHI COVERAGE ===\n")
final_chi_coverage <- chi_arrests_final %>%
  group_by(offense_description1) %>%
  summarise(
    n = n(),
    chi_mean = round(mean(chi_final)),
    chi_median = median(chi_final),
    chi_min = min(chi_final),
    chi_max = max(chi_final)
  )
print(final_chi_coverage)

# =============================================================================
# PART 6b: QA TABLES - CHARGE CONTRIBUTION BY CATEGORY
# =============================================================================

# Function to generate contribution table for a category
make_contribution_table <- function(data, category_name) {
  data %>%
    filter(offense_description1 == category_name) %>%
    group_by(law_code_trim, offense_name) %>%
    summarise(
      n = n(),
      chi_weight = first(chi_final),
      total_chi_days = sum(chi_final),
      .groups = "drop"
    ) %>%
    mutate(
      pct_of_arrests = round(100 * n / sum(n), 2),
      pct_of_total_chi = round(100 * total_chi_days / sum(total_chi_days), 2),
      contribution_to_mean = round((n / sum(n)) * chi_weight, 1)
    ) %>%
    arrange(desc(contribution_to_mean))
}

# --- MURDER/MANSLAUGHTER ---
cat("\n")
cat("=======================================================================\n")
cat("QA TABLE: MURDER & NON-NEGL. MANSLAUGHTE - CHARGE CONTRIBUTIONS\n")
cat("=======================================================================\n")
murder_contribution <- make_contribution_table(chi_arrests_final, "MURDER & NON-NEGL. MANSLAUGHTE")
print(murder_contribution, n = 30)
cat(sprintf("\nSum of contributions: %.0f (should ≈ mean)\n", sum(murder_contribution$contribution_to_mean)))

# --- FELONY ASSAULT ---
cat("\n")
cat("=======================================================================\n")
cat("QA TABLE: FELONY ASSAULT - CHARGE CONTRIBUTIONS\n")
cat("=======================================================================\n")
felony_assault_contribution <- make_contribution_table(chi_arrests_final, "FELONY ASSAULT")
print(felony_assault_contribution, n = 30)
cat(sprintf("\nSum of contributions: %.0f (should ≈ mean)\n", sum(felony_assault_contribution$contribution_to_mean)))

# --- MISD ASSAULT ---
cat("\n")
cat("=======================================================================\n")
cat("QA TABLE: ASSAULT 3 & RELATED OFFENSES - CHARGE CONTRIBUTIONS\n")
cat("=======================================================================\n")
misd_assault_contribution <- make_contribution_table(chi_arrests_final, "ASSAULT 3 & RELATED OFFENSES")
print(misd_assault_contribution, n = 30)
cat(sprintf("\nSum of contributions: %.0f (should ≈ mean)\n", sum(misd_assault_contribution$contribution_to_mean)))

# --- ROBBERY ---
cat("\n")
cat("=======================================================================\n")
cat("QA TABLE: ROBBERY - CHARGE CONTRIBUTIONS\n")
cat("=======================================================================\n")
robbery_contribution <- make_contribution_table(chi_arrests_final, "ROBBERY")
print(robbery_contribution, n = 30)
cat(sprintf("\nSum of contributions: %.0f (should ≈ mean)\n", sum(robbery_contribution$contribution_to_mean)))

# Export QA tables
write_csv(murder_contribution, here("output", "qa_murder_charge_breakdown.csv"))
write_csv(felony_assault_contribution, here("output", "qa_felony_assault_charge_breakdown.csv"))
write_csv(misd_assault_contribution, here("output", "qa_misd_assault_charge_breakdown.csv"))
write_csv(robbery_contribution, here("output", "qa_robbery_charge_breakdown.csv"))

# =============================================================================
# PART 7: KEEP HIGHEST HARM PER INCIDENT
# =============================================================================

# When multiple charges per incident, keep the most serious one
chi_per_incident <- chi_arrests_final %>%
  group_by(complaint_key) %>%
  slice_max(chi_final, n = 1, with_ties = FALSE) %>%
  ungroup()

cat("\nIncidents after keeping max harm per complaint_key:", nrow(chi_per_incident), "\n")

# =============================================================================
# PART 8: CALCULATE PROPORTIONS BY YEAR
# =============================================================================

# Calculate proportion of each specific charge within broader UCR category
proportions_by_year <- chi_arrests_final %>%
  group_by(arrest_year, offense_description1, law_code_trim) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(arrest_year, offense_description1) %>%
  mutate(
    total_in_category = sum(n),
    prop = n / total_in_category
  ) %>%
  ungroup()

# Calculate weighted CHI by UCR category and year
weighted_chi_by_year <- chi_arrests_final %>%
  group_by(arrest_year, offense_description1) %>%
  summarise(
    n_arrests = n(),
    chi_mean = mean(chi_final),
    chi_median = median(chi_final),
    chi_sd = sd(chi_final),
    chi_se = chi_sd / sqrt(n_arrests),
    chi_cv = chi_sd / chi_mean,  # Coefficient of variation
    .groups = "drop"
  )

cat("\n=== WEIGHTED CHI BY YEAR ===\n")
weighted_chi_by_year_sorted <- weighted_chi_by_year %>%
  arrange(offense_description1, arrest_year)
print(weighted_chi_by_year_sorted, n = 50)

# =============================================================================
# PART 9: YEAR-OVER-YEAR STABILITY ANALYSIS
# =============================================================================

# Pivot to wide format for correlation analysis
chi_wide <- weighted_chi_by_year %>%
  select(arrest_year, offense_description1, chi_mean) %>%
  pivot_wider(names_from = arrest_year, values_from = chi_mean)

cat("\n=== CHI BY YEAR (WIDE FORMAT) ===\n")
print(chi_wide)

# Calculate year-over-year changes
yoy_changes <- weighted_chi_by_year %>%
  arrange(offense_description1, arrest_year) %>%
  group_by(offense_description1) %>%
  mutate(
    chi_lag = lag(chi_mean),
    chi_change = chi_mean - chi_lag,
    chi_pct_change = 100 * (chi_mean - chi_lag) / chi_lag
  ) %>%
  ungroup()

cat("\n=== YEAR-OVER-YEAR CHI CHANGES ===\n")
yoy_changes_display <- yoy_changes %>%
  filter(!is.na(chi_change)) %>%
  select(arrest_year, offense_description1, chi_mean, chi_change, chi_pct_change)
print(yoy_changes_display, n = 50)

# Summary statistics for stability
stability_summary <- weighted_chi_by_year %>%
  group_by(offense_description1) %>%
  summarise(
    n_years = n(),
    chi_grand_mean = mean(chi_mean),
    chi_between_year_sd = sd(chi_mean),
    chi_cv_between = chi_between_year_sd / chi_grand_mean,
    chi_min_year = min(chi_mean),
    chi_max_year = max(chi_mean),
    chi_range = chi_max_year - chi_min_year,
    chi_range_pct = 100 * chi_range / chi_grand_mean,
    .groups = "drop"
  )

cat("\n=== STABILITY SUMMARY (ACROSS YEARS) ===\n")
print(stability_summary)

# =============================================================================
# PART 10: VARIATION BY BOROUGH
# =============================================================================

weighted_chi_by_boro <- chi_arrests_final %>%
  group_by(arrest_boro_code, offense_description1) %>%
  summarise(
    n_arrests = n(),
    chi_mean = mean(chi_final),
    chi_sd = sd(chi_final),
    chi_cv = chi_sd / chi_mean,
    .groups = "drop"
  )

cat("\n=== CHI BY BOROUGH ===\n")
weighted_chi_by_boro_sorted <- weighted_chi_by_boro %>%
  arrange(offense_description1, arrest_boro_code)
print(weighted_chi_by_boro_sorted, n = 30)

# Borough variation summary
boro_variation <- weighted_chi_by_boro %>%
  group_by(offense_description1) %>%
  summarise(
    n_boros = n(),
    chi_grand_mean = mean(chi_mean),
    chi_between_boro_sd = sd(chi_mean),
    chi_cv_between = chi_between_boro_sd / chi_grand_mean,
    chi_min_boro = min(chi_mean),
    chi_max_boro = max(chi_mean),
    chi_range = chi_max_boro - chi_min_boro,
    chi_range_pct = 100 * chi_range / chi_grand_mean,
    .groups = "drop"
  )

cat("\n=== BOROUGH VARIATION SUMMARY ===\n")
print(boro_variation)

# =============================================================================
# PART 11: VARIATION BY YEAR AND BOROUGH
# =============================================================================

weighted_chi_by_year_boro <- chi_arrests_final %>%
  group_by(arrest_year, arrest_boro_code, offense_description1) %>%
  summarise(
    n_arrests = n(),
    chi_mean = mean(chi_final),
    chi_sd = sd(chi_final),
    .groups = "drop"
  )

# Two-way ANOVA style decomposition (descriptive)
year_boro_summary <- weighted_chi_by_year_boro %>%
  group_by(offense_description1) %>%
  summarise(
    overall_mean = mean(chi_mean),
    overall_sd = sd(chi_mean),
    n_cells = n(),
    .groups = "drop"
  )

cat("\n=== YEAR x BOROUGH VARIATION ===\n")
print(year_boro_summary)

# =============================================================================
# PART 12: VARIATION BY PRECINCT
# =============================================================================

weighted_chi_by_pct <- chi_arrests_final %>%
  group_by(arrest_precinct_code, arrest_boro_code, offense_description1) %>%
  summarise(
    n_arrests = n(),
    chi_mean = mean(chi_final),
    chi_sd = sd(chi_final),
    .groups = "drop"
  ) %>%
  filter(n_arrests >= 30)  # Require minimum sample size

# Precinct variation summary
pct_variation <- weighted_chi_by_pct %>%
  group_by(offense_description1) %>%
  summarise(
    n_precincts = n(),
    chi_grand_mean = mean(chi_mean),
    chi_between_pct_sd = sd(chi_mean),
    chi_cv_between = chi_between_pct_sd / chi_grand_mean,
    chi_min_pct = min(chi_mean),
    chi_max_pct = max(chi_mean),
    chi_range = chi_max_pct - chi_min_pct,
    chi_range_pct = 100 * chi_range / chi_grand_mean,
    .groups = "drop"
  )

cat("\n=== PRECINCT VARIATION SUMMARY ===\n")
print(pct_variation)

# =============================================================================
# PART 13: INTRACLASS CORRELATION (ICC)
# =============================================================================

# ICC tells us what proportion of variance is at higher levels (year, boro, pct)
# vs. within-cell variation

# Simple ICC calculation for year
calc_icc <- function(data, group_var, value_var) {
  # Group means
  group_means <- data %>%
    group_by({{ group_var }}) %>%
    summarise(
      group_mean = mean({{ value_var }}),
      group_n = n(),
      .groups = "drop"
    )
  
  overall_mean <- mean(data %>% pull({{ value_var }}))
  
  # Between-group variance
  ssb <- sum(group_means$group_n * (group_means$group_mean - overall_mean)^2)
  dfb <- nrow(group_means) - 1
  msb <- ssb / dfb
  
  # Within-group variance (pooled)
  data_with_means <- data %>%
    group_by({{ group_var }}) %>%
    mutate(group_mean = mean({{ value_var }})) %>%
    ungroup()
  
  ssw <- sum((data_with_means %>% pull({{ value_var }}) - data_with_means$group_mean)^2)
  dfw <- nrow(data) - nrow(group_means)
  msw <- ssw / dfw
  
  # ICC
  n_avg <- nrow(data) / nrow(group_means)
  icc <- (msb - msw) / (msb + (n_avg - 1) * msw)
  
  return(list(icc = icc, msb = msb, msw = msw, n_groups = nrow(group_means)))
}

# ICC by offense type for different levels
cat("\n=== INTRACLASS CORRELATIONS ===\n")

for (offense in unique(chi_arrests_final$offense_description1)) {
  cat("\n---", offense, "---\n")
  
  subset_data <- chi_arrests_final %>% filter(offense_description1 == offense)
  
  # ICC for year
  icc_year <- calc_icc(subset_data, arrest_year, chi_final)
  cat(sprintf("  ICC (Year): %.4f (k=%d groups)\n", icc_year$icc, icc_year$n_groups))
  
  # ICC for borough  
  icc_boro <- calc_icc(subset_data, arrest_boro_code, chi_final)
  cat(sprintf("  ICC (Borough): %.4f (k=%d groups)\n", icc_boro$icc, icc_boro$n_groups))
  
  # ICC for precinct
  icc_pct <- calc_icc(subset_data, arrest_precinct_code, chi_final)
  cat(sprintf("  ICC (Precinct): %.4f (k=%d groups)\n", icc_pct$icc, icc_pct$n_groups))
}

# =============================================================================
# PART 14: EXPORT RESULTS
# =============================================================================

write_csv(weighted_chi_by_year, here("output", "chi_by_year.csv"))
write_csv(weighted_chi_by_boro, here("output", "chi_by_boro.csv"))
write_csv(weighted_chi_by_year_boro, here("output", "chi_by_year_boro.csv"))
write_csv(weighted_chi_by_pct, here("output", "chi_by_precinct.csv"))
write_csv(stability_summary, here("output", "chi_stability_summary.csv"))
write_csv(boro_variation, here("output", "chi_boro_variation.csv"))
write_csv(pct_variation, here("output", "chi_precinct_variation.csv"))

# Final recommended weights (grand mean across all years)
recommended_chi <- chi_arrests_final %>%
  group_by(offense_description1) %>%
  summarise(
    n_total = n(),
    chi_recommended = round(mean(chi_final)),
    chi_95_lower = round(quantile(chi_final, 0.025)),
    chi_95_upper = round(quantile(chi_final, 0.975)),
    .groups = "drop"
  )

cat("\n=== RECOMMENDED CHI WEIGHTS ===\n")
print(recommended_chi)

write_csv(recommended_chi, here("output", "chi_recommended_weights.csv"))

cat("\n=== FILES SAVED TO output/ ===\n")
list.files(here("output"))



# =============================================================================
# PART 15: PUBLICATION-QUALITY DESCRIPTIVE PLOTS
# =============================================================================

library(scales)

# Define a conservative, colorblind-friendly palette (grays + one accent)
palette_gray <- c(
  "ASSAULT 3 & RELATED OFFENSES" = "#969696",
  "FELONY ASSAULT" = "#636363",
  "MURDER & NON-NEGL. MANSLAUGHTE" = "#252525",
  "ROBBERY" = "#525252"
)

# Clean offense labels for publication
offense_labels <- c(
  
  "ASSAULT 3 & RELATED OFFENSES" = "Misdemeanor Assault",
  "FELONY ASSAULT" = "Felony Assault",
  "MURDER & NON-NEGL. MANSLAUGHTE" = "Murder/Manslaughter",
  "ROBBERY" = "Robbery"
)

# Base theme for publication
theme_pub <- function() {
  theme_minimal(base_size = 11, base_family = "sans") +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.line = element_line(color = "black", linewidth = 0.3),
      axis.ticks = element_line(color = "black", linewidth = 0.3),
      axis.ticks.length = unit(0.15, "cm"),
      plot.title = element_text(face = "bold", size = 12, hjust = 0),
      plot.subtitle = element_text(size = 10, hjust = 0, color = "gray40"),
      plot.caption = element_text(size = 8, hjust = 1, color = "gray50"),
      legend.position = "bottom",
      legend.title = element_blank(),
      strip.text = element_text(face = "bold", size = 10)
    )
}

# -----------------------------------------------------------------------------
# Plot 1: CHI Stability Over Time (line plot with confidence bands)
# -----------------------------------------------------------------------------

p1_data <- weighted_chi_by_year %>%
  mutate(
    offense_clean = offense_labels[offense_description1],
    chi_lower = chi_mean - 1.96 * chi_se,
    chi_upper = chi_mean + 1.96 * chi_se
  )

p1 <- ggplot(p1_data, aes(x = arrest_year, y = chi_mean, group = offense_clean)) +
  geom_ribbon(aes(ymin = chi_lower, ymax = chi_upper), 
              fill = "gray80", alpha = 0.5) +
  geom_line(linewidth = 0.8, color = "black") +
  geom_point(size = 2, color = "black", fill = "white", shape = 21) +
  facet_wrap(~ offense_clean, scales = "free_y", ncol = 2) +
  scale_x_continuous(breaks = 2018:2022) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Crime Harm Index Stability Over Time",
    subtitle = "Mean CHI score by offense category with 95% confidence intervals",
    x = "Arrest Year",
    y = "Mean CHI (days)",
    caption = "Note: CHI based on NYS Penal Law sentencing guidelines. N = 259,641 arrests (2018-2022)."
  ) +
  theme_pub()
p1

ggsave(here("output", "fig1_chi_temporal_stability.png"), p1, 
       width = 7, height = 6, dpi = 300, bg = "white")
ggsave(here("output", "fig1_chi_temporal_stability.pdf"), p1, 
       width = 7, height = 6, bg = "white")

cat("Saved: fig1_chi_temporal_stability\n")

# -----------------------------------------------------------------------------
# Plot 2: CHI Distribution by Borough (dot plot with error bars)
# -----------------------------------------------------------------------------

p2_data <- weighted_chi_by_boro %>%
  mutate(
    offense_clean = offense_labels[offense_description1],
    boro_name = case_when(
      arrest_boro_code == "B" ~ "Bronx",
      arrest_boro_code == "K" ~ "Brooklyn",
      arrest_boro_code == "M" ~ "Manhattan",
      arrest_boro_code == "Q" ~ "Queens",
      arrest_boro_code == "S" ~ "Staten Island"
    ),
    chi_se = chi_sd / sqrt(n_arrests),
    chi_lower = chi_mean - 1.96 * chi_se,
    chi_upper = chi_mean + 1.96 * chi_se
  )

# Add grand mean reference lines
grand_means <- p2_data %>%
  group_by(offense_clean) %>%
  summarise(grand_mean = weighted.mean(chi_mean, n_arrests), .groups = "drop")

p2 <- ggplot(p2_data, aes(x = reorder(boro_name, chi_mean), y = chi_mean)) +
  geom_hline(data = grand_means, aes(yintercept = grand_mean),
             linetype = "dashed", color = "gray50", linewidth = 0.5) +
  geom_errorbar(aes(ymin = chi_lower, ymax = chi_upper), 
                width = 0.2, linewidth = 0.5, color = "gray40") +
  geom_point(size = 3, color = "black") +
  facet_wrap(~ offense_clean, scales = "free_y", ncol = 2) +
  scale_y_continuous(labels = comma) +
  coord_flip() +
  labs(
    title = "Crime Harm Index by Borough",
    subtitle = "Mean CHI score with 95% CI; dashed line = citywide mean",
    x = NULL,
    y = "Mean CHI (days)",
    caption = "Note: Boroughs ordered by mean CHI within each offense category."
  ) +
  theme_pub() +
  theme(panel.grid.major.y = element_blank())
p2
ggsave(here("output", "fig2_chi_borough_variation.png"), p2, 
       width = 7, height = 6, dpi = 300, bg = "white")
ggsave(here("output", "fig2_chi_borough_variation.pdf"), p2, 
       width = 7, height = 6, bg = "white")

cat("Saved: fig2_chi_borough_variation\n")

# -----------------------------------------------------------------------------
# Plot 3: Precinct-Level Variation (coefficient plot / caterpillar plot)
# -----------------------------------------------------------------------------

p3_data <- weighted_chi_by_pct %>%
  mutate(
    offense_clean = offense_labels[offense_description1],
    chi_se = chi_sd / sqrt(n_arrests),
    chi_lower = chi_mean - 1.96 * chi_se,
    chi_upper = chi_mean + 1.96 * chi_se
  ) %>%
  group_by(offense_clean) %>%
  mutate(
    rank = rank(chi_mean),
    grand_mean = weighted.mean(chi_mean, n_arrests)
  ) %>%
  ungroup()

p3 <- ggplot(p3_data, aes(x = rank, y = chi_mean)) +
  geom_hline(aes(yintercept = grand_mean), 
             linetype = "dashed", color = "gray50", linewidth = 0.5) +
  geom_errorbar(aes(ymin = chi_lower, ymax = chi_upper), 
                width = 0, linewidth = 0.3, color = "gray60") +
  geom_point(size = 1.5, color = "black") +
  facet_wrap(~ offense_clean, scales = "free", ncol = 2) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Crime Harm Index Variation Across Precincts",
    subtitle = "Each point = one precinct (ranked by mean CHI); dashed line = citywide mean",
    x = "Precinct Rank (by CHI)",
    y = "Mean CHI (days)",
    caption = "Note: Precincts with n < 30 arrests excluded. Error bars = 95% CI."
  ) +
  theme_pub() +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    panel.grid.major.x = element_blank()
  )
p3
ggsave(here("output", "fig3_chi_precinct_variation.png"), p3, 
       width = 8, height = 6, dpi = 300, bg = "white")
ggsave(here("output", "fig3_chi_precinct_variation.pdf"), p3, 
       width = 8, height = 6, bg = "white")

cat("Saved: fig3_chi_precinct_variation\n")

# -----------------------------------------------------------------------------
# Plot 4: Coefficient of Variation Summary (bar chart)
# -----------------------------------------------------------------------------

cv_summary <- bind_rows(
  stability_summary %>%
    select(offense_description1, cv = chi_cv_between) %>%
    mutate(level = "Year"),
  boro_variation %>%
    select(offense_description1, cv = chi_cv_between) %>%
    mutate(level = "Borough"),
  pct_variation %>%
    select(offense_description1, cv = chi_cv_between) %>%
    mutate(level = "Precinct")
) %>%
  mutate(
    offense_clean = offense_labels[offense_description1],
    level = factor(level, levels = c("Year", "Borough", "Precinct"))
  )

p4 <- ggplot(cv_summary, aes(x = offense_clean, y = cv * 100, fill = level)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6, color = "black", linewidth = 0.3) +
  scale_fill_manual(values = c("Year" = "white", "Borough" = "gray60", "Precinct" = "gray30")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "Sources of Variation in Crime Harm Index",
    subtitle = "Coefficient of variation (%) at each geographic/temporal level",
    x = NULL,
    y = "Coefficient of Variation (%)",
    caption = "Note: Lower CV indicates greater stability of CHI weights across units."
  ) +
  theme_pub() +
  theme(
    axis.text.x = element_text(angle = 30, hjust = 1),
    legend.position = "right"
  )
p4
ggsave(here("output", "fig4_chi_cv_comparison.png"), p4, 
       width = 7, height = 5, dpi = 300, bg = "white")
ggsave(here("output", "fig4_chi_cv_comparison.pdf"), p4, 
       width = 7, height = 5, bg = "white")

cat("Saved: fig4_chi_cv_comparison\n")

# -----------------------------------------------------------------------------
# Plot 5: Year-over-Year Percent Change (slope chart)
# -----------------------------------------------------------------------------

p5_data <- yoy_changes %>%
  filter(!is.na(chi_pct_change)) %>%
  mutate(offense_clean = offense_labels[offense_description1])

p5 <- ggplot(p5_data, aes(x = arrest_year, y = chi_pct_change)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "gray70", linewidth = 0.5) +
  geom_col(fill = "gray40", color = "black", linewidth = 0.3, width = 0.6) +
  facet_wrap(~ offense_clean, ncol = 2) +
  scale_x_continuous(breaks = 2019:2022) +
  scale_y_continuous(labels = function(x) paste0(ifelse(x > 0, "+", ""), round(x, 1), "%")) +
  labs(
    title = "Year-over-Year Change in Crime Harm Index",
    subtitle = "Percent change in mean CHI from prior year",
    x = "Arrest Year",
    y = "Change from Prior Year (%)",
    caption = "Note: Positive values indicate higher severity mix; negative values indicate lower severity."
  ) +
  theme_pub()
p5
ggsave(here("output", "fig5_chi_yoy_change.png"), p5, 
       width = 7, height = 6, dpi = 300, bg = "white")
ggsave(here("output", "fig5_chi_yoy_change.pdf"), p5, 
       width = 7, height = 6, bg = "white")

cat("Saved: fig5_chi_yoy_change\n")

# -----------------------------------------------------------------------------
# Plot 6: Final Recommended Weights (horizontal bar chart)
# -----------------------------------------------------------------------------

p6_data <- recommended_chi %>%
  mutate(
    offense_clean = offense_labels[offense_description1],
    offense_clean = fct_reorder(offense_clean, chi_recommended)
  )

p6 <- ggplot(p6_data, aes(x = offense_clean, y = chi_recommended)) +
  geom_col(fill = "gray30", color = "black", linewidth = 0.3, width = 0.6) +
  geom_errorbar(aes(ymin = chi_95_lower, ymax = chi_95_upper), 
                width = 0.2, linewidth = 0.5) +
  geom_text(aes(label = comma(chi_recommended)), 
            hjust = -0.2, size = 3.5, fontface = "bold") +
  coord_flip() +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Recommended Crime Harm Index Weights",
    subtitle = "Mean CHI (days) with 2.5th–97.5th percentile range",
    x = NULL,
    y = "CHI Weight (days)",
    caption = "Note: Weights derived from NYS Penal Law Article 70 sentencing guidelines.\nBased on actual charge distributions in NYPD arrest data (2018-2022)."
  ) +
  theme_pub() +
  theme(panel.grid.major.y = element_blank())
p6
ggsave(here("output", "fig6_chi_recommended_weights.png"), p6, 
       width = 7, height = 4, dpi = 300, bg = "white")
ggsave(here("output", "fig6_chi_recommended_weights.pdf"), p6, 
       width = 7, height = 4, bg = "white")

cat("Saved: fig6_chi_recommended_weights\n")

cat("\n=== ALL PLOTS SAVED ===\n")

