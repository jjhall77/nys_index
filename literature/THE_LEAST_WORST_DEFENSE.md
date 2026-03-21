# The "Least Worst" Defense: Why Imperfect CHI Weights Are Better Than the Alternative

**Date:** 2026-03-21
**Author:** John Hall
**Companion to:** `CHI_synthesis.md`, `BIBLIOGRAPHY_AND_GAP_ANALYSIS.md`, `INDICES_MEASUREMENT_COMMENSURABILITY_synthesis.md`

---

## 1. The Critique

Any honest defense of Crime Harm Index weights must begin by taking the strongest objections seriously. The critiques are not trivial, and several draw on deep problems in social measurement theory.

### Within-Category Heterogeneity

The most intuitive objection is that statutory crime categories are crude containers. "Robbery" encompasses everything from a verbal threat to extract a wallet to an armed attack that leaves the victim permanently disabled. A CHI that assigns a single weight to "robbery" flattens this enormous variation into a point estimate. The same problem recurs across every offense category: the legal label is a bureaucratic convenience, not a natural kind. Critics argue that any weight derived from these categories inherits their imprecision and projects false exactitude onto what is fundamentally a rough grouping.

### Sentencing Ranges Are Politically Determined

Statutory sentencing ranges reflect legislative bargaining, moral panics, interest-group pressure, and path dependence far more than they reflect any principled calibration of harm. Drug offenses are the most obvious case — the crack/powder cocaine disparity persisted for decades despite its acknowledged irrationality — but the problem is general. Sentencing maxima for property crimes, sexual offenses, and violent crimes have shifted dramatically over time without corresponding shifts in the underlying conduct. Using these ranges as the foundation for a harm metric means building on political sand.

### Magnitude Estimation Fails Ratio-Scale Tests

The psychophysical tradition of crime seriousness scaling, running from Sellin and Wolfgang (1964) through the National Survey of Crime Severity (Wolfgang et al., 1985), sought ratio-scale measurement of perceived harm. Parton, Hansel, and Stratton (1991) demonstrated that magnitude estimation results are sensitive to the modulus, the anchoring stimulus, and the instructions given to respondents. The resulting scales do not reliably satisfy the properties required for ratio-level measurement. If survey-based weights cannot achieve ratio scale, the entire enterprise of multiplying crime counts by seriousness scores and summing them becomes mathematically questionable.

### Overcriminalization Distorts the Statutory Landscape

Stuntz (2001) and Kleinfeld (2019) document the relentless expansion of criminal codes. Legislatures add offenses and increase penalties far more readily than they rationalize or repeal them. The result is a statutory landscape in which the number of distinguishable offenses, the overlap between them, and the penalty ranges attached to them reflect prosecutorial convenience and political signaling rather than a coherent theory of proportionality. A CHI that takes this landscape at face value inherits all of its distortions.

### Arrow's Impossibility Theorem

Arrow (1951) proved that no aggregation procedure can simultaneously satisfy a small set of reasonable axioms (unrestricted domain, Pareto efficiency, independence of irrelevant alternatives, non-dictatorship) when combining ordinal preferences. The CHI is a composite index that aggregates heterogeneous crime types into a single number. While the CHI uses cardinal weights rather than ordinal rankings, the deeper lesson of Arrow's theorem applies: there is no uniquely correct way to collapse a multi-dimensional phenomenon into a single dimension. Every composite index embeds contestable value judgments in its aggregation rule.

### The Compensability Problem

A linear CHI implies full compensability between crime types. If murder carries a weight of 7,300 days and bicycle theft carries a weight of 2 days, then the index treats 3,650 bicycle thefts as equivalent in total harm to one murder. No serious person believes this. The problem is structural: any additive index permits these trade-offs by construction. Non-linear aggregation or lexicographic rules could prevent them, but at the cost of the index's simplicity and operational tractability.

### The Dark Figure

Not all crimes are reported at equal rates. Homicide reporting approaches completeness; petty theft reporting is far lower. If a CHI is computed from police-recorded data, it systematically undercounts low-reporting-rate offenses. This is not merely a missing-data problem — differential reportability is correlated with offense seriousness in complex ways (sexual offenses are both serious and underreported). The resulting index reflects not just the distribution of harm but the distribution of victims' willingness and ability to engage with the police.

---

## 2. The "Least Worst" Rejoinder

