# Session Log: 2026-03-21 (Part 2) — Broader Literature on Indices, Measurement, and Commensurability

## What Was Done

### Literature Review: Indices, Measurement, and Commensurability

John added ~22 new PDFs (with corresponding markdowns) to `literature/processed/` covering the broader intellectual foundations of crime measurement. These span:

- **Crime index foundations:** Sellin (1931), Wilkins (1963), Biderman & Reiss (1967), Maltz (1999)
- **Crime seriousness weighting:** Blumstein (1974), Rossi et al. (1974), Parton et al. (1991), Stylianou (2003), Pease et al. (1975)
- **Measurement theory:** Stevens (1946) — scales of measurement
- **Composite indicators:** OECD Handbook (Nardo et al., 2008), Saltelli (2007), Ravallion (2012)
- **Social choice and commensurability:** Sen (1999), Espeland & Stevens (1998)
- **Politics of measurement:** Bevan & Hood (2006), Jerven (2013), Maguire (2007)
- **Criminological method:** Sampson & Laub (2005)
- **Place-based harm:** Weinborn et al. (2017) — the foundational hotspots vs. harmspots paper
- **Crime and criminal justice indicators:** Fienberg & Reiss (1980)

Generated two comprehensive documents following the `literature_review_prompt.md` template:

**`literature/INDICES_MEASUREMENT_COMMENSURABILITY_synthesis.md`** covering:
- Five-phase intellectual history from 1831 to present
- Six active debates (perceptions vs. sentencing; compensability; measurement level; dark figure; gaming/Goodhart's Law; commensurability)
- Full methods inventory with tiered recommendations
- Seven identified gaps, several directly fillable by this project
- Missing corpus of critical external references

**`literature/INDICES_MEASUREMENT_COMMENSURABILITY_bibliography.md`** covering:
- Complete bibliography of all 21 new papers
- 15 papers to obtain, tiered by priority
- Quick-reference debate table
- Six research opportunities with priority rankings
- Top 5 recommended research priorities

### Project File Updates
- Updated `CLAUDE.md` literature section to reflect the expanded corpus (42 total markdowns), all four synthesis documents, and key findings from both reviews
- Identified a second duplicate file to clean up: `annurev.soc.24.1.313 (1).md`

## Key Findings

### Major theoretical contributions this project can make:

1. **Bridge the CHI and composite-indicator literatures.** No CHI paper cites the OECD Handbook, discusses compensability, or engages with Sen/Ravallion. This project can be the first.

2. **Replicate the Blumstein null at block level.** Blumstein (1974) showed weighting didn't matter nationally (inter-crime r > .958). If correlations are much lower across NYC blocks, this directly justifies block-level CHI.

3. **Publish embedded trade-off ratios.** No CHI reveals what its weights imply (e.g., 1 murder = 3,650 bicycle thefts). OECD framework mandates this transparency.

4. **Frame CHI in Sen's partial comparability.** Statutory midpoints are exactly what Sen calls "partial interpersonal comparisons" — imperfect but sufficient for practical decisions.

5. **Engage Goodhart's Law.** Bevan & Hood (2006) shows what happens when metrics become targets. Frame CHI as a targeting tool, not an accountability metric.

## Files Created
- `literature/INDICES_MEASUREMENT_COMMENSURABILITY_synthesis.md`
- `literature/INDICES_MEASUREMENT_COMMENSURABILITY_bibliography.md`
- `session_logs/2026-03-21_broader_literature_review.md`

## Files Modified
- `CLAUDE.md` — updated literature section

## Duplicates to Clean Up
- `literature/processed/paw003 (1).md` (duplicate of `paw003.md`)
- `literature/processed/annurev.soc.24.1.313 (1).md` (duplicate of `annurev.soc.24.1.313.md`)

## Open Questions / Next Steps
- Obtain Tier 1 missing papers: Porter (1995), Arrow (1951), Wolfgang et al. (1985), Munda (2004)
- Consider writing a standalone review paper tracing the full lineage from Sellin (1931) through modern CHI
- Run the Blumstein test (inter-crime correlations across blocks) as an empirical contribution
- Decide whether to test non-compensatory aggregation rules
- Consider a "trade-off ratio table" as a publication-ready appendix
