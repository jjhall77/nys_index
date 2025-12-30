# =============================================================================
# NYC Crime Harm Index (CHI) - Complete Analysis Script
# =============================================================================
# 
# Purpose: Develop place-based CHI weights for violent crime intervention targeting
# 
# Data sources:
#   - NYPD Complaints (for applying weights)
#   - NYPD Arrests (for proportion-weighting where pd_desc lumps degrees)
#   - Shooting incidents (separate dataset - victim hit)
#   - Shots fired (separate dataset - no victim hit)
#
# =============================================================================

library(tidyverse)
library(scales)
library(here)

# Create output directory
dir.create(here("output"), showWarnings = FALSE)

# =============================================================================
# PART 1: NY PENAL LAW REFERENCE WEIGHTS
# =============================================================================

# Sentencing-based weights (midpoint of determinate sentence range, in days)
penal_law_reference <- tribble(
  ~charge, ~penal_law, ~class, ~min_years, ~max_years, ~chi_weight,
  
  # Homicide
  "Murder 1st", "PL 125.27", "A-I Felony", 20, 40, 5475,
  "Murder 2nd", "PL 125.25", "A-I Felony", 15, 25, 5475,
  "Manslaughter 1st", "PL 125.20", "B Felony", 5, 25, 2738,
  "Manslaughter 2nd", "PL 125.15", "C Felony", 3.5, 15, 1095,
  
  # Assault
  "Assault 1st", "PL 120.10", "B Violent", 5, 25, 5475,
  "Assault 2nd", "PL 120.05", "D Violent", 2, 7, 1643,
  "Assault 3rd", "PL 120.00", "A Misd", 0, 1, 183,
  
  # Strangulation
  "Strangulation 1st", "PL 121.12", "C Violent", 3.5, 15, 3380,
  "Strangulation 2nd", "PL 121.13", "D Felony", 2, 7, 1643,
  "Crim Obstr Breathing", "PL 121.11-a", "A Misd", 0, 1, 183,
  
  # Robbery
  "Robbery 1st", "PL 160.15", "B Violent", 5, 25, 5475,
  "Robbery 2nd", "PL 160.10", "C Violent", 3.5, 15, 3380,
  "Robbery 3rd", "PL 160.05", "D Violent", 2, 7, 1643,
  
  # Weapons / Attempt (for shots fired context)
  "CPW 2nd (loaded firearm)", "PL 265.03", "C Violent", 3.5, 15, 3380,
  "Reckless Endangerment 1st", "PL 120.25", "D Felony", 2, 7, 1643,
  "Attempted Assault 1st", "PL 110/120.10", "C Felony", 3.5, 15, 3380,
  "Attempted Murder 2nd", "PL 110/125.25", "B Felony", 5, 25, 2738
)

print("=== NY PENAL LAW REFERENCE WEIGHTS ===")
print(penal_law_reference, n = 20)

# =============================================================================
# PART 2: HYBRID WEIGHT CALCULATIONS FROM ARRESTS
# =============================================================================

# -----------------------------------------------------------------------------
# 2a. Assault 1/2 Hybrid (pd_desc = "ASSAULT 2,1,UNCLASSIFIED")
# -----------------------------------------------------------------------------

assault_12_hybrid <- arrests %>%
  filter(pd_desc == "ASSAULT 2,1,UNCLASSIFIED") %>%
  mutate(
    pl_section = str_extract(law_code, "(?<=PL )\\d{5}"),
    assault_degree = case_when(
      str_starts(pl_section, "12010") ~ "Assault 1st",
      str_starts(pl_section, "12005") ~ "Assault 2nd",
      TRUE ~ "Other"
    ),
    chi_weight = case_when(
      assault_degree == "Assault 1st" ~ 5475,
      assault_degree == "Assault 2nd" ~ 1643,
      TRUE ~ 1643
    )
  ) %>%
  group_by(assault_degree, chi_weight) %>%
  summarise(n = n(), .groups = "drop") %>%
  mutate(
    prop = n / sum(n),
    weighted_contrib = prop * chi_weight
  )

assault_12_chi <- round(sum(assault_12_hybrid$weighted_contrib))

print("=== ASSAULT 1/2 HYBRID ===")
print(assault_12_hybrid)
cat("Hybrid CHI for ASSAULT 2,1,UNCLASSIFIED:", assault_12_chi, "\n\n")

