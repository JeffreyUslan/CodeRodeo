* Go over details of merge command on slurpee day 2014, 2014-07-11
* Other things to celebrate today:
*   - Independence Day, plus a week
*   - Tesla's birthday, plus a day
*   - Skylab falls to earth in 1979

* Set operating system dependent working directory
	if "`c(os)'" == "Windows" {
		local initialslash /
	}
	else {
		local initialslash
	}
	cd `initialslash'/storage/server/CodeRodeo/Stata_merge/
	
* Help file
	local showhelp 1
	if `showhelp' {
		if "`c(console)'" == "console" {
			man merge
		}
		else {
			help merge
		}
	}
	
* Many-to-many demo
	* Create two data sets with many instances of each siteid, let's say a washer & dryer data set
	clear
	set obs 5
	generate siteid = 10000 + _n
	expand 5
	by siteid, sort: generate cw_id = _n
	set seed 8675309
	generate cw_data = runiform()
	tempfile mainmany
	save "`mainmany'"
	list
	
	keep siteid
	by siteid, sort: generate dr_id = _n
	set seed 1800.6498568
	generate dr_data = runiform()
	tempfile newmany
	save "`newmany'"
	list
	
	merge m:m siteid using "`mainmany'"
	list
	use "`newmany'", clear
	gsort siteid -dr_id
	merge m:m siteid using "`mainmany'"
	list
	display "Okay kids, friends don't let friends do m:m"
	
	display "Did you mean to match every case to every case?"
	use "`mainmany'", clear
	expand 5
	by siteid cw_id, sort: generate dr_id = _n
	merge m:1 siteid dr_id using "`newmany'"
	sort siteid cw_id dr_id
	list

* Keepusing demo
	* Create two data sets, one with extra fields
	clear
	set obs 5
	generate siteid = 10000 + _n
	generate type = "SF"
	generate clim = ceil( runiform() * 3 )
	tempfile climates
	save "`climates'"
	list
	
	clear
	set obs 5
	generate siteid = 10000 + _n
	generate data = runiform()
	list
	
	* Now merge in the climate variable
	merge 1:1 siteid using "`climates'", keepusing(clim)
	list

* generate/nogenerate
	* I think we're good on this one. By default, _merge is a new variable added to the data set
	* (see the examples from above). If you don't want this output, use nogenerate. If you want 
	* the output, but want to name it something different use generate(varname).
	
* nolabel/nonotes
	* I haven't ever had a need for these.
	
* update/replace
	clear
	set obs 5
	generate siteid = 10000 + _n
	generate data = runiform()
	replace data = . in 5
	tempfile urdata
	save "`urdata'"
	list
	
	merge 1:1 siteid using "`urdata'"
	list
	
	clear
	set obs 5
	generate siteid = 10000 + _n
	generate data = runiform() + 10
	tempfile urdata2
	save "`urdata2'"
	list
	
	use "`urdata'", clear
	preserve
		merge 1:1 siteid using "`urdata2'"
		list
	restore
	preserve
		merge 1:1 siteid using "`urdata2'", update
		list
	restore
	preserve
		merge 1:1 siteid using "`urdata2'", update replace
		list
	restore

* noreport
	* This just turns off displaying the summary table in the results window
	
* force 
	clear
	set obs 5
	generate siteid = 10000 + _n
	generate data = runiform()
	replace data = . in 5
	tempfile urdata
	save "`urdata'"
	list
	
	clear
	set obs 5
	generate siteid = 10000 + _n
	generate data = runiform() + 10
	tostring data, replace force
	tempfile urdata2
	save "`urdata2'"
	list
	
	use "`urdata'", clear
	*merge 1:1 siteid using "`urdata2'"
	*merge 1:1 siteid using "`urdata2'", force
	merge 1:1 siteid using "`urdata2'", update replace force
	list

