# =============================================================================
# CHI Robustness Analysis
# =============================================================================
#
# Purpose: Test how robust block targeting is to different CHI assumptions
#
# Key comparisons:
# 1. All harm vs. Outside-only harm (street crime focus)
# 2. Low/Mid/High CHI weight ranges (citywide and borough-specific)
# 3. Different sample sizes (200, 300, 400, all)
#
# Outputs:
# - Overlap statistics between different specifications
# - Rank correlation (Spearman) between specifications
# - Practical summary: "X% of top 200 are same across specifications"
#
# =============================================================================

library(here)
library(tidyverse)
library(janitor)
library(sf)
library(lubridate)
library(scales)

# =============================================================================
# PARAMETERS
# =============================================================================

# Target sample sizes
TARGET_N <- c(200, 300, 400)

# Time window: 5 years ending 9/30/2025
END_DATE   <- as.Date("2025-09-30")
START_DATE <- END_DATE - years(5) + days(1)  # 10/1/2020

# Intersection proximity threshold (feet)
INTERSECTION_THRESHOLD <- 50

# Create output directory
dir.create(here("output"), showWarnings = FALSE)

cat("\n")
cat(strrep("=", 70), "\n")
cat("CHI ROBUSTNESS ANALYSIS\n")
cat(strrep("=", 70), "\n")
cat("Date range:", as.character(START_DATE), "to", as.character(END_DATE), "\n\n")

# =============================================================================
# PART 1: LOAD SPATIAL INFRASTRUCTURE
# =============================================================================

cat("LOADING SPATIAL INFRASTRUCTURE...\n")

physical_blocks <- st_read(here("data", "physical_blocks.gpkg"), quiet = TRUE) %>%
  st_transform(2263)
cat("  Physical blocks:", comma(nrow(physical_blocks)), "\n")

intersection_nodes <- st_read(here("data", "intersection_nodes.gpkg"), quiet = TRUE) %>%
  st_transform(2263)
cat("  Intersection nodes:", comma(nrow(intersection_nodes)), "\n")

intersection_to_blocks <- readRDS(here("data", "intersection_to_blocks.rds"))
cat("  Intersection-block mappings:", comma(nrow(intersection_to_blocks)), "\n")

nypp <- st_read(here("data", "nypp_25d"), quiet = TRUE) %>%
  st_transform(2263) %>%
  clean_names()
cat("  Precincts:", nrow(nypp), "\n")

# =============================================================================
# PART 2: DEFINE CHI WEIGHTS (FROM PART 1 ANALYSIS)
# =============================================================================

# Citywide CHI weights (mean and range from Part 1)
# Updated to match empirical results from chi_recommended_weights.csv
chi_weights <- tribble(
  ~crime_type, ~ky_cd, ~chi_low, ~chi_mid, ~chi_high,
  "Murder", 101, 5475, 5483, 7300,
  "Robbery", 105, 1004, 3144, 5475,
  "Felony Assault", 106, 1004, 1991, 5475,
  "Misd Assault", 344, 91, 178, 183,
  "Shooting", NA, 5475, 5475, 5475,
  "Shots Fired", NA, 3380, 3380, 3380
)

cat("\n=== CHI WEIGHTS ===\n")
print(chi_weights)

# =============================================================================
# PART 3: LOAD AND PREPARE CRIME DATA
# =============================================================================

cat("\nLOADING CRIME DATA...\n")

# --- Complaints ---
complaints_current <- read_csv(
  here("data", "NYPD_Complaint_Data_Current_(Year_To_Date)_20251214.csv"),
  show_col_types = FALSE
) %>%
  clean_names() %>%
  mutate(housing_psa = as.character(housing_psa))

complaints_historic <- read_csv(
  here("data", "NYPD_Complaint_Data_Historic_20251214.csv"),
  show_col_types = FALSE
) %>%
  clean_names() %>%
  mutate(housing_psa = as.character(housing_psa))

complaints <- bind_rows(complaints_historic, complaints_current) %>%
  filter(!pd_cd %in% c(111, 113, 186)) %>%  # Remove menacing
  filter(!ofns_desc == "RAPE") %>%
  filter(jurisdiction_code != 1)  # No subway

# Outside location keywords
outside_loc_keywords <- c(
  "FRONT OF", "OPPOSITE OF", "OUTSIDE", "REAR OF",
  "STREET", "IN STREET", "SIDEWALK"
)
outside_prem_keywords <- c(
  "PARK", "STREET", "PUBLIC PLACE", "HIGHWAY",
  "BRIDGE", "SIDEWALK", "VACANT LOT",
  "PUBLIC HOUSING AREA", "OUTSIDE"
)
outside_loc_pattern <- str_c(outside_loc_keywords, collapse = "|")
outside_prem_pattern <- str_c(outside_prem_keywords, collapse = "|")

