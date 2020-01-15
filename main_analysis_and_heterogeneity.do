set more off
*set trace on
capture log close
cd "C:\Users\Evan Generoli\Documents\Graduate School\Fall Semester 2018\Thesis\Final_to_turn_in"
log using main_analysis_and_heterogeneity.log, replace
clear
use main_analysis_and_heterogeneity.dta
describe, short

* create interaction variables for event study models
sum year
forvalues i = 2011/2016{
	gen y_`i' = (year == `i')
	gen uninsured_y_`i' = uninsured_rate_2013 * y_`i'
	gen medicaid_uninsured_y_`i' = medicaid_uninsured * y_`i'
	gen medicaid_y_`i' = medicaid * y_`i'
}



* full sample DiD regressions & event study

foreach y in ln_wage lfp employed uhrswork {
	xtreg `y' medicaid_post college hispanic black asian othrace citizen married female ///
		age30_35 age35_40 age40_45 age45_50 age50_55 i.year, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'
	
	*event study
	xtreg `y' medicaid_y_2011 medicaid_y_2012 medicaid_y_2014 medicaid_y_2015 medicaid_y_2016 ///
		college hispanic black asian othrace citizen married female age30_35 age35_40 ///
		age40_45 age45_50 age50_55 i.year, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'_ES
	
}
esttab using full_sample_DiD_results.csv, se(4) r2 star(* 0.1 ** 0.05 *** 0.01) replace
eststo clear

* full sample DiDiD regressions & event study

foreach y in ln_wage lfp employed uhrswork {
	xtreg `y' uninsured_post medicaid_uninsured_post college hispanic black asian othrace citizen married female ///
		age30_35 age35_40 age40_45 age45_50 age50_55 i.year#i.statefip, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'
	
	*event study
	xtreg `y' uninsured_y_2011 uninsured_y_2012 uninsured_y_2014 uninsured_y_2015 uninsured_y_2016 ///
		medicaid_uninsured_y_2011 medicaid_uninsured_y_2012 medicaid_uninsured_y_2014 medicaid_uninsured_y_2015 ///
		medicaid_uninsured_y_2016 college hispanic black asian othrace citizen married female ///
		age30_35 age35_40 age40_45 age45_50 age50_55 i.year#i.statefip, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'_ES
	
}
esttab using full_sample_DiDiD_results.csv, se(4) r2 star(* 0.1 ** 0.05 *** 0.01) replace
eststo clear




************************************************************************************************
****************** Heterogeneity Analysis ******************************************************
************************************************************************************************

* male DiDiD regressions & event study

foreach y in ln_wage lfp employed uhrswork {
	xtreg `y' uninsured_post medicaid_uninsured_post college hispanic black asian othrace citizen married female ///
		age30_35 age35_40 age40_45 age45_50 age50_55 i.year#i.statefip if female==0, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'
	
	*event study
	xtreg `y' uninsured_y_2011 uninsured_y_2012 uninsured_y_2014 uninsured_y_2015 uninsured_y_2016 ///
		medicaid_uninsured_y_2011 medicaid_uninsured_y_2012 medicaid_uninsured_y_2014 medicaid_uninsured_y_2015 ///
		medicaid_uninsured_y_2016 college hispanic black asian othrace citizen married female ///
		age30_35 age35_40 age40_45 age45_50 age50_55 i.year#i.statefip if female==0, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'_ES
	
}
esttab using male_DiDiD_results.csv, se(4) r2 star(* 0.1 ** 0.05 *** 0.01) replace
eststo clear






* female DiDiD regressions & event study

