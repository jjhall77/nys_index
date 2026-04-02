Article

Journal of Research in Crime and Delinquency 48(1) 58-82

# Testing the Stability of Crime Patterns: Implications for Theory and Policy

ª The Author(s) 2011 Reprints and permission:

sagepub.com/journalsPermissions.nav DOI: 10.1177/0022427810384136 http://jrcd.sagepub.com

Martin A. Andresen1 and Nicolas Malleson2

Abstract

Recent research in the ‘‘crime at places’’ literature is concerned with smaller units of analysis than conventional spatial criminology. An important issue is whether the spatial patterns observed in conventional spatial criminology focused on neighborhoods remain when the analysis shifts to street segments. In this article, the authors use a new spatial point pattern test that identifies the similarity in spatial point patterns. This test is local in nature such that the output can be mapped showing where differences are present. Using this test, the authors investigate the stability of crime patterns moving from census tracts to dissemination areas to street segments. The authors find that general crime patterns are somewhat similar at all spatial scales, but finer scales of analysis reveal significant variations within larger units. This result demonstrates the importance of analyzing crime patterns at small scales and has important implications for further theoretical development and policy implementation.

- 1 School of Criminology, Simon Fraser University, Burnaby, BC, Canada
- 2 School of Geography, University of Leeds, West Yorkshire, United Kingdom


Corresponding Author: Martin A. Andresen, School of Criminology, Simon Fraser University, 8888 University Drive, Burnaby, BC V5A 1S6, Canada Email: andresen@sfu.ca

Keywords crime at places, point pattern analysis, spatial criminology

Introduction

During the past 175 years, research in spatial criminology has been performedateverfinerspatialresolutions(Weisburd,Bruinsma,andBernasco 2009). Moving from counties to towns to wards and to neighborhoods, we are forcedtoask:whatistheappropriatescaleofanalysisforcrime?Isittheneighborhood? Or are there relatively few ‘‘chronic places’’ that make an entire neighborhood problematic, much like a small percentage of offenders may cause a significant portion of trouble (Wolfgang, Figlio, and Sellin 1972). Research in the ‘‘crime at places’’ literature, a term coined by Eck and Weisburd (1995),1 has emerged that uses microspatial units of analysis. This research has generated an increasing body of evidence that shows neighborhoods and/or communities are far from being spatially homogeneous with regard to criminal activity.

The first citywide study known to systematically investigate crime at places (street segments) is the analysis by Sherman, Gartin, and Buerger (1989) of predatory crime in Minneapolis. One of the most significant findings from this study is that 50 percent of calls for police service are generated from 3 percent of street segments. Therefore, even within the highest crime neighborhoods, crime tends to cluster at very few locations within those neighborhoods and other areas are (relatively) crime free. Understanding this is critical because there is clear evidence that any spatial analysis of crime at the neighborhood level is at high risk of committing the ecological fallacy (Robinson 1950). Moreover, because these crime places are discrete locations within neighborhoods that are often comprised of transient populations (Sherman et al. 1989), any census-based information regarding the neighborhood may not represent the population at risk at these crime places. This calls any inference based on neighborhood level census information into question.

The second citywide crime at places study is Smith, Frazee, and Davidson (2000), investigating the integration of routine activity theory and social disorganizationtheory.Smith etal.(2000)statethattheempiricalsupport for the integration of these theories is not strong. However, the reason for this is not because these two theories should not be integrated but because the spatialunitsofanalysishavebeentoocoarseinattemptstointegratethetheories. Using street segments as the spatial unit of analysis, Smith et al. (2000) are more successful in this integration than previous research. This is because

of the inherent heterogeneity within neighborhoods that may help explain where crime occurs.

Most recently, and most relevant to the current analysis, Weisburd et al. (2004) and Groff, Weisburd, and Morris (2009) undertook trajectory analyses of crime at places in Seattle. Similar to Sherman et al. (1989), Weisburd et al. (2004) found that approximately 5 percent of street segments accounted for 50 percent of all criminal incidents, over a 14-year period. Additionally, they found that the concentration of crime at crime places remains remarkably stable over time. Through the use of kernel density mapping, Weisburd et al. (2004) found some evidence that the geography of crime trajectories is clustered. This was particularly true for street segments that had their trajectories increasing or decreasing.

In a more explicit analysis of the spatial patterns of the trajectories in Seattle, Groff et al. (2009) confirmed that street segments with the same trajectory had a tendency to be clustered. Additionally, they found significant variation in the trajectory patterns of street segments. As such, even aggregating to an areal unit as small as census blocks would have resulted in Groff et al. (2009) losing a tremendous amount of information.2 And most recently, using a Lorenz plot and Gini coefficients, Johnson and Bowers (2010) demonstrated that crime is more concentrated than expected at the street segment level after considering the distribution of targets.

In this article, we contribute to the crime at places literature in two ways. First, we analyze crime at the level of the street segment over a span of 10 years in another city. Second, and most significantly, using a newly developed spatial point pattern test, we investigate the changes in the spatial distribution of crime at three levels of aggregation: census tracts, dissemination areas (census blocks), and street segments, all at a local level. We are able to show significant spatial heterogeneity within larger spatial units, and that the actual spatial distribution of crime is far more persistent when street segments are the unit of analysis. Implications for theory and policy are discussed.

Data and Testing Methodology

All data in the analysis below are for the City of Vancouver in British Columbia, Canada. The Vancouver Census Metropolitan Area (CMA) is the third largest metropolitan area in Canada, based on population (approximately 2.1 million people), and the largest metropolitan area in Western Canada. Based on its geographic size, coastal location, and resident population, it is quite similar to Seattle, Washington.

- Table 1. Counts and Percentages for Crime Types 1991 1996 2001


Count Percentage Count Percentage Count Percentage

Assault 16,556 20.1 10,046 10.9 7,643 13.4 Burglary 18,068 22.0 23,322 25.2 13,025 22.9 Robbery 1,421 1.7 1,893 2.0 1,251 2.2 Sexual Assault 672 0.8 506 0.5 440 0.8 Theft 16,862 20.5 19,843 21.5 11,255 19.8 Theft of Vehicle 5,957 7.2 7,930 8.6 6,273 11.0 Theft from Vehicle 22,728 27.6 28,941 31.3 16,991 29.9 Total 82,264 100.0 92,481 100.0 56,878 100.0

