# =============================================================================
# NYC Crime Harm Index (CHI) - Rebuild Part 2: Shootings & Shots Fired
# =============================================================================
#
# Purpose: Calculate CHI weights for gun violence incidents
#
# Key approach:
# - Shootings: Use pd_desc to classify, apply appropriate harm weights
# - Shots Fired: Classify by pd_desc, calculate weighted harm scores
# - All gun incidents get minimum CPW 2nd (PL 265.03) harm floor
# - Analyze temporal and geographic stability
#
# =============================================================================

library(tidyverse)
library(here)
library(janitor)
library(scales)
library(lubridate)

# Create output directory
dir.create(here("output"), showWarnings = FALSE)

# =============================================================================
# PART 1: DEFINE HARM WEIGHTS
# =============================================================================

# NYS Penal Law reference weights (days)
# All gun incidents have minimum CPW 2nd (PL 265.03) = C Violent = 3380 days

harm_weights <- tribble(
  ~category, ~chi_days, ~basis,
  "Murder 2nd", 5475, "A-I Felony (15-25 years)",
  "Attempted Murder 2nd", 5475, "B Felony (treated as full given gun)",
  "Assault 1st", 5475, "B Violent (5-25 years)",
  "Attempted Assault 1st", 3380, "C Violent (3.5-15 years) - one class down",
  "Robbery 1st", 5475, "B Violent (5-25 years)",
  "CPW 2nd (loaded firearm)", 3380, "C Violent (3.5-15 years) - MINIMUM for gun incidents",
  "Reckless Endangerment 1st", 1643, "D Felony (2-7 years)",
  "Reckless Endangerment 2nd (property)", 183, "A Misdemeanor"
)

cat("=== HARM WEIGHTS REFERENCE ===\n")
print(harm_weights)

# Minimum harm floor for any gun incident = CPW 2nd
MIN_GUN_HARM <- 3380

# =============================================================================
# PART 2: LOAD SHOOTINGS DATA
# =============================================================================

message("Loading shootings data...")

shootings <- read_csv(here("data", "NYPD_Shooting_Incident_Data_(Historic)_20251230.csv"),
                      show_col_types = FALSE) %>%
  clean_names() %>%
  mutate(
    date = mdy(occur_date),
    year = year(date)
  ) %>%
  filter(year >= 2018, year <= 2024)

message(sprintf("  Loaded %d shooting incidents (%d to %d)",
                nrow(shootings), min(shootings$year), max(shootings$year)))

# =============================================================================
# PART 3: LOAD AND MUNGE SHOTS FIRED DATA
# =============================================================================

message("Loading shots fired data...")

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

# Combine shots fired datasets
shots_fired <- bind_rows(sf2017, shots_fired_new) %>%
  filter(!is.na(x_coord_cd), !is.na(y_coord_cd)) %>%
  distinct(cmplnt_key, .keep_all = TRUE) %>%
  mutate(year = year(date)) %>%
  filter(year >= 2018, year <= 2024)

message(sprintf("  Loaded %d shots fired incidents (%d to %d)",
                nrow(shots_fired), min(shots_fired$year), max(shots_fired$year)))

# Check pd_desc distribution
cat("\n=== SHOTS FIRED PD_DESC DISTRIBUTION ===\n")
sf_pd_desc_counts <- shots_fired %>%
  count(pd_desc) %>%
  arrange(desc(n))
print(sf_pd_desc_counts)

# =============================================================================
# PART 4: ASSIGN CHI TO SHOTS FIRED
# =============================================================================

# Classification logic:
# - "ASSAULT 2,1,UNCLASSIFIED" → Attempted Assault 1st (3380) - one class down from completed
# - "RECKLESS ENDANGERMENT 1" → RE 1st (1643) but with CPW floor (3380)
# - "RECKLESS ENDANGERMENT OF PROPE" → Misd RE (183) but with CPW floor (3380)
# - Everything else (INVESTIGATE, BALLIS) → CPW 2nd floor (3380)

