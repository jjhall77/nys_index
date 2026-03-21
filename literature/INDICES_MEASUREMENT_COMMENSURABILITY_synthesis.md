# Indices, Measurement, and Commensurability: Literature Synthesis

**Date generated:** 2026-03-21 (updated 2026-03-21 with 8 additional papers)
**Corpus:** 29 markdown files (from 29 unique papers) covering the broader intellectual foundations of crime measurement — indices, commensurability, social choice, crime seriousness, measurement theory, and the politics of quantification.
**Research context:** NYC Crime Harm Index project using NYS Penal Law statutory sentencing midpoints to weight crimes by seriousness for block-level targeting of place-based interventions.

---

## Section 1 — Historical Evolution and Intellectual Lineage

### Phase 1: The Birth of the Crime Index Problem (1831–1964)

The impulse to count crime systematically arose with the "moral statisticians" — Quetelet and Guerry in 1830s France — who saw in criminal statistics the possibility of discovering social laws analogous to natural ones (Maguire, 2007). But the fundamental challenge was immediately apparent: what, exactly, should be counted, and from what source?

**Thorsten Sellin (1931)** established the foundational principle for crime measurement in "The Basis of a Crime Index." His key insight — still operative in every modern CHI — was that *the value of a crime rate for index purposes decreases as the procedural distance from the crime itself increases*. Police statistics ("crimes known to the police") are closer to the criminal event than prosecutorial, judicial, or prison statistics, and therefore less contaminated by the discretionary filtering of the criminal justice system. Prison statistics, Sellin argued, are "useless for index purposes" because they reflect sentencing policy changes rather than crime changes. He further argued that a crime index must be based on only a few selected offenses with high reportability — serious offenses that compel victim cooperation — not a comprehensive count of all crime.

This principle directly shaped the FBI's Uniform Crime Reports (UCR), launched in 1930, which selected seven "index crimes" (murder, rape, robbery, aggravated assault, burglary, larceny-theft, motor vehicle theft) precisely because they were frequent, serious, and most likely reported to police (Maltz, 1999). But the UCR counted all index crimes equally — one murder = one bicycle theft — creating the counting problem that would preoccupy criminologists for the next ninety years.

**Leslie Wilkins (1963)** provided the first rigorous empirical demonstration that a single crime index adding together heterogeneous offenses masks important variation. Using correlation analysis of 15 offense types in England and Wales (1927–1959), he showed that murder rates have *no correlation* with other crime rates; the best estimate of murders in any year is simply the average. Different crime types move independently over time and across space. Wilkins proposed four separate indices rather than one, and introduced the model of crime as a normal distribution of human actions where the boundary between "criminal" and "not criminal" is socially constructed and shifting.

**Biderman and Reiss (1967)** reframed the entire enterprise in their landmark paper "On Exploring the 'Dark Figure' of Crime." They identified the epistemological tension at the heart of crime measurement: **realists** want complete counts of all crime (and see any data source as an approximation of a true total), while **institutionalists** argue that crime has meaning only through organized legal responses (and see all data as products of institutional processing, not objective counts). Victimization surveys, introduced under the President's Crime Commission, were heralded as the ultimate realist tool — but Biderman and Reiss showed they suffer from their own institutional biases (selective recall, telescoping, definitional ambiguity). Their conclusion: no crime rate can "serve equally all purposes and perspectives." All crime statistics involve evaluative, institutional processing; data are events "defined, captured, and processed as such by some institutional mechanism."

### Phase 2: The Seriousness Revolution (1964–1985)

**Sellin and Wolfgang (1964)**, in *The Measurement of Delinquency*, transformed the field by proposing that crimes should be weighted by *perceived seriousness* rather than counted equally. They used psychophysical magnitude estimation — a technique borrowed from perceptual psychology — to have survey respondents assign numerical seriousness scores to crime vignettes. The resulting scale, with its claim to ratio-level measurement, offered a seemingly scientific basis for weighting.

**S.S. Stevens (1946)** had provided the theoretical scaffolding for this approach decades earlier. His taxonomy of measurement scales — nominal, ordinal, interval, ratio — defined what statistical operations are permissible at each level. If crime seriousness scores are merely ordinal (rank-ordering), they cannot be legitimately summed. If they are ratio (equal ratios, with a true zero), they can be multiplied and added — exactly what a weighted crime index requires. The Sellin-Wolfgang claim to ratio-level measurement via magnitude estimation was thus a claim about the *type* of scale they had constructed.

**Rossi, Waite, Bose, and Berk (1974)** provided the strongest evidence for normative consensus on crime seriousness. Their Baltimore household survey (200 adults rating 140 offense descriptions) found remarkably high inter-group correlations: r = .89 between blacks and whites, r = .94 between males and females, r = .89 across education levels. A simple 11-category classification accounted for 68% of variance. Demographic membership explained only 5–7% of variance in ratings. This consensus finding has been replicated across dozens of studies internationally (Stylianou, 2003).

**Alfred Blumstein (1974)** then delivered the devastating empirical challenge: *it doesn't matter*. Comparing the FBI Crime Index (unweighted) to the Sellin-Wolfgang weighted index for U.S. crimes 1960–1972, he found near-perfect linear correlation (r = .9994). The reason: all crime types were rising together due to common secular trends, making inter-crime correlations uniformly above .958. Even doubling violent crime weights and halving property crime weights yielded r = .9983. Blumstein's generalization: "for any social indicator composed of heterogeneous components, when components move together, the weighting scheme is irrelevant."

This finding suppressed enthusiasm for seriousness weighting for two decades. But note the critical scope condition: *when components move together*. When the crime mix changes — as it did dramatically in U.S. cities from the 1990s onward (violent crime plummeting while some property crimes held steady) — weighting matters enormously. This is exactly the condition Sherman et al. (2016) demonstrated for England and Wales 2002–2012.

