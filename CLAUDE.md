# NYC Crime Harm Index (CHI) Project

## What This Is

A research project building a **Crime Harm Index for New York City** that weights crimes by seriousness (midpoint of NYS Penal Law statutory sentencing range, in days) instead of counting them equally. The index is designed for **block-level targeting** of place-based interventions.

**Researcher:** John Hall
**Project root:** `/Users/johnhall/Documents/Research/nys_index/`

---

## Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| CHI weight source | NYS Penal Law sentencing **midpoints** by felony/misdemeanor class | Statutory (not judicial); democratic; avoids Lewis et al. (2024) equity critique; generalizable to other US states |
| Spatial unit | Physical block | Finest operational grain for place-based intervention |
| Gun violence scoring | **Substitution** (v2): shooting CHI *replaces* arrest-based CHI for matched incidents | Avoids double-counting; fatal = Murder 2nd (7,300 days), non-fatal = Att. Murder 2nd (5,475 days) |
| Shots fired | Data-driven pd_desc mix with CPW 2nd (3,376 days) floor | Novel; no existing literature scores shots-fired events |
| CHI granularity | PD-level (offense_description1 x pd_description) | Empirical mean of law_code charges within each PD; finer than any published US CHI |
| Deduplication | Spatiotemporal matching: 500 ft, 12 hours between shootings and complaints | Applied on raw coordinates before block assignment |
| Proactive crime | Excluded from base CHI (uses complaint data = victim-reported) | Per Sherman et al. (2016) principle |
| Year range | 2018-2022 for CHI construction; 2020-2025 for gun violence / robustness | |

---

## Script Pipeline

Scripts run in numbered order. The `scripts/` folder contains the current versions; root-level R files are older/legacy.

| Script | Purpose | Key Outputs |
|--------|---------|-------------|
| `scripts/00_chi_setup_v2.R` | Load NYPD complaint data, define 10 target offenses (7 UCR Part I + 3), build CHI lookup table from NYS Penal Law | Lookup tables, audit files |
| `scripts/01_chi_offense_level.R` | CHI weights at offense level (offense_description1) | `chi_offense_by_year.csv`, temporal stability |
| `scripts/02_chi_pd_level.R` | CHI weights at PD level (offense x police_description) | `chi_pd_key.csv`, `chi_pd_weights.csv` |
| `scripts/03_chi_model_comparison.R` | Compare offense-level vs PD-level models | Scatter plots, stability comparison |
| `scripts/04_gun_violence_index.R` | Score shootings (victim-level) and shots fired; v2 substitution approach | `gun_violence_chi_weights.csv`, shooting/SF datasets |
| `scripts/05-harm_key.R` | Unify all CHI sources into single lookup (`chi_harm_key`) | `chi_harm_key.csv` — the ONE object downstream scripts use |
| `scripts/06-aggregate_CHI_wts.R` | Portable functions: `deduplicate_gun_violence()`, `assign_chi()`, `aggregate_chi()` | Functions for any spatial aggregation |
| `03_robustness_analysis.R` (root) | Test robustness of block targeting across specs (all vs. outside-only harm, low/mid/high weights, N=200/300/400) | Overlap stats, rank correlations |

### EBC Targeting Analysis Scripts (in `ebc_targeting_choices/scripts/`)
| Script | Purpose | Key Outputs |
|--------|---------|-------------|
| `00_load_data.R` | Load spatial infrastructure, complaint/shooting/SF data, CHI harm key, facility data | All sf objects, parameters |
| `01_build_block_matrix.R` | Allocate crimes to blocks, identify exclusions, build analysis matrix | `block_matrix`, `exclusion_summary` |
| `02_model_definitions.R` | Define 9 targeting models (3 families: Gun Violence, Count-Based, CHI) | Model score columns, rankings |
| `03_exploratory_analysis.R` | EDA: distributions, concentration curves, borough breakdowns | Figures 00–06 |
| `04_model_comparison.R` | Compare models: capture rates, overlap, hot spot coverage | Figures 07–16 |
| `05_block_level_stats.R` | Block-level descriptive statistics for top-N blocks | Stats tables |
| `06_trajectory_analysis.R` | K-means trajectory groups for 7MF at physical blocks (2014–2024) | `17_trajectory_groups.png`, neighborhood zoom maps, `block_trajectory_assignments.csv` |

**Note:** `00_load_data.R` loads NYCHA shapefile from `ebc_targeting_choices/data/NYCHA_developments_public` (not root `data/`). The `chi_harm_key.rds` now has separate fatal (7,300) and non-fatal (5,475) shooting weights.

