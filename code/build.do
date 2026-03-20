/*******************************************************************************
	PRELIMINARIES
	SECTION 1. Make job title file
	SECTION 2. Get breakpoints of FWSD raw data.
	SECTION 3. Read in FWSD data to create full.dta.
	SECTION 4. Drop repeated observations, do data cleaning and make variables.
	
	Packages needed:
	cpigen
	egenmore
	strgroup (If plugin error: go into the ado folder and rename the windows plugin to ".plugin")
	_gwtmean
	labutil	
		
*******************************************************************************/

*-------------------------------------------------------------------------------
* Preliminaries
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* SECTION 1. Make job title file
*-------------------------------------------------------------------------------
cap log close
log using code/build.log, replace 
set seed 415 
// Pull together job title info
clear
infix jobn 1-3 ///
str misc 4-6 ///
str jobtitle 7-35 ///
using raw/jobtitle.txt

// Fix clear misspellings
replace jobtitle="COOK" if jobtitle=="OOK"
replace jobtitle="WAREHOUSEMAN" if jobtitle=="W AREHOUSEMAN"
replace jobtitle="MAINTENANCE LABORER" if jobtitle=="AINTENANCELABORER"
replace jobtitle="BINDERY MACHINE OPERATOR" if jobtitle=="BINDERYMACHINE OPERATOR"
replace jobtitle="HEAVY MOBILE EQUIPMENT" if jobtitle=="HEA VY MOBILE EQUIPMENT"
replace jobtitle="AIRCRAFT ATTENDANT (GROUND)" if jobtitle=="AIRCRAFT ATTENDANT (GROU"
replace jobtitle="PATTERNMAKER" if jobtitle=="P ATTERNMAKER"
replace jobtitle="SECRETARY III" if jobtitle=="SECRETARY ill"
replace jobtitle="SECRETARY IV" if jobtitle=="SECRETARY N"
replace jobtitle="CLERK III" if jobtitle=="CLERK ill"
replace jobtitle="CLERK IV" if jobtitle=="CLERK N"
replace jobtitle="ACCOUNTANT ill" if jobtitle=="ACCOUNTANT III"
replace jobtitle="SECRETARY - PRIVATE" if jobtitle=="SECRETARY - PRNATE"

// Save
label data "Made in build.do"
save created/jobtitle.dta, replace

/*******************************************************************************
Section 2. Get breakpoints of FWSD raw data.

  Locates the 999 lines in the FWSD data, which are used to delineate the boundaries
  between the three sub-data-bases contained within each file. Generates table 
  (saved to test1/lines.DTA) with one row per file, giving the 2/3 breakpoints.
	
  Infiles: 
	inequality_proj/firmocc/RG330.FWSD.* (all rounds)
	
  Outfiles:
	inequality_proj/test1/data/lines.DTA

*******************************************************************************/

clear 
gen str5 file = "" //create a blank variable so that we can save to an empty file
save "created/lines.dta", replace

// Loop through each of the FWSD files, getting the points at which the delimiter (999) is used
// Each time, save the result to lines.SAV
foreach x in "DEC77" "DEC79" "DEC80" "DEC81" "DEC82" "FEB77" "FEB86" "FEB87" "JAN76" "JAN84" "JAN88" "JAN89" ///
"JAN91" "JUL75" "JUL77" "JUL84" "JUL85" "JUL87" "JUL90" "JUL91" "JUN18" "JUN80" ///
"JUN82" "JUN83" "JUN86" "JUN88" "JUN89" "MAY78" "MAY79" "NOV74" {
  clear
  
  local filename = "raw/arrarecords/RG330.FWSD." + "`x'" //string with filename
  display("`filename'") //print for debugging
    
  infix marker 2-4 using "`filename'", clear //get 2nd through 4th characters of each row
  gen file = "`x'" //add a column with file info (will be the same for all in this segment of the loop)
  
  gen long n = _n //get row number of each row 
  keep if marker == 999 //only keep those rows with marker 999
  gen temp = _n //number the 2 (or 3) rows with 999. Used to reshape
  reshape wide n, i(file) j(temp) //fit info onto one line: file, n1, n2, (n3) }} the latter 3 help us 
  
  drop marker //get rid of unnecessary
  list //for debugging
  
  append using "created/lines.dta" //add the new 
	//row to the beginning of the file
  sleep 1000 // To prevent permission error
  save "created/lines.dta", replace //save all info
}

