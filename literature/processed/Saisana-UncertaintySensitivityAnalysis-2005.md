Royal Statistical Society and Wiley are collaborating with JSTOR to digitize, preserve and extend access to Journal of the Royal Statistical Society. Series A (Statistics in Society)

 J. R. Statist. Soc. A (2005)

 168, Part 2, pp. 307-323

 Uncertainty and sensitivity analysis techniques as  tools for the quality assessment of composite

 indicators

 M. Saisana, A. Saltelli and S. Tarantola

 European Commission, Ispra, Italy

 [Received November 2002. Final revision July 2004]

 Summary. Composite indicators are increasingly used for bench-marking countries' perfor-

 mances. Yet doubts are often raised about the robustness of the resulting countries' rankings

 and about the significance of the associated policy message. We propose the use of uncertainty

 analysis and sensitivity analysis to gain useful insights during the process of building composite  indicators, including a contribution to the indicators' definition of quality and an assessment of

 the reliability of countries' rankings. We discuss to what extent the use of uncertainty and sensi-

 tivity analysis may increase transparency or make policy inference more defensible by applying  the methodology to a known composite indicator: the United Nations's technology achievement

 index.

 Keywords: Composite indicators; Robustness assessment; Sensitivity analysis; Uncertainty

 1. Introduction

 Composite indicators (often called indices) are increasingly used by statistical offices and

 national or international organizations to convey information on the status of countries in fields  such as the environment, economy, society or technological development; a review is given in

 Saisana and Tarantola (2002). Composite indicators are calculated by combining well-chosen

 subindicators into a single index, on the basis of an underlying model of the policy domain that

 one wishes to measure. This is most often achieved by a weighted combination of normalized

 subindicators' values.

 The main pros and cons of using composite indicators have been debated within the services

 of the European Commission. The discussion is summarized by Saisana and Tarantola (2002),

 from which we quote:

 'Pros

 -Composite indicators can be used to summarise complex or multi-dimensional issues, in view of sup porting decision-makers.  -Composite indicators provide the big picture. They can be easier to interpret than trying to find a

 trend in many separate indicators. They facilitate the task of ranking countries on complex issues.

 -Composite indicators can help attracting public interest by providing a summary figure with which

 to compare the performance across countries and their progress over time.

 -Composite indicators could help to reduce the size of a list of indicators or to include more information

 within the existing size limit.

 Address for correspondence: M. Saisana, Joint Research Centre, European Commission, Enrico Fermi 1, 21020

 Ispra, TP 361, Italy.

 E-mail: michaela.saisana@jrc.it

 ? 2005 Royal Statistical Society 0964-1998/05/168307

 308 M. Saisana, A. Saltelli and S. Tarantola

 'Cons

 -Composite indicators may send misleading, non-robust policy messages if they are poorly constructed  or misinterpreted. Sensitivity analysis can be used to test composite indicators for robustness.

 -The simple "big picture" results which composite indicators show may invite politicians to draw sim plistic policy conclusions. Composite indicators should be used in combination with the sub-indicators  to draw sophisticated policy conclusions.  -The construction of composite indicators involves stages where judgement has to be made: the selec-

 tion of sub-indicators, choice of model, weighting indicators and treatment of missing values etc. These

 judgements should be transparent and based on sound statistical principles.  -There could be more scope for Member States about composite indicators than on individual indica-

 tors. The selection of sub-indicators and weights could be the target of political challenge.

 -The composite indicators increase the quantity of data needed because data are required for all the

 sub-indicators and for a statistically significant analysis.'

 We shall tackle in the present paper many of the points that are raised by these conclusions.  In practice, it is difficult to imagine that the debate on the use of composite indicators will ever

 be settled. Just to give an example that is linked to our experience, official statisticians may tend

 to resent composite indicators, whereby a large amount of work in data collection and editing is

 'wasted' or 'hidden' behind a single number of dubious significance. However, the temptation

 of stakeholders and practitioners to summarize complex and sometime elusive processes (e.g.

 sustainability or a single-market policy) into a single figure to bench-mark country performance

 for policy consumption seems likewise irresistible.

 General procedures to assess uncertainty in building composite indicators are described in

 this paper. In particular, we limit ourselves to three types of uncertainties:  (a) alternative normalization methods for the values of the subindicators,  (b) alternative weighting approaches and finally  (c) uncertainty in the weights of the subindicators.

 Two combined tools are suggested: uncertainty analysis (UA) and sensitivity analysis (SA).

 UA focuses on how uncertainty in the input factors propagates through the structure of the

 composite indicator and affects the values of the composite indicator. SA studies how much

 each individual source of uncertainty contributes to the output variance.

 In the field of building composite indicators, UA is more often adopted than SA (Jamison

 and Sandbu, 2001; Freudenberg, 2003) and the two types of analysis are almost always treated

 separately. A synergistic use of UA and SA is proposed and presented in Section 2, consider-

 ably extending earlier attempts in this direction (Tarantola et al., 2000). The test case, which is

 described in Section 3, is the technology achievement index (TAI) that was developed by the

 United Nations (2001) to help policy makers to define technology strategies. Two normalization  methods and two participatory approaches for assigning weights to the subindicators (budget

 allocation (BA) and analytic hierarchy processes (AHPs)) have been applied in the present

 work. Section 4 discusses the results and aims to answer two key questions on the quality of the

 composite indicator.

 (a) Does the use of one normalization method and one set of weights in the development of  the composite indicator (e.g. the original TAI) provide a biased picture of the countries'  performance?

 (b) To what extent do the uncertain input factors (normalization methods, weighting schemes  and weights) affect the countries' ranks with respect to the original TAI?

 Section 5 summarizes our conclusions on the role that the combination of UA and SA can

 play as a quality assurance tool during the development of a composite indicator for policy

 making.

 Quality Assessment of Composite Indicators 309

 2. Methodological aspects in building composite indicators

 Several methods for calculating composite indicators from a set of subindicators were described  in Saisana and Tarantola (2002). The methods that are most frequently met in the literature are

 based on the rescaled values (equation (la)) or on the standardized values (equation (ib)). A

 composite indicator Y, for a given country c is most often a simple linear weighted function of  a total of Q normalized subindicators Iq,c with weights wq,

 xq,c - min(xq)

 Yc= E lqcWq, where I = C , min(xj) (la) -range(xq)

 Slqq Xq,c - mean(xq) q1 q~c = std(xq) (Ib)

 Here xq,c represents the raw value of the subindicator xq for country c.

 The difference in the values of the composite indicator between two countries A and B will  be an output of interest studied in our UA-SA.

 Q

 DAB = (Iq,A - Iq, B)Wq. (2)

 q=1

 Additionally, the average shift in countries' ranks will be explored. This statistic captures in a

 single number the relative shift in the position of the entire system of countries. It can be quan-

 tified as the average of the absolute differences in countries' ranks with respect to a reference  ranking over the M countries:

 I M

 RS -- Irankref(Yc) - rank(Yc)I. (3)

 M c=1

 The investigation of the Yc, DAB and Rs will be the scope of the UA and SA, targeting the

 questions that were raised in Section 1 on the quality of the composite indicator.

 2. 1. Uncertainty analysis

 In the first stage, the uncertain input factors in the estimation of the outputs Yc, DAB and Rs  must be acknowledged. In general, the uncertainties in the development of a composite indicator

 will arise from some or all of the steps in the construction line:

 (a) selection of subindicators,

 (b) data selection,  (c) data editing,  (d) data normalization,

 (e) weighting scheme,

 (f) weights' values and

 (g) composite indicator formula.  The most debated problem in building composite indicators is the difficulty in assessing

 properly the plurality of perspectives about the relative importance of the subindicators. Expe rience shows that disputes over the appropriate method of establishing weights cannot be easily

 resolved. Cox et al. (1992) summarized the difficulties that are commonly encountered when

 proposing weights to combine indicators into a single measure, and they concluded that many  published weighting schemes are either based on too complex multivariate methods or have little  meaning to society. For these reasons, participatory approaches, such as BA or AHPs, are often

 310 M. Saisana, A. Saltelli and S. Tarantola

 preferred, as they allow for an expression of the relative importance of the subindicators from  the societal viewpoint. In BA experts are invited to distribute a budget of points over a number  of subindicators, paying more for those indicators whose importance they want to emphasize

 (Moldan et al., 1997). The AHP is a widely used technique for multiattribute decision-making

 (Saaty, 1980, 1987). The AHP is based on ordinal pairwise comparisons of subindicators. For

 a given objective, the comparisons are made per pairs of subindicators, and the strength of

 preference is expressed on a semantic scale of 1 (equality) to 9 (i.e. a subindicator can be voted  to be nine times more important than the subindicator with which it is being compared). The

 relative weights of the subindicators are calculated by using an eigenvector technique, which

 as described in Saaty (1980) serves to resolve inconsistencies (e.g. a better than b better than c

 better than a loops). Note that the AHP approach would also allow the analyst to 'grade' the

 expert by measuring his or her inconsistencies.  In this work, we focus on three points of the (a)-(g) chain of composite indicator building,

 which can introduce uncertainty in the output variables Y,, DAB and Rs: the type of normali zation (be it with rescaled (equation (1 a)) or standardized values (equation (I b))), the weighting

 scheme (be it BA or AHP) and the subindicators' weights. We anticipate here that we shall

 translate all these uncertainties into a set of scalar input factors, to be sampled from their distri-

 butions. As a result, all outputs Y,, DAB and Rs are non-linear functions of the uncertain input

 factors, and the estimation of the probability distribution functions (PDFs) of Y,., DAB and Rs  is the purpose of the UA. The UA procedure is essentially based on simulations that are carried

 out on each of equations (1)-(3), termed henceforth the model. Various methods are available

 for evaluating output uncertainty.

 In the following, the Monte Carlo approach is presented, which is based on performing

 multiple evaluations of the model with k randomly selected model input factors. The procedure  involves six steps.

 (a) Assign a PDF to each input factor Xi. The first input factor, X I, is the trigger to select

 the type of normalization method; the second input factor, X2, is the trigger to select  the weighting scheme. Factors X3 --Xk are random numbers that are used to select the  Q (= k - 2) uncertain weights.

 (b) Generate randomly N combinations of independent input factors X', with I = 1,..., N

 (a set Xi = X', X:,..., X of input factors is called a sample).

 (c) For each sample 1, select a normalization method and weighting scheme based on Xi,

 (d) For each sample 1, use factors X3-Xk to select the weights. X2, ...

 (e) Evaluate the model, i.e. by computing the output value Y1, where Y' is either Yc, the

 value of the composite indicator for each country, or DAB, the difference between two  countries, or Rs, the averaged shift in countries' ranks.

 (f) Close the loop over 1, and analyse the resulting output vector YV, with I = 1..., N.

 The generation of samples can be performed by using various procedures, such as simple  random sampling, stratified sampling, quasi-random sampling or others (Saltelli, Chan and

 Scott, 2000). The sequence of Y' allows the empirical PDF of the output Y to be built. The

 characteristics of the PDF, such as the variance and higher order moments, can be estimated

 with an arbitrary level of precision that is related to the size of the simulation N.

 2.2. Sensitivity analysis using variance-based techniques

 A necessary step when designing an SA is to identify a few summary variables that describe

 concisely, yet exhaustively, the message that is provided by a model (Saltelli, Tarantola and

 Quality Assessment of Composite Indicators 311

 Campolongo, 2000). In the present application for instance, although an uncertainty analysis

 of Yc is necessary, SA is only applied to the two summary model outputs, DAB and Rs, as they  are relevant to the quality assessment of a composite indicator.

 For non-linear models, such as our composite indicator happens to be when normalization

 methods, weighting schemes and weights are all sampled, variance-based techniques for SA

 are the most appropriate (Saltelli, Tarantola and Campolongo, 2000). The importance of a

 given input factor Xi can be measured via the so-called sensitivity index, which is defined as

 the fractional contribution to the model output variance due to the uncertainty in Xi. For

 k independent input factors, the sensitivity indices can be computed by using the following

 decomposition formula for the total output variance V(Y) of the output Y:

 V(Y)= E Vi +E E Vij + -...? + Vl2...k (4)

 i i j>i

 where

 Vi= Vx, {Ex_ (YI Xi)}, (5)

 Vij = Vx, xj{Ex_ j(YIXi, Xj)} - Vx {Ex_, (YIXj)} - Vxj{Ex_j(YIXj)} (6)

 X-i, i.e. over all factors except Xi, including the marginal distributions for these factors, whereas and so on. In computing Vxi { Ex_i (Y|Xi) }, the expectation Ex_, would call for an integral over

 measure of the fraction of the unconditional output variance V(Y) that is accounted for by the the variance Vxi would imply a further integral over Xi and its marginal distribution. A first

 uncertainty in Xi is the first-order sensitivity index for the factor Xi defined as

 Si = Vi / V. (7)

 Terms above the first term in equation (4) are known as interactions. A model without inter actions among its input factors is said to be additive. In this case, E= 1Si = 1 and the first-order

 conditional variances of equation (5) are all that we need to know to decompose the model

 output variance. For a non-additive model, higher order sensitivity indices, which are respon sible for interaction effects among sets of input factors, must be computed. However, higher  order sensitivity indices are usually not estimated, as in a model with k factors the total number  of indices (including the Sis) that should be estimated is as high as 2k - 1. For this reason, a more  compact sensitivity measure is used. This is the total effect sensitivity index, which concentrates  in one single term all the interactions involving a given factor Xi. To exemplify, for a model of  k = 3 independent factors, the three total sensitivity indices would be

 ST1 = -V (YxI = S1 + S12 + S13 + S123. (8) V(Y) - Vx2X3{Ex, (Y|X2, X3)}

 V( Y)

 Analogously:

 ST2 = S2 + S12 + S23 + S123,

 ST3 = S3 + S13 + S23 + S123-

 The conditional variance in equation (8) can be written generally as Vx_i { Exi (YIX-i)} (Homma and Saltelli, 1996). It expresses the total contribution to the variance of Y due to non-Xi, i.e.  to the k- 1 remaining factors, so that V(Y)- Vx_i {Ex (YIX-i)} includes all terms, i.e. a first-

 order term as well as interactions in equation (4), that involve factor Xi. In general E=L1 STi 1,  with equality if there are no interactions. For a given factor Xi a notable difference between

 STi and Si flags an important role of interactions for that factor in Y. Highlighting interactions  between input factors helps us to improve our understanding of the model structure. Estima-

 tors for both Si and STi are provided by a variety of methods reviewed in Chan et al. (2000).

 312 M. Saisana, A. Saltelli and S. Tarantola

 Here the method of Sobol' (1993), in its improved version due to Saltelli (2002), is used. The

 method of Sobol' uses quasi-random sampling of the input factors. The pair (Si, STi) give a fairly  good description of the model sensitivities at a reasonable cost, which for the improved Sobol'

 method is of 2n(k + 1) model evaluations, where n represents the sample size that is required

 to approximate the multidimensional integration implicit in equation (5) to a plain sum. n can  vary in the 100-1000 range.

 The extended variance-based techniques that have been described so far display several attrac tive features, such as

 (a) model independence (which is appropriate for non-linear and non-additive models),

 (b) exploration of the whole range of variation in the input factors, instead of just sampling

 factors over a limited number of values, as done for example in fractional factorial designs

 (Box et al., 1978), and

 (c) consideration of interaction effects.

 When the uncertain input factors Xi are dependent, the output variance cannot be decom-

 posed as in equation (4). The Si- and STi-indices are still valid sensitivity measures for Xi, though

 their interpretation changes as, for example, Si carries over also the effects of other factors that

 can be positively or negatively correlated to Xi (see Saltelli and Tarantola (2002)). Estimation

 procedures are offered in Saltelli et al. (2004).

 The extended variance-based methods, including the improved version of Sobol', for both

 dependent and independent input factors, are implemented in the freely distributed software

 SIM LAB (Saltelli et al., 2004).

 3. Case-study: technology achievement index

 The TAI is a composite indicator that was developed by the United Nations and was described

 in detail in United Nations (2001). The report argues that development strategies need to be

 redefined in the network age and calls on policy makers to take a new look at the current techno-

 logical achievements. The TAI composite indicator should help a country to assess its position

 relative to others, possibly to bench-mark policies. Although acknowledging that many elements  make up a country's technological achievement, the index suggests that an overall assessment is  more easily made on the basis of a single composite measure. Like other composite indices in the  Human Development Report series, such as the human development index, the TAI is suggested  for summary purposes, to be followed by individual analysis of the underlying indicators. The  design of the index reflects two particular concerns. The first is to compare policy effective ness across all countries, regardless of the level of technological development. The second is to  identify, and to send messages to, developing countries. To accomplish this, the index must be  able to discriminate between countries at the lower end of the range. The TAI focuses on four

 dimensions of technological capacity.

 (a) Creation of technology: two subindicators are used to capture the level of innovation in a

 society, the number of patents granted per capita (to reflect the current level of invention

 activities) and the receipts of royalty and licence fees from abroad per capita (to reflect  the stock of successful innovations of the past that are still useful and hence have market

 value).

 (b) Diffusion of recent innovations: all countries must adopt innovations to benefit from

 the opportunities of the network age. This diffusion is measured by two subindicators:  diffusion of the Internet (which is indispensable to participation) and by exports of high  and medium technology products as a share of all exports.

 Quality Assessment of Composite Indicators 313

 (c) Diffusion of old innovations: participation in the network age requires diffusion of many

 old innovations, as technological advance is a cumulative process, and widespread diffu-

 sion of older innovations is necessary for the adoption of later innovations. Two subindica-

 tors are included here, telephones and electricity, which are especially important because  they are needed to use newer technologies and are also pervasive inputs to a multitude of

 human activities. Both indicators are expressed as logarithms, as they are important at

 the earlier stages of technological advance but not at the most advanced stages. Expressing  the measure in logarithms ensures that, as the level increases, it contributes less to the

 index.

 (d) Human skills: a critical mass of skills is indispensable to technological dynamism. The

 foundations of such ability are basic education to develop cognitive skills and skills in

 science and mathematics. Two subindicators are used to reflect the human skills that are

 needed to create and absorb innovations: mean years of schooling and gross enrolment

 ratio of tertiary students enrolled in science, mathematics and engineering.

 The data that are used to construct the TAI are from international series that are most widely  used in analyses of trends in technology and so are considered the most reliable of the available

 sets (United Nations (2001), page 46). For each of the eight subindicators (two subindicators

 per dimension) the observed minimum and maximum values (among all available countries) are

 chosen as 'goalposts' (Table 1) and performance in each subindicator is expressed as a value

 between 0 and 1 by applying equation (la). The original TAI is calculated for 72 countries, for  which data are available and of acceptable quality, as the simple average of the eight subindi-

 cators, therefore considering that all subindicators are equally important in the development

 of the composite indicator. The statistics for the raw data of the subindicators for the 72 coun tries are given in Table 1. The data for patents, royalties and Internet hosts exhibit the highest  coefficient of variation (the ratio of the standard deviation to the mean), underlining the high  variability in these three subindicators. The distributions of data for patents and electricity are  the most skewed (positively).

 Table 1. Statistical properties of the eight subindicators that compose the TAI

 Subindicator Goalposts for calculating the TAI Statistics across 72 countries

 Observed Observed Mean Standard Skewness  minimum value maximum value deviation

 Patents granted to residents (per 0 994 109 199 3.4

 million people)

 Royalties and licence fees received 0.0 272.6 29.3 46.1 1.8

 (US $ per 1000 people)

 Internet hosts (per 1000 people) 0.0 232.4 32.3 51.1 2.0  High and medium technology 0.0 80.8 30.1 23.0 0.4

 exports (% of total goods exports)

 Telephones, main line and cellular 1 901 443 402 0.6

 (per 1000 people)

 Electricity consumption 22 6969 3496 4274 2.5

 (kW h per capita)

 Mean years of schooling (age 0.8 12.0 7.2 2.5 -0.1

 15 years and above)

 Gross tertiary science enrolment 0.1 27.4 8.1 6.2 1.0

 ratio (%)

 314 M. Saisana, A. Saltelli and S. Tarantola

 Correlation analysis reveals that the eight subindicators have an average bivariate correlation  of 0.55 and that six pairs of indicators have a correlation coefficient that is higher than 0.70.

 The covariance of subindicators is further investigated via factor analysis. To account for at

 least 90% of the variance in the data set of all the subindicators, five principal components

 are needed. This result indicates that the phenomenon that is described by the set of the eight  subindicators is quite multidimensional. A higher correlation between the subindicators would  have resulted in fewer components.

 Depending on a school of thought, one may see a high correlation between subindicators  as something to correct for, e.g. by making the weight for a given subindicator inversely

 proportional to the arithmetic mean of the coefficients of determination for each bivariate

 correlation that includes the given subindicator (Saisana and Tarantola, 2002). An example

 of this approach is the index of relative intensity of regional problems in the European Union  (Commission of the European Communities, 1984). Practitioners of multicriteria decision anal ysis would instead tend to consider the existence of correlations as a feature of the problem, not  to be corrected for, as correlated subindicators may indeed reflect non-compensational different

 features of the problem.

 In the present study, we deviate from the original deterministic formulation of the index,

 in that we allow both the normalization and the weighting procedures to vary, and we sam-

 ple the weights rather than keep them equal and fixed as in the original TAI. Henceforth, we

 indicate the extended composite indicator as Monte Carlo TAI (MCTAI). The weights for the

 eight subindicators have been derived from two pilot surveys that were carried out across 20  informed interviewees at the authors' institute, using the two participatory approaches BA and  AHP that were described in Section 2. For the present exercise, the interviewees had no bearing  on the issue being measured. In reality, interviewees should be part of a community of stake holders with a legitimate stake. To give an example, in the internal market composite indicator,  the experts were members of a committee representing the European Union member countries

 whose performance was being measured (Tarantola et al., 2002).

 Fig. I presents the eight scatterplots of the weights for each subindicator provided by the  20 interviewees using the two alternative weighting schemes. In other words, each point in a  scatterplot represents the weight that was given to the subindicator by one interviewee when

 requested in a BA or an AHP approach. The deviation of the weights from the 45?-line of perfect  agreement between the two weighting schemes is an interesting feature of this analysis, revealing

 the human tendency to reply differently to different formulations of the same question. Both

 weighting approaches have advantages and limitations. The weights that are provided by BA

 are less spread than for an AHP for each subindicator and the variance of the weights across

 the eight indicators is smaller for BA than for AHP. However, the AHP is based on pairwise

 comparisons, where perception is sufficiently high to make a distinction between subindicators.  In BA all the subindicators are compared at a glance, and this might lead to circular thinking  across subindicators, creating difficulties in assigning weights, particularly when the number of  subindicators is high.

 The 10 uncertain input factors in our analysis are described in Table 2 with their associated

 PDF. The input factors are sampled in a quasi-random sampling scheme (Sobol', 1967) using

 a base sample of size n = 512 (which is required for the computation of the integral; see the

 discussion in Section 2.2) and the composite indicator values per country are calculated by  performing 2n(k + 1) = 11264 simulations. The MCTAI for the 72 countries is calculated as

 follows: the data for each subindicator are first normalized according to the trigger X1 that is  sampled from a uniform distribution [0, 1], where for 0 < X1 <0.5 equation l(a) is used and for  0.5 < X? < 1 equation l(b) is used. The trigger X2, with the same type of PDF as X1, guides the

 Quality Assessment of Composite Indicators 315

 0.5

 0.4

 0.31 0 0 0

 000

 (a) (b) (c) (d)

 0.5

 0.4

 0.3 000. 00m

 03

 0.20 - 0 000 00

 0 0 0 000 0

 0.0 -. ._

 0.0 0.1 0.2 0.3 0.4 0.5 0.0 0.1 0.2 0.3 0.4 0.5 0.0 0.1 0.2 0.3 0.4 0.5 0.0 0.1 0.2 0.3 0.4 0.5

 (e) (f) (g) (h)

 Fig. 1. Scatterplots of weights (range between 0.0 and 0.5) for the eight subindicators of MCTAI (the weights

 have been derived from pilot surveys of 20 informed interviewees using BA (vertical axes) and AHPs (hori-

 zontal axes); - , best fit linear regression lines): (a) patents; (b) royalties; (c) Internet; (d) exports;

 (e) telephones; (f) electricity; (g) schooling; (h) enrolment

 Table 2. The 10 uncertain input factors for the analysis

 Input factor Definition PDF Range

 X1, rescaled or Normalization method Uniform [0, 1], where [0, 0.5] - rescaled

 standardized values and (0.5, 1] - standardized

 values values

 X2, BA or AHP Weighting scheme Uniform [0, 1], where [0, 0.5] - BA and

 and (0.5, 1] = AHP

 X3, W-patents Weights list for patents Discrete, uniform [1, 2,..., 20]

 X4, W-royalties Weights list for royalties Discrete, uniform [1, 2, .., 20]

 X5, W-internet Weights list for Internet Discrete, uniform [1, 2, ...,20]

 X6, W-exports Weights list for exports Discrete, uniform [1, 2,..., 20]

 X7, W-telephone Weights list for telephone Discrete, uniform [1, 2,...,20]  X8, W-electricity Weights list for electricity Discrete, uniform [1, 2,..., 20]  X9, W-schooling Weights list for schooling Discrete, uniform [1, 2,...,20]  X10, W-enrolment Weights list for enrolment Discrete, uniform [1, 2, .., 20]

 selection of the weighting scheme. Then the weights are sampled independently of one another  as follows. Each factor X3-X10 is sampled from a discrete distribution [1-20], representing the

 number of the interviewee, whose assigned weight is taken for the simulation. After all the

 weights have been assigned, they are scaled to a unit sum. The MCTAI is then calculated as

 the weighted average of the normalized subindicators. Linear scaling is finally applied to the

 composite indicator values per type of normalization method, to convert them in the range

 [0, 100].  Note that this assessment of uncertainties covers only points (d)-(f) in the uncertainty propa-

 gation chain (a)-(g) that was described in Section 2.1. To give an example, given the lack of

 information on the uncertainty in the values of the subindicators, the data are considered to

 be error free for this test case, and are not, therefore, among the input factors in the Monte-

 316 M. Saisana, A. Saltelli and S. Tarantola

 Carlo-based UA. In Tarantola et al. (2000) the reader can find an analysis where data, weights

 and model uncertainties are compounded. One might likewise investigate the inclusion or exclu sion of individual subindicators. This was not done explicitly here, though zero weights were

 occasionally assigned by the experts in the BA approach (Fig. 1).

 4. Results

 4. 1. Uncertainty analysis on the composite indicator values

 The MCTAI values for the 72 countries have been calculated for each of the 11264 combina-

 tions of normalization method, weighting scheme and set of weights. Fig. 2 displays the median  (black bar) and the corresponding fifth and 95th percentiles (bounds) of the distribution of the

 MCTAI per country. The crosses indicate the original value of the 2001 TAI.

 From this analysis we can conclude the following.

 (a) For most countries, the original TAI value is very close to the MCTAI median value of

 the distribution that acknowledges all three types of uncertainty. This implies that the  original TAI, despite being developed by using one normalization method and one set of  weights (equal weights), provides a picture of the countries' technological achievements  that is not generally biased.

 (b) There is, however, one country, the Netherlands, that is strongly favoured in the original  TAI. Originally, the performance of the Netherlands follows those of the five best coun tries, including Finland, the USA, Sweden, Japan and Korea. However, when accounting  for changes in the normalization method, the weighting scheme and the set of weights,

 its performance falls at the ninth position, behind Singapore, the UK and Australia.

 Singapore, in contrast, is ranked sixth in the MCTAI, instead of 10th in the original TAI.

 (c) The United Nations's TAI is not intended to be a measure of which country is leading in  global technology development, but to focus on how well the country as a whole is par ticipating in creating and using technology. Take for example Finland (TAloriginal = 74.4)

 and the USA (TAloriginal = 73.3). The USA, a global technology powerhouse, has far

 more inventions and Internet hosts in total than Finland does, although in Finland  more is being done to develop a technological skill base throughout the population.

 When accounting for the uncertainties in the input factors, the message is reinforced,  as the distance between the two countries is more evident (MCTAImedian,Finland = 83.1;

 MCTAImedian,USA = 78.1).

 4.2. Sensitivity analysis on selected outputs using Sobol' sensitivity measures

 The previous analysis motivates a quantitative estimation of the effect of the variation in the  input factors on two output variables of interest:

 (a) the difference DAB (equation (2)) in the composite indicator values between two countries

 (the Netherlands and Singapore are selected owing to the discussion above);

 (b) the average shift in countries' ranks, Rs (equation (3)), taking the original TAI as the

 reference.

 The sensitivity measures Si and STi, described previously in Section 2.2, have been computed

 using the same set of 11264 simulations for the two output variables of interest.

 4.2.1. Output 1: DNL,SG, difference in performance between the Netherlands and Singapore

 The histogram that is displayed in Fig. 3 represents the outcome of the UA on the differences in

 the composite indicator values between the Netherlands and Singapore (ranks sixth and 10th

 0

 0

 0

 so

 CD

 0

 C,

 CL

 C,)

 0

 0)

 0 E

 ) X

 c,)

 CA)

 cm

 sX

 0

 C,)

 0

 aa

 R.

 2 1)

 - ? 0. 1

 -L

 91.

 C,)

 u u GO. ? E

 3YOr. C-0r 'E!e! o .4N .2 ~ ~g0

 3 u am

 Fig. 2. Results of UA showing the original TAI for 2001 (-), and the median (x) and the corresponding 5th and 95th percentiles (bounds) of the distribution  of the MCTAI for 72 countries (uncertain input factors: normalization method, weighting scheme and weights for the subindicators; the countries are ordered

 according to their median values)

 318 M. Saisana, A. Saltelli and S. Tarantola

 350

 Singapore Netherlands

 300 performs better performs better

 c 250

 8 200

 U- o 150

 g 100

 L.

 50

 0

 -30 -25 -20 -15 -10 -5 0 5 10 15 20 25 30

 TAINL - TAISG

 Fig. 3. Results of UA for the output variable DNL SG: difference in the composite indicator values between

 the Netherlands and Singapore (uncertain input factors: normalization method, weighting scheme and weights

 for the subindicators)

 Table 3. Sobol' sensitivity measures of the

 first-order and total effect for the output DNL SG:

 difference in the composite indicator values  between the Netherlands and Singaporet

 Input First-order Total effect STi - Si

 factor effect (Si) (STi)

 X1 0.00 0.03 0.03  X2 0.14 0.56 0.42  X3 0.00 0.00 0.00

 X4 0.01 0.04 0.03  X5 0.02 0.05 0.03

 X6 0.02 0.17 0.15  X7 0.02 0.07 0.06

 X8 0.17 0.37 0.20

 X9 0.02 0.10 0.08

 X1o 0.12 0.29 0.16

 Sum 0.52 1.69 1.17

 tValues in italics (greater than 0.10) indicate

 important input factors based on Si or STi - Si.

 in the original TAI and ninth and sixth in the MCTAI respectively). The left-hand region of

 Fig. 3, where Singapore performs better than the Netherlands, covers about 65% of the total  area and this shows that Singapore participates in creating and using technology more than the  Netherlands does, in contradiction with the original TAI.

 The sensitivity measures Si and Sri for DNL,SG are shown in Table 3. When we use Si for

 SA, we are looking for important input factors that-if fixed singly-would reduce the variance  the most in the output variable. Importance in SA, though, is a relative notion and there is no

 established threshold: one usually looks at the Si-values and the distances between them and

 considers the first few factors as important. In this work, an input factor will be considered to  be important if Si > 0.10 (i.e. if the input factor explains more than 1/k of the output variance).  Thus, we see that the weights for electricity and enrolment are important variables, as well as

 Quality Assessment of Composite Indicators 319

 the type of weighting approach (BA or AHP). In contrast, the selection of the normalization  method does not affect the variance of DNL,SG. All the input factors, taken singly, explain

 52% of the output variance. The remaining 48% is the fraction of the output variance that is

 not explained by the input factors taken singly, but by interactions between the factors them-

 selves. The larger the difference Sri - Si, the more that factor is involved in interactions with the

 other factors. We can see that the trigger for the weighting scheme (BA or AHP) has a strong  interaction with other factors, mainly with the weights for electricity, enrolment and exports.  When we use STi for SA, we customarily look for factors with very small STi , which can thus  confidently be declared non-influential, and hence for example fixed in a subsequent iteration  of the analysis (Saltelli and Tarantola, 2002). The high value of Sni for the weight of export tells

 us that it cannot be fixed in spite of its low Si.

 The information that is provided by SA, e.g. the importance of the trigger for the weight-

 ing scheme, of the weights of electricity and enrolment, can be used to investigate further

 the difference in the ranking of the Netherlands (sixth in the original TAI; ninth in the  MCTAI).

 Let us start by investigating the relative performance between the Netherlands and Singapore

 in the two-dimensional space of the 'trigger for weighting scheme' and the 'weight of electricity'.

 Fig. 4(a) shows the box plots of the values for the weight of electricity for the two weighting

 schemes (i.e. BA or AHP) for the cases where the performance of the Netherlands is better

 than, worse than or equal to that of Singapore. The total of 11264 samples has been used. The

 same plot has been repeated for the 'trigger for weighting scheme' and the 'weight of enrolment'

 and is shown in Fig. 4(b). With respect to the original TAI, MCTAI favours Singapore when

 high weights are assigned to the enrolment subindicator, for which Singapore is much better  than the Netherlands (in 3684 + 3699 = 7383 samples), and/or to the electricity subindicator, for  which Singapore is marginally better than the Netherlands. The relative performance between  the Netherlands and Singapore on the 'weight of enrolment-weight of electricity' plane, which

 is not shown here, confirms that Singapore is better than the Netherlands mostly when the

 weight for enrolment is high, whereas the weight for electricity can only make a difference when

 extremely high values for it are assigned in the AHP.

 4.2.2. Output 2: RS, average shift in countries' ranks with respect to the original technology

 achievement index

 The Sobol' measures of first-order (Si) and total effect (STi) for the second output are shown in  Table 4. The trigger for the weighting scheme and the weight of exports are the most important  factors, explaining 35% of the output variance, whereas all the input factors taken singly explain  44% of the output variance. The high influence of the weight of exports on the variance of Rs

 is due to Australia, Singapore, Norway, New Zealand, Greece, Mexico, Chile and Malaysia,

 for which the subindicator's values for exports are lower than the 20th or higher than the 92nd  percentiles. The remaining 56% of the output variance that is not explained by the input factors

 taken singly is due to the interactions between the factors themselves. We can see that the trigger

 for the weighting scheme has a strong interaction with the weight of exports as for DNL,SG.  Note that the weight of exports contributes to the output variance more through interactions  than singly. Interestingly, the normalization method has no influence on the variation of the  output.

 This type of analysis has quantified the influence of the input factors on the average shift in

 countries' ranks with respect to the original TAI and has indicated that it is the weighting scheme  interacting mainly with the weight of exports that can influence the ranking of the countries in

 the MCTAI with respect to the original TAI.

 320 M. Saisana, A. Saltelli and S. Tarantola

 Ns=2545 Ns=68 Ns=3030 Ns=1251 Ns=21 Ns=4349

 0.5 +

 +

 0.45 +

 0.4

 0.35

 +

 . 0.3

 +

 Z0.25

 2 --

 0.15 --

 0.1

 0.05

 0-

 NL better Similar SG better NL better Similar SG better

 <B----------- udget Allocation-------------><------Analytic Hierarchy Process------->

 (a)

 Ns=1916 Ns=43 Ns=3684 Ns=1880 Ns=42 Ns=3699

 0.5-

 I-r

 0.4-

 E

 2 0.3-

 a)

 : 0.2

 0.1 I _L

 I+ +

 + +

 0-

 NL better Similar SG better NL better Similar SG better

 <------------Budget Allocation-------------><------Analytic Hierarchy Process------->

 (b)

 Fig. 4. Box plots of 11 264 values for (a) the weight for electricity and (b) the weight for enrolment with

 respect to the two weighting schemes (BA and the AHP) and the relative performance between the Nether-

 lands (NL) and Singapore (SG) (the numbers of samples, Ns, in each group are given on top of each plot):

 +, outlier

 Quality Assessment of Composite Indicators 321

 Table 4. Sobol' sensitivity measures of the

 first-order and total effect for the output 'aver-

 age shift in countries' ranks with respect to the

 original TAI't

 Input First-order Total effect STi - Si

 factor index (Si) index (STi)

 X1 0.00 0.06 0.06  X2 0.21 0.56 0.36  X3 0.00 0.00 0.00

 X4 0.02 0.02 0.01

 X5 0.01 0.03 0.02  X6 0.14 0.44 0.30

 X7 0.03 0.05 0.02

 X8 0.04 0.13 0.10  X9 0.00 0.09 0.09

 Xlo 0.00 0.14 0.14

 Sum 0.44 1.53 1.09

 tValues in italics (greater than 0.10) indicate

 important input factors based on Si or STi - Si.

 4.3. Worthiness of the composite indicator

 Now that-having propagated uncertainties-the value of the composite indicator is no longer  a simple number, but a distribution of values, the composite indicator might be seen to lose

 relevance if a high fraction of countries were to overlap with one another. A first remark is that

 some of the overlap in Fig. 2 is only exaggerated; once the correlation between the MCTAI for  pairs of countries is explicitly acknowledged, the overlap becomes much smaller than is implied  by the bars in Fig. 2. On a more general level, there is a trade-off between the level of uncer tainty that is included in the composite indicator and its worthiness, which is herein considered  as the capacity of the same index to discriminate effectively between countries. If the purpose  of an index in a given policy context were to be to embarrass, e.g. to spur lazy countries into  action, then again including layers of uncertainty may be seen as counter-productive. However,  a careful analysis of uncertainties seems to us to make the comparison more robust. The index

 is no longer a magic number corresponding to a crisp normalization, weighting scheme and

 weight assignment, but reflects uncertainty and ambiguity in a more transparent and defensible

 fashion.

 5. Conclusions and future work

 This work has shown how to use global uncertainty and SA and other statistical techniques for  the quality assessment of composite indicators, in general, and demonstrated their use on the

 United Nations's TAI. Three types of uncertainties have been acknowledged:

 (a) alternative normalization methods for the values of the subindicators,

 (b) alternative weighting approaches (such as BA and the AHP) and finally

 (c) uncertainty in the weights of the subindicators.  The analysis was useful in showing that

 (i) the original version of the composite indicator provided a picture of the countries'

 322 M. Saisana, A. Saltelli and S. Tarantola  relative performances that is similar to the indicator where the three types of uncertainties

 are accounted for,

 (ii) there are cases where countries' rankings change significantly between the original and  extended TAI, i.e. the Netherlands and Singapore in the present exercise, and in identi-

 fying the reason and the regions in the space of the weights that favour one country with

 respect to another,  (iii) the message of what the index aims at measuring (i.e. a country's participation in creating

 and using technology and not which country is leading in global technology development)  can be better communicated to the public when the uncertainties in the input factors are

 taken into consideration and

 (iv) the weighting approach (through interaction with a few weights for the subindicators)  affects the countries' ranks (which is useful to focus efforts on reducing the uncertainty

 bounds for the MCTAI), whereas the normalization method has no influence on the

 rankings.

 The iterative use of UA and SA during the preparation of composite indicators could there fore contribute to the well structuring of composite indicators, could provide information on  whether the countries' rankings measure anything meaningful and could reduce the possibility  that composite indicators may send misleading or non-robust policy messages.

 The verification that is offered in the present work is nevertheless partial. We have not

 considered as uncertain the values for the subindicators, because no estimates of the measure-

 ment errors are available for the raw data. Furthermore we have implicitly assumed that all

 the plurality of the debate (i.e. the sources of uncertainty) is captured by the variability in the

 weights, be it with the BA or AHP alternatives and the normalization method. Although the

 latter assumption is not far fetched, and one sees in practice examples where this happens,

 e.g. the European Union internal market score-board and European Union Internet business

 readiness index (for a review, see Saisana and Tarantola (2002)), we might also have situations

 where the very concept of a composite indicator is rejected by some of the stakeholders, or  where the model underlying the weighting is called into question. To give an example, some

 investigators (Munda and Nardo, 2003) have argued that, even if weights are customarily

 assigned as a measure of relative importance when using linear aggregation, they have in fact a  meaning of a substitution rate, whereby for example an equal weight for two indicators would  mean that we are willing to trade one unit down in one indicator for one unit up in another.

 Even if we have not propagated these other categories of uncertainty (data uncertainty and

 underlying model uncertainty) in our example, it should be clear to the reader that this can be  done in principle without difficulty, following a similar approach to that presented herein.

 References

 Box, G., Hunter, W. and Hunter, J. (1978) Statistics for Experimenters. New York: Wiley.

 Chan, K., Tarantola, S., Saltelli, A. and Sobol', I. M. (2000) Variance based methods. In Sensitivity Analysis

 (eds A. Saltelli, K. Chan and M. Scott), pp. 167-197. New York: Wiley.

 Commission of the European Communities (1984) The regions of Europe: second periodic report on the social  and economic situation of the regions of the Community, together with a statement of the regional policy

 committee, OPOCE. Report. Commision of the European Communities, Luxembourg.

 Cox, D. R., Fitzpatrick, R., Fletcher, A. E., Gore, S. M., Spiegelhalter, D. J. and Jones, D. R. (1992) Quality-of-life

 assessment: can we keep it simple (with discussion)? J R. Statist. Soc. A, 155, 353-393.

 Freudenberg, M. (2003) Composite indicators of country performance: a critical assessment. Report DSTI/

 IND(2003)5. Organisation for Economic Co-operation and Development, Paris.

 Homma, T. and Saltelli, A. (1996) Importance measures in global sensitivity analysis of model output. Reliab.

 Engng Syst. Sfty, 52, 1-17.

 Jamison, D. and Sandbu, M. (2001) WHO ranking of health system performance. Science, 293, 1595-1596.

 Quality Assessment of Composite Indicators 323

 Moldan, B., Billharz, S. and Matravers, R. (1997) Sustainability Indicators: Report of the Project on Indicators of  Sustainable Development. Chichester: Wiley.

 Munda, G. and Nardo, M. (2003) On the methodological foundations of composite indicators used for

 ranking countries. Organisation for Economic Co-operation and Development-Joint Research Centre Wrkshp

 Composite Indicators of Country Performance, Ispra, May 12th. (Available from http: / /webfarm. j rc.  cec. eu. int/uasa/evt-OECD-JRC . asp.)

 Saaty, R. W. (1987) The analytic hierarchy process-what it is and how it is used. Math. Modllng, 9, 161-176.  Saaty, T. L. (1980) The Analytic Hierarchy Process. New York: McGraw-Hill.

 Saisana, M. and Tarantola, S. (2002) State-of-the-art report on current methodologies and practices for composite

 indicator development. Report EUR 20408 EN. European Commission-Joint Research Centre, Ispra.

 Saltelli, A. (2002) Making best use of model valuations to compute sensitivity indices. Comput. Phys. Communs,

 145, 280-297.  Saltelli, A., Chan, K. and Scott, M. (2000) Sensitivity Analysis. New York: Wiley.  Saltelli, A. and Tarantola, S. (2002) On the relative importance of input factors in mathematical models: safety

 assessment for nuclear waste disposal. J Am. Statist. Ass., 97, 702-709.  Saltelli, A., Tarantola, S. and Campolongo, F. (2000) Sensitivity analysis as an ingredient of modelling. Statist.  Sci., 15, 377-395.

 Saltelli, A., Tarantola, S., Campolongo, E and Ratto, M. (2004) Sensitivity Analysis in Practice, a Guide to

 Assessing Scientific Models. New York: Wiley.

 Sobol', I. M. (1967) On the distribution of points in a cube and the approximate evaluation of integrals. USSR  Comput. Math. Phys., 7, 86-112.

 Sobol', I. M. (1993) Sensitivity analysis for non-linear mathematical models. Math. Modllng Comput. Exp., 1,

 407-414.

 Tarantola, S., Jesinghaus, J. and Puolamaa, M. (2000) Global sensitivity analysis: a quality assurance tool in

 environmental policy modelling. In Sensitivity Analysis (eds A. Saltelli, K. Chan and M. Scott), pp. 385-397.

 New York: Wiley.

 Tarantola, S., Saisana, M., Saltelli, A., Schmiedel, F. and Leapman, N. (2002) Statistical techniques and partici-

 patory approaches for the composition of the European Internal Market Index 1992-2001. Report EUR 20547

 EN. European Commission-Joint Research Centre, Ispra.

 United Nations (2001) Human Development Report. Oxford: Oxford University Press.

