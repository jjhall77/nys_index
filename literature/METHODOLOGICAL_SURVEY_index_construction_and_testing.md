# Methodological Survey: Building, Testing, and Validating Composite Indices
## With Applications to the NYC Crime Harm Index

**Date generated:** 2026-03-21
**Purpose:** A survey of methods for constructing, testing, and validating composite indices drawn from across disciplines — composite-indicator methodology, social choice theory, crime seriousness research, public administration, and development economics — read through the lens of what John Hall's NYC CHI project has already done and what it could do next.

---

## Part 1: The Construction Pipeline

### 1.1 What the OECD Handbook Prescribes

The canonical reference for composite index construction (Nardo et al., 2008) specifies a 10-step pipeline. Here is how each step maps to the NYC CHI project:

| OECD Step | CHI Project Status | What Could Be Done |
|-----------|-------------------|-------------------|
| 1. Theoretical framework | **Done.** 10 target offense categories selected on criminological grounds (7 UCR Part I + 3). Weights derived from NYS Penal Law statutory midpoints. | Explicitly cite the fitness-for-purpose principle. State the operational goal (block-level targeting for place-based intervention) and the theoretical commitment (sentencing as a democratic proxy for harm). |
| 2. Data selection | **Done.** NYPD complaint data (victim-reported), shooting victim data, shots-fired data. Complaint data selected per Sherman's (2016) exclusion of proactive crime. | Document the selection rationale as a design choice, not a data limitation. Acknowledge what is excluded (proactive, historic, company-detected). |
| 3. Imputation of missing data | **Partially addressed.** Law codes that don't match the CHI lookup table are audited (`missing_chi_weights.csv`). | Quantify the missingness rate (what % of complaint records lack a CHI weight?) and report whether the unmatched records differ systematically from matched ones. |
| 4. Multivariate analysis | **Not yet done.** | Run inter-crime correlations across blocks (the Blumstein test — see §2.1). Compute Cronbach's alpha across offense categories to test internal consistency. Run PCA on block-level offense counts to see how many dimensions of "crime" exist at the block level. |
| 5. Normalization | **Implicitly done** — weights are already in a common unit (imprisonment days), which is a natural normalization. Block-level CHI is a raw sum. | Consider z-score normalization for cross-precinct or cross-borough comparisons, following Weinborn et al. (2017). |
| 6. Weighting and aggregation | **Done.** Statutory midpoints by felony/misdemeanor class. Linear (additive) aggregation. | Test geometric aggregation. Publish the embedded trade-off ratios (see §2.4). Consider non-compensatory aggregation as a robustness check (see §2.5). |
| 7. Robustness and sensitivity analysis | **Partially done** (`03_robustness_analysis.R` tests low/mid/high weights, N=200/300/400, all-harm vs. outside-only). | Extend to Monte Carlo uncertainty analysis (vary all sources simultaneously). Compute Sobol' first-order and total-effect sensitivity indices. Report confidence intervals on block rankings, not just point estimates. |
| 8. Links to other variables | **Not yet done.** | Correlate block-level CHI with external outcomes: 311 complaints, ambulance calls, property values, demographic variables. This validates that the composite captures something "real." |
| 9. Visualization | **Done.** Extensive figures in `output/figures/`. | Add spider/radar diagrams showing offense-category decomposition for top-harm blocks. |
| 10. Back to the details | **Partially done.** The harm key decomposes by source (arrest, shooting, shots fired). | Publish block-level profiles: for each top-N block, show the composition of harm by offense type. This is essential for operational utility (knowing *what kind* of harm, not just *how much*). |

---

## Part 2: Testing and Validation Methods — What the Literature Offers and What You Can Do

### 2.1 The Blumstein Test: Do Crime Types Move Together Across Blocks?

**Source:** Blumstein (1974)

**The method:** Compute the full inter-crime-type Pearson correlation matrix across spatial units. If all correlations exceed ~0.95, weighting is irrelevant — any linear combination will produce the same ranking.

**Blumstein's result at the national level (1960–1972):**
- All 7 × 7 pairwise correlations exceeded 0.958.
- Even after detrending (removing linear time trends and correlating residuals), all exceeded 0.70 except auto theft vs. violent crimes (lowest: 0.336).

**What you can do:**
- Compute the 10 × 10 inter-crime-type correlation matrix across ~120K NYC blocks.
- If correlations are substantially lower than 0.958 — as they almost certainly will be, because the crime mix varies enormously across micro-geography — this is the *direct empirical justification* for block-level weighting.
- Also compute detrended correlations (removing precinct-level means to control for geographic clustering).
- Present as a table directly analogous to Blumstein's Tables 5 and 6.

