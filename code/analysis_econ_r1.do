/*******************************************************************************
	
		analysis_econ.do
		9.4.2020
		Main analysis for:
		"Wage Stagnation and the Rise of Merit Pay, 1974-1991"
		Nathan Wilmers and Maxim Massenkoff
	Packages needed:
	cpigen
	egenmore
	_gwtmean
	labutil	
	wordwrap 
		net from https://mloeffler.github.io/stata/
		net install wordwrap
	coefplot
	grc1leg
		
*******************************************************************************/

log using code/analysis_econ_r1.log, replace 

local start_time = "${S_TIME}"

global sec1  0  // 	SECTION 1. Descriptives
global sec2  0  // 	SECTION 2. Rates of merit pay over time
global sec3  0  // 	SECTION 3. Comparison to other wage data
global sec4  0  // 	SECTION 4. Decomposing wage stagnation trend
global sec5  0  // 	SECTION 5. Tight identification estimates
global sec6  0  // 	SECTION 6. Inequality evidence
global sec7  1  //  SECTION 7. Merit x firm size interaction
global sec8  0  //  SECTION 8. Change survey
global sec9  0  // Inflation (Online appendix)
global sec10 0  // merit adoption and job growth 
global sec11 0  // number of brackets by merit 
global sec12 0 // union-industry regions, union het 

global paper 1
global presentation 0

