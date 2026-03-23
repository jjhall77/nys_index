# =============================================================================
# NYC Crime Harm Index - Setup Script v2
# =============================================================================
#
# COMPLETE REBUILD with audit-first approach
#
# Categories included (7 majors + 3 additional):
#   1. MURDER & NON-NEGL. MANSLAUGHTER
#   2. RAPE
#   3. ROBBERY
#   4. FELONY ASSAULT
#   5. BURGLARY
#   6. GRAND LARCENY
#   7. GRAND LARCENY OF MOTOR VEHICLE
#   8. ASSAULT 3 & RELATED OFFENSES
#   9. PETIT LARCENY
#  10. SEX CRIMES
#
# Methodology:
#   - NO pre-filtering by offense_description
#   - Comprehensive CHI lookup table with trimmed law codes
#   - Simple join: if law_code_trim matches lookup, gets CHI
#   - Full audit trail of what matched and what didn't
#
# =============================================================================

library(tidyverse)
library(lubridate)
library(janitor)
library(here)
library(scales)

# Create output directories
dir.create(here("output", "tables"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("output", "figures"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("output", "audit"), recursive = TRUE, showWarnings = FALSE)

# =============================================================================
# PARAMETERS
# =============================================================================

YEAR_START <- 2018
YEAR_END   <- 2022

cat("="
    |> strrep(70), "\n")
cat("NYC CRIME HARM INDEX - SETUP v2\n")
cat("=" |> strrep(70), "\n\n")

cat("Parameters:\n")
cat(sprintf("  Year range: %d - %d (by complaint date)\n", YEAR_START, YEAR_END))

# =============================================================================
# OFFENSE CATEGORIES OF INTEREST
# =============================================================================

# 7 Major Felonies (UCR Part I equivalents) + 3 additional
target_offenses <- c(
  # 7 Majors
  "MURDER & NON-NEGL. MANSLAUGHTE",
  "RAPE",
  "ROBBERY",
  "FELONY ASSAULT",
  "BURGLARY",
  "GRAND LARCENY",
  "GRAND LARCENY OF MOTOR VEHICLE",
  # Additional
  "ASSAULT 3 & RELATED OFFENSES",
  "PETIT LARCENY",
  "SEX CRIMES"
)

cat("\nTarget offense categories:\n")
for (off in target_offenses) {
  cat(sprintf("  - %s\n", off))
}

# =============================================================================
# NYS PENAL LAW CHI LOOKUP TABLE
# =============================================================================
#
# Methodology: TRUE MIDPOINT of sentencing ranges
#
# Sources:
#   - PL 70.00: Non-violent felony sentences (indeterminate)
#   - PL 70.02: Violent felony sentences (determinate)
#   - PL 70.15: Misdemeanor sentences
#   - PL 70.00(3): A-I felony sentences (Murder)
#
# Sentencing ranges and midpoints:
#
# A-I FELONIES (INDETERMINATE TO LIFE):
#   Murder 1st: 20-40 years to life → midpoint 30 years = 10,950 days
#   Murder 2nd: 15-25 years to life → midpoint 20 years = 7,300 days
#
# VIOLENT FELONIES (DETERMINATE, PL 70.02):
#   B Violent: 5-25 years → midpoint 15 years = 5,475 days
#   C Violent: 3.5-15 years → midpoint 9.25 years = 3,380 days
#   D Violent: 2-7 years → midpoint 4.5 years = 1,643 days
#   E Violent: 1.5-4 years → midpoint 2.75 years = 1,004 days
#
# NON-VIOLENT FELONIES (INDETERMINATE, PL 70.00):
#   B Non-Violent: 1-9 years → midpoint 5 years = 1,825 days
#   C Non-Violent: 1-5.5 years → midpoint 3.25 years = 1,186 days
#   D Non-Violent: 0-2.5 years → midpoint 1.25 years = 456 days
#   E Non-Violent: 0-1.5 years → midpoint 0.75 years = 274 days
#
# MISDEMEANORS (PL 70.15):
#   A Misdemeanor: 0-1 year → midpoint 0.5 years = 183 days
#   B Misdemeanor: 0-90 days → midpoint 45 days
#
# =============================================================================

cat("\n")
cat("=" |> strrep(70), "\n")
cat("BUILDING CHI LOOKUP TABLE\n")
cat("=" |> strrep(70), "\n")

penal_law_chi <- tribble(
  ~law_code_trim, ~offense_name, ~pl_section, ~felony_class, ~is_violent, ~chi_days, ~notes,
  
  
  # =========================================================================
  # ARTICLE 125: HOMICIDE
  # =========================================================================
  "PL 12527", "Murder 1st", "125.27", "A-I", TRUE, 10950, "20-40 yrs to life; midpoint 30 yrs",
  "PL 12525", "Murder 2nd", "125.25", "A-I", TRUE, 7300, "15-25 yrs to life; midpoint 20 yrs",
  "PL 12522", "Aggravated Murder", "125.26", "A-I", TRUE, 10950, "Life without parole eligible",
  "PL 12520", "Manslaughter 1st", "125.20", "B", TRUE, 5475, "B Violent: 5-25 yrs",
  "PL 12515", "Manslaughter 2nd", "125.15", "C", FALSE, 1186, "C Non-Violent (NOT in 70.02)",
  "PL 12512", "Vehicular Manslaughter 1st", "125.13", "C", TRUE, 3380, "C Violent",
  "PL 12510", "Vehicular Manslaughter 2nd", "125.12", "D", FALSE, 456, "D Non-Violent",
  "PL 12505", "Criminally Negligent Homicide", "125.10", "E", FALSE, 274, "E Non-Violent",
  
  # =========================================================================
  # ARTICLE 130: SEX OFFENSES
  # =========================================================================
  # Rape
  "PL 13035", "Rape 1st", "130.35", "B", TRUE, 5475, "B Violent",
  "PL 13030", "Rape 2nd", "130.30", "D", TRUE, 1643, "D Violent",
  "PL 13025", "Rape 3rd", "130.25", "E", TRUE, 1004, "E Violent per 70.02",
  
  # Criminal Sexual Act
  "PL 13050", "Criminal Sexual Act 1st", "130.50", "B", TRUE, 5475, "B Violent",
  "PL 13045", "Criminal Sexual Act 2nd", "130.45", "D", TRUE, 1643, "D Violent",
  "PL 13040", "Criminal Sexual Act 3rd", "130.40", "E", TRUE, 1004, "E Violent",
  
  # Predatory Sexual Assault
  "PL 13096", "Predatory Sexual Assault Against Child", "130.96", "A-II", TRUE, 7300, "A-II: 10-25 yrs",
  "PL 13095", "Predatory Sexual Assault", "130.95", "A-II", TRUE, 7300, "A-II: 10-25 yrs",
  
  # Aggravated Sexual Abuse
  "PL 13070", "Aggravated Sexual Abuse 1st", "130.70", "B", TRUE, 5475, "B Violent",
  "PL 13067", "Aggravated Sexual Abuse 2nd", "130.67", "C", TRUE, 3380, "C Violent",
  "PL 13066", "Aggravated Sexual Abuse 3rd", "130.66", "D", TRUE, 1643, "D Violent",
  "PL 13065", "Aggravated Sexual Abuse 4th", "130.65-a", "E", TRUE, 1004, "E Violent",
  
  # Sexual Abuse
  "PL 13055", "Sexual Abuse 1st", "130.65", "D", TRUE, 1643, "D Violent",
  "PL 13060", "Sexual Abuse 2nd", "130.60", "A Misd", FALSE, 183, "A Misdemeanor",
  "PL 13052", "Sexual Abuse 3rd", "130.55", "B Misd", FALSE, 45, "B Misdemeanor",
  
  # Forcible Touching / Sexual Misconduct
  "PL 13053", "Forcible Touching", "130.52", "A Misd", FALSE, 183, "A Misdemeanor",
  "PL 13020", "Sexual Misconduct", "130.20", "A Misd", FALSE, 183, "A Misdemeanor",
  
  # Course of Sexual Conduct
  "PL 13075", "Course of Sexual Conduct 1st", "130.75", "B", TRUE, 5475, "B Violent",
  "PL 13080", "Course of Sexual Conduct 2nd", "130.80", "D", TRUE, 1643, "D Violent",
  
  # =========================================================================
  # ARTICLE 120: ASSAULT & RELATED
  # =========================================================================
  # Assault
  "PL 12010", "Assault 1st", "120.10", "B", TRUE, 5475, "B Violent",
  "PL 12005", "Assault 2nd", "120.05", "D", TRUE, 1643, "D Violent",
  "PL 12000", "Assault 3rd", "120.00", "A Misd", FALSE, 183, "A Misdemeanor",
  
  # Aggravated Assault
  "PL 12011", "Aggravated Assault on Police", "120.11", "B", TRUE, 5475, "B Violent",
  "PL 12012", "Aggravated Assault on <11yr or 65+", "120.12", "E", TRUE, 1004, "E Violent",
  
  # Gang Assault
  "PL 12007", "Gang Assault 1st", "120.07", "B", TRUE, 5475, "B Violent",
  "PL 12006", "Gang Assault 2nd", "120.06", "C", TRUE, 3380, "C Violent",
  
  # Assault on Specific Victims
  "PL 12008", "Assault on Police/Fire/EMS", "120.08", "C", TRUE, 3380, "C Violent",
  
  # Vehicular Assault
  "PL 12004", "Vehicular Assault 1st", "120.04", "D", TRUE, 1643, "D Violent",
  "PL 12003", "Vehicular Assault 2nd", "120.03", "E", FALSE, 274, "E Non-Violent",
  "PL 12004A", "Aggravated Vehicular Assault", "120.04-a", "C", TRUE, 3380, "C Violent",
  
  # Menacing
  "PL 12018", "Menacing Police/Peace Officer", "120.18", "D", TRUE, 1643, "D Violent",
  "PL 12015", "Menacing 1st", "120.13", "E", TRUE, 1004, "E Violent",
  "PL 12014", "Menacing 2nd", "120.14", "A Misd", FALSE, 183, "A Misdemeanor",
  "PL 12013", "Menacing 3rd", "120.15", "B Misd", FALSE, 45, "B Misdemeanor",
  
  # Reckless Endangerment
  "PL 12025", "Reckless Endangerment 1st", "120.25", "D", TRUE, 1643, "D Violent",
  "PL 12020", "Reckless Endangerment 2nd", "120.20", "A Misd", FALSE, 183, "A Misdemeanor",
  
  # Stalking
  "PL 12060", "Stalking 1st", "120.60", "D", TRUE, 1643, "D Violent per 70.02(1)(c)",
  "PL 12055", "Stalking 2nd", "120.55", "E", FALSE, 274, "E Non-Violent",
  "PL 12050", "Stalking 3rd", "120.50", "A Misd", FALSE, 183, "A Misdemeanor",
  "PL 12045", "Stalking 4th", "120.45", "B Misd", FALSE, 45, "B Misdemeanor",
  
  # Hazing
  "PL 12017", "Hazing 1st", "120.16", "A Misd", FALSE, 183, "A Misdemeanor",
  "PL 12016", "Hazing 2nd", "120.17", "Violation", FALSE, 15, "Violation",
  
  # =========================================================================
  # ARTICLE 121: STRANGULATION
  # =========================================================================
  # CRITICAL: 121.12 = 2nd degree, 121.13 = 1st degree (counterintuitive)
  "PL 12113", "Strangulation 1st", "121.13", "C", TRUE, 3380, "C Violent",
  "PL 12112", "Strangulation 2nd", "121.12", "D", TRUE, 1643, "D Violent",
  "PL 12111", "Criminal Obstruction of Breathing", "121.11", "A Misd", FALSE, 183, "A Misdemeanor",
  
  # =========================================================================
  # ARTICLE 160: ROBBERY
  # =========================================================================
  "PL 16015", "Robbery 1st", "160.15", "B", TRUE, 5475, "B Violent",
  "PL 16010", "Robbery 2nd", "160.10", "C", TRUE, 3380, "C Violent",
  "PL 16005", "Robbery 3rd", "160.05", "D", TRUE, 1643, "D Violent",
  
  # =========================================================================
  # ARTICLE 140: BURGLARY & TRESPASS
  # =========================================================================
  "PL 14030", "Burglary 1st", "140.30", "B", TRUE, 5475, "B Violent",
  "PL 14025", "Burglary 2nd", "140.25", "C", TRUE, 3380, "C Violent",
  "PL 14020", "Burglary 3rd", "140.20", "D", FALSE, 456, "D Non-Violent (NOT in 70.02)",
  "PL 14017", "Aggravated Criminal Trespass", "140.17", "E", FALSE, 274, "E Non-Violent",
  "PL 14015", "Criminal Trespass 1st", "140.15", "D", FALSE, 456, "D Non-Violent",
  "PL 14010", "Criminal Trespass 2nd", "140.10", "A Misd", FALSE, 183, "A Misdemeanor",
  "PL 14005", "Criminal Trespass 3rd", "140.05", "B Misd", FALSE, 45, "B Misdemeanor",
  
  # =========================================================================
  # ARTICLE 155: LARCENY
  # =========================================================================
  "PL 15542", "Grand Larceny 1st", "155.42", "B", FALSE, 1825, "B Non-Violent: 1-9 yrs",
  "PL 15540", "Grand Larceny 2nd", "155.40", "C", FALSE, 1186, "C Non-Violent",
  "PL 15535", "Grand Larceny 3rd", "155.35", "D", FALSE, 456, "D Non-Violent",
  "PL 15530", "Grand Larceny 4th", "155.30", "E", FALSE, 274, "E Non-Violent",
  "PL 15525", "Petit Larceny", "155.25", "A Misd", FALSE, 183, "A Misdemeanor",
  
  # =========================================================================
  # ARTICLE 165: THEFT-RELATED OFFENSES
  # =========================================================================
  # Auto Theft
  "PL 16550", "Unauthorized Use MV 1st", "165.50", "E", FALSE, 274, "E Non-Violent (not UUV 2nd)",
  "PL 16505", "Unauthorized Use MV 2nd", "165.05", "A Misd", FALSE, 183, "A Misdemeanor",
  "PL 16508", "Unauthorized Use MV 3rd", "165.08", "D", FALSE, 456, "D Non-Violent (fleet theft)",
  
  # Other Theft
  "PL 16545", "Criminal Possession Stolen Property 1st", "165.54", "B", FALSE, 1825, "B Non-Violent",
  "PL 16552", "Criminal Possession Stolen Property 2nd", "165.52", "C", FALSE, 1186, "C Non-Violent",
  "PL 16550", "Criminal Possession Stolen Property 3rd", "165.50", "D", FALSE, 456, "D Non-Violent",
  "PL 16545", "Criminal Possession Stolen Property 4th", "165.45", "E", FALSE, 274, "E Non-Violent",
  "PL 16540", "Criminal Possession Stolen Property 5th", "165.40", "A Misd", FALSE, 183, "A Misdemeanor"
)

cat(sprintf("\nCHI lookup table: %d offense codes\n", nrow(penal_law_chi)))

# Show CHI distribution
cat("\nCHI values in lookup:\n")
penal_law_chi %>%
  count(chi_days, felony_class, is_violent) %>%
  arrange(desc(chi_days)) %>%
  print(n = 20)

# =============================================================================
# ATTEMPT ADJUSTMENT FUNCTION
# =============================================================================

# Per PL 110.05: Attempts drop crime one class
adjust_for_attempt <- function(chi_days, felony_class, is_violent) {
  case_when(
    # A-I/A-II (Murder/Predatory Sex) → B violent
    felony_class %in% c("A-I", "A-II") ~ 5475,
    # B violent → C violent
    felony_class == "B" & is_violent ~ 3380,
    # B non-violent → C non-violent
    felony_class == "B" & !is_violent ~ 1186,
    # C violent → D violent
    felony_class == "C" & is_violent ~ 1643,
    # C non-violent → D non-violent
    felony_class == "C" & !is_violent ~ 456,
    # D violent → E violent
    felony_class == "D" & is_violent ~ 1004,
    # D non-violent → E non-violent
    felony_class == "D" & !is_violent ~ 274,
    # E → A misdemeanor
    felony_class == "E" ~ 183,
    # A misdemeanor → B misdemeanor
    felony_class == "A Misd" ~ 45,
    # B misdemeanor → violation
    felony_class == "B Misd" ~ 15,
    TRUE ~ chi_days * 0.5
  )
}

# =============================================================================
# LOAD RAW ARREST DATA
# =============================================================================

cat("\n")
cat("=" |> strrep(70), "\n")
cat("LOADING ARREST DATA\n")
cat("=" |> strrep(70), "\n")

arrests_raw <- read_csv(here("data", "arrests (13).csv"), show_col_types = FALSE) %>%
  clean_names()

cat(sprintf("\nRaw arrests loaded: %s\n", comma(nrow(arrests_raw))))

# =============================================================================
# BASIC CLEANING (NO CATEGORY FILTERING YET)
# =============================================================================

cat("\nApplying basic cleaning...\n")

arrests_clean <- arrests_raw %>%
  # Exclude Central Park precinct
  filter(arrest_precinct_code != "022") %>%
  # Keep distinct arrests
  distinct(arrest_key, .keep_all = TRUE) %>%
  # Create date fields
  mutate(
    complaint_date = ymd(rpt_dt),
    complaint_year = year(complaint_date),
    arrest_date = ymd(arrest_date),
    arrest_year = year(arrest_date),
    # Trimmed law code for matching (first 8 chars)
    law_code_trim = str_sub(law_code, 1, 8),
    # Attempt flag
    is_attempt = (arrest_charge_attempt_flag == "Y")
  ) %>%
  # Fix known data issues
  mutate(
    arrest_boro_code = if_else(arrest_precinct_code == "114", "Q", arrest_boro_code)
  ) %>%
  # Filter to analysis years
  filter(complaint_year >= YEAR_START & complaint_year <= YEAR_END)

cat(sprintf("  After basic cleaning: %s arrests\n", comma(nrow(arrests_clean))))

# =============================================================================
# FILTER TO TARGET OFFENSES (for audit)
# =============================================================================

cat("\nFiltering to target offense categories...\n")

arrests_target <- arrests_clean %>%
  filter(offense_description1 %in% target_offenses)

cat(sprintf("  Arrests in target categories: %s\n", comma(nrow(arrests_target))))

# Show distribution
cat("\n=== ARRESTS BY OFFENSE CATEGORY ===\n")
arrests_target %>%
  count(offense_description1) %>%
  arrange(desc(n)) %>%
  print()

# =============================================================================
# AUDIT: ALL LAW CODES BY OFFENSE DESCRIPTION
# =============================================================================

cat("\n")
cat("=" |> strrep(70), "\n")
cat("AUDIT: LAW CODES BY OFFENSE DESCRIPTION\n")
cat("=" |> strrep(70), "\n")

# -----------------------------------------------------------------------------
# STEP 1: Build empirical crosswalk - what offense does each law code USUALLY fall under?
# -----------------------------------------------------------------------------

Mode <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) == 0) return(NA_character_)
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

