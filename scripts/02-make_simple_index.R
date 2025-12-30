# =============================================================================
# NYC Crime Harm Index - Simple Scale Development
# =============================================================================
#
# Goal: Create simple whole-number weights for place-based targeting
#
# Base crimes (from complaints):
#   - Murder
#   - Robbery (hybrid from arrests)
#   - Felony Assault (hybrid from arrests)
#   - Misd Assault
#
# Gun violence data (separate datasets):
#   - Shooting (victim hit): Own weight (bumps to attempted murder level)
#   - Shots fired (no hit): Weighted avg by classification
#
# =============================================================================

library(tidyverse)
library(here)

# =============================================================================
# PART 1: EXACT HYBRID RATIOS FROM ARRESTS
# =============================================================================

# -----------------------------------------------------------------------------
# 1a. Felony Assault hybrid (ASSAULT 2,1,UNCLASSIFIED in complaints)
# -----------------------------------------------------------------------------

felony_assault_breakdown <- arrests %>%
  filter(pd_desc == "ASSAULT 2,1,UNCLASSIFIED") %>%
  mutate(
    pl_section = str_extract(law_code, "(?<=PL )\\d{5}"),
    degree = case_when(
      str_starts(pl_section, "12010") ~ "Assault 1st",
      str_starts(pl_section, "12005") ~ "Assault 2nd",
      TRUE ~ "Other"
    )
  ) %>%
  count(degree) %>%
  mutate(prop = n / sum(n))

print("=== FELONY ASSAULT BREAKDOWN (from arrests) ===")
print(felony_assault_breakdown)

# Exact proportions
prop_a1 <- felony_assault_breakdown$prop[felony_assault_breakdown$degree == "Assault 1st"]
prop_a2 <- felony_assault_breakdown$prop[felony_assault_breakdown$degree == "Assault 2nd"]

cat(sprintf("\nAssault 1st: %.2f%%\n", prop_a1 * 100))
cat(sprintf("Assault 2nd: %.2f%%\n", prop_a2 * 100))

# -----------------------------------------------------------------------------
# 1b. Robbery hybrid (all robbery in complaints)
# -----------------------------------------------------------------------------

robbery_breakdown <- arrests %>%
  filter(ky_cd == 105) %>%
  mutate(
    pl_section = str_extract(law_code, "(?<=PL )\\d{5}"),
    degree = case_when(
      str_starts(pl_section, "16015") ~ "Robbery 1st",
      str_starts(pl_section, "16010") ~ "Robbery 2nd",
      str_starts(pl_section, "16005") ~ "Robbery 3rd",
      TRUE ~ "Other"
    )
  ) %>%
  count(degree) %>%
  mutate(prop = n / sum(n))

print("=== ROBBERY BREAKDOWN (from arrests) ===")
print(robbery_breakdown)

prop_r1 <- robbery_breakdown$prop[robbery_breakdown$degree == "Robbery 1st"]
prop_r2 <- robbery_breakdown$prop[robbery_breakdown$degree == "Robbery 2nd"]
prop_r3 <- robbery_breakdown$prop[robbery_breakdown$degree == "Robbery 3rd"]

cat(sprintf("\nRobbery 1st: %.2f%%\n", prop_r1 * 100))
cat(sprintf("Robbery 2nd: %.2f%%\n", prop_r2 * 100))
cat(sprintf("Robbery 3rd: %.2f%%\n", prop_r3 * 100))

# -----------------------------------------------------------------------------
# 1c. Shots fired breakdown (by rpt_classfctn_desc)
# -----------------------------------------------------------------------------

shots_fired_breakdown <- shots_fired %>%
  count(rpt_classfctn_desc) %>%
  mutate(prop = n / sum(n)) %>%
  arrange(desc(n))

print("=== SHOTS FIRED BREAKDOWN ===")
print(shots_fired_breakdown, n = 15)

# =============================================================================
# PART 2: NY PENAL LAW REFERENCE (days of imprisonment)
# =============================================================================

# Midpoint of determinate sentencing range
penal_weights <- tribble(
  ~offense, ~class, ~min_yrs, ~max_yrs, ~chi_days,
  "Murder 2nd", "A-I Felony", 15, 25, 5475,
  "Assault 1st", "B Violent", 5, 25, 5475,
  "Robbery 1st", "B Violent", 5, 25, 5475,
  "Robbery 2nd", "C Violent", 3.5, 15, 3380,
  "Strangulation 1st", "C Violent", 3.5, 15, 3380,
  "Attempted Assault 1st", "C Felony", 3.5, 15, 3380,
  "Attempted Murder 2nd", "B Felony", 5, 25, 2738,
  "Assault 2nd", "D Violent", 2, 7, 1643,
  "Robbery 3rd", "D Violent", 2, 7, 1643,
  "Reckless Endangerment 1st", "D Felony", 2, 7, 1643,
  "Assault 3rd", "A Misd", 0, 1, 183
)

