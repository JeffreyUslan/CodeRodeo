*adjust billing data ddregs to post-install weather and long-term average weather
clear

use ../data/BDddregs

merge m:1 siteid using ../data/site_info, assert(match) keepusing(siteid staName installDate) nogenerate

gen date_install = date(installDate,"DMY")
format date_install %td
replace installDate = string(date_install, "%tdCCYY.NN.DD")
drop date_install

gen ddadj_bal = 0
gen ddnorm_bal = 0
local nobs = c(N)

forvalues i = 1/`nobs' {
	dd_lta `=staName[`i']', start_date(`=installDate[`i']') base(`=tbal[`i']')
	replace ddadj_bal = `r(dd)' in `i'
	dd_lta `=staName[`i']',  base(`=tbal[`i']')
	replace ddnorm_bal = `r(dd)' in `i'	
}

gen adj_heat1= ddadj_bal*slope
gen norm_heat1= ddnorm_bal*slope

gen adj_kWh_y = ddadj_bal*slope+const*365
gen norm_kWh_y = ddnorm_bal*slope+const*365

label var ddadj_bal "Degree days at balance pt in metering period weather"
label var ddnorm_bal "Degree days at balance pt for normalized weather"
label var adj_heat1 "Heating kWh/yr in metering period weather"
label var norm_heat1 "Heating kWh/yr for normalized weather"
label var adj_kWh_y "Total Service kWh/yr in metering period weather"
label var norm_kWh_y "Total Service kWh/yr for normalized weather"


format kWh_y adj_kWh_y norm_kWh_y ddbal_y heat1_y othr1_y ddadj_bal ddnorm_bal adj_heat1 norm_heat1 %9.0f

save ../data/BD_norm_adjusted, replace