# Violent crime KY codes
violent_ky <- c(101, 105, 106, 344)  # Murder, Robbery, Fel Assault, Misd Assault

# Process complaints
violent_crime_sf <- complaints %>%
  filter(!is.na(x_coord_cd), !is.na(y_coord_cd)) %>%
  mutate(
    date = mdy(rpt_dt),
    loc_of_occur_desc = str_to_upper(coalesce(loc_of_occur_desc, "")),
    prem_typ_desc = str_to_upper(coalesce(prem_typ_desc, "")),
    is_outdoor = str_detect(loc_of_occur_desc, outside_loc_pattern) |
      str_detect(prem_typ_desc, outside_prem_pattern)
  ) %>%
  filter(date >= START_DATE & date <= END_DATE) %>%
  filter(ky_cd %in% violent_ky) %>%
  st_as_sf(coords = c("x_coord_cd", "y_coord_cd"), crs = 2263, remove = FALSE)

cat("  Violent crime:", comma(nrow(violent_crime_sf)), "\n")
cat("    Outdoor:", comma(sum(violent_crime_sf$is_outdoor)), 
    "(", round(100*mean(violent_crime_sf$is_outdoor), 1), "%)\n")

rm(complaints, complaints_current, complaints_historic)

# --- Shootings ---
shootings_historic <- read_csv(
  here("data", "NYPD_Shooting_Incident_Data_(Historic)_20251230.csv"),
  show_col_types = FALSE
) %>%
  clean_names() %>%
  mutate(statistical_murder_flag = as.character(statistical_murder_flag))

shootings_current <- read_csv(
  here("data", "NYPD_Shooting_Incident_Data_(Year_To_Date)_20251215.csv"),
  show_col_types = FALSE
) %>%
  clean_names()

shootings_sf <- bind_rows(shootings_historic, shootings_current) %>%
  filter(!is.na(x_coord_cd), !is.na(y_coord_cd)) %>%
  mutate(date = mdy(occur_date)) %>%
  filter(date >= START_DATE & date <= END_DATE) %>%
  st_as_sf(coords = c("x_coord_cd", "y_coord_cd"), crs = 2263, remove = FALSE)

cat("  Shootings:", comma(nrow(shootings_sf)), "\n")

rm(shootings_historic, shootings_current)

# --- Shots Fired ---
sf_2017 <- read_csv(here("data", "sf_since_2017.csv"), show_col_types = FALSE) %>%
  clean_names()

sf_new <- read_csv(here("data", "shots_fired_new.csv"), show_col_types = FALSE) %>%
  clean_names()

cutoff_date <- min(mdy(sf_new$rec_create_dt), na.rm = TRUE)

sf_2017_std <- sf_2017 %>%
  mutate(date = mdy(rpt_dt)) %>%
  filter(date < cutoff_date) %>%
  transmute(
    cmplnt_key, date = as.Date(date),
    x = as.numeric(x_coord_cd), y = as.numeric(y_coord_cd)
  )

sf_new_std <- sf_new %>%
  mutate(date = mdy(rec_create_dt)) %>%
  filter(date >= cutoff_date) %>%
  transmute(
    cmplnt_key, date = as.Date(date),
    x = as.numeric(x_coordinate_code), y = as.numeric(y_coordinate_code)
  )

shots_fired_sf <- bind_rows(sf_2017_std, sf_new_std) %>%
  filter(!is.na(x), !is.na(y)) %>%
  distinct(cmplnt_key, .keep_all = TRUE) %>%
  filter(date >= START_DATE & date <= END_DATE) %>%
  st_as_sf(coords = c("x", "y"), crs = 2263, remove = FALSE)

cat("  Shots fired:", comma(nrow(shots_fired_sf)), "\n")

rm(sf_2017, sf_new, sf_2017_std, sf_new_std, cutoff_date)

# =============================================================================
# PART 4: ALLOCATION FUNCTION
# =============================================================================