**Decision criterion:** If the mean inter-crime correlation across blocks is below, say, 0.70, the Blumstein null is decisively rejected at the micro-geographic scale. This would be a significant empirical finding.

**R implementation:** Straightforward — `cor()` on a block × offense-category matrix of counts, then repeat on residuals from a precinct fixed-effect model.

### 2.2 Concentration Analysis: Power-Few, Gini, and Odds Ratios

**Sources:** Sherman (2007), Weinborn et al. (2017), Dudfield et al. (2017)

**The methods:**

**(a) Cumulative concentration curves (Lorenz curves for harm):**
- Rank blocks by total CHI (descending). Plot cumulative % of total CHI (y-axis) against cumulative % of blocks (x-axis).
- Do the same for raw crime counts.
- The divergence between the two curves shows how much more concentrated harm is than volume.

**(b) Gini coefficients:**
- Compute Gini for the block-level CHI distribution and for the block-level count distribution.
- If Gini(harm) > Gini(counts), harm is more concentrated — the standard finding in the literature (Ohyama et al., 2022; Weinborn et al., 2017).

**(c) The 50% threshold:**
- What percentage of blocks account for 50% of total CHI? What percentage account for 50% of total counts?
- Weinborn et al. found 0.96% of segments held 50% of harm vs. 3.26% for counts.

**(d) Odds ratio for concentration difference:**
- OR = (% segments for 50% counts) / (% segments for 50% harm).
- Weinborn et al. found OR = 3.49 (95% CI: 3.27–3.73).

**(e) Co-location analysis:**
- Define "hot blocks" (top 2 SD in counts) and "harm blocks" (top 2 SD in CHI).
- Cross-tabulate: what % are co-located, count-only, or harm-only?
- Weinborn et al. found only 24.7% co-location at 2 SD.

**What you can do:** All of the above. The NYC data is orders of magnitude larger than Weinborn's 15-council sample (~120K blocks vs. ~100K street segments), making these analyses highly powered and the results generalizable as the first US block-level replication.

### 2.3 Robustness of Rankings to Weight Specification

**Sources:** Ravallion (2012), OECD Handbook (Nardo et al., 2008), Saltelli (2007), Blumstein (1974)

**You already do:** Spearman rank correlations and overlap statistics across low/mid/high weights, N=200/300/400, all-harm vs. outside-only.

**What the literature recommends you add:**

**(a) Confidence intervals on rankings, not just point estimates.**
- Ravallion cites Hoyland, Moene & Willumsen (2010): even correlations above 0.95 can mask sizeable rerankings. Georgia's DBI rank was 18 with a 95% CI of (11, 59).
- Method: Monte Carlo simulation. Sample weights from a distribution around the midpoint (e.g., uniform between low and high statutory range). Compute CHI for each block under each draw. Report the 5th–95th percentile range of each block's rank across draws.
- Report how many of the top-200 blocks are *always* in the top 200 across all draws (the "robust core").

**(b) Defensible groupings rather than precise rankings.**
- Instead of saying "Block X is ranked #47," say "Block X is in the top tier (ranks 1–50) with 95% confidence, or in Tier 2 (51–200) with 80% confidence."
- This is more honest and more operationally useful — police don't need to know whether a block is ranked 47th or 53rd.

**(c) Extreme reweighting tests.**
- Following Ravallion: put all weight on single offense categories and see how rankings change. What are the top-200 blocks if only murder counts? Only robbery? Only assault?
- This reveals which offense categories *drive* the targeting, which is critical for operational interpretation.

**(d) Full Monte Carlo uncertainty analysis (OECD Handbook, Chapter 7).**
- Vary *all* sources of uncertainty simultaneously: weight specification, inclusion/exclusion of offense categories, aggregation method, deduplication threshold (500 ft / 12 hours vs. alternatives).
- Compute Sobol' first-order sensitivity indices (S_i) and total-effect indices (ST_i) for each uncertainty source.
- S_i tells you: "if I could fix this one source of uncertainty, how much would total ranking variance drop?"
- ST_i tells you: "if I fix everything *except* this source, how much variance remains?"
- If S_i ≈ ST_i, there are no interactions involving that source. If ST_i >> S_i, interactions are important.