These critiques are real. None of them, however, leads to the conclusion that crimes should be counted equally. The following ten arguments, drawn from the CHI literature, collectively establish that imperfect weighting dominates the alternative.

### 2.1 Sherman (2020) — The Cambridge Consensus

The Cambridge Harm Index Consensus statement, organized by Sherman, directly confronts the heterogeneity problem rather than evading it. Sherman frames the CHI as a deliberate "least worst" choice, acknowledging that any single weight for a crime category is an oversimplification but arguing that the oversimplification is vastly preferable to the implicit alternative.

The key formulation: "The moral ground for such an imperfect process is that the result will be so very much better than the current systems. The perfect can become the enemy of the better but arguably should not hold back progress."

This is not a claim that CHI weights are correct in any deep sense. It is a claim about relative improvement — that the distance between CHI-weighted analysis and unweighted counts is far greater than the distance between any two reasonable weighting schemes. Sherman treats within-category heterogeneity as a feature of reality that the CHI partially addresses rather than a fatal flaw that disqualifies the enterprise.

### 2.2 Sherman, Neyroud & Neyroud (2016) — The Greatest Argument

Sherman, Neyroud, and Neyroud state it most directly: "Whatever the imperfections of a CHI approach, the greatest argument for it is its improvement over raw crime counts."

They provide the arithmetic that makes the case concrete. In England and Wales, 308,325 recorded shoplifting offenses were counted alongside 551 homicides. Under unweighted counts, shoplifting exerted approximately 560 times more influence on the total crime figure than murder. Under any plausible weighting scheme, the relative influence reverses dramatically. The example is deliberately chosen for its absurdity — no police executive, no policymaker, and no member of the public believes that shoplifting volume should dominate resource allocation discussions to that degree. Yet that is precisely what unweighted counts deliver.

### 2.3 Van Ruitenburg & Ruiter (2022) — The Scoping Review Consensus

Van Ruitenburg and Ruiter conducted a systematic scoping review of CHI applications and found a near-universal consensus among researchers who have engaged with the problem. Their summary of the literature's judgment on unweighted counts: "the traditional way of counting the number of crimes provides an inadequate basis for crime policy and is sometimes even thought of as a 'fruitless exercise.'"

This is not one researcher's opinion but a distillation of the field's collective assessment. The scoping review format means this judgment emerges from examining dozens of independent studies across multiple countries. The convergence is notable precisely because the researchers disagree about many implementation details — which weights to use, which data source to draw from, how to handle temporal variation — while agreeing that the unweighted baseline is unacceptable.

### 2.4 Curtis-Ham (2022) — Complement, Not Replacement

Curtis-Ham reframes the entire debate by arguing that the CHI should be understood as a supplement to crime counts rather than a replacement for them. This framing dissolves much of the perfectionist critique: if the CHI need not carry the full weight of being the sole measure, its imperfections become less damaging.

Curtis-Ham's formulation: "crime harm indices provide a valuable second lens through which to understand crime and policing demand." The empirical finding that supports this framing is that high-harm locations, offenders, and victims frequently differ from those identified by unweighted counts. The CHI reveals patterns that counts cannot see, and counts capture volume dynamics that the CHI may obscure. The two measures are complementary, not competitive.

This is operationally significant. A police agency using both counts and CHI scores will make better decisions than one using either measure alone. The relevant standard for the CHI is therefore not "Is it a perfect harm metric?" but "Does it add information that counts alone do not provide?" The answer is unambiguously yes.

### 2.5 Boivin (2014) — The Canadian City Rankings

Boivin applied harm weights to Canadian city crime data and demonstrated that the practical consequences of not weighting are dramatic and potentially dangerous for policy. Under unweighted counts, Prince George — a small city whose crime volume was dominated by property offenses — ranked among Canada's most dangerous cities. When crimes were weighted by seriousness, the rankings shifted radically: Toronto moved from 75th to 2nd most dangerous; Montreal moved from 45th to 3rd.

The implication is stark. Unweighted counts were directing national attention and potentially federal resources toward a small city with a high volume of low-harm crime while obscuring the concentrated serious violence in Canada's two largest cities. Whatever the theoretical imperfections of the weighting scheme, the practical consequences of not weighting were dramatically misleading — and misleading in a direction that could cost lives by misallocating violence-prevention resources.

### 2.6 The CPI Analogy