Crime Data

Crime data are obtained for 1991, 1996, and 2001 to facilitate a comparison of spatial patterns of crime over a 10-year time span. The data used in the analysis are from the Vancouver Police Department (VPD) Calls for Service (CFS) Database generated by its Computer Aided Dispatch (CAD) system. The VPD-CFS Database is the set of all requests to the police made directly to the VPD as well as calls allocated to the VPD through the 911 Emergency Service. Each CFS contains the location and the complaint code/description for each incident; all CFS have an initial complaint code and a complaint code filed by the police officer on the scene, with the latter always taken as being correct.3

Index offenses consisting of assault, burglary, robbery, sexual assault, theft, theft of vehicle, and theft from vehicle are used in the analysishomicide is excluded because of its low incidence in Vancouver; 15-25 per year over the past 10 years. The numbers and percentages of criminal incidents for each crime classification are shown in Table 1. It should come as no surprise that theft-related crimes dominate property offenses and simple assault dominates violent offenses in Vancouver.

One last issue with CFS data is geocoding and the potential for error. As noted in previous research, geocoding algorithms are not only inaccurate at times but are at risk of not locating all street addresses or street intersections for (criminal) incidents (Cayo and Talbot 2003; Ratcliffe 2001; Zandbergen 2008). Therefore, there is a potential for spatial bias because of errors in geocoding. To address this issue, Ratcliffe (2004) identified a minimum acceptable hit/success rate of 85 percent. The geocoding procedure used for the current data generated 93, 93, and 94 percent success rates for 1991,

1996, and 2001, respectively. The proprietors of the data note that addresses may be improperly coded in the field (a nonexistent street address or only a street block number), preventing the complete data set to be geocoded. Because the success rates here exceed minimum acceptable success rate indicated by Ratcliffe (2004) and that improper address records appear to be random, the analysis is undertaken with little concern for spatial bias.

Our criteria for a successful geocoded event is for the event to be geocoded to the correct 100-block (street segment). All data are geocoded to the street network and then aggregated to the census tracts and dissemination areas using a spatial join function. Because Vancouver is a relatively old city (by western Canadian standards), its street network is dominantly a grid. This means that all street segments are quite short. The same cannot be said for Vancouver’s suburban areas, but these are not included in the current analysis. Moreover, the stability of crime patterns is determined, given a street network that does not change year to year. Although shorter street segments may have a lower probability of having a criminal event, ceteris paribus, the randomization process in the spatial point pattern test minimizes the potential for having less scope for change than longer street segments. Additionally, a sensitivity analysis is undertaken below that only uses nonzero spatial units of analysis to address this concern. Finally, the interpolation issue of geocoding algorithms, whereby a point’s position on a street segment might be inaccurate, is not a concern here because no inference is made at a finer scale than the street segment.

Spatial Units of Analysis

We use three spatial units of analysis: census tracts, dissemination areas, and street segments (blocks). Figure 1 provides a representation of the scales for these three spatial units of analysis: one census tract, nine dissemination areas, and one hundred and fifty-two street segments. The first two units are defined by Statistics Canada. Census tracts are relatively small and stable geographic areas that tend to have a population ranging from 2,500 to 8,000—the average is 4,000 persons. There were 110 census tracts in Vancouver, 2001. This is an increase from the previous census (1996), but the 2001 census tract boundaries are used for all three years of data.

Dissemination areas are smaller than census tracts, equivalent in size to a census block in the U.S. census—approximately 400-700 persons, composed of one or more blocks. There were 1,011 dissemination areas in Vancouver, 2001. As with the census tracts, these census boundaries

| |
|---|


- Figure 1. Spatial units of analysis.


change from census to census and the 2001 dissemination boundaries are used for all three years of data.4

Street segments are defined as ‘‘100 blocks’’ within the City of Vancouver. As such, the analysis below is at the same resolution as that of Weisburd et al. (2004). There are 11,730 street segments in Vancouver and each is considered a separate unit of analysis in the testing methodology.

Testing Methodology

The testing methodology is an application of the spatial point pattern test developed by Andresen (2009). This spatial point pattern test is not concerned with null hypotheses of random, uniform, or clustered distributions. Rather, this test is area-based5 and is concerned with the similarity between two different spatial point patterns at the local level.6 An advantage of the test, as we demonstrate here, is that it can be calculated for different area boundaries using the same original point data sets. For more detailed information about the test, see Andresen (2009). To simplify the process of

calculating the test, we developed a computer program that is freely available from the authors. The test can be computed as follows:

- 1. Nominate a base data set (e.g., 1991 assaults) and count, for each area, the number of points that fall within it.
- 2. From the test data set (e.g., 1996 assaults), randomly sample 85 percent of the points, with replacement.7 As with the previous step, count the number of points within each area using the sample. This is effectively a bootstrap created by sampling from the test data set.
- 3. Repeat (2) a number of times (200 is used here).
- 4. For each area in the test data set, calculate the percentage of crime that has occurred in the area. Use these percentages to generate a 95 percent nonparametric confidence interval by removing the top and bottom 2.5 percent of all counts (5 from the top and 5 from the bottom in this case). The minimum and maximum of the remaining percentages represent the confidence interval. It should be noted that the effect of the sampling procedure will be to reduce the number of observations in the test data set but, using percentages rather than the absolute counts, comparisons between data sets can be made even if the total number of observations are different.
- 5. Calculate the percentage of points within each area for the base data set and compare this to the confidence interval generated from the test data set. If the base percentage falls within the confidence interval, then the two data sets exhibit a similar proportion of points in the given area. Otherwise they are significantly different.8


The output of the test is comprised of two parts. First, a global parameter that ranges from 0 (no similarity) to 1 (perfect similarity): the index of similarity, S, is calculated as:

Pn i¼1 si n

S ¼

;