shots_fired_chi <- shots_fired %>%
  mutate(
    chi_category = case_when(
      pd_desc == "ASSAULT 2,1,UNCLASSIFIED" ~ "Attempted Assault 1st",
      pd_desc == "RECKLESS ENDANGERMENT 1" ~ "Reckless Endangerment 1st",
      pd_desc == "RECKLESS ENDANGERMENT OF PROPE" ~ "Reckless Endangerment (Property)",
      TRUE ~ "Other (CPW floor)"
    ),
    chi_base = case_when(
      pd_desc == "ASSAULT 2,1,UNCLASSIFIED" ~ 3380,  # Att Assault 1st
      pd_desc == "RECKLESS ENDANGERMENT 1" ~ 1643,   # RE 1st
      pd_desc == "RECKLESS ENDANGERMENT OF PROPE" ~ 183,  # Misd RE
      TRUE ~ 3380  # CPW 2nd floor
    ),
    # Apply CPW 2nd minimum floor for all gun incidents
    chi_final = pmax(chi_base, MIN_GUN_HARM)
  )

# Summary of CHI assignments
cat("\n=== SHOTS FIRED CHI ASSIGNMENTS ===\n")
sf_chi_summary <- shots_fired_chi %>%
  group_by(pd_desc, chi_category, chi_base, chi_final) %>%
  summarise(n = n(), .groups = "drop") %>%
  arrange(desc(n))
print(sf_chi_summary)

# =============================================================================
# PART 5: FELONY ASSAULT CATEGORY - CHARGE BREAKDOWN ANALYSIS
# =============================================================================

# Assumes chi_arrests_final exists from Part 1

cat("\n=== FELONY ASSAULT: PENAL LAW CHARGE BREAKDOWN ===\n")

# Filter to Felony Assault only
felony_assault_data <- chi_arrests_final %>%
  filter(offense_description1 == "FELONY ASSAULT")

# Overall stats
fa_overall <- felony_assault_data %>%
  summarise(
    n = n(),
    chi_mean = mean(chi_final),
    chi_median = median(chi_final),
    chi_sd = sd(chi_final)
  )

cat("OVERALL FELONY ASSAULT:\n")
cat(sprintf("  N: %s arrests\n", comma(fa_overall$n)))
cat(sprintf("  Mean CHI: %s days\n", comma(round(fa_overall$chi_mean))))
cat(sprintf("  Median CHI: %s days\n", comma(fa_overall$chi_median)))
cat("\n")

# Breakdown by law_code_trim
fa_by_charge <- felony_assault_data %>%
  group_by(law_code_trim, offense_name) %>%
  summarise(
    n = n(),
    chi_weight = first(chi_final),
    total_chi_days = sum(chi_final),
    .groups = "drop"
  ) %>%
  mutate(
    pct_of_arrests = 100 * n / sum(n),
    pct_of_total_chi = 100 * total_chi_days / sum(total_chi_days),
    contribution_to_mean = (n / sum(n)) * chi_weight
  ) %>%
  arrange(desc(contribution_to_mean))

cat("FELONY ASSAULT: CHARGE CONTRIBUTION TO MEAN CHI\n")
print(fa_by_charge, n = 30)

# Verify: sum of contributions should equal mean
cat(sprintf("\nSum of contributions: %.0f days (should ≈ mean of %s)\n", 
            sum(fa_by_charge$contribution_to_mean),
            comma(round(fa_overall$chi_mean))))

