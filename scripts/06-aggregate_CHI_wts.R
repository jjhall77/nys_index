# =============================================================================
# 06 - Assign Crime Harm Index Weights
# =============================================================================
#
# Portable functions to deduplicate, score, and aggregate crime harm.
#
# Usage:
#   source("06_assign_chi.R")
#
#   # Step 1: Deduplicate shooting/complaint overlap on raw coordinates
#   unified <- deduplicate_gun_violence(complaints, shootings, shots_fired,
#                                        dist_ft = 500, hours = 12)
#
#   # Step 2: Score complaint records via pd_key
#   scored <- assign_chi(unified, chi_pd_key)
#
#   # Step 3: Aggregate to any spatial unit already in your data
#   block_harm    <- aggregate_chi(scored, unit = "block_id")
#   precinct_harm <- aggregate_chi(scored, unit = "precinct")
#
# Functions:
#
#   deduplicate_gun_violence()
#     Matches shooting victims to their corresponding complaints using
#     spatiotemporal proximity on RAW coordinates (before any block
#     assignment). Removes matched complaints. Returns a single stacked
#     table of deduplicated events.
#
#   assign_chi()
#     Joins chi_pd_key to crime records on offense_description1 × pd_description.
#     Shooting and shots fired rows already have chi_weight from deduplication.
#
#   aggregate_chi()
#     Groups scored data by any column(s) and returns harm totals.
#
# Dependencies: dplyr, stringr, lubridate
# =============================================================================

library(dplyr)
library(stringr)
library(lubridate)


# =============================================================================
# deduplicate_gun_violence
# =============================================================================
#
# Matches shooting victims to complaint records using spatiotemporal proximity
# on raw XY coordinates. No block IDs, no grid snapping — the match happens
# in continuous coordinate space so boundary artifacts can't arise.
#
# Matching rules:
#   Fatal shooting     → nearest MURDER complaint within dist_ft AND hours
#   Non-fatal shooting → nearest FELONY ASSAULT complaint within dist_ft AND hours
#
# Each shooting matches at most one complaint (nearest in space, breaking
# ties by closest in time). Each complaint matches at most one shooting
# (first-come-first-served by spatial proximity). This prevents a single
# complaint from absorbing multiple shootings or vice versa.
#
# Returns a single stacked tibble with columns:
#   source:     "complaint" | "shooting" | "shots_fired"
#   chi_weight: filled for shooting/shots_fired; NA for complaints
#               (complaints get scored downstream by assign_chi)
#   matched:    TRUE for shooting victims that matched a complaint
#   All original columns preserved.
#
# The match log is attached as attr(result, "match_log") for audit.
#
# Arguments:
#   complaints   — NYPD complaint data with x_coord_cd, y_coord_cd, datetime
#   shootings    — shooting victim data with coordinates and is_fatal
#   shots_fired  — shots fired data (passed through unchanged, optional)
#   dist_ft      — max distance in feet (State Plane) for a match
#   hours        — max time gap in hours for a match
#   chi_fatal    — CHI for fatal shooting victims (default 7300)
#   chi_nonfatal — CHI for non-fatal shooting victims (default 5475)
#   chi_sf       — CHI for shots fired incidents (default 3376)
#
# =============================================================================

