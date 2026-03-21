# The Arrest-Distribution Bias Problem in PD-Level CHI Weights

**Date:** 2026-03-21
**Companion to:** `INDICES_MEASUREMENT_COMMENSURABILITY_synthesis.md`, `THE_LEAST_WORST_DEFENSE.md`
**Relevant scripts:** `scripts/02_chi_pd_level.R`, `scripts/03_chi_model_comparison.R`, `03_robustness_analysis.R`

---

## The Problem

### What the PD-Level CHI Does

The NYC CHI project estimates harm weights at the **PD level** — the combination of `offense_description1` (e.g., ROBBERY) and `pd_description` (e.g., ROBBERY, PERSONAL ELECTRONIC DEVICE). This is finer-grained than any published US Crime Harm Index, which typically weights at the offense category level.

To estimate the PD-level weight, the project uses **arrest charge distributions**. Within each `offense_description1 × pd_description` cell, the observed arrest charges (law_codes) are mapped to NYS Penal Law sentencing classes, and the **empirical mean CHI** across those charges becomes the PD-level weight.

### The Assumption

This procedure assumes that the **distribution of arrest charges within a PD cell is proportional to the distribution of offenses within that PD cell**. That is, if 60% of arrests in "ROBBERY, PERSONAL ELECTRONIC DEVICE" are charged as Robbery 3rd (Class D violent, 1,643 days) and 40% as Robbery 2nd (Class C violent, 3,380 days), the procedure assumes that 60% of *all complaints* in that cell involve conduct at the Robbery 3rd level and 40% at the Robbery 2nd level.

### Why the Assumption May Fail

Arrests are not a random sample of complaints. They are **filtered by clearance probability**, which varies by charge type within a PD cell. Potential mechanisms:

1. **Evidentiary asymmetry.** Within a PD cell, some charge levels produce stronger evidence than others. A robbery involving a firearm (higher charge) may leave more physical evidence, more cooperative witnesses, and more surveillance footage than a robbery involving verbal threats (lower charge). If so, the more serious conduct is *easier to clear*, and the arrest distribution overweights serious charges relative to their share of complaints.

2. **Investigative prioritization.** Police departments allocate investigative resources disproportionately to more serious incidents. A felony assault resulting in hospitalization gets more detective hours than one resulting in minor injury, even if both fall within the same PD code. This pulls the arrest distribution toward the serious end.

3. **Victim cooperation gradients.** Victims of more serious incidents may be more motivated to cooperate with investigations (or, conversely, more intimidated and less cooperative). The direction of this effect varies by offense type and is empirically uncertain.

4. **Plea bargaining and charge reduction.** Arrest charges may reflect prosecutorial expectations about what will survive plea negotiation, not the officer's assessment of the original conduct. This could push arrest charges either up (overcharging for bargaining leverage — Stuntz, 2001) or down (charging what's provable rather than what occurred).

### The Consequence

If the arrest distribution is biased relative to the offense distribution, the PD-level CHI weight is biased. The direction and magnitude of the bias are unknown *a priori* and may vary across PD cells. Specifically:

- **If serious charges are over-represented in arrests** (the most plausible direction for violent crimes), the PD weight is **biased upward** — overstating harm.
- **If serious charges are under-represented** (plausible for some property crimes where minor incidents are easier to clear), the PD weight is **biased downward** — understating harm.
- **If the bias varies across PD cells**, the relative ordering of PD weights may be distorted, potentially affecting block-level targeting decisions.

### What This Means for the Project