where si is equal to one if two crimes are similar in spatial unit i and zero otherwise, and n is the total number of spatial units. Therefore, the S-Index simply represents the percentage of spatial units that have a similar spatial pattern for both data sets, ranging from zero to one. Second, the test can be used to generate mappable output that shows where statistically significant change has occurred; that is, which census tracts, dissemination areas, and street segments have undergone a statistically significant change. As such,

- Table 2. Percent of Spatial Units Accounting for 50 percent of Crime (a) (b) (c)


Percent of Street Segments with Crime that Account for 50 Percent of Crime

Percentage of Street Segments Accounting of 50 Percent of Crime

Percent of Street Segments that Have Any Crime

1991 1996 2001 1991 1996 2001 1991 1996 2001

Assault 7.47 1.93 1.62 23.69 23.23 18.75 31.52 8.29 8.64 Burglary 7.85 8.14 7.61 45.51 48.99 39.43 17.25 16.62 19.31 Robbery 0.92 0.84 0.84 6.05 6.97 5.32 15.21 12.00 15.87 Sexual assault 1.63 1.41 1.12 4.50 3.57 2.99 36.17 39.38 37.32 Theft 4.36 3.82 2.58 38.70 39.85 26.79 11.28 9.58 9.64 Theft of vehicle 6.21 6.76 5.97 26.64 32.14 27.11 23.33 21.03 22.01 Theft from vehicle 4.95 2.89 2.64 46.85 45.97 36.00 10.57 6.29 7.34

though not a local indicator of spatial association (LISA, see Anselin 1995), this spatial point pattern test is in the spirit of LISA because the output may be mapped.

A number of tests for similarity are performed. For each crime classification and each spatial unit of analysis, indices of similarity are calculated for 1991-1996, 1996-2001, and 1991-2001. These indices are then used to reveal whether spatial patterns of crime are stable over time as indicated by previous crime at places research, and if the spatial unit of analysis matters for this search for stability.

Results and Discussion Replicating and Extending Previous Results

Before we turn to the results of the spatial point pattern tests of spatial change, we discuss some replication results for Vancouver. As shown in Table 2, column a, a very small percentage of street segments account for 50 percent of the various crime classifications in Vancouver. There is a fair degree of variation, less than 1 percent (robbery) to 8 percent (burglary), across the seven crime classifications. Regardless, these numbers are in line with Sherman et al. (1989) and Weisburd et al. (2004). Also worthy of note is that the percentage of streets segments that account for 50 percent of crime is quite stable over time: 1991, 1996, and 2001. If any trend is

present, the numbers are decreasing, indicating that the concentration of crime is increasing.

In addition to replicating the results of Sherman et al. (1989) and Weisburd et al. (2004), we investigated two further concentrations. First is the percentage of streets segments that have any crime. As column b in

- Table 2 shows, in all cases one half of Vancouver is free from each of the crime classifications—some street segments may experience none of one crime and some of another. In the cases of robbery and sexual assault, approximately 95 percent of Vancouver is free from these crimes, according to the police data.9 Only crimes such as burglary and theft from vehicle approach the 50 percent mark. But this is only for 1991, as both crime classifications show notable decreases by 2001. When plotted on maps, many of these crime classifications appear to be occurring everywhere, but this is clearly not the case. This only points to the importance of spatial scale in any efforts to understand the spatial distribution of crime.


Finally, column c of Table 2 shows the percentage of street segments with any crime that account for 50 percent of crime. Consider the case of robbery. Depending on the year of analysis, robbery occurs in approximately 6 percent of all streets segments of Vancouver. This is a high magnitude degree of clustering. Within that 6 percent of street segments, 50 percent of all robberies occurred on 15 percent of street segments. The results are similar for the other crime classifications. Needless to say, the crime classifications under analysis exhibit a high degree of concentration in particular places; and even within those places that have any crime, there is also a high degree of concentration.

An obvious question emerges from this high degree of clustering for all crime classifications: do the different crime classifications cluster in the same places? Table 3 contains the parametric (Pearson’s) and nonparametric (Spearman’s) correlations for the different crime classifications, using street segments as the unit of analysis. Immediately apparent is that all correlations are statistically significant at the 1 percent level. This is hardly a surprise because of the large number of zero values for each crime classifications—the vast majority of street segments have zero criminal incidents. Of particular interest are the correlations between crime classifications with large numbers of incidents: assault, burglary, theft, and theft from vehicle. Evident from Table 3 is that the crime classifications with large numbers of incidents have the greatest magnitude correlations. This result implies, though does not confirm, that street segments with high volumes of one crime classification have high volumes of other crime classifications.

- Table 3. Parametric and Nonparametric Correlations by Crime Classification, Street Segment Level


Assault Burglary Robbery

Sexual Assault Theft

Theft of Vehicle

Theft from Vehicle

Assault .33 .75 .40 .53 .27 .30 Burglary .34 .24 .21 .45 .38 .33 Robbery .36 .21 .37 .41 .21 .23 Sexual

.22 .14 .18 .25 .16 .12

assault

Theft .43 .43 .32 .19 .44 .63 Theft of

.37 .39 .25 .18 .42 .43 Theft from vehicle

vehicle

.40 .47 .26 .19 .51 .49

Notes: Nonparametric (Spearman’s) correlations in lower triangle, parametric (Pearson’s) correlations in upper triangle. All correlations significant at the 1 percent level.

On close inspection of the street segments that comprise 50 percent of all crimes in each classification, there is not a high degree of overlap for all crime classifications. As such, there are no ‘‘super chronic’’ street segments that are problematic for all crime classifications. However, the ‘‘top ranking chronic’’ street segments10 for particular crime classifications do overlap. For example, the top ranking chronic street segments for theft often overlap with the top ranking chronic street segments for theft from vehicle, and similarly for assault and robbery. Incidentally, these particular overlapping street segments correspond to the greatest magnitude correlations shown in

- Table 3. Additionally, the top ranking chronic street segments for each crime classification are always clustered in the same general locations: the central business district and Vancouver’s skid row, the Downtown Eastside. Therefore, chronic street segments tend to specialize in one or two crime classifications, most often related to opportunity,11 and they are in close proximity of one another.


Spatial Point Pattern Test Results

