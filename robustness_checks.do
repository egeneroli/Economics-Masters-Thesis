set more off
*set trace on
capture log close
*cd "C:\Users\Evan Generoli\Documents\Graduate School\Fall Semester 2018\Thesis\Dataset_and_Analysis_9_26_18"
log using robustness_checks.log, replace


/*
clear

use ACS_cleaned_whole.dta, replace



************************************************************************************************

* collapse dataset to state level means (default stat is mean)
collapse incwage uhrswork ///
	employed lfp uninsured_rate_2013 uninsured medicaid ///
	ln_incwage wage ln_wage medicaid_post hispanic black asian ///
	white othrace citizen medicaid_uninsured medicaid_uninsured_post ///
	married uninsured_post, by(statefip cpuma0010 year female college age18_25 age25_35 age35_45 age45_55 age55_65 age65_75 age75_85 age85_95 age95plus)

*save ACS_collapsed_state_puma_whole.dta, replace
save "C:\Users\Evan Generoli\Documents\Graduate School\Fall Semester 2018\Thesis\Final_to_turn_in\robustness_checks.dta"

*/

cd "C:\Users\Evan Generoli\Documents\Graduate School\Fall Semester 2018\Thesis\Final_to_turn_in"

******************************************************************************************
************************************************* run on old people
clear
use robustness_checks.dta

drop if year < 2011

drop if age18_25==1 | age25_35==1 | age35_45==1 | age45_55==1 | age55_65==1 

* create interaction variables for event study models
forvalues i = 2011/2016{
	gen y_`i' = (year == `i')
	gen uninsured_y_`i' = uninsured_rate_2013 * y_`i'
	gen medicaid_uninsured_y_`i' = medicaid_uninsured * y_`i'
	gen medicaid_y_`i' = medicaid * y_`i'
}


* seniors DiDiD regressions & event study

foreach y in ln_wage lfp employed uhrswork {
	xtreg `y' uninsured_post medicaid_uninsured_post college hispanic black asian othrace citizen married female ///
		age75_85 age85_95 age95plus i.year#i.statefip, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'
	
	*event study
	xtreg `y' uninsured_y_2011 uninsured_y_2012 uninsured_y_2014 uninsured_y_2015 uninsured_y_2016 ///
		medicaid_uninsured_y_2011 medicaid_uninsured_y_2012 medicaid_uninsured_y_2014 medicaid_uninsured_y_2015 ///
		medicaid_uninsured_y_2016 college hispanic black asian othrace citizen married female ///
		age75_85 age85_95 age95plus i.year#i.statefip, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'_ES
	
}
esttab using RC_seniors_DiDiD_results.csv, se(4) r2 star(* 0.1 ** 0.05 *** 0.01) replace
eststo clear

;
******************************************************************************************
************************************************* add 2009,2010 pre-years (2009-2016)
clear
use robustness_checks.dta



drop if age18_25==1 | age55_65==1 | age65_75==1 | age75_85==1 | age85_95==1 | age95plus==1


* create interaction variables for event study models
forvalues i = 2009/2016{
	gen y_`i' = (year == `i')
	gen uninsured_y_`i' = uninsured_rate_2013 * y_`i'
	gen medicaid_uninsured_y_`i' = medicaid_uninsured * y_`i'
	gen medicaid_y_`i' = medicaid * y_`i'
}



eststo clear
* all years full sample DiDiD regressions & event study
* white and age25_30 are reference groups
foreach y in ln_wage lfp employed uhrswork {
	xtreg `y' uninsured_post medicaid_uninsured_post college hispanic black asian othrace citizen married female ///
		age35_45 age45_55 i.year#i.statefip, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'
	
	*event study
	xtreg `y' uninsured_y_2011 uninsured_y_2012 uninsured_y_2014 uninsured_y_2015 uninsured_y_2016 ///
		medicaid_uninsured_y_2011 medicaid_uninsured_y_2012 medicaid_uninsured_y_2014 medicaid_uninsured_y_2015 ///
		medicaid_uninsured_y_2016 college hispanic black asian othrace citizen married female ///
		age35_45 age45_55 i.year#i.statefip, fe i(cpuma0010) cluster(statefip)
	
	eststo `y'_ES
	
}
esttab using all_years_full_sample_DiDiD_results.csv, se(4) r2 star(* 0.1 ** 0.05 *** 0.01) replace
eststo clear




capture log close


view robustness_checks.log
