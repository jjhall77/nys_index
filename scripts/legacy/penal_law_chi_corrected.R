# =============================================================================
# NYS Penal Law CHI Lookup - CORRECTED VERSION
# =============================================================================
#
# Based on audit against actual NYS Penal Law and PL 70.02 violent felony list
# 
# Changes from original:
# - Fixed strangulation section swap (121.12 = 2nd, 121.13 = 1st)
# - Fixed PL 12011 from 7300 to 5475 (B violent range)
# - Fixed PL 12055/12060 (these are Stalking, not Assault)
# - Corrected non-violent felony weights
# - Added section references for verification
#
# =============================================================================

penal_law_chi_corrected <- tribble(
  ~law_code_trim, ~offense_name, ~pl_section, ~felony_class, ~is_violent, ~chi_days, ~notes,
  
  # === MURDER & MANSLAUGHTER (PL 125) ===
  "PL 12527", "Murder 1st", "125.27", "A-I", TRUE, 7300, "15-40 yrs to life",
  "PL 12525", "Murder 2nd", "125.25", "A-I", TRUE, 5475, "15-25 yrs to life",
  "PL 12520", "Manslaughter 1st", "125.20", "B", TRUE, 5475, "B Violent per 70.02(1)(a)",
  "PL 12515", "Manslaughter 2nd", "125.15", "C", FALSE, 1095, "C Non-Violent - NOT in 70.02",
  
  # === ASSAULT (PL 120) ===
  "PL 12000", "Assault 3rd", "120.00", "A Misd", FALSE, 183, "A Misdemeanor",
  "PL 12001", "Reckless Assault of Child (DCP)", "120.01", "E", FALSE, 365, "E Non-Violent",
  "PL 12002", "Reckless Assault of Child", "120.02", "D", TRUE, 1643, "D Violent per 70.02(1)(c)",
  "PL 12005", "Assault 2nd", "120.05", "D", TRUE, 1643, "D Violent per 70.02(1)(c)",
  "PL 12006", "Gang Assault 2nd", "120.06", "C", TRUE, 3380, "C Violent per 70.02(1)(b)",
  "PL 12007", "Gang Assault 1st", "120.07", "B", TRUE, 5475, "B Violent per 70.02(1)(a)",
  "PL 12008", "Assault on Police/Fire/EMS", "120.08", "C", TRUE, 3380, "C Violent - requires SERIOUS physical injury",
  "PL 12009", "Assault on a Judge", "120.09", "C", TRUE, 3380, "C Violent per 70.02(1)(b)",
  "PL 12010", "Assault 1st", "120.10", "B", TRUE, 5475, "B Violent per 70.02(1)(a)",
  "PL 12011", "Aggravated Assault on Police/Peace", "120.11", "B", TRUE, 5475, "B Violent - 5-25 yrs, midpoint 5475",
  "PL 12012", "Aggravated Assault on <11yo", "120.12", "E", TRUE, 1004, "E Violent",
  "PL 12013", "Menacing 1st", "120.13", "E", FALSE, 365, "E Non-Violent - NOT in 70.02",
  "PL 12014", "Menacing 2nd", "120.14", "A Misd", FALSE, 183, "A Misdemeanor",
  "PL 12015", "Menacing 3rd", "120.15", "B Misd", FALSE, 45, "B Misdemeanor",
  "PL 12016", "Hazing 1st", "120.16", "A Misd", FALSE, 183, "A Misdemeanor",
  "PL 12017", "Hazing 2nd", "120.17", "Violation", FALSE, 15, "Violation",
  "PL 12018", "Menacing Police/Peace Officer", "120.18", "D", TRUE, 1643, "D Violent per 70.02(1)(c)",
  "PL 12020", "Reckless Endangerment 2nd", "120.20", "A Misd", FALSE, 183, "A Misdemeanor",
  "PL 12025", "Reckless Endangerment 1st", "120.25", "D", FALSE, 730, "D Non-Violent - NOT in 70.02",
  "PL 12045", "Stalking 4th", "120.45", "B Misd", FALSE, 45, "B Misdemeanor",
  "PL 12050", "Stalking 3rd", "120.50", "A Misd", FALSE, 183, "A Misdemeanor",
  "PL 12055", "Stalking 2nd", "120.55", "E", FALSE, 365, "E Non-Violent - NOT in 70.02",
  "PL 12060", "Stalking 1st", "120.60", "D", TRUE, 1643, "D Violent per 70.02(1)(c) subd 1",
  
  # === STRANGULATION (PL 121) ===
  # CRITICAL: 121.12 = 2nd degree, 121.13 = 1st degree
  "PL 12111", "Criminal Obstruction of Breathing", "121.11", "A Misd", FALSE, 183, "A Misdemeanor",
  "PL 12112", "Strangulation 2nd", "121.12", "D", TRUE, 1643, "D Violent per 70.02(1)(c)",
  "PL 12113", "Strangulation 1st", "121.13", "C", TRUE, 3380, "C Violent per 70.02(1)(b)",
  
  # === ROBBERY (PL 160) ===
  "PL 16005", "Robbery 3rd", "160.05", "D", TRUE, 1643, "D Violent per 70.02(1)(c)",
  "PL 16010", "Robbery 2nd", "160.10", "C", TRUE, 3380, "C Violent per 70.02(1)(b)",
  "PL 16015", "Robbery 1st", "160.15", "B", TRUE, 5475, "B Violent per 70.02(1)(a)",
  
  # === BURGLARY (PL 140) ===
  "PL 14020", "Burglary 3rd", "140.20", "D", FALSE, 730, "D Non-Violent - NOT in 70.02",
  "PL 14025", "Burglary 2nd", "140.25", "C", TRUE, 3380, "C Violent per 70.02(1)(b)",
  "PL 14030", "Burglary 1st", "140.30", "B", TRUE, 5475, "B Violent per 70.02(1)(a)",
  
  # === LARCENY (PL 155) - all non-violent ===
  "PL 15525", "Petit Larceny", "155.25", "A Misd", FALSE, 183, "A Misdemeanor",
  "PL 15530", "Grand Larceny 4th", "155.30", "E", FALSE, 365, "E Non-Violent",
  "PL 15535", "Grand Larceny 3rd", "155.35", "D", FALSE, 730, "D Non-Violent",
  "PL 15540", "Grand Larceny 2nd", "155.40", "C", FALSE, 1095, "C Non-Violent",
  "PL 15542", "Grand Larceny 1st", "155.42", "B", FALSE, 1825, "B Non-Violent",
  
  # === OTHER THEFT (PL 165) ===
  "PL 16505", "Unauthorized Use Vehicle 2nd", "165.05", "A Misd", FALSE, 183, "A Misdemeanor",
  "PL 16506", "Unauthorized Use Vehicle 3rd", "165.06", "E", FALSE, 365, "E Non-Violent",
  "PL 16550", "Unauthorized Use Vehicle 1st", "165.50", "E", FALSE, 365, "E Non-Violent"
)

# =============================================================================
# QUICK LOOKUP TABLE (for merging with arrest data)
# =============================================================================

chi_lookup_simple <- penal_law_chi_corrected %>%
  select(law_code_trim, offense_name, felony_class, is_violent, chi_days)
