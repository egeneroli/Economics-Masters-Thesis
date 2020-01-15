

set more off
*set trace on
capture log close
cd "C:\Users\Evan Generoli\Documents\Graduate School\Fall Semester 2018\Thesis\Dataset_and_Analysis_9_26_18"
log using ACS_9_26_18_cleaning.log, replace
clear
use ACS_9_26_18_truncated.dta
describe, short

* truncate sample to prime working age population
* lower age bound at 25 to minimize adult students in sample
* upper age bound at 55 to minimize early retirees in sample

* drop if age < 25 | age > 55
* truncating sample by age already done in formatting do file

*\ adding in medicaid expansion data

*dropping early expanding states
drop if inlist(statefip, 10,11,25,36,50)

*dropping late expanding states
drop if inlist(statefip, 2,18,22,23,26,30,33,42,51)

gen medicaid = .

replace medicaid = 0 if inlist(statefip, ///
	1,12,13,16,20,28,29,31,37,40,45,46,47,48,49,55,56)

replace medicaid = 1 if inlist(statefip, ///
	4,5,6,8,9,15,17,19,21,24,27,32,34,35,38,39,41,44,53,54)
			
*\ gen post variable
gen post=(year>=2014)


* checking if having missing education value is correlated with anything
gen missing_ed = 0
replace missing_ed = 1 if educ == 0
tab educ missing_ed
reg missing_ed sex age marst race hispan ///
	citizen speakeng hcovany empstat labforce
drop missing_ed
* note that citizen is the strongest predictor of having "no schooling"

***********************************************
* generate categorical variables for collapse *
***********************************************

* create indicator for whether person has attended college at all
*replace educ = . if educ==0
gen college = .
replace college = 0 if educ <= 6
replace college = 1 if educ >= 7
*replace college = . if educ == .
sum college


* create race indicators
gen hispanic = (hispand~=0 & hispand~=900)
gen black = (raced==200 & hispanic==0)
gen asian = (raced>=400 & raced<=699) & hispanic==0
*gen native = (raced>=300 & raced<=399) & hispanic==0
gen white = (raced==100 & hispanic==0)
gen othrace = (hispanic==0 & black==0 & asian==0 & white==0)
assert hispanic+black+asian+white+othrace==1

gen non_white = (white == 0)
assert white + non_white == 1


* create indicators for age categories
gen age25_35 = (age <= 35)
gen age35_45 = (age > 35 & age <= 45)
gen age45_55 = (age > 45)
assert age25_35 + age35_45 + age45_55 == 1

gen age25_45 = (age45_55 == 0)
assert age25_45 + age45_55 == 1

gen age25_30 = (age <= 30)
gen age30_35 = (age > 30 & age <= 35)
gen age35_40 = (age > 35 & age <= 40)
gen age40_45 = (age > 40 & age <= 45)
gen age45_50 = (age > 45 & age <= 50)
gen age50_55 = (age > 50 & age <= 55)
assert age25_30+age30_35+age35_40+age40_45+age45_50+age50_55 == 1

* create binary variable for sex
gen female = (sex==2)
sum female
tab female sex

* create binary variable for employed
gen employed = .
replace employed = 0 if empstat == 2
replace employed = 1 if empstat == 1
sum employed
tab employed empstat

* create binary variable for labor force participation
gen lfp = (labforce==2)
sum lfp
tab lfp labforce

* create ln_incwage, wage and ln_wage
* assume everyone in sample works 52 weeks per year to calculate hourly wage
* b/c wkswork2 is a shitty categorical variable w/ ~20% missing

* recode zeros in incwage as missing
replace incwage = . if incwage == 0
gen ln_incwage = ln(incwage)
gen wage = incwage / (uhrswork * 52)

* drop outliers in wage variable
replace wage = . if wage < 1
replace wage = . if wage > 1000

gen ln_wage = ln(wage)



* create indicator for married
gen married = .
replace married = 0 if marst <= 3
replace married = 1 if marst > 3

* create citizen indicator
rename citizen citizen_orig
gen citizen = .
replace citizen = 0 if citizen_orig == 3
replace citizen = 1 if citizen_orig < 3
tab citizen citizen_orig


* recode missing values for uhrswork
replace uhrswork = . if uhrswork==0