deduplicate_gun_violence <- function(complaints,
                                     shootings,
                                     shots_fired  = NULL,
                                     dist_ft      = 500,
                                     hours        = 12,
                                     chi_fatal    = 7300L,
                                     chi_nonfatal = 5475L,
                                     chi_sf       = 3376L) {
  
  # --- Field name harmonization ---
  if ("ofns_desc" %in% names(complaints) & !"offense_description1" %in% names(complaints)) {
    complaints <- rename(complaints,
                         offense_description1 = ofns_desc,
                         pd_description       = pd_desc)
  }
  
  # --- Parse complaint datetime ---
  if (!"complaint_datetime" %in% names(complaints)) {
    if ("cmplnt_fr_tm" %in% names(complaints)) {
      complaints <- complaints %>%
        mutate(
          complaint_datetime = parse_date_time(
            paste(cmplnt_fr_dt, cmplnt_fr_tm),
            orders = c("mdy HM", "mdy HMS", "ymd HM", "ymd HMS"),
            quiet = TRUE
          )
        )
    } else {
      complaints <- complaints %>%
        mutate(
          complaint_datetime = parse_date_time(
            cmplnt_fr_dt,
            orders = c("mdy", "ymd"),
            quiet = TRUE
          ) + hours(12)
        )
    }
  }
  
  # --- Parse shooting datetime ---
  if (!"shooting_datetime" %in% names(shootings)) {
    if ("occur_time" %in% names(shootings)) {
      shootings <- shootings %>%
        mutate(
          shooting_datetime = parse_date_time(
            paste(occur_date, occur_time),
            orders = c("mdy HM", "mdy HMS", "ymd HM", "ymd HMS"),
            quiet = TRUE
          )
        )
    } else {
      shootings <- shootings %>%
        mutate(
          shooting_datetime = parse_date_time(
            occur_date,
            orders = c("mdy", "ymd"),
            quiet = TRUE
          ) + hours(12)
        )
    }
  }
  
  # --- Harmonize shooting coordinate field names ---
  coord_x <- c("x_coord_cd", "x_coordinate", "x_coord", "x_coordinate_code")
  coord_y <- c("y_coord_cd", "y_coordinate", "y_coord", "y_coordinate_code")
  
  sx <- intersect(names(shootings), coord_x)
  sy <- intersect(names(shootings), coord_y)
  
  if (length(sx) > 0 & !"x_coord_cd" %in% names(shootings)) {
    shootings <- rename(shootings, x_coord_cd = !!sx[1])
  }
  if (length(sy) > 0 & !"y_coord_cd" %in% names(shootings)) {
    shootings <- rename(shootings, y_coord_cd = !!sy[1])
  }
  
  # --- Separate matchable vs non-matchable complaints ---
  murder_label <- "MURDER & NON-NEGL. MANSLAUGHTE"
  fa_label     <- "FELONY ASSAULT"
  
  matchable <- complaints %>%
    filter(
      offense_description1 %in% c(murder_label, fa_label),
      !is.na(x_coord_cd), !is.na(y_coord_cd),
      !is.na(complaint_datetime)
    ) %>%
    mutate(.crow = row_number())
  
  non_matchable <- complaints %>%
    filter(
      !(offense_description1 %in% c(murder_label, fa_label)) |
        is.na(x_coord_cd) | is.na(y_coord_cd) |
        is.na(complaint_datetime)
    )
  
  # --- Prepare shootings ---
  shootings_to_match <- shootings %>%
    filter(!is.na(x_coord_cd), !is.na(y_coord_cd), !is.na(shooting_datetime)) %>%
    mutate(
      .srow = row_number(),
      target_offense = if_else(is_fatal, murder_label, fa_label)
    )
  
  # --- Spatiotemporal matching ---
  # For each shooting, find the nearest complaint of the correct type
  # within both the distance AND time thresholds.
  #
  # Nearest in space first, break ties by time.
  # Each complaint can only be claimed once.
  
  time_threshold_secs <- hours * 3600
  matched_pairs       <- vector("list", nrow(shootings_to_match))
  claimed              <- integer(0)
  
  shootings_ordered <- shootings_to_match %>% arrange(shooting_datetime)
  
  for (i in seq_len(nrow(shootings_ordered))) {
    s <- shootings_ordered[i, ]
    
    candidates <- matchable %>%
      filter(
        offense_description1 == s$target_offense,
        !(.crow %in% claimed)
      )
    if (nrow(candidates) == 0) next
    
    # Time filter
    candidates <- candidates %>%
      mutate(.dt = abs(as.numeric(difftime(
        complaint_datetime, s$shooting_datetime, units = "secs"
      )))) %>%
      filter(.dt <= time_threshold_secs)
    if (nrow(candidates) == 0) next
    
    # Distance filter
    candidates <- candidates %>%
      mutate(.d = sqrt((x_coord_cd - s$x_coord_cd)^2 +
                         (y_coord_cd - s$y_coord_cd)^2)) %>%
      filter(.d <= dist_ft)
    if (nrow(candidates) == 0) next
    
    best <- candidates %>% arrange(.d, .dt) %>% slice(1)
    
    matched_pairs[[i]] <- tibble(
      .srow        = s$.srow,
      .crow        = best$.crow,
      dist_ft      = best$.d,
      time_gap_hrs = best$.dt / 3600
    )
    
    claimed <- c(claimed, best$.crow)
  }
  
  match_log <- bind_rows(matched_pairs)
  
  # --- Report ---
  n_fatal      <- sum(shootings_to_match$is_fatal)
  n_nonfatal   <- sum(!shootings_to_match$is_fatal)
  fatal_rows   <- shootings_ordered$.srow[shootings_ordered$is_fatal]
  n_matched_f  <- sum(match_log$.srow %in% fatal_rows)
  n_matched_nf <- nrow(match_log) - n_matched_f
  
  message(sprintf("deduplicate_gun_violence (dist <= %d ft, time <= %d hrs):",
                  dist_ft, hours))
  message(sprintf("  Fatal:     %s victims, %s matched (%.0f%%)",
                  format(n_fatal, big.mark = ","),
                  format(n_matched_f, big.mark = ","),
                  if (n_fatal > 0) 100 * n_matched_f / n_fatal else 0))
  message(sprintf("  Non-fatal: %s victims, %s matched (%.0f%%)",
                  format(n_nonfatal, big.mark = ","),
                  format(n_matched_nf, big.mark = ","),
                  if (n_nonfatal > 0) 100 * n_matched_nf / n_nonfatal else 0))
  message(sprintf("  Complaints removed: %s",
                  format(nrow(match_log), big.mark = ",")))
  if (nrow(match_log) > 0) {
    message(sprintf("  Match distance:  median %.0f ft, max %.0f ft",
                    median(match_log$dist_ft), max(match_log$dist_ft)))
    message(sprintf("  Match time gap:  median %.1f hrs, max %.1f hrs",
                    median(match_log$time_gap_hrs), max(match_log$time_gap_hrs)))
  }
  
  # --- Build unified table ---
  
  # Complaints: drop matched, keep rest
  complaints_keep <- matchable %>%
    filter(!(.crow %in% match_log$.crow)) %>%
    select(-.crow) %>%
    bind_rows(non_matchable) %>%
    mutate(source = "complaint", chi_weight = NA_integer_, matched = FALSE)
  
  # Shootings: all survive
  shootings_out <- shootings_to_match %>%
    mutate(
      source     = "shooting",
      chi_weight = if_else(is_fatal, chi_fatal, chi_nonfatal),
      matched    = .srow %in% match_log$.srow
    ) %>%
    select(-.srow, -target_offense)
  
  # Shots fired: pass through
  if (!is.null(shots_fired)) {
    sf_out <- shots_fired %>%
      mutate(
        source     = "shots_fired",
        chi_weight = as.integer(
          if ("chi_days" %in% names(.)) chi_days else chi_sf
        ),
        matched = FALSE
      )
  } else {
    sf_out <- tibble()
  }
  
  unified <- bind_rows(complaints_keep, shootings_out, sf_out)
  
  message(sprintf("  Unified table: %s rows",
                  format(nrow(unified), big.mark = ",")))
  
  attr(unified, "match_log") <- match_log
  unified
}


