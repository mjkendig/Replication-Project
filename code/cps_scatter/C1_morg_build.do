*-------------------------------------------------------------------------------
* PRELIMINARIES
*-------------------------------------------------------------------------------
// tasks: SECTION 1. appending data & renaming relevant variables
	   // SECTION 2. creating new variable jobn based on 1983-1991 industry codes
	   // SECTION 3. cleaning dataset
	   // SECTION 4. exporting new dataset 
// author: Elijah Ruiz 
*-------------------------------------------------------------------------------
* SECTION 1. appending data & renaming relevant variables
*-------------------------------------------------------------------------------

// loading in MORG data
use raw/cps/nber/morg83.dta, clear

// appending datasets
append using raw/cps/nber/morg84.dta 
append using raw/cps/nber/morg85.dta
append using raw/cps/nber/morg86.dta
append using raw/cps/nber/morg87.dta
append using raw/cps/nber/morg88.dta
append using raw/cps/nber/morg89.dta
append using raw/cps/nber/morg90.dta
append using raw/cps/nber/morg91.dta

// renaming relevant variables
rename earnhr hourwage
rename occ80 occ1990 
rename hourslw ahrsworkt
rename class classwkr
rename esr empstat

// making hourwage hourly
replace hourwage = hourwage/100

// generating region variable to correspond to DoD data
gen region=.
replace region=11 if state==16|state==11|state==14|state==12|state==15|state==13 
replace region=12 if state==22|state==21|state==23
replace region=21 if state==33|state==32|state==34|state==31|state==35
replace region=22 if state==42|state==47|state==41|state==43|state==46|state==44|state==45
replace region=31 if state==51|state==53|state==59|state==58|state==52|state==56|state==57|state==54|state==55
replace region=32 if state==63|state==61|state==64|state==62
replace region=33 if state==71|state==72|state==73|state==74
replace region=41 if state==86|state==84|state==82|state==81|state==88|state==85|state==87|state==83
replace region=42 if state==91|state==94|state==93|state==95|state==92


rename state statenum
tostring statenum, generate(state)

// fixing hourwagetc variabe & formatting it correctly
gen hourwagetc = hourwage
format hourwagetc %8.2f
recode hourwagetc (. = 0)

// Top coding
replace hourwagetc = 99*1.3 if hourwagetc > 99

// recoding ind80 to ind90 
gen ind90 = ind80 
replace ind90 = 20 if ind80 == 21
replace ind90 = 31 if ind80 == 30 
replace ind90 = 32 if ind80 == 31
replace ind90 =. if ind80 == 382
replace ind90 = 450 if ind80 == 460 
replace ind90 = 451 if ind80 == 461
replace ind90 = 452 if ind80 == 462
replace ind90 =. if ind80 == 522
replace ind90 = 623 if ind80 == 630
replace ind90 = 630 if ind80 == 631
replace ind90 = 631 if ind80 == 632
replace ind90 = 662 if ind80 == 661
replace ind90 = 663 if ind80 == 662
replace ind90 = 892 if ind80 == 732
replace ind90 = 732 if ind80 == 740 
replace ind90 = 740 if ind80 == 741
replace ind90 = 741 if ind80 == 742
replace ind90 = 802 if ind80 == 801 
replace ind90 = 810 if ind80 == 802
replace ind90 = 891 if ind80 == 730 | ind80 == 891
replace ind90 = 893 if ind80 == 892

*-------------------------------------------------------------------------------
* SECTION 2. creating new variable jobn based on 1983-1991 occupation codes
*-------------------------------------------------------------------------------

// generating new variable jobn
gen jobn =. 

// replacing jobn to correspond to JANITOR & JANITOR (LIGHT)
replace jobn = 1 if occ1990 == 453 //janitor

//Material Recording, Scheduling, and Distributing Clerks
replace jobn = 3 if occ1990 < 374 & occ1990 > 358 

// replacing jobn to correspond to MAINTENANCE LABORER
replace jobn = 4 if occ1990 == 509 | occ1990 == 514 | occ1990 < 534 & occ1990 > 522 | occ1990 == 534 | occ1990 < 550 & occ1990 > 533 | occ1990 == 563 | occ1990 == 577 | occ1990 == 579 | occ1990 == 877 | occ1990 == 883

// replacing jobn to correpsond to PACKER
replace jobn = 5 if occ1990 == 754 //Packers, fillers, and wrappers

// replacing jobn to correspond to HELPER (TRADES) 
replace jobn = 6 if occ1990 < 875 & occ1990 > 864 //Helpers, constructions; Helpers, surveyors; Production helpers