# -----------------------------------------------------------------------------
# 2b. Strangulation 1/2 Hybrid (pd_desc = "STRANGULATION 1ST")
# -----------------------------------------------------------------------------

strangulation_hybrid <- arrests %>%
  filter(str_detect(pd_desc, "STRANGULATION")) %>%
  mutate(
    pl_section = str_extract(law_code, "(?<=PL )\\d{5}"),
    strang_degree = case_when(
      str_starts(pl_section, "12112") ~ "Strangulation 1st",
      str_starts(pl_section, "12113") ~ "Strangulation 2nd",
      TRUE ~ "Other"
    ),
    chi_weight = case_when(
      strang_degree == "Strangulation 1st" ~ 3380,
      strang_degree == "Strangulation 2nd" ~ 1643,
      TRUE ~ 1643
    )
  ) %>%
  group_by(strang_degree, chi_weight) %>%
  summarise(n = n(), .groups = "drop") %>%
  mutate(
    prop = n / sum(n),
    weighted_contrib = prop * chi_weight
  )

strangulation_chi <- round(sum(strangulation_hybrid$weighted_contrib))

print("=== STRANGULATION 1/2 HYBRID ===")
print(strangulation_hybrid)
cat("Hybrid CHI for STRANGULATION 1ST (pd_desc):", strangulation_chi, "\n\n")

# -----------------------------------------------------------------------------
# 2c. Robbery 1/2/3 Hybrid (all robbery pd_desc types)
# -----------------------------------------------------------------------------

robbery_hybrid <- arrests %>%
  filter(ky_cd == 105) %>%
  mutate(
    pl_section = str_extract(law_code, "(?<=PL )\\d{5}"),
    robbery_degree = case_when(
      str_starts(pl_section, "16015") ~ "Robbery 1st",
      str_starts(pl_section, "16010") ~ "Robbery 2nd",
      str_starts(pl_section, "16005") ~ "Robbery 3rd",
      TRUE ~ "Other"
    ),
    chi_weight = case_when(
      robbery_degree == "Robbery 1st" ~ 5475,
      robbery_degree == "Robbery 2nd" ~ 3380,
      robbery_degree == "Robbery 3rd" ~ 1643,
      TRUE ~ 1643
    )
  ) %>%
  group_by(robbery_degree, chi_weight) %>%
  summarise(n = n(), .groups = "drop") %>%
  mutate(
    prop = n / sum(n),
    weighted_contrib = prop * chi_weight
  )

robbery_chi <- round(sum(robbery_hybrid$weighted_contrib))

print("=== ROBBERY 1/2/3 HYBRID ===")
print(robbery_hybrid)
cat("Hybrid CHI for ROBBERY:", robbery_chi, "\n\n")

# =============================================================================
# PART 3: SHOTS FIRED WEIGHT OPTIONS
# =============================================================================

# Shots fired = gun discharge with no victim hit
# These don't appear in standard crime categories but represent serious harm
# Typical charges IF filed: Reckless Endangerment 1st, Attempted Assault 1st

shots_fired_options <- tribble(
  ~option, ~chi_weight, ~equivalent_to, ~rationale,
  "Conservative", 1000, "0.6x Assault 2nd", "No physical injury occurred",
  "Moderate", 1643, "1x Assault 2nd / Reckless Endanger 1st", "Lethal intent present",
  "Aggressive", 2500, "1.5x Assault 2nd", "Near-miss; but-for luck = shooting",
  "Maximum", 3380, "1x Attempted Assault 1st / CPW 2nd", "Full weapons felony equivalent"
)

print("=== SHOTS FIRED WEIGHT OPTIONS ===")
print(shots_fired_options)

# Select moderate as default (can change)
shots_fired_chi <- 1643

# =============================================================================
# PART 4: FINAL CHI LOOKUP TABLE
# =============================================================================