The arrest-distribution bias is a **threat to the internal validity** of the PD-level CHI weights. It does not affect the offense-level weights (which don't use arrest distributions) or the gun violence layer (which uses incident-level data). It affects only the *incremental refinement* from offense-level to PD-level granularity — the component of the CHI that distinguishes, say, "ROBBERY, PERSONAL ELECTRONIC DEVICE" from "ROBBERY, BANK."

The practical question is whether this bias is large enough to change **block-level targeting decisions** — whether the top-N harm blocks under PD-level weights differ meaningfully from the top-N blocks under offense-level weights or under alternative within-PD distributions.

---

## Theoretical Arguments for Why the Bias Is Tolerable

### Argument 1: The Arrest-Based Weight Is a Bayesian Update — Even a Biased Update Improves on the Prior

Without arrest data, the only option is the offense-level weight, which assigns every PD code within an offense category the *identical* CHI. That is the prior: "ROBBERY, PERSONAL ELECTRONIC DEVICE" = "ROBBERY, BANK" = "ROBBERY, BODEGA." The arrest charge distribution is data that updates this prior toward a PD-specific estimate.

The relevant question is not whether the arrest data is unbiased, but whether it is **informative** — whether it has any positive correlation with the true offense distribution. It almost certainly does. Even a noisy, biased signal moves the estimate closer to truth than the uniform assumption. The bias would have to be not merely present but *perverse* — systematically anti-correlated with the true distribution — to make the PD weight worse than the offense-level weight. That is not a plausible failure mode.

### Argument 2: The Sufficient Condition Is Monotonicity, Not Proportionality

The project does not need arrest distributions to be *proportional* to offense distributions. It needs them to be **monotonically related**: PD cells where arrests skew toward more serious charges should be PD cells where offenses also skew toward more serious charges.

This is a far weaker condition than unbiasedness. It holds as long as police effort does not systematically *invert* the seriousness ranking within PD cells. Monotonicity is sufficient because the downstream use is **ranking blocks**, and rank orderings are preserved under monotone transformations. Even if the PD weight for a given cell is biased by 15% in absolute terms, as long as it is correctly ordered *relative to other PD codes within the same offense category*, block rankings are unaffected.

### Argument 3: The PD Code Itself Bounds the Within-Cell Charge Variation

The PD classification is a **complaint-side partition** — assigned by the recording officer at the time of the complaint, before any arrest decision. PD codes like "ROBBERY, PERSONAL ELECTRONIC DEVICE" or "BURGLARY, RESIDENCE, NIGHT" narrow the charge range considerably compared to the parent offense category.

Within a PD cell, the charge range is typically **one or two felony/misdemeanor classes** — not the full spread from the minimum to maximum charge in the offense category. The maximum possible bias is therefore bounded by the sentencing gap between adjacent felony classes (e.g., Class C violent to Class D violent = 3,380 − 1,643 = 1,737 days), not by the full offense range (e.g., Robbery 1st at 5,475 to Robbery 3rd at 1,643 = 3,832 days). The within-PD variation being estimated is small relative to the between-offense variation that dominates block-level rankings.

### Argument 4: The Between-Offense Component Dominates Block Rankings

Block-level CHI rankings are driven primarily by **which offense categories** occur at a block, not by the within-PD charge distribution. A block with murders, rapes, and felony assaults will outrank a block with petit larcenies and misdemeanor assaults regardless of how PD-level weights are estimated.

The arrest-bias problem lives in the **residual** after the between-offense component is accounted for. This residual matters at the margin — for blocks near the targeting threshold — but not for the core identification of high-harm places. The robustness analysis already tests whether marginal blocks are stable across weight specifications.

### Argument 5: The Likely Bias Direction Is Conservative for Targeting

For serious violent crimes — the offenses that drive the top of the CHI distribution — there is reason to think arrest distributions **overweight the most serious charges**. More serious incidents (weapon used, victim hospitalized, fatality) generate more evidence, more investigative resources, more victim/witness cooperation, and more institutional pressure to clear.

If this holds, the arrest-based PD weight for high-harm PD codes is biased *upward*. Upward bias in the most serious categories is **conservative for targeting**: it directs resources to blocks that register as high-harm, which is the correct policy direction even if the magnitude is somewhat overstated. The dangerous bias would be *downward* — underestimating harm at blocks that genuinely need intervention. The clearance-effort gradient runs the other way.

### Argument 6: The "Least Worst" Comparison

The alternative to arrest-based PD weights is not some ideal unbiased estimator — it is **offense-level weights**, which assume zero within-category variation. That assumption is itself a strong substantive claim: that every PD code within robbery, or within felony assault, or within burglary carries exactly the same harm. The arrest-based PD weight, even if biased by differential clearance, represents a move *toward* the truth from a starting point that is certainly wrong.

The structure mirrors the broader "least worst" defense of the CHI itself (see `THE_LEAST_WORST_DEFENSE.md`): the relevant comparison is not between the PD weight and perfection, but between the PD weight and the concrete alternative of ignoring within-offense variation entirely.

---

## Connections to the Measurement Literature

| Source | Principle | Application |
|--------|-----------|-------------|
| **Sellin (1931)** | Procedural distance: data closer to the crime event is less contaminated by institutional filtering | Complaints are closer than arrests. But complaints lack charge specificity — they provide offense and PD code, not law_code. Arrest data is used *only for the information complaints cannot provide*. The PD code is the complaint-side contribution; the arrest charge is the necessary supplement. |
| **Biderman & Reiss (1967)** | All crime data are institutional products; no source provides an objective count | Both complaints and arrests are filtered. The question is not whether arrest data is pure, but whether two imperfect institutional filters (complaint classification + arrest charge) compound or correct each other. Since the PD code constrains the charge range *before* the arrest filter is applied, the compound bias is bounded. |
| **Stuntz (2001)** | Criminal law's pathological politics produce overcharging incentives | Arrest charges may be inflated relative to actual conduct due to prosecutorial incentives. This would bias PD weights upward — which is conservative for targeting (Argument 5). |
| **Saisana, Saltelli & Tarantola (2005)** | Uncertainty propagation: treat uncertain parameters as distributions, not point estimates | The within-PD charge distribution should be treated as *uncertain*, not *known*. Propagate that uncertainty to block rankings and report bounds. |
| **Ravallion (2012)** | When theory doesn't determine a design choice, test robustness | The arrest-distribution-as-proxy choice is exactly the kind of weakly-theorized design decision that demands robustness testing rather than theoretical resolution. |
| **Blumstein (1974)** | When components move together, weighting is irrelevant | If the *within-PD* charge distribution is relatively stable across space (PD cells have similar arrest-charge mixes regardless of location), the bias affects the *level* of PD weights but not the *spatial pattern* — and therefore not block rankings. |

---

## Potential Empirical Solutions

### Solution 1: Robustness Bracketing (Minimal — Requires No New Data)

**Method:** For each PD cell, compute three weights:
- **Floor:** the minimum charge-level CHI within the cell (assume all complaints involve the least serious charge)
- **Ceiling:** the maximum charge-level CHI within the cell (assume all complaints involve the most serious charge)
- **Arrest-based mean:** the current estimate

Run block-level targeting under all three. Report the overlap in top-N blocks across specifications.

**What it shows:** If the same blocks emerge under floor, ceiling, and mean weights, the arrest-distribution bias is **operationally irrelevant** — the full range of possible within-PD distributions produces the same targeting decision. If blocks differ, the analysis identifies exactly *which* blocks are sensitive to this assumption.

**Effort:** Low. Extends the existing `03_robustness_analysis.R` architecture.

**Strength:** Directly answers the operational question without requiring any assumption about the true distribution.

### Solution 2: Offense-Level vs. PD-Level Comparison (Minimal)

**Method:** Compare block-level targeting under offense-level weights (script 01, no arrest data used) to PD-level weights (script 02, arrest data used). Report rank correlation and top-N overlap.

**What it shows:** If offense-level and PD-level targeting are highly correlated, the *incremental contribution* of the PD-level refinement is small, and the arrest-distribution bias within that increment is a second-order concern. If they diverge substantially, the PD-level refinement matters — and the arrest-distribution bias becomes a first-order concern that requires further investigation.

**Effort:** Low. May already be available in `scripts/03_chi_model_comparison.R`.

**Strength:** Isolates the contribution of the contested component (PD-level arrest data) from the uncontested component (offense-level weights).

### Solution 3: PD-Cell Charge Range Audit (Descriptive)

**Method:** For each PD cell, report:
- Number of distinct charge types observed in arrests
- Min, max, and interquartile range of charge-level CHI weights
- The ratio of within-PD range to between-offense range

**What it shows:** PD cells with narrow charge ranges are **robust by construction** — no matter how biased the arrest distribution, the weight can't deviate far from the mean. PD cells with wide charge ranges are the vulnerable ones. If most PD cells (especially high-volume ones) have narrow ranges, the problem is empirically small.

**Effort:** Low. A diagnostic table from existing data.

### Solution 4: Clearance-Rate Diagnostics (Moderate)

**Method:** Compute PD-cell-specific clearance rates (arrests ÷ complaints). Cross-tabulate with charge range width.

**What it shows:** PD cells with *low clearance rates and wide charge ranges* are the cells where arrest-distribution bias is potentially largest and most consequential. PD cells with *high clearance rates* have arrest distributions closer to offense distributions (less filtering). PD cells with *narrow charge ranges* are insensitive to the bias regardless of clearance rate.

**Effort:** Moderate. Requires linking complaint and arrest counts at the PD level.

**Strength:** Identifies exactly which PD cells are most vulnerable, allowing targeted sensitivity analysis rather than global uncertainty.

### Solution 5: Complaint-Side Covariate Estimation (Novel — Significant Contribution)

**Method:** Use covariates available in the complaint data — weapon involvement, victim injury level, property value, location type — to estimate the within-PD charge distribution *independently of arrest outcomes*. Build a predictive model: P(charge class | complaint covariates, PD code) → expected CHI weight. Apply this model to *all* complaints, not just those resulting in arrest.

**What it shows:** If complaint-covariate-based PD weights are similar to arrest-based PD weights, the arrest distribution is a reasonable proxy despite the selection bias. If they diverge, the complaint-based weights are *closer to the crime event* (Sellin's principle) and should be preferred.

**Effort:** Moderate to high. Requires identifying which complaint fields predict charge severity and building a classification model.

**Strength:** This would be a **genuinely novel methodological contribution**. No CHI paper has used complaint-side covariates to estimate within-category charge distributions. It directly addresses the procedural-distance concern by moving the estimation closer to the crime event.

### Solution 6: External Validation Against Court Data (If Available)

**Method:** Obtain court disposition data (indictments, convictions, or sentences) for NYC. Compute within-PD charge distributions from court records and compare to arrest-based distributions.

**What it shows:** Court data is filtered differently from arrest data (prosecutorial discretion rather than clearance probability). If the two distributions converge, the arrest-based weight is corroborated by an independent institutional filter. If they diverge, the direction of divergence reveals whether the arrest bias is upward or downward.

**Effort:** High. Requires obtaining and linking external data.

**Caveat:** Court data introduces its own biases (Stuntz's pathological politics, plea bargaining, charge reduction). Convergence between two biased sources does not prove either is unbiased. But divergence is informative.

### Solution 7: Formal Selection Model (Most Ambitious)

**Method:** A Heckman-type two-stage approach:
1. **Selection equation:** model the probability of arrest within each PD cell as a function of complaint characteristics
2. **Outcome equation:** model the charge type conditional on arrest, corrected for selection

**What it shows:** Produces bias-corrected charge distributions.

**Effort:** High. Requires a credible exclusion restriction — a variable that predicts arrest probability but not charge type. Candidate instruments (e.g., precinct staffing levels, day-of-week, detective caseload) are debatable.

**Caveat:** The exclusion restriction is difficult to defend in this context. The model's assumptions may introduce more uncertainty than the bias it corrects.

---

## Recommended Strategy

**For the dissertation:** Combine the **theoretical argument** (Section 2 above — the five arguments for tolerability) with **Solutions 1–3** (robustness bracketing, offense-vs-PD comparison, charge range audit). These require no new data, fit within the existing analytical architecture, and directly answer the operational question: does the bias change targeting? If it doesn't, write a paragraph acknowledging the bias, cite the robustness results, and move on.

**For a methods paper or revision:** Add **Solution 5** (complaint-side covariate estimation). This turns a limitation into a contribution — instead of just defending against the bias, you develop a novel estimator that other CHI projects could adopt.

**Frame in the paper as:** "The PD-level weights are estimated from arrest charge distributions, which are subject to selection bias from differential clearance rates. We bound this bias empirically by showing that [floor/ceiling/offense-level] specifications produce [X% overlap / rank correlation of Y] in the top-N target blocks. The within-PD charge range is [narrow relative to between-offense variation], and the between-offense component accounts for [Z%] of block-level CHI variance. We conclude that the arrest-distribution bias is bounded, conservative in direction for the most policy-relevant offense categories, and does not materially affect targeting decisions."

---

## Summary Table

| Solution | Data Required | Effort | What It Answers |
|----------|--------------|--------|-----------------|
| 1. Robustness bracketing | Existing | Low | Does the full range of possible within-PD distributions change targeting? |
| 2. Offense vs. PD comparison | Existing | Low | How much does the PD refinement contribute beyond offense-level weights? |
| 3. Charge range audit | Existing | Low | How wide is the within-PD charge range? Where is vulnerability greatest? |
| 4. Clearance-rate diagnostics | Existing (linked) | Moderate | Which PD cells are most susceptible to arrest-distribution bias? |
| 5. Complaint-covariate estimation | Existing (complaint fields) | Moderate–High | Can you estimate charge severity without using arrest outcomes? |
| 6. Court data validation | External | High | Do independent institutional filters converge on similar PD weights? |
| 7. Formal selection model | Existing + instrument | High | Can you estimate and correct the selection bias directly? |
