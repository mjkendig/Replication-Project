**---------------------------------------
//Build data set
**---------------------------------------
log using code/other_series.log, replace 

clear

//DINA data

import excel using raw/other_series/DINA_PSZ2018MainData.xlsx, sheet("Data")
drop if _n<=5
keep A AX DF
destring A, gen(year) force
destring AX, gen (taxablelaborincome)
destring DF, gen (dinab50r2014)
gen dinab50r2014earn = dinab50r2014 * taxablelaborincome 
drop AX DF
keep if year >=1962 & year <=2014
tempfile DINA 
save `DINA', replace


// CES data

clear

import excel using raw/other_series/CES_SeriesReport-20210823092746_2a07b0.xlsx, sheet("BLS Data Series")
drop if _n<=13
keep A G
destring A, gen(year) force
destring G, gen(ceshourlyprod) force
drop A G
tempfile CES 
save `CES', replace 

//ECI data

clear

import excel using raw/other_series/ECI_for_Blue_collar_Occupations_1975_2005.xlsx, sheet("Sheet1") firstrow
rename Year year
rename ECI eci
tempfile ECI 
save `ECI', replace 

//merge everything into one dataset

clear

use `DINA'
merge 1:1 year using `CES', nogen 

merge 1:1 year using `ECI', nogen 
drop A 

export delimited using "created/stagnation_replic.csv", replace


log close 



