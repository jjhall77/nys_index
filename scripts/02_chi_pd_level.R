# =============================================================================
# NYC Crime Harm Index - Script 02: PD-Description Based CHI
# =============================================================================
#
# Purpose: Calculate CHI weights at the PD_DESCRIPTION level
#          This is the "granular" model — one weight per pd_description
#
# Key difference from offense-level model:
# - pd_description is a SUBSET of offense_description
# - Within each pd_description, we examine law_code distribution
# - CHI is weighted average of law_code charges within each pd_description
#
# Example:
#   offense_description1 = "FELONY ASSAULT" contains:
#     - pd_description = "ASSAULT 2,1,UNCLASSIFIED" (mostly Assault 2nd)
#     - pd_description = "ASSAULT 1" (Assault 1st — higher harm)
#     - pd_description = "STRANGULATION 1ST" (C violent)
#     - etc.
#
# Unit of analysis: COMPLAINT (one observation per complaint_key)
# Year assignment: COMPLAINT date (incident date), not arrest date
#
# Outputs:
#   - chi_pd_level:          Incident-level dataset (one row per complaint_key)
#   - chi_pd_weights_full:   Full lookup of pd_description → CHI (ALL pd_descs)
#   - chi_pd_weights.csv:    Exported full lookup (output/tables/)
#   - chi_pd_weights.rds:    Exported full lookup (data/)
#   - Stability analysis across complaint years
#
# Dependencies: 00_chi_setup_v3.R
#
# Change log:
#   2026-02-09  v2  Source v3 setup; export FULL weights (drop n>=50 filter on
#                   primary export); add modal_law_code for interpretability;
#                   monotonicity note on attempt weights carried from setup.
# =============================================================================

# Run setup script if not already run
if (!exists("arrests_with_chi")) {
  source(here::here("00_chi_setup_v3.R"))
}

library(tidyverse)
library(here)
library(scales)

cat("\n")
cat(strrep("=", 70), "\n")
cat("CHI MODEL 2: PD-DESCRIPTION LEVEL (GRANULAR)\n")
cat(strrep("=", 70), "\n\n")

# =============================================================================
# PART 1: EXPLORE PD_DESCRIPTION STRUCTURE
# =============================================================================

cat("EXPLORING PD_DESCRIPTION STRUCTURE...\n")

# How many pd_descriptions per offense category?
pd_counts <- arrests_with_chi %>%
  group_by(offense_description1) %>%
  summarise(
    n_arrests = n(),
    n_pd_descriptions = n_distinct(pd_description),
    .groups = "drop"
  )
cat("\n=== PD_DESCRIPTIONS BY OFFENSE ===\n")
print(pd_counts)

# Full breakdown
pd_detail <- arrests_with_chi %>%
  count(offense_description1, pd_description) %>%
  arrange(offense_description1, desc(n)) %>%
  group_by(offense_description1) %>%
  mutate(
    pct = round(100 * n / sum(n), 1),
    cumulative_pct = cumsum(pct)
  ) %>%
  ungroup()

cat("\n=== PD_DESCRIPTION DETAIL (Top 10 per category) ===\n")
pd_detail %>%
  group_by(offense_description1) %>%
  slice_head(n = 10) %>%
  print(n = 100)

# =============================================================================
# PART 2: BUILD LAW_CODE DISTRIBUTION WITHIN PD_DESCRIPTION
# =============================================================================

cat("\nBUILDING LAW_CODE DISTRIBUTIONS WITHIN PD_DESCRIPTIONS...\n")

# Calculate law_code distribution within each pd_description
# arrests_with_chi already has chi_adjusted from setup
law_within_pd <- arrests_with_chi %>%
  group_by(offense_description1, pd_description, law_code_trim, chi_adjusted) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(offense_description1, pd_description) %>%
  mutate(
    total_in_pd = sum(n),
    pct = n / total_in_pd,
    # Contribution of this law_code to pd_description's mean CHI
    chi_contribution = pct * coalesce(chi_adjusted, 0)
  ) %>%
  ungroup()

