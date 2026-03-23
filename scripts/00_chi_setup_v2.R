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
#   Convention: "to life" sentences cannot be meaningfully midpointed because
#   the life tail makes the range unbounded. Instead, we use max-of-minimum
#   as an anchor for the lowest-ranked A-I (Murder 2nd), then apply a 
#   LWOP-eligibility premium for Murder 1st.
#
#   Murder 2nd (PL 125.25): min range 15-25 yrs to life (PL 70.00(3)(a)(i))
#     → midpoint of min range = 20 yrs = 7,300 days
#   Murder 1st (PL 125.27): min range 20-25 yrs to life (PL 70.00(3)(a)(i)(A))
#     → 1.5× Murder 2nd = 10,950 days (LWOP-eligible per PL 70.00(5))
#   Aggravated Murder (PL 125.26): mandatory LWOP → pegged to Murder 1st
#
#   NOTE: The naive midpoint of Murder 1st's min range (22.5 yrs = 8,213 days)
#   would produce a lower weight than attempted Murder 1st under PL 110.05
#   class reduction (20-40 yrs, midpoint 30 yrs = 10,950), violating the
#   monotonicity constraint that attempts must score ≤ completed offenses.
#   The 1.5× multiplier resolves this paradox. Attempted Murder 1st and
#   attempted Aggravated Murder score equal to their completed versions
#   (both 10,950) because LWOP makes the completed offense effectively
#   unbounded — equality is the least-bad resolution and acceptable for
#   a place-based harm index where the distinction does no analytic work.
#
# VIOLENT FELONIES (DETERMINATE, PL 70.02):
#   B Violent: 5-25 years → midpoint 15.0 years = 5,475 days
#   C Violent: 3.5-15 years → midpoint 9.25 years = 3,376 days
#   D Violent: 2-7 years → midpoint 4.5 years = 1,643 days
#   E Violent: 1.5-4 years → midpoint 2.75 years = 1,004 days
#
# NON-VIOLENT FELONIES (INDETERMINATE, PL 70.00):
#   Derived from the minimum period range: PL 70.00(3) requires min ≥ 1 yr
#   and min ≤ (max term / 3). Range of minimum period = 1 yr to (class_cap/3).
#   B Non-Violent: 1 to 25/3 yrs → midpoint 4.667 years = 1,703 days
#   C Non-Violent: 1 to 5 yrs → midpoint 3.0 years = 1,095 days
#   D Non-Violent: 1 to 7/3 yrs → midpoint 1.667 years = 608 days
#   E Non-Violent: 1 to 4/3 yrs → midpoint 1.167 years = 426 days
#
# MISDEMEANORS (PL 70.15):
#   A Misdemeanor: 0-364 days → midpoint 182 days (364-day max per 70.15(1-a))
#   B Misdemeanor: 0-90 days → midpoint 45 days
#
# =============================================================================

cat("\n")
cat("=" |> strrep(70), "\n")
cat("BUILDING CHI LOOKUP TABLE\n")
cat("=" |> strrep(70), "\n")