**Wolfgang, Figlio, Tracy, and Singer (1985)** produced the culmination of the magnitude-estimation program: the **National Survey of Crime Severity (NSCS)**. Administered to 60,000 Americans, the survey produced ratio-scale severity scores for 204 criminal events using magnitude estimation (respondents rated crimes as ratios to a reference stimulus: "a person steals a bicycle parked on the street" = 10). Scores ranged from 0.2 (playing hooky) to 72.1 (planting a bomb that kills 20 people). The NSCS decomposed severity into additive components — injury level (killed = 35.67, hospitalized = 11.96, treated/discharged = 8.53), forcible sex (25.92), intimidation (weapon = 5.60), premises entered (1.50), and property loss (a power function: log severity ~ 0.268 × log dollar value). The survey found remarkable cross-demographic consensus (r > .85–.98 across race, sex, age, and victim status), and cross-modal validation experiments confirmed ratio-scale properties. The NSCS provided the benchmark severity scores that Parton et al. (1991) would later critique and that the CHI movement would ultimately replace with sentencing-based weights. Notably, the NSCS's ratio of "killed" (35.67) to "hospitalized" (11.96) is about 3:1, while the CHI's Murder 2nd (7,300 days) to Felony Assault Class D (1,643 days) is about 4.4:1 — illustrating how weight source changes relative ratios.

**Parton, Hansel, and Stratton (1991)** provided the methodological critique that further undermined the Sellin-Wolfgang approach. They showed that the National Survey of Crime Severity (Wolfgang et al., 1985) violated standard magnitude estimation safeguards: no training task, no cross-modal validation, no individually assigned modulus, no random item ordering. Approximately 25% of respondents may have failed to perform magnitude estimation correctly. Crime seriousness, they argued, is multidimensional (victim harm, offender culpability, offender status) — not the unidimensional construct that magnitude estimation assumes. And the critical test of ratio-scale measurement — whether two identical offenses committed together are rated exactly twice as serious as one — failed: only 32% of subjects in the Pease, Ireson, and Thorpe (1974) study produced additive responses.

**Stylianou (2003)** synthesized the entire 40-year seriousness perceptions literature. The field's most robust finding is *relative consensus* — agreement on the rank ordering of crimes by seriousness. Cross-cultural correlations typically exceed r = .90. But *absolute consensus* (agreement on exact scores) is much weaker. And the fundamental unresolved question — whether seriousness scores can be meaningfully added across offenses — remains open.

**Pease, Ireson, and Thorpe (1975)** exposed the additional problem of cross-national comparisons. Normandeau's (1970) method of comparing seriousness across eight countries by expressing all scores as ratios to "larceny of $1" was flawed because (a) the range of seriousness judgments differed vastly between countries, (b) it implicitly assumed equal seriousness for the anchor offense, and (c) purchasing power differences distorted the anchor. Their standardized scores removed some artifacts but could not resolve the fundamental commensurability problem.

### Phase 3: The Science of Composite Indicators (1970s–2008)

Parallel to the crime seriousness literature, a broader methodological literature on composite indicators was developing — driven by the needs of economics, public health, and development measurement.

**Nardo, Saisana, Saltelli, Tarantola, Hoffmann, and Giovannini (2008)** produced the canonical reference: the OECD/JRC *Handbook on Constructing Composite Indicators*. Their 10-step construction sequence — theoretical framework, data selection, imputation, multivariate analysis, normalization, weighting/aggregation, uncertainty analysis, decomposition, links to other variables, visualization — provides the methodological gold standard. Two insights are critical for crime indices:

1. **Weights are trade-offs, not importance coefficients.** In linear aggregation, a weight does not mean "this component matters more." It means "a unit increase in this component can substitute for X units of decrease in another component." When the CHI assigns murder 7,300 days and bicycle theft 2 days, it is asserting a specific trade-off ratio: one murder = 3,650 bicycle thefts.

2. **Linear aggregation implies full compensability.** A decrease in serious crime can be fully offset by a sufficient increase in minor crime. This is a strong — and potentially troubling — assumption. Geometric aggregation reduces compensability; non-compensatory multi-criteria approaches eliminate it.

**Munda (2004)** provided the philosophical foundation for non-compensatory aggregation in his framework for **Social Multi-Criteria Evaluation (SMCE)**. Drawing on Funtowicz and Ravetz's post-normal science framework, Munda argued that complex policy problems involve two types of incommensurability: *technical* (multiple non-equivalent representations of a system) and *social* (multiple legitimate values in society). Traditional cost-benefit analysis or single-criterion optimization cannot handle this irreducible value pluralism. Munda's crucial contribution for composite indicators was the distinction between **weights as importance coefficients** (how much each dimension "matters") and **weights as substitution rates** (how much of one dimension compensates for a deficit in another). In linear aggregation — the method used by every published CHI — weights function as substitution rates, not importance coefficients. This means the CHI does not say "murder is more important than theft"; it says "a specific number of thefts can fully substitute for a murder with no net change in the index." Munda advocated non-compensatory algorithms that respect incommensurability: a bad score on one criterion should not be fully offset by a good score on another. He also argued that sensitivity analysis in a social context should test a few clear ethical positions, not all possible weight combinations — because the question is not "are rankings stable across arbitrary weights?" but "do different defensible normative stances produce different decisions?"

**Saisana, Saltelli, and Tarantola (2005)** provided the technical methodology for robustness testing of composite indicators. Using the UN Technology Achievement Index (TAI) as a case study, they demonstrated a combined **uncertainty analysis (UA) and sensitivity analysis (SA)** framework: propagate uncertainty through the composite by Monte Carlo simulation across normalization methods, weighting schemes, and individual weight values, then decompose the output variance using **Sobol' indices** (first-order effects S_i, total effects ST_i). Their key findings: (1) the choice of weighting scheme was the single most influential source of variance in country rankings — far more than normalization method, which had essentially no effect; (2) 48–56% of output variance came from *interactions* between factors, not from single factors alone, meaning one-at-a-time sensitivity tests are insufficient; (3) composite indicator rankings should be presented with uncertainty bounds rather than as crisp numbers. Their framework provides the exact methodological template for robustness analysis of any CHI: the dominant question is whether the choice of weight source (statutory midpoints vs. perception-based vs. actual sentences) changes block targeting, not whether minor weight variations within a single scheme matter.