Turning to the results of the spatial point pattern test for the temporal stability of crime, Table 4 shows the Indices of Similarity for census tracts; a value of 1 represents identical spatial patterns and a value of 0 represents completely different spatial patterns. Evident from Table 4, none of the crime classifications have stable spatial patterns over time. The highest

- Table 4. Indices of Similarity, Census Tracts 1991–1996 1996–2001 1991–2001

Assault .346 .318 .300 Burglary .173 .218 .155 Robbery .282 .364 .327 Sexual assault .455 .409 .509 Theft .199 .218 .136 Theft of vehicle .282 .227 .300 Theft from vehicle .091 .218 .146

- Table 5. Indices of Similarity, Dissemination Areas 1991–1996 1996–2001 1991–2001


Assault .365 .357 .335 Burglary .284 .288 .299 Robbery .624 .675 .662 Sexual assault .715 .753 .691 Theft .377 .271 .237 Theft of vehicle .313 .332 .332 Theft from vehicle .224 .332 .261

Index value is .509, for sexual assault, and that is only for one of the three tests for stability in the spatial patterns. Even crime classifications that appear to occureverywherewhen inspecting mapped pointdata,burglaryand theftfrom vehicle, have low degrees of similarity in their spatial patterns over time.

The Indices of Similarity for dissemination areas, Table 5, have increased in all cases, with a few notable results. According to the results in Table 4, robbery does not appear to have much stability in its spatial patterns over time—Indices range from .282 to .364. However, in Table 5, the Indices have increased substantially to approximately .65. Therefore, two thirds of the dissemination areas have the same percentage of robberies year to year and given the high degree of concentration for robbery (see Table 2), this percentage is probably zero. However, the important aspect of this finding is that crimes appear to be far more stable when the spatial scale of analysis becomes smaller. Although little has changed for assault, the other crime classifications have large magnitude increases in their Index values, particularly sexual assault.

The results for street segments, Table 6, show an even greater change in the Index values. Even assault now has an incredibly stable spatial pattern

- Table 6. Indices of Similarity, Street Segments 1991–1996 1996–2001 1991–2001


Assault .659 .659 .659 Burglary .537 .557 .567 Robbery .866 .856 .875 Sexual assault .920 .941 .919 Theft .534 .559 .577 Theft of vehicle .638 .577 .659 Theft from vehicle .408 .445 .442

over time—only theft from vehicle is still less than .50. The most notable results are those for robbery and sexual assault.12 In the analysis using census tracts, robbery appeared to have a rather unstable spatial pattern over time; now with the analysis of street segments, more than 85 percent of street segments have the same percentages of robberies year to year. As stated above, these street segments are likely always zero. However, what matters is that the spatial pattern of this crime is very stable year to year, unlike the results from the more conventional spatial unit of analysis in spatial criminology, the census tract. The results for sexual assault are similar to those of robbery, but sexual assault did have a more stable spatial pattern in the census tract analysis.

Sensitivity Analysis

Although support for the use of microspatial units of analysis is compelling, one may argue that the results reported above are an artifact of the data and/ or method rather than an artifact of spatial consistency becoming more apparent at smaller scales of analysis. As shown in Table 2, the percentage of street segments that have zero crime can be substantial. As such, smaller units of analysis will have greater degrees of similarity due to the presence of all the zeros. Consequently, the greater degree of spatial consistency at smaller units of analysis may not be present if only nonzero units of analysis are used.

To address this concern, we undertake the spatial point pattern test at all scales of aggregation, only using nonzero spatial units; a spatial unit is considered nonzero, if it has at least one crime in any of the three years of data. The results of this sensitivity analysis are presented in Tables 7-9. In the last column of each table, the percentage of spatial units retained is reported.

- Table 7. Indices of Similarity, Nonzero Census Tracts

1991–1996 1996–2001 1991–2001

Percentage of Census Tracts Retained

Assault .321 .264 .274 96.4 Burglary .149 .224 .140 97.3 Robbery .238 .343 .286 95.5 Sexual assault .438 .391 .476 95.5 Theft .194 .213 .121 98.2 Theft of vehicle .269 .250 .287 98.2 Theft from vehicle .056 .222 .148 98.2

- Table 8. Indices of Similarity, Nonzero Dissemination Areas

1991–1996 1996–2001 1991–2001

Percentage of Dissemination Areas Retained

Assault .321 .328 .294 94.2 Burglary .257 .265 .279 96.8 Robbery .399 .498 .458 63.1 Sexual assault .509 .579 .471 57.6 Theft .298 .253 .221 96.9 Theft of vehicle .291 .298 .294 95.7 Theft from vehicle .197 .311 .239 96.9

- Table 9. Indices of Similarity, Nonzero Street Segments


1991–1996 1996–2001 1991–2001

Percentage of Street Segments Retained

Assault .340 .351 .326 38.2 Burglary .327 .355 .372 63.8 Robbery .387 .385 .427 12.7 Sexual assault .518 .516 .501 9.4 Theft .291 .343 .354 56.6 Theft of vehicle .414 .325 .424 49.5 Theft from vehicle .206 .326 .253 63.9

Immediately apparent is that the smaller units of analysis retain far fewer spatial units than the larger units of analysis. In the case of robbery and sexual assault, 12.7 and 9.4 percent, respectively, of street segments are retained for the test. Not surprisingly, this has a significant impact on the

street segment results, but the general pattern outlined above (spatial consistency becomes more apparent at smaller units of analysis) is still present.

The sensitivity analysis results for census tracts (Table 7) show very little change from the initial test results (Table 4). The Indices of Similarity do decrease, but because so many of the census tracts are retained in the sensitivity analysis, this comes as no surprise. The sensitivity analysis results for dissemination areas (Table 8) show more change than census tracts when compared to the initial test results (Table 5), but the same basic pattern remains: Indices of Similarity increase (substantially in some cases) when moving to a smaller unit of analysis.

Turning to the sensitivity analysis results for street segments (Table 9), the decreases in the Indices of Similarity are most prominent when compared to the initial test results (Table 6). However, this should be expected given that no more than 64 percent of the street segments are ever retained in the sensitivity analysis. Most important is the comparison between the results for nonzero dissemination areas and nonzero street segments. Clearly evident is that the nonzero street segments exhibit more stability (spatial consistency) than nonzero dissemination areas—notably more stability in some cases. Only robbery consistently shows moderately less stability in the nonzero street segment sensitivity analysis. This result is no surprise given that more than 85 percent of the street segments are excluded in this sensitivity analysis.