* create indicator for poverty status
*preserve

*gen poverty_rate = .
*replace poverty_rate = 0 if poverty >= 100
*replace poverty_rate = 1 if poverty < 100

* create collapsed dataset of poverty rates by constantpuma and year
/*
collapse poverty_rate, by(cpuma0010 year)

save poverty_rates.dta, replace

restore
*/

* merge dataset of poverty rates back into master
*merge m:1 cpuma0010 year using poverty_rates.dta
*drop _merge

* create indicator for insurance status
gen uninsured = 0 if hcovany == 2
replace uninsured = 1 if hcovany == 1

* create collapsed dataset of 2013 uninsured rates by constantpuma
/*
preserve

collapse uninsured, by(cpuma0010 year)

drop if year != 2013
drop year
rename uninsured uninsured_rate_2013

save puma_uninsured_rates.dta, replace

restore
*/

* merge dataset of uninsured rates back into master
merge m:1 cpuma0010 using puma_uninsured_rates.dta
drop _merge


gen medicaid_post = medicaid * post
gen uninsured_post = uninsured_rate_2013 * post
gen medicaid_uninsured = medicaid * uninsured_rate_2013
gen medicaid_uninsured_post = medicaid * uninsured_rate_2013 * post


forvalues i = 2009/2016{
	gen y_`i' = (year == `i')
	gen uninsured_y_`i' = uninsured_rate_2013 * y_`i'
	gen medicaid_uninsured_y_`i' = medicaid_uninsured * y_`i'
}

* cut sample to only be 2011+
drop if year < 2011



*****************************************************************************************************
*****************************************************************************************************



save ACS_cleaned_9_27_18.dta, replace

clear
use ACS_cleaned_9_27_18.dta

* collapse dataset to state level means (default stat is mean)
collapse ///
	employed lfp uninsured_rate_2013 uninsured medicaid incwage ///
	uhrswork age25_30 age30_35 age35_40 age40_45 age45_50 age50_55 ///
	ln_incwage wage ln_wage medicaid_post hispanic black asian ///
	othrace citizen medicaid_uninsured medicaid_uninsured_post ///
	married uninsured_post, by(statefip cpuma0010 year female college age25_35 age35_45 age45_55)

*save ACS_collapsed_state_puma.dta, replace
save "C:\Users\Evan Generoli\Documents\Graduate School\Fall Semester 2018\Thesis\Final_to_turn_in\main_analysis_and_heterogeneity.dta"


clear
use ACS_cleaned_9_27_18.dta

* collapse dataset to state level means (default stat is mean)
collapse ///
	employed lfp uninsured_rate_2013 uninsured medicaid incwage ///
	uhrswork age25_30 age30_35 age35_40 age40_45 age45_50 age50_55 ///
	ln_incwage wage ln_wage medicaid_post hispanic black asian ///
	othrace citizen medicaid_uninsured medicaid_uninsured_post ///
	married uninsured_post, by(statefip cpuma0010 year female college age25_35 age35_45 age45_55 white)

*save ACS_collapsed_state_puma.dta, replace
save "C:\Users\Evan Generoli\Documents\Graduate School\Fall Semester 2018\Thesis\Final_to_turn_in\heterogeneity_race.dta"








/*
clear
use ACS_cleaned_9_27_18.dta


collapse college age25_35 age35_45 age45_55 ///
female incwage employed lfp uninsured_rate_2013 ///
poverty_rate uninsured medicaid uhrswork, by(cpuma0010 year)

save ACS_collapsed_puma.dta, replace


clear
use ACS_cleaned_9_27_18.dta

collapse college age25_35 age35_45 age45_55 ///
female incwage employed lfp uninsured_rate_2013 ///
poverty_rate uninsured medicaid uhrswork, by(statefip cpuma0010 year)

save ACS_collapsed_state_puma.dta, replace



* save summary dataset of cell counts
restore
collapse (count) college age25_35 age35_45 age45_55 ///
female incwage employed lfp uninsured_rate_2013 ///
poverty_rate uninsured uhrswork, by(statefip year)

save ACS_collapsed_counts.dta, replace
*/

describe, short
log close

view ACS_9_26_18_cleaning.log