# Empirical crosswalk: for each law_code_trim, what's the modal offense_description1?
law_code_crosswalk <- arrests_clean %>%
  group_by(law_code_trim) %>%
  summarise(
    modal_offense = Mode(offense_description1),
    n_total = n(),
    .groups = "drop"
  )

cat(sprintf("\nEmpirical crosswalk: %s unique law codes\n", comma(nrow(law_code_crosswalk))))

# -----------------------------------------------------------------------------
# STEP 2: Define valid exceptions (codes that legitimately appear under different offense)
# -----------------------------------------------------------------------------

# These are codes that can LEGITIMATELY appear under a different offense_description1
# than their modal offense. The logic handles specific known cross-category situations.

# Article 125 (Homicide) exceptions:
#   - Under MURDER = completed offense (valid)
#   - Under FELONY ASSAULT = attempt (valid)
# Note: Modal might be one or the other depending on data mix

# Article 155 (Grand Larceny) exceptions:
#   - Under GRAND LARCENY = standard (valid)
#   - Under GRAND LARCENY OF MOTOR VEHICLE = valid (NYPD distinction, not penal code)

valid_exceptions <- tribble(
  ~law_code_trim, ~exception_offense, ~reason,
  
  # === Article 125: Homicide (valid under both Murder AND Felony Assault) ===
  "PL 12527", "MURDER & NON-NEGL. MANSLAUGHTE", "Murder 1st (completed)",
  "PL 12527", "FELONY ASSAULT", "Attempted Murder 1st",
  "PL 12525", "MURDER & NON-NEGL. MANSLAUGHTE", "Murder 2nd (completed)",
  "PL 12525", "FELONY ASSAULT", "Attempted Murder 2nd",
  "PL 12522", "MURDER & NON-NEGL. MANSLAUGHTE", "Aggravated Murder (completed)",
  "PL 12522", "FELONY ASSAULT", "Attempted Aggravated Murder",
  "PL 12520", "MURDER & NON-NEGL. MANSLAUGHTE", "Manslaughter 1st (completed)",
  "PL 12520", "FELONY ASSAULT", "Attempted Manslaughter 1st",
  "PL 12515", "MURDER & NON-NEGL. MANSLAUGHTE", "Manslaughter 2nd (completed)",
  "PL 12515", "FELONY ASSAULT", "Attempted Manslaughter 2nd",
  "PL 12512", "MURDER & NON-NEGL. MANSLAUGHTE", "Vehicular Manslaughter 1st",
  "PL 12510", "MURDER & NON-NEGL. MANSLAUGHTE", "Vehicular Manslaughter 2nd",
  "PL 12505", "MURDER & NON-NEGL. MANSLAUGHTE", "Criminally Negligent Homicide",
  
  # === Article 155: Grand Larceny (valid under both GL and GLMV) ===
  "PL 15542", "GRAND LARCENY", "Grand Larceny 1st",
  "PL 15542", "GRAND LARCENY OF MOTOR VEHICLE", "Grand Larceny 1st (of MV)",
  "PL 15540", "GRAND LARCENY", "Grand Larceny 2nd",
  "PL 15540", "GRAND LARCENY OF MOTOR VEHICLE", "Grand Larceny 2nd (of MV)",
  "PL 15535", "GRAND LARCENY", "Grand Larceny 3rd",
  "PL 15535", "GRAND LARCENY OF MOTOR VEHICLE", "Grand Larceny 3rd (of MV)",
  "PL 15530", "GRAND LARCENY", "Grand Larceny 4th",
  "PL 15530", "GRAND LARCENY OF MOTOR VEHICLE", "Grand Larceny 4th (of MV)"
)