Sherman has analogized the CHI to the Consumer Price Index, and the comparison is instructive. The CPI also uses imperfect weights — no market basket perfectly represents every household's consumption pattern. The weights are periodically revised, the substitution bias is well-documented, and entire research programs exist to improve the methodology. Yet nobody seriously argues that the CPI should be abandoned because its weights are imperfect, or that the alternative of tracking all prices with equal weight would be superior.

The analogy highlights that we routinely accept imperfect composite indices in domains with high policy stakes — monetary policy, inflation targeting, cost-of-living adjustments to wages and benefits. The demand for theoretical perfection from the CHI is inconsistent with the standards applied to analogous instruments elsewhere. We do not demand theoretical perfection from other composite indices in wide policy use; requiring it from the CHI alone amounts to a double standard that serves the status quo.

### 2.7 Ratcliffe (2015) — Harm-Focused Policing

Ratcliffe developed a US-based harm index using federal sentencing guidelines and argued for its integration into police strategy and resource allocation. His position is pragmatic: any reasonable weighting scheme that distinguishes serious from minor crime represents an operational improvement for police resource allocation, even if the specific weights are debatable.

The emphasis on "any reasonable" is deliberate. Ratcliffe's claim is that the space of defensible weighting schemes is large and that all points within it outperform the unweighted baseline. This is an empirical claim about the robustness of the improvement, not a theoretical claim about the correctness of any particular set of weights. If the ranking of hotspots, offenders, or victims is approximately stable across the range of plausible weighting schemes — as the robustness analyses in this project suggest — then the exact weights matter far less than the decision to weight at all.

### 2.8 Mitchell (2019) — The Sacramento Experiment

Mitchell's Sacramento study provides the strongest pragmatic argument in the literature. Applying CHI weights to experimental data, Mitchell found that the harm index detected treatment effects from a policing intervention that raw crime counts missed entirely. The unweighted analysis showed no statistically significant effect; the CHI analysis revealed a meaningful reduction in harm.

The implications are profound. If police agencies evaluate interventions using only unweighted counts, they will abandon effective programs because the evaluation tool cannot detect their effects. The imperfect tool found something the supposedly neutral alternative could not see. This is not a hypothetical — it is a documented case in which reliance on unweighted counts would have led to a worse policy decision than reliance on imperfect CHI weights.

### 2.9 Harinam, Bavcevic & Ariel (2022) — Even Skeptics Concede

Harinam, Bavcevic, and Ariel are the closest the literature comes to CHI skeptics. Their title — cautioning researchers not to abandon count-based models — appears to push back against the CHI movement. But the substance of their argument is more nuanced. Their actual conclusion: "Abandoning count-based models in spatial analysis can lead to an incomplete picture, and both models are needed."

This is not an argument against CHIs. It is an argument against CHIs alone — which is precisely the complement framing that Curtis-Ham also advances. Harinam and colleagues demonstrate that counts and CHI scores capture different spatial patterns, and that discarding either one loses information. Their position, properly understood, is a "good enough plus counts" argument rather than an anti-CHI argument. The most prominent skeptics in the literature do not claim that weighting is worse than not weighting; they claim that weighting is insufficient by itself. That concession is, in substance, a defense of the CHI as one essential component of a multi-measure approach.

### 2.10 Ignatans & Pease (2016) — Playing the Weighting Game

Ignatans and Pease developed an alternative CHI weighting based on victim survey data rather than sentencing guidelines, arguing that victim-experienced harm might diverge from legislatively assigned severity. Their methodological critique of sentencing-based weights is substantive and worth engaging with on its own terms.

But the framing of their paper is revealing. The title — "Taking Crime Seriously: Playing the Weighting Game" — implicitly accepts that the game must be played. Their critique was about which weighting to use, not whether to weight. They agreed with the fundamental premise that unweighted counts are deeply problematic and that some form of differential weighting is necessary. The debate they entered is an intra-CHI debate about implementation, not a debate about whether the CHI enterprise is justified. When even the critics of a particular weighting scheme accept the necessity of weighting, the case for the general approach is strong.

---

## 3. The Strongest Formulation

The ten arguments above converge on a single logical structure. The relevant comparison is not between the CHI and some ideal harm metric, but between the CHI and the implicit weighting scheme currently in use — which assigns a weight of 1 to every crime from petit larceny to murder. That implicit scheme is not neutral; it is a strong and indefensible substantive claim that all crimes cause equal harm. Any sentencing-derived weighting, however imperfect its democratic pedigree, represents a massive improvement over that baseline.