* assert/keep
	* This is where the fun begins!
	* Generate two data sets, but with a different number of siteids
	clear
	set obs 3
	generate siteid = 10000 + _n
	generate data = runiform()
	tempfile urdata
	save "`urdata'"
	list
	
	clear
	set obs 5
	generate siteid = 10000 + _n
	generate data2 = runiform() + 10
	tempfile urdata2
	save "`urdata2'"
	list
	
	use "`urdata'", clear
	preserve
		* A normal merge will keep all siteids from all data sets
		merge 1:1 siteid using "`urdata2'"
		list
	restore
	* keep
		* keep(match master using) will only keep the siteids that show up in the data set(s) you 
		* specify:
		*   match: siteid must show up in both data sets
		*   master: siteid shows up in the master data set, but not in the using data set
		*   using: siteid shows up in the using data set, but not the master
	preserve
		merge 1:1 siteid using "`urdata2'", keep(match master)
		list
	restore
	preserve
		merge 1:1 siteid using "`urdata2'", keep(master using)
		list
	restore
	preserve
		merge 1:1 siteid using "`urdata2'", keep(match using)
		list
	restore
	* assert
		* assert(match master using) will also keep the siteids that show up in the data set(s) you 
		* specify, but the assert comman will not allow unmatched siteids from the data set(s) not 
		* specified. For instance, the master data has 3 siteids that are all represented in the 5 
		* siteids of the using data. So we can assert on the match and using, which will capture 
		* all the siteids in the data set:
	preserve
		merge 1:1 siteid using "`urdata2'", assert(match using)
		list
	restore
		* But we cannot assert on match and master because the using data has a extra siteids:
	preserve
		merge 1:1 siteid using "`urdata2'", assert(match master)
		list
	restore
	* In the examples above keep(match using) returns the same result as assert(match using), but 
	* keep(match master) is not the same as assert(match master) because of the error in siteid 
	* being deficient in the master data set. So, if we drop one site from the using data set then 
	* we'll get an error any time we try to use assert unless you specify all three data sets:
	use "`urdata2'"
	drop in 1
	preserve
		merge 1:1 siteid using "`urdata'", assert(match master using)
		list
	restore
	preserve
		merge 1:1 siteid using "`urdata'", assert(match using)
		list
	restore
	
	* Ecotope protocol:
	
	*   - keep(match master) or keep(match using) or keep(match) are the versions I use the most, 
	*     in that order. How about you?
	
	*   - assert should be used whenever you're trying to keep a complete data set together, for 
	*     instance when your data has 100 sites to start and you want to make sure the final data 
	*     set also has 100 sites, and the data are complete for the 100 sites. assert(match) is 
	*     your friend here. Better to have Stata stop when it's deficient so you can fix the 
	*     problem at the source then to have the code go all the way through before you realize 
	*     the deficiency.
	
	*   - Don't use force. Better practice is to let your code run into errors and then insert a 
	*     fix into the do file before the merge happens. The fix is to change the offending 
	*     variable to be the same data type in each data set.
	
	*   - Really don't use capture, unless you're going to act on it. This was a talk from a couple 
	*     weeks ago and is just here as a reminder. capture is best used to find an error and then 
	*     change course if an error occurs. 'capture confirm string variable' is a good use of the 
	*     capture command, where you can do one routine if the variable is a string and another 
	*     routine if the variable is numeric. I can't think of any scenarios where we'd use capture 
	*     on a merge, so I'll open the floor for discussion on this one. My feeling is if an error 
	*     is going to occur in a merge, then we always want Stata to stop running so we can fix 
	*     that error, rather than having the code continue with an ill-formed unexpected data set.
	
	*   - My personal preference is to always merge data sets with no common variable names (except 
	*     for the variables explicitly specified in the merge statement). If I need to then combine 
	*     together two variables that mean the same thing, I can generate a new variable and have a 
	*     record in the do file of exactly how I did that step. I can then drop the original 
	*     variables if I don't need them anymore.
	