cat(sprintf("\nValid exceptions defined: %s code × offense combinations\n", nrow(valid_exceptions)))

# -----------------------------------------------------------------------------
# STEP 3: For target offenses, identify which law codes are "appropriate"
# -----------------------------------------------------------------------------

# A law code is appropriate for an offense_description1 if:
#   (a) That offense is its modal_offense, OR
#   (b) It's a valid exception

appropriate_codes <- law_code_crosswalk %>%
  filter(modal_offense %in% target_offenses) %>%
  select(law_code_trim, modal_offense) %>%
  # Add exceptions
  
  bind_rows(
    valid_exceptions %>%
      select(law_code_trim, modal_offense = exception_offense)
  ) %>%
  distinct()

cat(sprintf("Appropriate codes for target offenses: %s\n", comma(nrow(appropriate_codes))))

# -----------------------------------------------------------------------------
# STEP 4: Audit - compare actual data to appropriate codes
# -----------------------------------------------------------------------------

# Get totals by offense_description1 and pd_description
totals_by_offense <- arrests_target %>%
  count(offense_description1, name = "n_offense_total")

totals_by_pd <- arrests_target %>%
  count(offense_description1, pd_description, name = "n_pd_total")

# Count every law_code_trim within each offense_description1/pd_description
law_code_audit <- arrests_target %>%
  count(offense_description1, pd_description, law_code_trim, name = "n_arrests") %>%
  # Join totals for percentage calculations
  left_join(totals_by_offense, by = "offense_description1") %>%
  left_join(totals_by_pd, by = c("offense_description1", "pd_description")) %>%
  # Join empirical crosswalk
  left_join(law_code_crosswalk, by = "law_code_trim") %>%
  # Join to CHI lookup
  left_join(
    penal_law_chi %>% select(law_code_trim, offense_name, pl_section, chi_days, is_violent, notes),
    by = "law_code_trim"
  ) %>%
  # Determine if code is appropriate for this offense
  # First, create a lookup key for valid exceptions
  left_join(
    valid_exceptions %>% 
      mutate(is_valid_exception = TRUE) %>%
      select(law_code_trim, exception_offense, is_valid_exception),
    by = c("law_code_trim", "offense_description1" = "exception_offense")
  ) %>%
  mutate(
    # Check if this is the modal offense for this code
    is_modal_offense = (offense_description1 == modal_offense),
    # Replace NA with FALSE for valid exception check
    is_valid_exception = replace_na(is_valid_exception, FALSE),
    # Code is appropriate if modal OR valid exception
    is_appropriate = is_modal_offense | is_valid_exception,
    # Has CHI weight
    has_chi = !is.na(chi_days),
    chi_days = if_else(is.na(chi_days), 0, chi_days),
    # Percentage calculations
    pct_of_pd = 100 * n_arrests / n_pd_total,
    pct_of_offense = 100 * n_arrests / n_offense_total
  ) %>%
  arrange(offense_description1, pd_description, desc(n_arrests))