cat("\n=== SAMPLE: LAW_CODE WITHIN PD_DESCRIPTION (Felony Assault) ===\n")
sample_output <- law_within_pd %>%
  filter(offense_description1 == "FELONY ASSAULT") %>%
  arrange(pd_description, desc(n)) %>%
  select(pd_description, law_code_trim, chi_adjusted, n, pct, chi_contribution)
print(sample_output, n = 80)

# =============================================================================
# PART 3: CALCULATE CHI WEIGHT FOR EACH PD_DESCRIPTION
# =============================================================================

cat("\nCALCULATING CHI WEIGHTS BY PD_DESCRIPTION...\n")

# CHI for each pd_description = weighted mean of law_codes within it
# This is the FULL lookup — no sample-size filter applied here.
chi_pd_weights_full <- arrests_with_chi %>%
  group_by(offense_description1, pd_description) %>%
  summarise(
    n_arrests    = n(),
    n_law_codes  = n_distinct(law_code_trim),
    chi_weight   = round(mean(chi_adjusted, na.rm = TRUE)),
    chi_median   = round(median(chi_adjusted, na.rm = TRUE)),
    chi_sd       = round(sd(chi_adjusted, na.rm = TRUE), 1),
    chi_min      = min(chi_adjusted, na.rm = TRUE),
    chi_max      = max(chi_adjusted, na.rm = TRUE),
    pct_matched  = round(mean(!is.na(chi_adjusted)), 3),
    # Modal charge within this pd — aids interpretability
    modal_law_code = names(sort(table(law_code_trim), decreasing = TRUE))[1],
    modal_law_pct  = round(max(table(law_code_trim)) / n(), 3),
    .groups = "drop"
  ) %>%
  arrange(offense_description1, desc(n_arrests))

cat("\n=== CHI WEIGHTS BY PD_DESCRIPTION (ALL) ===\n")
chi_pd_weights_full %>%
  select(offense_description1, pd_description, n_arrests,
         chi_weight, chi_sd, pct_matched) %>%
  print(n = 100)

# Variance WITHIN pd_description (how much variation in law_codes?)
cat("\n=== WITHIN-PD_DESCRIPTION VARIATION ===\n")
within_variation <- chi_pd_weights_full %>%
  filter(n_arrests >= 30, chi_sd > 0) %>%
  mutate(chi_cv = round(chi_sd / chi_weight, 3)) %>%
  select(offense_description1, pd_description, n_arrests,
         chi_weight, chi_sd, chi_cv) %>%
  arrange(desc(chi_cv))
print(within_variation, n = 30)

# =============================================================================
# PART 4: ASSIGN CHI TO INCIDENTS USING PD_DESCRIPTION
# =============================================================================

cat("\nASSIGNING CHI TO INCIDENTS BY PD_DESCRIPTION...\n")

# Create slim lookup (just the weight column we need for joining)
pd_chi_lookup <- chi_pd_weights_full %>%
  select(offense_description1, pd_description, chi_pd = chi_weight)

# Join to arrests
chi_arrests_pd <- arrests_with_chi %>%
  left_join(pd_chi_lookup, by = c("offense_description1", "pd_description"))

# Check coverage
cat(sprintf("  Arrests with pd_description CHI: %s (%.1f%%)\n",
            comma(sum(!is.na(chi_arrests_pd$chi_pd))),
            100 * mean(!is.na(chi_arrests_pd$chi_pd))))

# One observation per incident (max harm)
chi_pd_level <- chi_arrests_pd %>%
  group_by(complaint_key) %>%
  slice_max(chi_pd, n = 1, with_ties = FALSE) %>%
  ungroup()

cat(sprintf("  Incidents (unique complaint_key): %s\n", comma(nrow(chi_pd_level))))