penal_law_chi <- tribble(
  ~law_code_trim, ~offense_name, ~pl_section, ~felony_class, ~is_violent, ~sentencing_regime, ~chi_days, ~notes,
  
  
  # =========================================================================
  # ARTICLE 125: HOMICIDE
  # =========================================================================
  "PL 12527", "Murder 1st", "125.27", "A-I", TRUE, "70.00", 10950, "1.5x Murder 2nd (LWOP-eligible); min range 20-25 to life per 70.00(3)(a)(i)(A)",
  "PL 12525", "Murder 2nd", "125.25", "A-I", TRUE, "70.00", 7300, "Min range 15-25 to life per 70.00(3)(a)(i); midpoint of min = 20 yrs",
  "PL 12526", "Aggravated Murder", "125.26", "A-I", TRUE, "70.00", 10950, "Life without parole eligible; pegged to Murder 1st",
  "PL 12520", "Manslaughter 1st", "125.20", "B", TRUE, "70.02", 5475, "B Violent: 5-25 yrs; VFO per 70.02(1)(a)",
  "PL 12522", "Aggravated Manslaughter 1st", "125.22", "B", TRUE, "70.02", 7300, "B Violent; ENHANCED range 10-30 per 70.02(3)(a)(ii); midpoint 20 yrs",
  "PL 12521", "Aggravated Manslaughter 2nd", "125.21", "C", TRUE, "70.02", 4928, "C Violent; ENHANCED range 7-20 per 70.02(3)(b)(i); midpoint 13.5 yrs",
  "PL 12511", "Aggravated Criminally Negligent Homicide", "125.11", "C", TRUE, "70.02", 4289, "C Violent; ENHANCED range 3.5-20 per 70.02(3)(b)(iii); midpoint 11.75 yrs",
  "PL 12515", "Manslaughter 2nd", "125.15", "C", FALSE, "70.00", 1095, "C Non-Violent (NOT in 70.02); min period 1-5 yrs, midpoint 3",
  "PL 12513", "Vehicular Manslaughter 1st", "125.13", "C", FALSE, "70.00", 1095, "C Non-Violent (NOT in 70.02)",
  "PL 12512", "Vehicular Manslaughter 2nd", "125.12", "D", FALSE, "70.00", 608, "D Non-Violent; min period 1-2.33 yrs, midpoint 1.667",
  "PL 12510", "Criminally Negligent Homicide", "125.10", "E", FALSE, "70.00", 426, "E Non-Violent; min period 1-1.33 yrs, midpoint 1.167",
  
  # =========================================================================
  # ARTICLE 130: SEX OFFENSES
  # =========================================================================
  #
  # SENTENCING NOTE: Article 130 felonies are "felony sex offenses" under
  # PL 70.80, which imposes DETERMINATE sentences with ranges that mirror
  # the 70.02 violent felony ranges:
  #   B: 5-25 yrs    C: 3.5-15 yrs    D: 2-7 yrs    E: 1.5-4 yrs
  #
  # EXCEPTION: PL 70.80(3) explicitly carves out the A-II predatory offenses
  # (130.95 Predatory Sexual Assault, 130.96 PSA Against a Child) from the
  # 70.80 determinate structure. These are sentenced under PL 70.00 as
  # indeterminate sentences: min period 10-25 yrs, max term = life.
  #
  # Non-VFO Article 130 felonies (e.g., Rape 3rd, CSA 3rd) get the SAME
  # chi_days as VFOs of the same class, even though is_violent=FALSE,
  # because 70.80 supersedes 70.00 for B-E sex offenses.
  #
  # 70.80(1)(a) includes "felony attempt or conspiracy" in the definition
  # of "felony sex offense," so attempted Article 130 felonies also use
  # 70.80 ranges at the reduced attempt class.
  #
  # Misdemeanor Article 130 offenses remain under 70.15.
  # =========================================================================
  
  # Rape
  "PL 13035", "Rape 1st", "130.35", "B", TRUE, "70.02", 5475, "B Violent; VFO per 70.02(1)(a)",
  "PL 13030", "Rape 2nd", "130.30", "D", TRUE, "70.02", 1643, "D Violent; VFO per 70.02(1)(c)",
  "PL 13025", "Rape 3rd", "130.25", "E", FALSE, "70.80", 1004, "E felony sex offense; NOT a VFO per 70.02 but sentenced under 70.80(4)(a)(iv) at 1.5-4 yrs determinate",
  
  # Criminal Sexual Act
  "PL 13050", "Criminal Sexual Act 1st", "130.50", "B", TRUE, "70.02", 5475, "B Violent; VFO per 70.02(1)(a)",
  "PL 13045", "Criminal Sexual Act 2nd", "130.45", "D", TRUE, "70.02", 1643, "D Violent; VFO per 70.02(1)(c)",
  "PL 13040", "Criminal Sexual Act 3rd", "130.40", "E", FALSE, "70.80", 1004, "E felony sex offense; NOT a VFO per 70.02 but sentenced under 70.80(4)(a)(iv) at 1.5-4 yrs determinate",
  
  # Predatory Sexual Assault
  "PL 13096", "Predatory Sexual Assault Against Child", "130.96", "A-II", TRUE, "70.00", 6388, "A-II indeterminate; min period 10-25 to life per 70.00(3)(a)(ii); 70.80(3) carveout; midpoint of min = 17.5 yrs",
  "PL 13095", "Predatory Sexual Assault", "130.95", "A-II", TRUE, "70.00", 6388, "A-II indeterminate; min period 10-25 to life per 70.00(3)(a)(ii); 70.80(3) carveout; midpoint of min = 17.5 yrs",
  
  # Aggravated Sexual Abuse
  "PL 13070", "Aggravated Sexual Abuse 1st", "130.70", "B", TRUE, "70.02", 5475, "B Violent; VFO per 70.02(1)(a)",
  "PL 13067", "Aggravated Sexual Abuse 2nd", "130.67", "C", TRUE, "70.02", 3376, "C Violent; VFO per 70.02(1)(b)",
  "PL 13066", "Aggravated Sexual Abuse 3rd", "130.66", "D", TRUE, "70.02", 1643, "D Violent; VFO per 70.02(1)(c)",
  # NOTE: 130.65-a shares base code with 130.65 (Sexual Abuse 1st) under 8-char trim.
  # Using "PL 13065A" to disambiguate — VERIFY against your actual NYPD law_code values.
  "PL 13065A", "Aggravated Sexual Abuse 4th", "130.65-a", "E", TRUE, "70.02", 1004, "E Violent; VFO per 70.02(1)(d)",
  
  # Sexual Abuse
  "PL 13065", "Sexual Abuse 1st", "130.65", "D", TRUE, "70.02", 1643, "D Violent; VFO per 70.02(1)(c)",
  "PL 13060", "Sexual Abuse 2nd", "130.60", "A Misd", FALSE, "70.15", 182, "A Misdemeanor (364 days max per 70.15(1-a))",
  "PL 13055", "Sexual Abuse 3rd", "130.55", "B Misd", FALSE, "70.15", 45, "B Misdemeanor",
  
  # Forcible Touching / Sexual Misconduct
  "PL 13052", "Forcible Touching", "130.52", "A Misd", FALSE, "70.15", 182, "A Misdemeanor",
  "PL 13020", "Sexual Misconduct", "130.20", "A Misd", FALSE, "70.15", 182, "A Misdemeanor",
  
  # Course of Sexual Conduct
  "PL 13075", "Course of Sexual Conduct 1st", "130.75", "B", TRUE, "70.02", 5475, "B Violent; VFO per 70.02(1)(a)",
  "PL 13080", "Course of Sexual Conduct 2nd", "130.80", "D", TRUE, "70.02", 1643, "D Violent; VFO per 70.02(1)(c)",
  
  # =========================================================================
  # ARTICLE 120: ASSAULT & RELATED
  # =========================================================================
  # Assault
  "PL 12010", "Assault 1st", "120.10", "B", TRUE, "70.02", 5475, "B Violent; VFO per 70.02(1)(a)",
  "PL 12005", "Assault 2nd", "120.05", "D", TRUE, "70.02", 1643, "D Violent; VFO per 70.02(1)(c)",
  "PL 12000", "Assault 3rd", "120.00", "A Misd", FALSE, "70.15", 182, "A Misdemeanor",
  
  # Aggravated Assault
  "PL 12011", "Aggravated Assault on Police", "120.11", "B", TRUE, "70.02", 7300, "B Violent; ENHANCED range 10-30 per 70.02(3)(a)(i); midpoint 20 yrs",
  "PL 12012", "Aggravated Assault on Person <11yr", "120.12", "E", FALSE, "70.00", 426, "E Non-Violent (NOT in 70.02)",
  
  # Gang Assault
  "PL 12007", "Gang Assault 1st", "120.07", "B", TRUE, "70.02", 5475, "B Violent; VFO per 70.02(1)(a)",
  "PL 12006", "Gang Assault 2nd", "120.06", "C", TRUE, "70.02", 3376, "C Violent; VFO per 70.02(1)(b)",
  
  # Assault on Specific Victims
  # NOTE: PL 120.08 requires "serious physical injury" to a police/fire/EMS victim,
  # but NYPD RMS practice is to charge 120.08 based on victim category alone (i.e.,
  # the officer/firefighter/EMT status) rather than the actual injury threshold.
  # The vast majority of these arrests are functionally PL 120.05 (Assault 2nd)
  # conduct. We therefore score 120.08 as D Violent (matching 120.05) rather than
  # C Violent to reflect the empirical charging reality, not the statutory ceiling.
  "PL 12008", "Assault on Police/Fire/EMS", "120.08", "D", TRUE, "70.02", 1643, "D Violent (scored as 120.05); see note re NYPD overcharging of 120.08",
  
  # Vehicular Assault
  "PL 12004", "Vehicular Assault 1st", "120.04", "D", FALSE, "70.00", 608, "D Non-Violent (NOT in 70.02)",
  "PL 12003", "Vehicular Assault 2nd", "120.03", "E", FALSE, "70.00", 426, "E Non-Violent",
  "PL 12004A", "Aggravated Vehicular Assault", "120.04-a", "C", FALSE, "70.00", 1095, "C Non-Violent (NOT in 70.02)",
  
  # Menacing
  # NOTE: 120.18 has enhanced range per 70.02(3)(c)(i): 2-8 yrs, midpoint 5 yrs
  "PL 12018", "Menacing Police/Peace Officer", "120.18", "D", TRUE, "70.02", 1825, "D Violent; VFO per 70.02(1)(c); ENHANCED range 2-8 per 70.02(3)(c)(i)",
  "PL 12013", "Menacing 1st", "120.13", "E", FALSE, "70.00", 426, "E Non-Violent (NOT in 70.02)",
  "PL 12014", "Menacing 2nd", "120.14", "A Misd", FALSE, "70.15", 182, "A Misdemeanor",
  "PL 12015", "Menacing 3rd", "120.15", "B Misd", FALSE, "70.15", 45, "B Misdemeanor",
  
  # Reckless Endangerment
  "PL 12025", "Reckless Endangerment 1st", "120.25", "D", FALSE, "70.00", 608, "D Non-Violent (NOT in 70.02)",
  "PL 12020", "Reckless Endangerment 2nd", "120.20", "A Misd", FALSE, "70.15", 182, "A Misdemeanor",
  
  # Stalking
  "PL 12060", "Stalking 1st", "120.60", "D", TRUE, "70.02", 1643, "D Violent; VFO per 70.02(1)(c)",
  "PL 12055", "Stalking 2nd", "120.55", "E", FALSE, "70.00", 426, "E Non-Violent",
  "PL 12050", "Stalking 3rd", "120.50", "A Misd", FALSE, "70.15", 182, "A Misdemeanor",
  "PL 12045", "Stalking 4th", "120.45", "B Misd", FALSE, "70.15", 45, "B Misdemeanor",
  
  # Hazing
  "PL 12016", "Hazing 1st", "120.16", "A Misd", FALSE, "70.15", 182, "A Misdemeanor",
  "PL 12017", "Hazing 2nd", "120.17", "Violation", FALSE, "70.15", 8, "Violation; midpoint of 0-15 days per 70.15(4)",
  
  # =========================================================================
  # ARTICLE 121: STRANGULATION
  # =========================================================================
  # CRITICAL: 121.12 = 2nd degree, 121.13 = 1st degree (counterintuitive)
  "PL 12113", "Strangulation 1st", "121.13", "C", TRUE, "70.02", 3376, "C Violent; VFO per 70.02(1)(b)",
  "PL 12112", "Strangulation 2nd", "121.12", "D", TRUE, "70.02", 1643, "D Violent; VFO per 70.02(1)(c)",
  "PL 12111", "Criminal Obstruction of Breathing", "121.11", "A Misd", FALSE, "70.15", 182, "A Misdemeanor",
  
  # =========================================================================
  # ARTICLE 160: ROBBERY
  # =========================================================================
  "PL 16015", "Robbery 1st", "160.15", "B", TRUE, "70.02", 5475, "B Violent; VFO per 70.02(1)(a)",
  "PL 16010", "Robbery 2nd", "160.10", "C", TRUE, "70.02", 3376, "C Violent; VFO per 70.02(1)(b)",
  "PL 16005", "Robbery 3rd", "160.05", "D", FALSE, "70.00", 608, "D Non-Violent (NOT in 70.02)",
  
  # =========================================================================
  # ARTICLE 140: BURGLARY & TRESPASS
  # =========================================================================
  "PL 14030", "Burglary 1st", "140.30", "B", TRUE, "70.02", 5475, "B Violent; VFO per 70.02(1)(a)",
  "PL 14025", "Burglary 2nd", "140.25", "C", TRUE, "70.02", 3376, "C Violent; VFO per 70.02(1)(b)",
  "PL 14020", "Burglary 3rd", "140.20", "D", FALSE, "70.00", 608, "D Non-Violent (NOT in 70.02)",
  "PL 14017", "Criminal Trespass 1st", "140.17", "D", FALSE, "70.00", 608, "D Non-Violent",
  "PL 14015", "Criminal Trespass 2nd", "140.15", "A Misd", FALSE, "70.15", 182, "A Misdemeanor",
  "PL 14010", "Criminal Trespass 3rd", "140.10", "B Misd", FALSE, "70.15", 45, "B Misdemeanor",
  "PL 14005", "Trespass", "140.05", "Violation", FALSE, "70.15", 8, "Violation; midpoint of 0-15 days per 70.15(4)",
  
  # =========================================================================
  # ARTICLE 155: LARCENY
  # =========================================================================
  "PL 15542", "Grand Larceny 1st", "155.42", "B", FALSE, "70.00", 1703, "B Non-Violent; min period 1-8.33 yrs, midpoint 4.667",
  "PL 15540", "Grand Larceny 2nd", "155.40", "C", FALSE, "70.00", 1095, "C Non-Violent; min period 1-5 yrs, midpoint 3",
  "PL 15535", "Grand Larceny 3rd", "155.35", "D", FALSE, "70.00", 608, "D Non-Violent",
  "PL 15530", "Grand Larceny 4th", "155.30", "E", FALSE, "70.00", 426, "E Non-Violent; min period 1-1.33 yrs, midpoint 1.167",
  "PL 15525", "Petit Larceny", "155.25", "A Misd", FALSE, "70.15", 182, "A Misdemeanor",
  
  # =========================================================================
  # ARTICLE 165: THEFT-RELATED OFFENSES
  # =========================================================================
  # Unauthorized Use of Vehicle (PL 165.05, 165.06, 165.08)
  "PL 16508", "Unauthorized Use Vehicle 1st", "165.08", "D", FALSE, "70.00", 608, "D Non-Violent",
  "PL 16506", "Unauthorized Use Vehicle 2nd", "165.06", "E", FALSE, "70.00", 426, "E Non-Violent",
  "PL 16505", "Unauthorized Use Vehicle 3rd", "165.05", "A Misd", FALSE, "70.15", 182, "A Misdemeanor",
  
  # Criminal Possession of Stolen Property (PL 165.40-165.54)
  "PL 16554", "Crim Poss Stolen Property 1st", "165.54", "B", FALSE, "70.00", 1703, "B Non-Violent",
  "PL 16552", "Crim Poss Stolen Property 2nd", "165.52", "C", FALSE, "70.00", 1095, "C Non-Violent",
  "PL 16550", "Crim Poss Stolen Property 3rd", "165.50", "D", FALSE, "70.00", 608, "D Non-Violent",
  "PL 16545", "Crim Poss Stolen Property 4th", "165.45", "E", FALSE, "70.00", 426, "E Non-Violent",
  "PL 16540", "Crim Poss Stolen Property 5th", "165.40", "A Misd", FALSE, "70.15", 182, "A Misdemeanor"
)