cat(sprintf("\nUnique combinations: %s\n", comma(nrow(law_code_audit))))

# -----------------------------------------------------------------------------
# STEP 5: Summarize match rates and appropriateness
# -----------------------------------------------------------------------------

match_summary <- law_code_audit %>%
  group_by(offense_description1) %>%
  summarise(
    n_combinations = n(),
    n_arrests_total = sum(n_arrests),
    # Appropriate codes (modal or exception)
    n_arrests_appropriate = sum(n_arrests[is_appropriate]),
    pct_appropriate = 100 * n_arrests_appropriate / n_arrests_total,
    # Has CHI weight
    n_arrests_has_chi = sum(n_arrests[has_chi]),
    pct_has_chi = 100 * n_arrests_has_chi / n_arrests_total,
    # Both appropriate AND has CHI
    n_arrests_valid = sum(n_arrests[is_appropriate & has_chi]),
    pct_valid = 100 * n_arrests_valid / n_arrests_total,
    .groups = "drop"
  )

cat("\n=== MATCH RATE BY OFFENSE CATEGORY ===\n")
cat("appropriate = modal offense or valid exception\n")
cat("has_chi = has weight in CHI lookup\n")
cat("valid = appropriate AND has_chi\n\n")
print(match_summary %>% 
        mutate(across(starts_with("pct"), ~round(., 1))))