# =============================================================================
# PART 5: CONTRIBUTION TABLES (QA)
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("QA: PD_DESCRIPTION CONTRIBUTION TO CATEGORY MEAN CHI\n")
cat(strrep("=", 70), "\n")

# How much does each pd_description contribute to its parent category's mean?
pd_contribution <- chi_pd_level %>%
  group_by(offense_description1, pd_description) %>%
  summarise(
    n = n(),
    chi_weight = first(chi_pd),
    .groups = "drop"
  ) %>%
  group_by(offense_description1) %>%
  mutate(
    pct_of_incidents = round(100 * n / sum(n), 2),
    contribution_to_mean = round((n / sum(n)) * chi_weight, 1)
  ) %>%
  arrange(offense_description1, desc(contribution_to_mean))

for (cat_name in unique(chi_pd_level$offense_description1)) {
  cat(sprintf("\n--- %s ---\n", cat_name))
  contrib <- pd_contribution %>% filter(offense_description1 == cat_name)
  print(contrib %>% select(-offense_description1), n = 15)
  cat(sprintf("Sum of contributions: %.0f days (category mean)\n",
              sum(contrib$contribution_to_mean)))
}

# =============================================================================
# PART 6: STABILITY ANALYSIS BY COMPLAINT YEAR
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("STABILITY ANALYSIS BY COMPLAINT YEAR\n")
cat(strrep("=", 70), "\n")

# CHI by year for pd-level model (aggregated to offense level for comparison)
chi_by_year_pd <- chi_pd_level %>%
  group_by(complaint_year, offense_description1) %>%
  summarise(
    n_incidents = n(),
    chi_mean = mean(chi_pd),
    chi_median = median(chi_pd),
    chi_sd = sd(chi_pd),
    chi_se = chi_sd / sqrt(n_incidents),
    .groups = "drop"
  )

cat("\n=== CHI BY YEAR (PD-LEVEL MODEL, AGGREGATED TO OFFENSE) ===\n")
print(chi_by_year_pd %>%
        mutate(chi_mean = round(chi_mean), chi_se = round(chi_se, 1)) %>%
        select(complaint_year, offense_description1, n_incidents, chi_mean, chi_se),
      n = 60)

# Year-over-year changes
yoy_pd <- chi_by_year_pd %>%
  arrange(offense_description1, complaint_year) %>%
  group_by(offense_description1) %>%
  mutate(
    chi_lag = lag(chi_mean),
    chi_change = chi_mean - chi_lag,
    chi_pct_change = 100 * (chi_mean - chi_lag) / chi_lag
  ) %>%
  ungroup() %>%
  filter(!is.na(chi_change))

cat("\n=== YEAR-OVER-YEAR CHANGES (PD-LEVEL MODEL) ===\n")
print(yoy_pd %>%
        mutate(chi_mean = round(chi_mean), chi_pct_change = round(chi_pct_change, 1)) %>%
        select(complaint_year, offense_description1, chi_mean, chi_pct_change),
      n = 50)

# Stability summary
stability_pd <- chi_by_year_pd %>%
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

cat("\n=== STABILITY SUMMARY (PD-LEVEL MODEL) ===\n")
print(stability_pd %>%
        mutate(
          chi_grand_mean = round(chi_grand_mean),
          chi_cv_between = round(chi_cv_between, 4),
          chi_range_pct = round(chi_range_pct, 2)
        ))

# =============================================================================
# PART 7: STABILITY AT PD_DESCRIPTION LEVEL
# =============================================================================

cat("\n=== PD_DESCRIPTION STABILITY ACROSS YEARS ===\n")

# How stable are individual pd_descriptions over time?
pd_year_stability <- chi_pd_level %>%
  group_by(offense_description1, pd_description, complaint_year) %>%
  summarise(n = n(), chi_mean = mean(chi_pd), .groups = "drop") %>%
  filter(n >= 30) %>%
  group_by(offense_description1, pd_description) %>%
  summarise(
    n_years = n(),
    total_n = sum(n),
    chi_grand_mean = mean(chi_mean),
    chi_between_sd = sd(chi_mean),
    chi_cv_between = chi_between_sd / chi_grand_mean,
    .groups = "drop"
  ) %>%
  filter(n_years >= 3)  # At least 3 years of data