allocate_crimes_to_blocks <- function(crime_sf, 
                                      physical_blocks,
                                      intersection_nodes,
                                      intersection_to_blocks,
                                      threshold = INTERSECTION_THRESHOLD,
                                      verbose = FALSE) {
  n_crimes <- nrow(crime_sf)
  if (n_crimes == 0) {
    return(tibble(block_id = integer(), crime_count = numeric()))
  }
  
  # Find nearest intersection and block for each crime
  nearest_node_idx <- st_nearest_feature(crime_sf, intersection_nodes)
  nearest_node_id <- intersection_nodes$nodeid[nearest_node_idx]
  
  dist_to_intersection <- as.numeric(
    st_distance(crime_sf, intersection_nodes[nearest_node_idx, ], by_element = TRUE)
  )
  
  nearest_block_idx <- st_nearest_feature(crime_sf, physical_blocks)
  nearest_block_id <- physical_blocks$physical_id[nearest_block_idx]
  
  crime_allocation <- tibble(
    crime_idx = 1:n_crimes,
    nearest_node_id = nearest_node_id,
    dist_to_intersection = dist_to_intersection,
    nearest_block_id = nearest_block_id,
    is_at_intersection = dist_to_intersection <= threshold
  )
  
  # Intersection crimes: split across adjacent blocks
  intersection_crimes <- crime_allocation %>% filter(is_at_intersection)
  
  if (nrow(intersection_crimes) > 0) {
    intersection_split <- intersection_crimes %>%
      left_join(
        intersection_to_blocks %>% select(node_id, adjacent_blocks),
        by = c("nearest_node_id" = "node_id")
      ) %>%
      unnest(adjacent_blocks) %>%
      rename(block_id = adjacent_blocks) %>%
      group_by(crime_idx) %>%
      mutate(weight = 1 / n()) %>%
      ungroup() %>%
      group_by(block_id) %>%
      summarise(crime_count = sum(weight), .groups = "drop")
  } else {
    intersection_split <- tibble(block_id = integer(), crime_count = numeric())
  }
  
  # Non-intersection crimes: assign to nearest block
  non_intersection_crimes <- crime_allocation %>%
    filter(!is_at_intersection) %>%
    count(nearest_block_id, name = "crime_count") %>%
    rename(block_id = nearest_block_id)
  
  # Combine
  total_counts <- bind_rows(intersection_split, non_intersection_crimes) %>%
    group_by(block_id) %>%
    summarise(crime_count = sum(crime_count), .groups = "drop")
  
  if (verbose) {
    n_at_int <- sum(crime_allocation$is_at_intersection)
    cat("    At intersections:", n_at_int, "(", round(100*n_at_int/n_crimes, 1), "%)\n")
  }
  
  total_counts
}

# =============================================================================
# PART 5: BUILD BASE BLOCK MATRIX
# =============================================================================

cat("\nBUILDING BLOCK-LEVEL CRIME MATRIX...\n")

# Initialize matrix
block_matrix <- physical_blocks %>%
  st_drop_geometry() %>%
  select(physical_id, boro) %>%
  rename(block_id = physical_id) %>%
  mutate(
    borough = case_when(
      boro == 1 ~ "Manhattan",
      boro == 2 ~ "Bronx",
      boro == 3 ~ "Brooklyn",
      boro == 4 ~ "Queens",
      boro == 5 ~ "Staten Island",
      TRUE ~ NA_character_
    )
  )

# --- Allocate Shootings ---
cat("  Processing shootings...\n")
shooting_counts <- allocate_crimes_to_blocks(
  shootings_sf, physical_blocks, intersection_nodes, intersection_to_blocks, verbose = TRUE
) %>%
  rename(shootings = crime_count)

block_matrix <- block_matrix %>%
  left_join(shooting_counts, by = "block_id")

# --- Allocate Shots Fired ---
cat("  Processing shots fired...\n")
shots_counts <- allocate_crimes_to_blocks(
  shots_fired_sf, physical_blocks, intersection_nodes, intersection_to_blocks, verbose = TRUE
) %>%
  rename(shots_fired = crime_count)

block_matrix <- block_matrix %>%
  left_join(shots_counts, by = "block_id")

# --- Allocate Violent Crime by Type ---
for (crime_type in c("Murder", "Robbery", "Felony Assault", "Misd Assault")) {
  ky <- chi_weights$ky_cd[chi_weights$crime_type == crime_type]
  crime_subset <- violent_crime_sf %>% filter(ky_cd == ky)
  
  cat("  Processing", crime_type, "(n =", comma(nrow(crime_subset)), ")...\n")
  
  # All
  counts_all <- allocate_crimes_to_blocks(
    crime_subset, physical_blocks, intersection_nodes, intersection_to_blocks
  ) %>%
    rename(!!paste0(tolower(gsub(" ", "_", crime_type)), "_all") := crime_count)
  
  # Outdoor only
  counts_outdoor <- allocate_crimes_to_blocks(
    crime_subset %>% filter(is_outdoor),
    physical_blocks, intersection_nodes, intersection_to_blocks
  ) %>%
    rename(!!paste0(tolower(gsub(" ", "_", crime_type)), "_outdoor") := crime_count)
  
  block_matrix <- block_matrix %>%
    left_join(counts_all, by = "block_id") %>%
    left_join(counts_outdoor, by = "block_id")
}

# Replace NAs with 0
block_matrix <- block_matrix %>%
  mutate(across(where(is.numeric), ~replace_na(., 0)))

cat("  Block matrix complete:", comma(nrow(block_matrix)), "blocks\n")

# =============================================================================
# PART 6: CALCULATE CHI SCORES UNDER DIFFERENT SPECIFICATIONS
# =============================================================================

cat("\nCALCULATING CHI SCORES UNDER DIFFERENT SPECIFICATIONS...\n")