# =============================================================================
# EXPORT AUDIT FILES
# =============================================================================

cat("\n=== EXPORTING AUDIT FILES ===\n")

# 1. Full audit with all codes
write_csv(law_code_audit, here("output", "audit", "law_code_audit_full.csv"))
cat("  Saved: output/audit/law_code_audit_full.csv\n")

# 2. Empirical crosswalk (what offense each law code belongs to)
write_csv(law_code_crosswalk, here("output", "audit", "law_code_crosswalk.csv"))
cat("  Saved: output/audit/law_code_crosswalk.csv\n")

# 3. Appropriate codes by offense (the "whitelist" derived from data)
appropriate_by_offense <- law_code_audit %>%
  filter(is_appropriate) %>%
  group_by(offense_description1, law_code_trim, modal_offense, is_valid_exception) %>%
  summarise(
    n_arrests = sum(n_arrests),
    has_chi = any(has_chi),
    chi_days = max(chi_days),
    .groups = "drop"
  ) %>%
  arrange(offense_description1, desc(n_arrests))

write_csv(appropriate_by_offense, here("output", "audit", "appropriate_codes_by_offense.csv"))
cat("  Saved: output/audit/appropriate_codes_by_offense.csv\n")

# 4. Inappropriate codes (errant charges - code appears under wrong offense)
inappropriate_codes <- law_code_audit %>%
  filter(!is_appropriate) %>%
  select(
    offense_description1,
    pd_description,
    law_code_trim,
    modal_offense,
    n_arrests,
    pct_of_pd,
    pct_of_offense,
    n_pd_total,
    n_offense_total
  ) %>%
  arrange(offense_description1, desc(n_arrests)) %>%
  mutate(
    pct_of_pd = round(pct_of_pd, 2),
    pct_of_offense = round(pct_of_offense, 3)
  )

