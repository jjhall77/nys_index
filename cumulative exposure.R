# =============================================================================
# CUMULATIVE EXPOSURE ANALYSIS
# =============================================================================
# =============================================================================
# CUMULATIVE EXPOSURE ANALYSIS
# =============================================================================

# Create rolling windows of injury exposure
panel <- panel |>
  group_by(precinct) |>
  arrange(incident_date) |>
  mutate(
    # Rolling sum of serious injuries over past 7 days (excluding today)
    serious_past_7d = lag(n_serious, 1) + lag(n_serious, 2) + lag(n_serious, 3) +
      lag(n_serious, 4) + lag(n_serious, 5) + lag(n_serious, 6) + 
      lag(n_serious, 7),
    # Rolling sum over past 14 days
    serious_past_14d = serious_past_7d + 
      lag(n_serious, 8) + lag(n_serious, 9) + lag(n_serious, 10) +
      lag(n_serious, 11) + lag(n_serious, 12) + lag(n_serious, 13) + 
      lag(n_serious, 14),
    # Same for severe
    severe_past_7d = lag(n_severe, 1) + lag(n_severe, 2) + lag(n_severe, 3) +
      lag(n_severe, 4) + lag(n_severe, 5) + lag(n_severe, 6) + 
      lag(n_severe, 7),
    severe_past_14d = severe_past_7d +
      lag(n_severe, 8) + lag(n_severe, 9) + lag(n_severe, 10) +
      lag(n_severe, 11) + lag(n_severe, 12) + lag(n_severe, 13) + 
      lag(n_severe, 14)
  ) |>
  ungroup() |>
  replace_na(list(serious_past_7d = 0, serious_past_14d = 0, 
                  severe_past_7d = 0, severe_past_14d = 0))

# Check distribution of cumulative exposure
cat("\n===== CUMULATIVE EXPOSURE DISTRIBUTION =====\n")

cat("\n--- Serious Injuries in Past 7 Days ---\n")
panel |>
  filter(serious_past_7d > 0) |>
  count(serious_past_7d) |>
  mutate(pct = round(100 * n / sum(n), 1)) |>
  print()

cat("\n--- Severe Injuries in Past 7 Days ---\n")
panel |>
  filter(severe_past_7d > 0) |>
  count(severe_past_7d) |>
  mutate(pct = round(100 * n / sum(n), 1)) |>
  print(n = 15)

# =============================================================================
# MODEL 1: Linear cumulative exposure
# =============================================================================

cat("\n===== MODEL: CUMULATIVE SERIOUS INJURIES (7-day window) =====\n")

fml_cumul <- n_uof_clean_serious ~ serious_past_7d | precinct^year^month + dow
model_cumul <- feols(fml_cumul, data = panel, cluster = ~precinct)
summary(model_cumul)

# =============================================================================
# MODEL 2: Categorical cumulative exposure (0, 1, 2+)
# =============================================================================

cat("\n===== MODEL: CATEGORICAL CUMULATIVE EXPOSURE =====\n")

panel <- panel |>
  mutate(
    serious_7d_0 = as.integer(serious_past_7d == 0),
    serious_7d_1 = as.integer(serious_past_7d == 1),
    serious_7d_2plus = as.integer(serious_past_7d >= 2)
  )

fml_cat_cumul <- n_uof_clean_serious ~ serious_7d_1 + serious_7d_2plus | 
  precinct^year^month + dow

model_cat_cumul <- feols(fml_cat_cumul, data = panel, cluster = ~precinct)
summary(model_cat_cumul)

# =============================================================================
# MODEL 3: Recent vs less recent exposure
# =============================================================================

cat("\n===== MODEL: RECENCY OF EXPOSURE =====\n")

panel <- panel |>
  mutate(
    # Days 1-3 (recent)
    serious_1_3 = lag(n_serious, 1) + lag(n_serious, 2) + lag(n_serious, 3),
    # Days 4-7 (less recent)
    serious_4_7 = lag(n_serious, 4) + lag(n_serious, 5) + lag(n_serious, 6) + lag(n_serious, 7)
  ) |>
  replace_na(list(serious_1_3 = 0, serious_4_7 = 0))

fml_recency <- n_uof_clean_serious ~ serious_1_3 + serious_4_7 | precinct^year^month + dow
model_recency <- feols(fml_recency, data = panel, cluster = ~precinct)
summary(model_recency)

# =============================================================================
# MODEL 4: Interaction - does recent injury amplify past exposure?
# =============================================================================

cat("\n===== MODEL: INTERACTION (recent × cumulative) =====\n")

panel <- panel |>
  mutate(
    had_serious_1_3 = as.integer(serious_1_3 > 0),
    had_serious_4_7 = as.integer(serious_4_7 > 0)
  )

fml_interact <- n_uof_clean_serious ~ 
  had_serious_1_3 * had_serious_4_7 | 
  precinct^year^month + dow

model_interact <- feols(fml_interact, data = panel, cluster = ~precinct)
summary(model_interact)

# =============================================================================
# COMPARISON
# =============================================================================

cat("\n===== MODEL COMPARISON =====\n")

etable(
  model_cumul, model_cat_cumul, model_recency, model_interact,
  headers = c("Linear 7d", "Categorical", "Recency", "Interaction"),
  se.below = TRUE,
  fitstat = c("n", "r2")
)

# Effect sizes
cat("\n===== EFFECT SIZES =====\n")
baseline <- mean(panel$n_uof_clean_serious)

cat("\nLinear cumulative (7d): per injury in past week → +", 
    round(coef(model_cumul)["serious_past_7d"], 4), " UOF\n", sep = "")

cat("\nCategorical:\n")
cat("  1 serious injury in past 7d:  +", round(coef(model_cat_cumul)["serious_7d_1"], 4), "\n")
cat("  2+ serious injuries in past 7d: +", round(coef(model_cat_cumul)["serious_7d_2plus"], 4), "\n")

cat("\nRecency:\n")
cat("  Days 1-3: +", round(coef(model_recency)["serious_1_3"], 4), " per injury\n")
cat("  Days 4-7: +", round(coef(model_recency)["serious_4_7"], 4), " per injury\n")