# --- BASELINE: All harm, mid weights ---
block_matrix <- block_matrix %>%
  mutate(
    chi_all_mid = 
      murder_all * 5086 +
      robbery_all * 3081 +
      felony_assault_all * 1991 +
      misd_assault_all * 231 +
      shootings * 5475 +
      shots_fired * 3380
  )

# --- OUTDOOR: Outdoor harm only, mid weights ---
block_matrix <- block_matrix %>%
  mutate(
    chi_outdoor_mid = 
      murder_outdoor * 5086 +
      robbery_outdoor * 3081 +
      felony_assault_outdoor * 1991 +
      misd_assault_outdoor * 231 +
      shootings * 5475 +
      shots_fired * 3380
  )

# --- EXTREME LOW: All harm, 2.5th percentile weights ---
block_matrix <- block_matrix %>%
  mutate(
    chi_all_extreme_low = 
      murder_all * 1000 +
      robbery_all * 1004 +
      felony_assault_all * 183 +
      misd_assault_all * 91 +
      shootings * 5475 +
      shots_fired * 3380
  )

# --- EXTREME HIGH: All harm, 97.5th percentile weights ---
block_matrix <- block_matrix %>%
  mutate(
    chi_all_extreme_high = 
      murder_all * 7300 +
      robbery_all * 5475 +
      felony_assault_all * 5475 +
      misd_assault_all * 1643 +
      shootings * 5475 +
      shots_fired * 3380
  )

# --- CONSERVATIVE LOW: All harm, -10% from mid weights ---
block_matrix <- block_matrix %>%
  mutate(
    chi_all_low_10pct = 
      murder_all * (5086 * 0.9) +
      robbery_all * (3081 * 0.9) +
      felony_assault_all * (1991 * 0.9) +
      misd_assault_all * (231 * 0.9) +
      shootings * 5475 +
      shots_fired * 3380
  )

# --- CONSERVATIVE HIGH: All harm, +10% from mid weights ---
block_matrix <- block_matrix %>%
  mutate(
    chi_all_high_10pct = 
      murder_all * (5086 * 1.1) +
      robbery_all * (3081 * 1.1) +
      felony_assault_all * (1991 * 1.1) +
      misd_assault_all * (231 * 1.1) +
      shootings * 5475 +
      shots_fired * 3380
  )

# --- FELONY ONLY: Exclude Misd Assault, mid weights ---
block_matrix <- block_matrix %>%
  mutate(
    chi_felony_only_mid = 
      murder_all * 5086 +
      robbery_all * 3081 +
      felony_assault_all * 1991 +
      # NO misd_assault
      shootings * 5475 +
      shots_fired * 3380
  )

# --- FELONY ONLY OUTDOOR: Exclude Misd Assault, outdoor, mid weights ---
block_matrix <- block_matrix %>%
  mutate(
    chi_felony_outdoor_mid = 
      murder_outdoor * 5086 +
      robbery_outdoor * 3081 +
      felony_assault_outdoor * 1991 +
      # NO misd_assault
      shootings * 5475 +
      shots_fired * 3380
  )

# --- FELONY ONLY EXTREME LOW ---
block_matrix <- block_matrix %>%
  mutate(
    chi_felony_extreme_low = 
      murder_all * 1000 +
      robbery_all * 1004 +
      felony_assault_all * 183 +
      shootings * 5475 +
      shots_fired * 3380
  )

# --- FELONY ONLY EXTREME HIGH ---
block_matrix <- block_matrix %>%
  mutate(
    chi_felony_extreme_high = 
      murder_all * 7300 +
      robbery_all * 5475 +
      felony_assault_all * 5475 +
      shootings * 5475 +
      shots_fired * 3380
  )

# --- GUN VIOLENCE ONLY ---
block_matrix <- block_matrix %>%
  mutate(
    chi_gun_only = shootings * 5475 + shots_fired * 3380
  )

# --- COUNT-BASED (unweighted) ---
block_matrix <- block_matrix %>%
  mutate(
    count_all = murder_all + robbery_all + felony_assault_all + misd_assault_all +
      shootings + shots_fired,
    count_felony = murder_all + robbery_all + felony_assault_all + 
      shootings + shots_fired,
    count_outdoor = murder_outdoor + robbery_outdoor + felony_assault_outdoor + 
      misd_assault_outdoor + shootings + shots_fired,
    count_felony_outdoor = murder_outdoor + robbery_outdoor + felony_assault_outdoor +
      shootings + shots_fired
  )

# List of all specifications
spec_names <- c(
  # Full CHI (all crime types)
  "chi_all_mid", "chi_outdoor_mid",
  "chi_all_extreme_low", "chi_all_extreme_high",
  "chi_all_low_10pct", "chi_all_high_10pct",
  # Felony-only CHI (no misd assault)
  "chi_felony_only_mid", "chi_felony_outdoor_mid",
  "chi_felony_extreme_low", "chi_felony_extreme_high",
  # Gun violence only
  "chi_gun_only",
  # Count-based
  "count_all", "count_felony", "count_outdoor", "count_felony_outdoor"
)