**Saltelli (2007)** crystallized the tension between "aggregators" and "non-aggregators." Aggregators value the bottom-line summary for communication and advocacy. Non-aggregators see weighting as inherently arbitrary and prefer dashboards of component indicators. Even Amartya Sen, initially skeptical of composite indices, was drawn to the HDI because it operationalized his capabilities concept in a single communicable number.

**Ravallion (2012)** provided the sharpest critique of "mashup indices" — composites where theory provides little guidance on design. His four tests apply directly to any CHI:
- **Conceptual clarity:** What exactly does "crime harm" mean?
- **Embedded trade-offs:** What does the CHI imply about how many thefts equal one murder? Are users aware of and comfortable with these implicit trade-offs?
- **Robustness:** Do rankings change substantially with different weighting schemes? (Even r > 0.95 can mask substantial re-rankings.)
- **Policy relevance:** Is the composite more useful than its components for allocation decisions?

### Phase 4: The Politics of Measurement (1995–present)

A distinct strand of scholarship examines measurement not as a technical challenge but as a *social and political process*.

**Espeland and Stevens (1998)**, in "Commensuration as a Social Process," argue that transforming different qualities into a common metric is never merely technical — it is fundamentally political. Commensuration reduces information, standardizes comparisons, and enables mechanized decision-making. It reconstructs authority. And it constitutes what it measures: once a metric exists, actors orient toward it. The Crime Harm Index is an explicit act of commensuration — converting murder, theft, and assault into a single unit (prison days). Espeland and Stevens identify three crucial dynamics:

1. **Constitutive effects.** Once institutionalized, the CHI will shape what counts as "harm" — officers and analysts will attend to what the index measures and ignore what it doesn't.
2. **Incommensurables.** Some things resist commensuration because their value lies in their uniqueness. Claims that sexual violence and property crime "cannot be compared" are claims about incommensurability.
3. **Political authority.** Who chooses the weights? The democratic legitimacy argument for sentencing-based weights (Sherman et al., 2016) is a response to the authority problem.

**Kenneth Arrow (1963 [1951])**, in *Social Choice and Individual Values*, proved the foundational impossibility theorem for aggregation: no social welfare function can simultaneously satisfy unrestricted domain, the Pareto principle, independence of irrelevant alternatives, and non-dictatorship. Any attempt to aggregate individual ordinal preferences into a social ranking must violate at least one of these conditions. For the CHI, Arrow's theorem is the formal reason why no "perfect" composite index can exist — any weighting scheme that aggregates qualitatively different harms into a single number must sacrifice some desirable property. The impossibility is not a flaw in any particular index design; it is a structural feature of aggregation itself.

**Amartya Sen (1999)**, in his Nobel lecture "The Possibility of Social Choice," provides the deepest theoretical treatment of the aggregation problem and the escape route from Arrow's impossibility. Arrow's theorem binds only under an ordinal preference framework that excludes interpersonal comparisons. Sen argues the impossibility arises from *informational poverty* — restricting decisions to voting-type rules that exclude interpersonal comparisons. Even *partial comparability* (not full cardinal) is sufficient to break the impossibility. The CHI's use of sentencing ranges represents exactly this: a partial, imperfect, but democratically grounded basis for comparing the severity of qualitatively different harms. Arrow provides the formal proof that no perfect CHI can exist; Sen provides the philosophical justification for building one anyway.

**Bevan and Hood (2006)** demonstrated the behavioral consequences of measurement in their study of NHS "targets and terror." When indicators are used for accountability, Goodhart's Law applies: "any observed statistical regularity collapses once pressure is placed on it for control purposes." They documented gaming (reclassification, threshold manipulation, output distortion) and warned of "synecdoche" — taking a measured indicator to stand for total performance. Their typology of actors (saints, honest triers, reactive gamers, rational maniacs) describes how organizational behavior adapts to measurement regimes. This is directly relevant to any CHI used for police resource allocation.

**The Pathological Politics of Criminal Law.** A distinct strand of legal scholarship examines the legislative process that *produces* the statutory weights on which the CHI relies. **William Stuntz (2001)**, in "The Pathological Politics of Criminal Law," argued that American criminal codes expand without bound due to structural "deep politics": prosecutors and legislators form a natural alliance (both benefit from broad, overlapping statutes that maximize charging discretion), while judges are marginalized by plea bargaining's dominance. The result is that criminal codes cover far more conduct than can ever be punished, and statutory breadth enables selective enforcement. Crucially, however, Stuntz observed that core common-law crimes — murder, rape, robbery, assault — have *not* substantially broadened; the pathological expansion is concentrated in regulatory and modern offenses. This distinction is directly relevant to the CHI: the ten target offense categories used in the NYC project are precisely these stable core offenses whose statutory definitions and sentencing ranges reflect relatively durable democratic judgments about harm, not the expansionary pathology Stuntz documents.

**Joshua Kleinfeld (2019)**, in "Textual Rules in Criminal Statutes," extended and refined the Stuntz critique. He showed that the pathological politics produce statutory text that is systematically overbroad, overharsh, and intentionally vague — designed not for literal application but as instruments of prosecutorial leverage in plea bargaining. Criminal statutes are "instrumental law" — their text does not describe the conduct actually punished but rather the maximum envelope of prosecutorial threat. Rule-oriented textualism cannot constrain this pathology because the overbreadth is a feature, not a bug. For the CHI, Kleinfeld's analysis reinforces a critical distinction: the project uses statutory *sentencing ranges* (which constrain judicial discretion at the back end), not *charging text* (which empowers prosecutorial discretion at the front end). Sentencing ranges for core offenses reflect relatively stable legislative harm judgments, even as the charging text that initiates the process is instrumentally distorted.