This sensitivity analysis shows that the results reported above are similar to the results for the nonzero spatial units of analysis: an increase in similarity as the spatial unit of analysis becomes smaller. Although the size of the effect in the sensitivity analysis is smaller than in the initial analysis, the overall distribution of Index values are different depending on the spatial unit of analysis used. Using a Wilcoxon signed ranks test on the paired observations, the Indices are higher for the nonzero street segments than for the nonzero dissemination areas, p ¼ .0173.13

However, it should be noted that the original results (Tables 4-6) would have merit even if the sensitivity analysis did not show the same general pattern. This merit lays in showing the magnitude of the ecological fallacy when using larger spatial units of analysis. Quite clearly, the presence of so many spatial units with zero crime shows that there are ‘‘safe places’’ in ‘‘bad areas’’ (Sherman et al. 1989). Consequently, even if there was no similarity in nonzero street segments, the fact that some street segments are free from particular crime types in upward of 90 percent of cases (e.g., sexual assault) has important implications for theory and policy.

Interpretation of the Results

Overall, the spatial pattern of crime is rather stable over time when one considers the street segment as the spatial unit of analysis. An obvious question, of course, is: why? This may simply be a case of the modifiable areal unit problem (Openshaw 1984a) whereby the choice of district boundaries is influencing the results. If this is the case then different boundaries might reveal more similarity across crime types as we find with street segments, although there is no evidence to suggest this would be the case. Or the ecological fallacy (Openshaw 1984b; Robinson 1950) might be influencing the results, causing us to make potentially false claims regarding smaller areas within the larger areas. We argue, however, that there is no problem with our results. In the first place, if there was no underlying process that needs to be understood, we would not expect the changing results from census tracts to dissemination areas to street segments to be so consistent across crime classifications. Rather, we believe these changing results are a product of using increasingly appropriate spatial units of analysis. Indeed, the results provide evidence that the ecological fallacy is present when data are aggregated to the dissemination area and census tract.

It is clear from these results that the choice of the spatial unit of analysis may have substantial implications on the analysis. Moreover, these substantial implications cannot simply be labeled a problem resulting from modifying areal units. Rather, the street segments are most often driving the change for the larger spatial units. Specifically, a small number of ‘‘chronic’’ street segments dictate the results for the entire dissemination area or census tract much like a small number of chronic offenders can dictate the results for a larger set of individuals (Wolfgang et al. 1972). In some cases, the results of the street segments are unrelated to that of the larger spatial units. This is precisely the trajectory of spatial criminology over the past 175 years: the move toward smaller units of analysis because new research shows that the ecological fallacy was being committed, explicitly or implicitly, when labeling departments, towns, wards, and neighborhoods. This is clearly problematic in any attempts to understand why crime is high/low or increasing/decreasing in particular areas or for the formulation of initiatives to deal with crime.

Turning to a citywide representation of the results to provide context of the change in spatial patterns, the street segments with statistically significant increases and decreases (1991-2001) in robbery are shown in Figure 2—robbery is used because of its relatively low frequency that allows for a meaningful visualization of the test results at the level of the

| |
|---|


## Figure 2. A. Citywide increases, robbery, street segments. B. Citywide decreases,robbery, street segments.

city. Figure 2a shows the street segments with statistically significant increases, whereas Figure 2b shows the street segments with statistically significant decreases. It should be clear from Figure 2b that most areas of Vancouver are experiences decreases in robbery. However, as shown in Figure 2a, only particular areas within Vancouver are experiencing increases in robbery: the central business district, the Downtown Eastside (Skid Row), and one street (Kingsway) that runs southeast from the Downtown Eastside. With the vast majority of Vancouver maintaining a stable crime pattern (approximately 85 percent) and much of the remainder of the city (approximately 11 percent) exhibiting decreases in crime, what is it about these three areas that are increasing?

Fifty years ago, Calvin Schmid (1960a, 1960b) outlined the importance of understanding a city’s structure when considering the spatial distribution of crime. Simply put, the central business district has a lot of crime because of the abundance of people—more offenders and more targets. Indeed, this is the fundamental point of routine activity theory: if there is an increase in the convergence of motivated offenders, suitable targets, and a lack of capable guardianship, crime will increase (Cohen and Felson 1979; Felson and Cohen 1980, 1981). In the context of Vancouver, the central business district, the Downtown Eastside (adjacent to the central business district), and Kingsway are all places with high concentrations of people. Therefore, the street segments with statistically significant increases in their share of robbery are located in highly populated areas in Vancouver. Moreover, these are areas that are not necessarily high in residential populations, but ambient populations because people are attracted to these locations for the varied land uses present (Andresen 2006, 2007).

Implications for Theory and Policy

Consistent with previous research in the crime at places literature, the above analysis has shown that micro places, such as the street segment, are the driving force behind broader neighborhood change. If micro places are the appropriate spatial units of analysis in any effort to understand crime, a number of implications are immediately apparent. These implications are best organized along two lines of thought: theory and policy.

The implications for theory may be organized to correspond with the three theoretical perspectives discussed in terms of crime at places (routine activity theory, geometric theory of crime, and rational choice theory) as well as social disorganization theory. Although there is strong support for the use of routine activity theory on individual characteristics (Kennedy and

Forde 1990) to predict criminal victimization, there is a need for further research into the routine activities of places (Felson 1987; Sherman et al. 1989). With such stable and high concentrations of crime occurring at so few micro places, an in-depth understanding of these places is in order. Such an understanding is in order because it is the convergence of suitable targets and motivated offenders without capable guardians at (micro-) places that leads to crime.

Consequently, knowing why the convergence occurs on this street segment and not that street segment needs to be incorporated into further understanding of the importance of that convergence. Additionally, at the heart of understanding the routine activities of micro places is a temporal analysis. This is because changes in routine activities lead to corresponding changes in crime. Although significant insight may be gathered through comparisons of multiple places at the same time, relationships are less likely to be causal when temporal change is not considered.