// replacing jobn to correspond to WAREHOUSEMAN; there are no codes that correspond
replace jobn = 7 if occ1990 == 888 //Hand packers and packagers

// replacing jobn to correspond to FORKLIFT OPERATOR
replace jobn = 8 if occ1990 == 518 //Industry Machine Operators

// replacing jobn to correspond to MATERIAL HANDLING EQUIPMENT OPERATOR
replace jobn = 9 if occ1990 < 860 & occ1990 > 843

// replacing jobn to correspond to TRUCK DRIVER (MEDIUM) & TRUCK DRIVER (HEAVY)
replace jobn = 10 if occ1990 == 804 //Truck, delivery, and tractor drivers

//replacing jobn to correspond to MACHINE TOOL OPERATOR I & MACHINE TOOL OPERATOR II 
replace jobn = 12 if occ1990 == 345 | occ1990 == 347 | occ1990 < 780 & occ1990 > 754 | occ1990 < 754 & occ1990 > 702 | occ1990 == 853

// replacing jobn to correspond to CARPENTER
replace jobn = 14 if occ1990 == 567

// replacing jobn to correspond to ELECTRICIAN
replace jobn = 15 if occ1990 == 575 //Electricians

// replacing jobn to correspond to AUTOMOTIVE MECHANIC
replace jobn = 16 if occ1990 == 505 //Automobile mechanics

// replacing jobn to correspond to SHEET METAL MECHANIC
	replace jobn = 17 if occ1990 == 653
	
// replacing jobn to correspond to PIPEFITTER 
replace jobn = 18 if occ1990 == 585 //Plumbers, pipe fitters, and steamfitters
*NOTE: This same code can be found for MAINTENANCE LABORER

// replacing jobn to correspond to WELDER
replace jobn = 19 if occ1990 == 783 //Welders and metal cutters

//replacing jobn to correspond to MACHINIST
replace jobn = 20 if occ1990 == 637 //Machinists

// replacing jobn to correspond to ELECTRONICS MECHANIC
replace jobn = 21 if occ1990 == 538

//replacing jobn to correspond to TOOL MAKER
replace jobn = 22 if occ1990 == 634 //Tool and die makers and die setters

// replacing jobn to correspond to AIRCRAFT STRUCTURES ASSEMBLER; there are no codes that correspond 
replace jobn = 24 if occ1990 == 044

// replacing jobn to correspond to AIRCRAFT MECHANIC
replace jobn = 26 if occ1990 == 515 //Aircraft mechanics

// replacing jobn = 29 to correspond to SHIPFITTER; there are no codes that correspond
replace jobn = 29 if occ1990 == 547

// replacing jobn to correspond to ELECTRICAL LINEMAN
replace jobn = 32 if occ1990 == 527 //Telecom and line installers and repairers

// replacing jobn to correspond to ELECTRICAN (POWERPLANT)
replace jobn = 33 if occ1990 == 695 //Power plant operators

// replacing jobn to correspond to INDUSTRIAL ELECTRONIC CONTROLS REPAIRER
replace jobn = 34 if occ1990 == 523 //Repairers of Industrial electrical equipment

// replacing jobn to correspond to ELECTRONIC TEST EQUIPMENT REPAIRER
replace jobn = 35 if occ1990 == 577 //Electric power installers and repairers

// replacing jobn to correspond to TELEPHONE INSTALLER-REPAIRER
replace jobn = 52 if occ1990 == 527 //Telecom and line installers and repairers

// replacing jobn to orrespond to HEAVY MOBILE EQUIPMENT OPERATOR
replace jobn = 55 if occ1990 == 844

// replacing jobn to correspond to DIESEL ENGINE MECHANIC
replace jobn = 111 if occ1990 == 509 //Small engine repairers

// replacing jobn to correspond to AIR CONDITIONING MECHANIC
replace jobn = 150 if occ1990 == 534 //Heating, air conditioning, and refrigerationg mechanics 
*NOTE: 534 also found in MAINTENANCE LABORER & SHEET METAL MECHANIC

*-------------------------------------------------------------------------------
* SECTION 3. cleaning dataset
*-------------------------------------------------------------------------------

drop if empstat > 2 & year < 1989 & year > 1982
recode empstat (2 = 1)

drop if year==1989 & earnwt==.
drop if year==1990 & earnwt==. //1,820 obs deleted
drop if year==1991 & earnwt==. //1,817 obs deleted
*-------------------------------------------------------------------------------
* SECTION 4. exporting new dataset 
*-------------------------------------------------------------------------------

// saving as new dataset
save created/cps/1983_1991morg.dta, replace