# =============================================================================
# PART 7: RANK BLOCKS UNDER EACH SPECIFICATION
# =============================================================================

cat("\nRANKING BLOCKS UNDER EACH SPECIFICATION...\n")

# Create ranks for each specification
for (spec in spec_names) {
  rank_col <- paste0("rank_", spec)
  block_matrix <- block_matrix %>%
    mutate(!!rank_col := rank(-get(spec), ties.method = "first"))
}

# =============================================================================
# PART 8: OVERLAP ANALYSIS
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("ROBUSTNESS ANALYSIS RESULTS\n")
cat(strrep("=", 70), "\n")

# Function to calculate overlap between two specifications
calc_overlap <- function(data, spec1, spec2, n) {
  rank1 <- paste0("rank_", spec1)
  rank2 <- paste0("rank_", spec2)
  
  top_n_1 <- data %>% filter(get(rank1) <= n) %>% pull(block_id)
  top_n_2 <- data %>% filter(get(rank2) <= n) %>% pull(block_id)
  
  overlap <- length(intersect(top_n_1, top_n_2))
  pct_overlap <- 100 * overlap / n
  
  tibble(
    spec1 = spec1,
    spec2 = spec2,
    n = n,
    overlap = overlap,
    pct_overlap = pct_overlap
  )
}

# Calculate all pairwise overlaps
overlap_results <- expand_grid(
  spec1 = spec_names,
  spec2 = spec_names,
  n = c(TARGET_N, nrow(block_matrix))
) %>%
  filter(spec1 < spec2) %>%  # Avoid duplicates
  pmap_dfr(function(spec1, spec2, n) calc_overlap(block_matrix, spec1, spec2, n))

# =============================================================================
# PART 9: RANK CORRELATION ANALYSIS
# =============================================================================

cat("\n=== RANK CORRELATIONS (Spearman) ===\n")

# Calculate Spearman correlations between rank columns
rank_cols <- paste0("rank_", spec_names)
rank_data <- block_matrix %>% select(all_of(rank_cols))

# Rename for cleaner output
names(rank_data) <- spec_names

cor_matrix <- cor(rank_data, method = "spearman")
print(round(cor_matrix, 3))

# =============================================================================
# PART 10: SUMMARY TABLES
# =============================================================================

cat("\n=== OVERLAP SUMMARY: KEY COMPARISONS ===\n\n")

# Main comparisons
key_comparisons <- tribble(
  ~comparison, ~spec1, ~spec2,
  # Location comparisons
  "All vs Outdoor (mid weights)", "chi_all_mid", "chi_outdoor_mid",
  "Felony: All vs Outdoor", "chi_felony_only_mid", "chi_felony_outdoor_mid",
  
  # Weight variation - EXTREME
  "Extreme Low vs Mid (all)", "chi_all_extreme_low", "chi_all_mid",
  "Extreme High vs Mid (all)", "chi_all_extreme_high", "chi_all_mid",
  "Extreme Low vs High (all)", "chi_all_extreme_high", "chi_all_extreme_low",
  
  # Weight variation - CONSERVATIVE (±10%)
  "±10%: Low vs Mid", "chi_all_low_10pct", "chi_all_mid",
  "±10%: High vs Mid", "chi_all_high_10pct", "chi_all_mid",
  "±10%: Low vs High", "chi_all_high_10pct", "chi_all_low_10pct",
  
  # With vs without Misd Assault
  "Full vs Felony-only (mid)", "chi_all_mid", "chi_felony_only_mid",
  "Full vs Felony-only (outdoor)", "chi_outdoor_mid", "chi_felony_outdoor_mid",
  
  # Felony-only weight variation
  "Felony: Extreme Low vs Mid", "chi_felony_extreme_low", "chi_felony_only_mid",
  "Felony: Extreme High vs Mid", "chi_felony_extreme_high", "chi_felony_only_mid",
  
  # Gun-only comparisons
  "Gun-only vs Full CHI", "chi_all_mid", "chi_gun_only",
  "Gun-only vs Felony CHI", "chi_felony_only_mid", "chi_gun_only",
  
  # CHI vs Count-based
  "CHI vs Count (all)", "chi_all_mid", "count_all",
  "CHI vs Count (felony)", "chi_felony_only_mid", "count_felony"
)

key_results <- key_comparisons %>%
  left_join(
    overlap_results %>% filter(n %in% TARGET_N),
    by = c("spec1", "spec2")
  ) %>%
  select(comparison, n, overlap, pct_overlap) %>%
  pivot_wider(
    names_from = n,
    values_from = c(overlap, pct_overlap),
    names_glue = "{.value}_{n}"
  )

print(key_results, width = Inf)

