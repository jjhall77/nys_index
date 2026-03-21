# Session Log: 2026-03-21 (Part 5) — Indices/Measurement/Commensurability Literature Update

## What Was Done

### Updated Indices/Measurement/Commensurability Literature Documents with 4 New Papers

John added new theory/indices PDFs (converted to markdowns) to `literature/processed/`. Four new unique papers were identified and integrated into the existing `INDICES_MEASUREMENT_COMMENSURABILITY_synthesis.md` and `INDICES_MEASUREMENT_COMMENSURABILITY_bibliography.md`.

#### New papers integrated:

1. **Munda (2004)** — "Social Multi-Criteria Evaluation: Methodological Foundations and Operational Consequences." *European J Operational Research*. Key contribution: distinguishes weights-as-importance-coefficients from weights-as-substitution-rates; argues for non-compensatory aggregation that respects incommensurability; sensitivity analysis should test ethical positions, not arbitrary weight combinations. Integrated into Phase 3.

2. **Saisana, Saltelli & Tarantola (2005)** — "Uncertainty and Sensitivity Analysis Techniques as Tools for the Quality Assessment of Composite Indicators." *JRSS-A*. Key contribution: Monte Carlo UA + Sobol' variance decomposition for composite indicators; weighting scheme dominates output variance (not normalization); 48-56% of variance from interactions; rankings should have uncertainty bounds. Integrated into Phase 3.

3. **Stiglitz, Sen & Fitoussi (2009)** — *Report on Measurement of Economic Performance and Social Progress*. Key contribution: "what we measure affects what we do"; present composites alongside components; capability approach as philosophical grounding for non-monetary weights; dashboard vs. composite debate. Integrated into Phase 4.

4. **Wolfgang, Figlio, Tracy & Singer (1985)** — *National Survey of Crime Severity* (NSCS). Key contribution: 60,000-respondent magnitude estimation study; 204-event severity scale; component-based scoring (injury + theft + intimidation + entry); strong cross-demographic consensus (r > .85-.98); provides the benchmark perception-based severity scores against which statutory-midpoint CHI weights can be compared. Integrated into Phase 2.

### Also identified:
- 2 new duplicate files: `11OxfordJLegalStud1 (1).md`, `Criminology - 2014 - GROFF - DOES WHAT POLICE DO AT HOT SPOTS MATTER (2).md`
- 1 file that is criminological methodology, not indices/theory: `Criminology - 2005 - SAMPSON - SEDUCTIONS OF METHOD (rejonder)` (variant of already-in-corpus Sampson & Laub 2005)

### Changes to `INDICES_MEASUREMENT_COMMENSURABILITY_synthesis.md`:
- Updated corpus count (22 → 25 papers)
- Integrated Wolfgang et al. (1985)/NSCS into Phase 2 (seriousness revolution) — the culmination of magnitude estimation
- Integrated Munda (2004) into Phase 3 — non-compensatory SMCE, weights-as-trade-offs distinction
- Integrated Saisana et al. (2005) into Phase 3 — Monte Carlo + Sobol' robustness methodology
- Integrated Stiglitz-Sen-Fitoussi (2009) into Phase 4 — measurement shapes policy, capability approach, dashboard principle
- Added 3 new entries to Methods Inventory
- Updated Tier 2 and Tier 3 recommendations with new methodological references
- Reorganized Section 5 (Missing Corpus): moved 4 papers to "Now in Corpus" tracker

### Changes to `INDICES_MEASUREMENT_COMMENSURABILITY_bibliography.md`:
- Added entries #22–25 to Part 1 bibliography table
- Added 2 new duplicate files to Part 1B
- Restructured Part 2: down from 15 to 10 papers still needed
- Added "Papers Now in Corpus" tracking table
- Updated debates 1, 2, and 6 with new citations

### Changes to `CLAUDE.md`:
- Updated indices/measurement corpus count from 21 to 25
- Listed key new papers
- Updated synthesis document descriptions to note updates
- Added 2 new duplicate files to cleanup list

## Files Modified
- `literature/INDICES_MEASUREMENT_COMMENSURABILITY_synthesis.md`
- `literature/INDICES_MEASUREMENT_COMMENSURABILITY_bibliography.md`
- `CLAUDE.md`

## Files Created
- `session_logs/2026-03-21_indices_measurement_update.md`

## Key New Insights

- **Munda (2004)** sharpens the compensability debate: the CHI's linear aggregation means weights function as *substitution rates* (one murder = N thefts), not as *importance coefficients*. This distinction should be made explicit in any crossover paper.
- **Saisana et al. (2005)** provides the exact template for Monte Carlo robustness testing. Their finding that interaction effects dominate (48-56% of variance) means the project's multi-specification robustness analysis is on the right track — but one-at-a-time sensitivity tests would be insufficient.
- **Stiglitz-Sen-Fitoussi (2009)** links the capability approach to sentencing-based weights: imprisonment = direct freedom deprivation, giving statutory midpoints a philosophical grounding beyond "democratic legitimacy."
- **Wolfgang et al. (1985)/NSCS** provides the 204-event perception-based benchmark against which the project's statutory-midpoint weights can be compared. The NSCS severity ratio for killed:hospitalized (~3:1) vs. the CHI ratio for Murder 2nd:Felony Assault D (~4.4:1) shows the two approaches produce similar but non-identical orderings.

## New Duplicates Identified
- `literature/processed/11OxfordJLegalStud1 (1).md` (duplicate of Von Hirsch & Jareborg 1991)
- `literature/processed/Criminology - 2014 - GROFF - DOES WHAT POLICE DO AT HOT SPOTS MATTER (2).md` (duplicate of Groff et al. 2015)

## Open Questions / Next Steps
- 3 Tier 1 papers still to obtain: Porter (1995), Arrow (1951), Sellin & Wolfgang (1964)
- The Sobol' sensitivity analysis (Saisana et al. 2005) is the gold standard for robustness — consider implementing in R
- Munda's SMCE framework could be tested as an alternative to linear CHI aggregation
- The NSCS provides severity benchmarks that could be directly compared to statutory midpoints in a table