**Todd Haugh (2015)**, in "Overcriminalization's New Harm Paradigm," identified a downstream consequence of the Stuntz-Kleinfeld pathology: overcriminalization is itself criminogenic. Drawing on behavioral ethics, Haugh argued that vague, overbroad, and inconsistent criminal law erodes perceived fairness, which in turn fuels offender rationalizations ("the system is arbitrary anyway") and reduces voluntary compliance. The mechanism runs through law legitimacy: when people perceive criminal law as capricious or unjust, they are more likely to offend. For the CHI, Haugh's analysis suggests that a transparent, statute-based harm index — one that makes explicit the trade-off ratios embedded in democratic sentencing legislation — could actually *enhance* perceived legitimacy of enforcement prioritization, countering the rationalizations that Haugh identifies as criminogenic. Opaque, ad hoc enforcement priorities are exactly the kind of perceived arbitrariness that erodes compliance.

**Stiglitz, Sen, and Fitoussi (2009)** produced the most authoritative modern critique of composite indicators in their *Report by the Commission on the Measurement of Economic Performance and Social Progress*. Commissioned by French President Sarkozy, the report argued that GDP — the paradigmatic aggregate composite — conflates production with well-being, masking distributional inequality and environmental degradation. The Commission's 12 recommendations crystallize principles that apply directly to any crime composite: (1) present distributions and medians, not just means, because averages mask what is happening to most people; (2) accompany any aggregate with its components, because combining current speed and remaining fuel into one number helps no one; (3) what we measure affects what we do — if metrics are flawed, policy decisions are distorted; (4) sustainability must be assessed separately from current performance. The report's stance on the "dashboard vs. composite" debate was nuanced: statistical agencies should provide data that *allows* construction of different indices (Recommendation 9), but no single composite should substitute for the underlying multidimensional reality. For the CHI, the Stiglitz-Sen-Fitoussi framework counsels presenting block-level harm alongside its decomposition (violent, property, gun violence separately) so the composite does not mask important patterns. The Commission's grounding in Sen's capability approach also offers a philosophical link: statutory sentencing midpoints can be understood as measures of freedom deprivation (imprisonment = direct capability restriction), giving them a theoretical legitimacy that dollar-cost or perception-based weights lack.

**Jerven (2013)** provided the most vivid case study of how composite metrics mislead when underlying data infrastructure is weak. African GDP statistics — the paradigmatic aggregate composite — produce wildly different country rankings depending on which dataset is used. When Ghana rebased its GDP in 2010, the estimate jumped 60% overnight. The "precision" of published numbers concealed massive uncertainty. Jerven's lesson applies directly: crime harm indices built from administrative data inherit the recording practices, classification inconsistencies, and political pressures of those data systems.

**Sampson and Laub (2005)**, though focused on developmental criminology, articulated a warning applicable to all quantitative criminology: method choices shape findings and can create artifacts. The "seductions of method" — treating statistical techniques as substantive contributions — cautions against letting the mechanics of CHI construction (weighting, aggregation, normalization) overshadow the theoretical rationale for the enterprise.

### Phase 5: The Spatial Turn and the Modern CHI (2015–present)

**Weinborn, Ariel, Sherman, and O'Dwyer (2017)** provided the key empirical bridge between the general composite-indicator literature and the operational CHI movement. Analyzing 180,916 crimes across 15 UK councils at the street-segment level, they showed:

- 50% of crime *counts* concentrate in 3.26% of street segments
- 50% of crime *harm* concentrates in just 0.96% of street segments — three times more concentrated (OR = 3.49)
- Only ~25% of street segments qualify as both hotspots and harmspots
- ~33% of hotspots have low harm; ~42% of harmspots have low crime volume

This finding — that harm and count distributions are substantially different at micro-geographic scales — is the empirical justification for the entire CHI enterprise. It directly refutes Blumstein's (1974) null finding, which operated at the national aggregate level where all crime types moved together. At the block level, crime mix varies dramatically across space, making weighting consequential.

**Fienberg and Reiss (1980)**, in their edited volume *Indicators of Crime and Criminal Justice*, had anticipated many of these issues. Their framework for decomposing crime rate changes into prevalence, incidence, and interaction components remains essential for understanding what harm indices actually measure. Their finding that offense seriousness dominated parole decisions by roughly 3:1 over offender characteristics supports the empirical validity of seriousness-based measures. And their demonstration that equal-weighting and differential-weighting of parole prediction variables produced similar results (due to collinearity) parallels Blumstein's finding while flagging the scope conditions under which it breaks down.

### The Current Frontier

The frontier is no longer "should we weight crime by harm?" — that question is settled. The frontier questions are:

1. **What is the right informational basis for weights?** Survey perceptions, sentencing guidelines, statutory ranges, actual sentences, or expert judgment?
2. **What are the behavioral consequences of institutionalizing a CHI?** Will it produce the gaming and synecdoche effects Bevan and Hood documented in healthcare?
3. **How robust are micro-place targeting decisions to the details of CHI construction?**
4. **Can commensuration across qualitatively different harms be made legitimate and transparent?**

---

## Section 2 — Current Conflicts and Debates

### Debate 1: Perceptions vs. Sentencing as the Basis for Weights

**The camps:**

- **Perception-based (Sellin & Wolfgang, 1964; Rossi et al., 1974; Wolfgang et al., 1985; Stylianou, 2003):** Crime seriousness should reflect what the public thinks. Survey-based magnitude estimation produces (claimed) ratio-scale scores grounded in normative consensus. This approach has theoretical purity — it measures harm as experienced by the community, not as filtered through legislative or judicial institutions.

- **Sentencing-based (Sherman et al., 2016; Curtis-Ham & Walton, 2017; House & Neyroud, 2018):** Survey-based scores are methodologically problematic (Parton et al., 1991), non-additive (Pease et al., 1975), and impractical at scale. Sentencing guidelines or statutory ranges are democratic (legislatively determined), reliable (consistently applied), affordable (no new data collection), and operational (simple to compute). They are an imperfect but usable proxy for public judgment of seriousness.

- **Critical (Blumstein, 1974; Parton et al., 1991; Pease et al., 1975):** Commensuration across crime types separated by orders of magnitude in seriousness is "probably very difficult, and inappropriate in any index" (Blumstein). Magnitude estimation fails its own ratio-scale tests. And the strong consensus finding may reflect consensus on rank-ordering but not on the cardinal distances between crimes.

