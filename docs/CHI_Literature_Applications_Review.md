# What Crime Harm Index Papers Actually Do: A Review of Empirical Applications

## Purpose

This document surveys the empirical applications of Crime Harm Indices across the published literature. The goal is to map out what CHI papers make their "bones" on — what substantive questions they answer, what data they bring to bear, and what the index reveals that raw counts would not. This informs the design of the "work" section of the NYC Crime Harm Index paper.

---

## I. National and Jurisdictional Trend Analysis

The most common CHI application: build an index, apply it to multi-year crime data, and show that harm trends diverge from count trends. Every paper that does this finds the same thing — counts and harm tell different stories.

### Sherman, Neyroud & Neyroud (2016) — The Cambridge CHI

The foundational methodological paper. Uses the "starting point" sentence from England & Wales Sentencing Council guidelines — days of imprisonment for a first offender, no aggravating/mitigating factors. Fines are converted to days via minimum wage; community service hours are similarly converted. The CHI range spans from less than 1 day (minor offenses converted from fines) to 5,475 days (murder at 15 years).

Applied to aggregated England & Wales recorded crime over 10 years (2002/03 to 2012/13). Crime counts dropped 37% (from 5.15M to 3.23M offenses) while the CHI dropped only 21% (from 147.8M to 117.8M imprisonable days). Crime counts overstated the improvement in public safety by 76%. Non-violent offenses constituted 16% of crime counts but violent offenses constituted 76% of CHI harm. The paper articulates the three-pronged test for any CHI — democracy (weights reflect democratic judgment), reliability (reproducible), and cost (feasible to implement) — and argues for excluding proactively detected crime from the index.

### Wallace, Turner, Matarazzo & Babyak (2009) — Canadian Crime Severity Index

The first nationally adopted crime severity index by any government, and it remains in operational use. Weights each offense type by the product of (1) its incarceration rate and (2) its mean prison sentence length. Life sentences are treated as 25 years. The base year (2006) is standardized to 100, analogous to CPI methodology. Weights are updated every 5 years from court data.

Applied to all police-reported crime across Canada, 1998–2007, at national, provincial, and census metropolitan area levels. From 1998 to 2007, the crime rate fell 15% while the CSI fell 21% — severity dropped faster than volume. Between 1999 and 2002, the crime rate was stable but the CSI dropped 6%, driven by declines in serious offenses (break-ins -16%, robbery -11%) offset by increases in mischief. Level 1 assaults comprised 40% of the violent crime rate but only 9% of the Violent CSI; robbery comprised 40% of the Violent CSI but only 8% of the violent crime rate. Saskatchewan had the highest provincial CSI (165 vs. national 95), and territorial crime rates that were 60–230% above the highest province showed only 15–100% CSI gaps, due to a higher mix of less-serious crimes.

### Andersen & Mueller-Johnson (2018) — Danish Crime Harm Index