# Compare to reference points
cat("\n=== REFERENCE COMPARISONS ===\n")
cat(sprintf("Assault 1st (B Violent):
 5,475 days\n"))
cat(sprintf("Attempted Assault 1st (C Violent): 3,380 days\n"))
cat(sprintf("Felony Assault Category Mean: %s days\n", comma(round(fa_overall$chi_mean))))
cat(sprintf("  → %.1f%% of Assault 1st\n", 100 * fa_overall$chi_mean / 5475))
cat(sprintf("  → %.1f%% of Attempted Assault 1st\n", 100 * fa_overall$chi_mean / 3380))

# Export
write_csv(fa_by_charge, here("output", "felony_assault_charge_breakdown.csv"))

# =============================================================================
# PART 5b: SHOOTINGS CHI ASSIGNMENT
# =============================================================================

cat("\n=== SHOOTINGS OUTCOME BREAKDOWN ===\n")
shootings_outcome <- shootings %>%
  count(statistical_murder_flag) %>%
  mutate(
    outcome = if_else(statistical_murder_flag, "Fatal (Murder)", "Non-fatal (Fel Assault)"),
    pct = round(100 * n / sum(n), 1)
  )
print(shootings_outcome)

# For shootings:
# - Fatal → Murder 2nd weight (5475)
# - Non-fatal → Since gun was used, treat as Attempted Murder / Assault 1st level (5475)
#   Rationale: Gun violence bumps severity above typical Assault 2nd

shootings_chi <- shootings %>%
  mutate(
    chi_category = if_else(statistical_murder_flag, "Murder", "Non-fatal Shooting"),
    chi_final = 5475  # Both get top weight due to gun involvement
  )

cat("\n=== SHOOTINGS CHI SUMMARY ===\n")
shootings_chi_summary <- shootings_chi %>%
  group_by(chi_category) %>%
  summarise(
    n = n(),
    chi_mean = mean(chi_final),
    .groups = "drop"
  )
print(shootings_chi_summary)

# =============================================================================
# PART 6: SHOTS FIRED - PROPORTIONS BY YEAR
# =============================================================================

cat("\n=== SHOTS FIRED: PD_DESC PROPORTIONS BY YEAR ===\n")

sf_by_year_pd <- shots_fired_chi %>%
  group_by(year, pd_desc, chi_category, chi_final) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(year) %>%
  mutate(
    total = sum(n),
    prop = n / total,
    weighted_chi = prop * chi_final
  ) %>%
  ungroup()

sf_by_year_pd_wide <- sf_by_year_pd %>%
  select(year, pd_desc, prop) %>%
  pivot_wider(names_from = pd_desc, values_from = prop, values_fill = 0)
print(sf_by_year_pd_wide)

# Average CHI by year
sf_chi_by_year <- shots_fired_chi %>%
  group_by(year) %>%
  summarise(
    n = n(),
    chi_mean = mean(chi_final),
    chi_sd = sd(chi_final),
    chi_se = chi_sd / sqrt(n),
    chi_cv = chi_sd / chi_mean,
    .groups = "drop"
  )

cat("\n=== SHOTS FIRED: AVERAGE CHI BY YEAR ===\n")
print(sf_chi_by_year)

# =============================================================================
# PART 7: SHOTS FIRED - YEAR-OVER-YEAR VARIATION
# =============================================================================

sf_yoy <- sf_chi_by_year %>%
  arrange(year) %>%
  mutate(
    chi_lag = lag(chi_mean),
    chi_change = chi_mean - chi_lag,
    chi_pct_change = 100 * (chi_mean - chi_lag) / chi_lag
  )

cat("\n=== SHOTS FIRED: YEAR-OVER-YEAR CHANGES ===\n")
sf_yoy_display <- sf_yoy %>%
  filter(!is.na(chi_change)) %>%
  select(year, n, chi_mean, chi_change, chi_pct_change)
print(sf_yoy_display)

# Stability statistics
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
print(sf_stability)

# =============================================================================
# PART 8: SHOTS FIRED - VARIATION BY PATROL BOROUGH
# =============================================================================

# Map PSB codes to boroughs
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

# Add borough to shots fired
shots_fired_chi <- shots_fired_chi %>%
  left_join(psb_to_boro, by = "psb")

# Check PSB distribution
cat("\n=== SHOTS FIRED: PSB DISTRIBUTION ===\n")
sf_psb_counts <- shots_fired_chi %>%
  count(psb, borough) %>%
  arrange(desc(n))
print(sf_psb_counts)

# CHI by patrol borough
sf_chi_by_psb <- shots_fired_chi %>%
  filter(!is.na(psb)) %>%
  group_by(psb, borough) %>%
  summarise(
    n = n(),
    chi_mean = mean(chi_final),
    chi_sd = sd(chi_final),
    chi_se = chi_sd / sqrt(n),
    chi_cv = chi_sd / chi_mean,
    .groups = "drop"
  )

cat("\n=== SHOTS FIRED: CHI BY PATROL BOROUGH ===\n")
sf_chi_by_psb_sorted <- sf_chi_by_psb %>%
  arrange(borough, psb)
print(sf_chi_by_psb_sorted)

# CHI by borough (aggregated)
sf_chi_by_boro <- shots_fired_chi %>%
  filter(!is.na(borough)) %>%
  group_by(borough) %>%
  summarise(
    n = n(),
    chi_mean = mean(chi_final),
    chi_sd = sd(chi_final),
    chi_se = chi_sd / sqrt(n),
    chi_cv = chi_sd / chi_mean,
    .groups = "drop"
  )

cat("\n=== SHOTS FIRED: CHI BY BOROUGH ===\n")
sf_chi_by_boro_sorted <- sf_chi_by_boro %>%
  arrange(desc(chi_mean))
print(sf_chi_by_boro_sorted)

# Borough variation summary
sf_boro_variation <- sf_chi_by_boro %>%
  summarise(
    n_boros = n(),
    chi_grand_mean = mean(chi_mean),
    chi_between_boro_sd = sd(chi_mean),
    chi_cv_between = chi_between_boro_sd / chi_grand_mean,
    chi_min_boro = min(chi_mean),
    chi_max_boro = max(chi_mean),
    chi_range = chi_max_boro - chi_min_boro,
    chi_range_pct = 100 * chi_range / chi_grand_mean
  )

cat("\n=== SHOTS FIRED: BOROUGH VARIATION SUMMARY ===\n")
print(sf_boro_variation)

# =============================================================================
# PART 9: SHOTS FIRED - VARIATION BY YEAR AND BOROUGH
# =============================================================================

sf_chi_by_year_boro <- shots_fired_chi %>%
  filter(!is.na(borough)) %>%
  group_by(year, borough) %>%
  summarise(
    n = n(),
    chi_mean = mean(chi_final),
    chi_sd = sd(chi_final),
    .groups = "drop"
  )

cat("\n=== SHOTS FIRED: CHI BY YEAR AND BOROUGH ===\n")
sf_chi_by_year_boro_wide <- sf_chi_by_year_boro %>%
  select(year, borough, chi_mean) %>%
  pivot_wider(names_from = borough, values_from = chi_mean)
print(sf_chi_by_year_boro_wide)

# Two-way summary
sf_year_boro_summary <- sf_chi_by_year_boro %>%
  summarise(
    overall_mean = mean(chi_mean),
    overall_sd = sd(chi_mean),
    n_cells = n()
  )

cat("\n=== SHOTS FIRED: YEAR x BOROUGH VARIATION ===\n")
print(sf_year_boro_summary)

# =============================================================================
# PART 10: RECOMMENDED WEIGHTS
# =============================================================================

cat("\n")
cat("=======================================================================\n")
cat("                    RECOMMENDED CHI WEIGHTS                           \n")
cat("=======================================================================\n")

# Shootings
shootings_recommended <- shootings_chi %>%
  summarise(
    n = n(),
    chi_recommended = round(mean(chi_final)),
    chi_95_lower = round(quantile(chi_final, 0.025)),
    chi_95_upper = round(quantile(chi_final, 0.975))
  ) %>%
  mutate(category = "Shooting (victim hit)")

# Shots Fired
sf_recommended <- shots_fired_chi %>%
  summarise(
    n = n(),
    chi_recommended = round(mean(chi_final)),
    chi_95_lower = round(quantile(chi_final, 0.025)),
    chi_95_upper = round(quantile(chi_final, 0.975))
  ) %>%
  mutate(category = "Shots Fired (no victim)")

gun_violence_weights <- bind_rows(shootings_recommended, sf_recommended) %>%
  select(category, n, chi_recommended, chi_95_lower, chi_95_upper)

cat("\n=== GUN VIOLENCE CHI WEIGHTS ===\n")
print(gun_violence_weights)

# =============================================================================
# PART 11: EXPORT RESULTS
# =============================================================================

write_csv(sf_chi_by_year, here("output", "sf_chi_by_year.csv"))
write_csv(sf_chi_by_boro, here("output", "sf_chi_by_borough.csv"))
write_csv(sf_chi_by_psb, here("output", "sf_chi_by_psb.csv"))
write_csv(sf_chi_by_year_boro, here("output", "sf_chi_by_year_borough.csv"))
write_csv(gun_violence_weights, here("output", "gun_violence_chi_weights.csv"))
write_csv(sf_pd_desc_counts, here("output", "sf_pd_desc_distribution.csv"))

# =============================================================================
# PART 12: PUBLICATION-QUALITY PLOTS
# =============================================================================

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
# Plot 1: Shots Fired CHI Over Time
# -----------------------------------------------------------------------------

p1_sf <- ggplot(sf_chi_by_year, aes(x = year, y = chi_mean)) +
  
  geom_ribbon(aes(ymin = chi_mean - 1.96 * chi_se, 
                  ymax = chi_mean + 1.96 * chi_se),
              fill = "gray80", alpha = 0.5) +
  geom_line(linewidth = 0.8, color = "black") +
  geom_point(size = 3, color = "black", fill = "white", shape = 21) +
  geom_hline(yintercept = MIN_GUN_HARM, linetype = "dashed", color = "gray50") +
  annotate("text", x = 2018.5, y = MIN_GUN_HARM + 50, 
           label = "CPW 2nd floor (3,380)", size = 3, hjust = 0, color = "gray40") +
  scale_x_continuous(breaks = 2018:2024) +
  scale_y_continuous(labels = comma, limits = c(3200, 3600)) +
  labs(
    title = "Shots Fired: Crime Harm Index Over Time",
    subtitle = "Mean CHI with 95% confidence interval",
    x = "Year",
    y = "Mean CHI (days)",
    caption = sprintf("Note: N = %s incidents (2018-2024). All incidents have CPW 2nd minimum floor.",
                      comma(nrow(shots_fired_chi)))
  ) +
  theme_pub()

ggsave(here("output", "fig_sf_chi_temporal.png"), p1_sf,
       width = 7, height = 5, dpi = 300, bg = "white")
ggsave(here("output", "fig_sf_chi_temporal.pdf"), p1_sf,
       width = 7, height = 5, bg = "white")

cat("Saved: fig_sf_chi_temporal\n")

# -----------------------------------------------------------------------------
# Plot 2: Shots Fired YoY Change
# -----------------------------------------------------------------------------

p2_sf_data <- sf_yoy %>%
  filter(!is.na(chi_pct_change))

p2_sf <- ggplot(p2_sf_data, aes(x = year, y = chi_pct_change)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "gray70", linewidth = 0.5) +
  geom_col(fill = "gray40", color = "black", linewidth = 0.3, width = 0.6) +
  scale_x_continuous(breaks = 2019:2024) +
  scale_y_continuous(labels = function(x) paste0(ifelse(x > 0, "+", ""), round(x, 1), "%")) +
  labs(
    title = "Shots Fired: Year-over-Year Change in CHI",
    subtitle = "Percent change in mean CHI from prior year",
    x = "Year",
    y = "Change from Prior Year (%)",
    caption = "Note: Positive values indicate higher proportion of assault-classified incidents."
  ) +
  theme_pub()

ggsave(here("output", "fig_sf_chi_yoy.png"), p2_sf,
       width = 6, height = 4, dpi = 300, bg = "white")
ggsave(here("output", "fig_sf_chi_yoy.pdf"), p2_sf,
       width = 6, height = 4, bg = "white")

cat("Saved: fig_sf_chi_yoy\n")

# -----------------------------------------------------------------------------
# Plot 3: Shots Fired CHI by Borough
# -----------------------------------------------------------------------------

p3_sf_data <- sf_chi_by_boro %>%
  mutate(
    chi_lower = chi_mean - 1.96 * chi_se,
    chi_upper = chi_mean + 1.96 * chi_se
  )

grand_mean_sf <- weighted.mean(sf_chi_by_boro$chi_mean, sf_chi_by_boro$n)

p3_sf <- ggplot(p3_sf_data, aes(x = reorder(borough, chi_mean), y = chi_mean)) +
  geom_hline(yintercept = grand_mean_sf, linetype = "dashed", color = "gray50") +
  geom_hline(yintercept = MIN_GUN_HARM, linetype = "dotted", color = "gray70") +
  geom_errorbar(aes(ymin = chi_lower, ymax = chi_upper),
                width = 0.2, linewidth = 0.5, color = "gray40") +
  geom_point(size = 4, color = "black") +
  coord_flip() +
  scale_y_continuous(labels = comma, limits = c(3200, 3600)) +
  labs(
    title = "Shots Fired: Crime Harm Index by Borough",
    subtitle = "Mean CHI with 95% CI; dashed line = citywide mean",
    x = NULL,
    y = "Mean CHI (days)",
    caption = "Note: Higher CHI indicates more assault-classified incidents vs. reckless endangerment."
  ) +
  theme_pub() +
  theme(panel.grid.major.y = element_blank())

ggsave(here("output", "fig_sf_chi_borough.png"), p3_sf,
       width = 6, height = 4, dpi = 300, bg = "white")
ggsave(here("output", "fig_sf_chi_borough.pdf"), p3_sf,
       width = 6, height = 4, bg = "white")

cat("Saved: fig_sf_chi_borough\n")

# -----------------------------------------------------------------------------
# Plot 4: Shots Fired PD_DESC Proportions Over Time (Stacked Area)
# -----------------------------------------------------------------------------

p4_sf_data <- sf_by_year_pd %>%
  mutate(
    pd_desc_clean = case_when(
      pd_desc == "ASSAULT 2,1,UNCLASSIFIED" ~ "Assault",
      pd_desc == "RECKLESS ENDANGERMENT 1" ~ "Reckless Endangerment",
      pd_desc == "RECKLESS ENDANGERMENT OF PROPE" ~ "RE (Property)",
      TRUE ~ "Other/Investigate"
    ),
    pd_desc_clean = factor(pd_desc_clean, 
                           levels = c("Assault", "Reckless Endangerment", 
                                      "RE (Property)", "Other/Investigate"))
  ) %>%
  group_by(year, pd_desc_clean) %>%
  summarise(prop = sum(prop), .groups = "drop")

p4_sf <- ggplot(p4_sf_data, aes(x = year, y = prop, fill = pd_desc_clean)) +
  geom_area(alpha = 0.8, color = "white", linewidth = 0.3) +
  scale_x_continuous(breaks = 2018:2024) +
  scale_y_continuous(labels = percent, expand = c(0, 0)) +
  scale_fill_manual(values = c("Assault" = "gray20", 
                               "Reckless Endangerment" = "gray50",
                               "RE (Property)" = "gray70",
                               "Other/Investigate" = "gray85")) +
  labs(
    title = "Shots Fired: Classification Distribution Over Time",
    subtitle = "Proportion of incidents by PD description category",
    x = "Year",
    y = "Proportion",
    caption = "Note: 'Assault' classification drives higher CHI; 'Other' typically from ShotSpotter/investigation."
  ) +
  theme_pub() +
  theme(legend.position = "right")

ggsave(here("output", "fig_sf_pd_desc_trend.png"), p4_sf,
       width = 8, height = 5, dpi = 300, bg = "white")
ggsave(here("output", "fig_sf_pd_desc_trend.pdf"), p4_sf,
       width = 8, height = 5, bg = "white")

cat("Saved: fig_sf_pd_desc_trend\n")

# -----------------------------------------------------------------------------
# Plot 5: Shots Fired CHI by Year and Borough (Heatmap)
# -----------------------------------------------------------------------------

p5_sf <- ggplot(sf_chi_by_year_boro, aes(x = factor(year), y = borough, fill = chi_mean)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = comma(round(chi_mean))), size = 3, color = "white") +
  scale_fill_gradient(low = "gray70", high = "gray20", 
                      labels = comma,
                      name = "Mean CHI") +
  labs(
    title = "Shots Fired: CHI by Year and Borough",
    subtitle = "Darker = higher harm index (more assault classifications)",
    x = "Year",
    y = NULL,
    caption = "Note: Values represent mean CHI in days."
  ) +
  theme_pub() +
  theme(
    panel.grid = element_blank(),
    legend.position = "right"
  )

ggsave(here("output", "fig_sf_chi_heatmap.png"), p5_sf,
       width = 8, height = 4, dpi = 300, bg = "white")
ggsave(here("output", "fig_sf_chi_heatmap.pdf"), p5_sf,
       width = 8, height = 4, bg = "white")

cat("Saved: fig_sf_chi_heatmap\n")

# =============================================================================
# PART 13: FINAL SUMMARY
# =============================================================================

cat("\n")
cat("=======================================================================\n")
cat("                         FINAL SUMMARY                                \n")
cat("=======================================================================\n")
cat("\n")

cat("SHOOTINGS (victim hit):\n")
cat(sprintf("  N: %s incidents\n", comma(nrow(shootings_chi))))
cat(sprintf("  Recommended CHI: %s days\n", comma(shootings_recommended$chi_recommended)))
cat("  Rationale: All shootings treated as Murder/Assault 1st level due to gun use\n")
cat("\n")

cat("SHOTS FIRED (no victim):\n")
cat(sprintf("  N: %s incidents\n", comma(nrow(shots_fired_chi))))
cat(sprintf("  Recommended CHI: %s days\n", comma(sf_recommended$chi_recommended)))
cat(sprintf("  Temporal CV: %.2f%%\n", sf_stability$chi_cv_between * 100))
cat(sprintf("  Borough CV: %.2f%%\n", sf_boro_variation$chi_cv_between * 100))
cat("  Rationale: Weighted by PD_DESC with CPW 2nd (3,380) minimum floor\n")
cat("\n")

cat("=== FILES SAVED ===\n")
list.files(here("output"), pattern = "^(sf_|fig_sf|gun_)")