foreach y in ln_wage lfp employed uhrswork {
	xtreg `y' uninsured_post medicaid_uninsured_post college hispanic black asian othrace citizen married female ///
		age30_35 age35_40 age40_45 age45_50 age50_55 i.year#i.statefip if female==1, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'
	
	*event study
	xtreg `y' uninsured_y_2011 uninsured_y_2012 uninsured_y_2014 uninsured_y_2015 uninsured_y_2016 ///
		medicaid_uninsured_y_2011 medicaid_uninsured_y_2012 medicaid_uninsured_y_2014 medicaid_uninsured_y_2015 ///
		medicaid_uninsured_y_2016 college hispanic black asian othrace citizen married female ///
		age30_35 age35_40 age40_45 age45_50 age50_55 i.year#i.statefip if female==1, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'_ES
	
}
esttab using female_DiDiD_results.csv, se(4) r2 star(* 0.1 ** 0.05 *** 0.01) replace
eststo clear





* no college DiDiD regressions & event study

foreach y in ln_wage lfp employed uhrswork {
	xtreg `y' uninsured_post medicaid_uninsured_post college hispanic black asian othrace citizen married female ///
		age30_35 age35_40 age40_45 age45_50 age50_55 i.year#i.statefip if college==0, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'
	
	*event study
	xtreg `y' uninsured_y_2011 uninsured_y_2012 uninsured_y_2014 uninsured_y_2015 uninsured_y_2016 ///
		medicaid_uninsured_y_2011 medicaid_uninsured_y_2012 medicaid_uninsured_y_2014 medicaid_uninsured_y_2015 ///
		medicaid_uninsured_y_2016 college hispanic black asian othrace citizen married female ///
		age30_35 age35_40 age40_45 age45_50 age50_55 i.year#i.statefip if college==0, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'_ES
	
}
esttab using no_college_DiDiD_results.csv, se(4) r2 star(* 0.1 ** 0.05 *** 0.01) replace
eststo clear





* college DiDiD regressions & event study

foreach y in ln_wage lfp employed uhrswork {
	xtreg `y' uninsured_post medicaid_uninsured_post college hispanic black asian othrace citizen married female ///
		age30_35 age35_40 age40_45 age45_50 age50_55 i.year#i.statefip if college==1, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'
	
	*event study
	xtreg `y' uninsured_y_2011 uninsured_y_2012 uninsured_y_2014 uninsured_y_2015 uninsured_y_2016 ///
		medicaid_uninsured_y_2011 medicaid_uninsured_y_2012 medicaid_uninsured_y_2014 medicaid_uninsured_y_2015 ///
		medicaid_uninsured_y_2016 college hispanic black asian othrace citizen married female ///
		age30_35 age35_40 age40_45 age45_50 age50_55 i.year#i.statefip if college==1, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'_ES
	
}
esttab using college_DiDiD_results.csv, se(4) r2 star(* 0.1 ** 0.05 *** 0.01) replace
eststo clear





* age25_35 DiDiD regressions & event study

foreach y in ln_wage lfp employed uhrswork {
	xtreg `y' uninsured_post medicaid_uninsured_post college hispanic black asian othrace citizen married female ///
		 i.year#i.statefip if age25_35==1, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'
	
	*event study
	xtreg `y' uninsured_y_2011 uninsured_y_2012 uninsured_y_2014 uninsured_y_2015 uninsured_y_2016 ///
		medicaid_uninsured_y_2011 medicaid_uninsured_y_2012 medicaid_uninsured_y_2014 medicaid_uninsured_y_2015 ///
		medicaid_uninsured_y_2016 college hispanic black asian othrace citizen married female ///
		i.year#i.statefip if age25_35==1, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'_ES
	
}
esttab using age25_35_DiDiD_results.csv, se(4) r2 star(* 0.1 ** 0.05 *** 0.01) replace
eststo clear




* age25_45 DiDiD regressions & event study

