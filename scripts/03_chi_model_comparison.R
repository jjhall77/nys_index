# =============================================================================
# NYC Crime Harm Index - Script 03: Model Comparison
# =============================================================================
#
# Purpose: Compare offense-level CHI model vs pd-description level model
#
# Questions addressed:
# 1. Do the two models produce different CHI weights?
# 2. Which model is more stable across years?
# 3. How correlated are the incident-level scores?
# 4. Does the pd-level model provide meaningfully more precision?
#
# Outputs:
# - Side-by-side stability comparison
# - Incident-level correlation analysis
# - Visualizations of model differences
#
# =============================================================================

# Run prior scripts if not already run
if (!exists("chi_offense_level")) {
  source(here::here("01_chi_offense_level.R"))
}
if (!exists("chi_pd_level")) {
  source(here::here("02_chi_pd_level.R"))
}

library(tidyverse)
library(here)
library(scales)

cat("\n")
cat(strrep("=", 70), "\n")
cat("MODEL COMPARISON: OFFENSE-LEVEL VS PD-LEVEL CHI\n")
cat(strrep("=", 70), "\n\n")

# =============================================================================
# PART 1: LOAD RESULTS FROM BOTH MODELS
# =============================================================================

cat("LOADING MODEL RESULTS...\n")

# Load if not in environment
if (!exists("chi_offense_level")) {
  chi_offense_level <- readRDS(here("data", "chi_offense_level.rds"))
}
if (!exists("chi_pd_level")) {
  chi_pd_level <- readRDS(here("data", "chi_pd_level.rds"))
}

# Load stability summaries
stability_offense <- read_csv(here("output", "tables", "chi_offense_stability.csv"), 
                              show_col_types = FALSE)
stability_pd <- read_csv(here("output", "tables", "chi_pd_stability.csv"), 
                         show_col_types = FALSE)

cat(sprintf("  Offense-level model: %s incidents\n", comma(nrow(chi_offense_level))))
cat(sprintf("  PD-level model: %s incidents\n", comma(nrow(chi_pd_level))))

# =============================================================================
# PART 2: MERGE INCIDENT-LEVEL DATA
# =============================================================================

cat("\nMERGING INCIDENT-LEVEL DATA...\n")

# Both datasets should have same complaint_keys
# Join to compare CHI scores side-by-side
comparison_data <- chi_offense_level %>%
  select(
    complaint_key,
    complaint_year,
    offense_description1,
    pd_description,
    chi_offense = chi_final
  ) %>%
  inner_join(
    chi_pd_level %>%
      select(complaint_key, chi_pd = chi_pd),
    by = "complaint_key"
  ) %>%
  mutate(
    chi_diff = chi_pd - chi_offense,
    chi_pct_diff = 100 * (chi_pd - chi_offense) / chi_offense
  )

cat(sprintf("  Matched incidents: %s\n", comma(nrow(comparison_data))))

# Check for mismatches
n_mismatch <- sum(comparison_data$chi_diff != 0)
cat(sprintf("  Incidents with different CHI: %s (%.1f%%)\n", 
            comma(n_mismatch), 100 * n_mismatch / nrow(comparison_data)))

# =============================================================================
# PART 3: COMPARE AGGREGATE WEIGHTS
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("AGGREGATE CHI WEIGHTS COMPARISON\n")
cat(strrep("=", 70), "\n")

# Calculate aggregate weights for both models
weights_comparison <- comparison_data %>%
  group_by(offense_description1) %>%
  summarise(
    n_incidents = n(),
    chi_offense_mean = mean(chi_offense),
    chi_pd_mean = mean(chi_pd),
    chi_diff = chi_pd_mean - chi_offense_mean,
    chi_pct_diff = 100 * chi_diff / chi_offense_mean,
    .groups = "drop"
  ) %>%
  arrange(desc(chi_offense_mean))

cat("\n=== MEAN CHI BY MODEL ===\n")
print(weights_comparison %>%
        mutate(
          chi_offense_mean = round(chi_offense_mean),
          chi_pd_mean = round(chi_pd_mean),
          chi_diff = round(chi_diff),
          chi_pct_diff = round(chi_pct_diff, 1)
        ))