# =============================================================================
# SENTENCING CONSTANTS REFERENCE
# =============================================================================
#
# All values computed with 365 days/year, round-half-up to integer days.
#
# A-I FELONIES (special handling per PL 70.00(3)(a)(i)):
#   Murder 2nd: min range 15-25 to life; midpoint of min = 20 yrs = 7,300
#   Murder 1st: 1.5x Murder 2nd = 10,950 (LWOP-eligible, monotonicity fix)
#     NOTE: The 20-40 yr minimum for attempted Murder 1st comes from
#     70.00(3)(a)(i)(C), NOT from a 110.05 class reduction. PL 110.05
#     explicitly keeps attempted Murder 1st at class A-I.
#
# A-II FELONIES (special handling per PL 70.00(3)(a)(ii)):
#   Predatory Sexual Assault (130.95/130.96): min period 10-25, max life.
#   70.80(3) explicitly carves these out from determinate sentencing.
#   Sentenced under 70.00 indeterminate. Midpoint of min = 17.5 yrs = 6,388.
#   NOTE: 7,300 was erroneously used in v2 (borrowed from Murder 2nd's
#   15-25 midpoint; actual floor is 10, not 15).
#
# VIOLENT FELONIES (determinate, PL 70.02):
#   B Violent: 5-25 yrs → midpoint 15.0 yrs = 5,475 days
#   C Violent: 3.5-15 yrs → midpoint 9.25 yrs = 3,376 days
#   D Violent: 2-7 yrs → midpoint 4.5 yrs = 1,643 days (standard)
#   E Violent: 1.5-4 yrs → midpoint 2.75 yrs = 1,004 days
#
#   Offense-specific overrides per 70.02(3):
#     120.11 (Agg Assault on Police):  B 10-30 → midpoint 20.0 = 7,300
#     125.22 (Agg Manslaughter 1st):   B 10-30 → midpoint 20.0 = 7,300
#     125.21 (Agg Manslaughter 2nd):   C 7-20  → midpoint 13.5 = 4,928
#     125.11 (Agg Crim Neg Hom):       C 3.5-20 → midpoint 11.75 = 4,289
#     Attempted 120.11:                C 7-20  → midpoint 13.5 = 4,928
#     120.18 (Menacing Police):        D 2-8   → midpoint 5.0  = 1,825
#     265.02(10) (CPW 3rd sub 10):     D 3.5-7 → midpoint 5.25 = 1,916
#       (not currently in table; flag for future inclusion)
#
# FELONY SEX OFFENSES (determinate, PL 70.80):
#   Applies to Article 130 felonies EXCEPT the A-II predatory offenses
#   (130.95/130.96), which are carved out by 70.80(3) and sentenced
#   under 70.00 indeterminate (see A-II section above).
#   70.80(4)(a) ranges are identical to 70.02 violent felony ranges:
#     B: 5-25 → 5,475    C: 3.5-15 → 3,376    D: 2-7 → 1,643    E: 1.5-4 → 1,004
#   Non-VFO Art 130 felonies (e.g., Rape 3rd, CSA 3rd) get these values
#   even though is_violent=FALSE, because 70.80 supersedes 70.00.
#   70.80(1)(a) includes "felony attempt or conspiracy" in the definition,
#   so attempted Art 130 felonies also use 70.80 ranges at reduced class.
#
# NON-VIOLENT FELONIES (indeterminate, PL 70.00):
#   Derived from the minimum period range: PL 70.00(3) requires min ≥ 1 yr
#   and min ≤ (max term / 3). Max term is capped by class.
#   So the range of the minimum period is: 1 yr to (class_cap / 3).
#
#   B Non-Violent: 1 to 25/3 → midpoint 14/3 = 4.667 yrs = 1,703 days
#   C Non-Violent: 1 to 5 → midpoint 3.0 yrs = 1,095 days
#   D Non-Violent: 1 to 7/3 → midpoint 5/3 = 1.667 yrs = 608 days
#   E Non-Violent: 1 to 4/3 → midpoint 7/6 = 1.167 yrs = 426 days
#
# MISDEMEANORS (PL 70.15):
#   A Misdemeanor: 0-364 days → midpoint 182 days
#     (364-day max per 70.15(1-a), amended to avoid immigration consequences)
#   B Misdemeanor: 0-90 days → midpoint 45 days
#
# VIOLATIONS (PL 70.15(4)):
#   0-15 days → midpoint 7.5 → 8 days (round-half-up)
#
# =============================================================================