**Assessment:** The sentencing-based approach has won operationally — it is used by every published CHI. But it has not fully answered the theoretical challenge. Sentencing ranges are politically determined and change with legislation (Sarnecki, 2021). They are a *convention* for commensuration, not a measurement of harm. The honest position is Saltelli's: weighting is always partly arbitrary, and transparency about the choice matters more than the choice itself. A further complication comes from legal scholarship: Stuntz (2001) and Kleinfeld (2019) show that statutory text is politically distorted by structural incentives favoring prosecutorial breadth. However, their analyses also reveal that sentencing *ranges* for core offenses (murder, rape, robbery, assault) are more stable and less distorted than charging text — the pathological expansion concentrates in regulatory and modern offenses, not in the common-law core that forms the CHI's backbone.

**NYC project angle:** The statutory-midpoint approach has the virtue of being anchored in democratic legislation while avoiding the instability of actual sentences. It can be explicitly defended as a "partial comparability" move in Sen's sense — not claiming to measure harm perfectly, but providing a sufficient informational basis for practical targeting decisions.

### Debate 2: Compensability — Can Enough Minor Crimes Equal One Serious Crime?

**The camps:**

- **Full compensability (implicit in all linear-aggregation CHIs):** The standard CHI computation — multiply counts by weights, sum — implies that 3,650 bicycle thefts produce exactly the same "harm" as one murder. This is the mathematical consequence of linear aggregation.

- **Limited compensability (OECD Handbook, Ravallion, 2012):** Geometric aggregation or non-compensatory multi-criteria methods can reduce or eliminate compensability. The HDI switched from arithmetic to geometric mean in 2010 precisely to reduce compensability.

- **Incommensurability (Espeland & Stevens, 1998; Greenfield & Paoli, 2013):** Some harms are categorically different and should not be placed on a single scale. Aggregation across qualitatively different offense types destroys information that matters morally and operationally.

