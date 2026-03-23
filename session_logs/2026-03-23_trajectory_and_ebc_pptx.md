# Session Log: 2026-03-23 — EBC PowerPoint, Trajectory Analysis, Pipeline Fixes

## What Was Done

### 1. EBC Targeting Analysis PowerPoint
- Created `policy/EBC_Targeting_Analysis.pptx` — 9 slides, restrained MOCJ palette
- Slides: Title, The Question (3 big stats), Nine Models/Three Families, Capture Rates (fig), Core Trade-Off (table + recommendation cards), Hot Spot Coverage (fig), Overlap Heatmap + findings, Geographic Concentration (borough dist + concentration curves), Closing
- Same design language as CHI PPTX: navy/white/seafoam, Helvetica Neue, proper aspect ratios

### 2. Trajectory Analysis — Diagnosed & Fixed Sawtooth Bug
- User flagged sawtooth pattern in trajectory groups plot from discursive document v2
- **Root cause identified:** `cmplnt_fr_dt` (complaint-from date) had sparse pre-2014 records (88 in 2006, 112 in 2007, ..., 2,745 in 2013) that were just late-reported crimes, not complete years. The NYPD historic complaint file (`_20251214`) only contains data starting 2014 by `rpt_dt`.
- Verified year counts for both date fields across combined historic + current files
- **Fix:** Start trajectory analysis at 2014 where data is complete (~96K–126K 7MF complaints/year)

### 3. Trajectory Analysis Script Created
- Created `ebc_targeting_choices/scripts/06_trajectory_analysis.R`
- K-means (k=6 + crime-free) on block × year matrix of 7 Major Felonies, 2014–2024
- **Three bugs from original plot fixed:**
  1. Sawtooth: caused by sparse pre-2014 `cmplnt_fr_dt` records → start at 2014
  2. Duplicate "High-stable" labels: now uses relative trend (slope/mean) for direction labels + rank suffix for collisions
  3. Cluttered legend: cleaned up with unique, descriptive labels + n/pct
- Outputs:
  - `17_trajectory_groups.png` — citywide trajectory plot (clean, no sawtooth)
  - `18_trajectory_map_1_elmhurst.png` — neighborhood zoom (most heterogeneous NTA)
  - `18_trajectory_map_2_hunts_point.png` — neighborhood zoom
  - `block_trajectory_assignments.csv` — block-level cluster assignments
  - `trajectory_means.csv` — cluster means by year
  - `nta_trajectory_heterogeneity.csv` — NTA-level diversity scores
- Final trajectory groups (2014–2024, N=89,292 blocks):
  - Chronic-high-stable (n=7, 0.0%) — mean 185 incidents/yr
  - High-increasing (n=97, 0.1%) — mean 46
  - Moderate-increasing (n=635, 0.7%) — mean 18
  - Moderate-increasing (n=3,372, 3.8%) — mean 8
  - Low-stable (n=12,281, 13.8%) — mean 3
  - Low-stable (n=56,245, 63.0%) — mean 0.5
  - Crime-free (n=16,655, 18.7%) — mean 0

### 4. Pipeline Fixes (00_load_data.R)
- **NYCHA path fix:** Shapefile was in `ebc_targeting_choices/data/NYCHA_developments_public`, not `data/`. Updated `here()` path in `00_load_data.R`.
- **Shooting weight fix:** `chi_harm_key.rds` now has separate FATAL (7,300 days) and NON-FATAL (5,475 days) shooting weights. The `stopifnot(length(SHOOTING_WEIGHT) == 1)` was failing. Fixed to extract both, using non-fatal as default for block-level allocation.
- Full pipeline now runs clean: `00_load_data.R` → `01_build_block_matrix.R` → `06_trajectory_analysis.R`

## Files Created
- `policy/EBC_Targeting_Analysis.pptx`
- `ebc_targeting_choices/scripts/06_trajectory_analysis.R`
- `ebc_targeting_choices/output/17_trajectory_groups.png`
- `ebc_targeting_choices/output/18_trajectory_map_1_elmhurst.png`
- `ebc_targeting_choices/output/18_trajectory_map_2_hunts_point.png`
- `ebc_targeting_choices/output/block_trajectory_assignments.csv`
- `ebc_targeting_choices/output/trajectory_means.csv`
- `ebc_targeting_choices/output/nta_trajectory_heterogeneity.csv`

## Files Modified
- `ebc_targeting_choices/scripts/00_load_data.R` — NYCHA path fix + shooting weight fix
- `CLAUDE.md` should be updated to reflect new script 06 and the NYCHA path

## Key Decisions
- 2014–2024 is the valid date range for trajectory analysis given available complaint data
- `cmplnt_fr_dt` filtered to 2014+ is functionally equivalent to `rpt_dt` (within ~1%)
- Non-fatal shooting weight (5,475) used as default; fatal (7,300) available for substitution logic
- Elmhurst and Hunts Point selected as zoom neighborhoods (highest trajectory heterogeneity)

## Open Questions / Next Steps
- Consider switching trajectory script to `rpt_dt` for consistency with EBC pipeline convention
- The "Moderate-increasing (1)" and "(2)" labels could use better names — may want manual override
- Trajectory assignments could feed into the discursive document v2
- CLAUDE.md needs update to document script 06 and the corrected NYCHA/shooting weight paths
