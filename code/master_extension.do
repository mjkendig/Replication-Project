/**

    OUTPUTS CREATED
    ---------------
    1. Table 1 descriptive-statistics files:
       results/descriptive_table_extension_zeroaware3_v7.xlsx
       results/descriptive_table_extension_zeroaware3_v7.csv

    2. Figure 1 histogram:
       results/growth_histogram_strict1yr_zeroaware3_nonzero_log_v2.pdf

    3. Table 2 regression files:
       results/table2_style_growth_interaction_strict1yr_zeroaware3_polished.rtf
       results/table2_style_growth_interaction_strict1yr_zeroaware3_polished.tex

    4. Figure 2 margins plot:
       results/growth_bins_strict1yr_zeroaware3_polished_merit_effect_marginsplot.pdf

    HOW TO RUN
    ----------
    Preferred:
        clear all
        cd *working directory as established in master.do for replication*
        do master_extension.do

    The file also tries to work if run from the code subfolder.
*****************************************************************************/

capture log close _all
clear all
set more off

*-----------------------------*
* 0. Locate replication root
*-----------------------------*
local cwd "`c(pwd)'"
capture confirm file "created/fullworking.dta"
if _rc {
    capture confirm file "../created/fullworking.dta"
    if !_rc {
        cd ..
    }
    else {
        di as error "Could not find created/fullworking.dta. Run this do-file from the Replication root or from its code subfolder."
        exit 601
    }
}

capture mkdir results
capture mkdir code

log using "code/master_paper_outputs_zeroaware3.log", replace text

*-----------------------------*
* 1. Basic checks and globals
*-----------------------------*
cap which reghdfe
if _rc {
    di as error "reghdfe is required but not installed."
    exit 199
}

cap which esttab
if _rc {
    di as error "esttab/estout is required but not installed."
    exit 199
}

cap which eststo
if _rc {
    di as error "eststo/estout is required but not installed."
    exit 199
}

capture confirm global controls
if _rc {
    global controls lnnumemp lnN_in_occ lnnemp union office coworkjobq sicwacunion lnminwage
    global controls_no_size union office coworkjobq sicwacunion lnminwage
}

capture confirm global weight
if _rc {
    global weight invrowwt
}

local year_fe year
local lab_market_FE i.year#i.sicdiv#i.jobn#i.wac
local full_interaction i.merit##ib2.job_growth_bin

*-----------------------------*
* 2. Build the analytic sample once
*-----------------------------*
use created/fullworking.dta, clear

preserve
keep estid firmid jobn year month N_in_occ nemp merit
collapse (max) any_merit=merit (mean) N_in_occ nemp, by(estid firmid jobn year month)
collapse (max) any_merit (mean) N_in_occ nemp, by(estid firmid jobn year)

sort estid jobn year
by estid jobn: gen year_gap = year - year[_n-1]
by estid jobn: gen ln_job_growth_1yr = ln(N_in_occ) - ln(N_in_occ[_n-1]) ///
    if year_gap == 1 & N_in_occ > 0 & N_in_occ[_n-1] > 0
by estid jobn: gen prev_year_gap = year[_n-1] - year[_n-2]
by estid jobn: gen L_ln_job_growth_1yr = ln_job_growth_1yr[_n-1] ///
    if year_gap == 1 & prev_year_gap == 1

gen job_growth_bin = .
replace job_growth_bin = 1 if L_ln_job_growth_1yr < 0 & L_ln_job_growth_1yr < .
replace job_growth_bin = 2 if L_ln_job_growth_1yr == 0
replace job_growth_bin = 3 if L_ln_job_growth_1yr > 0 & L_ln_job_growth_1yr < .

capture label drop job_growth_bin_lbl
label define job_growth_bin_lbl ///
    1 "Negative growth" ///
    2 "Zero growth" ///
    3 "Positive growth"
label values job_growth_bin job_growth_bin_lbl

tempfile strict_growth_bins
keep estid firmid jobn year job_growth_bin L_ln_job_growth_1yr
save `strict_growth_bins', replace
restore

merge m:1 estid firmid jobn year using `strict_growth_bins', nogen keep(master match)
drop if missing(job_growth_bin)