write_csv(inappropriate_codes, here("output", "audit", "inappropriate_codes.csv"))
cat("  Saved: output/audit/inappropriate_codes.csv\n")
cat(sprintf("         (%s combinations, %s arrests are errant charges)\n",
            comma(nrow(inappropriate_codes)),
            comma(sum(inappropriate_codes$n_arrests))))

# 5. Appropriate but missing CHI (need to add to lookup)
missing_chi <- law_code_audit %>%
  filter(is_appropriate & !has_chi) %>%
  select(
    offense_description1,
    pd_description,
    law_code_trim,
    n_arrests,
    pct_of_pd,
    pct_of_offense
  ) %>%
  arrange(offense_description1, desc(n_arrests)) %>%
  mutate(
    pct_of_pd = round(pct_of_pd, 2),
    pct_of_offense = round(pct_of_offense, 3)
  )

write_csv(missing_chi, here("output", "audit", "missing_chi_weights.csv"))
cat("  Saved: output/audit/missing_chi_weights.csv\n")
cat(sprintf("         (%s combinations, %s arrests need CHI weights added)\n",
            comma(nrow(missing_chi)),
            comma(sum(missing_chi$n_arrests))))

# 6. Summary by offense
write_csv(match_summary, here("output", "audit", "match_summary_by_offense.csv"))
cat("  Saved: output/audit/match_summary_by_offense.csv\n")