This formulation reframes the burden of proof. The defender of unweighted counts must explain why equal weighting — a scheme that treats shoplifting and homicide as interchangeable units — is preferable to any system that distinguishes between them. That is an extraordinarily difficult position to defend, and no one in the literature attempts it. The critics of CHI weights are not defenders of equal weighting; they are advocates for better weighting. Their critiques, properly understood, strengthen the case for the CHI enterprise while improving its implementation.

---

## 4. Implications for the NYC CHI Project

The "least worst" defense is not merely an abstract philosophical position. It has direct implications for the design choices embedded in this project's Crime Harm Index for New York City.

### Statutory Midpoints as Democratic Baseline

This project derives CHI weights from the midpoints of New York State Penal Law sentencing ranges. The midpoint is a deliberate choice: it avoids the extremes of the statutory range while anchoring the weight in democratically enacted legislation. This approach is resistant to the Lewis et al. (2024) equity critique because it draws on the statutory framework — the product of legislative deliberation — rather than on judicial sentencing outcomes, which reflect the documented disparities of the criminal justice system. The weights are imperfect for all the reasons enumerated in Section 1, but they are grounded in a defensible institutional source.

### PD-Level Granularity Reducing Within-Category Heterogeneity

The within-category heterogeneity problem is the single most intuitive critique of CHI weights. This project addresses it directly by computing weights at the PD (police description) level rather than the offense level. Instead of assigning one weight to "robbery," the index distinguishes between PD-level subcategories that correspond to different charging patterns and therefore different positions within the sentencing range. This does not eliminate heterogeneity — it cannot — but it substantially reduces it. The PD-level CHI may be the finest-grained operational harm index in the US literature.

### Robustness Analysis Showing Targeting Stability

Ratcliffe's claim that all reasonable weighting schemes outperform the unweighted baseline is an empirical proposition that can be tested. This project's robustness analysis examines whether block-level targeting is stable across multiple CHI specifications: low, mid, and high sentencing weights; inclusion and exclusion of outside-harm incidents; and different thresholds for the number of targeted blocks. If the top-N targeted blocks substantially overlap across these specifications — and the preliminary evidence suggests they do — then the exact weights matter less than the decision to weight. This directly operationalizes the "least worst" argument: the policy output is robust to the acknowledged imperfections of the inputs.

### Complement Framing

Following Curtis-Ham (2022) and Harinam, Bavcevic, and Ariel (2022), this project presents the CHI as a complement to crime counts rather than a replacement. Block-level analyses report both volume (counts) and severity (CHI scores), and the divergences between the two rankings are treated as substantively informative rather than as evidence of measurement failure. A block with high counts but low CHI scores tells a different story — and demands a different intervention — than a block with low counts but high CHI scores. Both measures are necessary; neither is sufficient alone.

### Substitution Approach for Gun Violence

The gun violence substitution methodology (v2) addresses a specific form of within-category heterogeneity: the gap between arrest-based complaint data and the actual severity of shooting incidents. Fatal shootings are scored at Murder 2nd (7,300 days) and non-fatal shootings at Attempted Murder 2nd (5,475 days), with these scores replacing — not supplementing — the arrest-based CHI for matched incidents. This prevents double-counting while ensuring that the most serious violent events receive weights commensurate with their severity. The approach is novel in the CHI literature and represents a direct response to the heterogeneity critique as it applies to gun violence.

### Transparent Trade-Off Ratios

Espeland and Stevens (1998) argue that commensuration — the reduction of different qualities to a common metric — is a social process with political consequences. The CHI is an explicit act of commensuration, and its embedded trade-off ratios (e.g., how many misdemeanor assaults "equal" one homicide in index terms) should be published transparently rather than hidden in methodology appendices. This project commits to that transparency, publishing the full lookup table and making the implied trade-offs available for scrutiny. Transparency does not make the trade-offs correct, but it makes them contestable — which is the appropriate standard for a democratic society's measurement instruments.

---

*This document is a companion to the literature synthesis and bibliography documents generated for the NYC Crime Harm Index project. It draws on the CHI literature corpus in `literature/processed/` and is intended to support the methodological defense section of the project's written output.*