# =============================================================================
# CHANGE LOG (cumulative)
# =============================================================================
#
# ROUND 1: law_code_trim corrections (11 fixes)
#   - PL 12522 → PL 12526 (Aggravated Murder, 125.26)
#   - PL 12512 → PL 12513 (Vehicular Manslaughter 1st, 125.13)
#   - PL 12510 → PL 12512 (Vehicular Manslaughter 2nd, 125.12)
#   - PL 12505 → PL 12510 (Criminally Negligent Homicide, 125.10)
#   - PL 12015 ↔ PL 12013 (Menacing 1st/3rd swapped)
#   - PL 12017 ↔ PL 12016 (Hazing 1st/2nd swapped)
#   - PL 13055 → PL 13065 (Sexual Abuse 1st, 130.65)
#   - PL 13052 → PL 13055 (Sexual Abuse 3rd, 130.55)
#   - PL 13053 → PL 13052 (Forcible Touching, 130.52)
#   - ASA 4th set to PL 13065A to avoid collision with SA 1st (VERIFY)
#
# ROUND 2: is_violent / VFO corrections per PL 70.02(1) (8 fixes)
#   All were incorrectly marked is_violent = TRUE; none enumerated in 70.02.
#   chi_days updated from violent to non-violent sentencing bucket.
#
#   1. Vehicular Manslaughter 1st (125.13) C: 3,380 → 1,186
#   2. Rape 3rd (130.25) E: 1,004 → 274
#   3. Criminal Sexual Act 3rd (130.40) E: 1,004 → 274
#   4. Agg. Assault on <11yr (120.12) E: 1,004 → 274
#   5. Vehicular Assault 1st (120.04) D: 1,643 → 456
#   6. Agg. Vehicular Assault (120.04-a) C: 3,380 → 1,186
#   7. Menacing 1st (120.13) E: 1,004 → 274
#   8. Reckless Endangerment 1st (120.25) D: 1,643 → 456
#
# ROUND 3: Empirical charging correction (1 fix)
#   PL 120.08 (Assault on Police/Fire/EMS): C Violent 3,380 → D Violent 1,643
#   NYPD RMS systematically charges 120.08 based on victim category (officer/
#   firefighter/EMT status) rather than the statutory "serious physical injury"
#   element. Actual conduct overwhelmingly matches 120.05 (Assault 2nd, D Violent).
#   Scored at D Violent sentencing to reflect empirical charging reality.
#
# ROUND 4: Statutory precision audit (multiple fixes)
#
#   4a. PL 70.80 sentencing regime for Article 130 felonies:
#       Rape 3rd (130.25) and CSA 3rd (130.40) were incorrectly routed to
#       70.00 non-violent bucket after Round 2 VFO correction. PL 70.80
#       requires determinate sentencing for ALL Art 130 felonies.
#       E sex offense range = 1.5-4 yrs = 1,004 days (matches E Violent).
#       Rape 3rd: 274 → 1,004; CSA 3rd: 274 → 1,004.
#       is_violent remains FALSE (not in 70.02). sentencing_regime = "70.80".
#
#   4b. C Violent arithmetic correction:
#       9.25 × 365 = 3,376.25 → 3,376 (was 3,380 due to rounding error).
#       Affects: Gang Assault 2nd, ASA 2nd, Strangulation 1st, Robbery 2nd,
#       Burglary 2nd. (120.08 already moved to D in Round 3.)
#
#   4c. Non-violent felony ranges re-derived from PL 70.00(3):
#       Minimum period range: floor = 1 yr, ceiling = class_cap / 3.
#       B NV: 1,825 → 1,703 (midpoint of 1 to 25/3)
#       C NV: 1,186 → 1,095 (midpoint of 1 to 5)
#       D NV: 456 → 608 (midpoint of 1 to 7/3)
#       E NV: 274 → 426 (midpoint of 1 to 4/3)
#
#   4d. PL 120.18 enhanced range per 70.02(3)(c)(i):
#       Standard D Violent = 2-7 yrs, but 120.18 = 2-8 yrs.
#       Midpoint 5 × 365 = 1,825 days (was 1,643).
#
#   4e. A Misdemeanor: 183 → 182 days.
#       PL 70.15(1-a) sets max at 364 days (not 365); (0+364)/2 = 182.
#
#   4f. Violations: 15 → 8 days.
#       PL 70.15(4) sets max at 15 days; midpoint = (0+15)/2 = 7.5 → 8.
#
#   4g. PL 120.12 name corrected:
#       "Aggravated Assault on <11yr or 65+" → "Aggravated Assault on Person <11yr"
#       PL 120.12 applies only to victims < 11; 65+ is in 120.05 subdivisions.
#
#   4h. Attempted Murder 1st comment corrected:
#       The 20-40 yr minimum comes from PL 70.00(3)(a)(i)(C), not from a
#       PL 110.05 class reduction. 110.05 explicitly keeps att. Murder 1st
#       at class A-I.
#
#   4i. Added sentencing_regime column ("70.00", "70.02", "70.80", "70.15")
#       to prevent future "wrong bucket" errors and enable correct routing.
#
# ROUND 5: Statutory precision audit II - enhanced ranges, predatory assault,
#           attempt function rewrite (multiple fixes)
#
#   5a. PL 120.11 (Aggravated Assault on Police) enhanced range:
#       70.02(3)(a)(i) overrides B Violent to 10-30 yrs (not standard 5-25).
#       Midpoint 20 × 365 = 7,300 days (was 5,475).
#
#   5b. PL 130.95/130.96 (Predatory Sexual Assault / Against Child):
#       70.80(3) explicitly carves out A-II predatory offenses from the 70.80
#       determinate structure. Sentenced under 70.00 indeterminate: min period
#       10-25 yrs, max life. Using Murder 2nd convention (midpoint of min):
#       (10+25)/2 = 17.5 × 365 = 6,388 days (was 7,300, erroneously borrowed
#       from Murder 2nd's 15-25 midpoint).
#       sentencing_regime: "70.02" → "70.00".
#
#   5c. Article 130 header comment updated:
#       Added predatory assault carveout per 70.80(3). The blanket statement
#       "All Article 130 felonies sentenced under 70.80" was incorrect for
#       130.95/130.96. Added note re 70.80(1)(a) including attempts.
#
#   5d. Added enhanced-range offenses to Article 125:
#       PL 125.22 (Agg Manslaughter 1st): B 10-30 per 70.02(3)(a)(ii) → 7,300
#       PL 125.21 (Agg Manslaughter 2nd): C 7-20 per 70.02(3)(b)(i) → 4,928
#       PL 125.11 (Agg Crim Neg Homicide): C 3.5-20 per 70.02(3)(b)(iii) → 4,289
#
#   5e. Attempt function (adjust_for_attempt) completely rewritten:
#       - Now takes sentencing_regime and pl_section as inputs
#       - PL 110.05(1): A-I stays A-I for Murder 1st/Agg Murder (was dropping
#         all A-I to B Violent)
#       - PL 110.05(2): A-II stays A-II (was dropping to B Violent)
#       - PL 110.05(8): Attempted misdemeanor (any) = B Misd (was mapping
#         B Misd → Violation, contrary to statute)
#       - Routes through sentencing_regime (70.02/70.80/70.00) instead of
#         is_violent alone, ensuring 70.80 sex offense attempts get correct
#         determinate ranges
#       - Handles enhanced attempt range for 120.11: C 7-20 per 70.02(3)(b)(ii)
#         → 4,928 days
#       - All constants updated to v3 values (was using pre-Round-4 stale values:
#         3380, 1186, 456, 274, 183, 15)
#
#   5f. PL 125.11 (Agg Crim Neg Homicide) enhanced range:
#       70.02(3)(b)(iii) provides 3.5-20 (not standard C-violent 3.5-15).
#       Midpoint 11.75 × 365 = 4,289 days (was 3,376).
#       Originally added in 5d at standard C Violent; corrected here.
#
#   5g. D-violent attempt routing corrected per 70.02(1)(d):
#       The resulting E-class offense after a D-violent attempt is NOT
#       automatically a VFO. 70.02(1)(d) enumerates a narrow set of E VFOs
#       (att. CPW 3rd sub 5-8, persistent sex abuse, ASA 4th, falsely
#       reporting 2nd, placing false bomb 2nd). None of our D-violent → E
#       attempts produce these offenses. Non-sex D-violent attempts now
#       route to E non-violent = 426 (was 1,004, a 2.4x overweight).
#       Art 130 D-violent attempts still route to E sex offense = 1,004
#       via 70.80(1)(a).
#       Affected: att. 120.05, att. 121.12, att. 120.18, att. 120.60,
#       att. 120.08.
#
#   5h. Monotonicity constraint clarified:
#       Changed from "attempts must score below completed" to "attempts
#       must score ≤ completed." Equality is permitted for attempted
#       Murder 1st / Agg Murder (both 10,950) because LWOP makes the
#       completed offense effectively unbounded.
#
# =============================================================================
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
#
# Per PL 110.05, attempts reduce the crime class with these rules:
#   Sub 1: A-I → A-I for Murder 1st (125.27), Agg Murder (125.26(1)),
#          CPCS 1st, CSCS 1st, CP/CU Chem/Bio Weapon 1st
#   Sub 2: A-II → A-II (stays; e.g., attempted Pred Sex Assault)
#   Sub 3: A-I → B (all other A-I, e.g., attempted Murder 2nd)
#   Sub 4: B → C
#   Sub 5: C → D
#   Sub 6: D → E
#   Sub 7: E → A Misdemeanor
#   Sub 8: Misdemeanor (any) → B Misdemeanor
#          (covers both A Misd and B Misd; attempted B Misd = B Misd)
#
# After determining the attempt class, the CHI value is assigned using the
# correct sentencing regime:
#   - 70.02 (violent felony) → violent ranges
#   - 70.80 (felony sex offense) → same ranges as 70.02 (per 70.80(4)(a))
#   - 70.00 (non-violent) → non-violent indeterminate ranges
#   - 70.15 (misdemeanor/violation) → misdemeanor/violation ranges
#
# Enhanced attempt ranges per 70.02(3)(b):
#   Attempted 120.11: C 7-20 per 70.02(3)(b)(ii) → midpoint 13.5 = 4,928
#
# D-violent attempt routing (70.02(1)(d) enumeration):
#   When a D violent felony is attempted, the resulting E-class offense is
#   NOT automatically a VFO. 70.02(1)(d) enumerates a narrow list of E VFOs
#   that does NOT include attempted versions of most D violent felonies.
#   Non-sex D violent attempts → E non-violent (426).
#   Art 130 D violent attempts → E sex offense (1,004) via 70.80(1)(a).
#
# Monotonicity: attempts score ≤ completed offenses. Equality is permitted
#   for attempted Murder 1st / Agg Murder (both 10,950) because LWOP makes
#   the completed offense effectively unbounded.
#
# =============================================================================