# =============================================================================
# PART 4: STABILITY COMPARISON
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("TEMPORAL STABILITY COMPARISON\n")
cat(strrep("=", 70), "\n")

# Side-by-side stability metrics
stability_compare <- stability_offense %>%
  select(
    offense_description1,
    offense_cv = chi_cv_between,
    offense_range_pct = chi_range_pct
  ) %>%
  inner_join(
    stability_pd %>%
      select(
        offense_description1,
        pd_cv = chi_cv_between,
        pd_range_pct = chi_range_pct
      ),
    by = "offense_description1"
  ) %>%
  mutate(
    cv_diff = pd_cv - offense_cv,
    better_model = if_else(pd_cv < offense_cv, "PD-level", "Offense-level")
  )

cat("\n=== COEFFICIENT OF VARIATION (ACROSS YEARS) ===\n")
cat("Lower CV = more stable over time\n\n")
print(stability_compare %>%
        mutate(
          offense_cv = round(offense_cv, 4),
          pd_cv = round(pd_cv, 4),
          cv_diff = round(cv_diff, 4)
        ) %>%
        select(offense_description1, offense_cv, pd_cv, cv_diff, better_model))

# Which model is more stable overall?
cat("\n=== STABILITY WINNER BY CATEGORY ===\n")
print(table(stability_compare$better_model))

# Mean CV across categories
cat(sprintf("\nMean CV - Offense model: %.4f\n", mean(stability_compare$offense_cv, na.rm = TRUE)))
cat(sprintf("Mean CV - PD model: %.4f\n", mean(stability_compare$pd_cv, na.rm = TRUE)))

# =============================================================================
# PART 5: YEAR-BY-YEAR COMPARISON
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("YEAR-BY-YEAR COMPARISON\n")
cat(strrep("=", 70), "\n")

# CHI by year for both models
chi_by_year_compare <- comparison_data %>%
  group_by(complaint_year, offense_description1) %>%
  summarise(
    n = n(),
    chi_offense = mean(chi_offense),
    chi_pd = mean(chi_pd),
    chi_diff = mean(chi_pd) - mean(chi_offense),
    correlation = cor(chi_offense, chi_pd),
    .groups = "drop"
  )

cat("\n=== CHI BY YEAR - BOTH MODELS ===\n")
print(chi_by_year_compare %>%
        mutate(
          chi_offense = round(chi_offense),
          chi_pd = round(chi_pd),
          chi_diff = round(chi_diff),
          correlation = round(correlation, 3)
        ), n = 60)

# =============================================================================
# PART 6: INCIDENT-LEVEL CORRELATION
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("INCIDENT-LEVEL CORRELATION\n")
cat(strrep("=", 70), "\n")

# Overall correlation
overall_cor <- cor(comparison_data$chi_offense, comparison_data$chi_pd)
cat(sprintf("\nOverall Pearson correlation: %.4f\n", overall_cor))

# Correlation by offense category
cor_by_offense <- comparison_data %>%
  group_by(offense_description1) %>%
  summarise(
    n = n(),
    correlation = cor(chi_offense, chi_pd),
    mean_abs_diff = mean(abs(chi_diff)),
    .groups = "drop"
  )

cat("\n=== CORRELATION BY OFFENSE CATEGORY ===\n")
print(cor_by_offense %>%
        mutate(
          correlation = round(correlation, 4),
          mean_abs_diff = round(mean_abs_diff)
        ))

# Distribution of differences
cat("\n=== DISTRIBUTION OF CHI DIFFERENCES (PD - Offense) ===\n")
diff_summary <- comparison_data %>%
  summarise(
    mean_diff = mean(chi_diff),
    median_diff = median(chi_diff),
    sd_diff = sd(chi_diff),
    pct_pd_higher = mean(chi_diff > 0),
    pct_same = mean(chi_diff == 0),
    pct_pd_lower = mean(chi_diff < 0)
  )