The geometric theory of crime was highly developed when it first emerged 30 years ago (Brantingham and Brantingham 1981, 1993). However, very few tests (for the purpose of further understanding and refinement) have been performed of this theory—see Rengert and Wasilchick (1985) for an exception. The reason for the lack of empirical tests of the geometric theory of crime is that the data requirements for proper testing are very high: not only is detailed crime data necessary (spatially and for individual offenders) but so is information on legitimate and criminal movements patterns of large numbers of people. The data used in this analysis are longitudinal and very precise spatially, but do not have information on individual offenders, let alone their movement patterns. Perhaps, it is time for such an analysis to occur.

Rational choice theory has always made the point of stressing the importance of focusing on choices specific to a crime classification (Clarke and Cornish 1985; Cornish and Clarke 1986): the decisions necessary to commit a burglary are different from the decisions necessary to rob a convenience store. These choices were shortly thereafter broken down into what Cornish and Clarke (1987) referred to as choice-structuring properties. Some of these properties include the accessibility of targets, risks of apprehension/detectability, and the time required to commit the crime. Because of the prevalence of various crime classifications at particular places (Table 2, column a), criminal choices that involve these factors are easier to make at those particular places: one street segment versus another. As such, the micro place must be considered one of the many choice-structuring properties for committing a crime.

Finally, with regard to social disorganization theory, it appears as though the neighborhood is no longer appropriate for understanding the spatial distribution of crime. Although this may be an unpopular claim to state, given the widespread use of the neighborhood in crime analysis to this day, we must keep in mind that the work of Burgess (1916), Shaw (1929), and Shaw and McKay (1931, 1942) showed that the previous era of spatial criminology used spatial units of analysis that were too coarse for an appropriate understanding of the spatial distribution of crime: there was significant variation in crime within cities and counties. Similarly, the crime at places literature has found a similar result: there is significant variation in crime within neighborhoods—dangerous neighborhoods are generally safe (Sherman et al. 1989). Consequently, social disorganization theory can only matter for crime at places if and only if socially disorganized neighborhoods (theoretically predicted to be high in crime) have more dangerous places than socially organized places. This, of course, is an empirical question and is a direction for further research.

Regardless of the theoretical perspective within spatial criminology, the importance of crime at micro places has practical implications. The incorporation of these very few places that generate the majority of crime across our urban landscapes reinforces that crime is indeed a rare event. The convergences, activity patterns, and choices that lead to crime, all occur in these discrete locations.

With regard to policy, the stability of spatial crime patterns implies that crime prevention through environmental design is an appropriate course of action (Jeffery 1969, 1971, 1976, 1977). In its most common application, routine activity theory is used to make statements regarding the change of routine activities for victims of crime. However, it is far easier to change and/or regulate places than individuals (Sherman et al. 1989). And because these places are micro places, the specific crime prevention activity that should be used is situational crime prevention (Clarke 1980, 1983). This focus on situational crime prevention should occur because situational crime prevention works best when applied to crime- and place-specific problems. Although one may argue that this will simply result in the spatial displacement of crime, the most recent and definitive research on spatial displacement indicates that will not occur (Guerette and Bowers 2009; Weisburd et al. 2006); in fact, this research shows that there will likely be the diffusion of benefits to surrounding places.

Because of the stability of the spatial patterns of crime at micro places, especially for robbery and sexual assault, these micro places should be able to be disrupted or altered to prevent crime—modifying the conditions for

one of the choice-structuring properties of crime. The theoretical justification and empirical support for such a practice is well known. And now with the growing bodyofcrime at places literature,there is theoretical justification and empirical support for the application of crime prevention activities focused on micro places.

The difficulty with considering micro places for theory and policy is data availability. Census data are not available for areas smaller than dissemination areas (Canada) and the census block (United States), aside from some microdata that are based on 20 percent sampling—many street segments will, therefore, be missing data. One possible alternative is in situ fieldwork that could provide context for micro place theory and policy analysis. Such data collection is not feasible in a citywide analysis, making it limited for testing theory at the street segment level because of the limited number of observations. However, this type of data would prove useful for situational crime prevention policy because it is locally based. Therefore, with the empirical support for analysis at micro places, the significance of future research in the crime and places literature (in part) depends on supplementary data at the street segment level to better understand crime patterns occurring at micro places.

Authors’ Note

This research was carried out using data stored in the Institute for Canadian Urban Research Studies.

Declaration of Conflicting Interests

The authors declared no conflicts of interest with respect to the authorship and/or publication of this article.

Funding

The authors received no financial support for the research and/or authorship of this article.

Notes

- 1. There is other notable research that analyzes small units of analysis. First is the work involving crime prevention initiatives. This research involves microspatial analysis of crime and the effects of prevention initiatives and tends to focus on relatively small areas rather than citywide analyses. See Sherman et al. (1989) and Weisburd et al. (2004) for reviews of this literature. Second, is the work of Brantingham, Dyreson, and Brantingham (1976) regarding the changes in crime patternswhenthespatialunitofanalysisisaltered.Andthird,theworkofBowers