**R implementation:** The `sensitivity` package provides Sobol' index estimation. You would need a function that takes a vector of parameters (weight specification, inclusion flags, aggregation function, dedup threshold) and returns a vector of block rankings.

### 2.4 Trade-Off Ratios: The Ravallion/Saltelli Transparency Test

**Sources:** Ravallion (2012), Saltelli (2007), Espeland & Stevens (1998)

**The requirement:** Every composite index embeds implicit trade-off ratios (marginal rates of substitution) between its components. These must be computed, published, and evaluated for reasonableness.

**For linear aggregation:** The MRS between offense types i and j is simply w_i / w_j, where w is the CHI weight. For the NYC CHI:

| Trade-off | Implied equivalence |
|-----------|-------------------|
| 1 Murder 2nd (7,300 days) = | 39.9 Class A misdemeanor assaults (183 days each) |
| 1 Murder 2nd = | 4.4 Felony assaults (avg ~1,643 days via D Violent) |
| 1 Rape (B Violent, 5,475 days) = | 121.7 Petit larcenies (45 days each) |
| 1 Robbery (avg ~1,186–1,643 days) = | 6.5–8.9 Petit larcenies |
| 1 Fatal shooting (7,300 days) = | 1.33 Non-fatal shootings (5,475 days each) |

**What you should do:**
- Publish a full trade-off ratio table as an appendix.
- State explicitly: "Our index implies that one murder produces as much harm as approximately 40 misdemeanor assaults. Users of this index for targeting decisions should evaluate whether this trade-off is acceptable for their operational context."
- Note that under geometric aggregation, the MRS changes: it becomes w_i/w_j × (CHI_j / CHI_i), meaning the trade-off rate depends on the current *level* of each component. This makes the trade-off harder to state simply but reduces compensability.

### 2.5 Compensability Testing: Linear vs. Geometric vs. Non-Compensatory

**Sources:** OECD Handbook (Nardo et al., 2008), Ravallion (2012)

**The problem:** Linear aggregation (your current method) implies full compensability — enough petit larcenies can offset a murder in total block harm. Geometric aggregation reduces this; non-compensatory methods eliminate it.

**What you can test:**

**(a) Geometric aggregation:**
- CHI_block = Π (count_i × weight_i)^{w_i}, where w_i sums to 1.
- This penalizes blocks that score zero on any offense type (geometric mean = 0 if any component = 0). May need a minimum-count adjustment.
- Compare block rankings to linear CHI.

**(b) Lexicographic (priority-based) aggregation:**
- First sort blocks by murder CHI. Break ties by felony assault CHI. Break remaining ties by robbery CHI. Etc.
- This is fully non-compensatory: no amount of petit larceny can compensate for a murder deficit.
- Compare to linear rankings.

**(c) The OECD's non-compensatory multi-criteria approach (Condorcet-Kemeny-Young-Levenglick):**
- For each pair of blocks, compute an outranking score based on pairwise offense-category comparisons.
- Computationally expensive for ~120K blocks but feasible for the top-1000.
- Weights function as "importance coefficients" (not trade-offs) under this method.

**Decision criterion:** If linear, geometric, and lexicographic produce essentially the same top-200, compensability is operationally harmless. If they diverge, you've identified a consequential design choice that the field has ignored.

### 2.6 Correlation with External Variables (Validation)

**Sources:** OECD Handbook Step 9, Ravallion (2012)

**The principle:** A composite index should correlate with outcomes it is theoretically expected to predict, *after* removing any component overlap (to avoid tautological correlation).

**What you can do:**
- Correlate block-level CHI with external harm indicators: 311 quality-of-life complaints, ambulance/EMS calls, emergency department assault admissions (Shepherd method), property value changes.
- Use the OECD's Monte Carlo correlation framework: vary weights over 10,000 random draws, compute the correlation with the external variable at each draw, report the distribution of correlations.
- If the correlation is robust across weight specifications, the index captures something "real" beyond the particular weights chosen.

### 2.7 Decomposition and Dominance Analysis

**Sources:** OECD Handbook Step 8, Blumstein (1974)

**The principle:** After computing the composite, decompose it to check that no single component dominates the index (unless that is theoretically intended).

**Blumstein's decomposition for the US (1972):**
- FBI index: homicide + rape = 1.1%; burglary + larceny + auto theft = 86%.
- Sellin-Wolfgang: homicide + rape = 7%; property = 62%.
- Dollar index: homicide = 96.13%.