print(diff_summary %>%
        mutate(
          mean_diff = round(mean_diff, 1),
          median_diff = round(median_diff, 1),
          sd_diff = round(sd_diff, 1),
          pct_pd_higher = round(pct_pd_higher, 3),
          pct_same = round(pct_same, 3),
          pct_pd_lower = round(pct_pd_lower, 3)
        ))

# =============================================================================
# PART 7: WHERE DO MODELS DIFFER MOST?
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("WHERE DO MODELS DIFFER MOST?\n")
cat(strrep("=", 70), "\n")

# By pd_description
diff_by_pd <- comparison_data %>%
  group_by(offense_description1, pd_description) %>%
  summarise(
    n = n(),
    chi_offense_mean = mean(chi_offense),
    chi_pd_mean = mean(chi_pd),
    mean_diff = mean(chi_diff),
    .groups = "drop"
  ) %>%
  filter(n >= 50) %>%
  arrange(desc(abs(mean_diff)))

cat("\n=== PD_DESCRIPTIONS WITH LARGEST CHI DIFFERENCES ===\n")
print(diff_by_pd %>%
        mutate(
          chi_offense_mean = round(chi_offense_mean),
          chi_pd_mean = round(chi_pd_mean),
          mean_diff = round(mean_diff)
        ) %>%
        head(20))

cat("\n=== PD_DESCRIPTIONS WHERE MODELS AGREE ===\n")
print(diff_by_pd %>%
        filter(abs(mean_diff) < 10) %>%
        mutate(
          chi_offense_mean = round(chi_offense_mean),
          chi_pd_mean = round(chi_pd_mean),
          mean_diff = round(mean_diff)
        ) %>%
        head(20))

# =============================================================================
# PART 8: IMPLICATIONS FOR TARGETING
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("IMPLICATIONS FOR TARGETING\n")
cat(strrep("=", 70), "\n")

# If we sum harm by some grouping (e.g., precinct), how different are results?
# Simulate by summing at complaint_year level
total_harm_comparison <- comparison_data %>%
  group_by(complaint_year, offense_description1) %>%
  summarise(
    n_incidents = n(),
    total_harm_offense = sum(chi_offense),
    total_harm_pd = sum(chi_pd),
    pct_diff = 100 * (total_harm_pd - total_harm_offense) / total_harm_offense,
    .groups = "drop"
  )

cat("\n=== TOTAL HARM BY YEAR (BOTH MODELS) ===\n")
print(total_harm_comparison %>%
        mutate(
          total_harm_offense = comma(total_harm_offense),
          total_harm_pd = comma(total_harm_pd),
          pct_diff = round(pct_diff, 2)
        ), n = 60)

# Would rankings change?
rank_comparison <- total_harm_comparison %>%
  group_by(complaint_year) %>%
  mutate(
    rank_offense = rank(-as.numeric(gsub(",", "", total_harm_offense))),
    rank_pd = rank(-as.numeric(gsub(",", "", total_harm_pd))),
    rank_same = rank_offense == rank_pd
  )

cat("\n=== DO OFFENSE CATEGORY RANKINGS CHANGE? ===\n")
cat(sprintf("Same ranking under both models: %.1f%%\n", 
            100 * mean(rank_comparison$rank_same)))

# =============================================================================
# PART 9: EXPORT COMPARISON RESULTS
# =============================================================================

cat("\n=== SAVING RESULTS ===\n")

write_csv(weights_comparison, here("output", "tables", "chi_model_weights_comparison.csv"))
write_csv(stability_compare, here("output", "tables", "chi_model_stability_comparison.csv"))
write_csv(chi_by_year_compare, here("output", "tables", "chi_model_year_comparison.csv"))
write_csv(diff_by_pd, here("output", "tables", "chi_model_pd_differences.csv"))

cat("  Saved: chi_model_weights_comparison.csv\n")
cat("  Saved: chi_model_stability_comparison.csv\n")
cat("  Saved: chi_model_year_comparison.csv\n")
cat("  Saved: chi_model_pd_differences.csv\n")