- andJohnson(2004),JohnsonandBowers(2004a,2004b),andTownsley,Homel, and Chaseling (2000, 2003) with their research on near-repeat victimization.
- 2. Although not reviewed here, or in Weisburd et al. (2004), Taylor et al. (1995) analyze street segments/blocks, but are concerned with physical deterioration, not crime. In addition, Weisburd, Bernasco, and Bruinsma (2009) is a recent collection of essays that discusses the appropriate unit of analysis in spatial criminology.
- 3. See Sherman et al. (1989) for a discussion of the limitations and strengths of using police calls for service data.
- 4. Prior to the 2001 census, these census boundaries were called enumeration areas.
- 5. A street segment may be considered an area, as multiple points may be geocoded to a single street segment.
- 6. This test may also be used to compare a point pattern with random, uniform, or clustered data sets.
- 7. An 85 percent sample is based on the minimum acceptable hit rate to maintain spatial patterns, determined by Ratcliffe (2004). Maintaining the spatial pattern of the complete data set is important so we used this as a benchmark for sampling. An 85percent sample was for the purposes of generating asmuch variability as possible while maintaining the original spatial pattern. Also note that ‘‘replacement’’ in this context refers to subsequent samples; any one point may only be sampled once per iteration in this procedure to mimic Ratcliffe (2004).
- 8. The program written to perform the test uses double precision that has at least 14 decimal points when dealing with numbers less than unity. The smallest number that we have to deal with in the current analysis (regardless of scale) is .000034553. This is well within the limits of double precision.
- 9. This may partially be a result of underreporting, particularly for crimes related to sexual assault.
- 10. This set of street segments comprises 50 percent of all criminal incidents for each crime classification as identified in Table 2.
- 11. Forexample,assaultsarehighlyclusteredinareaswithlargenumbersofdrinking establishments and thefts from vehicles are highly clustered in areas with many parking lots. Both these areas are in or close to the central business district.
- 12. It may be the case that this high degree of stability is because of the low numbers of these crimes; there are so many areas without any robbery or sexual assault.
- 13. We would like to thank an anonymous reviewer for suggesting this discussion.
- 14. We would like to thank Eric Beauregard, Paul Brantingham, and Greg Jenion for their insightful comments on earlier drafts of this article. We would also like to thank George Rengert, Elizabeth Groff, John Eck, Michael Maxfield, and three anonymous reviewers whose comments significantly improved the quality of this article.


References

- Andresen, Martin A. 2006. ‘‘Crime Measures and the Spatial Analysis of Criminal Activity.’’ British Journal of Criminology 46:258-85.
- Andresen, Martin A. 2007. ‘‘Location Quotients, Ambient Populations, and the Spatial Analysis of Crime in Vancouver, Canada.’’ Environment and Planning A 39:2423-44.


Andresen, Martin A. 2009. ‘‘Testing for Similarity in Area-Based Spatial Patterns: A Nonparametric Monte Carlo Approach.’’ Applied Geography 29:333-45. Anselin,Luc.1995.‘‘LocalIndicatorsofSpatialAssociation—LISA.’’Geographical

Analysis 27:93-115. Bowers, Kate J. and Shane D. Johnson. 2004. ‘‘Who Commits Near Repeats? A Test of the Boost Explanation.’’ Western Criminology Review 5:12-24.

Brantingham, Paul J., Delmar A. Dyreson, and Patricia L. Brantingham. 1976. ‘‘Crime Seen Through a Cone of Resolution.’’ American Behavioral Scientist 20:261-73.

Brantingham, Patricia L. and Paul J. Brantingham. 1981. ‘‘Notes of the Geometry of crime.’’ Pp. 27-54 in Environmental Criminology, edited by Paul J. Brantingham and Patricia L. Brantingham. Prospect Heights IL, Waveland Press.

Brantingham, Patricia L. and Paul J. Brantingham. 1993. ‘‘Nodes, Paths and Edges: Considerations on the Complexity of Crime and the Physical Environment.’’ Journal of Environmental Psychology 13:3-28.

Burgess, Ernest W. 1916. ‘‘Juvenile Delinquency in a Small City.’’ Journal of the American Institute of Criminal Law and Criminology 6:724-28.

Cayo, Nichael R. and Thomas O. Talbot. 2003. ‘‘Positional Error in Automated Geocoding of Residential Addresses.’’ International Journal of Health Geographics 2:1-12.

Clarke, Ronald V. G. 1980. ‘‘Situational Crime Prevention: Theory and Practice.’’ British Journal of Criminology 20:136-47.

Clarke, Ronald V. G. 1983. ‘‘Situational Crime Prevention: Its Theoretical Basis and Practical Scope.’’ Crime and Justice: An Annual Review of Research 4:225-56.

Clarke, Ronald V. G. and Derek B. Cornish. 1985. ‘‘Modeling Offenders’ Decisions: A Framework for Research and Policy.’’ Crime and Justice: An Annual Review of Research 6:147-85.

Cohen, Lawrence E. and Marcus Felson. 1979. ‘‘Social Change and Crime Rate Trends: A Routine Activity Approach.’’ American Sociological Review 44:588-608.

Cornish, Derek B. and Ronald V. G. Clarke. 1986. The Reasoning Criminal: Rational Choice Perspectives on Offending. New York, NY: Springer-Verlag.

Cornish,DerekB.andRonaldV.G.Clarke.1987.‘‘UnderstandingCrimeDisplacement: An Application of Rational Choice Theory.’’ Criminology 25:933-47. Eck, John, E. and David Weisburd, eds. 1995. Crime Prevention Studies. Vol. 4, Crime and Place. Monsey, NY: Criminal Justice Press. Felson, Marcus. 1987. ‘‘Routine Activities and Crime Prevention in the Developing Metropolis.’’ Criminology 25:911-31.

- Felson, Marcus and Lawrence E. Cohen. 1980. ‘‘Human Ecology and Crime: A Routine Activity Approach.’’ Human Ecology 8:398-405.
- Felson, Marcus and Lawrence E. Cohen. 1981. ‘‘Modeling Crime Trends: A Cumulative Opportunity Perspective.’’ Journal of Research in Crime and Delinquency 18:138-64.


Groff, Elizabeth, David Weisburd, and Nancy A. Morris. 2009. ‘‘Where the Action is at Places: Examining Spatio-Temporal Patterns of Juvenile Crime at Places using Trajectory Analysis.’’ Pp. 61-86 in Putting Crime in its Place: Units of Analysis in Geographic Criminology, edited by David Weisburd, Wim Bernasco, and Gerben J. N. Bruinsma. New York, NY: Springer.

Guerette, Rob T. and Kate J. Bowers. 2009. ‘‘Assessing the Extent of Crime Displacementand Diffusion of Benefits:AReviewofSituationalCrime Prevention Evaluations.’’ Criminology 47:1331-68.

Jeffery, C. Ray. 1969. ‘‘Crime Prevention and Control Through Environmental Engineering.’’ Criminologica 7:35-58. Jeffrey, C. Ray. 1971. Crime Prevention Through Environmental Design. Beverly Hills, CA: Sage.