### Legacy scripts
- `scripts/legacy/00_setup_and_data.R` — older setup version
- `scripts/legacy/penal_law_chi_corrected.R` — earlier CHI table

---

## Data Sources

| File | Description | Notes |
|------|-------------|-------|
| `data/NYPD_Complaint_Data_Historic_*.csv` | NYPD complaint records (victim-reported) | Multiple download dates; ~5M+ rows |
| `data/NYPD_Complaint_Data_Current_*.csv` | Current YTD complaints | |
| `data/NYPD_Shooting_Incident_Data_*.csv` | Shooting incidents (one row per event) | |
| `data/NYPD_Shooting_Victims_20260217.csv` | Victim-level shooting data with STAT_MURDER_FLG | Key for fatal/non-fatal distinction |
| `data/NYPD_Shootings_20260217.csv` | Incident-level shooting data | |
| `data/NYPD_Arrests_Data_*.csv` | Historic arrest records | |
| `data/sf_since_2017.csv` | Shots fired data | |
| `data/shots_fired_new.csv` | Updated shots fired | |
| `data/nypd_precinct_locations.csv` | Precinct geocodes | |
| `data/intersection_to_blocks_flat.csv` | Intersection-to-block crosswalk | |
| `data/Facilities_Database_20260115.csv` | NYC facilities | |
| `data/chi_reference_clean.csv` | Cleaned CHI reference table | |
| `data/arrest_table.csv` | Arrest summary table | |

---

## Key Output Files

### Tables (in `output/tables/`)
- `chi_harm_key.csv` — Unified harm weights (THE key lookup)
- `chi_pd_key.csv` — PD-level weights
- `chi_lookup_table.csv` — Full law-code-to-CHI mapping
- `penal_law_chi_lookup.csv` — Penal law reference
- `gun_violence_chi_weights.csv` — Shooting/SF weights
- `chi_model_*` — Model comparison tables
- `sf_chi_*` — Shots-fired CHI by geography/time
- `shootings_by_*` — Shooting volume tables

### Figures (in `output/figures/`)
- `fig01-05` — CHI offense/PD level analysis
- `fig06-09` — Model comparison
- `fig_gun_*` — Gun violence visualizations

### Audit (in `output/audit/`)
- `law_code_audit_full.csv` — Complete code matching audit
- `law_code_crosswalk.csv` — Code mapping
- `missing_chi_weights.csv` — Unmatched codes

### Diagnostics (in `output/diagnostics/`)
- Block-level shooting/complaint comparison
- Fatal/non-fatal match summaries

---

## Literature

### Corpus
- `literature/processed/` — 42 markdown files (extracted from PDFs) covering two bodies of literature:
  - **CHI literature** (27 unique papers): Sherman (2007), Sherman (2013), Sherman et al. (2016), Bland & Ariel (2015), Wallace et al. (2009), Weinborn et al. (2017), Ratcliffe (2015), Mitchell (2019), Lewis et al. (2024), Fenimore (2019), Ignatans & Pease (2016), Von Hirsch & Jareborg (1991), Groff et al. (2015), etc.
  - **Indices, measurement, and commensurability** (25 papers): Sellin (1931), Blumstein (1974), Rossi et al. (1974), Sen (1999), Espeland & Stevens (1998), OECD Handbook, Ravallion (2012), Bevan & Hood (2006), Jerven (2013), Munda (2004), Saisana et al. (2005), Stiglitz-Sen-Fitoussi (2009), Wolfgang et al./NSCS (1985), etc.
- `literature/to_be_processed/` — original PDFs (do not read; markdowns are the working copies)

### Synthesis Documents
- `literature/CHI_synthesis.md` — Full CHI literature synthesis (generated 2026-03-21; updated with 8 new papers)
- `literature/BIBLIOGRAPHY_AND_GAP_ANALYSIS.md` — CHI annotated bibliography + gap analysis (generated 2026-03-21; updated with 8 new papers)
- `literature/INDICES_MEASUREMENT_COMMENSURABILITY_synthesis.md` — Broader measurement/indices synthesis (generated 2026-03-21; updated with 4 new papers)
- `literature/INDICES_MEASUREMENT_COMMENSURABILITY_bibliography.md` — Measurement bibliography + gap analysis (generated 2026-03-21; updated with 4 new papers)