# =============================================================================
# PART 10: VISUALIZATIONS
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

# Plot 1: Scatter of incident-level CHI (both models)
set.seed(42)
sample_for_plot <- comparison_data %>%
  mutate(offense_clean = offense_labels[offense_description1]) %>%
  filter(!is.na(offense_clean)) %>%
  group_by(offense_description1) %>%
  mutate(rand = runif(n())) %>%
  arrange(rand, .by_group = TRUE) %>%
  slice_head(n = 3000) %>%
  select(-rand) %>%
  ungroup()

p1 <- sample_for_plot %>%
  ggplot(aes(x = chi_offense, y = chi_pd)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray50") +
  geom_point(alpha = 0.1, size = 0.5) +
  geom_smooth(method = "lm", se = FALSE, color = "red", linewidth = 0.8) +
  facet_wrap(~ offense_clean, scales = "free", ncol = 3) +
  scale_x_continuous(labels = comma) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Incident-Level CHI: Offense Model vs PD Model",
    subtitle = "Each point = one incident; dashed line = perfect agreement",
    x = "CHI - Offense-Level Model (days)",
    y = "CHI - PD-Level Model (days)",
    caption = sprintf("Sample of up to 3,000 incidents per category. Overall r = %.3f", overall_cor)
  ) +
  theme_pub()
p1
ggsave(here("output", "figures", "fig06_chi_model_scatter.png"), p1,
       width = 12, height = 10, dpi = 300, bg = "white")

# Plot 2: Stability comparison (CV)
p2_data <- stability_compare %>%
  mutate(offense_clean = offense_labels[offense_description1]) %>%
  filter(!is.na(offense_clean)) %>%
  pivot_longer(
    cols = c(offense_cv, pd_cv),
    names_to = "model",
    values_to = "cv"
  ) %>%
  mutate(model = if_else(model == "offense_cv", "Offense-Level", "PD-Level"))

p2 <- ggplot(p2_data, aes(x = offense_clean, y = cv * 100, fill = model)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_text(aes(label = sprintf("%.2f%%", cv * 100)),
            position = position_dodge(width = 0.7), vjust = -0.5, size = 2.5) +
  scale_fill_manual(values = c("Offense-Level" = "gray60", "PD-Level" = "gray30")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Temporal Stability: Offense-Level vs PD-Level Model",
    subtitle = "Coefficient of variation across complaint years (lower = more stable)",
    x = NULL,
    y = "CV (%)",
    fill = "Model"
  ) +
  theme_pub() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
    legend.position = "bottom"
  )
p2
ggsave(here("output", "figures", "fig07_chi_model_stability.png"), p2,
       width = 10, height = 6, dpi = 300, bg = "white")

# Plot 3: Year-by-year comparison
p3_data <- chi_by_year_compare %>%
  mutate(offense_clean = offense_labels[offense_description1]) %>%
  filter(!is.na(offense_clean)) %>%
  pivot_longer(
    cols = c(chi_offense, chi_pd),
    names_to = "model",
    values_to = "chi_mean"
  ) %>%
  mutate(model = if_else(model == "chi_offense", "Offense-Level", "PD-Level"))

p3 <- ggplot(p3_data, aes(x = complaint_year, y = chi_mean, color = model, linetype = model)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  facet_wrap(~ offense_clean, scales = "free_y", ncol = 3) +
  scale_color_manual(values = c("Offense-Level" = "gray50", "PD-Level" = "black")) +
  scale_linetype_manual(values = c("Offense-Level" = "dashed", "PD-Level" = "solid")) +
  scale_x_continuous(breaks = 2018:2022) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Mean CHI Over Time: Both Models",
    subtitle = "By complaint year",
    x = "Complaint Year",
    y = "Mean CHI (days)",
    color = "Model",
    linetype = "Model"
  ) +
  theme_pub() +
  theme(legend.position = "bottom")
p3
ggsave(here("output", "figures", "fig08_chi_model_temporal.png"), p3,
       width = 12, height = 10, dpi = 300, bg = "white")