adjust_for_attempt <- function(chi_days, felony_class, is_violent,
                               sentencing_regime, pl_section) {
  case_when(
    # =================================================================
    # A-I: STAYS A-I for specific offenses (PL 110.05(1))
    # =================================================================
    # Murder 1st and Agg Murder stay A-I. Return chi_days (the completed
    # offense value) because the attempted-A-I min ranges (20-40 to life)
    # produce midpoints ≤ the completed values we've already engineered.
    felony_class == "A-I" & pl_section %in% c("125.27", "125.26") ~ chi_days,
    
    # All other A-I → B (PL 110.05(3))
    # e.g., attempted Murder 2nd (125.25 A-I → B Violent)
    felony_class == "A-I" ~ 5475,   # B Violent: 5-25, midpoint 15
    
    # =================================================================
    # A-II: STAYS A-II (PL 110.05(2))
    # =================================================================
    # e.g., attempted Predatory Sexual Assault (130.95/130.96)
    # Return chi_days because attempted A-II has same min period range.
    felony_class == "A-II" ~ chi_days,
    
    # =================================================================
    # ENHANCED ATTEMPT RANGES (offense-specific overrides)
    # =================================================================
    # Attempted 120.11: C 7-20 per 70.02(3)(b)(ii), midpoint 13.5 = 4,928
    felony_class == "B" & pl_section == "120.11" ~ 4928L,
    
    # Attempted 125.22 (Agg Man 1st B enhanced → C):
    # No enhanced C range specified in 70.02(3)(b) for this; standard C Violent
    felony_class == "B" & pl_section == "125.22" ~ 3376L,
    
    # =================================================================
    # B → C (PL 110.05(4))
    # =================================================================
    felony_class == "B" & sentencing_regime == "70.02" ~ 3376L,  # C Violent
    felony_class == "B" & sentencing_regime == "70.80" ~ 3376L,  # C Sex Offense (= C Violent)
    felony_class == "B" & sentencing_regime == "70.00" ~ 1095L,  # C Non-Violent
    
    # =================================================================
    # C → D (PL 110.05(5))
    # =================================================================
    felony_class == "C" & sentencing_regime == "70.02" ~ 1643L,  # D Violent
    felony_class == "C" & sentencing_regime == "70.80" ~ 1643L,  # D Sex Offense
    felony_class == "C" & sentencing_regime == "70.00" ~ 608L,   # D Non-Violent
    
    # =================================================================
    # D → E (PL 110.05(6))
    # =================================================================
    # CRITICAL: The resulting E-class offense is NOT automatically a VFO.
    # 70.02(1)(d) enumerates a NARROW list of E violent felonies:
    #   - Attempted CPW 3rd (sub 5-8), persistent sexual abuse (130.53),
    #     ASA 4th (130.65-a), falsely reporting 2nd (240.55),
    #     placing false bomb 2nd (240.61).
    # None of our D-violent → E attempts produce those offenses.
    #
    # Art 130 sex offenses route through 70.80 for attempts (per
    # 70.80(1)(a): "felony attempt" included in "felony sex offense").
    # So attempted Rape 2nd, CSA 2nd, SA 1st, etc. → E sex offense = 1,004.
    #
    # All other D violent attempts → E non-violent = 426.
    # (e.g., att. Assault 2nd, att. Strangulation 2nd, att. Stalking 1st,
    #  att. Menacing Police, att. Assault on Police/Fire/EMS)
    felony_class == "D" & str_detect(pl_section, "^130\\.") ~ 1004L,  # E sex offense via 70.80
    felony_class == "D" & sentencing_regime == "70.80" ~ 1004L,        # E sex offense (safety net)
    felony_class == "D" & sentencing_regime == "70.02" ~ 426L,         # E NON-violent (not in 70.02(1)(d))
    felony_class == "D" & sentencing_regime == "70.00" ~ 426L,         # E Non-Violent
    
    # =================================================================
    # E → A Misdemeanor (PL 110.05(7))
    # =================================================================
    felony_class == "E" ~ 182L,
    
    # =================================================================
    # Misdemeanor (any) → B Misdemeanor (PL 110.05(8))
    # =================================================================
    # "Class B misdemeanor when the crime attempted is a misdemeanor"
    # Covers both A Misd and B Misd → B Misd
    felony_class %in% c("A Misd", "B Misd") ~ 45L,
    
    # =================================================================
    # FALLBACK (should not fire if lookup is complete)
    # =================================================================
    TRUE ~ as.integer(round(chi_days * 0.5))
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
  "PL 12526", "MURDER & NON-NEGL. MANSLAUGHTE", "Aggravated Murder (completed)",
  "PL 12526", "FELONY ASSAULT", "Attempted Aggravated Murder",
  "PL 12522", "MURDER & NON-NEGL. MANSLAUGHTE", "Aggravated Manslaughter 1st (completed)",
  "PL 12522", "FELONY ASSAULT", "Attempted Aggravated Manslaughter 1st",
  "PL 12521", "MURDER & NON-NEGL. MANSLAUGHTE", "Aggravated Manslaughter 2nd (completed)",
  "PL 12521", "FELONY ASSAULT", "Attempted Aggravated Manslaughter 2nd",
  "PL 12511", "MURDER & NON-NEGL. MANSLAUGHTE", "Aggravated Crim Neg Homicide (completed)",
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

# =============================================================================
# PD-LEVEL WHITELIST: FILTER ERRANT WITHIN-CATEGORY CHARGES
# =============================================================================
#
# For categories where pd_descriptions map to specific charges, only keep
# legitimate law_code × pd combinations. Categories not listed here
# (Robbery, Burglary, Grand Larceny, GLMV, Petit Larceny, Murder, Rape)
# pass through unfiltered because all degrees are legitimate under every pd.
#
# =============================================================================

pd_whitelist <- tribble(
  ~offense_description1, ~pd_description, ~law_code_trim,
  
  # =========================================================================
  # ASSAULT 3 & RELATED OFFENSES
  # =========================================================================
  
  # ASSAULT 3: only Assault 3rd
  "ASSAULT 3 & RELATED OFFENSES", "ASSAULT 3", "PL 12000",
  
  # MENACING pds: Menacing 1st + 2nd
  "ASSAULT 3 & RELATED OFFENSES", "MENACING,PEACE OFFICER", "PL 12015",
  "ASSAULT 3 & RELATED OFFENSES", "MENACING,PEACE OFFICER", "PL 12014",
  "ASSAULT 3 & RELATED OFFENSES", "MENACING,UNCLASSIFIED", "PL 12014",
  "ASSAULT 3 & RELATED OFFENSES", "MENACING,UNCLASSIFIED", "PL 12015",
  
  # OBSTR BREATH/CIRCUL: only Criminal Obstruction of Breathing
  "ASSAULT 3 & RELATED OFFENSES", "OBSTR BREATH/CIRCUL", "PL 12111",
  
  # =========================================================================
  # FELONY ASSAULT
  # =========================================================================
  
  # ASSAULT 2,1,UNCLASSIFIED: all assault + art 125 codes, NO strangulation
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12005",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12010",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12006",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12007",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12008",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12011",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12012",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12003",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12004",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12004A",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12525",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12527",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12526",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12522",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12521",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12511",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12520",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12515",
  "FELONY ASSAULT", "ASSAULT 2,1,UNCLASSIFIED", "PL 12510",
  
  # ASSAULT POLICE/PEACE OFFICER
  "FELONY ASSAULT", "ASSAULT POLICE/PEACE OFFICER", "PL 12008",
  "FELONY ASSAULT", "ASSAULT POLICE/PEACE OFFICER", "PL 12005",
  "FELONY ASSAULT", "ASSAULT POLICE/PEACE OFFICER", "PL 12011",
  "FELONY ASSAULT", "ASSAULT POLICE/PEACE OFFICER", "PL 12010",
  "FELONY ASSAULT", "ASSAULT POLICE/PEACE OFFICER", "PL 12527",
  "FELONY ASSAULT", "ASSAULT POLICE/PEACE OFFICER", "PL 12525",
  "FELONY ASSAULT", "ASSAULT POLICE/PEACE OFFICER", "PL 12007",
  "FELONY ASSAULT", "ASSAULT POLICE/PEACE OFFICER", "PL 12006",
  
  # ASSAULT OTHER PUBLIC SERVICE EMPLOYEE
  "FELONY ASSAULT", "ASSAULT OTHER PUBLIC SERVICE EMPLOYEE", "PL 12005",
  "FELONY ASSAULT", "ASSAULT OTHER PUBLIC SERVICE EMPLOYEE", "PL 12008",
  "FELONY ASSAULT", "ASSAULT OTHER PUBLIC SERVICE EMPLOYEE", "PL 12010",
  "FELONY ASSAULT", "ASSAULT OTHER PUBLIC SERVICE EMPLOYEE", "PL 12006",
  "FELONY ASSAULT", "ASSAULT OTHER PUBLIC SERVICE EMPLOYEE", "PL 12007",
  "FELONY ASSAULT", "ASSAULT OTHER PUBLIC SERVICE EMPLOYEE", "PL 12011",
  
  # ASSAULT SCHOOL SAFETY AGENT
  "FELONY ASSAULT", "ASSAULT SCHOOL SAFETY AGENT", "PL 12005",
  "FELONY ASSAULT", "ASSAULT SCHOOL SAFETY AGENT", "PL 12008",
  "FELONY ASSAULT", "ASSAULT SCHOOL SAFETY AGENT", "PL 12011",
  
  # ASSAULT TRAFFIC AGENT
  "FELONY ASSAULT", "ASSAULT TRAFFIC AGENT", "PL 12005",
  "FELONY ASSAULT", "ASSAULT TRAFFIC AGENT", "PL 12008",
  "FELONY ASSAULT", "ASSAULT TRAFFIC AGENT", "PL 12003",
  "FELONY ASSAULT", "ASSAULT TRAFFIC AGENT", "PL 12010",
  
  # STRANGULATION 1ST: only strangulation codes
  "FELONY ASSAULT", "STRANGULATION 1ST", "PL 12112",
  "FELONY ASSAULT", "STRANGULATION 1ST", "PL 12113",
  
  # =========================================================================
  # SEX CRIMES
  # =========================================================================
  
  # AGGRAVATED SEXUAL ABUSE: four ASA degrees only
  "SEX CRIMES", "AGGRAVATED SEXUAL ASBUSE", "PL 13070",
  "SEX CRIMES", "AGGRAVATED SEXUAL ASBUSE", "PL 13067",
  "SEX CRIMES", "AGGRAVATED SEXUAL ASBUSE", "PL 13066",
  "SEX CRIMES", "AGGRAVATED SEXUAL ASBUSE", "PL 13065",
  
  # COURSE OF SEXUAL CONDUCT: two CSC degrees only
  "SEX CRIMES", "COURSE OF SEXUAL CONDUCT AGAIN", "PL 13080",
  "SEX CRIMES", "COURSE OF SEXUAL CONDUCT AGAIN", "PL 13075",
  
  # SEXUAL ABUSE: abuse + forcible touching codes
  "SEX CRIMES", "SEXUAL ABUSE", "PL 13065",
  "SEX CRIMES", "SEXUAL ABUSE", "PL 13055",
  "SEX CRIMES", "SEXUAL ABUSE", "PL 13060",
  "SEX CRIMES", "SEXUAL ABUSE", "PL 13052",
  "SEX CRIMES", "SEXUAL ABUSE", "PL 13053",
  
  # SEXUAL ABUSE 3,2: abuse degrees + misconduct + touching
  "SEX CRIMES", "SEXUAL ABUSE 3,2", "PL 13052",
  "SEX CRIMES", "SEXUAL ABUSE 3,2", "PL 13055",
  "SEX CRIMES", "SEXUAL ABUSE 3,2", "PL 13060",
  "SEX CRIMES", "SEXUAL ABUSE 3,2", "PL 13020",
  "SEX CRIMES", "SEXUAL ABUSE 3,2", "PL 13053",
  
  # SEXUAL MISCONDUCT: only Sexual Misconduct
  "SEX CRIMES", "SEXUAL MISCONDUCT,DEVIATE", "PL 13020",
  "SEX CRIMES", "SEXUAL MISCONDUCT,INTERCOURSE", "PL 13020",
  
  # SODOMY 1: CSA 1st + 2nd + 3rd
  "SEX CRIMES", "SODOMY 1", "PL 13050",
  "SEX CRIMES", "SODOMY 1", "PL 13040",
  "SEX CRIMES", "SODOMY 1", "PL 13045",
  
  # SODOMY 2: CSA 2nd + 3rd
  "SEX CRIMES", "SODOMY 2", "PL 13045",
  "SEX CRIMES", "SODOMY 2", "PL 13040",
  
  # SODOMY 3: CSA 3rd only
  "SEX CRIMES", "SODOMY 3", "PL 13040"
  
  # NOTE: Small pds get blanket pass (not listed = all codes valid):
  #   CHILD, ENDANGERING WELFARE (n=16)
  #   OBSCENE MATERIAL - UNDER 17 YE (n=2)
  #   SEX CRIMES (n=19)
)

cat(sprintf("\nPD whitelist: %s valid pd x law_code combinations\n", nrow(pd_whitelist)))
cat(sprintf("  Offense categories with pd filtering: %s\n",
            n_distinct(pd_whitelist$offense_description1)))

# --- Offenses governed by the pd whitelist ---
pd_filtered_offenses <- unique(pd_whitelist$offense_description1)

# =============================================================================
# APPLY PD WHITELIST
# =============================================================================
# Split into governed (has whitelist entries) vs ungoverned (blanket pass).
# For governed offenses, keep only whitelisted combos OR combos where the
# pd_description has no whitelist entries (small catch-all pds).

# Which pd_descriptions within governed offenses have explicit whitelist entries?
governed_pds <- pd_whitelist %>%
  distinct(offense_description1, pd_description)

arrests_pd_filtered <- bind_rows(
  # Ungoverned offenses: pass through entirely
  arrests_target %>%
    filter(!offense_description1 %in% pd_filtered_offenses),
  
  # Governed offenses, whitelisted pd: semi_join
  arrests_target %>%
    filter(offense_description1 %in% pd_filtered_offenses) %>%
    semi_join(governed_pds, by = c("offense_description1", "pd_description")) %>%
    semi_join(pd_whitelist, by = c("offense_description1", "pd_description", "law_code_trim")),
  
  # Governed offenses, unlisted pd (small catch-alls): pass through
  arrests_target %>%
    filter(offense_description1 %in% pd_filtered_offenses) %>%
    anti_join(governed_pds, by = c("offense_description1", "pd_description"))
)

n_pd_dropped <- nrow(arrests_target) - nrow(arrests_pd_filtered)
cat(sprintf("\nPD-level filter:\n"))
cat(sprintf("  Before: %s arrests\n", comma(nrow(arrests_target))))
cat(sprintf("  After:  %s arrests\n", comma(nrow(arrests_pd_filtered))))
cat(sprintf("  Dropped: %s errant within-category charges (%.2f%%)\n",
            comma(n_pd_dropped), 100 * n_pd_dropped / nrow(arrests_target)))

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

arrests_with_chi <- arrests_pd_filtered %>%
  # Only keep appropriate codes for each offense
  semi_join(valid_combinations, by = c("offense_description1", "law_code_trim")) %>%
  # Join to CHI lookup
  left_join(
    penal_law_chi %>% select(law_code_trim, offense_name, pl_section, felony_class,
                             is_violent, sentencing_regime, chi_days),
    by = "law_code_trim"
  ) %>%
  # Apply attempt adjustment for Article 125 under Felony Assault
  mutate(
    is_attempt_art125 = (offense_description1 == "FELONY ASSAULT" & str_detect(law_code, "^PL 125")),
    is_attempt_final = is_attempt | is_attempt_art125,
    chi_adjusted = if_else(
      is_attempt_final,
      adjust_for_attempt(chi_days, felony_class, is_violent, sentencing_regime, pl_section),
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