- Jeffery, C. Ray. 1976.‘‘CriminalBehaviourand the PhysicalEnvironment.’’American Behavioral Scientist 20:149-74.
- Jeffery, C. Ray. 1977. Crime Prevention Through Environmental Design, 2nd ed. Beverly Hills, CA: Sage.


- Johnson, Shane D. and Kate J. Bowers. 2004a. ‘‘The Burglary as Clue to the Future: The Beginnings of Prospective Hot-Spotting.’’ European Journal of Criminology 1:237-55.
- Johnson, Shane D. and Kate J. Bowers. 2004b. ‘‘The Stability of Space—Time Clusters of Burglary.’’ British Journal of Criminology 44:55-65.


Johnson, Shane D. and Kate J. Bowers. 2010. ‘‘Permeability and Burglary Risk: Are Cul-de-sacs Safer?’’ Journal of Quantitative Criminology 26:89-111. Kennedy, Leslie W. and David R. Forde. 1990. ‘‘Routine Activities and Crime: An Analysis of Victimization in Canada.’’ Criminology 28:137-52.

- Openshaw, Stan. 1984a. The Modifiable Areal Unit Problem. CATMOG (Concepts and Techniques in Modern Geography) Vol. 38. Norwich: Geo Books.
- Openshaw, Stan. 1984b. ‘‘Ecological Fallacies and the Analysis of Areal Census Data.’’ Environment and Planning A 16:17-31.


Ratcliffe, Jerry H. 2001. ‘‘On the Accuracy of TIGER Type Geocoded Address Data in Relation to Cadastral and Census Areal Units.’’ International Journal of Geographical Information Science 15:473-85.

Ratcliffe, Jerry H. 2004. ‘‘Geocoding Crime and a First Estimate of a Minimum Acceptable Hit Rate.’’ International Journal of Geographical Information Science 18:61-72.

Rengert, George F. and John Wasilchick. 1985. Suburban Burglary: A Time and Place for Everything. Springfield, IL: Charles C. Thomas. Robinson, William S. 1950. ‘‘Ecological Correlations and the Behavior of Individuals.’’ American Sociological Review 15:351-57.

- Schmid, Calvin F. 1960a. ‘‘Urban Crime Areas: Part I.’’ American Sociological Review 25:527-42.
- Schmid, Calvin F. 1960b. ‘‘Urban Crime Areas: Part II.’’ American Sociological Review 25: 655-78.


Shaw, Clifford R. 1929. Delinquency Areas. Chicago, IL: University of Chicago Press. Shaw, Clifford R. and Henry D. McKay. 1931. Social Factors in Juvenile

Delinquency. Washington, DC: U.S. Government Printing Office.

Shaw, Clifford R. and Henry D. MacKay. 1942. Juvenile Delinquency and Urban Areas: A Study of Rates of Delinquency in Relation to Differential Characteristics of Local Communities in American Cities. Chicago, IL: University of Chicago Press.

Smith, William R., Sharon G. Frazee, and Elizabeth L. Davidson. 2000. ‘‘Furthering the Integration of Routine Activity and Social Disorganization Theories: Small Units of Analysis and the Study of Street Robbery as a Diffusion Process.’’ Criminology 38:489-524.

Sherman, Lawrence W., Patrick R. Gartin, and Michael E. Buerger. 1989. ‘‘Hot Spots of Predatory Crime: Routine Activities and the Criminology of Place.’’ Criminology 27:27-56.

Taylor, Ralph B., Barbara A. Koons, Ellen M. Kurtz, Jack R. Greene, and Douglas D. Perkins. 1995. ‘‘Street Blocks with More Nonresidential Land Use Have More Physical Deterioration.’’ Urban Affairs Review 31:120-36.

Townsley, Michale, Ross Homel, and Janet Chaseling. 2000. ‘‘Repeat Burglary Victimisation: Spatial and Temporal Patterns.’’ Australian and New Zealand Journal of Criminology 33:37-63.

Townsley, Michale, Ross Homel, and Janet Chaseling. 2003. ‘‘Infectious Burglaries: A Test of the Near Repeat Hypothesis.’’ British Journal of Criminology 43:615-33.

Weisburd, David, Wim Bernasco, and Gerben J. N. Bruinsma. 2009. Putting Crime in its Place: Units of Analysis in Geographic Criminology. New York, NY: Springer.

Weisburd, David, Gerben J. N. Bruinsma, and Wim Bernasco. 2009. ‘‘Units of Analysis in Geographic Criminology: Historical Development, Critical Issues, and Open Questions.’’ Pp. 3-31 in Putting Crime in its Place: Units of Analysis in Geographic Criminology, edited by David Weisburd, Wim Bernasco, and Gerben J. N. Bruinsma. New York, NY: Springer.

Weisburd, David, Shawn Bushway, Cynthia Lum, and Sue-Ming Yang. 2004. ‘‘Trajectories of Crime at Places: A Longitudinal Study of Street Segments in the City of Seattle.’’ Criminology 42:283-321.

Weisburd, David, Laura A. Wyckoff, Justin Ready, John E. Eck, Joshua C. Hinkle, and Frank Gajewski. 2006. ‘‘Does Crime just Move Around the Corner? A Controlled Study of the Spatial Displacement and Diffusion of Crime Control Benefits.’’ Criminology 44:549-91.

Wolfgang, Marvin E., Robert M. Figlio, and Thorsten Sellin. 1972. Delinquency in a Birth Cohort. Chicago, IL: University of Chicago Press.

Zandbergen, Paul A. 2008. ‘‘A Comparison of Address Point, Parcel and Street Geocoding Techniques.’’ Computers, Environment and Urban Systems 32:214-32.

Bios

Martin A. Andresen is an Assistant Professor at Simon Fraser University, School of Criminology and Institute for Canadian Urban Research Studies. His research areas include spatial statistical analysis, crime at places, and co-offending with recent research published in Annals of the Association of American Geographers, British Journal of Criminology, Environment and Planning A, and European Journal of Criminology.

Nicolas Malleson is a Research Fellow at University of Leeds, School of Geography. His research areas include crime at places, agent-based modeling, and geocomputation with recent research published in Crime Patterns and Analysis, Environment and Planning B and Computers Environment and Urban Systems.