# 7. Valid exceptions (codes that legitimately appear under different offense)
write_csv(valid_exceptions, here("output", "audit", "valid_exceptions.csv"))
cat("  Saved: output/audit/valid_exceptions.csv\n")

# =============================================================================
# SHOW KEY AUDIT RESULTS
# =============================================================================

cat("\n=== TOP 20 INAPPROPRIATE CODES (errant charges) ===\n")
cat("These appear under the wrong offense_description1\n\n")
inappropriate_codes %>%
  head(20) %>%
  print(n = 20)

cat("\n=== TOP 20 MISSING CHI WEIGHTS ===\n")
cat("These are appropriate but need CHI lookup entries\n\n")
missing_chi %>%
  head(20) %>%
  print(n = 20)

# =============================================================================
# CREATE FINAL ARRESTS WITH CHI
# =============================================================================

cat("\n")
cat("=" |> strrep(70), "\n")
cat("CREATING FINAL DATASET WITH CHI\n")
cat("=" |> strrep(70), "\n")

# Get the appropriate + has_chi codes from audit
valid_combinations <- law_code_audit %>%
  filter(is_appropriate & has_chi) %>%
  distinct(offense_description1, law_code_trim)

cat(sprintf("\nValid offense × law_code combinations: %s\n", comma(nrow(valid_combinations))))

arrests_with_chi <- arrests_target %>%
  # Only keep appropriate codes for each offense
  semi_join(valid_combinations, by = c("offense_description1", "law_code_trim")) %>%
  # Join to CHI lookup
  left_join(
    penal_law_chi %>% select(law_code_trim, offense_name, pl_section, felony_class, is_violent, chi_days),
    by = "law_code_trim"
  ) %>%
  # Apply attempt adjustment for Article 125 under Felony Assault
  mutate(
    is_attempt_art125 = (offense_description1 == "FELONY ASSAULT" & str_detect(law_code, "^PL 125")),
    is_attempt_final = is_attempt | is_attempt_art125,
    chi_adjusted = if_else(
      is_attempt_final,
      adjust_for_attempt(chi_days, felony_class, is_violent),
      chi_days
    )
  )

