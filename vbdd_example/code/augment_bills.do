****************************************************************************************************
* Name: augment_bills
* Description: VBDD process example - augment bill stream to prepare to run a degree day regression
* Author(s): BL
* Date: 2013-09-16
* Modified: ?
* Bonus Info: ?
****************************************************************************************************

*start by opening our clean bill data set
use ../data/clean_bills, clear

*merge in weather station and installation date information for each site
merge m:1 siteid using ../data/site_info, assert(match) keepusing(siteid staName installDate) nogenerate

*create a variable to uniquely identify the bills belonging to the baseline period
*and the post installation period
*by convention, pre is -1 and post is 1
*then drop all the bills that have unassigned or ambigous dates
generate int prepost=.
replace prepost = -1 if readDate < date(installDate, "DMY")
replace prepost = 1  if readDate > date(installDate, "DMY")
drop if prepost==.

*change from kWh over the billing period to kWh per day over the period
*the DDreg routine wants things in units of kWh per day later on
replace kWh = kWh/days


*augment the bills with heating degree days to bases ranging from 48F to 70F
forvalues i = 48/70 {
    DDaddMultWeather `i' "siteid prepost" readDate staName days 
}

*augment the bills with cooling degree days to bases ranging from 60F to 80F
forvalues i = 60/80 {
    DDaddMultWeather `i' "siteid prepost" readDate staName days 1
}

*associate a weight with each bill so that we can create annualized results
*this allows us to have multiple months over several years
billWeights "siteid prepost" readDate days oneyrwt kWh


save ../data/augmented_bills, replace
