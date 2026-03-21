# Crime Harm Index Literature Synthesis and Analysis

**Date generated:** 2026-03-21 (updated 2026-03-21 with 8 additional papers)
**Corpus:** 30 processed markdown files (from 27 unique PDFs + 3 duplicates) in `literature/processed/`
**Research context:** NYC Crime Harm Index project using NYPD complaint, arrest, and shooting data geocoded to street segments and blocks, with CHI weights derived from NYS Penal Law sentencing midpoints.

---

## Section 1 — Historical Evolution and Intellectual Lineage

### Phase 1: Theoretical Foundations (1964–2006)

The intellectual roots of crime harm measurement trace to Sellin and Wolfgang's (1964) *The Measurement of Delinquency*, which first proposed that crimes should be weighted by seriousness rather than counted equally. This foundational insight — that a murder and a bicycle theft cannot occupy the same unit of analysis — persisted as an academic talking point for four decades without producing a standardized operational tool.

During this period, the most philosophically rigorous attempt to ground harm measurement came from **von Hirsch and Jareborg (1991)**, who proposed a "living-standard analysis" that gauges criminal harm by the degree to which a crime reduces the victim's standard of living across four levels: subsistence, minimal well-being, adequate well-being, and enhanced well-being. Their framework used a two-stage assessment: first, identify which "living-standard interests" (physical integrity, material support, freedom from humiliation, privacy/autonomy) the crime invades; second, judge how far and how durably the invasion reduces the victim's living standard. The result was a four-band ordinal scale — from offences touching enhanced well-being (e.g., minor property crimes) to those that extinguish subsistence (homicide). Von Hirsch and Jareborg explicitly designed this as a principled alternative to empirical seriousness scaling (which they criticized for circular reliance on existing sentencing practice) and as a sentencing-proportionality anchor rather than a policing metric. The framework is intellectually compelling but, crucially, not operational: it requires case-by-case judgment about living-standard impact and provides an ordinal ranking rather than a cardinal scale suitable for aggregation. It nevertheless remains the most serious philosophical attempt to answer *what* sentencing weights are supposed to measure, and Greenfield and Paoli (2013) explicitly build on it.

**Greenfield and Paoli (2013)** represent the culmination of this theoretical tradition. Their framework for assessing harms of crime — with taxonomies of bearers (individuals, private entities, government, environment), harm types (functional integrity, material interest, reputation, privacy), and ordinal severity scales — is intellectually comprehensive but, by their own admission, "daunting" to apply. The framework explicitly avoids sentencing data, arguing that criminal justice outcomes are too crude to capture the multidimensional nature of harm. This position set up the central tension that the CHI movement would later resolve pragmatically: theoretical completeness versus operational utility.

### Phase 2: The Sherman Manifesto and the Cambridge CHI (2007–2016)

**Sherman (2007), "The Power Few,"** reframed crime harm measurement from a philosophical exercise into an operational imperative for evidence-based policing. The paper's central empirical claim was that across every domain — offenders, victims, places, and even police units — the distribution of harm follows a steep power curve: a tiny fraction of units accounts for the vast majority of total harm. Sherman illustrated this with offenders (5% of a Philadelphia birth cohort caused ~70% of all criminal harm), victims (a small number of repeat victims in domestic abuse absorb most harm), and places (micro-locations generating wildly disproportionate serious crime). The key rhetorical move was connecting this distributional fact to resource allocation: if a small number of offenders, victims, and places account for the vast majority of harm, then counting all crimes equally actively misleads police decision-making. Sherman proposed a "Total Harm Index" that would weight crimes by seriousness to identify the power few targets where intervention resources would produce the greatest harm reduction. This was the conceptual blueprint for the CCHI that followed a decade later.