*-------------------------------------------------------------------------------
* SECTION 1. Descriptives
*-------------------------------------------------------------------------------
if $full_run | $sec1 {	
	// Open main data from build.do
	use created/fullworking.dta, clear

	label var sicwacunion "Share Union, Ind.-Wage Area"
	label var coworkjobq "Co-Workers' Occ. Level"
	label var office "Share Office in Est."
	label var colad "Share with COL Adj."

	// Descriptive table
	eststo nonmerit: estpost sum ///
	    hourlyc lnhourlyc $desccontrols bonusd piecerate colad ///
		if merit == 0 [aw = invrowwt], detail
	eststo merit: estpost sum ///
	    hourlyc lnhourlyc $desccontrols bonusd piecerate colad ///
		if merit == 1 [aw = invrowwt], detail
	 
	 esttab nonmerit merit using results/descriptives.tex, replace ///
	 cells("mean(fmt(2) label(Mean)) sd(fmt(2) label(SD)) p10(fmt(2) label(p(10)))  p90(fmt(2) label(p(90)))") nomtitles ///
	 mgroups("Standardized Pay Rates" "Non-Standardized/Flexible", pattern(1 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	 compress nonumbers label lines
	 
	preserve
	// Histogram of jobs over time
	duplicates drop estid year, force
	capture drop count
	bys estid: gen count=_N
	gen nochange=change==0
	bys estid: egen countnochange=total(nochange)

	twoway ///
	(histogram year, discrete freq fcolor(black) lcolor(black)) ///
	(histogram year if count>1, discrete freq fcolor(none) lcolor(gs7) lpattern(solid)) ///
	(histogram year if countnochange>1 & change!=1, discrete freq fcolor(none) lcolor(gs14) lpattern(solid))  ///
	, ///
	graphregion(color(white)) ///
	yla(0 "0" 5000 "5k" 10000 "10k") ///
	ylabel(, nogrid) plotregion(color(white)) ///
	ytitle("Number of Establishments") xtitle("") ///
	legend(col(1) ring(1) position(2) label(1 "All Estabs") label(2 "Panel" "Estabs") label(3 "Panel, excl." "Change Survey") ///
	region(lcolor(white)) size(small)  symxsize(5))
	graph export  results/histogramdistcomb.pdf, replace

	restore 
	
	// Firms and industries 
	local ind sicshort 

	// By industry
	bys `ind': gen icount=_N
	gen `ind'd=`ind' if icount>10000
	replace `ind'd=99 if `ind'd==.
	label values `ind'd `ind'

	gen manuf=sicdiv==4
	gen icountm=icount if manuf==1
	gen icounts=icount if manuf==0
	drop if `ind'd==99

	graph dot ///
	icountm icounts ///
	, over(`ind'd) ///
	exclude0  ///
	plotregion(color(white)) graphregion(color(white)) ///
	marker(1, msymbol(circle) mcolor(black)) ///
	marker(2, msymbol(circle) mcolor(gs10)) ///
	ytitle("Number of Jobs in WFAS") ///
	yscale(range(0 1000)) ///
	yla(0(20000)100000) ///
	legend(col(1) order(1 2) label(1 "Manuf.") label(2 "Services") position(2) /// 
	ring(0) region(lcolor(black)))
	graph export results/dot`ind'.pdf, replace
	drop icount icounts icountm
	
	// By jobn
	local occ jobtitle 
	replace jobtitle=proper(jobtitle)
	bys `occ': gen icount=_N
	gen `occ'd=`occ' if icount>10000
	gen icountus=icount if unskill==1
	gen icounts=icount if unskill==0

	graph dot ///
	icountus icounts ///
	, over(`occ'd, sort(lnhourlyc descending)) ///
	exclude0  ///
	plotregion(color(white)) graphregion(color(white)) ///
	marker(1, msymbol(circle) mcolor(black)) ///
	marker(2, msymbol(circle) mcolor(gs10)) ///
	ytitle("Number of Jobs in WFAS") ///
	legend(col(1) order(1 2) label(1 "Non-trades") label(2 "Trades") position(4) /// 
	ring(0) region(lcolor(black)))
	graph export results/dot`occ'.pdf, replace
	drop icount icountus icounts `occ'd
	
	// By estname
	replace estname=proper(estname)
	bys estname: gen ecount=_N
	replace estname="E.I. du Pont de Nemours" if estname=="E I Dupont De Nemours P"
	gen estnamed=estname if ecount>1000
	replace estnamed=strproper(estnamed)
	bys estname: egen elnhourlyc=mean(lnhourlyc)

	graph dot ///
	ecount ///
	, over(estnamed, sort(ecount)) ///
	exclude0 ///
	plotregion(color(white)) graphregion(color(white)) ///
	marker(1, msymbol(circle) mcolor(black)) ///
	yscale(range(0 1000)) ///
	yla(0(500)3000) ///
	ytitle("Number of Jobs in WFAS") 
	graph export results/dotestname.pdf, replace
	drop ecount

	****
	// Histograms of wages by year
	use created/fullworking.dta, clear
	local glist ""
	forvalues year=1974(2)1990 {
		twoway ///
		(histogram lnhourlyc if (rangereason=="L" | rangereason=="N") & lnhourlyc<3.5 & lnhourlyc>1.5 & year==`year', fcolor(black) lcolor(black) percent) ///
		(histogram lnhourlyc if merit==1 & lnhourlyc<3.5 & lnhourlyc>1.5 & year==`year', fcolor(none) lcolor(blue) percent) ///
		, graphregion(color(white)) plotregion(color(white)) ///
	ylabel(none, nogrid labsize(medium)) xlabel(none) legend(col(1) label(1 "Standardized") label(2 "Flexible") size(small) region(lcolor(white))) ///
	xtitle("") ytitle("") ///
		title("`year'") name(hist`year', replace)
		local glist "`glist' hist`year'"
	}

	grc1leg `glist' ///
	, graphregion(color(white)) ycommon xcommon col(3) position(7)
	graph export results/histogramwage.pdf, replace
	****
	
	// Make pay scale width chart
	use created/fullworking.dta, clear 
	drop if rangereason=="N"
	egen jobunit=group(year estid jobn maxhourly minhourly)
	bys jobunit: egen realmaxhourly=max(hourly)
	bys jobunit: egen realminhourly=min(hourly)

	foreach var in max min {
		gen `var'hourly2=`var'hourly 
		replace `var'hourly2=hourly if `var'hourly==. | `var'hourly==0
		replace `var'hourly2=`var'hourly2/cpiu
		gen ln`var'hourly2=ln(`var'hourly2)
		bys year unskill: egen `var'hourlyy=wtmean(ln`var'hourly2), weight($weight)
	}

	foreach var in realmax realmin {
		gen `var'hourly2=`var' 
		replace `var'hourly2=hourly if `var'hourly==. | `var'hourly==0
		replace `var'hourly2=`var'hourly2/cpiu
		gen ln`var'hourly2=ln(`var'hourly2)
		bys year unskill: egen `var'hourlyy=wtmean(ln`var'hourly2), weight($weight)
		drop `var'hourly2
	}
	bys year unskill: gen dup=cond(_N==1,0,_n)

	twoway ///
	(line maxhourlyy year if dup<2 & unskill==1, lcolor(gs10) lwidth(medthick) lpattern(solid)) ///
	(line minhourlyy year if dup<2 & unskill==1, lcolor(gs10) lwidth(medthick) lpattern(solid)) ///
	(line realmaxhourlyy year if dup<2 & unskill==1, lcolor(black) lwidth(medthick) lpattern(solid)) ///
	(line realminhourlyy year if dup<2 & unskill==1, lcolor(black) lwidth(medthick) lpattern(solid)) ///
	(line maxhourlyy year if dup<2 & unskill==0, lcolor(gs10) lwidth(medthick) lpattern(solid)) ///
	(line minhourlyy year if dup<2 & unskill==0, lcolor(gs10) lwidth(medthick) lpattern(solid)) ///
	(line realmaxhourlyy year if dup<2 & unskill==0, lcolor(black) lwidth(medthick) lpattern(solid)) ///
	(line realminhourlyy year if dup<2 & unskill==0, lcolor(black) lwidth(medthick) lpattern(solid)) ///
	, xtitle("") ytitle("Hourly Wages") ///
	ylabel(, nogrid labsize(medium)) ///
	xlabel(, labsize(medium)) plotregion(color(white)) ///
	graphregion(color(white)) ///
	legend(col(1) order(1 3) label(1 "Formal Pay" "Scale") label(3 "Observed" "Pay Range") ///
	position(4) ring(1) size(small) region(lcolor(white))) ///
	text(2.97 1973.7 "Trades", place(e)) ///
	text(2.29 1973.7 "Non-trades", place(e))
	graph export results/rangetrend.pdf, replace
	
	// Wage levels dot plot
	gen jobtitleb=jobtitle if core==1
	gen lnhourlycnp=lnhourlyc if merit==1
	gen lnhourlycp=lnhourlyc if merit!=1
	replace jobtitleb=strproper(jobtitleb)
	replace jobtitleb="Machine Tool Operator" if jobtitleb=="Machine Tool Operator II"
	replace jobtitleb="Machine Tool Operator" if jobtitleb=="Machine Tool Operator Ii"
	replace jobtitleb="Machine Tool Operator" if jobtitleb=="Machine Tool Operator I"
	bys jobtitleb: gen jobcount=_N
	replace jobtitleb="" if jobcount<10000
	bys jobtitleb: egen sortlnhourlyc=mean(lnhourlyc)

	graph dot ///
	lnhourlycnp ///
	lnhourlycp ///
	[aw=$weight] ///
	, over(jobtitleb, sort(sortlnhourlyc)) ///
	exclude0 ///
	plotregion(color(white)) graphregion(color(white)) ///
	marker(1, msymbol(circle) mcolor(black) msize(large)) ///
	marker(2, msymbol(circle) mcolor(gs9) msize(large)) ///
	legend(col(1) order(1 2) label(1 "Non-Standardized/Flexible") label(2 "Standardized Pay Rate") position(1) /// 
	ring(0) region(lcolor(white) color(white)) size(small)) ///
	ytitle("log(Hourly Wage)", size(medium)) aspect(1.2)
	graph export results/dotwageocc.pdf, replace

	graph dot ///
	lnhourlycnp ///
	lnhourlycp ///
	[aw=$weight] ///
	if union, over(jobtitleb, sort(sortlnhourlyc)) ///
	exclude0 ///
	plotregion(color(white)) graphregion(color(white)) ///
	marker(1, msymbol(circle) mcolor(black) msize(large)) ///
	marker(2, msymbol(circle) mcolor(gs9) msize(large)) ///
	legend(off) yscale(range(2.15 3.2)) ylabel(2.2(.2)3.2) ///
	ytitle("log(Hourly Wage)")
	graph export results/dotwageocc_union.pdf, replace

	graph dot ///
	lnhourlycnp ///
	lnhourlycp ///
	[aw=$weight] ///
	if union==0, over(jobtitleb, sort(sortlnhourlyc)) ///
	exclude0 ///
	plotregion(color(white)) graphregion(color(white)) ///
	marker(1, msymbol(circle) mcolor(black) msize(large)) ///
	marker(2, msymbol(circle) mcolor(gs9) msize(large)) ///
	legend(col(1) order(1 2) label(1 "Non-Standardized") label(2 "Standardized") position(2) /// 
	ring(0) region(lcolor(black)) size(small)) ///
	ytitle("log(Hourly Wage)")
	graph export results/dotwageocc_nonunion.pdf, replace
}

*-------------------------------------------------------------------------------
* SECTION 2. Rates of merit pay over time
*-------------------------------------------------------------------------------
if $full_run | $sec2 {
	use created/fullworking.dta, clear
	
	sum office [aw = invrowwt], detail
	gen officelevel=office>r(p50)
	
	sum merit [aw = $weight] if year==1974
	sum merit [aw = $weight] if year==1991

	// Add labels
	label define sicdiv 1 "Agriculture" 2 "Mining" 3 "Construction" 4 "Manufacturing" 5 "Transportation" 6 "Wholesale" 7 "Retail" 8 "Finance, insurance and real estate" 9 "Services", replace
	label define union 0 "Non-union" 1 "Union", replace
	label define unskill 0 "Trades" 1 "Non-trades", replace
	label define bigregionn 1 "Midwest" 2 "North" 3 "South" 4 "West", replace
	label define size 1 "0-199" 2 "200+", replace
	label define unit 1 "Merit", replace
	label define officelevel 0 "Low office" 1 "High office", replace

	foreach cat in unit sicdiv unskill union bigregionn size officelevel {
		bys `cat' period: egen m`cat'=wtmean(merit), weight($weight)
		bys `cat' period: gen dup`cat'=cond(_N==1,0,_n)
		gen labelertemp=`cat' if period==3
		label values `cat' `cat'
		label values labelertemp `cat'
		decode labelertemp, gen(labeler`cat')
		replace labeler`cat'="" if labeler`cat'=="."
		drop labelertemp
	}

	drop seniority
	gen seniority=rangereason=="L"
	gen none=rangereason=="N"
	foreach cat in unit {
		foreach practice in merit seniority none {
			bys `cat' year: egen `practice'`cat'=wtmean(`practice'), weight($weight)
		}
	}

	bys year: gen dupall=cond(_N==1,0,_n)
	gen labelermerit="Flexible" if year==1991
	gen labelerseniority="Seniority" if  year==1991
	gen labelernone="No Range" if year==1991

	local merit="lwidth(medthick) msymbol(none) c(l) lcolor(gs10) mlabel(labelermerit) mlabcolor(black)"
	local seniority="lwidth(medthick) msymbol(none) c(l) lcolor(black) mlabel(labelerseniority) mlabcolor(black)"
	local none="lwidth(medthick) msymbol(none) c(l) lcolor(black) mlabel(labelernone) mlabcolor(black)"

	local sicdiv="lwidth(medthick)  msymbol(circle) mcolor(black) c(l) lcolor(black) mlabel(labelersicdiv) mlabcolor(black)"
	local sicdiv2="lwidth(medthick)  msymbol(circle) mcolor(gs10) c(l) lcolor(gs10) mlabel(labelersicdiv) mlabcolor(black)"

	local unskill="lwidth(medthick)  msymbol(circle) mcolor(black) c(l) lcolor(black) mlabel(labelerunskill) mlabcolor(black)"
	local unskill2="lwidth(medthick)  msymbol(circle) mcolor(black) c(l) lcolor(black) mlabel(labelerunskill) mlabcolor(black)"

	local union="lwidth(medthick)  msymbol(circle) mcolor(gs10) c(l) lcolor(gs10) mlabel(labelerunion) mlabcolor(black)"
	local union2="lwidth(medthick)  msymbol(circle) mcolor(gs10) c(l) lcolor(gs10) mlabel(labelerunion) mlabcolor(black)"

	local bigregionn="lwidth(medthick)  msymbol(circle) mcolor(black) c(l) lcolor(black) mlabel(labelerbigregionn) mlabcolor(black)"
	local bigregionn2="lwidth(medthick)  msymbol(circle) mcolor(gs10) c(l) lcolor(gs10) mlabel(labelerbigregionn) mlabcolor(black)"

	local size="lwidth(medthick)  msymbol(circle) mcolor(gs10) c(l) lcolor(gs10) mlabel(labelersize) mlabcolor(black)"
	local size2="lwidth(medthick)  msymbol(circle) mcolor(gs10) c(l) lcolor(gs10) mlabel(labelersize) mlabcolor(black)"

	local officelevel="lwidth(medthick)  msymbol(circle) mcolor(black) c(l) lcolor(black) mlabel(labelerofficelevel) mlabcolor(black)"
	local officelevel2="lwidth(medthick)  msymbol(circle) mcolor(black) c(l) lcolor(black) mlabel(labelerofficelevel) mlabcolor(black)"

	
	local definition="Source: Wage Fixing Authority Survey.  Flexible pay is discretionary (non-seniority), subjective (not piece rate), base pay (not a bonus) variation within a job."
	wordwrap "`definition'", l(70)
	local defshort1=r(text)
	di "`defshort1'"

	local aspect 1
	local range="1 3"

	sort year
	twoway ///
	(scatter meritunit year if unit==1 & dupall<2 & year!=1974, `merit') ///
	(scatter seniorityunit year if unit==1 & dupall<2 & year!=1974, `seniority') ///
	(scatter noneunit year if unit==1 & dupall<2 & year!=1974, `none') ///
	, legend(off) graphregion(color(white)) ///
	aspect(.9) ylabel(, nogrid) plotregion(color(white)) ///
	ytitle("Share of Jobs")  xtitle("")
	graph export results/adoptionunit.pdf, replace

	twoway ///
	(scatter meritunit year if unit==1 & dupall<2 & year!=1974, `merit') ///
	(scatter seniorityunit year if unit==1 & dupall<2 & year!=1974, `seniority') ///
	(scatter noneunit year if unit==1 & dupall<2 & year!=1974, `none') ///
	, legend(off) graphregion(color(white)) ///
	aspect(.9) ylabel(, nogrid) plotregion(color(white)) ///
	ytitle("Share of Jobs")  xtitle("")
	graph export results/adoptionunit.pdf, replace

	sort period
	twoway ///
	(scatter msicdiv period if sicdiv==2 & dupsicdiv<2, `sicdiv2' mlabposition(5)) ///
	(scatter msicdiv period if sicdiv==4 & dupsicdiv<2, `sicdiv2') ///
	(scatter msicdiv period if sicdiv==5 & dupsicdiv<2, `sicdiv' mlabposition(1)) ///
	(scatter msicdiv period if sicdiv==6 & dupsicdiv<2, `sicdiv') ///
	(scatter msicdiv period if sicdiv==9 & dupsicdiv<2, `sicdiv2') ///
	, aspect(`aspect') legend(off) graphregion(color(white)) ///
	ylabel(, nogrid) plotregion(color(white)) ///
	xlabel(1 2 3, valuelabel) xscale(range(`range')) ytitle("")  xtitle("") name(sicdiv, replace)

	twoway ///
	(scatter munion period if union==0 & dupunion<2, `union') ///
	(scatter munion period if union==1 & dupunion<2, `union2') ///
	(scatter munskill period if unskill==0 & dupunskill<2, `unskill') ///
	(scatter munskill period if unskill==1 & dupunskill<2, `unskill2') ///
	, aspect(`aspect') legend(off) graphregion(color(white)) ///
	ylabel(, nogrid) plotregion(color(white)) ///
	xlabel(1 2 3, valuelabel) xscale(range(`range')) ytitle("Share of Flexible Pay Jobs")  xtitle("") name(union, replace)

	twoway ///
	(scatter mbigregionn period if bigregionn==1 & dupbigregionn<2, `bigregionn') ///
	(scatter mbigregionn period if bigregionn==2 & dupbigregionn<2, `bigregionn2') ///
	(scatter mbigregionn period if bigregionn==3 & dupbigregionn<2, `bigregionn') ///
	(scatter mbigregionn period if bigregionn==4 & dupbigregionn<2, `bigregionn2') ///
	, aspect(`aspect') legend(off) graphregion(color(white)) ///
	ylabel(, nogrid) plotregion(color(white)) ///
	xlabel(1 2 3, valuelabel) xscale(range(`range')) ytitle("") xtitle("") name(bigregionn, replace)

	twoway ///
	(scatter msize period if size==1 & dupsize<2, `size') ///
	(scatter msize period if size==2 & dupsize<2, `size2') ///
	(scatter mofficelevel period if officelevel==0 & dupofficelevel<2, `officelevel') ///
	(scatter mofficelevel period if officelevel==1 & dupofficelevel<2, `officelevel2' mlabposition(2)) ///
	, aspect(`aspect') legend(off) graphregion(color(white)) ///
	ylabel(, nogrid) plotregion(color(white)) ///
	xlabel(1 2 3, valuelabel) xscale(range(`range')) ytitle("") xtitle("") name(size, replace)

	graph combine ///
	union ///
	bigregionn ///
	size ///
	sicdiv ///
	, ycommon col(2) ///
	graphregion( color(white))
	graph export results/adoptiontrends.pdf, replace
}

*-------------------------------------------------------------------------------
* SECTION 3. Comparison to other wage data
*-------------------------------------------------------------------------------
if $full_run | $sec3 {
	use created/fullworking.dta, clear 
	reg lnhourlyc i.year [aw = $weight]
	est store dod
	scalar def dodcons=_b[_cons]

	// import other wage series data
	clear
	import delimited using created/stagnation_replic.csv, varnames(1)

	cpigen
	replace cpiu=1.333270186093963 if year==2012
	replace cpiu=1.350378821468469 if year==2013
	replace cpiu=1.3747154 if year==2014
	replace cpiu=1.3763415 if year==2015
	replace cpiu=1.3937282 if year==2016
	replace cpiu=1.4210221 if year==2017
	replace cpiu=1.458161229 if year==2018

	// Real hourly wages
	gen ces=ceshourlyprod/cpiu
	replace ces=ln(ces)
	gen dina=ln(dinab50r2014earn)

	keep if year>1963 & year<1999

	foreach var in ces dina eci {
	reg `var' i.year if year<2007
	est store `var'
	scalar def `var'cons=_b[_cons]
	}

	local note="Note: CES is real hourly production worker wages from BLS's Current Employment Survey.  ECI is Employer Cost Index for blue-collar workers, which covers base pay, bonuses and benefits including health, retirement and leave. DINA is Distributional National Accounts average labor income for the bottom 50 percent of workers.  All series are placed on separate y-axes to reveal similarity in change over time.  The axis shown is for CES series."
	wordwrap "`note'", l(95)
	local noteshort=r(text)
	di "`noteshort'"

	local years=`"_cons=" " 1960.year*=" " 1961.year*=" "  1962.year*=" "  1963.year*=" "  1964.year*=" "  1965.year*=1965  1966.year*=" "  1967.year*=" "  1968.year*=" "  1969.year*=" "  1970.year*=1970  1971.year*=" "  1972.year*=" "  1973.year*=" "  1974.year*=" "  1975.year*=1975  1976.year*=" "  1977.year*=" "  1978.year*=" "  1979.year*=" "  1980.year*=1980  1981.year*=" "  1982.year*=" "  1983.year*=" "  1984.year*=" "  1985.year*=1985  1986.year*=" "  1987.year*=" "  1988.year*=" "  1989.year*=" "  1990.year*=1990  1991.year*=" "  1992.year*=" "  1993.year*=" "  1994.year*=" "  1995.year*=1995  1996.year*=" "  1997.year*=" "  1998.year*=" "  1999.year*=" "  2000.year*=2000"'

	coefplot ///
	(ces, transform(* =cescons+@) noci lcolor(black) lwidth(medthick) lpattern(solid) msymbol(none) yaxis(1)) ///
	(eci, transform(* =ecicons+@) noci lcolor(gs6) lwidth(medthick) lpattern(solid) msymbol(none) yaxis(2)) ///
	(dina, transform(* =dinacons+@) noci lcolor(gs12) lwidth(medthick) lpattern(solid) msymbol(none) yaxis(4)) ///
	(dod, transform(* =dodcons+@) noci lcolor(black) lwidth(thick) lpattern(dash) msymbol(none) yaxis(3)) ///
	, drop(_cons) vertical nooffset graphregion(color(white)) plotregion(color(white)) ///
	yscale(lstyle(none) axis(2)) yscale(lstyle(none) axis(3)) yscale(lstyle(none) axis(4)) ///
	ytitle("log(Real Wages)", axis(1)) ytitle("", axis(2)) ytitle("", axis(3)) ytitle("", axis(4)) ///
	ylabel(, nogrid axis(1)) ylabel(none, axis(2)) ylabel(none, axis(3)) ylabel(none, axis(4)) ///
	legend(col(1) order(1 2 3 4) position(7) ring(0) ///
	label(1 "CES (production workers)") ///
	label(2 "ECI (blue-collar)") ///
	label(3 "DINA (b50)")  ///
	label(4 "WFAS") ///
	size(small) region(lcolor(white))) ///
	recast(connected) ///
	coeflabels(`years')
	graph export results/otherseries1.pdf, replace
}

*-------------------------------------------------------------------------------
* SECTION 4. Decomposing wage stagnation trend
*-------------------------------------------------------------------------------
if $full_run | $sec4 {
	use created/fullworking.dta, clear 
	gen skill="skilled" if unskill==0
	replace skill="unskilled" if unskill==1

	foreach skill in skilled unskilled {
	preserve
	keep if skill=="`skill'"

	// baseline R2(1)
	gen meritcf=merit
	reghdfe lnhourlyc meritcf i.year [aw = $weight], noabsorb resid
	local b1: di %6.2f _b[meritcf]
	di `b1'
	replace meritcf=0 if meritcf==1
	predict lnhourlyc_xb1, xb
	drop meritcf
	
	// + controls 
	gen meritcf=merit
	reghdfe lnhourlyc meritcf i.year ///
	$controls /// 
	[aw = $weight] ///
	, noabsorb resid
	local b2: di %6.2f _b[meritcf]
	di `b2'
	replace meritcf=0 if meritcf==1
	predict lnhourlyc_xb2, xb
	drop meritcf
	
	// + labor market FEs R2(2)
	gen meritcf=merit
	reghdfe lnhourlyc meritcf ///
	$controls ///
	[aw = $weight] ///
	, absorb(lmfe=i.year#i.wac#i.sicdiv#i.jobn) resid keepsingletons
	local b3: di %6.2f _b[meritcf]
	di `b3'
	replace meritcf=0 if meritcf==1
	predict lnhourlyc_xb3, xb
	replace lnhourlyc_xb3=lnhourlyc_xb3+lmfe
	drop meritcf lmfe

	// Job fixed effect
	gen meritcf=merit
	reghdfe lnhourlyc meritcf ///
	$controls ///
	[aw = $weight] ///
	, absorb(jobfe=i.estid#i.jobn lmfe=i.year#i.wac#i.sicdiv#i.jobn, savefe) resid keepsingletons
	replace meritcf=0 if meritcf==1
	local b4: di %6.2f _b[meritcf]
	di `b4'
	predict lnhourlyc_xb4, xb
	replace lnhourlyc_xb4=lnhourlyc_xb4+jobfe+lmfe
	drop meritcf jobfe lmfe
	
	bys year: gen yeardup=_n
	forval x=1/4 {
		bys year: egen xb`x'yr=wtmean(lnhourlyc_xb`x'), weight($weight)
	}
	bys year: egen xb0yr=wtmean(lnhourlyc), weight($weight)
	
	forval x=0/4 {
		gen startt=xb`x'yr if year==1974
		egen start=max(startt)
		gen diffxb`x'yr=xb`x'yr-start
		drop start startt
	}	
	
	twoway ///
	(scatter diffxb1yr year if yeardup==1, lwidth(medthick) lcolor(gs13) connect(l) lpattern(dash)  msymbol(none) mcolor(black) msize(small)) ///
	(scatter diffxb2yr year if yeardup==1, lwidth(medthick) lcolor(gs10) connect(l) lpattern(dash) msymbol(none) mcolor(black) msize(small)) ///
	(scatter diffxb3yr year if yeardup==1, lwidth(medthick) lcolor(gs7) connect(l) lpattern(dash) msymbol(none) mcolor(black) msize(small)) ///
	(scatter diffxb4yr year if yeardup==1, lwidth(medthick) lcolor(gs3) connect(l) lpattern(dash) msymbol(none) mcolor(black) msize(small)) ///
	(scatter diffxb0yr year if yeardup==1, lwidth(medthick) lcolor(black) connect(l)  msymbol(none)) ///
	, graphregion(color(white)) ///
	ylabel(, glcolor(gs14)) ///
	xtitle("") 	ytitle("log(Hourly Wage), base 1974", size(medium)) ///
	legend(label(1 "Baseline: {&beta}=`b1'") ///
	label(2 "Controls: {&beta}=`b2'") ///
	label(3 "Ind/Occ/City/Year: {&beta}=`b3'") ///
	label(4 "Job: {&beta}=`b4'") ///
	label(5 "Observed") ///
	col(1) position(2) ring(0) region(lcolor(white)) size(small) symxsize(6))
	graph export results/counterf`skill'.pdf, replace
	
	*for descriptives in text:
	sum diffxb0yr if year==1978
	local base1978=`r(mean)'
	di `base1978'
	sum diffxb0yr if year==1991
	local base1991=`r(mean)'
	local realdiff=`base1991'-`base1978'
	di `realdiff'
	
	foreach n in 1 4 {
		sum diffxb`n'yr if year==1991
		local xb`n'1991=`r(mean)'
		local xb`n'diff=`xb`n'1991'-`base1978'
		di `xb`n'diff'
		di "xb`n'"
		di (`realdiff'-`xb`n'diff')/`realdiff'	
	}

	restore
	}

}

*-------------------------------------------------------------------------------
* SECTION 5. Tight identification estimates
*-------------------------------------------------------------------------------
if $full_run | $sec5 {
	use created/fullworking.dta, clear 
	// Baseline, just year and headcount
	reg lnhourlyc merit i.year lnnumemp lnnemp lnN_in_occ lnminwage ///
	[aw = $weight] ///
	, vce(cluster estid)
	est store base0

	// + controls 
	reg lnhourlyc merit i.year ///
	$controls /// 
	[aw = $weight] ///
	, vce(cluster estid)
	est store base1
	
	// + labor market FEs
	reghdfe lnhourlyc merit ///
	$controls ///
	[aw = $weight] ///
	, absorb(i.year#i.wac#i.sicdiv#i.jobn) cluster(estid)
	est store withinlm

	// Job fixed effect
	reghdfe lnhourlyc merit ///
	$controls ///
	[aw = $weight] ///
	, absorb(i.estid#i.jobn i.year#i.wac#i.sicdiv#i.jobn) cluster(estid)
	est store withinjob

	// Within-firm
	reghdfe lnhourlyc merit ///
	$controls ///
	[aw = $weight] ///
	, absorb(i.estid#i.jobn i.firmid#i.jobn#i.year i.year#i.wac#i.sicdiv#i.jobn) cluster(estid)
	est store withinfirm

 	estadd local yearFEs "$\times$", replace: base0 base1
	estadd local controls "$\times$", replace: withinlm withinjob withinfirm
	estadd local lmfixed "$\times$", replace: withinlm withinjob withinfirm
	estadd local estfixed "$\times$", replace: withinjob withinfirm
	estadd local firmfixed "$\times$", replace: withinfirm
	estadd local controls "$\times$", replace: base1 withinlm withinjob withinfirm

	// For paper
	if $paper {
	local note="Note: Source is Wage Fixing Authority Survey. Outcome is logged hourly wages.  Sample size varies due to exclusion of singletons from fixed effects regressions. Standard errors (in parentheses) are robust and clustered at the establishment level."
	wordwrap "`note'", l(90)
	local noteshort=r(text)
	di "`noteshort'"

	esttab base0 base1 withinlm withinjob withinfirm using  results/meritfull.tex, replace /// // order(merit $controls) ///
	b(3) se(3) $starcode obslast label nogaps nobaselevels lines nomtitles nonotes ///
	nodepvars interaction(" * ") drop(*year) ///
	scalar("hello Fixed effects:" ///
	"yearFEs \hspace{.1cm} Year " ///
	"lmfixed \hspace{.1cm} Year X City X Ind. X Occup." ///
	"estfixed \hspace{.1cm} Occup. X Establishment" ///
	"firmfixed \hspace{.1cm} Year X Occup. X Firm")  // 
	}
	
	// For presentation
	if $presentation {
	local note="Note: Controls are log(workers at pay level), log(workers in estab), log(workers in job), minimum wage, collective bargaining at estab, share managerial, clerical, co-workers occupational level, union density in industry-area. Standard errors clustered at the establishment level."
	wordwrap "`note'", l(90)
	local noteshort=r(text)
	di "`noteshort'"

	esttab base0 base1 withinlm withinjob withinfirm using  results/meritfull_pres.tex, replace /// // order(merit $controls) ///
	b(3) se(3) $starcode obslast label nogaps nobaselevels lines nomtitles nonotes ///
	nodepvars interaction(" * ") drop(*year _cons lnnumemp lnN_in_occ lnnemp union office coworkjobq sicwacunion lnminwage) ///
	scalar("controls Controls" ///
	"hello Fixed effects:" ///
	"yearFEs \hspace{.1cm} Year " ///
	"lmfixed \hspace{.1cm} Year X City X Industry X Occupation" ///
	"estfixed \hspace{.1cm} Occupation X Establishment" ///
	"firmfixed \hspace{.1cm} Year X Occupation X Firm") ///
	addnote("`noteshort'")
	}
}
*-------------------------------------------------------------------------------
* SECTION 6. Inequality evidence
*-------------------------------------------------------------------------------
if $full_run | $sec6 {
		
	use created/fullworking.dta, clear  

	// Mean effect
	reghdfe lnhourlyc merit ///
	$controls ///
	[aw = $weight] ///
	, absorb(i.estid#i.jobn i.year#i.wac#i.sicdiv#i.jobn) cluster(estid)
	est store main

	// Formal within-firm differences
	replace lnmaxhourly=lnhourly if lnmaxhourly==.
	replace lnminhourly=lnhourly if lnminhourly==.
	foreach var in lnmaxhourly lnminhourly {
		gen merit`var'=merit
		reghdfe `var' i.merit`var' $controls ///
		[aw = $weight] if lnmaxhourly!=., absorb(i.jobn#i.estid i.year#i.wac#i.sicdiv#i.jobn) ///
		cluster(estid)
		est store `var'eff
	}
			
	// Real within-job differences
	drop maxreal minreal
	bys estid jobtitle year: egen maxreal=max(lnhourlyc)
	bys estid jobtitle year: egen minreal=min(lnhourlyc)
	
	gen winjoblevel=2 if lnhourlyc!=minreal & lnhourlyc!=maxreal
	replace winjoblevel=1 if lnhourlyc==minreal
	replace winjoblevel=3 if lnhourlyc==maxreal
	
	reghdfe lnhourlyc $controls i.winjoblevel i.merit#i.winjoblevel ///
	[aw = $weight], absorb(i.jobn#i.estid i.year#i.wac#i.sicdiv#i.jobn) ///
	cluster(estid)
	est store withinjob
	
	// Real between-job differences
	bys estid jobn year: egen jobmean=wtmean(lnhourlyc), weight($weight)
	bys estid year: egen maxjob=max(jobmean)
	bys estid year: egen minjob=min(jobmean)
	
	gen bwjoblevel=2 if lnhourlyc!=maxjob & lnhourlyc!=minjob
	replace bwjoblevel=1 if lnhourlyc==minjob
	replace bwjoblevel=3 if lnhourlyc==maxjob
	
	reghdfe lnhourlyc $controls i.bwjoblevel i.merit#i.bwjoblevel ///
	[aw = $weight], absorb(i.jobn#i.estid i.year#i.wac#i.sicdiv#i.jobn) ///
	cluster(estid)
	est store bwjob

	// Between-firm
	reghdfe lnhourlyc [aw = $weight] if merit==0, absorb(firmfe=i.estid occwacfe=i.year#i.wac#i.sicdiv#i.jobn)
	bys estid: egen mfirmfe=wtmean(firmfe), weight($weight)
	sum mfirmfe  [aw = $weight], detail
	gen festd=1 if mfirmfe>r(p50) & mfirmfe!=.
	replace festd=0 if mfirmfe<=r(p50) & mfirmfe!=.
	
	reghdfe lnhourlyc $controls i.festd i.merit#i.festd ///
	[aw = $weight], absorb(i.jobn#i.estid i.year#i.wac#i.sicdiv#i.jobn) ///
	cluster(estid)
	est store bwfirm
	

	local note="Note: Data from Wage Fixing Authority Survey.  Estimates are wage differences associated with switching to merit pay, controlling for controls, job by establishment fixed effects and year by city by industry and job fixed effects as in Model 3 in Table 2."
	wordwrap "`note'", l(90)
	local noteshort=r(text)
	di "`noteshort'"
	
	coefplot ///
	(lnminhourlyeff, keep(*1.merit*) mcolor(black) msize(medium) msymbol(circle_hollow) ciopts(lcolor(gs13))) ///
	(lnmaxhourlyeff, keep(*1.merit*) mcolor(black) msize(medium) msymbol(circle_hollow) ciopts(lcolor(gs13))) ///
	(withinjob, keep(*1.merit*) mcolor(black) msize(medium) msymbol(circle) ciopts(lcolor(gs13))) ///
	(bwjob, keep(*1.merit*) mcolor(black) msize(medium) msymbol(circle) ciopts(lcolor(gs13))) ///
	(bwfirm, keep(*1.merit*) mcolor(black) msize(medium) msymbol(circle) ciopts(lcolor(gs13))) ///
	, vertical  yline(0, lpattern(dash) lcolor(black)) aseq nooffset baselevels ///
	graphregion(color(white)) ylabel(, nogrid) ///
	ytitle("log(Hourly Wage) Effect", size(medium)) ///
	legend(off) ///
	coeflabels( ///
	1.meritlnminhourly="Low" ///
	1.meritlnmaxhourly="Top" ///
	1.merit#1.winjoblevel="Low" ///
	1.merit#2.winjoblevel="Mid" ///
	1.merit#3.winjoblevel="Top" ///
	1.merit#1.bwjoblevel="Low" ///
	1.merit#2.bwjoblevel="Mid" ///
	1.merit#3.bwjoblevel="Top" ///
	1.merit#0.festd*="Low" ///
	1.merit#1.festd*="High") ///
	group(1.meritlnminhourly 1.meritlnmaxhourly = `""Formal range" "within-job"' ///
	1.merit#1.winjoblevel 1.merit#2.winjoblevel 1.merit#3.winjoblevel = `""Real range" "within-job"' ///
	1.merit#1.bwjoblevel 1.merit#2.bwjoblevel 1.merit#3.bwjoblevel = `""Within-estab," "across jobs"' ///
	1.merit#0.festd* 1.merit#1.festd* = "Firm FE")
	graph export results/ineqeffinvw.pdf, replace

}



*-------------------------------------------------------------------------------
* SECTION 7. Firm size effects
*-------------------------------------------------------------------------------
	
if $full_run | $sec7 {
	local lab_market_FE i.year#i.sicdiv#i.jobn#i.wac
	use using created/fullworking.dta, clear	
	gcollapse (mean) estsize=nemp, by(estid year)
	bys estid (year): gen shrunk=estsize<estsize[_n-1]
	bys estid (year): gen lfd=ln(estsize)-ln(estsize[_n-1])
	tempfile estsize 
	save `estsize', replace 
	
	use using created/fullworking.dta, clear
	gen tocount=1
	bys estid year: keep if _n==1
	gcollapse (sum) Nests=tocount, by(firmid year)
	tempfile Nests 
	save `Nests', replace 
	
	use using created/fullworking.dta, clear
	merge m:1 estid year using `estsize', nogen keep(master match)
	merge m:1 firmid year using `Nests', nogen keep(master match)
	
	gen ln_estsize = ln(estsize)
	gen meritXln_estsize = merit * ln_estsize 
	
	
	bys estid jobn year (lnhourlyc): gen top_rank = _n==_N if _N>1
	bys estid jobn year (lnhourlyc): gen lowest_rank = _n==1 if _N>1
	
	// Just year FEs
	reghdfe lnhourlyc ln_estsize ///
	[aw = $weight] ///
	, absorb(year) cluster(estid)
	est store reg0
	
	// Just year FEs
	reghdfe lnhourlyc merit meritXln_estsize ln_estsize ///
	[aw = $weight] ///
	, absorb(year) cluster(estid)
	est store reg0	
	
	// Job fixed effect
	reghdfe lnhourlyc merit meritXln_estsize ln_estsize ///
	[aw = $weight] ///
	, absorb(year i.estid#i.jobn) cluster(estid)
	est store reg1

	// + controls
	reghdfe lnhourlyc merit meritXln_estsize ln_estsize ///
	$controls_no_size ///
	[aw = $weight] ///
	, absorb(year i.estid#i.jobn) cluster(estid)
	est store reg2
	
	// + labor market FEs
	reghdfe lnhourlyc merit meritXln_estsize ln_estsize ///
	$controls_no_size ///
	[aw = $weight] ///
	, absorb(i.estid#i.jobn `lab_market_FE') cluster(estid)
	est store reg3

	// Within-firm
	reghdfe lnhourlyc merit meritXln_estsize ln_estsize ///
	$controls_no_size ///
	[aw = $weight] ///
	, absorb(i.estid#i.jobn i.firmid#i.jobn#i.year `lab_market_FE') cluster(estid)
	est store reg4

 	estadd local yearFEs "$\times$",   replace: reg0 reg1 reg2
	estadd local controls "$\times$" , replace: reg0      reg2 reg3 reg4
	estadd local lmfixed "$\times$",   replace:                reg3 reg4
	estadd local jobFE "$\times$",     replace:      reg1 reg2 reg3 reg4
	estadd local firmfixed "$\times$", replace:                     reg4
	
	label var ln_estsize "Log(Estab. size)"
	label var meritXln_estsize "Non-Standardized * Log(Estab. size)"
	// For paper
	esttab reg0 reg1 reg2 reg3 reg4   using  "results/meritXestsizes.tex", replace /// 
	b(3) se(3) $starcode obslast label nogaps nobaselevels lines nomtitles nonotes ///
	nodepvars keep(merit ln_estsize meritXln_estsize)  ///
	scalar("hello Other regressors:" ///
	"controls \hspace{.1cm} Controls" ///
	"yearFEs \hspace{.1cm} Year" ///
	"lmfixed \hspace{.1cm} Year X City X Ind. X Occup." ///
	"jobFE \hspace{.1cm} Occup. X Establishment" ///
	"firmfixed \hspace{.1cm} Year X Occup. X Firm") 
}

*-------------------------------------------------------------------------------
* SECTION 8. Change survey
*-------------------------------------------------------------------------------
	
if $full_run | $sec8 {
	// Open main data from build.do
	use created/fullworking.dta, clear
	
	// Recode reasoncode
	gen reasoncoden=1 if reasoncode=="G"
	replace reasoncoden=2 if reasoncode=="C"
	replace reasoncoden=3 if reasoncode=="W"
	replace reasoncoden=4 if (reasoncode==" " | reasoncode=="") & change
	replace reasoncoden=5 if (reasoncode=="B" | reasoncode=="I") & change
	replace reasoncoden=6 if reasoncode=="D" | reasoncode=="P"
	label define reasoncoden 1 "General change" 2 "COLA" 3 "Only individual" 4 "No change" 5 "Bonus, incentive" 6 "Other"
	label values reasoncoden reasoncoden
		
	keep if change
	bys merit: egen totweight=total($weight)
	bys merit reasoncoden: egen reason_totweight=total($weight)
	gen reason_meritt=reason_totweight/totweight if merit
	bys reasoncoden: egen reason_merit=mean(reason_merit)
	gen reason_nonmeritt=reason_totweight/totweight if !merit
	bys reasoncoden: egen reason_nonmerit=mean(reason_nonmeritt)

	estpost tabstat reason_nonmerit reason_merit, by(reasoncoden) nototal
	est store reason
	
	esttab reason using results/reasoncode.tex ///
	, cells("reason_nonmerit(fmt(2) label(\shortstack{Standardized pay rate jobs})) reason_merit(fmt(2) label(\shortstack{Flexible pay jobs})) ") ///
	nolabel nomtitles noobs label replace nogaps lines compress nodepvars nonumbers 


	if $presentation {
		replace reasoncoden=6 if reasoncoden==5
		bys reasoncoden merit: egen t=total($weight)
		gen sh=t/totweight
		mean sh, over(reasoncoden merit)
		est store reason
		
		coefplot ///
		(reason, keep(*0.merit*) color(red%40)) ///
		(reason, keep(*1.merit*) color(blue%40)) ///
		, graphregion(color(white)) grid(none) ///
		nooffset ///
		xscale(range(0 .7)) ///
		recast(bar) recast(bar) barwidth(0.7) ///
		order(*1.r* *2.r* *3.r* *4.r* *5.r* *6.r*) ///
		group(*1.r*="General" *2.r*="COLA" *3.r*="Only individual" *4.r*="No change" *5.r*="Bonus, incentive" *6.r*="Other", angle(horizontal)) ///
		legend(col(1) label(2 "Standardized pay rate jobs")  label(4 "Flexible pay jobs") symxsize(4) region(color(white)) ring(0) position(5)) ///
		coeflabel(*1.r*=" " *2.r*=" " *3.r*=" " *4.r*=" " *5.r*=" " *6.r*=" ") ///
		format(%9.2f) ///
		addplot(scatter  @at @b if @plot==1, ms(i) mlabel(@b) mlabpos(3) mlabcolor(red) ///
	   || scatter @at @b  if @plot==2, ms(i) mlabel(@b) mlabpos(3) mlabcolor(blue) )
	   graph export results/reasonchange.pdf, replace
	   
	   drop t sh
    }
	gen none=(reasoncoden==4)
	replace none=. if !change
	gen individ=(reasoncoden==3 | reasoncoden==5)
	replace individ=. if !change
	gen none_individ=(reasoncoden==3 | reasoncoden==4 | reasoncoden==5)
	replace none_individ=. if !change
	
	// Recode actioncode
	tab actioncode if change
	gen actioncoden=1 if actioncode=="A"
	replace actioncoden=2 if actioncode=="Z"
	replace actioncoden=3 if actioncode=="N"
	replace actioncoden=4 if actioncode=="R" | actioncode=="T" | actioncode=="S" 
	label define actioncoden 1 "Across board" 2 "No Changes" 3 "Different" 4 "Other"
	label values actioncoden actioncoden

	tab actioncoden merit if change, row
	
}		

if $full_run | $sec9 {
	use year cpiu using created/fullworking.dta, clear	
	gcollapse (firstnm) cpiu, by(year)
	sort year
	gen cpiu_pct_change = 100*(cpiu - cpiu[_n-1]) / cpiu[_n-1]
	tempfile d_inflation
	save `d_inflation', replace 
	
	use using created/fullworking.dta, clear
	gen any_cola = cola!=0
	merge m:1 year using `d_inflation', nogen keep(master match)
	bys estid jobn year month: gegen any_merit = max(merit)
	* Key collapse: 
	gcollapse (firstnm) cpiu_pct_change (mean) any_cola [aw=invrowwt], by(any_merit year)       
	sort year 
	twoway (connected any_cola year            if year>1974 & any_merit==1, lc(maroon) mfc(maroon) mlc(maroon))  /// 
		   (connected any_cola year            if year>1974 & any_merit==0, lc(navy) mfc(navy) mlc(navy))        /// 
	       (connected cpiu_pct_change year if year>1974, yaxis(2) lc(gray%20) mfc(gray%20) mlc(gray%20)), /// 
	  graphregion(color(white)) ytitle(COLA share) ytitle("Inflation (%)", axis(2)) ///
	  legend(order(1 "COLA Share, Non-standardized" 2 "COLA Share, Standardized" 3 "Inflation (right axis)") region(lwidth(none)) row(3)) xtitle(Year)
	graph export results/cola_vs_merit.pdf, replace	
}

if $full_run | $sec10 {
	global outcome switch_to_merit
	global indvars ln_job_growth

	local lab_market_FE i.year#i.sicdiv#i.jobn#i.wac
	use using created/fullworking.dta, clear	
	gcollapse (firstnm) firmid coworkjobq office sicwacunion minwage (max) any_merit=merit (mean) nemp (sum) numemp, by(estid jobn year month) // collapse to job x est x survey level 
	gcollapse (firstnm) firmid coworkjobq office sicwacunion minwage (max) any_merit       (mean) nemp numemp , by(estid year jobn)  // collapse to job x est x year level 
	
	bys estid jobn (year): gen job_growth = (numemp-numemp[_n-1]) / numemp[_n-1]
	bys estid jobn (year): gen ln_job_growth = ln(numemp) - ln(numemp[_n-1])
	bys estid jobn (year): gen switch_to_merit = any_merit==1 & any_merit[_n-1]==0 
	
	gen switchyear = year if switch_to_merit
	bys estid jobn: gegen min_switchyear = min(switchyear)
	sum switch_to_merit if year<=min_switchyear
	
	gen ln_nemp = ln(nemp)
	sum switch_to_merit
	tempfile growth 
	save `growth', replace 
	
	use using created/fullworking.dta, clear
	merge m:1 estid year jobn using `growth', nogen keep(master match)
	
	sum switch_to_merit [aw=$weight]
	
	// Baseline, just year and headcount
	reg $outcome $indvars i.year  ///
	[aw = $weight] ///
	, vce(cluster estid)
	est store reg1
	
	// + job FEs
	reghdfe $outcome $indvars i.year ///
	[aw = $weight] ///
	, vce(cluster estid) absorb(i.estid#i.jobn)
	est store reg2
		
	// + controls
	reghdfe $outcome $indvars i.year ///
	$controls_no_size ln_nemp /// 
	[aw = $weight] ///
	, vce(cluster estid) absorb(i.estid#i.jobn)
	est store reg2a
	
	// + labor market FEs
	reghdfe $outcome $indvars ///
	$controls_no_size ln_nemp ///
	[aw = $weight] ///
	, absorb(i.estid#i.jobn `lab_market_FE') cluster(estid)
	est store reg3

	// Within-firm
	reghdfe $outcome $indvars ///
	$controls_no_size ln_nemp ///
	[aw = $weight] ///
	, absorb(i.estid#i.jobn i.firmid#i.jobn#i.year `lab_market_FE') cluster(estid)
	est store reg4
	
 	estadd local yearFEs "$\times$", replace:  reg1 reg2 reg2a
	estadd local controls "$\times$", replace:           reg2a reg3 reg4
	estadd local lmfixed "$\times$", replace:                  reg3 reg4
	estadd local estfixed "$\times$", replace:      reg2 reg2a reg3 reg4
	estadd local firmfixed "$\times$", replace:                     reg4

	local note="Note: Source is Wage Fixing Authority Survey. Outcome is logged hourly wages. Sample size varies due to exclusion of singletons from fixed effects regressions. Standard errors are robust and clustered at the establishment level."
	wordwrap "`note'", l(90)
	local noteshort=r(text)
	di "`noteshort'"

	label var ln_job_growth "Log(Job Growth)"
	label var ln_nemp "log(Workers in Est.)"
	// For paper ////////////////////////////////////////////////////////////
	esttab reg1 reg2 reg2a reg3 reg4  using  results/meritXoccgrowth.tex, replace /// // order(merit $controls) ///
	b(3) se(3) nostar obslast label nogaps nobaselevels lines nomtitles nonotes ///
	nodepvars interaction(" * ") drop(*year) ///
	scalar("hello Fixed effects:" ///
	"yearFEs \hspace{.1cm} Year " ///
	"lmfixed \hspace{.1cm} Year X City X Ind. X Occup." ///
	"estfixed \hspace{.1cm} Occup. X Establishment" ///
	"firmfixed \hspace{.1cm} Year X Occup. X Firm") 
}

if $full_run | $sec11 {
	use created/fullworking, clear  
	bys estid jobn year month: gen num_wage_brackets = _N
	bys estid jobn year month: gegen total_workers=sum(numemp)
	bys estid jobn year month: keep if _n==1 
		
	preserve
	gcollapse (mean) num_wage_brackets, by(merit total_workers )
	drop if total_workers > 20 
	twoway (scatter num_wage_brackets total_workers if merit==1, color(black)) (scatter num_wage_brackets total_workers if merit==0,  color(gray%50)) , ///
	 ytitle(Number of wage levels) xtitle(Total workers in job) legend(order(1 "Non-standardized" 2 "Standardized")) graphregion(fcolor(white)) plotregion(fcolor(white)) xlabel(1 5 10 15 20)
	graph export results/num_brackets.pdf, replace
	restore 
	
	gcollapse (mean) num_wage_brackets, by(merit total_workers union)
	drop if total_workers > 20 
	twoway (scatter num_wage_brackets total_workers if merit==1 & union==0, color(red%50)) /// 
	       (scatter num_wage_brackets total_workers if merit==1 & union==1, color(blue%50)) /// 
	       (scatter num_wage_brackets total_workers if merit==0 & union==0, color(green%50)) /// 
	       (scatter num_wage_brackets total_workers if merit==0 & union==1, color(orange%50)) , ///
	 ytitle(Number of wage levels) xtitle(Total workers in occupation) legend(order(1 "Merit, Non-Union" 2 "Merit, Union" 3 "Non-Merit, Non-Union" 4 "Non-Merit, Union")) graphregion(fcolor(white)) plotregion(fcolor(white)) xlabel(1 5 10 15 20)
	graph export results/num_brackets_unions_too.pdf, replace
}

if $full_run | $sec12 {
    local unit wac  sicshort
	use created/fullworking.dta, clear	
	replace year = 1974 if inrange(year,1974        ,1974+2) 
	replace year = 1989 if inrange(year,1991-2,1991)
	keep if year==1974 | year==1989
	bys year `unit' estid: gen unique_est = _n==1
	
	preserve 
	gcollapse (sum) unique_est numemp                                 , by(year `unit')
	gcollapse (min) unique_est numemp                                 , by(`unit')
	drop if unique_est<20
	tempfile un 
	save `un', replace 
	restore 
	
	gcollapse   (sum) unique_est nemp                      (mean) lnhourlyc merit union [aw=invrowwt], by(year `unit')
	merge m:1 `unit' using `un', nogen keep(master match)
	
	gen emp_per_firm = nemp / unique_est
	
	bys `unit' (year): gen d_merit = merit - merit[_n-1]
	bys `unit' (year): gen d_union = union - union[_n-1]
	bys `unit' (year): gen ln_d_emp = ln(nemp) - ln(nemp[_n-1])
	bys `unit' (year): gen ln_d_emp_per_firm = ln(emp_per_firm) - ln(emp_per_firm[_n-1])
	bys `unit' (year): gen d_lnhourlyc = lnhourlyc - lnhourlyc[_n-1]
	 
	twoway (scatter d_merit d_union, msize(small) mfc(none) mlc(blue%50) mlw(vthin)) /// 
	       (lfit    d_merit d_union),  ///
		   graphregion(color(white)) legend(off) /// 
		   xtitle("Change in union share, p.p.") ytitle("Change in flexible pay")
	
	regress d_merit d_union
	display "-20 pp change in union assocaited with : " round(100*-.20*_b[d_union]) " percentage point change in merit" 
	binscatter d_merit d_union,  xtitle("Change in union share") ytitle("Change in flexible pay") mcolor(gray) lcolor(black) 
	graph export results/wac_union_share_vs_flex.pdf, replace 

	use created/fullworking.dta, clear	
	gcollapse (mean) union [aw=invrowwt], by(estid jobn)
	sum union if union!=0 & union!=1
	gen     group=1 if union==0
	replace group=2 if union!=0 & union!=1
	replace group=3 if union==1
	tab group
	keep estid jobn group 
	tempfile ugroups
	save    `ugroups', replace 
	
	use created/fullworking.dta, clear
	merge m:1 estid jobn using `ugroups', nogen 
	
	gen sometimes = group==2
	label var sometimes "Sometimes union"
	gen meritXsometimes = merit*(group==2) 
	label var meritXsometimes "Non-Standard $\times$ Sometimes union"

	gen always = group==3
	label var always "Always union"
	gen meritXalways  = merit*(group==3)
	label var meritXalways "Non-Standard $\times$ Always union"	
	
	// Baseline, just year and headcount
	reg lnhourlyc merit meritXsometimes meritXalways sometimes always i.year lnnumemp lnnemp lnN_in_occ lnminwage ///
	[aw = $weight] ///
	, vce(cluster estid)
	est store base0
	lincom merit+meritXsometimes
	local com_beta : di %4.3f r(estimate)
	local com_se :   di %4.3f r(se)

	estadd local sometimes_beta = `com_beta'
	estadd local sometimes_se   = "(`com_se')"

	lincom merit+meritXalways
	local com_beta : di %4.3f r(estimate)
	local com_se :   di %4.3f r(se)

	estadd local always_beta = `com_beta'
	estadd local always_se   = "(`com_se')"

	// + controls 
	reg lnhourlyc merit meritXsometimes meritXalways sometimes always   i.year ///
	$controls /// 
	[aw = $weight] ///
	, vce(cluster estid)
	est store base1
	lincom merit+meritXsometimes
	local com_beta : di %4.3f r(estimate)
	local com_se :   di %4.3f r(se)

	estadd local sometimes_beta = `com_beta'
	estadd local sometimes_se   = "(`com_se')"

	lincom merit+meritXalways
	local com_beta : di %4.3f r(estimate)
	local com_se :   di %4.3f r(se)

	estadd local always_beta = `com_beta'
	estadd local always_se   = "(`com_se')"

	// + labor market FEs
	reghdfe lnhourlyc merit meritXsometimes meritXalways sometimes always ///
	$controls ///
	[aw = $weight] ///
	, absorb(i.year#i.wac#i.sicdiv#i.jobn) cluster(estid)
	est store withinlm
	lincom merit+meritXsometimes
	local com_beta : di %4.3f r(estimate)
	local com_se :   di %4.3f r(se)

	estadd local sometimes_beta = `com_beta'
	estadd local sometimes_se   = "(`com_se')"

	lincom merit+meritXalways
	local com_beta : di %4.3f r(estimate)
	local com_se :   di %4.3f r(se)

	estadd local always_beta = `com_beta'
	estadd local always_se   = "(`com_se')"
	
	// Job fixed effect
	reghdfe lnhourlyc merit meritXsometimes meritXalways  ///
	$controls ///
	[aw = $weight] ///
	, absorb(i.estid#i.jobn i.year#i.wac#i.sicdiv#i.jobn) cluster(estid)
	est store withinjob
	lincom merit+meritXsometimes
	local com_beta : di %4.3f r(estimate)
	local com_se :   di %4.3f r(se)

	estadd local sometimes_beta = `com_beta'
	estadd local sometimes_se   = "(`com_se')"

	lincom merit+meritXalways
	local com_beta : di %4.3f r(estimate)
	local com_se :   di %4.3f r(se)

	estadd local always_beta = `com_beta'
	estadd local always_se   = "(`com_se')"

	// Within-firm
	reghdfe lnhourlyc merit meritXsometimes meritXalways  ///
	$controls ///
	[aw = $weight] ///
	, absorb(i.estid#i.jobn i.firmid#i.jobn#i.year i.year#i.wac#i.sicdiv#i.jobn) cluster(estid)
	est store withinfirm
	lincom merit+meritXsometimes
	local com_beta : di %4.3f r(estimate)
	local com_se :   di %4.3f r(se)

	estadd local sometimes_beta = `com_beta'
	estadd local sometimes_se   = "(`com_se')"

	lincom merit+meritXalways
	local com_beta : di %4.3f r(estimate)
	local com_se :   di %4.3f r(se)

	estadd local always_beta = `com_beta'
	estadd local always_se   = "(`com_se')"

 	estadd local yearFEs "$\times$", replace: base0 base1
	estadd local controls "$\times$", replace: withinlm withinjob withinfirm
	estadd local lmfixed "$\times$", replace: withinlm withinjob withinfirm
	estadd local estfixed "$\times$", replace: withinjob withinfirm
	estadd local firmfixed "$\times$", replace: withinfirm
	estadd local controls "$\times$", replace: base1 withinlm withinjob withinfirm

	// For paper
	esttab base0 base1 withinlm withinjob withinfirm using  results/union_het.tex, replace /// // order(merit $controls) ///
	b(3) se(3) $starcode obslast label nogaps nobaselevels lines nomtitles nonotes nocons ///
	nodepvars drop(*year $controls _cons) ///
	 stats(LINEBREAK1 yearFEs lmfixed estfixed firmfixed N LINEBREAK2 sometimes_beta sometimes_se always_beta always_se, label("Fixed effects" "Year" "Year X City X Ind. X Occup." "Occup. X Establishment" "Year X Occup. X Firm" "N" "\hline Linear combinations" "Non-Standardized + Non-Standardized $*$ Sometimes" "$$" "Non-Standardized + Non-Standardized $*$ Always" "$$") fmt(0 0 0 0 0 %9.0fc 0 0 0 0 0))
}

display "Started at `start_time' Ended at: ${S_TIME}"

log close 
local mytime = subinstr("$S_TIME",":","_",.)