print("=== PENAL LAW REFERENCE WEIGHTS ===")
print(penal_weights)

# =============================================================================
# PART 3: CALCULATE EXACT HYBRID CHI (in days)
# =============================================================================

# Felony Assault hybrid
chi_felony_assault <- (prop_a1 * 5475) + (prop_a2 * 1643) + 
  ((1 - prop_a1 - prop_a2) * 1643)

# Robbery hybrid  
chi_robbery <- (prop_r1 * 5475) + (prop_r2 * 3380) + (prop_r3 * 1643) +
  ((1 - prop_r1 - prop_r2 - prop_r3) * 1643)

# Shots fired: weighted average by rpt_classfctn_desc
shots_fired_with_weights <- shots_fired_breakdown %>%
  mutate(
    chi_days = case_when(
      rpt_classfctn_desc == "ROBBERY" ~ 5475,
      rpt_classfctn_desc == "ASSAULT" ~ 3380,
      rpt_classfctn_desc == "HOMICIDE" ~ 2738,
      TRUE ~ 1643  # RE 1st default
    ),
    weighted_contrib = prop * chi_days
  )

chi_shots_fired <- sum(shots_fired_with_weights$weighted_contrib)

# Shooting (victim hit): fixed at murder/assault 1st level
# Rationale: gun violence bumps severity + broader community harm
chi_shooting <- 5475

# Create exact CHI table
exact_chi <- tribble(
  ~crime, ~chi_days, ~basis,
  "Murder", 5475, "Fixed: A-I Felony",
  "Shooting", 5475, "Fixed: Attempted Murder / Assault 1st level",
  "Robbery", chi_robbery, sprintf("Hybrid: %.1f%% R1 / %.1f%% R2 / %.1f%% R3", 
                                  prop_r1*100, prop_r2*100, prop_r3*100),
  "Felony Assault", chi_felony_assault, sprintf("Hybrid: %.1f%% A1 / %.1f%% A2", 
                                                prop_a1*100, prop_a2*100),
  "Shots Fired", chi_shots_fired, "Weighted avg by rpt_classfctn_desc",
  "Misd Assault", 183, "Fixed: A Misdemeanor"
)

print("=== EXACT CHI VALUES (days) ===")
print(exact_chi)

# =============================================================================
# PART 4: PROGRAMMATIC CONVERSION TO SIMPLE SCALE
# =============================================================================

# Anchor: Misd Assault = 1
# All weights expressed as multiples of misd assault

simple_chi <- exact_chi %>%
  mutate(
    # Exact ratio to misd assault
    exact_ratio = chi_days / 183,
    
    # Round to whole number
    simple_weight = round(exact_ratio),
    
    # For policy: what does this mean?
    equiv_misd_assaults = simple_weight
  )

print("=== SIMPLE SCALE (Misd Assault = 1) ===")
print(simple_chi)

# =============================================================================
# PART 5: SHOOTING INCIDENTS BREAKDOWN
# =============================================================================

# Non-fatal shooting = Attempted Murder / Assault 1st territory
# Even though complaint shows as Felony Assault (mostly A2), the gun bumps severity
# Also: gun violence has broader community harm effects beyond the individual victim

shootings_summary <- shootings %>%
  count(statistical_murder_flag) %>%
  mutate(
    outcome = if_else(statistical_murder_flag, "Fatal", "Non-fatal"),
    n_formatted = format(n, big.mark = ",")
  )

print("=== SHOOTING INCIDENTS BREAKDOWN ===")
print(shootings_summary)

# =============================================================================
# PART 6: FINAL SIMPLE SCALE
# =============================================================================

chi_final <- tribble(
  ~Crime, ~Weight,
  "Murder", 30,
  "Shooting", round(chi_shooting / 183),
  "Robbery", round(chi_robbery / 183),
  "Felony Assault", round(chi_felony_assault / 183),
  "Shots Fired", round(chi_shots_fired / 183),
  "Misd Assault", 1
)

print("=== NYC CRIME HARM INDEX - SIMPLE SCALE ===")
print(chi_final, n = 10)

# =============================================================================
# PART 7: EXPORT
# =============================================================================

write_csv(chi_final, here("output", "chi_simple_scale.csv"))
write_csv(felony_assault_breakdown, here("output", "arrests_felony_assault_breakdown.csv"))
write_csv(robbery_breakdown, here("output", "arrests_robbery_breakdown.csv"))
write_csv(shots_fired_with_weights, here("output", "shots_fired_breakdown.csv"))

cat("Files saved to output/\n")