chi_lookup <- tribble(
  ~offense_type, ~pd_desc, ~chi_weight, ~method, ~penal_class,
  
  # ----- FIXED WEIGHTS -----
  "Murder", "—", 5475, "Fixed", "A-I Felony",
  "Shooting (victim hit)", "—", 5475, "Fixed", "—",
  "Shots fired (no hit)", "—", shots_fired_chi, "Policy (Moderate)", "—",
  
  # ----- HYBRID WEIGHTS (proportion from arrests) -----
  "Felony Assault", "STRANGULATION 1ST", strangulation_chi, "Hybrid", "Mix C/D Violent",
  "Felony Assault", "ASSAULT 2,1,UNCLASSIFIED", assault_12_chi, "Hybrid", "Mix B/D Violent",
  "Robbery", "— (all)", robbery_chi, "Hybrid", "Mix B/C/D Violent",
  
  # ----- DIRECT WEIGHTS (single penal class) -----
  "Felony Assault", "ASSAULT POLICE/PEACE OFFICER", 1643, "Direct", "D Violent (overcharge adj)",
  "Felony Assault", "ASSAULT OTHER PUBLIC SERVICE EMPLOYEE", 1643, "Direct", "D Violent Felony",
  "Felony Assault", "ASSAULT SCHOOL SAFETY AGENT", 1643, "Direct", "D Violent Felony",
  "Felony Assault", "ASSAULT TRAFFIC AGENT", 1643, "Direct", "D Violent Felony",
  "Misd Assault", "ASSAULT 3", 183, "Direct", "A Misdemeanor",
  "Misd Assault", "OBSTR BREATH/CIRCUL", 183, "Direct", "A Misdemeanor"
)

print("=== FINAL CHI LOOKUP TABLE ===")
print(chi_lookup, n = 15)

# =============================================================================
# PART 5: COMPARISON VISUALIZATIONS
# =============================================================================

# -----------------------------------------------------------------------------
# 5a. Full scale: All offenses with proposed weights
# -----------------------------------------------------------------------------

# Penal law reference points
penal_reference_plot <- tribble(
  ~charge, ~chi_weight, ~category,
  "Murder 2nd", 5475, "Penal Law",
  "Assault 1st", 5475, "Penal Law",
  "Robbery 1st", 5475, "Penal Law",
  "Strangulation 1st", 3380, "Penal Law",
  "Robbery 2nd", 3380, "Penal Law",
  "Attempted Assault 1st", 3380, "Penal Law",
  "CPW 2nd (loaded firearm)", 3380, "Penal Law",
  "Assault 2nd", 1643, "Penal Law",
  "Robbery 3rd", 1643, "Penal Law",
  "Strangulation 2nd", 1643, "Penal Law",
  "Reckless Endangerment 1st", 1643, "Penal Law",
  "Assault 3rd", 183, "Penal Law",
  "Crim Obstr Breathing", 183, "Penal Law"
)

# Proposed weights
proposed_plot <- tribble(
  ~charge, ~chi_weight, ~category,
  "→ Murder", 5475, "Proposed",
  "→ Shooting (victim hit)", 5475, "Proposed",
  "→ Robbery (hybrid)", robbery_chi, "Proposed",
  "→ STRANGULATION 1ST (hybrid)", strangulation_chi, "Proposed",
  "→ Shots fired (Aggressive)", 2500, "Proposed",
  "→ ASSAULT 2,1,UNCLASS (hybrid)", assault_12_chi, "Proposed",
  "→ Shots fired (Moderate)", 1643, "Proposed",
  "→ ASSAULT POLICE/PEACE", 1643, "Proposed",
  "→ Shots fired (Conservative)", 1000, "Proposed",
  "→ ASSAULT 3", 183, "Proposed",
  "→ OBSTR BREATH/CIRCUL", 183, "Proposed"
)

full_comparison <- bind_rows(penal_reference_plot, proposed_plot) %>%
  arrange(chi_weight, category)

p1 <- ggplot(full_comparison, aes(x = chi_weight, y = reorder(charge, chi_weight))) +
  geom_segment(aes(x = 0, xend = chi_weight, yend = reorder(charge, chi_weight)),
               color = "gray80", linewidth = 0.5) +
  geom_point(aes(color = category, shape = category), size = 3.5) +
  geom_vline(xintercept = c(183, 1643, 3380, 5475), 
             linetype = "dotted", alpha = 0.4, color = "gray40") +
  scale_x_continuous(
    labels = comma,
    breaks = c(0, 183, 1000, 1643, 2500, 3380, 5475),
    sec.axis = sec_axis(~ . / 365, name = "Years", 
                        breaks = c(0, 0.5, 1, 3, 5, 7, 10, 15))
  ) +
  scale_color_manual(values = c("Penal Law" = "gray50", "Proposed" = "#2166ac")) +
  scale_shape_manual(values = c("Penal Law" = 16, "Proposed" = 17)) +
  labs(
    title = "NYC Crime Harm Index: Proposed Weights vs NY Penal Law",
    subtitle = "Triangles = proposed weights | Circles = statutory reference points",
    x = "CHI Weight (days)",
    y = NULL,
    color = NULL,
    shape = NULL
  ) +
  theme_minimal() +
  theme(
    panel.grid.major.y = element_blank(),
    legend.position = "bottom"
  )