/*******************************************************************************
SECTION 3. Read in FWSD data to create full.dta

  Reads in FWSD files (RG330.FWSD.*). Loops through all of the FWSD files
  and reads in the 3 different subsections (header, establishment, job rate) of 
  each one using the line numbers stored in test1/data/lines.dta using 3 dictionaries. 
 
  NEW: Uses two different job dictionaries, one (job_pre77) for 74-77, and one
  (job_post78) for 78+.
 
  Does some preliminary cleaning. Saves each section to its own DTA file in test1/data/fwsd/. 
  
  For each round, merges the three subsets by wac (wage area code) and estc 
  (establishment code). Finally, appends all the rounds into one complete file, "full.dta".
  
  Note: Must run getlines.do first to create lines.dta.
  
  Infiles: 
	test1/dictionaries/lines.dta (list of FWSD files with subsection lines),
	test1/dictionaries/header.dict (header dictionary), 
	test1/dictionaries/est.dict (establishment dictionary),
	test1/dictionaries/job.dict (job rate dictionary)
	
  Outfiles: (DEC77 is an example. Same format for all MMMYY)
	test1/data/fwsd/header.DEC77.dta (DTA of header data),
	test1/data/fwsd/est.DEC77.dta (DTA of establishment data),
	test1/data/fwsd/job.DEC77.dta (DTA of job rate data),
	test1/data/fwsd/merged.DEC77.dta (DTA of merged header+establishment+job data),
	... 
	test1/data/fwsd/full.dta (DTA of merged for all rounds)
*******************************************************************************/

clear
gen str5 round = "" //empty variable to create an empty dataset
sleep 1000 // To prevent permission error
tempfile full 
save `full', replace 

use "created/lines.dta", clear //need to 
	//load this at first in order to use `=_N' below

