# =============================================================================
# NYC Crime Harm Index - Script 01: Offense-Description Based CHI
# =============================================================================
#
# Purpose: Calculate CHI weights at the OFFENSE_DESCRIPTION level
#          This is the "baseline" model - one weight per offense category
#
# Unit of analysis: COMPLAINT (one observation per complaint_key)
# Year assignment: COMPLAINT date (incident date), not arrest date
# Aggregation level: offense_description1 (10 categories)
#
# Categories:
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
# Outputs:
# - chi_offense_level: Dataset with one row per incident, CHI assigned
# - Stability analysis across complaint years
# - Recommended weights with confidence intervals
#
# =============================================================================

# Run setup script if not already run
if (!exists("incidents_chi")) {
  source(here::here("00_chi_setup_v2.R"))
}

library(tidyverse)
library(here)
library(scales)

cat("\n")
cat(strrep("=", 70), "\n")
cat("CHI MODEL 1: OFFENSE-DESCRIPTION LEVEL\n")
cat(strrep("=", 70), "\n\n")

# =============================================================================
# PART 1: USE INCIDENT DATA FROM SETUP
# =============================================================================

cat("LOADING INCIDENT DATA FROM SETUP...\n")

# incidents_chi already has:
#   - One row per complaint_key (highest CHI charge kept)
#   - chi_adjusted = final CHI score with attempt adjustments
#   - All filtering for appropriate codes already done

chi_offense_level <- incidents_chi %>%
  rename(chi_final = chi_adjusted)  # For consistency with downstream code

cat(sprintf("  Incidents loaded: %s\n", comma(nrow(chi_offense_level))))

# =============================================================================
# PART 2: CHI SUMMARY BY OFFENSE CATEGORY
# =============================================================================

cat("\n=== CHI SUMMARY BY OFFENSE CATEGORY ===\n")
chi_summary <- chi_offense_level %>%
  group_by(offense_description1) %>%
  summarise(
    n = n(),
    chi_mean = round(mean(chi_final)),
    chi_median = median(chi_final),
    chi_sd = round(sd(chi_final)),
    chi_min = min(chi_final),
    chi_max = max(chi_final),
    .groups = "drop"
  ) %>%
  arrange(desc(chi_mean))
print(chi_summary)

# =============================================================================
# PART 3: CHARGE CONTRIBUTION TABLES (QA)
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("QA: CHARGE CONTRIBUTION TO MEAN CHI BY OFFENSE CATEGORY\n")
cat(strrep("=", 70), "\n")

make_contribution_table <- function(data, category_name) {
  data %>%
    filter(offense_description1 == category_name) %>%
    group_by(law_code_trim, offense_name) %>%
    summarise(
      n = n(),
      chi_weight = first(chi_final),
      .groups = "drop"
    ) %>%
    mutate(
      pct_of_incidents = round(100 * n / sum(n), 2),
      contribution_to_mean = round((n / sum(n)) * chi_weight, 1)
    ) %>%
    arrange(desc(contribution_to_mean))
}

for (cat_name in unique(chi_offense_level$offense_description1)) {
  cat(sprintf("\n--- %s ---\n", cat_name))
  contrib <- make_contribution_table(chi_offense_level, cat_name)
  print(contrib, n = 15)
  cat(sprintf("Sum of contributions: %.0f days (= category mean)\n", sum(contrib$contribution_to_mean)))
}

# =============================================================================
# PART 4: STABILITY ANALYSIS BY COMPLAINT YEAR
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("STABILITY ANALYSIS BY COMPLAINT YEAR\n")
cat(strrep("=", 70), "\n")

# Calculate weighted CHI by complaint year
chi_by_year <- chi_offense_level %>%
  group_by(complaint_year, offense_description1) %>%
  summarise(
    n_incidents = n(),
    chi_mean = mean(chi_final),
    chi_median = median(chi_final),
    chi_sd = sd(chi_final),
    chi_se = chi_sd / sqrt(n_incidents),
    chi_cv = chi_sd / chi_mean,
    .groups = "drop"
  )

cat("\n=== CHI BY COMPLAINT YEAR ===\n")
chi_by_year_display <- chi_by_year %>%
  mutate(
    chi_mean = round(chi_mean),
    chi_se = round(chi_se, 1)
  ) %>%
  select(complaint_year, offense_description1, n_incidents, chi_mean, chi_se, chi_cv)