# =============================================================================
# assign_chi: Score complaint records via pd_key
# =============================================================================
#
# Joins chi_pd_key on offense_description1 × pd_description.
# Rows that already have chi_weight (shootings, shots fired) are untouched.
# Only fills chi_weight for source == "complaint" rows.
#
assign_chi <- function(events, chi_key) {
  
  if ("ofns_desc" %in% names(chi_key) & !"offense_description1" %in% names(chi_key)) {
    chi_key <- rename(chi_key,
                      offense_description1 = ofns_desc,
                      pd_description       = pd_desc)
  }
  
  stopifnot(
    "offense_description1" %in% names(events),
    "pd_description"       %in% names(events),
    "offense_description1" %in% names(chi_key),
    "pd_description"       %in% names(chi_key),
    "chi_weight"           %in% names(chi_key)
  )
  
  key_slim <- chi_key %>%
    select(offense_description1, pd_description, chi_weight) %>%
    distinct() %>%
    rename(chi_weight_lookup = chi_weight)
  
  out <- events %>%
    left_join(key_slim, by = c("offense_description1", "pd_description")) %>%
    mutate(chi_weight = coalesce(chi_weight, chi_weight_lookup)) %>%
    select(-chi_weight_lookup)
  
  # Report on complaints only
  cpl <- out %>% filter(source == "complaint")
  n_total   <- nrow(cpl)
  n_matched <- sum(!is.na(cpl$chi_weight))
  
  message(sprintf("assign_chi: %s / %s complaints matched (%.1f%%)",
                  format(n_matched, big.mark = ","),
                  format(n_total, big.mark = ","),
                  if (n_total > 0) 100 * n_matched / n_total else 100))
  
  if (n_matched < n_total) {
    n_miss <- n_total - n_matched
    message(sprintf("  %s unmatched", format(n_miss, big.mark = ",")))
    
    top_miss <- cpl %>%
      filter(is.na(chi_weight)) %>%
      count(offense_description1, pd_description, sort = TRUE) %>%
      head(5)
    
    message("  Top unmatched:")
    for (i in seq_len(nrow(top_miss))) {
      message(sprintf("    %s | %s  (n=%s)",
                      top_miss$offense_description1[i],
                      top_miss$pd_description[i],
                      format(top_miss$n[i], big.mark = ",")))
    }
  }
  
  out
}


# =============================================================================
# aggregate_chi: Sum harm to any areal unit
# =============================================================================
#
# Groups scored data by any column(s) and returns totals.
# Pass whatever spatial or temporal column(s) you want.
#
aggregate_chi <- function(scored_events, unit, na.rm = TRUE) {
  
  stopifnot(all(unit %in% names(scored_events)))
  
  if (na.rm) {
    scored_events <- filter(scored_events, !is.na(chi_weight))
  }
  
  scored_events %>%
    group_by(across(all_of(unit))) %>%
    summarise(
      n_crimes  = n(),
      chi_total = sum(chi_weight, na.rm = TRUE),
      chi_mean  = mean(chi_weight, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(desc(chi_total))
}