**What you should do:**
- For the top-200 blocks, compute the share of total CHI attributable to each offense category.
- If murder dominates (>50%), the CHI is effectively a murder counter — operationally useful but not a "general harm" index.
- If the composition is diverse, the index captures multi-dimensional harm.
- Report this as a stacked bar chart (analogous to Blumstein's Table 10).

### 2.8 Temporal Stability of Weights

**Sources:** Karrholm et al. (2020), Sarnecki (2021), your scripts 01 and 02

**You already do:** Year-by-year CHI weights at offense and PD level.

**What you should add:**
- Compute the coefficient of variation (CV) for each weight across years.
- Identify "stable" (CV < 0.10) and "volatile" (CV > 0.25) categories.
- Test whether block rankings are stable across time using the same weights applied to different year windows (e.g., 2018–2020 vs. 2020–2022).
- Report Spearman rank correlations across time windows.

### 2.9 The Gaming/Goodhart Audit

**Sources:** Bevan & Hood (2006), Maguire (2007)

**You cannot run this empirically** (it requires a post-implementation study). But you can:

**(a) Use Bevan & Hood's formal framework to classify what the CHI captures:**
- Ω (total performance domain) = all crime harm in the city.
- α (target domain) = 10 offense categories in the CHI.
- α_g (good measures) = offenses with high reporting rates and stable recording practices (murder, auto theft).
- α_i (imperfect measures) = offenses with moderate reporting rates (assault, robbery).
- α_n (no usable data) = offenses with very low reporting rates or outside the 10 categories (domestic violence underreporting, white-collar crime).
- β (not measured) = fear of crime, quality of life, disorder, proactive policing outputs.

**(b) Identify specific gaming risks:**
- Reclassification: felony assault downgraded to misdemeanor assault to reduce block CHI.
- Threshold effects: if resources are deployed to "top-200" blocks, blocks near the threshold have incentives to suppress reporting.
- Output distortion: focus on measured offense categories at the expense of unmeasured community safety dimensions.

**(c) Recommend safeguards:**
- Use the CHI as a *targeting* tool (where to look), not an *accountability* metric (how well police performed).
- Never publish block-level rankings as performance measures.
- Audit recording practices for blocks near the targeting threshold.

---

## Part 3: Problems and Analytical Pitfalls

### 3.1 The Additivity Problem

**The concern:** Can CHI weights be meaningfully summed across offense types?

**Evidence from the seriousness perceptions literature (against simple summation):**
- Only 32% of subjects judged two identical crimes as twice as serious as one (Pease, Ireson & Thorpe, 1974).
- 63.5% judged coupled offenses as equally serious to a single offense (Wagner & Pease, 1978).
- Significant interaction between crime type and monetary loss — directly damaging the additivity assumption (Gottfredson, Young & Laufer, 1980).
- Crime seriousness is multidimensional (harmfulness × wrongfulness), violating the unidimensionality required for magnitude scaling (Schneider, 1982; Parton et al., 1991).

**Why this does not apply to your CHI:** The additivity debate concerns *perceptual seriousness scores* derived from magnitude estimation — a psychophysical procedure whose ratio-scale claims are contested. Your CHI uses *statutory sentencing days* — a unit with a true zero (0 days) and objective interval properties (365 days is exactly twice 182.5 days). The measurement-theoretic objections (no zero point, multidimensionality of the construct, non-additive perceptual processes) do not apply. Sentencing days are not psychological magnitudes; they are legislatively defined quantities that can be summed without invoking psychophysical assumptions. **This is a significant methodological advantage that should be articulated explicitly in any paper.**

### 3.2 The Dark Figure Problem

**Source:** Biderman & Reiss (1967), Maguire (2007)

**The concern:** The CHI measures *reported* harm. Offense types with low reporting rates (sexual assault, domestic violence) are systematically underweighted relative to their true harm burden.

**Available reporting rate estimates (from NCVS):**

| Offense | Approximate reporting rate |
|---------|--------------------------|
| Murder | ~100% |
| Robbery | ~60% |
| Aggravated assault | ~60% |
| Burglary | ~55% |
| Motor vehicle theft | ~80% |
| Rape/sexual assault | ~25–35% |
| Simple assault | ~45% |
| Petit larceny | ~30% |

**What you could do (sensitivity analysis):**
- Divide each block's CHI contribution by offense-specific reporting rate to produce a "reportability-adjusted" CHI.
- Compare block rankings before and after adjustment.
- If rankings are stable, the dark figure doesn't affect targeting. If they shift, identify which blocks are most sensitive to the adjustment (likely those with high sexual-assault or domestic-violence concentrations).

### 3.3 The Data Infrastructure Problem

**Source:** Jerven (2013), Maltz (1999)

**The concern:** Administrative crime data inherit the recording practices, classification inconsistencies, and institutional pressures of the producing agencies.

| Jerven's GDP Problem | Your CHI Analogue |
|---------------------|-------------------|
| Base year obsolescence | Offense classification systems unchanged since the 1970s; new crime types (cyberstalking, identity theft) poorly captured |
| Informal sector invisibility | Unreported crime (the "dark figure") |
| Political manipulation of counts | CompStat-era pressure to downgrade offense classifications |
| Multiple conflicting datasets | NYPD complaint data vs. arrest data vs. shooting data giving different pictures of the same block |
| Rebasing shocks | NIBRS transition creating artificial breaks in time series |

**What you should do:** Acknowledge these as limitations. Note that the deduplication algorithm (500 ft, 12 hours) and the audit trail (`law_code_audit_full.csv`, `missing_chi_weights.csv`) are transparency measures that address the Jerven critique. Frame the CHI as a "best available estimate" rather than a precise measurement.

### 3.4 The Single-Event Outlier Problem

**Source:** Weinborn et al. (2017)

**The concern:** A single catastrophic event (a double murder, a mass shooting) can make a block appear as a top-harm location when it has no other crime. This is a genuine targeting problem — should police deploy ongoing resources to a block where a once-in-a-decade event occurred?

**What you should do:**
- Flag blocks where >50% of total CHI comes from a single incident.
- Report the "event count" alongside total CHI for each top-N block.
- Consider a minimum-event threshold (e.g., exclude blocks with fewer than 3 CHI-contributing events from the targeting list).

### 3.5 The Modifiable Areal Unit Problem (MAUP)

**The concern:** Results can change depending on how geographic units are defined. "Block" is not a natural geographic unit — it is an administrative construct.

**What you should do:**
- Test whether aggregation to a slightly different spatial unit (census block group, street segment, 200-meter grid) changes the top-N targeting list.
- If robust, MAUP is not a concern for this application. If not, the spatial unit definition is consequential.

---

## Part 4: The Full Testing Agenda — Priority-Ordered

### Tier 1: Essential for Publication

| Test | Method | What It Shows | Script/Effort |
|------|--------|--------------|---------------|
| **Blumstein test at block level** | 10×10 inter-crime correlation matrix across blocks | Whether weighting matters at the micro-geographic scale | New; straightforward |
| **Concentration analysis** | Lorenz curves, Gini, 50% threshold, OR, co-location | How much more concentrated harm is than volume | New; moderate |
| **Trade-off ratio table** | w_i / w_j for all offense pairs | What the weights imply about equivalences | New; trivial to compute |
| **Decomposition of top-N blocks** | Stacked bar chart of CHI by offense category | What drives harm at targeted blocks | New; straightforward |
| **Ranking confidence intervals** | Monte Carlo over weight distributions | How robust individual block rankings are | New; moderate |

### Tier 2: Strongly Recommended

| Test | Method | What It Shows | Script/Effort |
|------|--------|--------------|---------------|
| **Compensability test** | Compare linear, geometric, lexicographic block rankings | Whether the aggregation function matters | New; moderate |
| **Extreme reweighting** | All-weight-on-one-offense rankings | Which offense categories drive targeting | New; straightforward |
| **Temporal stability of targeting** | Spearman ρ across time windows | Whether the same blocks emerge year after year | Extend existing |
| **External validation** | Correlate block CHI with 311 calls, EMS, property values | Whether the index captures "real" harm | New; needs external data |

### Tier 3: Advanced / Future Work

| Test | Method | What It Shows | Script/Effort |
|------|--------|--------------|---------------|
| **Full Sobol' sensitivity analysis** | Variance decomposition across all uncertainty sources | Which design choice matters most | New; substantial |
| **PCA on block-level offense counts** | How many dimensions of "crime" exist at the block level | Whether a single index can represent block-level crime | New; straightforward |
| **Dark-figure sensitivity** | Reportability-adjusted CHI | Whether reporting rate variation changes targeting | New; moderate |
| **MAUP test** | Re-aggregate to alternative spatial units | Whether block definition matters | New; moderate |
| **Non-compensatory multi-criteria** | Condorcet-Kemeny-Young-Levenglick ranking for top-1000 | Most rigorous aggregation alternative | New; computationally intensive |