cat("\nMost stable pd_descriptions (lowest CV):\n")
print(pd_year_stability %>%
        arrange(chi_cv_between) %>%
        head(15) %>%
        mutate(chi_cv_between = round(chi_cv_between, 4)))

cat("\nLeast stable pd_descriptions (highest CV):\n")
print(pd_year_stability %>%
        arrange(desc(chi_cv_between)) %>%
        head(15) %>%
        mutate(chi_cv_between = round(chi_cv_between, 4)))

# =============================================================================
# PART 8: RECOMMENDED WEIGHTS
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("RECOMMENDED CHI WEIGHTS (PD-LEVEL MODEL)\n")
cat(strrep("=", 70), "\n")

# At offense level (for comparison with offense-level model)
recommended_pd_offense <- chi_pd_level %>%
  group_by(offense_description1) %>%
  summarise(
    n_incidents = n(),
    chi_recommended = round(mean(chi_pd)),
    chi_median = median(chi_pd),
    chi_sd = sd(chi_pd),
    chi_95_lower = round(quantile(chi_pd, 0.025)),
    chi_95_upper = round(quantile(chi_pd, 0.975)),
    .groups = "drop"
  ) %>%
  arrange(desc(chi_recommended))

cat("\nOffense-level summary (from PD model):\n")
print(recommended_pd_offense)

# Filtered view for console display (n >= 50)
cat("\nFull pd_description weights (n >= 50):\n")
chi_pd_weights_display <- chi_pd_weights_full %>%
  filter(n_arrests >= 50) %>%
  select(offense_description1, pd_description, n_arrests,
         chi_weight, chi_sd, modal_law_code, modal_law_pct) %>%
  arrange(offense_description1, desc(chi_weight))
print(chi_pd_weights_display, n = 80)


chi_pd_key <- chi_pd_weights_full %>%
  select(offense_description1, pd_description, chi_weight)

write_csv(chi_pd_key, here("output", "tables", "chi_pd_key.csv"))
saveRDS(chi_pd_key, here("output", "chi_pd_key.rds"))

# =============================================================================
# PART 9: EXPORT RESULTS
# =============================================================================

cat("\n=== SAVING RESULTS ===\n")

# Ensure output directories exist
dir.create(here("data"), showWarnings = FALSE)
dir.create(here("output", "tables"), showWarnings = FALSE)
dir.create(here("output", "figures"), showWarnings = FALSE)

# --- Primary deliverable: FULL pd_description weights (no sample-size filter)
write_csv(chi_pd_weights_full, here("output", "tables", "chi_pd_weights.csv"))
saveRDS(chi_pd_weights_full, here("data", "chi_pd_weights.rds"))
cat(sprintf("  Saved: output/tables/chi_pd_weights.csv  (%d rows)\n",
            nrow(chi_pd_weights_full)))

# --- Category-level summary
category_summary <- chi_pd_weights_full %>%
  group_by(offense_description1) %>%
  summarise(
    n_pd_descriptions = n(),
    total_arrests     = sum(n_arrests),
    category_chi_mean = round(weighted.mean(chi_weight, n_arrests)),
    chi_range         = paste0(min(chi_weight), " \u2013 ", max(chi_weight)),
    .groups = "drop"
  )
cat("\n=== CATEGORY SUMMARY ===\n")
print(category_summary, n = 20)
cat(sprintf("\nTotal pd_descriptions: %d\n", nrow(chi_pd_weights_full)))
cat(sprintf("Total arrests covered: %s\n", comma(sum(chi_pd_weights_full$n_arrests))))

