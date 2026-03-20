*-------------------------------------------------------------------------------------------------------------------------------
* SECTION 1. cleaning merged data & deflating/logging wages 
*-------------------------------------------------------------------------------------------------------------------------------

// load in fullcpsmerged dataset
use created/cps/fullcpsmerged.dta, clear
sum 
keep if _merge == 3 //190,086 observations deleted

gen lnincwage = log(hourwagetc) 
gen lnhourly = log(hourly)

cpigen //Variables "month" and "quarter" missing, annual CPI will be generated
gen rincwage = hourwagetc/cpiu 
gen rhourly = hourly/cpiu 

// logging rhourly & rincwage
gen lnrincwage = log(rincwage)
gen lnrhourly = log(rhourly)

drop _merge
merge m:1 jobn using created/jobtitle.dta //24,773 matched (3)
keep if _merge == 3 //296 obs deleted

sort year
sort jobn region year sic3d

gen period=year>=1983

gen lnrhourlyd=round(lnrhourly*50)/50
bys lnrhourlyd period: egen lnrincwaged=wtmean(lnrincwage), weight(totalnumempdod)
bys lnrhourlyd period: egen totalnumempdodt=total(totalnumempdod)
bys lnrhourlyd period: gen dup=cond(_N==1,0,_n)

// Binned scatterplot
foreach dir in up down {
	*split by year?
	local splitdown year<1983
	local splitup year>=1983
	local size 100
	*take out outliers and small samples?
	local cut 0
	*weight?
	local weight totalnumempdodt
	*print correlation on chart...
	corr lnrincwage lnrhourly [aweight=`weight'] if  `split`dir''
	local rho: di %6.2f r(rho)
	*at point minimums
	sum lnrincwaged [aweight=`weight'] if totalnumempdodt>`size'
	local ymin: di r(min) 
	sum lnrhourlyd [aweight=`weight'] if  totalnumempdodt>`size'
	local xmax: di r(max) 
	*make chart
	twoway ///
	(scatter lnrincwaged lnrhourlyd [aweight=`weight']  if `split`dir'' & totalnumempdodt>`size' & dup<2 ///
	, mcolor(gs5) msymbol(circle_hollow) msize(tiny)) ///
	, xtitle("log(Real Wages in WFAS)") ytitle("log(Real Earnings in CPS)") ///
	ylabel(, nogrid) ///
	xlabel(, nogrid) ///
	plotregion(color(white)) ///
	graphregion(color(white)) ///
	aspect(1.1) ///
	legend(off) ///
	text(2.1 3.4 "{&rho} =`rho'", placement(ne)) ///
	text(2.1 3.4 "`split`dir''", placement(se)) name(cpsdodscatter`dir', replace)
}

graph combine cpsdodscatterdown cpsdodscatterup ///
, plotregion(color(white)) graphregion(color(white)) ycommon xcommon ///
graphregion(margin(zero)) ysize(3) iscale(1)
graph export results/cpsdodscattercomb.pdf, replace