**Sherman (2013), "The Rise of Evidence-Based Policing: Targeting, Testing, and Tracking,"** extended the power-few concept into a comprehensive operational framework. The paper introduced the "Triple-T" strategy: **Target** (use harm-weighted analysis to identify the highest-harm people, places, and situations), **Test** (use randomized controlled trials to evaluate interventions), and **Track** (use ongoing measurement to monitor whether harm is actually being reduced). Sherman articulated the "fungibility fallacy" — the assumption embedded in unweighted crime counts that all crimes are interchangeable — and argued that this fallacy fundamentally corrupts resource allocation, trend analysis, and performance measurement. The paper proposed a seven-step CHI construction process: (1) identify data source, (2) select weight basis, (3) assign weights, (4) define exclusion rules, (5) aggregate, (6) decompose, (7) track over time. This became the operational template that Sherman et al. (2016) formalized.

**Sherman, Neyroud, and Neyroud (2016)** operationalized these insights as the **Cambridge Crime Harm Index (CCHI)**. The design choices were deliberate and parsimonious:

- **Weight source:** Sentencing Council "starting point" for each offence — the recommended sentence for a first offender with no aggravating or mitigating factors
- **Unit:** Days of recommended imprisonment
- **Exclusions:** Proactively detected crime (drugs, traffic, shoplifting detected by store security), historical offences reported in the current year
- **Evaluation criteria:** Democratic (derived from elected government's sentencing policy), reliable (consistently applied), affordable (no new data collection), valid (measures harm to victims independent of offender characteristics), operational (simple to compute)

The foundational empirical demonstration was powerful: UK crime counts dropped 37% from 2002–2012, but CHI dropped only 21% — crime counts had overstated the improvement in public safety by 76%. Violent offences constituted 16% of crime volume but 76% of CHI value. The gap between counts and harm was not a statistical curiosity; it was a policy distortion.

### Phase 2b: Parallel Developments — Canada's CSI and Domestic Abuse Applications (2009–2015)

Two important developments preceded the international CHI wave and deserve separate treatment because they represent independent streams that the CCHI later absorbed or cited.

**Wallace, Turner, Matarazzo, and Babyak (2009)** introduced the **Canadian Crime Severity Index (CSI)** — arguably the first operational national harm-weighted crime index. Developed by Statistics Canada, the CSI weights each offence type by two factors: the **incarceration rate** (proportion of convicted offenders sentenced to prison) and the **average sentence length** for those imprisoned. The product — a severity weight reflecting both the probability and severity of punishment — is applied to police-reported crime volumes to produce a single summary index. The CSI was benchmarked to 2006 as a base year (index = 100), decomposed into violent and non-violent sub-indices, and computed at national, provincial, and census-metropolitan-area levels. The key finding: between 1998 and 2007, the CSI declined 22% while total crime counts fell only 7% — the reverse of the UK pattern where counts overstated improvement. In Canada, the severity-weighted decline was *steeper* because the most serious crimes dropped fastest. The CSI has been published annually since 2009, making it the longest-running national harm index. Methodologically, the CSI differs from the CCHI in using actual sentencing outcomes (incarceration rate × sentence) rather than guidelines, making it vulnerable to the Lewis et al. (2024) feedback-loop critique in principle, though the population-level averaging mitigates individual-case bias.

**Bland and Ariel (2015)** produced the first CHI application to **domestic abuse**, using the Cambridge Crime Harm Index to analyze escalation patterns in reported domestic violence in Suffolk, England. Their core finding — that approximately 80% of total domestic abuse harm was concentrated in fewer than 2% of victim-offender dyads — was a striking demonstration of the power-few principle applied to a specific crime domain. The paper used the CCHI "menu" (a detailed appendix mapping each offence to its sentencing-guideline starting point in days) that became widely cited as a reference implementation. Bland and Ariel showed that harm-weighted analysis of domestic abuse revealed escalation dynamics invisible to count-based metrics: dyads that generated many low-level incidents could be distinguished from those generating fewer but far more serious events. The targeting implication was direct: resources for domestic abuse intervention should be allocated based on cumulative harm trajectories, not on frequency of calls.

### Phase 3: International Replication and Adaptation (2017–2020)

The CCHI triggered a wave of national adaptations, each confronting the same core problem: how to translate the Cambridge sentencing-guidelines approach into jurisdictions with different legal systems.

**Jurisdictions without sentencing guidelines** had to improvise:

- **Denmark** (Andersen & Mueller-Johnson, 2018): Used prosecutor sentencing recommendations from the Director of Public Prosecutions, validated by five prosecutors (Cronbach's α = 0.93). Covered 93% of Criminal Code offences. Key finding: crime counts dropped 14% from 2011–2016, but Danish CHI *rose* by 0.5% (6% including rapes) — a complete reversal of the crime trend narrative.

- **New Zealand** (Curtis-Ham & Walton, 2017): Used the 15th percentile of actual sentence distributions as a proxy for first-offender starting points. Produced CHI weights for 6,412 offence codes. Sex offences: 1% of volume, 30% of harm.

- **Western Australia** (House & Neyroud, 2018): Used median actual court outcomes for first-time offenders across 2.2 million court records. Found crime counts and WACHI moved in opposite directions in 2 of 4 year-over-year comparisons.

- **Sweden** (Karrholm, Neyroud & Smaaland, 2020): Compared five methods (judge panels, statutory max, statutory min, average of max/min, average actual sentences). Average actual sentences provided greatest sensitivity. This choice later drew criticism from Sarnecki (2021).

**Jurisdictions with structured sentencing** adapted more directly:

- **California** (Mitchell, 2019): Used maximum statutory sentences from the California Penal Code, since California lacks starting-point guidelines.

- **Philadelphia/Pennsylvania** (Ratcliffe, 2015; Ratcliffe & Kikuchi, 2019): Used the Pennsylvania offense gravity score (1–14 ordinal scale), and later sentence-based scores from PA sentencing guidelines.

**Later additions** extended the model to non-Western contexts:

- **Japan** (Ohyama et al., 2022): Used minimum imprisonment terms from the Japanese Penal Code, with fine-to-imprisonment conversions based on minimum wage.

- **Brazil** (Silva, Faria & Alves, 2025): Used minimum legal penalties from the Brazilian Penal Code. First CHI application in Latin America.

### Phase 4: The Cambridge Consensus and Institutionalization (2020–present)

Sherman and Cambridge University Associates (2020) published "How to Count Crime: the Cambridge Harm Index Consensus," a manifesto signed by senior criminologists, statisticians (David Spiegelhalter), and former Metropolitan Police Commissioners. This proposed a seven-series statistical reporting framework:

1. A Crime Harm Index (CHI) for current-year victim-reported crimes
2. Crime counts by category (inputs to CHI)
3. A Historic Offences Index (HOCHI) for prior-year offences reported currently
4. A Proactive Policing Index (PPI) for police-detected crimes
5. A Company-Detected Crime Harm Index (CDCHI)
6. A Harm Detection Fraction (HDF) — proportion of CHI with detections
7. Detection rates per 100 by category

The Consensus also specified three things **not** to count: total offence rates, total detection rates, and average sentences (because offender prior records contaminate them). This document marks the transition from "should we weight crime by harm?" to "how should we implement harm-weighted counting as standard practice?"

The scoping review by van Ruitenburg and Ruiter (2023) — the most comprehensive assessment of the CHI literature — confirmed that CHIs were being adopted across at least 13 countries and applied to hot spot analysis, offender targeting, victim prioritization, and trend analysis. Their review of 141 documents confirmed the consistent finding: harm is more concentrated than volume across offenders, victims, and places.

### The Current Frontier

The frontier questions are now:

1. **Which sentencing metric is best?** Guidelines vs. actual sentences vs. statutory maxima/minima — and what are the equity implications of each choice?
2. **How to handle gun violence and multi-victim events** in a sentencing-based framework?
3. **Spatial aggregation:** What is the right geographic unit for harm measurement, and how robust are targeting decisions to CHI specification choices?
4. **Feedback loops and equity:** Does harm-weighted policing amplify racial disparities?

---

## Section 2 — Current Conflicts and Debates

### Debate 1: Sentencing Guidelines vs. Actual Sentences

**The camps:**

- **Guidelines-based (Sherman et al., 2016; Sherman & Cambridge Associates, 2020; Lewis, Pina-Sanchez & Birks, 2024):** The "starting point" sentence for a first offender is the purest measure of harm to victims. Actual sentences are contaminated by offender prior records, plea bargaining, and racial disparities. "A murder victim is just as dead when they are killed by a first offender as by a career criminal" (Sherman et al., 2016).

- **Actual-sentences-based (House & Neyroud, 2018; Karrholm et al., 2020; Curtis-Ham & Walton, 2017):** Many jurisdictions lack sentencing guidelines. Actual sentences are the only available data. With appropriate filtering (first offenders, median/15th percentile), actual sentences can approximate a "pure" harm value. The WACHI uses median sentences for first-time offenders; the NZ CHI uses the 15th percentile as a proxy for the minimum first-offender outcome.

- **Critical view (Sarnecki, 2021):** Average actual sentences are deeply problematic because most sentences are non-custodial. In Sweden, only 15% of sanctions involve imprisonment. Computing average prison terms for crime types where prison is rare inflates harm scores for high-volume low-harm offences (e.g., molestation: 16 of 160,000 cases resulted in prison). Legislative changes and increased punitiveness also contaminate trend analysis.

- **Victim-perception-based (Ignatans & Pease, 2016):** Ignatans and Pease proposed a fundamentally different approach to CHI weighting: using **victim-assessed seriousness** from the Crime Survey for England and Wales (CSEW), where victims rate the seriousness of the crime they experienced on a 1–20 scale. Their argument was that sentencing-based weights reflect the state's valuation of harm, not the victim's experience. Using CSEW data, they computed mean seriousness scores by crime type and showed that the victim-perception ranking diverges from the sentencing-guideline ranking in important ways — particularly for crimes with high emotional/psychological impact (e.g., domestic violence, stalking) that receive lower statutory sentences. Ignatans and Pease argued that the CHI should incorporate victim experience rather than relying solely on the legislature's sentencing calculus. This position directly challenges the Sherman et al. (2016) "democratic legitimacy" argument by countering that victims themselves are the most democratic source of harm information. However, the approach faces the psychometric problems identified in the broader seriousness-scaling literature (Parton et al., 1991; Pease et al., 1975): perception scales lack ratio properties, are sensitive to framing, and produce non-additive scores.

**Assessment:** The guidelines-based approach is theoretically cleaner, but the pragmatic reality is that most countries lack the Sentencing Council infrastructure of England and Wales. Ignatans and Pease's victim-perception alternative raises an important question about *whose* valuation of harm the CHI should reflect, but faces serious measurement-theoretic obstacles. The NYC project's use of NYS Penal Law sentencing midpoints — the midpoint of the statutory sentencing range for each felony/misdemeanor class — is a principled middle ground: it uses statutory ranges (democratic, transparent, independent of actual sentencing) while avoiding the maximum-sentence approach that Mitchell (2019) acknowledged reduces sensitivity.

**NYC project angle:** This project can directly contribute to this debate by demonstrating whether a statutory-midpoint approach produces meaningfully different targeting decisions than a guidelines-starting-point or actual-sentences approach. The robustness analysis (script `03_robustness_analysis.R`) testing low/mid/high CHI weight ranges already begins this work.

### Debate 2: Harm Spots vs. Hot Spots — How Different Are They?

**The camps:**

- **Substantial divergence (Weinborn et al., 2017; Ratcliffe, 2015; Fenimore, 2019; Silva et al., 2025):** Harm spots and hot spots identify meaningfully different places. Harm-weighted analysis reveals critical areas that frequency-based mapping misses entirely. In Belo Horizonte, harm spots revealed high-harm areas outside central areas that hot spots overlooked (Silva et al., 2025). In Philadelphia, harm profiles varied dramatically across police districts even when volume was similar (Ratcliffe, 2015). **Fenimore (2019)** produced the **first US harmspot mapping study**, applying three weighting scales (CCHI-adapted, FBI NIBRS-based, and a proportional scale) to Washington DC crime data and comparing the resulting harmspot maps to traditional hotspot maps. Using kernel density estimation and spatial overlap analysis, Fenimore showed that harmspots and hotspots identified substantially different locations across all three weighting schemes, with overlap ranging from only 40–65% depending on the threshold. Critically, Fenimore also tested the sensitivity of harmspot identification to the choice of weighting scale and found moderate but non-trivial differences — reinforcing the need for robustness testing across specifications. The DC study fills a key gap as the first US evidence that the Weinborn et al. (2017) finding generalizes beyond the UK.

- **Convergence in low-crime contexts (Ohyama et al., 2022):** In low-crime settings (Tokyo), the cumulative impact of minor crimes can dominate total harm, making CHI results converge with raw counts. The distinction between harm spots and hot spots may be context-dependent.

**Assessment:** The divergence finding is now robust across multiple countries and crime contexts: the UK (Weinborn et al., 2017), US-DC (Fenimore, 2019), US-Philadelphia (Ratcliffe, 2015), and Brazil (Silva et al., 2025). The convergence finding in Tokyo is important but reflects a very different crime profile. For NYC, we should expect substantial divergence, particularly at the block level where shootings and serious assaults create extreme harm concentration.

**NYC project angle:** The block-level aggregation in this project, combined with the gun violence substitution approach, is exactly the right design to test harm-spot vs. hot-spot divergence at a finer spatial grain than any existing study. Fenimore (2019) operates at the grid-cell level; this project's block-level analysis would be the finest-grained US harmspot study.

### Debate 3: Should Police-Detected Crime Be Included?

**The camps:**

- **Exclude (Sherman et al., 2016; Sherman & Cambridge Associates, 2020):** Proactively detected crimes measure police investment, not public safety. Including them creates perverse incentives: more knife arrests → "knife crime is up." Policing is an independent variable that cannot simultaneously be a dependent variable.

- **Include selectively (Andersen & Mueller-Johnson, 2018; Ratcliffe, 2015):** For targeting purposes, excluding narcotics and weapons offences reduces the accuracy of offender harm scores. An appendix to the CHI containing police-initiated offences can be used for targeting without contaminating trend analysis. Ratcliffe (2015) goes further, proposing that police stops and traffic accidents should also be incorporated into a broader "community harm" framework.

**Assessment:** Sherman's exclusion principle is correct for trend analysis and accountability metrics. For operational targeting — especially offender triage — Ratcliffe and Kikuchi's (2019) approach of including arrest-based offences with time-decay functions is more practical. The NYC project's use of complaint data (victim-reported) as the base, with shooting data layered via substitution, aligns with Sherman's principle while incorporating the most serious proactive data (shootings) through a carefully controlled mechanism.

### Debate 4: Equity and Feedback Loops

**The camps:**

- **Risk of amplifying disparities (Lewis, Pina-Sanchez & Birks, 2024):** Indices based on actual sentencing data (like the ONS CSS) embed racial disparities because unjustified sentencing gaps by ethnicity inflate severity scores for crime types where minorities are over-represented. This can create negative feedback loops: deploy more to high-harm areas → more arrests of minorities → higher average sentences → higher CHI scores → deploy even more.

- **Guidelines-based indices are safer (Lewis et al., 2024; Sherman et al., 2016):** The CCHI, because it is based on sentencing guidelines set independently of actual sentencing decisions, does not present the same feedback loop risk.

**Assessment:** Lewis et al.'s analysis is the most important recent contribution to CHI methodology. The feedback loop concern is real for actual-sentencing indices but does not apply to guidelines-based or statutory-range-based indices. The NYC project's statutory-midpoint approach is resistant to this critique, since NYS Penal Law sentencing ranges are set by the legislature, not by judicial practice.

**NYC project angle:** This project should explicitly acknowledge and cite Lewis et al. (2024) as justification for the statutory-midpoint approach over actual-sentencing alternatives.

### Debate 5: Within-Category Variability

**The camps:**

- **Single weight per crime type is sufficient (Sherman et al., 2016; Mitchell, 2019):** Parsimony matters. A single CHI weight per offence category is good enough for resource allocation. "The goal of setting fine distinctions in harm within crime categories is worthy. It is not an essential first step" (Sherman & Cambridge Associates, 2020).

- **Granularity matters (Curtis-Ham & Walton, 2017; Ratcliffe & Kikuchi, 2019):** The NZ CHI covers 6,412 offence codes. Within-category variation is enormous — the range of harm within "assault" or "robbery" is as large as the range between categories. Ratcliffe & Kikuchi (2019) showed that using PA sentencing guidelines (median recommended sentence by specific offence) outperformed the cruder gravity-score approach for offender triage.

**Assessment:** Granularity matters more for some applications than others. For trend analysis, category-level weights are sufficient. For block-level targeting and offender prioritization, finer-grained weights improve discrimination. The NYC project's PD-level (police description) CHI weights — which compute empirical mean harm within each offense×PD combination — represent the most granular approach in the US CHI literature.

---

## Section 3 — Methodological Landscape and Application

### Methods Inventory

| Technique | Papers Using It | Description |
|-----------|----------------|-------------|
| Sentencing-guideline starting points | Sherman et al. (2016); Sidhu et al. (2017); Dudfield et al. (2017); Sherman & Associates (2020) | Weight = days imprisonment recommended for first offender, no agg/mit factors |
| Statutory maximum sentences | Mitchell (2019) | Weight = max possible sentence under penal code |
| Statutory minimum sentences | Ohyama et al. (2022); Silva et al. (2025) | Weight = min sentence under penal code |
| Statutory midpoint of range | **NYC project (this project)** | Weight = midpoint of sentencing range by felony/misdemeanor class |
| Median actual sentences, first offenders | House & Neyroud (2018) | Median court outcome for first-time offenders from court records |
| 15th percentile actual sentences | Curtis-Ham & Walton (2017) | 15th percentile of sentence distribution as proxy for first-offender floor |
| Mean actual sentences (all offenders) | Karrholm et al. (2020); ONS CSS | Average sentence from judicial records |
| Prosecutorial guidelines | Andersen & Mueller-Johnson (2018) | Recommended sentence from DPP, validated by 5 prosecutors (α=0.93) |
| Offense gravity score | Ratcliffe (2015); Ratcliffe & Kikuchi (2019) | Ordinal scale (1–14) from sentencing commission |
| Incarceration rate × average sentence | Canadian CSI (Huey, 2016) | Proportion sentenced to prison × average sentence length |
| Expert panel survey | Karrholm et al. (2020, compared) | Judges rate offence seriousness |
| Fine-to-prison-day conversion | All CHI papers | Convert monetary fines/community orders to prison-day equivalents via minimum wage |
| Incarceration rate × average sentence | Wallace et al. (2009) | National-level severity weight combining probability and duration of imprisonment |
| Victim-assessed seriousness scale | Ignatans & Pease (2016) | Mean victim seriousness rating (1–20 CSEW scale) per crime type |
| Randomized policing tactics comparison | Groff et al. (2015) | RCT comparing foot patrol, problem-oriented policing, and offender-focused policing at hot spots |
| Power-few analysis | Sherman (2007); Dudfield et al. (2017); Sidhu et al. (2017); Bland & Ariel (2015) | Rank-ordered cumulative harm distribution (Lorenz curve equivalent) |
| Spearman rank correlation | van Ruitenburg & Ruiter (2023 review) | Test rank-order stability of harm rankings across specifications |
| Gini coefficient for harm concentration | Ohyama et al. (2022) | Measure inequality of harm distribution across spatial units |
| Space-time permutation scan statistics | Ohyama et al. (2022) | Detect spatiotemporal clusters of harm |
| Time-decay weighting | Ratcliffe & Kikuchi (2019) | Full weight for recent offences, exponential decay over 10 years |
| Inter-rater reliability (Cronbach's α) | Andersen & Mueller-Johnson (2018) | Test agreement between expert raters and guideline values |
| Harm Detection Fraction | Sherman & Associates (2020) | Proportion of total CHI for which offenders are brought to justice |

### Tiered Recommendations for the NYC Project

**Tier 1: Core (already implemented or essential)**
- Statutory midpoint weighting (NYS Penal Law) — the project's approach
- PD-level granularity for arrest-based CHI
- Substitution approach for gun violence (avoid double-counting)
- Power-few analysis at block level
- Robustness testing across CHI weight specifications

**Tier 2: Extended (high value, should implement)**
- Time-decay weighting for multi-year aggregation (following Ratcliffe & Kikuchi, 2019)
- Harm Detection Fraction by precinct (what proportion of block-level CHI has an arrest?)
- Spearman rank correlations and overlap statistics across targeting specifications (partially done in `03_robustness_analysis.R`)
- Gini coefficients for harm concentration at block and precinct levels

**Tier 3: Advanced (for publication/future work)**
- Comparison of statutory midpoint vs. actual NYS sentencing data (if available)
- Space-time scan statistics for harm clusters
- Equity audit: compare demographic composition of top-harm blocks across CHI specifications

### What to Avoid

- **Using maximum statutory sentences alone** (Mitchell, 2019 acknowledged reduced sensitivity; Karrholm et al., 2020 confirmed minimum sentences lack variability)
- **Using mean actual sentences without filtering** (Sarnecki, 2021 demonstrated inflation for crimes where imprisonment is rare; Lewis et al., 2024 demonstrated racial disparity embedding)
- **Including police-detected offences in trend analysis** (Sherman et al., 2016; but acceptable for targeting with appropriate caveats)
- **Assuming harm spots = hot spots** without testing (Ohyama et al., 2022 shows context-dependence)
- **Small-sample CHI analysis** (Mitchell, 2019 found CHI less useful than counts for small experimental samples)

---

## Section 4 — Theoretical and Empirical Gaps

### Gap 1: No US CHI Using Statutory Sentencing Midpoints

The US CHI literature consists of Mitchell (2019) using California maximum sentences and Ratcliffe (2015; 2019) using Pennsylvania gravity scores or guideline medians. No published US CHI uses the midpoint of structured sentencing ranges — a principled approach that avoids the ceiling effect of maxima and the floor effect of minima. **This project is positioned to fill this gap directly.**

### Gap 2: No CHI Has Addressed Gun Violence Substitution

Every existing CHI treats shooting data either as absent (most international indices), additive (layered on top of complaint-based harm), or implicitly embedded in assault/homicide categories. No published work addresses the double-counting problem that arises when shooting victims generate both a complaint record and a shooting incident record — and no work proposes a substitution methodology to resolve it. **This project's v2 substitution approach (script 04) is novel.**

### Gap 3: Block-Level Harm Aggregation Is Unstudied in the US

Existing US harm-spot analyses operate at the police district (Ratcliffe, 2015) or hot-spot level (Mitchell, 2019). No published US study aggregates CHI to the block level — the operational unit for place-based interventions. The block level is where the "power few" concentration should be most extreme, but this has not been demonstrated empirically in a US city. **This project's block-level aggregation fills this gap.**

### Gap 4: Robustness of Targeting Decisions to CHI Specification

Van Ruitenburg and Ruiter (2023) note that comparisons across CHI methods are scarce. Ashby (2018) compared CCHI and CSS at the police-force level but not at the micro-place level relevant to targeting. No study has tested whether the specific blocks selected for intervention change materially when CHI weights are varied within plausible ranges. **This project's robustness analysis (script 03) directly addresses this gap.**

### Gap 5: PD-Level (Sub-Offense) CHI Granularity

Curtis-Ham and Walton (2017) achieved offence-code-level granularity (6,412 codes) for New Zealand, but this has not been replicated in a US jurisdiction. The NYC project's empirical PD-level weights — computing the mean CHI within each offense × police-description combination — may be the most granular operational CHI in the US. **This is a methodological contribution worth documenting.**

### Gap 6: Temporal Stability of CHI Weights

Most CHI papers report a single set of weights or weights computed over a fixed period. No study has systematically tested how CHI weights vary year-over-year and what this implies for the stability of targeting decisions. **This project's year-by-year weight analysis (output tables: chi_offense_by_year, chi_pd_by_year) addresses this.**

### Gap 7: Equity Implications of Sentencing-Based CHI in US Policing

Lewis et al. (2024) analyzed feedback loops in England and Wales. No equivalent analysis exists for US sentencing structures, where racial disparities are well-documented. The NYC project's use of statutory ranges (set by the legislature, not judicial practice) is theoretically resistant to this critique but has not been tested empirically. **This is an important future direction.**

### Gap 8: CHI for Shots-Fired Events

No CHI paper addresses how to score shots-fired incidents — events where a gun was discharged but no victim was struck. These events represent substantial community harm (fear, property damage, near-miss injury risk) but fall between assault and weapons possession in seriousness. **This project's data-driven scoring of shots-fired events using pd_desc classification with a CPW 2nd floor is novel.**

---

## Section 5 — The "Missing Corpus": Critical External References

*Updated 2026-03-21: 8 papers previously listed as "needed" are now in the corpus and integrated into Sections 1–4. Remaining gaps are listed below.*

### Tier 1: Structurally Essential

| Citation | Why It Matters |
|----------|---------------|
| Sellin, T. & Wolfgang, M.E. (1964). *The Measurement of Delinquency*. New York: Wiley. | The original crime seriousness weighting proposal — intellectual ancestor of all CHIs |

### Tier 2: Important for Specific Arguments

| Citation | Why It Matters |
|----------|---------------|
| Sparrow, M. (2008). *The Character of Harms*. Cambridge University Press. | Broader framework for understanding harm in regulatory/policing contexts |
| Weisburd, D. (2015). The law of crime concentration and the criminology of place. *Criminology*, 53(2), 133–157. | Theoretical foundation for place-based concentration that CHI extends to harm |
| Curtis-Ham, S. (2022). Further development of NZ CHI (various). | Updates and extensions to the NZ CHI approach |

### Tier 3: Background

| Citation | Why It Matters |
|----------|---------------|
| Rinaldo, M. (2015/2016). Comparing crime hotspots and crime harm-spots in a Swedish city. Cambridge M.St. thesis. | Early Swedish application; cited in Karrholm et al. (2020) |
| Ashby, M.P.J. (2017). UCL crime harm index lookup. Technical resource. | Lookup table implementation for England and Wales |
| Telep, C., Mitchell, R.J., & Weisburd, D. (2014). How much time should the police spend at crime hot spots? *Justice Q*, 31, 905–933. | Sacramento experiment that Mitchell (2019) re-analyzed with CHI |
| Sherman, L.W. (2011). Al Capone, the sword of Damocles, and the police-corrections budget ratio. *Criminology and Public Policy*, 10, 195–206. | Extended argument for harm-based resource allocation |

### Papers Now in Corpus (Previously Listed as Needed)

The following papers have been obtained, processed, and integrated into the synthesis above:

| Citation | Where Integrated |
|----------|-----------------|
| Sherman, L.W. (2007). The power few. *J Exp Criminol*, 3(4), 299–321. | Phase 2 (foundational) |
| Sherman, L.W. (2013). Targeting, testing, and tracking. *Crime and Justice*, 42, 377–451. | Phase 2 (Triple-T framework) |
| Wallace et al. (2009). Measuring crime in Canada: the CSI. *Statistics Canada*. | Phase 2b (Canadian CSI) |
| Bland, M. & Ariel, B. (2015). Targeting escalation in domestic abuse. *Int Crim Justice Rev*, 25, 30–53. | Phase 2b (domestic abuse application) |
| Von Hirsch, A. & Jareborg, N. (1991). Gauging criminal harm. *Oxford J Legal Studies*, 11, 1–38. | Phase 1 (theoretical foundations) |
| Ignatans, D. & Pease, K. (2016). Taking crime seriously. *Policing*, 10(3), 184–193. | Debate 1 (victim-perception camp) |
| Fenimore, D. (2019). Mapping harm in Washington DC. *Applied Geography*, 102, 119–132. | Debate 2 (first US harmspot study) |
| Groff, E.R. et al. (2015). Philadelphia Policing Tactics Experiment. *J Exp Criminol*, 11, 149–190. | Methods Inventory; context for Philadelphia CHI |