print(chi_by_year_display, n = 60)

# Wide format for comparison
chi_wide <- chi_by_year %>%
  select(complaint_year, offense_description1, chi_mean) %>%
  pivot_wider(
    names_from = complaint_year, 
    values_from = chi_mean,
    names_prefix = "y"
  )
cat("\n=== CHI BY YEAR (WIDE) ===\n")
print(chi_wide)

# Year-over-year changes
yoy_changes <- chi_by_year %>%
  arrange(offense_description1, complaint_year) %>%
  group_by(offense_description1) %>%
  mutate(
    chi_lag = lag(chi_mean),
    chi_change = chi_mean - chi_lag,
    chi_pct_change = 100 * (chi_mean - chi_lag) / chi_lag
  ) %>%
  ungroup() %>%
  filter(!is.na(chi_change))

cat("\n=== YEAR-OVER-YEAR CHANGES ===\n")
yoy_display <- yoy_changes %>%
  mutate(
    chi_mean = round(chi_mean),
    chi_change = round(chi_change),
    chi_pct_change = round(chi_pct_change, 1)
  ) %>%
  select(complaint_year, offense_description1, chi_mean, chi_change, chi_pct_change)
print(yoy_display, n = 50)

# Stability summary
stability_summary <- chi_by_year %>%
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

cat("\n=== STABILITY SUMMARY (OFFENSE-LEVEL MODEL) ===\n")
stability_display <- stability_summary %>%
  mutate(
    chi_grand_mean = round(chi_grand_mean),
    chi_between_year_sd = round(chi_between_year_sd, 1),
    chi_cv_between = round(chi_cv_between, 4),
    chi_range = round(chi_range),
    chi_range_pct = round(chi_range_pct, 2)
  )
print(stability_display)

# =============================================================================
# PART 5: RECOMMENDED WEIGHTS
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("RECOMMENDED CHI WEIGHTS (OFFENSE-LEVEL MODEL)\n")
cat(strrep("=", 70), "\n")

recommended_weights_offense <- chi_offense_level %>%
  group_by(offense_description1) %>%
  summarise(
    n_incidents = n(),
    chi_recommended = round(mean(chi_final)),
    chi_median = median(chi_final),
    chi_sd = sd(chi_final),
    chi_se = chi_sd / sqrt(n_incidents),
    chi_95_lower = round(quantile(chi_final, 0.025)),
    chi_95_upper = round(quantile(chi_final, 0.975)),
    .groups = "drop"
  ) %>%
  arrange(desc(chi_recommended))

print(recommended_weights_offense)

# =============================================================================
# PART 6: EXPORT RESULTS
# =============================================================================

cat("\n=== SAVING RESULTS ===\n")

# Save incident-level data
saveRDS(chi_offense_level, here("data", "chi_offense_level.rds"))

# Export tables
write_csv(chi_by_year, here("output", "tables", "chi_offense_by_year.csv"))
write_csv(stability_summary, here("output", "tables", "chi_offense_stability.csv"))
write_csv(recommended_weights_offense, here("output", "tables", "chi_offense_recommended.csv"))
write_csv(yoy_changes, here("output", "tables", "chi_offense_yoy_changes.csv"))

cat("  Saved: data/chi_offense_level.rds\n")
cat("  Saved: output/tables/chi_offense_by_year.csv\n")
cat("  Saved: output/tables/chi_offense_stability.csv\n")
cat("  Saved: output/tables/chi_offense_recommended.csv\n")
cat("  Saved: output/tables/chi_offense_yoy_changes.csv\n")

# =============================================================================
# PART 7: VISUALIZATION
# =============================================================================

cat("\n=== CREATING PLOTS ===\n")

# Theme
theme_pub <- function() {
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      axis.line = element_line(color = "black", linewidth = 0.3),
      plot.title = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(size = 10, color = "gray40"),
      strip.text = element_text(face = "bold")
    )
}