forvalues i = 1/`=_N' { 
  // Cycle through all rows of lines.dta (ie., all MMMYY's)
  di "Line 157, `i' "
  use "created/lines.dta", clear //re-load the 
	// lines data file so that we can get the next file's information

  // Create filenames:
  local filetemp = file[`i'] //JUN79, etc.
    display("`filetemp'") //print for debugging
    
  local readname = "raw/arrarecords/RG330.FWSD." + "`filetemp'"
	//FWSD file we're reading from
  local headername = "created/fwsd/header." + "`filetemp'" + ".dta"
  local estname =    "created/fwsd/est."    + "`filetemp'" + ".dta"
  local jobname =    "created/fwsd/job."    + "`filetemp'" + ".dta"
  local mergedname = "created/fwsd/merged." + "`filetemp'" + ".dta"

  
  // Get critical points for this file (month-year combination):
  local n1temp = n1[`i']
  local n2temp = n2[`i']
  local n3temp = n3[`i']
  
  local headerend = `n1temp' - 1
  local eststart = `n1temp' + 1
  local estend = `n2temp' - 1
  local jobstart = `n2temp' + 1
  
  
  // Get header (region,etc.) information:
  // 	(Header occurs from lines 2-headerend)
  quietly infile using "raw/dictionaries/header.dict" in 1/`headerend', using("`readname'") clear
  //codebook, compact
  quietly replace minwage = minwage/1000 //get into dollars
  keep wac state watitle domindustry1 domindustry2 sic1 sic2 sic3 sic4 sic5 sic6 minemp minwage
  save "`headername'", replace
  
  
  // Get establishment information: 
  // 	(Establishment occurs from lines eststart-estend)
  quietly infile using "raw/dictionaries/est.dict" in `eststart'/`estend', using("`readname'") clear
  //codebook, compact

  keep wac estc sicc nemp estname nonparticip contract repemp weight nplantemp estreplace //keep some of the variables
  save "`estname'", replace
  
  
  // Get job rate information: 
  //	(Job rate occurs from lines jobstart-(second to last))
  local filetemp_year = real(substr("`filetemp'", 4,.)) // get the year's ones and tens
  if `filetemp_year' == 18 local filetemp_year = 81 // there's an incorrect filename (18 instead of 81)
  disp "`filetemp_year'"
  if `filetemp_year' >= 78 quietly infile using "raw/dictionaries/job_post78.dict" in `jobstart'/l, using("`readname'") clear
  if `filetemp_year' <= 77 quietly infile using "raw/dictionaries/job_pre77.dict" in `jobstart'/l, using("`readname'") clear
  keep in f/-2 //get rid of the last observation, 9999 etc.

  // Divide money variables by 1000 to get into dollars:
  quietly replace hourly = hourly/1000
  quietly replace cola = cola/1000
  quietly replace bonus = bonus/1000
  quietly replace minhourly = minhourly/1000
  quietly replace maxhourly = maxhourly/1000
  quietly replace incrate = incrate/1000
  quietly replace incredrate = incredrate/1000
  quietly replace minrate = minrate/1000

  //codebook, compact
  save "`jobname'", replace

  // Merge! //
  merge m:1 wac using "`headername'", gen(_merge1) //bring in the header information
	//(area, etc.) using wage area code (WAC) as key.
  merge m:1 wac estc using "`estname'", gen(_merge2) //bring in the establishment
	//information using WAC and establishment code (ESTC) as keys.
  save "`mergedname'", replace

  gen round = "`filetemp'" //need to note the MMMYY that these rows are from
//   append using "$data/data/full.dta" //add the new 
  append using `full'
	//rows to the beginning of the file
  di "Line 231"
//   save "$data/data/full.dta", replace //save all info
  save `full', replace 
}

save "created/full.dta", replace 

// Some additional cleaning for the full.DTA file:
use "created/full.dta", clear
//sum
tab round
// f is currently in form MMMYY (JAN91, etc.). Want to get month number (1-12) and year number (YY):
gen year = real(substr(round,4,2))
replace year = 81 if year == 18 //one is mislabeled
gen month_s = substr(round,1,3)
gen month = .
replace month = 1 if month_s == "JAN"
replace month = 2 if month_s == "FEB"
replace month = 3 if month_s == "MAR"
replace month = 4 if month_s == "APR"
replace month = 5 if month_s == "MAY"
replace month = 6 if month_s == "JUN"
replace month = 7 if month_s == "JUL"
replace month = 8 if month_s == "AUG"
replace month = 9 if month_s == "SEP"
replace month = 10 if month_s == "OCT"
replace month = 11 if month_s == "NOV"
replace month = 12 if month_s == "DEC"
label def month 1 "JAN" 2 "FEB" 3 "MAR" 4 "APR" 5 "MAY" 6 "JUN" 7 "JUL" 8 "AUG" 9 "SEP" 10 "OCT" 11 "NOV" 12 "DEC"
label val month month
drop month_s

keep if _merge1 == 3 & _merge2 == 3 //get rid of establishments without any job-rate info,
	// and wage areas with no job-rate entries

label var round "Survey round (MMMYY)"
label var year "Year of survey (last 2 digits)"
label var month "Month of survey (numeric)"

order year extra month wac watitle estc estname sicc jobn jobseq numemp nemp hourly
sleep 1000
save "created/full.dta", replace

*-------------------------------------------------------------------------------
* SECTION 4. Drop repeated observations, do data cleaning and make variables.
*-------------------------------------------------------------------------------

// Open main data
use "created/full.dta", clear 

// "Any data with wage area codes above 197 are not valid data . The data was used for in-house purposes only" (archives survey documentation)
drop if wac > 197 

// Create dates and drop repeated values
replace year=1900+year
gen date = mdy(month,1,year)
gen change=actioncode!="" | reasoncode!=""
bys estname estc change: egen first_month = min(date)
// But keep change survey respondents
keep if date == first_month

foreach var in changes_hourly changes_cola changes_bonus changes_incentive changes_incent_red changes_guaranteed {
bys year: sum `var', detail
}

// For change months, replace cola, bonus, hourly with changed value
foreach var in changes_hourly changes_cola changes_bonus changes_incentive changes_incent_red changes_guaranteed {
replace `var'=`var'/1000
}
replace changes_cola=changes_cola/100 if year<1981 & changes_cola>4

foreach var in hourly cola bonus {
replace `var'=changes_`var' if change==1
}
replace incrate=changes_incentive if change==1
replace incredrate=changes_incent_red if change==1
replace minrate=changes_guaranteed if change==1
replace numemp=changes_nemp if change==1

// Clean and create variables
drop if numemp == 0
drop if hourly == 0
drop if estname==""

// Run cleaning code for company names and states
gen estnameorig=estname
do "code/clean_co_names.do"
egen estnamec=sieve(estname), keep(a n space)
*remove the, etc
replace estnamec = subinstr(estnamec, "THE ", "",.) 
replace estnamec = subinstr(estnamec, "U S", "US",.) 
replace estnamec = subinstr(estnamec, "TX", "TEXAS",.) 
replace estnamec = subinstr(estnamec, "TEX ", "TEXAS",.) 
replace estnamec = subinstr(estnamec, "GEN ", "GENERAL ",.) 
replace estnamec = subinstr(estnamec, "STD ", "STANDARD ",.) 
replace estnamec = subinstr(estnamec, "NATL", "NATIONAL",.) 
replace estnamec= trim(itrim(estnamec))
replace estname=estnamec
drop estnamec
drop state
do "code/clean_statecity.do"

// Group similar estnames
capture noisily confirm file raw/strgroup_IDs.dta
if _rc!=0 {
  display "Making new strgroup IDs"
	preserve 
	keep estname
	duplicates drop
	strgroup estname, gen(strgrp_id) threshold(.1) first
	keep estname strgrp_id
	bys strgrp_id (estname): gen estname_unified = estname[1]
	label data "Made in build.do on ${S_DATE}"
	save raw/strgroup_IDs.dta, replace 
	restore
}

d using raw/strgroup_IDs.dta

merge m:1 estname using raw/strgroup_IDs.dta, keep(master match)
replace estname = estname_unified
drop estname_unified

egen estidnarr = group(estname wac year nemp)
egen estid = group(estname wac)
egen occ2 = group(jobn)
sum 

// Wages
cpigen
foreach var in hourly maxhourly minhourly {
gen ln`var'=ln(`var'/cpiu)
}
egen firm_id = group(estname wac)

// Merge in job titles
merge m:1 jobn using created/jobtitle.dta, nogen 

egen jobcat=group(estname jobtitle)
gen jobweight=weight*numemp
bys estid estc year: gen wagecount=_N
gen newweight=weight/wagecount

// Industry
tostring sicc, gen(sic)
gen sicshort= regexs(1) if regexm(sic, "(^[0-9][0-9])")
gen sic3d= regexs(1) if regexm(sic, "(^[0-9][0-9][0-9])")
destring sic3d, replace
destring sicshort, replace
gen sicdiv=1 if sicshort>=1 & sicshort<=9
replace sicdiv=2 if sicshort>=10 & sicshort<=14
replace sicdiv=3 if sicshort>=15 & sicshort<=17
replace sicdiv=4 if sicshort>=20 & sicshort<=39
replace sicdiv=5 if sicshort>=40 & sicshort<=49
replace sicdiv=6 if sicshort>=50 & sicshort<=51
replace sicdiv=7 if sicshort>=52 & sicshort<=59
replace sicdiv=8 if sicshort>=60 & sicshort<=67
replace sicdiv=9 if sicshort>=70 & sicshort<=89
label define sicdiv 1 "Agriculture" 2 "Mining" 3 "Construction" 4 "Manufacturing" 5 "Transportation and utilities" 6 "Wholesale" 7 "Retail" 8 "Finance, insurance and real estate" 9 "Services"
label values sicdiv sicdiv
destring sic, replace

label define sicshort 66 "Insurance" 19 "Transportation Equipment" 1 "Agricultural Production – Crops"	2 "Agricultural Production – Livestock"	7 "Agricultural Services"	8 "Forestry"	9 "Fishing, Hunting, & Trapping"	10 "Metal, Mining"	12 "Coal Mining"	13 "Oil & Gas Extraction"	14 "Nonmetallic Minerals, Except Fuels"	15 "General Building Contractors"	16 "Heavy Construction, Except Building"	17 "Special Trade Contractors"	20 "Food & Kindred Products"	21 "Tobacco Products"	22 "Textile Mill Products"	23 "Apparel & Other Textile Products"	24 "Lumber & Wood Products"	25 "Furniture & Fixtures"	26 "Paper & Allied Products"	27 "Printing & Publishing"	28 "Chemical & Allied Products"	29 "Petroleum & Coal Products"	30 "Rubber & Miscellaneous Plastics Products"	31 "Leather & Leather Products"	32 "Stone, Clay, & Glass Products"	33 "Primary Metal Industries"	34 "Fabricated Metal Products"	35 "Industrial Machinery & Equipment"	36 "Electronic & Other Electric Equipment"	37 "Transportation Equipment"	38 "Instruments & Related Products"	39 "Miscellaneous Manufacturing Industries"	40 "Railroad Transportation"	41 "Local & Interurban Passenger Transit"	42 "Trucking & Warehousing"	43 "U.S. Postal Service"	44 "Water Transportation"	45 "Transportation by Air"	46 "Pipelines, Except Natural Gas"	47 "Transportation Services"	48 "Communications"	49 "Electric, Gas, & Sanitary Services"	50 "Wholesale Trade – Durable Goods"	51 "Wholesale Trade – Nondurable Goods"	52 "Building Materials & Gardening Supplies"	53 "General Merchandise Stores"	54 "Food Stores"	55 "Automative Dealers & Service Stations"	56 "Apparel & Accessory Stores"	57 "Furniture & Homefurnishings Stores"	58 "Eating & Drinking Places"	59 "Miscellaneous Retail"	60 "Depository Institutions"	61 "Nondepository Institutions"	62 "Security & Commodity Brokers"	63 "Insurance Carriers"	64 "Insurance Agents, Brokers, & Service"	65 "Real Estate"	67 "Holding & Other Investment Offices"	70 "Hotels & Other Lodging Places"	72 "Personal Services"	73 "Business Services"	75 "Auto Repair, Services, & Parking"	76 "Miscellaneous Repair Services"	78 "Motion Pictures"	79 "Amusement & Recreation Services"	80 "Health Services"	81 "Legal Services"	82 "Educational Services"	83 "Social Services"	84 "Museums, Botanical, Zoological Gardens"	86 "Membership Organizations"	87 "Engineering & Management Services"	88 "Private Households"	89 "Services, Not Elsewhere Classified"	91 "Executive, Legislative, & General"	92 "Justice, Public Order, & Safety"	93 "Finance, Taxation, & Monetary Policy"	94 "Administration of Human Resources"	95 "Environmental Quality & Housing"	96 "Administration of Economic Programs"	97 "National Security & International Affairs"	98 "Zoological Gardens"	99 "Non-Classifiable Establishments", replace
label values sicshort sicshort

// Share office workers
gen office=(nemp-nplantemp)/nemp
replace office=0 if office<0

// Unionized?
gen union=contract=="Y"

// Rangereason
gen rangereason2=rangereason
replace rangereason="X" if rangereason=="0" | rangereason=="Y" | rangereason=="7" | rangereason=="T" | rangereason==""
replace rangereason="M" if rangereason=="C"
encode(rangereason), gen(rangereasonc) 
gen merit=rangereason2=="M" | rangereason2=="X" | rangereason2=="C"
gen piecerate=incrate!=0 & incrate!=.

// Spread
replace minhourly=. if rangereason=="N"
replace lnminhourly=. if rangereason=="N"
gen spread=lnmaxhourly-lnminhourly if maxhourly!=0
replace spread=0 if spread==.

// Real spread
bys wac estname jobtitle year: egen maxreal=max(lnhourly)
bys wac estname jobtitle year: egen minreal=min(lnhourly)
gen realspread=maxreal-minreal if maxhourly!=0

// Unskill, Grade 8 is cut-off
gen unskill=jobn==1 | jobn==2 | jobn==191 | jobn==3 | jobn==4 | jobn==5 | jobn==6 | jobn==7 | jobn==8 | jobn==9 | jobn==10 | jobn==11 | jobn==410 | jobn==418 | jobn==192 | jobn==12 | jobn==13 | jobn==40 | jobn==190 | jobn==156 | jobn==42 | jobn==43 | jobn==44 | jobn==45 | jobn==46 | jobn==47 | jobn==61 | jobn==62 | jobn==102 | jobn==140 | jobn==156 | jobn==159 | jobn==161 | jobn==162 | jobn==163 | jobn==166 | jobn==171 | jobn==175 | jobn==176 | jobn==186 | jobn==193 | jobn==194 | jobn==500 | jobn==501 | jobn==502 | jobn==503 | jobn==504 | jobn==505 | jobn==507 | jobn==511 | jobn==512 | jobn==513 | jobn==514 | (jobn>514 & jobn<524) | jobn==550 | jobn==551 | jobn==552 | jobn==553 | jobn==554 | jobn==555 | jobn==556 | (jobn>556 & jobn<=573) | (jobn>=600 & jobn<=670) 

gen trades=jobn==14 | jobn==15 | jobn==16 | jobn==17 | jobn==18 | jobn==19 | jobn==20 | jobn==21 | jobn==22 | jobn==24 | jobn==25 | jobn==35 | jobn==36 | jobn==37 | jobn==150 | jobn==169 | jobn==172 | jobn==173 | jobn==178 | jobn==195 | jobn==400 | jobn==401 | jobn==404 | jobn==409 | jobn==411 | jobn==414 | jobn==416 | jobn==417 | jobn==419 | jobn==420 | jobn==421 | jobn==27 | jobn==38 | jobn==29 | jobn==30 | jobn==31 | jobn==55 | jobn==26 | jobn==189 | jobn==111 | jobn==64 | jobn==28 | jobn==33 | jobn==34 | jobn==34 | jobn==48 | jobn==49 | jobn==51 | jobn==51 | jobn==52 | jobn==53 | jobn==54 | jobn==63 | jobn==65 | jobn==103 | jobn==107 | jobn==108 | jobn==109 | jobn==122 | jobn==124 | jobn==126 | jobn==130 | jobn==131 | jobn==133 | jobn==134 | jobn==137 | jobn==142 | jobn==143 | jobn==152 | jobn==154 | jobn==167 | jobn==170 | jobn==174 | jobn==177 | jobn==181 | jobn==182 | jobn==183 | jobn==185 | jobn==187 | jobn==196 | jobn==350 | jobn==351 | jobn==352 | jobn==353 | jobn==354 | jobn==355 | jobn==356 | jobn==357 | jobn==402 | jobn==403 | jobn==406 | jobn==412 | jobn==412 | jobn==405 | jobn==407 | jobn==408 | jobn==413 | jobn==415 | jobn==422 | jobn==506 | jobn==508 | jobn==509 | jobn==510 | jobn==524 |  jobn==525 |  jobn==526 |  jobn==527 |  jobn==528 |  jobn==529 |  jobn==530 |  jobn==531 |  (jobn>=574 & jobn<=582)

// Drop extra variables
drop cpi domindustry1 domindustry2 sic1 sic2 sic3 sic4 sic5 sic6 _merge1 ///
changes_nemp changes_weight changes_hourly changes_cola changes_bonus ///
changes_incentive changes_incent_red changes_guaranteed changes_julian extra ///
watitle incredrate minrate bluecol particip ///
minemp estreplace nonparticip _merge2 _merge misc repemp
compress

// Count
preserve
duplicates drop estid, force
// How many establishments?
di _N
restore
preserve 
expand numemp
// How many worker-years?
di _N
restore

// Job as share of total?
gen shareemp=numemp/nemp

// Recode spread
replace spread=0 if spread==.
replace spread=0 if spread<0
replace spread=2 if spread>2

// Headcount variables
gen lnnumemp=ln(numemp)
gen lnnemp=ln(nemp)
bys estid jobn year month: egen N_in_occ = sum(numemp)
gen lnN_in_occ = ln(N_in_occ)

// What is skill composition of co-workers?
bys jobn: egen lnhourlyj=wtmean(lnhourly), weight(newweight)

bys estid year: egen hourlyes=total(lnhourlyj*numemp)
bys estid year jobn: egen hourlyesi=total(lnhourlyj*numemp)
bys estid year: egen size=total(numemp)
bys estid year jobn: egen sizei=total(numemp)
gen coworkjobq=(hourlyes-hourlyesi)/(size-sizei)
drop hourlyes size sizei hourlyesi

labmask jobn, values(jobtitle)

// Construct wage info
replace bonus=bonus/10 if year<1978
replace bonus=0 if bonus<.01
replace cola=cola/10 if year<1978
replace cola=0 if cola<.001
gen colad=cola>0 & cola!=.
gen bonusd=bonus>0 & bonus!=.

egen hourlyc=rowtotal(hourly cola bonus)
replace hourlyc=incrate if incrate!=0
gen rhourlyc=hourlyc/cpiu
gen lnhourlyc=ln(hourlyc/cpiu)

*types of employers? Identify public
gen public=1 if regexm(estname, "CITY OF")

// Real logged minimum wage
gen lnminwage=ln(minwage/cpiu)

// To restrict to a balanced sample of jobs by year, keep the jobns that <=18 here:
preserve
duplicates drop jobn year, force
bys jobn: gen jobncount=_N
tab jobncount
gen core=1 if jobncount>16
keep jobn core
duplicates drop
tempfile jobcore 
save `jobcore', replace
restore

merge m:1 jobn using `jobcore', nogen

// Skill composition of establishment
reghdfe lnhourlyj i.jobn [aweight=newweight] if core==1, absorb(fe=i.year#wac#sicdiv)
predict occfe, xb
drop fe
bys estid year: egen estskill=wtmean(occfe) if core==1, weight(numemp)


// Encode state, to use in regressions
encode state, gen(staten)

// Drop missing rangereason obs
drop if rangereason2==""

// Define seniority or none vs. merit or combo
gen seniority=(rangereasonc==1 | rangereasonc==3)

// Labor market level measures
bys sic year: egen sicunion=wtmean(union), weight(newweight)
bys wac sic year: egen sicwacunion=wtmean(union), weight(newweight)
bys wac year: egen wacoffice=wtmean(office), weight(newweight)
gen tradeable=sicdiv==2 | sicdiv==4
bys wac year: egen wactradeable=wtmean(tradeable), weight(newweight)
drop tradeable

bys wac year unskill: egen hourlyskill=wtmean(lnhourlyc), weight(newweight)
forval x=0/1 {
gen wachourly`x't=hourlyskill if unskill==`x'
bys wac year: egen wachourly`x'=max(wachourly`x't)
drop wachourly`x't
}
gen wacskillgap=wachourly0-wachourly1
drop hourlyskill wachourly1 wachourly0

// string group
drop estid firm_id
egen estid=group(strgrp_id wac)
egen firmid=group(strgrp_id)
bys year jobn estid: gen count=_N
gen invrowwt=1/count
gen noweight=1

// Region, industry, etc. categorizations
gen region=""
replace region="New England" if state=="CONNECTICUT" | state=="MAINE" | state=="MASSACHUSETTS" | state=="RHODE ISLAND" | state=="VERMONT" | state=="NEW HAMPSHIRE" 
replace region="Mid-Atlantic" if state=="NEW JERSEY" | state=="NEW YORK" | state=="PENNSYLVANIA"

replace region="East Midwest" if state=="ILLINOIS" | state=="INDIANA" | state=="MICHIGAN" | state=="OHIO" | state=="WISCONSIN" 
replace region="West Midwest" if state=="IOWA" | state=="KANSAS" | state=="MINNESOTA" | state=="MISSOURI" | state=="NEBRASKA" | state=="NORTH DAKOTA" | state=="SOUTH DAKOTA"

replace region="South Atlantic" if state=="DELAWARE" | state=="FLORIDA" | state=="GEORGIA" | state=="MARYLAND" | state=="NORTH CAROLINA" | state=="SOUTH CAROLINA" | state=="VIRGINIA" | state=="DISTRICT OF COLUMBIA" | state=="WEST VIRGINIA" 
replace region="Eastern South" if state=="ALABAMA" | state=="KENTUCKY" | state=="MISSISSIPPI" | state=="TENNESSEE" 
replace region="Western South" if state=="ARKANSAS" | state=="LOUISIANA" | state=="OKLAHOMA" | state=="TEXAS" | state=="TX" | state=="TX-SOUTHWESTERN OKLAHOMA" 
replace region="Caribbean" if state=="PUERTO RICO" | state=="BERMUDA" | state=="BURMUDA" | state=="JAMAICA"

replace region="Mountain" if state=="ARIZONA" | state=="COLORADO" | state=="IDAHO" | state=="MONTANA" | state=="NEVADA" | state=="NEW MEXICO" | state=="UTAH" | state=="WYOMING" | state=="ALASKA" 
replace region="Pacific" if state=="CALIFORNIA" | state=="HAWAII" | state=="OREGON" | state=="WASHINGTON" | state=="SOUTHEASTERN WASHINGTON-EASTERN OREGON" | state=="ALASKA" 

encode region, gen(regionn)

gen bigregion=""
replace bigregion="North" if state=="CONNECTICUT" | state=="MAINE" | state=="MASSACHUSETTS" | state=="RHODE ISLAND" | state=="VERMONT" | state=="NEW HAMPSHIRE" | state=="NEW JERSEY" | state=="NEW YORK" | state=="PENNSYLVANIA"

replace bigregion="Midwest" if state=="ILLINOIS" | state=="INDIANA" | state=="MICHIGAN" | state=="OHIO" | state=="WISCONSIN" | state=="IOWA" | state=="KANSAS" | state=="MINNESOTA" | state=="MISSOURI" | state=="NEBRASKA" | state=="NORTH DAKOTA" | state=="SOUTH DAKOTA"

replace bigregion="South" if state=="DELAWARE" | state=="FLORIDA" | state=="GEORGIA" | state=="MARYLAND" | state=="NORTH CAROLINA" | state=="SOUTH CAROLINA" | state=="VIRGINIA" | state=="DISTRICT OF COLUMBIA" | state=="WEST VIRGINIA" | state=="ALABAMA" | state=="KENTUCKY" | state=="MISSISSIPPI" | state=="TENNESSEE" | state=="ARKANSAS" | state=="LOUISIANA" | state=="OKLAHOMA" | state=="TEXAS" | state=="TX" | state=="TX-SOUTHWESTERN OKLAHOMA" | state=="PUERTO RICO" | state=="BERMUDA" | state=="BURMUDA" | state=="JAMAICA"

replace bigregion="West" if state=="ARIZONA" | state=="COLORADO" | state=="IDAHO" | state=="MONTANA" | state=="NEVADA" | state=="NEW MEXICO" | state=="UTAH" | state=="WYOMING" | state=="ALASKA" | state=="CALIFORNIA" | state=="HAWAII" | state=="OREGON" | state=="WASHINGTON" | state=="SOUTHEASTERN WASHINGTON-EASTERN OREGON"

encode bigregion, gen(bigregionn)

replace sicdiv=6 if sicdiv==7 // Lump retail and wholesale
replace sicdiv=9 if sicdiv==8 // Lump finance and services
replace sicdiv=2 if sicdiv==3 // Lump mining and construction

gen size=1 if nemp<200
replace size=2 if nemp>=200

gen period=1 if year<1980
replace period=2 if year>1981 & year<1987
replace period=3 if year>1986
label define period 1 "1974-80" 2 "1981-86" 3 "1987-91"
label values period period

gen unit=1

// CPS weights
numlabel jobn, add
numlabel sicdiv, add

gen occ = .

replace occ = 1 if jobn == 1 

replace occ = 1 if jobn == 2

replace occ = 3 if jobn == 3

replace occ = 4 if jobn == 4

replace occ = 5 if jobn == 5

replace occ = 6 if jobn == 6

replace occ = 7 if jobn == 7

replace occ = 8 if jobn == 8

replace occ = 9 if jobn == 9

replace occ = 10 if jobn == 10 | jobn == 11 | jobn==156

replace occ = 12 if jobn == 12 | jobn == 13

replace occ = 14 if jobn == 14

replace occ = 15 if jobn == 15 | jobn == 27

replace occ = 16 if jobn == 16

replace occ = 17 if jobn == 17

replace occ = 18 if jobn == 18 | jobn == 28

replace occ = 19 if jobn == 19

replace occ = 20 if jobn == 20 | jobn == 31

replace occ = 21 if jobn == 21 | jobn == 37 | jobn == 36 

replace occ = 22 if jobn == 22

replace occ = 24 if jobn == 24 | jobn == 25 | jobn == 29 // Adding shipfitter to aircraft structures assemblers

replace occ = 26 if jobn == 26 | jobn == 40

replace occ = 35 if jobn == 35

replace occ = 55 if jobn == 55 | jobn == 178

replace occ = 64 if jobn == 64

replace occ = 111 if jobn == 111

replace occ = 169 if jobn == 169

replace occ = 172 if jobn == 172 | jobn == 173

replace occ = 189 if jobn == 189

replace occ = 190 if jobn == 190

replace occ = 191 if jobn == 191

replace occ = 192 if jobn == 192

replace occ = 400 if jobn > 399 & jobn < 410

replace occ = 410 if jobn > 409 & jobn < 500


// Region
capture rename region oldregion

	gen region =.
replace region = 11 if state == "CONNECTICUT" | state == "MAINE" | state == "MASSACHUSETTS" | state == "NEW HAMPSHIRE" | state == "RHODE ISLAND" | state == "VERMONT" //No VERMONT in dataset; corresponds to "NEW ENGLAND DIVISION" in marchcps.dta
replace region = 12 if state == "NEW JERSEY" | state == "NEW YORK" | state == "PENNSYLVANIA" // no NEW JERSEY in dataset; corresponds to "MIDDLE ATLANTIC DIVISION" in marchcps.dta
replace region = 21 if state == "ILLINOIS" | state == "INDIANA" | state == "MICHIGAN" | state == "OHIO" | state == "WISCONSIN" //corresponds to "EAST NORTH CENTRAL DIVISION" in marchcps.dta
replace region = 22 if state == "IOWA" | state == "KANSAS" | state == "MINNESOTA" | state == "MISSOURI" | state == "NEBRASKA" | state == "NORTH DAKOTA" | state == "SOUTH DAKOTA" //corresponds to "WEST NORT CENTRAL DIVISION" in marchcps.dta
replace region = 31 if state == "DELAWARE" | state == "DISTRICT OF COLUMBIA" | state == "FLORIDA" | state == "GEORGIA" | state == "MARYLAND" | state == "NORTH CAROLINA" | state == "SOUTH CAROLINA" | state == "VIRGINIA" | state == "WEST VIRGINIA" //corresponds to "SOUTH ATLANTIC DIVISION" in marchcps.dta
replace region = 32 if state == "ALABAMA" | state == "KENTUCKY" | state == "MISSISSIPPI" | state == "TENNESSEE" //corresponds to "EAST SOUTH CENTRAL DIVISION" in marchcps.dta
replace region = 33 if state == "ARKANSAS" | state == "LOUISIANA" | state == "OKLAHOMA" | state == "TEXAS" | state == "TX" | state == "TX-SOUTHWESTERN OKLAHOMA" //corresponds to "WEST SOUTH CENTRAL DIVISION" in marchcps.dta
replace region = 41 if state == "ARIZONA" | state == "COLORADO" | state == "IDAHO" | state == "MONTANA" | state == "NEVADA" | state == "NEW MEXICO" | state == "UTAH" | state == "WYOMING" //corresponding to "MOUNTAIN DIVISION" in marchcps.dta
replace region = 42 if state == "WASHINGTON" | state == "ALASKA" | state == "CALIFORNIA" | state == "HAWAII" | state == "OREGON" | state == "SOUTHEASTERN WASHINGTON-EASTERN OREGON" //corresponds to "PACIFIC DIVISION" in marchcps.dta

*merge m:1 year jobn using cps/new_cpsappended_jobn_year.dta, keepusing( totalnumempcps)
merge m:1 region sicdiv occ using created/cps_occ_region_sicdiv.dta, keepusing(totalnumempcps) nogen

bys region sicdiv occ: egen dodcount=total(invrowwt)
gen cpsweight=(totalnumempcps/dodcount)*invrowwt
sum cpsweight, detail

// Save working dataset

// Label variables 
label var lnhourlyc "log(Real Hourly Wages)"
label var hourlyc "Real Hourly Wages"
label var seniority "No Merit Range"
label var merit "Non-standardized Pay"
label var spread "Pay Scale Range"
label var union "Collective Bargaining"
label var lnN_in_occ "log(Workers in Job)"
label var N_in_occ "Workers in Job"
label var lnnumemp "log(Workers at Pay Level)"
label var numemp "Workers at Pay Level"
label var lnnemp "log(Workers in Est.)"
label var nemp "Workers in Est."
label var coworkjobq "Co-Workers' Occupational Level"
label var office "Share Managerial, Clerical in Est."
label var sicwacunion "Union Density in Industry-Wage Area"
label var wacskillgap "Wage Area Skilled/Unskilled Gap"
label var wactradeable "Wage Area Tradeable Industry Share"
label var wacoffice "Wage Area Managerial/Clerical Share"
label var bonusd "Share with Bonus"
label var colad "Share with COL Adjustment"
label var piecerate "Share with Piece Rate"
label var lnminwage "log(Minimum Wage)"
label var minwage "Minimum Wage"

sum
save created/fullworking.dta, replace

log close 