### Duplicates to clean up
- `literature/processed/paw003 (1).md` (duplicate of `paw003.md` — Sherman et al. 2016)
- `literature/processed/annurev.soc.24.1.313 (1).md` (duplicate of `annurev.soc.24.1.313.md` — Espeland & Stevens 1998)
- `literature/processed/pav029 (1).md` (duplicate of `pav029.md` — Ignatans & Pease 2016)
- `literature/processed/1-s2.0-S0143622816304933-main (1).md` (duplicate of Weinborn et al. 2017)
- `literature/processed/11OxfordJLegalStud1 (1).md` (duplicate of Von Hirsch & Jareborg 1991)
- `literature/processed/Criminology - 2014 - GROFF - DOES WHAT POLICE DO AT HOT SPOTS MATTER (2).md` (duplicate of Groff et al. 2015)

### Key literature findings for this project
- This project fills **4 major gaps** in the CHI literature: (1) first US CHI using statutory midpoints, (2) gun violence substitution methodology, (3) block-level harm concentration in a US city, (4) robustness of targeting to CHI specification
- The statutory-midpoint approach is resistant to the Lewis et al. (2024) equity/feedback-loop critique
- The PD-level granularity may be the finest operational CHI in the US literature
- **No CHI paper engages the composite-indicator methodology literature** (OECD Handbook, Sen, Ravallion) — this project can be the first to bridge the two traditions
- Blumstein (1974) showed weighting didn't matter at the national level; Weinborn et al. (2017) showed it did at the street-segment level. Testing inter-crime correlations at the NYC block level would directly justify the CHI approach
- Bevan & Hood (2006) / Goodhart's Law: frame the CHI as a targeting tool, not an accountability metric, to mitigate gaming risks
- The CHI is an explicit act of commensuration (Espeland & Stevens, 1998) — embedded trade-off ratios should be published transparently

---

## Documentation

### Academic / Technical (`docs/`)
- `docs/chi_technical_reference.docx` — Technical reference document
- `docs/matching_logic (1).svg` — Matching logic diagram
- `scripts/CHI_Lookup_Table_Complete.md` — Full CHI lookup with NYS Penal Law citations and sentencing framework

### Policy / MOCJ (`policy/`)
- `policy/NYC_Crime_Harm_Index_Policy_Brief.docx` — Plain-language policy brief (~10 pages, embedded figures, footnoted citations)
- `policy/NYC_Crime_Harm_Index.pptx` — 11-slide presentation for policymakers (MOCJ-branded, Helvetica Neue, restrained navy palette)
- `policy/Colors.pdf` — MOCJ color palette reference
- `policy/Style guide_2021.pdf` — MOCJ 2021 style guide (fonts, logos, colors)

---

## Sentencing Framework Quick Reference

| Class | Type | Range | Midpoint | CHI (days) |
|-------|------|-------|----------|------------|
| A-I | Murder 1st (125.27) | 20-40 yrs to life | 30 yrs | 10,950 |
| A-I | Murder 2nd (125.25) | 15-25 yrs to life | 20 yrs | 7,300 |
| B | Violent | 5-25 yrs | 15 yrs | 5,475 |
| C | Violent | 3.5-15 yrs | 9.25 yrs | 3,380 |
| D | Violent | 2-7 yrs | 4.5 yrs | 1,643 |
| E | Violent | 1.5-4 yrs | 2.75 yrs | 1,004 |
| B | Non-Violent | 1-9 yrs | 5 yrs | 1,825 |
| C | Non-Violent | 1-5.5 yrs | 3.25 yrs | 1,186 |
| D | Non-Violent | 0-2.5 yrs | 1.25 yrs | 456 |
| E | Non-Violent | 0-1.5 yrs | 0.75 yrs | 274 |
| A | Misdemeanor | ≤1 yr | 0.5 yr | 183 |
| B | Misdemeanor | ≤3 mo | 45 days | 45 |

---

## 10 Target Offense Categories

1. MURDER & NON-NEGL. MANSLAUGHTER
2. RAPE
3. ROBBERY
4. FELONY ASSAULT
5. BURGLARY
6. GRAND LARCENY
7. GRAND LARCENY OF MOTOR VEHICLE
8. ASSAULT 3 & RELATED OFFENSES
9. PETIT LARCENY
10. SEX CRIMES

(7 UCR Part I equivalents + Misdemeanor Assault + Petit Larceny + Sex Crimes)

---

## Session Logging

Session logs are stored in `session_logs/` with format `YYYY-MM-DD_summary.md`. Each log captures:
- What was done
- Key decisions made
- Files created or modified
- Open questions / next steps

---

## Conventions

- R is the primary analysis language (tidyverse ecosystem)
- `here()` is used for relative paths
- Output CSVs go in `output/tables/`; figures in `output/figures/`
- Script numbering reflects dependency order (00 → 01 → 02 → ... → 06)
- The `chi_harm_key` from script 05 is the single source of truth for downstream harm weights
- The dedup/score/aggregate functions in script 06 are the canonical way to apply weights