# Clean offense labels (all 10 categories)
offense_labels <- c(
  "MURDER & NON-NEGL. MANSLAUGHTE" = "Murder/Manslaughter",
  "RAPE" = "Rape",
  "ROBBERY" = "Robbery",
  "FELONY ASSAULT" = "Felony Assault",
  "BURGLARY" = "Burglary",
  "GRAND LARCENY" = "Grand Larceny",
  "GRAND LARCENY OF MOTOR VEHICLE" = "GLA Motor Vehicle",
  "ASSAULT 3 & RELATED OFFENSES" = "Misd. Assault",
  "PETIT LARCENY" = "Petit Larceny",
  "SEX CRIMES" = "Sex Crimes"
)

# Plot 1: CHI over time
p1 <- chi_by_year %>%
  mutate(offense_clean = offense_labels[offense_description1]) %>%
  filter(!is.na(offense_clean)) %>%
  ggplot(aes(x = complaint_year, y = chi_mean)) +
  geom_ribbon(aes(ymin = chi_mean - 1.96 * chi_se, 
                  ymax = chi_mean + 1.96 * chi_se),
              fill = "gray80", alpha = 0.5) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  facet_wrap(~ offense_clean, scales = "free_y", ncol = 3) +
  scale_x_continuous(breaks = 2018:2022) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Crime Harm Index Over Time (Offense-Level Model)",
    subtitle = "Mean CHI by complaint year with 95% CI",
    x = "Complaint Year",
    y = "Mean CHI (days)",
    caption = "Note: Year assigned by complaint date (incident date), not arrest date."
  ) +
  theme_pub()
p1
ggsave(here("output", "figures", "fig01_chi_offense_temporal.png"), p1,
       width = 10, height = 8, dpi = 300, bg = "white")

# Plot 2: YoY changes
p2 <- yoy_changes %>%
  mutate(offense_clean = offense_labels[offense_description1]) %>%
  filter(!is.na(offense_clean)) %>%
  ggplot(aes(x = complaint_year, y = chi_pct_change)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "gray70") +
  geom_col(fill = "gray40", width = 0.6) +
  facet_wrap(~ offense_clean, ncol = 3) +
  scale_x_continuous(breaks = 2019:2022) +
  scale_y_continuous(labels = function(x) paste0(ifelse(x > 0, "+", ""), round(x, 1), "%")) +
  labs(
    title = "Year-over-Year Change in CHI (Offense-Level Model)",
    subtitle = "Percent change from prior complaint year",
    x = "Complaint Year",
    y = "Change from Prior Year (%)"
  ) +
  theme_pub()
p2
ggsave(here("output", "figures", "fig02_chi_offense_yoy.png"), p2,
       width = 10, height = 8, dpi = 300, bg = "white")

# Plot 3: Recommended weights
p3 <- recommended_weights_offense %>%
  mutate(offense_clean = offense_labels[offense_description1]) %>%
  filter(!is.na(offense_clean)) %>%
  mutate(offense_clean = fct_reorder(offense_clean, chi_recommended)) %>%
  ggplot(aes(x = offense_clean, y = chi_recommended)) +
  geom_col(fill = "gray30", width = 0.6) +
  geom_errorbar(aes(ymin = chi_95_lower, ymax = chi_95_upper), width = 0.2) +
  geom_text(aes(label = comma(chi_recommended)), hjust = -0.2, fontface = "bold", size = 3) +
  coord_flip() +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Recommended CHI Weights (Offense-Level Model)",
    subtitle = "Mean CHI with 2.5th-97.5th percentile range",
    x = NULL,
    y = "CHI Weight (days)",
    caption = "Based on NYS Penal Law Article 70 sentencing guidelines midpoints."
  ) +
  theme_pub() +
  theme(panel.grid.major.y = element_blank())
p3
ggsave(here("output", "figures", "fig03_chi_offense_recommended.png"), p3,
       width = 8, height = 6, dpi = 300, bg = "white")

cat("  Saved: fig01_chi_offense_temporal.png\n")
cat("  Saved: fig02_chi_offense_yoy.png\n")
cat("  Saved: fig03_chi_offense_recommended.png\n")

cat("\n")
cat(strrep("=", 70), "\n")
cat("OFFENSE-LEVEL MODEL COMPLETE\n")
cat(strrep("=", 70), "\n")
cat("\nNext: Run 02_chi_pd_level.R for pd-description based CHI\n")