print(p1)
ggsave(here("output", "chi_full_comparison.png"), p1, width = 11, height = 9, dpi = 150)

# -----------------------------------------------------------------------------
# 5b. Focused: Shots fired decision context
# -----------------------------------------------------------------------------

shots_context <- tribble(
  ~charge, ~chi_weight, ~category,
  "Assault 3rd", 183, "Penal Law",
  "Reckless Endangerment 1st", 1643, "Penal Law",
  "Assault 2nd", 1643, "Penal Law",
  "Strangulation 2nd", 1643, "Penal Law",
  "CPW 2nd (loaded firearm)", 3380, "Penal Law",
  "Attempted Assault 1st", 3380, "Penal Law",
  "Assault 1st", 5475, "Penal Law",
  "→ Shots fired (Conservative)", 1000, "Proposed: Shots Fired",
  "→ Shots fired (Moderate)", 1643, "Proposed: Shots Fired",
  "→ Shots fired (Aggressive)", 2500, "Proposed: Shots Fired",
  "→ Shooting (victim hit)", 5475, "Proposed: Shooting"
)

p2 <- ggplot(shots_context, aes(x = chi_weight, y = reorder(charge, chi_weight))) +
  geom_segment(aes(x = 0, xend = chi_weight, yend = reorder(charge, chi_weight)),
               color = "gray80") +
  geom_point(aes(color = category), size = 4) +
  geom_vline(xintercept = c(1643, 3380), linetype = "dashed", alpha = 0.4) +
  annotate("text", x = 1750, y = 1, label = "D Felony line", hjust = 0, size = 3, color = "gray40") +
  annotate("text", x = 3490, y = 1, label = "C Felony line", hjust = 0, size = 3, color = "gray40") +
  scale_x_continuous(labels = comma, breaks = c(0, 500, 1000, 1643, 2500, 3380, 5475)) +
  scale_color_manual(values = c(
    "Penal Law" = "gray50",
    "Proposed: Shots Fired" = "#1f77b4",
    "Proposed: Shooting" = "#d62728"
  )) +
  labs(
    title = "Where Should 'Shots Fired' Fall on the Harm Scale?",
    subtitle = "Context: Typical charges for shots fired are Reckless Endangerment 1st or Attempted Assault 1st",
    x = "CHI Weight (days)",
    y = NULL,
    color = NULL
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

print(p2)
ggsave(here("output", "chi_shots_fired_decision.png"), p2, width = 10, height = 6, dpi = 150)

# -----------------------------------------------------------------------------
# 5c. Offense type breakdown by category
# -----------------------------------------------------------------------------

# Show where each offense type sits by category
category_summary <- chi_lookup %>%
  mutate(
    offense_group = case_when(
      str_detect(offense_type, "Murder|Shooting") ~ "Homicide/Shooting",
      str_detect(offense_type, "Shots fired") ~ "Shots Fired",
      str_detect(offense_type, "Robbery") ~ "Robbery",
      str_detect(offense_type, "Felony Assault") ~ "Felony Assault",
      str_detect(offense_type, "Misd") ~ "Misd Assault"
    )
  )

p3 <- ggplot(category_summary, aes(x = chi_weight, y = reorder(pd_desc, chi_weight))) +
  geom_segment(aes(x = 0, xend = chi_weight, yend = reorder(pd_desc, chi_weight)),
               color = "gray80") +
  geom_point(aes(color = offense_group), size = 4) +
  geom_text(aes(label = format(chi_weight, big.mark = ",")), 
            hjust = -0.3, size = 3) +
  scale_x_continuous(
    labels = comma, 
    limits = c(0, 6500),
    sec.axis = sec_axis(~ . / 365, name = "Years")
  ) +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "Final CHI Weights by Offense Category",
    subtitle = "Weights derived from NY Penal Law sentencing guidelines",
    x = "CHI Weight (days)",
    y = NULL,
    color = "Offense Group"
  ) +
  theme_minimal() +
  theme(
    panel.grid.major.y = element_blank(),
    legend.position = "bottom"
  )

