*-------------------------------------------------------------------------------
* SECTION 1. Open "DoD weights basic monthlty" IPUMS-CPS download
*-------------------------------------------------------------------------------

* NOTE: You need to set the Stata working directory to the path
* where the data file is located.

log using code/cps_weight_build.log, replace

cd raw/cps 

do cps_00054_extract.do 

cd ../..
*-------------------------------------------------------------------------------
* SECTION 2. Drop non-employed workers
*-------------------------------------------------------------------------------

keep if empstat == 10 | empstat == 12

*-------------------------------------------------------------------------------
* SECTION 3. Code to sicdiv
*-------------------------------------------------------------------------------

gen sicdiv = . 
replace sicdiv = 2 if ind1950 > 126 & ind1950 < 246
replace sicdiv = 3 if ind1950 == 246
replace sicdiv = 4 if ind1950 > 246 & ind1950 < 500
replace sicdiv = 5 if ind1950 > 499 & ind1950 < 606
replace sicdiv = 6 if ind1950 > 598 & ind1950 < 636
replace sicdiv = 7 if ind1950 > 627 & ind1950 < 716
replace sicdiv = 8 if ind1950 > 699 & ind1950 < 806
replace sicdiv = 9 if ind1950 == 869 | ind1950 == 526

*-------------------------------------------------------------------------------
* SECTION 4. Code occupations
*-------------------------------------------------------------------------------

gen occ = .

replace occ = 1 if occ1990 == 453

replace occ = 3 if occ1990 > 874 & occ1990 < 891

replace occ = 4 if occ1990 > 498 & occ1990 < 558

replace occ = 5 if occ1990 == 888

replace occ = 6 if occ1990 > 859 & occ1990 < 875

replace occ = 7 if occ1990 == 876 | occ1990 == 877 | occ1990 == 883

replace occ = 8 if occ1990 == 859

replace occ = 9 if occ1990 > 834 & occ1990 < 859 

replace occ = 10 if occ1990 == 804

replace occ = 12 if occ1990 > 699 & occ1990 < 719

replace occ = 14 if occ1990 == 567

replace occ = 15 if occ1990 == 575 | occ1990 == 577 

replace occ = 16 if occ1990 == 505 | occ1990 == 507 

replace occ = 17 if occ1990 == 653 

replace occ = 18 if occ1990 == 585 

replace occ = 20 if occ1990 == 637 

replace occ = 21 if occ1990 > 519 & occ1990 < 535

replace occ = 22 if occ1990 == 634

replace occ = 24 if occ1990 > 717 & occ1990 < 726

replace occ = 26 if occ1990 == 508

replace occ = 35 if occ1990 == 518

replace occ = 55 if occ1990 == 516

replace occ = 64 if occ1990 == 308

replace occ = 111 if occ1990 == 507

replace occ = 150 if occ1990 == 534

replace occ = 169 if occ1990 == 579

replace occ = 172 if occ1990 == 696

replace occ = 189 if occ1990 == 519

replace occ = 190 if occ1990 == 748

replace occ = 191 if occ1990 > 427 & occ1990 < 445

replace occ = 192 if occ1990 == 436

replace occ = 400 if occ1990 == 189 | occ1990 == 774 

replace occ = 410 if occ1990 > 733 & occ1990 < 738


*-------------------------------------------------------------------------------
* SECTION 5. Make final version
*-------------------------------------------------------------------------------

// generating new variable counting number of total employees
bys occ region sicdiv: egen totalnumempcps=total(wtfinl)

// collapsing data
keep occ region sicdiv totalnumempcps
bys occ region sicdiv: gen t=_n
keep if t==1
drop if occ==. | sicdiv==. | region==. | totalnumempcps==.

// #
// saving appended dataset
sum 
save created/cps_occ_region_sicdiv.dta, replace //collapsed on jobn, year

log close 