# =============================================================================
# PART 11: PRACTICAL SUMMARY
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("PRACTICAL INTERPRETATION\n")
cat(strrep("=", 70), "\n\n")

for (n in TARGET_N) {
  cat(sprintf("TOP %d BLOCKS:\n", n))
  cat(strrep("-", 50), "\n")
  
  # Helper function to safely get overlap
  get_ov <- function(s1, s2) {
    # Try both orderings since we filtered spec1 < spec2
    ov <- overlap_results %>%
      filter((spec1 == s1 & spec2 == s2) | (spec1 == s2 & spec2 == s1), n == !!n)
    if (nrow(ov) == 0) return(list(overlap = NA, pct_overlap = NA))
    return(ov)
  }
  
  cat("\n  LOCATION (All vs Outdoor):\n")
  ov <- get_ov("chi_all_mid", "chi_outdoor_mid")
  cat(sprintf("    Full CHI: %d same (%.1f%%)\n", ov$overlap, ov$pct_overlap))
  ov <- get_ov("chi_felony_only_mid", "chi_felony_outdoor_mid")
  cat(sprintf("    Felony-only: %d same (%.1f%%)\n", ov$overlap, ov$pct_overlap))
  
  cat("\n  WEIGHT VARIATION - Conservative (±10%):\n")
  ov <- get_ov("chi_all_low_10pct", "chi_all_mid")
  cat(sprintf("    -10%% vs Mid: %d same (%.1f%%)\n", ov$overlap, ov$pct_overlap))
  ov <- get_ov("chi_all_high_10pct", "chi_all_mid")
  cat(sprintf("    +10%% vs Mid: %d same (%.1f%%)\n", ov$overlap, ov$pct_overlap))
  ov <- get_ov("chi_all_high_10pct", "chi_all_low_10pct")
  cat(sprintf("    -10%% vs +10%%: %d same (%.1f%%)\n", ov$overlap, ov$pct_overlap))
  
  cat("\n  WEIGHT VARIATION - Extreme (2.5th vs 97.5th %ile):\n")
  ov <- get_ov("chi_all_extreme_low", "chi_all_mid")
  cat(sprintf("    Extreme Low vs Mid: %d same (%.1f%%)\n", ov$overlap, ov$pct_overlap))
  ov <- get_ov("chi_all_extreme_high", "chi_all_mid")
  cat(sprintf("    Extreme High vs Mid: %d same (%.1f%%)\n", ov$overlap, ov$pct_overlap))
  ov <- get_ov("chi_all_extreme_high", "chi_all_extreme_low")
  cat(sprintf("    Extreme Low vs High: %d same (%.1f%%)\n", ov$overlap, ov$pct_overlap))
  
  cat("\n  WITH vs WITHOUT MISD ASSAULT:\n")
  ov <- get_ov("chi_all_mid", "chi_felony_only_mid")
  cat(sprintf("    Full vs Felony-only (all): %d same (%.1f%%)\n", ov$overlap, ov$pct_overlap))
  ov <- get_ov("chi_outdoor_mid", "chi_felony_outdoor_mid")
  cat(sprintf("    Full vs Felony-only (outdoor): %d same (%.1f%%)\n", ov$overlap, ov$pct_overlap))
  
  cat("\n  GUN VIOLENCE FOCUS:\n")
  ov <- get_ov("chi_all_mid", "chi_gun_only")
  cat(sprintf("    Gun-only vs Full CHI: %d same (%.1f%%)\n", ov$overlap, ov$pct_overlap))
  ov <- get_ov("chi_felony_only_mid", "chi_gun_only")
  cat(sprintf("    Gun-only vs Felony CHI: %d same (%.1f%%)\n", ov$overlap, ov$pct_overlap))
  
  cat("\n  CHI vs SIMPLE COUNTS:\n")
  ov <- get_ov("chi_all_mid", "count_all")
  cat(sprintf("    CHI vs Count (all crimes): %d same (%.1f%%)\n", ov$overlap, ov$pct_overlap))
  ov <- get_ov("chi_felony_only_mid", "count_felony")
  cat(sprintf("    CHI vs Count (felonies): %d same (%.1f%%)\n", ov$overlap, ov$pct_overlap))
  
  cat("\n")
}

# =============================================================================
# PART 12: ADDITIONAL ROBUSTNESS CHECKS
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("ADDITIONAL ROBUSTNESS CHECKS\n")
cat(strrep("=", 70), "\n")

# Check 1: Distribution of rank changes
cat("\n=== RANK STABILITY ===\n")
cat("(How much do ranks change across specifications?)\n")
cat("(Excluding benchmark specs: gun-only and count-based)\n\n")

# Define which specs are "real" alternatives vs benchmarks
chi_specs_only <- c(
  
  "rank_chi_all_mid", "rank_chi_outdoor_mid",
  "rank_chi_all_extreme_low", "rank_chi_all_extreme_high",
  "rank_chi_all_low_10pct", "rank_chi_all_high_10pct",
  "rank_chi_felony_only_mid", "rank_chi_felony_outdoor_mid",
  "rank_chi_felony_extreme_low", "rank_chi_felony_extreme_high"
)