print(p3)
ggsave(here("output", "chi_by_category.png"), p3, width = 10, height = 7, dpi = 150)

# =============================================================================
# PART 6: RATIO TABLE (for interpretation)
# =============================================================================

# How many X = 1 murder?
ratio_table <- chi_lookup %>%
  select(offense_type, pd_desc, chi_weight) %>%
  mutate(
    events_per_murder = round(5475 / chi_weight, 1),
    ratio_to_assault_2 = round(chi_weight / 1643, 2),
    ratio_to_misd_assault = round(chi_weight / 183, 1)
  ) %>%
  arrange(desc(chi_weight))

print("=== RATIO TABLE: How offenses compare ===")
print(ratio_table, n = 15)

# =============================================================================
# PART 7: EXPORT EVERYTHING
# =============================================================================

# Final lookup table
write_csv(chi_lookup, here("output", "chi_final_lookup.csv"))

# Hybrid calculation details
write_csv(assault_12_hybrid, here("output", "hybrid_assault_12_breakdown.csv"))
write_csv(strangulation_hybrid, here("output", "hybrid_strangulation_breakdown.csv"))
write_csv(robbery_hybrid, here("output", "hybrid_robbery_breakdown.csv"))

# Reference and comparison tables
write_csv(penal_law_reference, here("output", "penal_law_reference.csv"))
write_csv(full_comparison, here("output", "chi_full_comparison.csv"))
write_csv(shots_fired_options, here("output", "shots_fired_options.csv"))
write_csv(ratio_table, here("output", "chi_ratio_table.csv"))

cat("\n=== FILES SAVED TO output/ ===\n")
list.files(here("output"))

# =============================================================================
# PART 8: SUMMARY PRINTOUT
# =============================================================================

cat("\n")
cat("===========================================================================\n")
cat("                     NYC CRIME HARM INDEX - FINAL SUMMARY                  \n")
cat("===========================================================================\n")
cat("\n")
cat("FIXED WEIGHTS:\n")
cat("  Murder ............................ 5,475 (A-I Felony)\n")
cat("  Shooting (victim hit) ............. 5,475 (equal to Murder)\n")
cat(sprintf("  Shots fired (no hit) .............. %s (Moderate option)\n", 
            format(shots_fired_chi, big.mark = ",")))
cat("\n")
cat("HYBRID WEIGHTS (proportion-weighted from arrests):\n")
cat(sprintf("  ASSAULT 2,1,UNCLASSIFIED .......... %s (%.1f%% A1, %.1f%% A2)\n",
            format(assault_12_chi, big.mark = ","),
            assault_12_hybrid$prop[assault_12_hybrid$assault_degree == "Assault 1st"] * 100,
            assault_12_hybrid$prop[assault_12_hybrid$assault_degree == "Assault 2nd"] * 100))
cat(sprintf("  STRANGULATION 1ST ................. %s (%.1f%% S1, %.1f%% S2)\n",
            format(strangulation_chi, big.mark = ","),
            strangulation_hybrid$prop[strangulation_hybrid$strang_degree == "Strangulation 1st"] * 100,
            strangulation_hybrid$prop[strangulation_hybrid$strang_degree == "Strangulation 2nd"] * 100))
cat(sprintf("  Robbery (all) ..................... %s (%.1f%% R1, %.1f%% R2, %.1f%% R3)\n",
            format(robbery_chi, big.mark = ","),
            robbery_hybrid$prop[robbery_hybrid$robbery_degree == "Robbery 1st"] * 100,
            robbery_hybrid$prop[robbery_hybrid$robbery_degree == "Robbery 2nd"] * 100,
            robbery_hybrid$prop[robbery_hybrid$robbery_degree == "Robbery 3rd"] * 100))
cat("\n")
cat("DIRECT WEIGHTS:\n")
cat("  ASSAULT POLICE/PEACE OFFICER ...... 1,643 (D Violent - overcharge adj)\n")
cat("  ASSAULT OTHER PUBLIC SERVICE ...... 1,643 (D Violent)\n")
cat("  ASSAULT 3 ......................... 183 (A Misdemeanor)\n")
cat("  OBSTR BREATH/CIRCUL ............... 183 (A Misdemeanor)\n")
cat("\n")
cat("===========================================================================\n")