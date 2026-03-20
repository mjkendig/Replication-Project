*-------------------------------------------------------------------------------
* SECTION 1. Generates region variable and maps it to different states
*-------------------------------------------------------------------------------

// load in fullworking.dta
use created/fullworking.dta, clear

*-------------------------------------------------------------------------------
* SECTION 2. rename & recode jobn variable to match jobn in marchcps.dta
*-------------------------------------------------------------------------------

// rename jobn to jobn1
rename jobn jobn1

// gen jobn
gen jobn=.

// replacing jobn based on marchcps.dta occupations
replace jobn = 1 if jobn1 == 1 | jobn1 ==2 //JANITOR + JANITOR(LIGHT) 
replace jobn = 3 if jobn1 == 3 // MATERIAL HANDLER
replace jobn = 4 if jobn1 == 4 // MAINTENANCE LABORER
replace jobn = 5 if jobn1 == 5 // PACKER
replace jobn = 6 if jobn1 == 6 // HELPER (TRADES)
replace jobn = 7 if jobn1 == 7 // WAREHOUSEMAN
replace jobn = 8 if jobn1 == 8 // FORKLIFT OPERATOR
replace jobn = 9 if jobn1 == 9 // MATERIAL HANDLING EQUIPMENT OPERATOR
replace jobn = 10 if jobn1 == 10 | jobn1 == 11 // TRUCKDRIVER (MEDIUM); TRUCKDRIVER (HEAVY) 
replace jobn = 12 if jobn1 == 12 | jobn1 == 13 // MACHINE TOOL OPERATOR I & II
replace jobn = 14 if jobn1 == 14 //CARPENTER
replace jobn = 15 if jobn1 == 15 | jobn1 == 27 //ELECTRICIAN + ELECTRICIAN, SHIP
replace jobn = 16 if jobn1 == 16 //AUTOMOTIVE MECHANIC
replace jobn = 17 if jobn1 == 17 //SHEET METAL MECHANIC
replace jobn = 18 if jobn1 == 18 | jobn1 == 28 //PIPEFITTER + PIPEFITTER, SHIP
replace jobn = 19 if jobn1 == 19 //WElDER
replace jobn = 20 if jobn1 == 20 | jobn1 == 31 //MACHINIST + MACHINIST, MARINE
replace jobn = 21 if jobn1 == 21 //ELECTRONICS MECHANIC
replace jobn = 22 if jobn1 == 22 //TOOLMAKER
replace jobn = 23 if jobn1 == 23 //***RESERVED*** (not in CPS)
replace jobn = 24 if jobn1 == 24 //AIRCRAFT STRUCTURES ASSEMBLER (not in CPS)
replace jobn = 25 if jobn1 == 25 //SEE: 24
replace jobn = 26 if jobn1 == 26 //AIRCRAFT MECHANIC
replace jobn = 29 if jobn1 == 29 //SHIPFITTER (not in CPS)
replace jobn = 30 if jobn1 == 30 //SHIPWRIGHT (not in CPS)
replace jobn = 32 if jobn1 == 32 //ELECTRICAL, LINEMAN
replace jobn = 33 if jobn1 == 33 //ELECTRICIAN (POWERPLANT)
replace jobn = 34 if jobn1 == 34 //INDUSTRIAL ELECTRONIC CONTROL
replace jobn = 35 if jobn1 == 35 //ELECTRONIC TEST EQUIPMENT REPAIRER
replace jobn = 52 if jobn1 == 52 //TELEPHONE INSTALLER-REPAIRER
replace jobn = 55 if jobn1 == 55 //HEAVY MOBILE EQUIPMENT MECHANIC
replace jobn = 111 if jobn1 == 111 //DIESEL ENGINE MECHANIC
replace jobn = 150 if jobn1 == 150 //AIR CONDITIONING MECHANIC

*-------------------------------------------------------------------------------
* SECTION 3. collapse dataset down to jobn, sicdiv, region, & year level; saving dataset
*-------------------------------------------------------------------------------

// dropping states not found in CPS/states that are not states
drop if state == "PUERTO RICO" | state == "JAMAICA" | state == "BURMUDA" | state == "BERMUDA" | state == "DEWS INSIDE WORK SURVEY AREA" | state == "DEWS OUTSIDE WORK SURVEY AREA1" | state == "DOD WAGE FIXING AUTHORITY TECH STAFF 2" 

// dropping core
drop if core!=1

drop if jobn==. | year==. | region==. | sic3d==. //merging on jobn region year sic

//renaming sic to sic87
rename sic sic87

// generating new variable counting total number of employees
egen totalnumempdod = count(jobn), by (year region sic3d) 

// collapsing data
collapse (mean) hourlyc [aw=weight], by (jobn year region sic3d totalnumempdod)

rename hourlyc hourly

save created/cps/fullworkingcoll_ind_region_occ_year.dta, replace //collapsed on jobn year region sic3d

// exit