**Assessment:** Full compensability is the default in the CHI literature because linear aggregation is simple and transparent. In practice, the compensability problem rarely arises at the micro-geographic level because the crime mix at specific blocks tends to be dominated by a few offense types. But for trend analysis (where a city's total CHI could rise due to minor-crime increases while serious crime falls), compensability is a genuine concern. No CHI paper has engaged seriously with this issue.

**NYC project angle:** At the block level, the substitution approach for gun violence and the exclusion of proactive crime both mitigate compensability concerns by ensuring that the most serious events are not diluted by minor ones. But the paper should acknowledge the compensability assumption and note that it is a limitation shared by all linear-aggregation composites.

### Debate 3: Measurement Level — Can CHI Weights Be Meaningfully Added?

**The camps:**

- **Yes, if based on statutory days (Sherman et al., 2016; Mitchell, 2019):** Imprisonment days are a ratio-scale measure with a meaningful zero (no imprisonment). Addition is legitimate because the units are physically commensurable — days are days.

- **Skeptical (Parton et al., 1991; Pease et al., 1975; Stevens, 1946):** The "days" in a CHI are not physical days served; they are statutory recommendations that bear an uncertain relationship to actual harm. The seriousness perceptions underlying legislation may be ordinal at best. Adding ordinal values is technically "illegal" (Stevens, 1946), though Stevens himself acknowledged it can be pragmatically productive.

- **Constructive pragmatism (Blumstein, 1974; OECD Handbook):** The question is not whether the scale is "really" interval or ratio, but whether the ranking of places, offenders, or time periods produced by the index is robust to plausible alternative specifications. If the same blocks come out on top regardless of how weights are varied, the measurement-level question is moot operationally.

**Assessment:** The constructive-pragmatist position is the strongest. The NYS project's robustness analysis — testing whether block-level targeting is stable across low/mid/high weight specifications — directly answers the operational question without needing to resolve the philosophical one.

### Debate 4: The Dark Figure and Data Infrastructure

**The camps:**

- **Realist (crime surveys, Sellin's original vision):** An ideal crime index would count all crimes, including unreported ones. Police statistics systematically undercount crime, and the undercounting varies by offense type.

- **Institutionalist (Biderman & Reiss, 1967; Wilkins, 1963; Maguire, 2007):** All crime data are institutional products. Different data sources (complaints, arrests, surveys, hospital records) illuminate different facets of the dark figure, and no single source provides an objective count. The question is not "how much crime is there?" but "what are the selective properties of this particular measurement system?"

- **Pragmatist (Sherman et al., 2016; Maltz, 1999):** Use the best available data — victim-reported complaints — with full awareness of their limitations. Exclude police-detected crime to avoid measuring policing inputs rather than public safety outcomes.

**Assessment:** The institutionalist position is correct epistemologically, but the pragmatist position governs CHI construction. Complaint data are used because they are closest to the criminal event (Sellin's principle), not because they represent "all crime." The NYC project's use of NYPD complaint data follows this logic. The gun violence layer (shootings, shots fired) adds a second data stream for the most serious events, partially filling the dark figure for gun crime.

**NYC project angle:** Acknowledge explicitly that the CHI measures *reported* crime harm, not total crime harm. The gap between reported and total harm is larger for some offense types (e.g., sexual assault, domestic violence) than others (homicide), which means the index systematically underweights offenses with lower reportability.

### Debate 5: Gaming, Goodhart's Law, and Institutional Incentives

**The camps:**

- **Measurement optimists (Sherman & Cambridge Associates, 2020):** A CHI, by focusing on harm rather than counts, creates better incentives than the status quo. Officers should focus on the most harmful crimes, and a CHI correctly directs attention there.

- **Measurement critics (Bevan & Hood, 2006; Maguire, 2007):** Any performance metric used for accountability will be gamed. If police are measured on CHI, they will reclassify crimes, manipulate recording practices, and focus on measured dimensions at the expense of unmeasured ones. Goodhart's Law is not optional.

- **Structural concern (Jerven, 2013; Maltz, 1999):** The quality of the underlying data infrastructure constrains the utility of any composite metric. Voluntary reporting, imputation gaps, and recording inconsistencies produce uncertainty that published indices conceal.

**Assessment:** Both camps are right. A CHI is better than crime counts for directing attention to serious harm. But any metric used for accountability will be distorted. The mitigation is transparency: publish the components alongside the composite, report uncertainty, and audit recording practices. The NYC project should present block-level CHI as a targeting tool (directing where to look), not an accountability metric (measuring how well police performed). Haugh (2015) adds a complementary argument from behavioral ethics: opaque, ad hoc enforcement priorities erode perceived law legitimacy, which is itself criminogenic — people rationalize offending when they perceive the system as arbitrary. A transparent CHI that makes its trade-off ratios explicit could actually *enhance* legitimacy by replacing opaque prioritization with a principled, statute-based framework, countering the criminogenic effects of perceived arbitrariness.

### Debate 6: The Commensurability Question — Can Qualitatively Different Harms Share a Scale?

**The camps:**

- **Yes, pragmatically (Sherman et al., 2016; Sen, 1999; OECD Handbook):** Perfect commensurability is impossible, but partial comparability is sufficient for practical decisions. Arrow's (1963) impossibility theorem provides the formal foundation: no aggregation procedure can satisfy all desirable properties simultaneously, so any composite index must sacrifice something. Sen showed that even incomplete interpersonal comparisons break Arrow's impossibility by enriching the informational basis beyond ordinal preferences. Sentencing ranges provide a democratic, imperfect, but workable basis for comparison — a practical implementation of Sen's partial-comparability escape from Arrow's impossibility.

- **No, fundamentally (Espeland & Stevens, 1998; Greenfield & Paoli, 2013):** Some harms are constitutively incommensurable — comparing them on a common scale destroys what makes them matter. Sexual violence and property crime are qualitatively different in kind, not just degree.

- **Yes, but reveal the trade-offs (Ravallion, 2012; Saltelli, 2007):** Commensuration is unavoidable in resource allocation — police must decide where to deploy. The question is whether the trade-offs are made explicitly (through a CHI) or implicitly (through ad hoc judgment). Explicit is better, provided the embedded trade-offs are transparent.

**Assessment:** The reveal-the-trade-offs position is the most defensible for an operational CHI. The project should be transparent: "Our index implies that one murder (7,300 days) is equivalent in harm to 40 Class A misdemeanor assaults (40 × 183 days = 7,320 days). Users should evaluate whether this trade-off is acceptable for their purposes."

---

## Section 3 — Methodological Landscape

### Methods Inventory

| Technique | Papers Using It | Description |
|-----------|----------------|-------------|
| Magnitude estimation | Sellin & Wolfgang (1964); Wolfgang et al. (1985); Parton et al. (1991 — critiquing) | Psychophysical scaling: respondents assign unbounded numbers to crime vignettes relative to a standard |
| Category scaling (bounded rating) | Rossi et al. (1974); Parton et al. (1991) | Respondents rate crimes on a fixed scale (e.g., 1–9). Ordinal at best; inter-group correlations test consensus |
| Paired comparison | Stylianou (2003, review) | Respondents compare crimes pairwise. Thurstone scaling produces interval-level scores |
| Sentencing guideline starting points | Sherman et al. (2016); Cambridge CHI | Weight = recommended sentence for first offender, no aggravating/mitigating factors |
| Statutory sentencing midpoints | **NYC project** | Weight = midpoint of legislated sentencing range by felony/misdemeanor class |
| Actual sentencing medians/means | House & Neyroud (2018); Curtis-Ham & Walton (2017); Karrholm et al. (2020) | Weight derived from court records, filtered by offender characteristics |
| Offense gravity scores | Ratcliffe (2015) | Ordinal scale (1–14) from sentencing commission |
| Correlation analysis of crime types | Wilkins (1963); Blumstein (1974) | Test whether different crime types move together over time/space |
| Power-few / Lorenz curve analysis | Sherman (2007); Dudfield et al. (2017); Weinborn et al. (2017) | Rank-ordered cumulative distribution of harm |
| Gini coefficient | Ohyama et al. (2022); OECD Handbook | Measure inequality of harm distribution |
| Sensitivity/robustness analysis (Sobol' indices) | OECD Handbook (Nardo et al., 2008); Saltelli (2007) | Variance-based decomposition of composite index uncertainty |
| Multi-criteria aggregation (SMCE) | OECD Handbook; Munda (2004) | Non-compensatory aggregation; weights as importance coefficients rather than substitution rates |
| Monte Carlo UA + Sobol' SA | Saisana, Saltelli & Tarantola (2005); OECD Handbook | Propagate uncertainty across construction choices; decompose variance into first-order and interaction effects |
| Component-based event scoring | Wolfgang et al. (1985) / NSCS | Additive scoring: injury + theft + intimidation + entry weights per event |
| Dashboard + composite reporting | Stiglitz, Sen & Fitoussi (2009) | Present composite alongside components; distributions alongside means |
| Geometric aggregation | OECD Handbook; HDI (post-2010) | Reduces compensability relative to linear aggregation |
| Cost-benefit analysis / dollar index | Blumstein (1974) | Converts seriousness to dollar terms via power function |
| Time-decay weighting | Ratcliffe & Kikuchi (2019) | Full weight for recent offenses, exponential decay |
| Space-time permutation scan | Ohyama et al. (2022) | Detect spatiotemporal clusters |

### Tiered Recommendations for the NYC Project

**Tier 1: Core (essential for publication)**
- Statutory midpoint weighting with full lookup table (already done)
- Robustness/sensitivity analysis across weight specifications (already done in `03_robustness_analysis.R`)
- Explicit statement of embedded trade-offs (what the weight ratios imply)
- Power-few concentration analysis at block level
- Component reporting alongside composite (break out CHI by offense category)

**Tier 2: Extended (strengthens the paper significantly)**
- Correlation analysis of crime types (Wilkins/Blumstein test): do different offense categories in NYC move independently across blocks? If yes, weighting matters; if no, it doesn't.
- Gini coefficients comparing harm concentration to count concentration (Weinborn et al., 2017)
- Explicit compensability discussion following Munda (2004): what happens to block rankings if a non-compensatory aggregation rule is used? Are the CHI's weights functioning as trade-off rates or importance coefficients?
- Component decomposition alongside composite, per Stiglitz-Sen-Fitoussi (2009): report top-harm blocks with offense-category breakdown so the aggregate does not mask the driving offense type

**Tier 3: Advanced (for future work)**
- Full Monte Carlo UA + Sobol' SA following Saisana et al. (2005): propagate uncertainty across weight source, normalization, and aggregation method simultaneously; report block rankings with confidence intervals rather than as crisp numbers
- Comparison of statutory-midpoint weights to perception-based weights from the NSCS (Wolfgang et al., 1985) or Rossi et al. consensus data — directly testing whether weight source changes targeting decisions
- Dark-figure adjustment: estimate offense-specific reporting rates and test whether adjusting for differential reportability changes block rankings

### What to Avoid

- **Claiming ratio-scale measurement** without qualification. The days-of-imprisonment unit looks like a ratio scale but rests on legislative convention, not physical measurement.
- **Suppressing the trade-off ratios.** Make explicit what the weights imply (e.g., "one murder = N assaults"). Users should be able to evaluate these.
- **Treating robustness as a yes/no.** Blumstein (1974) showed that at the national level, weighting didn't matter. Weinborn et al. (2017) showed that at the micro-place level, it did. Report *where* in the ranking distribution specifications diverge (usually in the middle, not the top or bottom).
- **Ignoring the dark figure.** The CHI measures reported harm. Offense types with low reportability (sexual assault, domestic violence) are systematically underweighted relative to their true harm burden.
- **Using the CHI as an accountability metric without safeguards.** Bevan and Hood (2006) showed what happens when metrics become targets. Frame the CHI as a targeting tool, not a performance measure.

---

## Section 4 — Theoretical and Empirical Gaps

### Gap 1: No CHI Paper Engages with the Commensurability Literature

The entire CHI literature (Sherman et al., 2016 onward) treats the weighting problem as a design choice to be evaluated against five criteria (democratic, reliable, affordable, valid, operational). None engages with the deeper commensurability questions raised by Espeland and Stevens (1998), Sen (1999), or Ravallion (2012). The CHI literature does not cite the OECD Handbook. It does not discuss compensability. It does not reveal the embedded trade-off ratios. This is a significant intellectual gap — the CHI movement is building a consequential composite index without engaging with the composite-indicator methodology literature.

**NYC project angle:** This project can be the first to bridge the CHI literature and the composite-indicator literature. Explicitly cite the OECD framework, discuss compensability, and conduct robustness analysis according to composite-indicator best practices.

### Gap 2: No CHI Paper Tests the Blumstein Null at Micro-Geographic Scales

Blumstein (1974) showed that weighting didn't matter at the national level because all crime types moved together. Weinborn et al. (2017) showed divergence at the street-segment level. But no study has directly replicated the Blumstein test (inter-crime correlations) at the block level for a U.S. city to show *why* weighting matters there — i.e., that crime types do *not* move together across micro-geographic units.

**NYC project angle:** Compute inter-crime-type correlations across NYC blocks. If they are substantially lower than Blumstein's .958+ at the national level, this provides the direct empirical justification for block-level CHI weighting.

### Gap 3: Compensability Has Never Been Discussed in the CHI Context

Every published CHI uses linear aggregation, which implies full compensability. No paper acknowledges or tests this. At the block level, could a non-compensatory aggregation rule (which treats a block with one murder differently from a block with 3,650 bicycle thefts, even if their CHI is identical) produce different targeting decisions?

**NYC project angle:** Test a lexicographic or geometric aggregation rule and compare block rankings to the standard linear CHI. If rankings are stable, the compensability assumption is harmless in practice; if not, it matters and should be flagged.

### Gap 4: The Behavioral Consequences of CHI Adoption Are Unstudied

Bevan and Hood (2006) documented gaming in healthcare targets. No equivalent study examines whether CHI-based policing produces analogous effects: crime reclassification, differential recording, attention to measured vs. unmeasured harm dimensions.

**NYC project angle:** Not directly addressable with current data (this would require a post-implementation study). But the paper should cite Bevan and Hood, Goodhart's Law, and Maguire (2007) to acknowledge this risk and recommend safeguards.

### Gap 5: No CHI Paper Addresses Differential Reportability

The CHI measures reported harm. Offense types with low victim reporting rates (sexual assault, domestic violence) are systematically underweighted. This is the dark-figure problem (Biderman & Reiss, 1967) applied to harm measurement. No CHI paper quantifies how much reportability variation affects block-level rankings.

**NYC project angle:** Potentially addressable using BCS/NCVS-type reporting rate estimates as adjustment factors. Even a sensitivity analysis showing the effect of adjusting high-harm/low-report offenses would be novel.

### Gap 6: The Historical Roots of the CHI Are Under-Cited

The CHI literature cites Sellin and Wolfgang (1964) as a starting point but does not engage with the broader intellectual history: Sellin (1931), Wilkins (1963), Biderman and Reiss (1967), Blumstein (1974), Rossi et al. (1974), or the OECD composite-indicator framework. This makes the CHI appear to be a self-contained invention rather than the latest chapter in a century-long effort to measure crime.

**NYC project angle:** A literature review that traces the full lineage — from Sellin (1931) through the seriousness revolution to the modern CHI — would be a significant intellectual contribution and would position the project within the broader measurement science.

### Gap 7: No CHI Engages with Sen's Social Choice Framework

Sen (1999) showed that partial comparability is sufficient to make social welfare judgments, even without full cardinal interpersonal comparisons. Arrow (1963) — now in the corpus — provides the formal impossibility result that Sen's framework addresses: no aggregation procedure satisfying ordinal-only preferences can meet all desirable conditions simultaneously. This is exactly the philosophical position the CHI occupies: sentencing-midpoint weights don't perfectly measure harm, but they provide sufficient basis for targeting. No CHI paper makes the Arrow-Sen connection explicit.

**NYC project angle:** Cite both Arrow and Sen directly. Frame the statutory-midpoint approach as a "partial comparability" solution (Sen) to an impossibility (Arrow) in the crime harm aggregation problem. Arrow proves no perfect CHI can exist; Sen proves an imperfect but useful one can. This elevates the theoretical ambition of the paper significantly.

### Gap 8: The Legislative Process That Produces CHI Weights Is Itself Pathological

Stuntz (2001) and Kleinfeld (2019) demonstrate that American criminal codes expand via structural political incentives — prosecutors and legislators benefit from broad, overlapping statutes, and statutory text is designed as an instrument of plea-bargaining leverage rather than a faithful description of punishable conduct. No CHI paper engages with this legal scholarship critique of the very legislative process that produces the statutory weights on which the index depends. The implicit assumption in the CHI literature is that sentencing legislation reflects considered democratic judgment about harm severity; Stuntz and Kleinfeld show this is only partially true.

**NYC project angle:** The project can acknowledge the pathological-politics critique while arguing that core-offense sentencing ranges are relatively insulated from it. Stuntz himself observed that murder, rape, robbery, and assault statutes have not substantially broadened — the pathological expansion concentrates in regulatory and modern offenses. The CHI's ten target offense categories are precisely these stable core offenses. Kleinfeld's distinction between instrumental charging text and sentencing ranges further supports the argument: the CHI relies on sentencing ranges (which constrain judicial discretion) rather than charging text (which empowers prosecutorial discretion). Haugh (2015) adds that a transparent, statute-based index may actually counter the legitimacy erosion caused by the broader overcriminalization pathology. This engagement with the legal scholarship would be a novel contribution — no existing CHI acknowledges that the legislative process producing its weights is itself politically distorted, let alone argues for why the distortion does not fatally compromise the enterprise.

---

## Section 5 — The "Missing Corpus": Critical External References

*Updated 2026-03-21: 8 papers previously listed as "needed" or newly added are now in the corpus and integrated into Sections 1–4. Remaining gaps below.*

### Tier 1: Structurally Essential

| Citation | Why It Matters |
|----------|---------------|
| Porter, T. (1995). *Trust in Numbers: The Pursuit of Objectivity in Science and Public Life*. Princeton. | The foundational work on why quantification signals weak authority and how numbers acquire political power. Cited by Espeland & Stevens (1998), Jerven (2013). Essential for understanding the political context of CHI adoption. |
| Sellin, T. & Wolfgang, M. (1964). *The Measurement of Delinquency*. New York: Wiley. | The foundational crime seriousness weighting proposal. Already in your earlier "papers to obtain" list. |

### Tier 2: Important for Specific Arguments

| Citation | Why It Matters |
|----------|---------------|
| Radin, M.J. (1996). *Contested Commodities*. Cambridge: Harvard. | Philosophical treatment of incommensurability in market valuation. Cited by Espeland & Stevens for the argument that some harms resist commensuration. |
| Anderson, E.S. (1993). *Value in Ethics and Economics*. Cambridge: Harvard. | Another philosophical treatment of pluralistic valuation. Supports the non-compensability critique. |
| Hacking, I. (1990). *The Taming of Chance*. Cambridge University Press. | Historical treatment of how statistical thinking transformed governance. Context for the CHI as a governing instrument. |
| Goodhart, C.A.E. (1984). *Monetary Theory and Practice: The UK Experience*. London: Macmillan. | Original statement of Goodhart's Law. Essential for gaming concerns. |

### Tier 3: Background

| Citation | Why It Matters |
|----------|---------------|
| Simmel, G. (1978 [1900]). *The Philosophy of Money*. London: Routledge. | Money as the paradigmatic commensurating form. Illuminates what CHI does conceptually. |
| Foucault, M. (1977). *Discipline and Punish*. New York: Vintage. | Government statistics as instruments of surveillance and control. Context for the political sociology of crime measurement. |
| Normandeau, A. (1970). Cross-national seriousness data. In *Sociology of Punishment and Correction*. | The cross-national comparison that Pease et al. (1975) corrected. |

### Papers Now in Corpus (Previously Listed as Needed)

| Citation | Where Integrated |
|----------|-----------------|
| Munda, G. (2004). Social multi-criteria evaluation. *European J Operational Research*, 158, 662–677. | Phase 3 (non-compensatory aggregation; weights-as-trade-offs distinction) |
| Saisana, M., Saltelli, A., & Tarantola, S. (2005). UA/SA for composite indicators. *JRSS-A*, 168(2), 307–323. | Phase 3 (Monte Carlo + Sobol' robustness methodology) |
| Stiglitz, J., Sen, A., & Fitoussi, J.-P. (2009). Report on Measurement of Economic Performance. | Phase 4 (dashboard vs. composite; capability approach; "what we measure affects what we do") |
| Wolfgang, M.E., Figlio, R.M., Tracy, P.E., & Singer, S.I. (1985). *National Survey of Crime Severity*. BJS. | Phase 2 (NSCS as culmination of magnitude-estimation program; 204-event severity scale) |
| Arrow, K.J. (1963 [1951]). *Social Choice and Individual Values* (2nd ed.). Cowles Foundation. | Phase 4 (impossibility theorem as formal foundation for why no perfect CHI exists; paired with Sen's partial-comparability escape); Debate 6 (commensurability) |
| Stuntz, W.J. (2001). The pathological politics of criminal law. *Michigan Law Review*, 100, 505–600. | Phase 4 (pathological expansion of criminal codes; core offenses stable; CHI sentencing ranges insulated from pathology); Debate 1 |
| Kleinfeld, J. (2019). Textual rules in criminal statutes. *UCLA Law Review*, 88, 1791+. | Phase 4 (instrumental statutory text; distinction between charging text and sentencing ranges); Debate 1 |
| Haugh, T. (2015). Overcriminalization's new harm paradigm. *Vanderbilt Law Review*, 68(5). | Phase 4 (overcriminalization as criminogenic; transparent CHI enhances legitimacy); Debate 5 (gaming/Goodhart's) |