# --- Incident-level data
saveRDS(chi_pd_level, here("data", "chi_pd_level.rds"))

# --- Supporting tables
write_csv(chi_by_year_pd, here("output", "tables", "chi_pd_by_year.csv"))
write_csv(stability_pd, here("output", "tables", "chi_pd_stability.csv"))
write_csv(pd_contribution, here("output", "tables", "chi_pd_contribution.csv"))
write_csv(law_within_pd, here("output", "tables", "chi_law_within_pd.csv"))

cat("  Saved: data/chi_pd_level.rds\n")
cat("  Saved: data/chi_pd_weights.rds\n")
cat("  Saved: output/tables/chi_pd_by_year.csv\n")
cat("  Saved: output/tables/chi_pd_stability.csv\n")
cat("  Saved: output/tables/chi_pd_contribution.csv\n")
cat("  Saved: output/tables/chi_law_within_pd.csv\n")

# =============================================================================
# PART 10: VISUALIZATION
# =============================================================================

cat("\n=== CREATING PLOTS ===\n")

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

# Plot 1: PD_description weights within each offense category
p1_data <- chi_pd_weights_full %>%
  filter(n_arrests >= 100) %>%
  mutate(offense_clean = offense_labels[offense_description1]) %>%
  filter(!is.na(offense_clean))

# Top 10 pd_descriptions per category for readability
p1_data_top <- p1_data %>%
  group_by(offense_clean) %>%
  slice_head(n = 10) %>%
  ungroup()

p1 <- ggplot(p1_data_top, aes(x = reorder(pd_description, chi_weight),
                              y = chi_weight)) +
  geom_col(fill = "gray40", width = 0.7) +
  geom_text(aes(label = comma(chi_weight)), hjust = -0.1, size = 2.5) +
  facet_wrap(~ offense_clean, scales = "free", ncol = 2) +
  coord_flip() +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "CHI Weights by PD_Description",
    subtitle = "Top 10 within each offense category (n \u2265 100 arrests)",
    x = NULL,
    y = "CHI Weight (days)"
  ) +
  theme_pub() +
  theme(
    panel.grid.major.y = element_blank(),
    axis.text.y = element_text(size = 6)
  )
p1
ggsave(here("output", "figures", "fig04_chi_pd_weights.png"), p1,
       width = 14, height = 12, dpi = 300, bg = "white")

# Plot 2: Within-pd_description variation (shows how much law_codes vary)
p2_data <- within_variation %>%
  mutate(offense_clean = offense_labels[offense_description1]) %>%
  filter(!is.na(offense_clean), n_arrests >= 100)

p2 <- ggplot(p2_data, aes(x = chi_weight, y = chi_sd)) +
  geom_point(aes(size = n_arrests), alpha = 0.6) +
  geom_abline(slope = 0.5, intercept = 0, linetype = "dashed", color = "gray50") +
  facet_wrap(~ offense_clean, scales = "free") +
  scale_x_continuous(labels = comma) +
  scale_y_continuous(labels = comma) +
  scale_size_continuous(labels = comma, range = c(2, 8)) +
  labs(
    title = "Within-PD_Description Variation",
    subtitle = "Each point = one pd_description; size = arrest count",
    x = "Mean CHI (days)",
    y = "SD of CHI within pd_description",
    size = "N Arrests",
    caption = "Dashed line: CV = 0.5. Points above line have high within-category variation."
  ) +
  theme_pub()
p2
ggsave(here("output", "figures", "fig05_chi_pd_variation.png"), p2,
       width = 12, height = 10, dpi = 300, bg = "white")

cat("  Saved: fig04_chi_pd_weights.png\n")
cat("  Saved: fig05_chi_pd_variation.png\n")

cat("\n")
cat(strrep("=", 70), "\n")
cat("PD-LEVEL MODEL COMPLETE\n")
cat(strrep("=", 70), "\n")
cat("\nNext: Run 03_chi_model_comparison.R to compare models\n")