# Plot 4: Distribution of differences
p4 <- comparison_data %>%
  filter(chi_diff != 0) %>%
  mutate(offense_clean = offense_labels[offense_description1]) %>%
  filter(!is.na(offense_clean)) %>%
  ggplot(aes(x = chi_diff)) +
  geom_histogram(bins = 50, fill = "gray40", color = "white") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
  facet_wrap(~ offense_clean, scales = "free", ncol = 3) +
  scale_x_continuous(labels = comma) +
  labs(
    title = "Distribution of CHI Differences (PD Model - Offense Model)",
    subtitle = "Only incidents where models differ",
    x = "CHI Difference (days)",
    y = "Count",
    caption = "Positive = PD model assigns higher harm; Negative = Offense model assigns higher harm"
  ) +
  theme_pub()
p4
ggsave(here("output", "figures", "fig09_chi_model_diff_dist.png"), p4,
       width = 12, height = 10, dpi = 300, bg = "white")

cat("  Saved: fig06_chi_model_scatter.png\n")
cat("  Saved: fig07_chi_model_stability.png\n")
cat("  Saved: fig08_chi_model_temporal.png\n")
cat("  Saved: fig09_chi_model_diff_dist.png\n")

# =============================================================================
# SUMMARY
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("MODEL COMPARISON SUMMARY\n")
cat(strrep("=", 70), "\n")

cat("\n1. OVERALL CORRELATION\n")
cat(sprintf("   Incident-level correlation between models: r = %.3f\n", overall_cor))

cat("\n2. STABILITY\n")
cat(sprintf("   Model with lower mean CV: %s\n",
            if_else(mean(stability_compare$offense_cv, na.rm = TRUE) < 
                    mean(stability_compare$pd_cv, na.rm = TRUE),
                    "Offense-Level", "PD-Level")))
cat(sprintf("   Offense-level mean CV: %.4f\n", mean(stability_compare$offense_cv, na.rm = TRUE)))
cat(sprintf("   PD-level mean CV: %.4f\n", mean(stability_compare$pd_cv, na.rm = TRUE)))
cat(sprintf("   PD-level wins in %d/%d categories\n",
            sum(stability_compare$better_model == "PD-level"),
            nrow(stability_compare)))

cat("\n3. PRACTICAL DIFFERENCES\n")
cat(sprintf("   %% of incidents with identical CHI: %.1f%%\n", 
            100 * mean(comparison_data$chi_diff == 0)))
cat(sprintf("   Mean absolute difference when different: %.0f days\n",
            mean(abs(comparison_data$chi_diff[comparison_data$chi_diff != 0]))))

cat("\n4. RECOMMENDATION\n")
if (overall_cor > 0.95 & mean(stability_compare$offense_cv, na.rm = TRUE) < 
    mean(stability_compare$pd_cv, na.rm = TRUE)) {
  cat("   The offense-level model is simpler and more stable.\n")
  cat("   Consider using it unless pd-level granularity is specifically needed.\n")
} else if (overall_cor > 0.95 & mean(stability_compare$pd_cv, na.rm = TRUE) < 
           mean(stability_compare$offense_cv, na.rm = TRUE)) {
  cat("   The pd-level model is more stable while maintaining high correlation.\n")
  cat("   Consider using it for more precise harm measurement.\n")
} else if (mean(stability_compare$pd_cv, na.rm = TRUE) < 
           mean(stability_compare$offense_cv, na.rm = TRUE)) {
  cat("   The pd-level model is more stable AND captures more variation.\n")
  cat("   RECOMMENDED for targeting applications.\n")
} else {
  cat("   Models differ meaningfully. Choice depends on use case.\n")
  cat("   PD-level: More granular, may capture within-category variation better.\n")
  cat("   Offense-level: Simpler, more interpretable, well-established.\n")
}

cat("\n")
cat(strrep("=", 70), "\n")
cat("MODEL COMPARISON COMPLETE\n")
cat(strrep("=", 70), "\n")
