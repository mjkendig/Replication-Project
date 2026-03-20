/******************************************************************************
JJ: last modified 1/31/2015
Purpose: clean company names
Input: 	 
Output:  
Notes:	 set $name to appropriate variable to clean
Assumptions: 
******************************************************************************/
******************************************************************************


global name estname
replace $name = " " + $name + " "

forval i = 1/2 {
	
	* clean company name *
	replace $name = upper($name)
	replace $name = itrim($name)
	replace $name = " " + $name + " " //for comparisons at the beginnings/ends

	replace $name = subinstr($name, "[EACUTE]", "E", .)
	replace $name = subinstr($name, "[COMMAT]", "@", .)
	replace $name = subinstr($name, "[AMP]", "&", .)

	// "and" synonyms
	replace $name = subinstr($name, "+", "&", .)
	replace $name = subinstr($name, " AND ", " & ", .)
	replace $name = subinstr($name, " ET ", " & ", .)
	replace $name = subinstr($name, " UND ", " & ", .)
	replace $name = subinstr($name, "&", " & ", .)
	replace $name = subinstr($name, " & ", "", .)

	// accented characters 

	// remove punctuation
	replace $name = subinstr($name, "@", "", .)
	replace $name = subinstr($name, ",", "", .)
	replace $name = regexr($name, "\.COM[ a-zA-Z_0-9]*", " ")
	replace $name = regexr($name, " DOT COM$", " ")
	replace $name = subinstr($name, ".", " ", .)
	replace $name = subinstr($name, "'", " ", .)
	replace $name = subinstr($name, ";", " ", .)
	replace $name = subinstr($name, "^", " ", .)
	replace $name = subinstr($name, "<", " ", .)
	replace $name = subinstr($name, ">", " ", .)
	replace $name = subinstr($name, "`", " ", .)
	replace $name = subinstr($name, "_", " ", .)
	replace $name = subinstr($name, "!", " ", .)
	replace $name = subinstr($name, "+", " ", .)
	replace $name = subinstr($name, "?", " ", .)
	replace $name = regexr($name, "\(.*\)", " ") // remove everything in parentheses
	replace $name = subinstr($name, "(", " ", .)
	replace $name = subinstr($name, ")", " ", .)
	replace $name = subinstr($name, "$", " ", .)
	replace $name = subinstr($name, "{", " ", .)
	replace $name = subinstr($name, "}", " ", .)
	replace $name = subinstr($name, "\", " ", .)
	replace $name = subinstr($name, "|", " ", .)
	replace $name = subinstr($name, "%", " ", .)
	replace $name = subinstr($name, "[", " ", .)
	replace $name = subinstr($name, "]", " ", .)
	replace $name = subinstr($name, "*", " ", .)
	replace $name = subinstr($name, ":", " ", .)
	replace $name = subinstr($name, "~", " ", .)
	replace $name = subinstr($name, "#", " ", .)
	replace $name = subinstr($name, "/", " ", .)
	replace $name = subinstr($name, "-", " ", .)
	replace $name = subinstr($name, "=", " ", .)
	replace $name = subinstr($name, "  ", " ", .)

	// add a space at the beginning & end of all, remove at the end
	replace $name = " " + $name + " "

	// remove extraneous words
	replace $name = subinstr($name, " THE ", " ", .)
	replace $name = regexr($name, " (AS )?REPRESENTED BY ", " ") 

	// common misspellings
	replace $name = regexr($name, " ASSETTS ", " ASSETS ") 
	replace $name = regexr($name, " ALUMINUM ", " ALUMINIUM ") 
	replace $name = regexr($name, " ASSOCIATES? ", " ASSOCIATES ") 
	replace $name = regexr($name, " AUHTORITHY ", " AUTHORITY ") 
	replace $name = regexr($name, " BANDWITH ", " BANDWIDTH ") 
	replace $name = regexr($name, " BELL SOUTH ", " BELLSOUTH ") 
	replace $name = regexr($name, " CHRYLSER ", " CHRYSLER ") 
	replace $name = regexr($name, " COLTD ", " CO LTD ") 
	replace $name = regexr($name, " COMAPNY ", " COMPANY ") 
	replace $name = regexr($name, " COMPAMY ", " COMPANY ") 
	replace $name = regexr($name, " COMAPNY ", " COMPANY ") 
	replace $name = regexr($name, " COMPA ", " COMPANY ") 
	replace $name = regexr($name, " COMPANY ", " CO ") 
	replace $name = regexr($name, " CONSULANT ", " CONSULTANT ") 
	replace $name = regexr($name, " CORPORATIONI ", " CORPORATION ") 
	replace $name = regexr($name, " COR?PORATII?ON ", " CORPORATION ") 
	replace $name = regexr($name, " CORPORTION ", " CORPORATION ") 
	replace $name = regexr($name, " CORPROATION ", " CORPORATION ") 
	replace $name = regexr($name, " DAIM(LER) ?CHRYSLER ", " DAIMLER CHRYSLER ") 
	replace $name = regexr($name, " ELECRONIC ", " ELECTRONIC ") 
	replace $name = regexr($name, " ELECTONICS ", " ELECTRONICS ") 
	replace $name = regexr($name, " ELECTRONISC ", " ELECTRONICS ") 
	replace $name = regexr($name, " ELECTRONIOCS ", " ELECTRONICS ") 
	replace $name = regexr($name, " ENGG ", " ENG ")
	replace $name = regexr($name, " GOVENORS ", " GOVERNORS ") 
	replace $name = regexr($name, " IMC ", " INC ") 
	replace $name = regexr($name, " INSTI(TI)?TUT?E ", " INSTITUTE ") 
	replace $name = regexr($name, " LIMTIED ", " LIMITED ") 
	replace $name = regexr($name, " LIABITY ", " LIABILITY ") 

	// standard abbreviations
	replace $name = regexr($name, " A B ", " AB ") 
	replace $name = regexr($name, " ACADEM(IA|Y) ", " ACAD ") 
	replace $name = regexr($name, " A G ", " AG ") 
	replace $name = regexr($name, " AGRIC[OU]L[A-Z]* ", " AGRIC ") 
	replace $name = regexr($name, " A S ", " AS ") 
	replace $name = regexr($name, " ASSOCIATION ", " ASSOC ") 
	replace $name = regexr($name, " AMER ", " AMERICA ") //*

	replace $name = regexr($name, " BROTHERS ", " BROS ") 

	replace $name = regexr($name, " CAPITAL ", " CAP ") 
	replace $name = regexr($name, " CLOSE CORPORATION ", " CC ") 
	replace $name = regexr($name, " COMPAN(IES|Y|) ", " CO ") 
	replace $name = regexr($name, " COMMUNICATIONS? ", " COMM ") 
	replace $name = regexr($name, " CONSOLIDATED ", " CON ") 
	replace $name = regexr($name, " CORPORATION ", " CORP ") 
	replace $name = regexr($name, " CORPORATE ", " CORP ") 
	replace $name = regexr($name, " CRESENT ", " CRESCENT ")

	replace $name = regexr($name, " DEPARTE?MENT ", " DEPT ") 
	replace $name = regexr($name, " DIVISIONE? ", " DIV ") 
	replace $name = regexr($name, " DIRECTOR ", " DIR ") 

	replace $name = regexr($name, " GROUPE?(MENT)? ", " GRP ") 
	replace $name = regexr($name, " GP ", " GRP ") 

	replace $name = regexr($name, " HOLDINGS? ", " HLDGS ") 

	replace $name = regexr($name, " INCO[RPOR]ATED ", " INC ") 
	replace $name = regexr($name, " INCO[RPOR]ATION ", " INC ") 
	replace $name = regexr($name, " INDUSTR(I|Y)[A-Z]* ", " IND ") 
	replace $name = regexr($name, " INSURANCE ", " INS ") 
	replace $name = regexr($name, " INTERNA[TION]AL ", " INTL ") 

	replace $name = regexr($name, " L L C ", " LLC ") 
	replace $name = regexr($name, " LIMITED ", " LTD ") 
	replace $name = regexr($name, " LTD CO ", " CO LTD ") 
	replace $name = regexr($name, " LTD LTEE ", " LTD ") 
	replace $name = regexr($name, " LTD LIABILITY CO ", " LLC ") 

	replace $name = regexr($name, " MEDICAL ", " MED ") 
	replace $name = regexr($name, " MANUFACTURINGS? ", " MFG ") 
	replace $name = regexr($name, " MANAGEMENT ", " MGT ") 

	replace $name = regexr($name, " NATIONA[A-Z]* ", " NAT ") 
	replace $name = regexr($name, " NATL ", " NAT ") 

	replace $name = regexr($name, " ORGANI[SZ]Z?ATI[A-Z]* ", " ORG ")
	 
	replace $name = regexr($name, " PUBLIC LTD COMPANY ", " PLC ") 
	replace $name = regexr($name, " PUBLIC LTD ", " PLC ") 
	replace $name = regexr($name, " PUBLIC LIABILITY CO ", " PLC ") 
	replace $name = regexr($name, " P L C ", " PLC ") 
	replace $name = regexr($name, " PROPERT(IES|Y) ", " PROP ") 

	replace $name = regexr($name, " SOCIET[AEY] ", " SOC ") 
	replace $name = regexr($name, " STORE?S? ", " ") 

	replace $name = regexr($name, " TECHNOLOGI(C|QUE)[A-Z]* ", " TECH ") 
	replace $name = regexr($name, " TECHN?OLOG(IES|Y) ", " TECH ") 
	replace $name = regexr($name, " TELECOMM?UNICA[CTZ]ION[IS]? ", " TELECOM ") 

	replace $name = regexr($name, " UNITED STATES (OF AMERICA )? ", " USA ") 
	
	// connor code 
	
	replace $name = regexr($name, " ASSN ", " ASSOC ") 
	replace $name = regexr($name, " TV ", "TELEVISION") 
	replace $name = regexr($name, " ASN ", " ASSOC ") 
	replace $name = regexr($name, " DIST ", " DISTRICT ") 
	replace $name = regexr($name, " DISTR ", " DISTRICT ") 
	replace $name = regexr($name, " UNIV ", " UNIVERSITY ")
	replace $name = regexr($name, " COLL ", " COLLEGE ") 

	// NUMBERS

	replace $name = regexr($name, " 12TH", " TWELFTH ")
	replace $name = regexr($name, " 10TH", " TENTH ")
	replace $name = regexr($name, " 9TH", " NINTH ")
	replace $name = regexr($name, " 8TH", " EIGHTH ")
	replace $name = regexr($name, " 7TH", " SEVENTH ")
	replace $name = regexr($name, " 6TH", " SIXTH ")
	replace $name = regexr($name, " 5TH", " FIFTH ")
	replace $name = regexr($name, " 4TH", " FOURTH ")
	replace $name = regexr($name, " 3RD", " THIRD ")
	replace $name = regexr($name, " 2ND", " SECOND ")
	replace $name = regexr($name, " 1ST", " FIRST ")

// see below for reasons behind number correction order/ details
	replace $name = regexr($name, " (1 |1-|1|)800", " ONE EIGHT HUNDRED ")

	replace $name = trim($name)

	replace $name = regexr($name, " [0-9][0-9][0-9][0-9]+([A-Z]*)$", "")
	replace $name = regexr($name, " [0-9][0-9][0-9][0-9]+([A-Z]*)$", "")
	replace $name = regexr($name, " [0-9][0-9][0-9]$", "")

	replace $name = " " + $name + " "

	replace $name = regexr($name, " 90", " NINETY ")
	replace $name = regexr($name, " 80", " EIGHTY ")
	replace $name = regexr($name, " 70", " SEVENTY ")
	replace $name = regexr($name, " 60", " SIXTY ")
	replace $name = regexr($name, " 50", " FIFTY ")
	replace $name = regexr($name, " 40", " FORTY ")
	replace $name = regexr($name, " 30", " THIRTY ")
	replace $name = regexr($name, " 20", " TWENTY ")
	replace $name = regexr($name, " 10", " TEN ")

	replace $name = regexr($name, " 24", " TWENTY FOUR ")
	replace $name = regexr($name, " 99", " NINETY NINE ")
	replace $name = regexr($name, " 21", " TWENTY ONE ")
	replace $name = regexr($name, " 31", " THIRTY ONE ")

	replace $name = regexr($name, " 11", " ELEVEN ")
	replace $name = regexr($name, " 12", " TWELVE ")
	replace $name = regexr($name, " 13", " THIRTEEN ")
	replace $name = regexr($name, " 14", " FOURTEEN ")
	replace $name = regexr($name, " 15", " FIFTEEN ")
	replace $name = regexr($name, " 16", " SIXTEEN ")
	replace $name = regexr($name, " 17", " SEVENTEEN ")
	replace $name = regexr($name, " 18", " EIGHTEEN ")
	replace $name = regexr($name, " 19", " NINETEEN ")

	replace $name = regexr($name, "[0-9][0-9]$", "")

	replace $name = regexr($name, " 9", " NINE ")
	replace $name = regexr($name, " 8", " EIGHT ")
	replace $name = regexr($name, " 7", " SEVEN ")
	replace $name = regexr($name, " 6", " SIX ")
	replace $name = regexr($name, " 5", " FIVE ")
	replace $name = regexr($name, " 4", " FOUR ")
	replace $name = regexr($name, " 3", " THREE ")
	replace $name = regexr($name, " 2", " TWO ")
	replace $name = regexr($name, " 1", " ONE ")
	replace $name = regexr($name, " 0", " ZERO ")

	// remove Inc, Co, Corp (isolated)
	replace $name = regexr($name," INC "," ")
	replace $name = regexr($name," ([IN]*)CORP([.ICRPATIONED]*) "," ")
	replace $name = regexr($name," CO(\.|,|) "," ")
	replace $name = regexr($name,"( LLC | LLP | LP | LTD | GRP | HLDGS | AG | PLC ) "," ")
	
	// remove extra spaces
	replace $name = trim($name)
	replace $name = itrim($name)

	// remove Inc, Co, Corp (at end)
	replace $name = regexr($name,"(, |,| |& |&)INC(\.|,|)$","")
	replace $name = regexr($name,"(, |,| |& |&)IN(\.|,|)$","")
	replace $name = regexr($name,"(, |,| |& |&)([IN]*)CORP([.ICRPATIONED]*)(\.|,|)$"," ")
	replace $name = regexr($name," CO(\.|,|)$"," ")
	replace $name = regexr($name," CA(\.|,|)$"," ")
	replace $name = regexr($name,"( LLC| LLP| LP| LTD| GRO| GRP| HLDGS| AG| PLC)$"," ")
	replace $name = regexr($name," STORES(\.|,|)$"," ")

	// clean up end of name
	replace $name = regexr($name,"( \.|\.| &|&| ,|,)$","")
	replace $name = regexr($name," SERVICES", " SERVICE ")
	
	// common names
	/*
	replace $name = regexr($name,"A\s?T & T","AT & T")
	replace $name = regexr($name,"B\s?B & T","BB & T")
	replace $name = regexr($name,"P\s?G & E","PG & E")
	replace $name = regexr($name,"WALMART","WAL MART")
	*/
	replace $name = regexr($name,"AMERICA ONLINE","AOL")
	replace $name = regexr($name,"AMERICAN TELEPHONE TELEGRAPH","ATT")
	replace $name = regexr($name,"CAREMARK","")
	replace $name = "COORS" if regexm($name, "( |^)COORS( |$)")
	replace $name = "HEINZ" if regexm($name, "( |^)HEINZ( |$)")
	replace $name = "HERSHEY" if regexm($name, "( |^)HERSHEY( |$)")
	
}

replace $name = strtrim(stritrim($name))

/*
gen sicc3 = floor(sicc/10) //get rid of last (fourth) digit of SIC code; there seems to be some
	//variation in assigning this code to the same company
egen est_id = group(sicc3 estname) //wage area-sicc pair identifier
sort wac sicc est_id year month
//cpigen //get CPI for wage deflation
save $path/data/est.dta, replace


// Save this information to the full job-rate dataset (created in readfwsd.do):
use $path/data/est.dta, clear
merge 1:m wac estc year month using $path/data/full.dta //add this information
save $path/data/full.dta, replace




