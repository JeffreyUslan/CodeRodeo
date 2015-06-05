set more off

*drop cdd  cooling-degree-day so ddreg will not try to use them
regexVlistFilter _all, regex(^cdd[0-9]+$)
local filtered `r(filtered)'
foreach var of local filtered {
    drop `var' 
}    

*perform the degree day regressions
DDreg "siteid prepost" kWh oneyrwt 0 0 /BDddregs

*graph the output of the degree day regressions
DDregGraph "siteid prepost" kWh  ../data/BDddregs


*now switch to cooling regressions --------------------------------------------------------------------
use ../data/augmented_bills, clear
*drop hdd heating-degree-day so ddreg will not try to use them
regexVlistFilter _all, regex(^dd[0-9]+$)
local filtered `r(filtered)'

foreach var of local filtered {
    drop `var' 
}    

DDreg "siteid prepost" kWh oneyrwt 0 0 /BDcddregs

CDDregGraph "siteid prepost" kWh  ../data/BDcddregs


