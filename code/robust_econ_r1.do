/*******************************************************************************
	
		robust_econ.do
		9.4.2020
		Main analysis for:
		"Wage Stagnation and Merit Pay"
		Nathan Wilmers and Maxim Massenkoff
	
	Packages needed:
	cpigen
	egenmore
	_gwtmean
	labutil	
		
*******************************************************************************/

log using code/robust_econ_r1.log, replace 

global sec1 1  // 	SECTION 1. Weights assessment
global sec2 0  // 	SECTION 2. Merit alternatives

*-------------------------------------------------------------------------------
* SECTION 1. Weights assessment
*-------------------------------------------------------------------------------
if $full_run | $sec1 {	

	use created/fullworking.dta, clear
	
	gen altnumemp=numemp
	replace altnumemp=. if numemp>31 & numemp!=.

	sum numemp, detail

	tabstat numemp if numemp>=r(p95), stat(sum)

	tabstat numemp, stat(sum)

	di 4149603/7627103

	tabstat invrowwt, stat(sum)

	foreach altweight in invrowwt numemp weight cpsweight altnumemp {

		// Within-labor market
		reghdfe lnhourlyc merit ///
		$controls ///
		[aw = `altweight'] ///
		, absorb(i.year#i.wac#i.sicdiv#i.jobn) cluster(estid)
		est store withinlm`altweight'

		// Job fixed effect
		reghdfe lnhourlyc merit ///
		$controls ///
		[aw = `altweight'] ///
		, absorb(i.estid#i.jobn i.year#i.wac#i.sicdiv#i.jobn) cluster(estid)
		est store withinjob`altweight'

		estadd local controls "$\times$", replace: withinlm`altweight' withinjob`altweight'
		estadd local lmfixed "$\times$", replace: withinlm`altweight' withinjob`altweight' 
		estadd local estfixed "$\times$", replace: withinjob`altweight'
	}

	label var seniority "No Merit Range"
	label var merit "Non-standardized Pay"
	label var spread "Pay Scale Range"
	label var union "Collective Bargaining"
	label var lnnumemp "log(Workers in Job)"
	label var lnnemp "log(Workers in Est.)"
	label var coworkjobq "Co-Workers' Occupational Level"
	label var office "Share Managerial, Clerical in Est."
	label var sicwacunion "Union Density in Industry-Wage Area"
	label var wacskillgap "Wage Area Skilled/Unskilled Gap"
	label var wactradeable "Wage Area Tradeable Industry Share"
	label var wacoffice "Wage Area Managerial/Clerical Share"
	label var bonusd "Bonus"
	label var colad "COL Adjustment"
	label var piecerate "Piece Rate"

	local note=""
	wordwrap "`note'", l(90)
	local noteshort=r(text)
	di "`noteshort'"
	
	estadd local excl "$\times$", replace: withinlmaltnumemp withinjobaltnumemp

	// For paper
	esttab withinlminvrowwt withinjobinvrowwt  withinlmweight withinjobweight withinlmcpsweight withinjobcpsweight withinlmnumemp withinjobnumemp withinlmaltnumemp withinjobaltnumemp using results/meritfullwt.tex, replace ///
	b(3) se(3) $starcode obslast label nogaps nobaselevels lines nomtitles nonotes ///
	nodepvars interaction(" * ") keep(merit) ///
	mgroups("Inv. Row Wt." "Survey Wt." "CPS Wt." "N. Employees", pattern(1 0 1 0 1 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	scalar("controls Controls" ///
	"hello Fixed effects:" ///
	"lmfixed \hspace{.1cm} Year X City X" ///
	"estfpart \hspace{.3cm} Ind. X Occup." ///
	"estfixed \hspace{.1cm} Occup. X Estab." ///
	"excl Excl. largest 5\%" ///
	"blank \hspace{.2cm} of job brackets") 
}

*-------------------------------------------------------------------------------
* SECTION 2. Merit alternatives
*-------------------------------------------------------------------------------
if $full_run | $sec2 {	
	use created/fullworking.dta, clear 
	preserve 
	gen meritonly=rangereason2=="M"
	gen meritcomb=rangereason2=="M" | rangereason2=="C"
	gen meritcomboth=rangereason2=="M" | rangereason2=="C" | rangereason2=="X"

	foreach merit in meritonly meritcomb meritcomboth {
	// Within-labor market
	reghdfe lnhourlyc `merit' ///
	$controls ///
	[aw = $weight] ///
	, absorb(i.year#i.wac#i.sicdiv#i.jobn) cluster(estid)
	est store withinlm`merit'

	// Job fixed effect
	reghdfe lnhourlyc `merit' ///
	$controls ///
	[aw = $weight] ///
	, absorb(i.estid#i.jobn i.year#i.wac#i.sicdiv#i.jobn) cluster(estid)
	est store withinjob`merit'

	// Within-firm
	reghdfe lnhourlyc `merit' ///
	$controls ///
	[aw = $weight] ///
	, absorb(i.estid#i.jobn i.firmid#i.jobn#i.year i.year#i.wac#i.sicdiv#i.jobn) cluster(estid)
	est store withinfirm`merit'
	}

	estadd local controls "$\times$", replace: withinlmmeritcomboth withinjobmeritcomboth withinfirmmeritcomboth withinlmmeritcomb withinjobmeritcomb withinfirmmeritcomb withinlmmeritonly withinjobmeritonly withinfirmmeritonly
	estadd local lmfixed "$\times$", replace: withinlmmeritcomboth withinjobmeritcomboth withinfirmmeritcomboth withinlmmeritcomb withinjobmeritcomb withinfirmmeritcomb withinlmmeritonly withinjobmeritonly withinfirmmeritonly
	estadd local estfixed "$\times$", replace: withinjobmeritcomboth withinfirmmeritcomboth withinjobmeritcomb withinfirmmeritcomb withinjobmeritonly withinfirmmeritonly
	estadd local firmfixed "$\times$", replace: withinfirmmeritcomboth withinfirmmeritcomb withinfirmmeritonly

	local note=""
	wordwrap "`note'", l(100)
	local noteshort=r(text)
	di "`noteshort'"

	label var meritonly "Merit (Narrow)"
	label var meritcomb "Merit or Combination"
	label var meritcomboth "Merit, Combination or Other"

	// For paper
	esttab withinlmmeritcomboth withinjobmeritcomboth withinlmmeritcomb withinjobmeritcomb withinlmmeritonly withinjobmeritonly using results/meritoptions.tex, replace ///
	b(3) se(3) $starcode obslast label nogaps nobaselevels lines nomtitles nonotes ///
	nodepvars interaction(" * ") keep(meritonly meritcomb meritcomboth) ///
	scalar("controls Controls" ///
	"hello Fixed effects:" ///
	"lmfixed \hspace{.1cm} Year X City X Ind. X Occup." ///
	"estfixed \hspace{.1cm} Occup. X Establishment") 

	restore
}
log close