In the absence of sentencing guidelines, used Danish Director of Public Prosecutions (DPP) guidelines — what sentence prosecutors should request for a first-time offender. Five prosecutors independently validated the DPP values (Cronbach's alpha = 0.93 between prosecutor average and DPP guidelines). Covered 504 criminal code numbers grouped into 46 crime categories, encompassing 93% of all Danish Criminal Code offenses. Applied to 2,129,550 reported criminal incidents from 2011–2016.

While crime volume dropped 14% (54,000 fewer crimes), the DCHI rose by 0.5% (excluding rape) or 6% (including). Crime counts and harm moved in opposite directions. By volume, property crime was 81% of Denmark's total; by harm, only 53%. Crimes against persons were nearly 5x their proportion of total volume when measured by harm. Fraud volume tripled (10,748 to 32,802) over the period, contributing substantially to property harm despite a relatively modest weight of 60 days.

### Karrholm, Neyroud & Smaaland (2020) — Swedish Crime Harm Index

Compared five weighting methods across 17 common offense types: judges' estimates (inter-rater r = 0.966–0.994), average actual sentences, statutory minimums, statutory maximums, and the average of min/max. The minimum sentence had the lowest variability (more than half of crimes shared the same value). Maximum sentences sometimes produced counterintuitive results (e.g., criminal damage receiving a 2-year maximum despite typical sentences being fines). Average actual sentences provided the greatest reliability and sensitivity.

Values ranged from 14 days (harassment) to 5,185 days (murder). Applied to Swedish crime trends 1989–2018 and showed an increase in harm from approximately 2005 onward, even as crime counts were declining or stable in some categories.

### Sarnecki (2021) — Critique of the Swedish CHI for Long-Term Trends

A methodological critique arguing the Swedish CHI overestimates historical increases in crime harm due to: (1) over-counting of homicides in police statistics (by a factor of 3x), (2) legislative changes criminalizing new behavior and increasing penalties (especially for sex crimes and offenses against liberty/peace), and (3) basing harm weights for low-severity offenses on the tiny fraction that actually receive prison sentences.

The key conclusion: a CHI is useful for short-term operational planning (hot spots, resource allocation, evaluation) but may be unreliable for studying long-term crime trends because legislative changes, net-widening, and increased punitiveness inflate the index independent of actual behavior change.

### House & Neyroud (2018) — Western Australian Crime Harm Index (WACHI)

Based on median court outcomes for first-time offenders, drawn from 2.2 million court records (880,000 criminal + 1.2 million traffic) over 6.5 years. A first-time offender was defined as appearing in court only once in 6.5 years; from 880,000 criminal cases, approximately 46,100 (5%) qualified, of which 29,700 had calculable outcomes. Medians were used (not means) because distributions were highly skewed. Fines were converted to prison days using WA minimum wage. 88 offense categories survived the reliability threshold of 5+ court outcomes.

WACHI scores ranged from 1 (street drinking, speeding) to 6,023 (murder). Crime counts and harm moved in different directions in 2 of 4 year-on-year comparisons. A dramatic district-level finding: in Pilbara, crime counts rose 12.5% (1,384 offenses) but harm rose 67%, driven by 106 additional historical sex offenses accounting for 70% of the harm increase but only 8% of the count increase. Correlated highly with other CHIs (Pearson r = 0.84–0.97).

### Curtis-Ham & Walton (2017) — New Zealand Crime Harm Index

Used the 15th percentile of the Equivalent Prison Days distribution from Ministry of Justice sentencing data (2004–2015) as a proxy for first-offender starting-point sentences, across 6,412 offense codes — the most granular CHI published. Determinate sentences of 2 years or less were halved (mandatory release at halfway); longer sentences were multiplied by 0.74 (average proportion actually served). Life imprisonment was set at 5,337 days (average time served).

Sexual offenses stood out dramatically: 30% of harm vs. 1% of volume. Dishonesty offenses comprised 39% of CHI harm vs. 67% of volume. The NZ CHI correlated highly with alternative percentiles (r = 0.87–0.97) and moderately with the MOJ Seriousness Score (r = 0.77), but poorly with maximum penalties (r = 0.47).

---

## II. Spatial Concentration: Hotspots vs. Harmspots

The lane most directly relevant to the NYC block-level CHI. These papers compare the spatial distribution of crime counts against crime harm at micro-geographic levels.

### Weinborn, Ariel, Sherman & O'Dwyer (2017) — 15 UK Councils, Street Segments

The most rigorous hotspot-vs-harmspot comparison. Developed a full 415-category Cambridge CHI for England & Wales. Analyzed all crime events over 1 year across 15 local councils (stratified sample from Cambridgeshire, West Midlands, Sussex), 180,916 events, 121,607 street segments.

Used two standard deviations from the mean to define hotspots and harmspots. Constructed 3D maps in ArcScene where "towers" on each segment represented counts or CHI totals (rescaling was necessary because the ratio between mean counts and mean harm was approximately 1:24).

**Core finding:** 50% of crime harm concentrated in just 0.96% of street segments, vs. 50% of counts in 3.26% of segments — harm is approximately 3x more concentrated than volume. Only about 25% of street segments qualified as both hotspots and harmspots. About 33% of hotspots were NOT harmspots (high-volume, low-harm), and roughly 33% of all harm was in Type III segments (harmspot only — low volume, high harm, invisible to count-based patrol). The authors developed a five-type typology:

- **Type I** (hotspot + harmspot): <2% of segments, highest priority
- **Type II** (hotspot only): high volume, low harm — overpatrolled under current allocation
- **Type III** (harmspot only): low volume, high harm — underpatrolled, ~33% of all harm
- **Type IV** (scattered low-crime): ~40% of crime, ~25% of segments
- **Type V** (crime-free): ~75% of all segments

Estimated cost differential: patrolling 100 harmspots vs. 300 hotspots saves approximately 5.3 million GBP annually.

Limitations acknowledged: cross-sectional (harm persistence unknown), sentencing guidelines are updated regularly and don't exist everywhere, and isolated high-harm events (e.g., a double murder) can create outlier harmspots.

### Fenimore (2019) — Washington, DC

Applied three seriousness scales to 37,183 geocoded Part I offenses in 2016: (1) Cambridge CHI (English-Welsh guidelines), (2) a new US Federal Sentencing Guidelines CHI, and (3) Wolfgang et al. (1985) NSCS severity scores. All scales were standardized to a 0–100 proportional range. Used kernel density estimation for continuous surface maps.

50% of unweighted crime occurred within approximately 7.5% of grid cells. Harm was similarly concentrated (50% within 6–9% of cells depending on scale). But the geographic distribution differed: unweighted crime clustered in the city center (entertainment, tourism, universities), while CHI-weighted harmspots emerged in residential areas further from the center, especially the southeast. Violent crimes drove this spatial divergence — weighted property crime maps resembled unweighted maps, but weighted violent crime maps produced the distinctive non-central pattern. The three different weighting scales produced broadly similar spatial patterns, suggesting the hotspot-harmspot divergence is robust to weighting methodology.

### Ohyama et al. (2022) — Central Tokyo (referenced in literature, not in corpus)

Applied a Japanese CHI based on minimum legal penalties to 77 jurisdictions in central Tokyo, 2010–2019. Found temporal and spatial variability of harm was higher than that of counts, but clustering tendency was lower. Distinct socioeconomic factors were associated with harm accumulation vs. crime volume. Demonstrated that even in a low-crime, low-gun-violence context, harm analysis reveals patterns invisible to count-based analysis.

### Silva, Faria & Alves (2025) — Belo Horizonte, Brazil (referenced, not in corpus)

Adapted the Cambridge CHI to the Brazilian Penal Code using minimum legal penalties. Harm-based mapping substantially reconfigured spatial priorities compared to conventional frequency-based mapping, identifying critical points in police sectors overlooked by count-based analysis. First empirical application of the CCHI in Brazil.

---

## III. Victim and Offender Harm Concentration

These papers apply CHI to the "who" rather than the "where" — identifying the power-few victims and offenders who account for most harm.

### Dudfield, Angel, Sherman & Torrence (2017) — Dorset, Victim Power Curve

All 30,244 crimes against 25,831 unique persons in Dorset (pop. 760,000) over one year (June 2015–May 2016). Over 600 offenses coded with Cambridge CHI values, producing a total of 1,396,650 CHI-days.

**Core finding:** 3.75% of victims (968 people) suffered 85.16% of all CHI harm — a disproportionality ratio of approximately 15:1. Mean CHI for power-few victims was 1,228.7 days vs. 8.34 days for others (147x higher). Sexual offenses accounted for 57.65% of total harm but only 3.24% of crime counts. Repeat victims (12.14% of all victims, n=3,136) accounted for 29% of total harm; just 256 repeat victims (1% of all) suffered 26% of total harm. Power-few victims were substantially younger (mean 30.9 vs. 40.6) with 53% aged 12–29. Female victims suffered much higher harm in both cohorts.

### Bland & Ariel (2015) — Suffolk, Domestic Abuse Trajectories

36,742 domestic abuse events from Suffolk Constabulary (2009–2014). Victim URNs were manually constructed from concatenated surname/DOB fields over approximately 2 months of batch processing. Cambridge CHI values assigned via a 119-offense lookup. A study group of 727 dyads with 5+ events in a 3-year window was identified.

Less than 2% of dyads (412 of 24,311) accounted for 80% of all domestic abuse harm. ANOVA found only borderline significance for escalation in severity (F(9,4802)=1.76, p=.07), driven entirely by increases after the first three events. No significant escalation for the 76 chronic high-harm dyads (F(9,539)=1.29, p=.24). Critically, 53% of the highest-harm dyads were "never called before" — police had no prior domestic abuse record, making prospective risk assessment impossible. Intermittency (days between calls) decreased significantly after Event 5.

### Ignatans & Pease (2016) — CSEW Victim Seriousness, National

Crime Survey for England and Wales, 14 sweeps from 1994–2012 (sample sizes 8,985 to 47,796 per year). Victims rated each crime 1–20 on seriousness. Series victims rated only the most recent event, applied to all events in the series.

Both counts and seriousness dropped by roughly 60% over the period, but seriousness dropped less steeply. Approximately 39% of all victimizations were series crimes, accounting for 42% of total seriousness — remarkably stable proportions over time. The most-victimized 10% of households saw absolute seriousness decline but their share of total seriousness remained constant at approximately 40–45%. Within-offense-label seriousness ratings varied widely, suggesting legal categories are crude proxies for experienced harm.

---

## IV. Evaluating Policing Interventions with CHI

Only one paper has re-analyzed an existing policing experiment through a harm lens. This lane is wide open.

### Mitchell (2019) — Sacramento Hot Spot Experiment Re-Analyzed with CA-CHI

The California Crime Harm Index uses California Penal Code maximum sentences (not starting points, as California lacks sentencing guidelines with starting points). Applied to the Sacramento Hot Spot Experiment — a 90-day RCT (Feb–May 2011) of 15-minute high-visibility patrols across 42 treatment and 21 control hot spots.

Part I crime showed a medium effect (d = 0.71, p = .012): 25% decrease in treatment vs. 27% increase in control. The CA-CHI showed a slightly smaller effect (d = 0.62, p = .025): 22.8% decrease in treatment harm (23,580 prison days) vs. 24% increase in control. When property and violent crime were separated, property crime was significant for both counts and CHI (p = .005, .047), but violent crime was not — too few events (7–19 in treatment, 8–12 in control).

Key methodological insight: the CA-CHI's sensitivity depends on having enough serious crime to differentiate from count-based analysis. The truncated range (homicide at 5,400 was only 2.5x burglary-residence at 2,160) limited discriminating power. Mitchell concludes the CHI may not add value for small studies or low-violence datasets.

---

## V. Operational Resource Prioritization

### Ratcliffe (2015) — Philadelphia District Harm Profiles

Used Pennsylvania Offense Gravity Scores (OGS, range 1–15) on 10 years of Philadelphia police data across 21 districts. Experimentally incorporated traffic accidents (injury = OGS 5, damage-only = 2) and coded investigative stops at 0.25 (acknowledged as arbitrary).

Part I crime frequency explained only R-squared = 0.43 of homicide variance across districts, while the harm index predicted R-squared = 0.60. Significant variation in harm profiles existed across districts invisible in crime counts — some districts with moderate counts had high harm (driven by violence), while high-count districts were dominated by low-harm property crime. Some districts had traffic accidents contributing more to their harm profile than Part 2 crime.

### Ratcliffe & Kikuchi (2019) — Philadelphia Offender Triage (referenced, not in corpus)

Compared three methods of selecting prolific offenders across 10 high-crime Philadelphia districts: (1) analyst-selected lists, (2) detective-selected lists from a Gun Violence Reduction Task Force, and (3) a data-driven harm-score ranked list using PA OGS with time-decay. The harm-score list identified offenders with significantly higher mean harm AND more gun crime episodes than either intuitive selection method. Clinical/intuitive target selection systematically underperforms actuarial harm-based selection.

### Sidhu, Barnes & Sherman (2017) — ANPR Alert Prioritization, West Midlands

70.3 million vehicle registration mark reads from fixed ANPR cameras in April 2015, generating 12,581 live alerts for 1,488 unique vehicles. A random sample of 210 was analyzed.

Police were responding to lower-harm alerts: mean CHI of dispatched alerts was 58% lower than non-dispatched (59 vs. 141 days). Only 23% of total alerts received rapid response, relating to only 11% of total CHI harm. CCHI-based automated prioritization could target over 90% of harm.

---

## VI. Methodological Comparisons and Critiques

### Ashby (2017) — CHI vs. CSS Methods

Compared Cambridge CHI (guideline starting points) and ONS Crime Severity Score (mean actual sentences) across 120 Notifiable Offence List categories. For most offenses, the CSS exceeded the CHI — mean sentences are typically longer than guideline starting points. Differences were sometimes extreme: CSS for possession of false documents was 66x the CHI value; for assaults with injury, nearly 10x. The two methods produced markedly different estimates of which offense types contributed most to national harm.

### Lewis, Pina-Sanchez & Birks (2024) — Racial Feedback Loop Risk

A theoretical paper examining whether ethnic disparities in the criminal justice system could be amplified by CHIs used for police targeting. The ONS CSS (based on mean sentences) risks a negative feedback loop: ethnic disparities in sentencing inflate severity scores for crime types where minorities are overrepresented (especially drug offenses — odds of imprisonment for BAME defendants were more than 2x those of white defendants), leading to more police attention in minority communities, generating more offenses, further inflating scores. The CSS weight for drug trafficking increased from 513 to 667 between the original and updated index.

The Cambridge CHI (based on sentencing guideline starting points, which are offense-focused not offender-focused) does NOT present this problem — no evidence that starting points are set in a racially biased way. This distinction is critical for the NYC project's use of statutory midpoints rather than judicial sentence outcomes.

---

## VII. Summary: Application Types and Gaps

| Application Type | Papers | Status |
|---|---|---|
| National/jurisdictional trends (harm vs. counts over time) | Sherman et al. 2016, Wallace et al. 2009, Andersen & Mueller-Johnson 2018, Karrholm et al. 2020, House & Neyroud 2018, Curtis-Ham & Walton 2017 | Well-established; every country finds the same divergence |
| Spatial concentration at micro-places (hotspots vs. harmspots) | Weinborn et al. 2017, Fenimore 2019, Ohyama et al. 2022, Silva et al. 2025 | Growing but **no US city at the block level** |
| Victim harm concentration (power few) | Dudfield et al. 2017, Bland & Ariel 2015, Ignatans & Pease 2016 | UK-centric |
| Offender targeting and triage | Ratcliffe & Kikuchi 2019, Ratcliffe 2015 | Philadelphia only; uses OGS (truncated range) |
| Evaluating policing interventions | Mitchell 2019 | **Only one paper** — found CHI added little for a property-crime-dominated experiment |
| Operational resource prioritization | Sidhu et al. 2017 | Single case study |
| Equity/feedback loop critique | Lewis et al. 2024 | Theoretical; statutory-midpoint CHIs are resistant |
| Methodological comparison of weighting schemes | Ashby 2017, Karrholm et al. 2020, Curtis-Ham & Walton 2017 | Mature |
| Robustness of targeting to CHI specification | **None** | **Open gap** |
| Gun violence integration/substitution | **None** | **Open gap** |
| Bridging CHI and composite indicator methodology | **None** | **Open gap** |

---

## VIII. Implications for the NYC Crime Harm Index Paper

The NYC block-level CHI can make its bones in several ways, and the strongest paper would combine two or three:

### A. Hotspots vs. Harmspots at the Block Level (extending Weinborn to the US)

This is the most natural application. Report: (1) concentration ratios — what percentage of blocks hold 50% of harm vs. 50% of counts; (2) the overlap/mismatch rate between hot blocks and harm blocks at various thresholds (top 100, 200, 300); (3) the five-type typology applied to NYC blocks. No US city has this at the block level with a statutory-midpoint CHI.

### B. Robustness of Targeting to Specification (novel)

No CHI paper has systematically tested whether the choice of target list is sensitive to CHI construction decisions. The robustness analysis (all vs. outside-only harm, low/mid/high weight variants, N=200/300/400 block thresholds) fills a genuine gap. If targeting is robust, it strengthens the operational case; if not, it quantifies the stakes of methodological choices.

### C. Gun Violence Substitution Methodology (novel)

No CHI paper has addressed the double-counting problem that arises when shooting data and complaint data overlap. The victim-level substitution approach (fatal = Murder 2nd at 7,300 days, non-fatal = Att. Murder 2nd at 5,475 days, with 500ft/12hr spatiotemporal dedup on raw coordinates) is a genuine methodological contribution that any US city CHI would need to solve.

### D. NYC Trend Analysis (straightforward secondary finding)

Like Sherman et al. (2016) for England & Wales or Andersen & Mueller-Johnson (2018) for Denmark, show whether NYC's crime trends look different through the harm lens over 2018–2022. This is low-hanging fruit and readers will expect it.

### E. Intervention Evaluation (if data permits)

Mitchell (2019) is the only paper to re-analyze a policing experiment with a CHI, and she found it added little for a property-crime experiment. Evaluating a violence-focused intervention (directed patrols, transit patrols, precision policing) through the CHI lens would be a direct and valuable extension. The key question: does the intervention reduce harm or just counts?

**TODO: Investigate whether NYPD directed patrol or transit patrol deployment data can be obtained. If so, test whether these deployments reflect harm prioritization or count prioritization — a direct application of the Sidhu et al. (2017) finding that police resources were systematically allocated to lower-harm targets.**

### F. Bridging CHI and Composite Indicator Methodology (theoretical contribution)

No CHI paper engages the OECD Handbook, Sen, Ravallion, or the composite-indicator methodology literature. The CHI is an explicit act of commensuration (Espeland & Stevens, 1998) — the embedded trade-off ratios (e.g., 1 murder = 40 petit larcenies) should be published transparently and subjected to sensitivity analysis in the OECD Handbook tradition.

---

*Document created: 2026-04-02*
*Based on review of 25 CHI and related papers from the project literature corpus*