rank_stability <- block_matrix %>%
  select(block_id, all_of(chi_specs_only)) %>%
  pivot_longer(
    cols = starts_with("rank_"),
    names_to = "spec",
    values_to = "rank"
  ) %>%
  group_by(block_id) %>%
  summarise(
    mean_rank = mean(rank),
    sd_rank = sd(rank),
    min_rank = min(rank),
    max_rank = max(rank),
    rank_range = max_rank - min_rank,
    .groups = "drop"
  )

# For top blocks (by mid-weight all-harm)
top_500_ids <- block_matrix %>%
  filter(rank_chi_all_mid <= 500) %>%
  pull(block_id)

top_stability <- rank_stability %>%
  filter(block_id %in% top_500_ids) %>%
  summarise(
    mean_rank_sd = mean(sd_rank),
    median_rank_range = median(rank_range),
    pct_range_under_50 = 100 * mean(rank_range < 50),
    pct_range_under_100 = 100 * mean(rank_range < 100)
  )

cat("Among top 500 blocks (by chi_all_mid):\n")
cat(sprintf("  Mean rank SD across specifications: %.1f\n", top_stability$mean_rank_sd))
cat(sprintf("  Median rank range (min to max): %.0f\n", top_stability$median_rank_range))
cat(sprintf("  %% with rank range < 50: %.1f%%\n", top_stability$pct_range_under_50))
cat(sprintf("  %% with rank range < 100: %.1f%%\n", top_stability$pct_range_under_100))

# Check 2: Extreme blocks (always in top N or never in top N)
cat("\n=== CONSISTENTLY HIGH-HARM BLOCKS ===\n")
cat("(Blocks in top N across ALL CHI specifications, excluding benchmarks)\n\n")

for (n in TARGET_N) {
  consistent <- block_matrix %>%
    filter(
      rank_chi_all_mid <= n &
        rank_chi_outdoor_mid <= n &
        rank_chi_all_extreme_low <= n &
        rank_chi_all_extreme_high <= n &
        rank_chi_all_low_10pct <= n &
        rank_chi_all_high_10pct <= n &
        rank_chi_felony_only_mid <= n &
        rank_chi_felony_outdoor_mid <= n &
        rank_chi_felony_extreme_low <= n &
        rank_chi_felony_extreme_high <= n
    )
  
  cat(sprintf("  Top %d under all specs: %d blocks (%.1f%% of %d)\n",
              n, nrow(consistent), 100*nrow(consistent)/n, n))
}

# Check 3: Blocks that move dramatically
cat("\n=== SENSITIVE BLOCKS ===\n")
cat("(Blocks whose rank changes dramatically across specs)\n\n")

sensitive_blocks <- rank_stability %>%
  filter(mean_rank <= 1000) %>%  # Focus on relatively high-harm blocks
  arrange(desc(rank_range)) %>%
  head(20)

cat("Top 20 most rank-variable blocks (among those with mean rank ≤ 1000):\n")
print(sensitive_blocks %>% select(block_id, mean_rank, rank_range, min_rank, max_rank))

# =============================================================================
# PART 13: EXPORT RESULTS
# =============================================================================

cat("\n=== EXPORTING RESULTS ===\n")

write_csv(block_matrix, here("output", "chi_robustness_block_matrix.csv"))
write_csv(overlap_results, here("output", "chi_robustness_overlap.csv"))
write_csv(rank_stability, here("output", "chi_robustness_rank_stability.csv"))

# Correlation matrix
cor_df <- as.data.frame(cor_matrix) %>%
  rownames_to_column("spec")
write_csv(cor_df, here("output", "chi_robustness_correlations.csv"))

cat("  Saved: chi_robustness_block_matrix.csv\n")
cat("  Saved: chi_robustness_overlap.csv\n")
cat("  Saved: chi_robustness_rank_stability.csv\n")
cat("  Saved: chi_robustness_correlations.csv\n")

# =============================================================================
# PART 14: VISUALIZATION
# =============================================================================

cat("\n=== CREATING PLOTS ===\n")

# Base theme
theme_pub <- function() {
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      axis.line = element_line(color = "black", linewidth = 0.3),
      plot.title = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(size = 10, color = "gray40")
    )
}

# Plot 1: Correlation heatmap
cor_long <- cor_df %>%
  pivot_longer(-spec, names_to = "spec2", values_to = "correlation")

