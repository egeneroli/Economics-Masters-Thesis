set more off
*set trace on
capture log close
cd "C:\Users\Evan Generoli\Documents\Graduate School\Fall Semester 2018\Thesis\Final_to_turn_in"
log sum_stats.log, replace

clear
use cleaned_data_indiv_lev.dta
describe, short

tabstat employed lfp incwage wage uhrswork ///
	medicaid uninsured_rate_2013 ///
	female age age25_35 age35_45 age45_55 college ///
	hispanic black asian white othrace ///
	, statistics(mean semean min max n) columns(statistics)



	
	
capture log close
