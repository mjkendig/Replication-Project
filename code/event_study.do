eststo clear 
cap log close 
log using "code/event_study.log", replace 
local start_time = "${S_TIME}"
assert ("$controls"!="") // if this fails, need to run set_parameters.do 

eststo clear 
forvalues i = 1/3 { 
	if `i'!= 0 { // Spec 1 AND defaults 
		global time_var year // "year" or "survey_time"
		global date_var year // "year" or "mdate"
		global et_max 6
		global event (any_merit==1) & (any_merit[_n-1]==0)
		global balance neg_event>=2 & pos_event>=2
		global FE_controls i.year#i.wac#i.sicdiv#i.jobn
	}

	if `i'==2 { // Spec 2: using survey time
		global time_var survey_time
		global date_var mdate 
		global survey_time 1 // Use surveys to measure time instead of calendar years 
	}
	if `i'==3 { // Spec 5: tight balance
		global et_max 4
		global balance neg_event>=3 & pos_event>=3
	}
	**********************************
	if ("$time_var"=="survey_time") global xname "Surveys"
	if ("$time_var"=="year") global xname "Years"
	
	use using created/fullworking.dta, clear
	gegen id=group(estid jobn)
	gen mdate = mofd(mdy(month,1,year))
	tempfile tmp
	save `tmp', replace 

	* Collapse data to calculate event time
	gcollapse (firstnm) id change wac sicdiv (min) minhourly (max) maxhourly union any_merit=merit seniorityw=seniority ///
			  (sum) numemp /// 
			  (mean) lnnumemp lnnemp mean_spread=spread share_merit=merit office nemp lnhourlyc [aw=numemp], /// 
			  by($date_var estid jobn)
			  
	bys id ($date_var): gen survey_time = _n 
	
	* Identify switch
	bys id ($time_var): gen occurrence = $time_var if $event 
	bys id: gegen first_event = min(occurrence)

	* Make event time variables / bin 
	gen event_time = clip(floor(($time_var - first_event)),-$et_max,$et_max)

	* Balance
	display "Event time"
	tab event_time
	if "$balance"!="" {
		bys id: gegen neg_event = sum(event_time<0)
		bys id: gegen pos_event = sum(event_time>=0 & event_time!=.)
		bys id: gen id_N = _N 
		keep if ($balance) | (first_event==.)
		display "Event time after balance"
		tab event_time
	} 
	
	* Add 1000 for regression; Non-merit places get omitted period
	replace event_time = event_time+1000
	replace event_time = 999 if first_event==.   

	* Restore original one-wage-per-row structure
	keep $date_var estid jobn event_time survey_time
	tempfile et_temp
	save `et_temp', replace 

	use `tmp', clear 
	merge m:1 $date_var estid jobn using `et_temp', nogen 

	di "On spec `i'"
	label define et_vals 994 "-6 yrs" 995 "-5 yrs" 996 "-4 yrs" 997 "-3 yrs" 998"-2 yrs"  1000 " 0 yrs"  1001 "1 yrs"  1002 "2 yrs"  1003 "3 yrs"  1004 "4 yrs" 1005 "5 yrs"
	label values event_time et_vals
	eststo reg`i': reghdfe lnhourlyc ib(999).event_time $controls [aw=$weight], absorb(id $FE_controls) cluster(estid)
	di "Count of switchers "
	count if event_time==1000 & e(sample)==1
	qui estadd scalar n_switchers = `r(N)'
	global cmd = e(cmdline)
	estimates title : Output of <`e(cmdline)'>

	* Save results
	tempfile coefs`i'
	tempname poster 
	postfile `poster' float(et b_T se_T) using `coefs`i'', replace
	
	forvalues etx = -$et_max/$et_max {
		local eti = 1000 + `etx'
		if (`eti'!= 999) post `poster' (`etx') (_b[`eti'.event_time]) (_se[`eti'.event_time])
		if (`eti'== 999) post `poster' (`etx') (0) (0)
	}
	postclose `poster' 
	 
	* Plot results 
	use `coefs`i'', clear 
	gen ub_T = b_T + 1.96*se_T
	gen lb_T = b_T - 1.96*se_T
	
	* Paper fig 
	global xrange = $et_max
	twoway  (connected b_T   et, cmissing(n) msymbol(diamond) msize(small) mlwidth(tiny) mfcolor(black) mlcolor(black) lwidth(vthin) lcolor(black)) /// 
			(rcap ub_T lb_T et , lcolor(black%40) lpattern(dash)), legend(off) ytitle(Event study coefficient) /// 
			 xtitle("$xname Since Switch to Non-Standardized Pay") /// 
			 xscale(range(-$xrange $xrange)) xlabel(-$xrange(1)$xrange) graphregion(fcolor(white)) plotregion(fcolor(white)) 
	graph export "results/event_study_fig_spec`i'.pdf", replace 
}

if ($stars==1) local starcode star(* 0.05  ** 0.01  *** 0.001)
if ($stars==0) local starcode nostar

* Export / Edit coefficient table 
esttab reg1 reg2 reg3 using results/event_study_table.tex, `starcode' keep(*event*) drop(999.event_time) stats(r2 N n_switchers, fmt(3 %9.0fc %9.0fc) label("R-squared" "N" "N switchers")) se label  se(3) b(3) varlabels(994.event_time "-6 yrs" 994bn.event_time "-6 yrs" 995.event_time "-5 yrs" 996.event_time "-4 yrs" 997.event_time "-3 yrs" 998.event_time "-2 yrs" 998bn.event_time "-2 yrs"  1000.event_time " 0 yrs"  1001.event_time "1 yrs"  1002.event_time "2 yrs"  1003.event_time "3 yrs"  1004.event_time "4 yrs" 1005.event_time "5 yrs"  1006.event_time "6 yrs") replace mtitle("" "" "")

* Put some finishing touches on the .tex file:
// import delimited using results/event_study_table_esttab.tex, delim("%") clear 
// set obs `=_N+1'
// replace v1 = "\floatfoot{Note: Data from Wage Fixing Authority Survey. This table shows the estimated event study coefficients from equation (2) for the three specifications described in the empirical section. Column (1) corresponds to Figure and Columns (2) and (3) correspond to Figure \ref{fig:event_study_robustness} plots (a) and (b), respectively. N switchers gives the number of included job-by-establishments that abandoned standardized pay. Standard errors in parentheses.}" if v1==""
// // drop if _n==37
// drop if _n==4
// export delimited results/event_study_table.tex, novarnames delim(tab) replace
// sleep 20000
// erase results/event_study_table_esttab.tex
display "Started at `start_time' Ended at: ${S_TIME}"

log close 