label var lnhourlyc          "log(Real Hourly Wage)"
label var merit             "Non-standardized pay"
label var lnnumemp          "log(Workers at Pay Level)"
label var lnN_in_occ        "log(Workers in Job)"
label var lnnemp            "log(Workers in Establishment)"
label var union             "Collective Bargaining"
label var office            "Share Managerial, Clerical in Establishment"
label var coworkjobq        "Coworkers' Occupational Level"
label var sicwacunion       "Union Density in Industry-Wage Area"
label var lnminwage         "log(Minimum Wage)"
label var job_growth_bin    "Lagged one-year job-growth bin"
label var L_ln_job_growth_1yr "Lagged one-year job growth"

tempfile analytic_sample
save `analytic_sample', replace

qui summarize year, meanonly
di "Analytic sample year range: " r(min) " to " r(max)
qui count
di "Analytic sample observations: " r(N)
tab job_growth_bin

*===========================================================*
* PART A. TABLE 1 DESCRIPTIVE STATISTICS
*===========================================================*
use `analytic_sample', clear

* Construct variables
capture drop realw workers_paylevel minw_raw neg_growth zero_growth pos_growth

gen double realw = hourlyc
capture confirm variable numemp
if !_rc {
    gen double workers_paylevel = numemp
}
else {
    gen double workers_paylevel = exp(lnnumemp)
}

capture confirm variable minwage
if !_rc {
    gen double minw_raw = minwage
}
else {
    gen double minw_raw = exp(lnminwage)
}

gen byte neg_growth  = (job_growth_bin == 1) if job_growth_bin < .
gen byte zero_growth = (job_growth_bin == 2) if job_growth_bin < .
gen byte pos_growth  = (job_growth_bin == 3) if job_growth_bin < .

local bonus_var
foreach v in bonus with_bonus sharebonus bonusdum bonus_ind {
    capture confirm variable `v'
    if !_rc {
        local bonus_var `v'
        continue, break
    }
}

local piece_var
foreach v in piece piecerate piece_rate sharepiece piecedum {
    capture confirm variable `v'
    if !_rc {
        local piece_var `v'
        continue, break
    }
}

local cola_var
foreach v in cola coladj col_adj sharecola coladum {
    capture confirm variable `v'
    if !_rc {
        local cola_var `v'
        continue, break
    }
}

di "Detected bonus variable: `bonus_var'"
di "Detected piece-rate variable: `piece_var'"
di "Detected COLA variable: `cola_var'"

tempfile statsfile
tempname posth
postfile `posth' ///
    str40 rowlabel ///
    double std_mean std_sd std_p10 std_p90 ///
    double flex_mean flex_sd flex_p10 flex_p90 ///
    using `statsfile', replace