p1 <- ggplot(cor_long, aes(x = spec, y = spec2, fill = correlation)) +
  geom_tile(color = "white") +
  geom_text(aes(label = round(correlation, 2)), size = 2.5) +
  scale_fill_gradient2(low = "red", mid = "white", high = "darkgreen", midpoint = 0.9) +
  labs(
    title = "Rank Correlation Matrix Across CHI Specifications",
    subtitle = "Spearman correlations between block rankings",
    x = NULL, y = NULL
  ) +
  theme_pub() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
    axis.text.y = element_text(size = 8),
    legend.position = "right"
  )
p1

ggsave(here("output", "fig_chi_robustness_correlations.png"), p1,
       width = 10, height = 8, dpi = 300, bg = "white")

# Plot 2: Overlap by sample size - key comparisons
overlap_plot_data <- key_comparisons %>%
  left_join(
    overlap_results,
    by = c("spec1", "spec2")
  ) %>%
  filter(n %in% TARGET_N) %>%
  # Group comparisons for cleaner plotting
  mutate(
    category = case_when(
      str_detect(comparison, "All vs Outdoor|Felony: All vs Outdoor") ~ "Location",
      str_detect(comparison, "±10%") ~ "Conservative (±10%)",
      str_detect(comparison, "Extreme") ~ "Extreme Weights",
      str_detect(comparison, "Felony-only|Full vs Felony") ~ "With/Without Misd Assault",
      str_detect(comparison, "Gun-only") ~ "Gun Violence Focus",
      str_detect(comparison, "Count") ~ "CHI vs Counts",
      TRUE ~ "Other"
    )
  )

# Create separate plots for each category
plot_overlap_category <- function(data, cat_name, n_val) {
  plot_data <- data %>% 
    filter(category == cat_name, n == n_val)
  
  if (nrow(plot_data) == 0) return(NULL)
  
  ggplot(plot_data, aes(x = reorder(comparison, pct_overlap), y = pct_overlap)) +
    geom_col(fill = "gray40", width = 0.7) +
    geom_text(aes(label = paste0(round(pct_overlap), "%")), hjust = -0.2, size = 3) +
    coord_flip() +
    scale_y_continuous(limits = c(0, 105), expand = c(0, 0)) +
    labs(
      title = paste0(cat_name, " (N = ", n_val, ")"),
      x = NULL,
      y = "Overlap (%)"
    ) +
    theme_pub()
}

# Main overlap plot - simplified version for key comparisons
key_overlap <- overlap_plot_data %>%
  filter(comparison %in% c(
    "All vs Outdoor (mid weights)",
    "±10%: Low vs High",
    "Extreme Low vs High (all)",
    "Full vs Felony-only (mid)",
    "Gun-only vs Full CHI",
    "CHI vs Count (all)"
  )) %>%
  mutate(comparison = str_replace(comparison, " \\(mid weights\\)", "")) %>%
  mutate(comparison = str_replace(comparison, " \\(all\\)", "")) %>%
  mutate(comparison = str_replace(comparison, " \\(mid\\)", ""))

p2 <- ggplot(key_overlap %>% filter(n %in% TARGET_N), 
             aes(x = factor(n), y = pct_overlap, fill = comparison)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_text(aes(label = paste0(round(pct_overlap), "%")), 
            position = position_dodge(width = 0.8), vjust = -0.5, size = 2.5) +
  scale_fill_brewer(palette = "Set2") +
  scale_y_continuous(limits = c(0, 105), expand = c(0, 0)) +
  labs(
    title = "Block Overlap Across CHI Specifications",
    subtitle = "Percentage of top N blocks that are the same under different assumptions",
    x = "Number of Top Blocks (N)",
    y = "Overlap (%)",
    fill = "Comparison"
  ) +
  theme_pub() +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 8))
p2

ggsave(here("output", "fig_chi_robustness_overlap.png"), p2,
       width = 8, height = 6, dpi = 300, bg = "white")

# Plot 3: Rank stability histogram
p3 <- ggplot(rank_stability %>% filter(mean_rank <= 2000), 
             aes(x = rank_range)) +
  geom_histogram(bins = 50, fill = "gray40", color = "white") +
  geom_vline(xintercept = 50, linetype = "dashed", color = "red") +
  geom_vline(xintercept = 100, linetype = "dashed", color = "orange") +
  labs(
    title = "Distribution of Rank Variability Across Specifications",
    subtitle = "Among blocks with mean rank ≤ 2000",
    x = "Rank Range (max rank - min rank)",
    y = "Number of Blocks",
    caption = "Dashed lines at 50 and 100 rank difference"
  ) +
  theme_pub()
p3

ggsave(here("output", "fig_chi_robustness_rank_stability.png"), p3,
       width = 8, height = 5, dpi = 300, bg = "white")

cat("  Saved: fig_chi_robustness_correlations.png\n")
cat("  Saved: fig_chi_robustness_overlap.png\n")
cat("  Saved: fig_chi_robustness_rank_stability.png\n")

cat("\n")
cat(strrep("=", 70), "\n")
cat("ROBUSTNESS ANALYSIS COMPLETE\n")
cat(strrep("=", 70), "\n")