foreach y in ln_wage lfp employed uhrswork {
	xtreg `y' uninsured_post medicaid_uninsured_post college hispanic black asian othrace citizen married female ///
		 i.year#i.statefip if age45_55==0, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'
	
	*event study
	xtreg `y' uninsured_y_2011 uninsured_y_2012 uninsured_y_2014 uninsured_y_2015 uninsured_y_2016 ///
		medicaid_uninsured_y_2011 medicaid_uninsured_y_2012 medicaid_uninsured_y_2014 medicaid_uninsured_y_2015 ///
		medicaid_uninsured_y_2016 college hispanic black asian othrace citizen married female ///
		i.year#i.statefip if age45_55==0, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'_ES
	
}
esttab using age25_45_DiDiD_results.csv, se(4) r2 star(* 0.1 ** 0.05 *** 0.01) replace
eststo clear







* age45_55 DiDiD regressions & event study

foreach y in ln_wage lfp employed uhrswork {
	xtreg `y' uninsured_post medicaid_uninsured_post college hispanic black asian othrace citizen married female ///
		 i.year#i.statefip if age45_55==1, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'
	
	*event study
	xtreg `y' uninsured_y_2011 uninsured_y_2012 uninsured_y_2014 uninsured_y_2015 uninsured_y_2016 ///
		medicaid_uninsured_y_2011 medicaid_uninsured_y_2012 medicaid_uninsured_y_2014 medicaid_uninsured_y_2015 ///
		medicaid_uninsured_y_2016 college hispanic black asian othrace citizen married female ///
		i.year#i.statefip if age45_55==1, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'_ES
	
}
esttab using age45_55_DiDiD_results.csv, se(4) r2 star(* 0.1 ** 0.05 *** 0.01) replace
eststo clear




clear
use heterogeneity_race.dta

* create interaction variables for event study models
sum year
forvalues i = 2011/2016{
	gen y_`i' = (year == `i')
	gen uninsured_y_`i' = uninsured_rate_2013 * y_`i'
	gen medicaid_uninsured_y_`i' = medicaid_uninsured * y_`i'
	gen medicaid_y_`i' = medicaid * y_`i'
}


* White DiDiD regressions & event study

foreach y in ln_wage lfp employed uhrswork {
	xtreg `y' uninsured_post medicaid_uninsured_post college hispanic black asian othrace citizen married female ///
		age30_35 age35_40 age40_45 age45_50 age50_55 i.year#i.statefip if white==1, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'
	
	*event study
	xtreg `y' uninsured_y_2011 uninsured_y_2012 uninsured_y_2014 uninsured_y_2015 uninsured_y_2016 ///
		medicaid_uninsured_y_2011 medicaid_uninsured_y_2012 medicaid_uninsured_y_2014 medicaid_uninsured_y_2015 ///
		medicaid_uninsured_y_2016 college hispanic black asian othrace citizen married female ///
		age30_35 age35_40 age40_45 age45_50 age50_55 i.year#i.statefip if white==1, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'_ES
	
}
esttab using white_DiDiD_results.csv, se(4) r2 star(* 0.1 ** 0.05 *** 0.01) replace
eststo clear



* Non-White DiDiD regressions & event study

foreach y in ln_wage lfp employed uhrswork {
	xtreg `y' uninsured_post medicaid_uninsured_post college hispanic black asian othrace citizen married female ///
		age30_35 age35_40 age40_45 age45_50 age50_55 i.year#i.statefip if white==0, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'
	
	*event study
	xtreg `y' uninsured_y_2011 uninsured_y_2012 uninsured_y_2014 uninsured_y_2015 uninsured_y_2016 ///
		medicaid_uninsured_y_2011 medicaid_uninsured_y_2012 medicaid_uninsured_y_2014 medicaid_uninsured_y_2015 ///
		medicaid_uninsured_y_2016 college hispanic black asian othrace citizen married female ///
		age30_35 age35_40 age40_45 age45_50 age50_55 i.year#i.statefip if white==0, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'_ES
	
}
esttab using non_white_DiDiD_results.csv, se(4) r2 star(* 0.1 ** 0.05 *** 0.01) replace
eststo clear






describe, short
log close

view prelim_regression_analysis.log