quietly summarize realw [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile realw [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize realw [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile realw [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("Real Hourly Wages") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

quietly summarize lnhourlyc [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile lnhourlyc [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize lnhourlyc [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile lnhourlyc [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("log(Real Hourly Wages)") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

quietly summarize workers_paylevel [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile workers_paylevel [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize workers_paylevel [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile workers_paylevel [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("Workers at Pay Level") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

quietly summarize lnnumemp [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile lnnumemp [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize lnnumemp [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile lnnumemp [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("log(Workers at Pay Level)") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

quietly summarize N_in_occ [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile N_in_occ [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize N_in_occ [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile N_in_occ [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("Workers in Job") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

quietly summarize lnN_in_occ [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile lnN_in_occ [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize lnN_in_occ [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile lnN_in_occ [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("log(Workers in Job)") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

quietly summarize nemp [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile nemp [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize nemp [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile nemp [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("Workers in Est.") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

quietly summarize lnnemp [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile lnnemp [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize lnnemp [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile lnnemp [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("log(Workers in Est.)") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

quietly summarize union [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile union [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize union [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile union [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("Collective Bargaining") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

quietly summarize office [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile office [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize office [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile office [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("Share Office in Est.") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

quietly summarize coworkjobq [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile coworkjobq [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize coworkjobq [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile coworkjobq [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("Coworkers' Occ. Level") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

quietly summarize sicwacunion [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile sicwacunion [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize sicwacunion [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile sicwacunion [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("Share Union, Ind.-Wage Area") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

quietly summarize minw_raw [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile minw_raw [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize minw_raw [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile minw_raw [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("Minimum Wage") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

quietly summarize lnminwage [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile lnminwage [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize lnminwage [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile lnminwage [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("log(Minimum Wage)") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

quietly summarize L_ln_job_growth_1yr [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile L_ln_job_growth_1yr [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize L_ln_job_growth_1yr [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile L_ln_job_growth_1yr [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("Lagged one-year job growth") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

quietly summarize neg_growth [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile neg_growth [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize neg_growth [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile neg_growth [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("Share Negative growth") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

quietly summarize zero_growth [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile zero_growth [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize zero_growth [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile zero_growth [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("Share Zero growth") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

quietly summarize pos_growth [aw = $weight] if merit == 0
local std_mean = r(mean)
local std_sd   = r(sd)
quietly _pctile pos_growth [aw = $weight] if merit == 0, p(10 90)
local std_p10  = r(r1)
local std_p90  = r(r2)
quietly summarize pos_growth [aw = $weight] if merit == 1
local flex_mean = r(mean)
local flex_sd   = r(sd)
quietly _pctile pos_growth [aw = $weight] if merit == 1, p(10 90)
local flex_p10  = r(r1)
local flex_p90  = r(r2)
post `posth' ("Share Positive growth") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')

if "`bonus_var'" != "" {
    quietly summarize `bonus_var' [aw = $weight] if merit == 0
    local std_mean = r(mean)
    local std_sd   = r(sd)
    quietly _pctile `bonus_var' [aw = $weight] if merit == 0, p(10 90)
    local std_p10  = r(r1)
    local std_p90  = r(r2)
    quietly summarize `bonus_var' [aw = $weight] if merit == 1
    local flex_mean = r(mean)
    local flex_sd   = r(sd)
    quietly _pctile `bonus_var' [aw = $weight] if merit == 1, p(10 90)
    local flex_p10  = r(r1)
    local flex_p90  = r(r2)
    post `posth' ("Share with Bonus") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')
}

if "`piece_var'" != "" {
    quietly summarize `piece_var' [aw = $weight] if merit == 0
    local std_mean = r(mean)
    local std_sd   = r(sd)
    quietly _pctile `piece_var' [aw = $weight] if merit == 0, p(10 90)
    local std_p10  = r(r1)
    local std_p90  = r(r2)
    quietly summarize `piece_var' [aw = $weight] if merit == 1
    local flex_mean = r(mean)
    local flex_sd   = r(sd)
    quietly _pctile `piece_var' [aw = $weight] if merit == 1, p(10 90)
    local flex_p10  = r(r1)
    local flex_p90  = r(r2)
    post `posth' ("Share with Piece Rate") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')
}

if "`cola_var'" != "" {
    quietly summarize `cola_var' [aw = $weight] if merit == 0
    local std_mean = r(mean)
    local std_sd   = r(sd)
    quietly _pctile `cola_var' [aw = $weight] if merit == 0, p(10 90)
    local std_p10  = r(r1)
    local std_p90  = r(r2)
    quietly summarize `cola_var' [aw = $weight] if merit == 1
    local flex_mean = r(mean)
    local flex_sd   = r(sd)
    quietly _pctile `cola_var' [aw = $weight] if merit == 1, p(10 90)
    local flex_p10  = r(r1)
    local flex_p90  = r(r2)
    post `posth' ("Share with COL Adj.") (`std_mean') (`std_sd') (`std_p10') (`std_p90') (`flex_mean') (`flex_sd') (`flex_p10') (`flex_p90')
}

postclose `posth'

quietly count if merit == 0
local N_std = r(N)
quietly count if merit == 1
local N_flex = r(N)

use `statsfile', clear
export delimited using "results/descriptive_table_extension_zeroaware3_v7.csv", replace

putexcel set "results/descriptive_table_extension_zeroaware3_v7.xlsx", replace
putexcel A1 = "Descriptive statistics for the extension sample only"
putexcel B3:E3 = "Standardized pay rates", merge hcenter border(bottom)
putexcel F3:I3 = "Nonstandardized/Flexible", merge hcenter border(bottom)
putexcel B3:I3, bold
putexcel A4 = ""
putexcel B4 = "Mean"
putexcel C4 = "SD"
putexcel D4 = "p(10)"
putexcel E4 = "p(90)"
putexcel F4 = "Mean"
putexcel G4 = "SD"
putexcel H4 = "p(10)"
putexcel I4 = "p(90)"
putexcel A4:I4, bold

local startrow = 5
forvalues i = 1/`=_N' {
    local r = `startrow' + `i' - 1
    putexcel A`r' = rowlabel[`i']
    putexcel B`r' = std_mean[`i']
    putexcel C`r' = std_sd[`i']
    putexcel D`r' = std_p10[`i']
    putexcel E`r' = std_p90[`i']
    putexcel F`r' = flex_mean[`i']
    putexcel G`r' = flex_sd[`i']
    putexcel H`r' = flex_p10[`i']
    putexcel I`r' = flex_p90[`i']
}

local obsrow = `startrow' + _N + 1
putexcel A`obsrow' = "Observations"
putexcel B`obsrow' = `N_std'
putexcel F`obsrow' = `N_flex'
putexcel A`obsrow', bold

local noterow = `obsrow' + 3
putexcel A`noterow' = "Notes:"
putexcel A`noterow', bold
putexcel A`=`noterow'+1' = "Sample restricted to the polished strict one-year zero-aware 3-bin extension sample."
putexcel A`=`noterow'+2' = "Statistics split by merit = 0 (standardized pay) and merit = 1 (nonstandardized/flexible pay)."
putexcel A`=`noterow'+3' = "Weighted using inverse number of rows within each establishment-by-occupation."
putexcel A`=`noterow'+4' = "Growth definition for sample inclusion: strict one-year lagged establishment-by-occupation employment growth from consecutive annual observations only."
putexcel B5:I`obsrow', nformat(number_d2)

di "Descriptive table created successfully."
di "Excel: results/descriptive_table_extension_zeroaware3_v7.xlsx"
di "CSV:   results/descriptive_table_extension_zeroaware3_v7.csv"

*===========================================================*
* PART B. FIGURE 1 HISTOGRAM
*===========================================================*
use `analytic_sample', clear
count if L_ln_job_growth_1yr == 0
local zeroN = r(N)
count
local totalN = r(N)
local zeropct : display %4.1f 100*`zeroN'/`totalN'

_pctile L_ln_job_growth_1yr if L_ln_job_growth_1yr != 0, p(1 99)
local p1 = r(r1)
local p99 = r(r2)

histogram L_ln_job_growth_1yr if L_ln_job_growth_1yr != 0 & ///
    inrange(L_ln_job_growth_1yr, `p1', `p99'), ///
    width(0.05) fraction ///
    xline(0, lpattern(dash) lwidth(medthick)) ///
    xtitle("Lagged one-year log job growth") ///
    ytitle("Fraction of nonzero observations") ///
    title("") ///
    subtitle("") ///
    note("Exact zeros omitted: `zeroN' observations (`zeropct'% of sample). Central 98% of nonzero observations shown for readability.") ///
    graphregion(color(white)) plotregion(color(white))

graph export "results/growth_histogram_strict1yr_zeroaware3_nonzero_log_v2.pdf", replace

di "Histogram created successfully."
di "Figure 1: results/growth_histogram_strict1yr_zeroaware3_nonzero_log_v2.pdf"

*===========================================================*
* PART C. TABLE 2 AND FIGURE 2
*===========================================================*
use `analytic_sample', clear

eststo clear

* Column 1: size controls + year FE
reghdfe lnhourlyc `full_interaction' ///
    lnnumemp lnnemp lnN_in_occ ///
    [aw = $weight], ///
    absorb(`year_fe') ///
    cluster(estid)
eststo col1
estadd local Controls "No"
estadd local YearFE "Yes"
estadd local LaborMktFE "No"
estadd local OccEstFE "No"
estadd local FirmOccYearFE "No"
estadd local GrowthDef "Strict 1-year lag, zero-aware 3-bin"

* Column 2: full controls + year FE
reghdfe lnhourlyc `full_interaction' ///
    $controls ///
    [aw = $weight], ///
    absorb(`year_fe') ///
    cluster(estid)
eststo col2
estadd local Controls "Yes"
estadd local YearFE "Yes"
estadd local LaborMktFE "No"
estadd local OccEstFE "No"
estadd local FirmOccYearFE "No"
estadd local GrowthDef "Strict 1-year lag, zero-aware 3-bin"

* Column 3: preferred model as in massenkoff and wilmer
reghdfe lnhourlyc `full_interaction' ///
    $controls ///
    [aw = $weight], ///
    absorb(i.estid#i.jobn `lab_market_FE') ///
    cluster(estid)
eststo col3
estadd local Controls "Yes"
estadd local YearFE "No"
estadd local LaborMktFE "Yes"
estadd local OccEstFE "Yes"
estadd local FirmOccYearFE "No"
estadd local GrowthDef "Strict 1-year lag, zero-aware 3-bin"

* Column 4: preferred model + firm x occupation x year FE
reghdfe lnhourlyc `full_interaction' ///
    $controls ///
    [aw = $weight], ///
    absorb(i.estid#i.jobn i.firmid#i.jobn#i.year `lab_market_FE') ///
    cluster(estid)
eststo col4
estadd local Controls "Yes"
estadd local YearFE "No"
estadd local LaborMktFE "Yes"
estadd local OccEstFE "Yes"
estadd local FirmOccYearFE "Yes"
estadd local GrowthDef "Strict 1-year lag, zero-aware 3-bin"

local order_list 1.merit 1.job_growth_bin 3.job_growth_bin ///
    1.merit#1.job_growth_bin 1.merit#3.job_growth_bin ///
    lnnumemp lnnemp lnN_in_occ lnminwage union office coworkjobq sicwacunion

esttab col1 col2 col3 col4 using "results/table2_style_growth_interaction_strict1yr_zeroaware3_polished.rtf", replace ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    label nogaps nobaselevels nonotes ///
    varlabels(1.merit "Non-standardized pay" ///
              1.job_growth_bin "Negative growth" ///
              3.job_growth_bin "Positive growth" ///
              1.merit#1.job_growth_bin "Non-standardized pay x Negative growth" ///
              1.merit#3.job_growth_bin "Non-standardized pay x Positive growth") ///
    order(`order_list') ///
    stats(N Controls YearFE LaborMktFE OccEstFE FirmOccYearFE GrowthDef, ///
        labels("Observations" "Controls" "Year FE" "Year x City x Ind. x Occ. FE" "Occupation x Establishment FE" "Year x Occupation x Firm FE" "Growth definition")) ///
    addnotes("Omitted growth category = Zero growth.", ///
             "Growth bins are based on STRICT one-year lagged establishment-by-occupation employment growth from consecutive annual observations only.", ///
             "Zero-aware 3-bin definition: negative, zero, positive.", ///
             "Standard errors clustered at the establishment level.", ///
             "Weights = inverse number of rows within each establishment-by-occupation.")

esttab col1 col2 col3 col4 using "results/table2_style_growth_interaction_strict1yr_zeroaware3_polished.tex", replace ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    label nogaps nobaselevels nonotes ///
    varlabels(1.merit "Non-standardized pay" ///
              1.job_growth_bin "Negative growth" ///
              3.job_growth_bin "Positive growth" ///
              1.merit#1.job_growth_bin "Non-standardized pay x Negative growth" ///
              1.merit#3.job_growth_bin "Non-standardized pay x Positive growth") ///
    order(`order_list') ///
    stats(N Controls YearFE LaborMktFE OccEstFE FirmOccYearFE GrowthDef, ///
        labels("Observations" "Controls" "Year FE" "Year x City x Ind. x Occ. FE" "Occupation x Establishment FE" "Year x Occupation x Firm FE" "Growth definition")) ///
    addnotes("Omitted growth category = Zero growth.", ///
             "Growth bins are based on STRICT one-year lagged establishment-by-occupation employment growth from consecutive annual observations only.", ///
             "Zero-aware 3-bin definition: negative, zero, positive.", ///
             "Standard errors clustered at the establishment level.", ///
             "Weights = inverse number of rows within each establishment-by-occupation.")

estimates restore col3
margins job_growth_bin, dydx(merit)

marginsplot, xdimension(job_growth_bin) ///
    recast(scatter) ///
    ciopts(recast(rcap)) ///
    xlabel(1 "Negative" 2 "Zero" 3 "Positive", noticks) ///
    xtitle("Lagged one-year job-growth bin") ///
    ytitle("Marginal effect on log(real hourly wage)") ///
    title("") ///
    graphregion(color(white) margin(medium)) ///
    plotregion(color(white) margin(medium))

graph export "results/growth_bins_strict1yr_zeroaware3_polished_merit_effect_marginsplot.pdf", replace

di "Regression table created successfully."
di "Table 2 RTF: results/table2_style_growth_interaction_strict1yr_zeroaware3_polished.rtf"
di "Table 2 TEX: results/table2_style_growth_interaction_strict1yr_zeroaware3_polished.tex"
di "Figure 2:     results/growth_bins_strict1yr_zeroaware3_polished_merit_effect_marginsplot.pdf"

*-----------------------------*
* End
*-----------------------------*
di "All main paper outputs created successfully."
log close