cat(sprintf("Arrest records with CHI: %s\n", comma(nrow(arrests_with_chi))))

# =============================================================================
# AGGREGATE TO INCIDENT LEVEL
# =============================================================================

cat("\nAggregating to incident level (one record per complaint_key)...\n")

# Keep highest CHI charge per incident
incidents_chi <- arrests_with_chi %>%
  group_by(complaint_key) %>%
  slice_max(order_by = chi_adjusted, n = 1, with_ties = FALSE) %>%
  ungroup()

cat(sprintf("  Unique incidents: %s\n", comma(nrow(incidents_chi))))

# Summary by offense
cat("\n=== INCIDENTS BY OFFENSE CATEGORY ===\n")
incidents_chi %>%
  count(offense_description1) %>%
  arrange(desc(n)) %>%
  print()

# =============================================================================
# SAVE OUTPUTS
# =============================================================================

cat("\n=== SAVING DATA FILES ===\n")

saveRDS(arrests_with_chi, here("data", "arrests_with_chi.rds"))
saveRDS(incidents_chi, here("data", "incidents_chi.rds"))
saveRDS(penal_law_chi, here("data", "penal_law_chi.rds"))

write_csv(penal_law_chi, here("output", "tables", "chi_lookup_table.csv"))

cat("  Saved: data/arrests_with_chi.rds\n")
cat("  Saved: data/incidents_chi.rds\n")
cat("  Saved: data/penal_law_chi.rds\n")
cat("  Saved: output/tables/chi_lookup_table.csv\n")

# =============================================================================
# SUMMARY STATISTICS
# =============================================================================

cat("\n")
cat("=" |> strrep(70), "\n")
cat("SUMMARY STATISTICS\n")
cat("=" |> strrep(70), "\n")

cat("\n=== CHI BY OFFENSE CATEGORY ===\n")
incidents_chi %>%
  group_by(offense_description1) %>%
  summarise(
    n_incidents = n(),
    chi_mean = mean(chi_adjusted),
    chi_median = median(chi_adjusted),
    chi_sd = sd(chi_adjusted),
    chi_min = min(chi_adjusted),
    chi_max = max(chi_adjusted),
    .groups = "drop"
  ) %>%
  arrange(desc(chi_mean)) %>%
  mutate(
    chi_mean = round(chi_mean),
    chi_median = round(chi_median),
    chi_sd = round(chi_sd)
  ) %>%
  print()

cat("\n=== CHI BY YEAR ===\n")
incidents_chi %>%
  group_by(complaint_year) %>%
  summarise(
    n_incidents = n(),
    chi_mean = round(mean(chi_adjusted)),
    total_chi = sum(chi_adjusted),
    .groups = "drop"
  ) %>%
  print()

# =============================================================================
# SETUP COMPLETE
# =============================================================================

cat("\n")
cat("=" |> strrep(70), "\n")
cat("SETUP COMPLETE\n")
cat("=" |> strrep(70), "\n")

cat("\nObjects available:\n")
cat("  - arrests_with_chi: All arrest records with CHI scores (appropriate codes only)\n")
cat("  - incidents_chi: One record per incident (highest CHI)\n")
cat("  - penal_law_chi: CHI lookup table\n")
cat("  - law_code_crosswalk: Empirical mapping of law codes to offense descriptions\n")
cat("  - law_code_audit: Full audit of all codes\n")

cat("\nAudit files in output/audit/:\n")
cat("  - law_code_crosswalk.csv: Modal offense for each law code (data-driven)\n")
cat("  - appropriate_codes_by_offense.csv: Valid codes per offense (the 'whitelist')\n")
cat("  - inappropriate_codes.csv: Errant charges (code under wrong offense)\n")
cat("  - missing_chi_weights.csv: Appropriate codes missing CHI (ADD THESE)\n")
cat("  - valid_exceptions.csv: Codes that legitimately cross categories (e.g., attempted murder)\n")
cat("  - match_summary_by_offense.csv: Summary statistics\n")
cat("  - law_code_audit_full.csv: Complete audit trail\n")

cat("\nNEXT STEPS:\n")
cat("  1. Review missing_chi_weights.csv - add these to CHI lookup\n")
cat("  2. Review inappropriate_codes.csv - confirm these are truly errant\n")
cat("  3. Update valid_exceptions if needed\n")
cat("  4. Re-run and verify match rates\n")
cat("  5. Run model comparison scripts\n")