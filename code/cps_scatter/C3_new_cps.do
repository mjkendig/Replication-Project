*-------------------------------------------------------------------------------------------------------------------------------
* PRELIMINARIES
*-------------------------------------------------------------------------------------------------------------------------------

version 15.1
clear all
set linesize 80

*-------------------------------------------------------------------------------------------------------------------------------
* SECTION 1. Appending data & labeling variables of CPS May Extract Document
*-------------------------------------------------------------------------------------------------------------------------------

// loading in CPS May Extract Data from https://data.nber.org/cps-may/
use raw/cps/nber/cpsmay74.dta, clear 
append using raw/cps/nber/cpsmay75.dta
append using raw/cps/nber/cpsmay76.dta
append using raw/cps/nber/cpsmay77.dta
append using raw/cps/nber/cpsmay78.dta
append using raw/cps/nber/cpsmay79.dta
append using raw/cps/nber/cpsmay80.dta
append using raw/cps/nber/cpsmay81.dta
append using raw/cps/nber/cpsmay82.dta

// labeling variables for appended dataset
label variable x1 "Record type"
label variable x2 "Month in sample"
label variable x3 "Sample (A or C)"
label variable x4 "Random Cluster (first ID field)"
label variable x5 "Segment number (second ID field)"
label variable x6 "Serial number (third ID field)"
label variable x7 "State Codes - 1969-72, 77-84"
label variable x8 "Region"
label variable x9 "*State Codes - 1975 version"
label variable x10 "Regional office"
label variable x11 "*SMSA rankings"
label variable x12 "Interviewer check"
label variable x13 "Noninterview cluster"
label variable x14 "Line number of respondent"
label variable x15 "Type of interview"
label variable x16 "Date completed"
label variable x17 "Did X do any work  last week?"
label variable x18 "Interviewer check  (hours range)"
label variable x19 "Absent from job or on layoff?"
label variable x20 "Looking for work last 4 weeks?"
label variable x21 "Check (continuing/departing rot.)"
label variable x22 "Sample (A or C)"
label variable x23 "*Land usage (urban/rural, farm)"
label variable x24 "Type of living quarters"
label variable x25 "*SMSA status code (central city)"
label variable x26 "Household number"
label variable x27 "Major activity last week"
label variable x28 "Hours worked last week all jobs"
label variable x29 "Usually work 35+ hours this job"
label variable x30 "*Reason less than 35 hours worked"
label variable x31 "Why absent from work"
label variable x32 "Getting wages for time off"
label variable x33 "Usually work 35+ hours this job"
label variable x34 "What doing to find work  #1"
label variable x35 "What doing to find work  #2"
label variable x36 "What doing to find work  #3"
label variable x37 "What doing to find work  #4"
label variable x38 "What doing to find work  #5"
label variable x39 "What doing to find work  #6"
label variable x40 "What doing to find work  #7"
label variable x41 "Why started looking for work"
label variable x42 "Weeks unemployed"
label variable x43 "Looking for full or part-time"
label variable x44 "Reason couldn't take job? (Y/N)"
label variable x45 "(lists reason)"
label variable x46 "When last worked full-time"
label variable x47 "When last worked for pay"
label variable x48 "Why left that job?"
label variable x49 "Wants regular job now?"
label variable x50 "Why not looking for work #1"
label variable x51 "Reason not looking       #2"
label variable x52 "Reason not looking #3"
label variable x53 "Reason not looking #4"
label variable x54 "Reason not looking #5"
label variable x55 "Reason not looking #6"
label variable x56 "Reason not looking #7"
label variable x57 "Reason not looking #8"
label variable x58 "Reason not looking #9"
label variable x59 "Reason not looking #10"
label variable x60 "Reason not looking #11"
label variable x61 "Intends to look in next 12 months?"
label variable x62 "*Class of worker"
label variable x63 "*Industry"
label variable x64 "*Occupation"
label variable x65 "Line number"
label variable x66 "Relationship to head of household"
label variable x67 "Age"
label variable x68 "Marital status"
label variable x69 "Race"
label variable x70 "Sex"
label variable x71 "Veteran status"
label variable x72 "Highest grade attended"
label variable x73 "Grade completed?"
label variable x74 "Family number for subdivided hhld"
label variable x75 "Employment status recode"
label variable x76 "Principal person of hhld?"
label variable x77 "Document count"
label variable x78 "Month"
label variable x79 "Year (last digit)"
label variable x80 "Weight (2 implied  decimals)"
label variable x81 "Errors charged to   enumerator"
label variable x82 "Type of PSU (self  representing?)"
label variable x83 "Incidence of poverty in area"
label variable x84 "SMSA size"
label variable x85 "Ethnicity"
label variable x86 "Age recode"
label variable x87 "Residence recode (always missing)"
label variable x88 "Race recode"
label variable x89 "Area recode"
label variable x90 "Poverty area code"
label variable x91 "Part-time status recode"
label variable x92 "Race-sex recode"
label variable x93 "Agricultural wage and salary?"
label variable x94 "Civilian labor force status"
label variable x95 "Full/part-time status"
label variable x96 "Experienced labor force status"
label variable x97 "Household relationship recode"
label variable x98 "Employed class of worker"
label variable x99 "Major occupation group"
label variable x100 "Labor force by time worked"
label variable x101 "Duration of unemployment"
label variable x102 "In civilian labor force?"
label variable x103 "Unemployed?"
label variable x104 "Unemployed 15+ weeks?"
label variable x105 "Other NILF?"
label variable x106 "Full time labor force?"
label variable x107 "Looking for full-time work?"
label variable x108 "Wage and salary worker?"
label variable x109 "Employed person?"
label variable x110 "Employed(nonfarm, non-hhld work)?"
label variable x111 "Experienced labor force?"
label variable x112 "Full-time experienced labor force?"
label variable x113 "Full-time or economic-part-time?"
label variable x114 "Nonfarm industry?"
label variable x115 "Nonfarm wage and salary?"
label variable x116 "Agriculture?"
label variable x117 "White collar?"
label variable x118 "Blue collar?"
label variable x119 "Manufacturing, wage and salary?"
label variable x120 "Private wage and salary?"
label variable x121 "Part-time for noneconomic reasons?"
label variable x122 "Seeking full time work?"
label variable x123 "Unemployed-no previous experience?"
label variable x124 "Full-time labor force recode"
label variable x125 "Program signal"
label variable x126 "Program signal"
label variable x127 "Age-school recode"
label variable x128 "Age recode"
label variable x129 "Age-major activity recode"
label variable x130 "Age recode"
label variable x131 "Employed status-farm recode"
label variable x132 "Marital status-age recode"
label variable x133 "Marital status-activity recode"
label variable x134 "*Major industry"
label variable x135 "Detailed class of worker"
label variable x136 "Class-employed recode"
label variable x137 "*Major industry"
label variable x138 "*Detailed industry"
label variable x139 "*Major occupation"
label variable x140 "*Detailed occupation"
label variable x141 "*Manufacturing industries"
label variable x142 "Reason not working-hours recode"
label variable x143 "Reason part time-hours recode"
label variable x144 "Detailed reason-hours recode"
label variable x145 "Covered by collective agreement"
label variable x146 "Reason-pay status recode"
label variable x147 "Program signal  so"
label variable x148 "Gross Change employment-industry"
label variable x149 "G.C. expanded employment status"
label variable x150 "G.C. intermed. emp. status"
label variable x151 "G.C. industry"
label variable x152 "G.C. employment-occupation"
label variable x153 "G.C. age"
label variable x154 "G.C. summary age"
label variable x155 "G.C. duration of unemployment"
label variable x156 "G.C. summary duration of unemp."
label variable x157 "G.C. duration by full-part time"
label variable x158 "G.C. employment and NILF"
label variable x159 "G.C. age-employment"
label variable x160 "G.C. age-employment (restricted)"
label variable x161 "G.C. education-employment"
label variable x162 "G.C. class-farm"
label variable x163 "G.C. industry"
label variable x164 "G.C. hours-at work"
label variable x165 "G.C. full/part reason"
label variable x166 "G.C. looking full/part - age"
label variable x167 "Number under 18, related to head"
label variable x168 "Total family income"
label variable x169 "Usual weekly earnings"
label variable x170 "Work for 2+ employers?"
label variable x171 "Operate own business?"
label variable x172 "Have other job (not worked)?"
label variable x173 "Check (40 or more hours)"
label variable x174 "Get higher pay for over 40 hours?"
label variable x175 "Usually work over 40 hours?"
label variable x176 "Did X also work regular job?"
label variable x177 "Another job, not worked?"
label variable x178 "Another job, not worked? (recode)"
label variable x179 "Was second job same?"
label variable x180 "Reason worked second job"
label variable x181 "Hours worked second job"
label variable x182 "Hours worked principal job"
label variable x183 "Check/recode"
label variable x184 "Days per week usually works (code)"
label variable x185 "Hours per week usually works"
label variable x186 "Usually weekly earnings"
label variable x187 "Paid by the hour?"
label variable x188 "Earnings per hour (cents)"
label variable x189 "Belong to labor union?"
label variable x190 "Who reported income data?"
label variable x191 "Second industry recode"
label variable x192 "Second occupation recode"
label variable x193 "Secondary class of worker"
label variable x194 "Dual job/unpaid job recode"
label variable x195 "Time of day begins work"
label variable x196 "AM/PM begins"
label variable x197 "Time of day ends work"
label variable x198 "AM/PM ends"
label variable x199 "Rotation group 3/other?"
label variable x200 "Year"

// renaming relevant variables
rename x7 state6
rename x9 state73
rename x63 ind70
rename x64 occ1971 
rename x188 hourwagetc
rename x200 year
rename x8 region1
rename x75 empstat

// generating region variable to correspond to DoD data (1977-1991)
gen region=.
replace region=11 if state6==16|state6==11|state6==14|state6==12|state6==15|state6==13 
replace region=12 if state6==22|state6==21|state6==23
replace region=21 if state6==33|state6==32|state6==34|state6==31|state6==35
replace region=22 if state6==42|state6==47|state6==41|state6==43|state6==46|state6==44|state6==45
replace region=31 if state6==51|state6==53|state6==59|state6==58|state6==52|state6==56|state6==57|state6==54|state6==55
replace region=32 if state6==63|state6==61|state6==64|state6==62
replace region=33 if state6==71|state6==72|state6==73|state6==74
replace region=41 if state6==86|state6==84|state6==82|state6==81|state6==88|state6==85|state6==87|state6==83
replace region=42 if state6==91|state6==94|state6==93|state6==95|state6==92

// replacing region variable to correspond to DoD data (1974-1976)
replace region=11 if state73==11|state73==12|state73==13 & year<1977 //equivalent to states in DoD
replace region=12 if state73==21|state73==22|state73==23 & year<1977 //equivalent to states in DoD
replace region=21 if state73==31|state73==32|state73==33|state73==34|state73==35 & year < 1977 //equivalent to states in DoD
replace region=22 if state73==41|state73==42|state73==43 & year<1977 //equivalent to states in DoD
replace region=31 if state73==51|state73==52|state73==53|state73==54|state73==55|state73==56 & year<1977 //equivalent to states in DoD
replace region=32 if state73==61|state73==62 & year<1977 //equivalent to states in DoD
replace region=33 if state73==71|state73==72|state73==73 & year<1977 //equivalent to states in DoD
replace region=41 if state73==81 & year<1977 //equivalent to states in DoD
replace region=42 if state73==91|state73==92|state73==93 & year<1977 //equivalent to states in DoD

// replacing hourwage variable so that it is in dollars
replace hourwagetc =. if hourwagetc ==999.99
drop if hourwagetc==. | hourwagetc<1

replace hourwagetc = hourwagetc/100 

replace hourwagetc = 99*1.3 if year < 1985 & hourwagetc > 99

*-------------------------------------------------------------------------------------------------------------------------------
* SECTION 2. generating new industry codes to correspond to IND var
*-------------------------------------------------------------------------------------------------------------------------------

*lines that are commented out means that thd ind70 code(s) has already been used 
gen ind80 = 0
replace ind80 = 10 if ind70 == 17 
*replace ind80 = 11 if ind70 == 18 //17;18;28 = other ind70 codes, but the main one has most obs
replace ind80 = 20 if ind70 == 18
replace ind80 = 21 if ind70 == 19 
replace ind80 = 30 if ind70 == 27 
replace ind80 = 31 if ind70 == 28 //18
replace ind80 = 40 if ind70 == 47 
replace ind80 = 41 if ind70 == 48 
replace ind80 = 42 if ind70 == 49
replace ind80 = 50 if ind70 == 57 
replace ind80 = 60 if ind70 == 69 //67;68;77
replace ind80 = 100 if ind70 == 268 
replace ind80 = 101 if ind70 == 269
replace ind80 = 102 if ind70 == 278 
replace ind80 = 110 if ind70 == 279 
replace ind80 = 111 if ind70 == 287 
replace ind80 = 112 if ind70 == 297 //288
replace ind80 = 120 if ind70 == 289 
replace ind80 = 121 if ind70 == 278 //297
replace ind80 = 122 if ind70 == 298 
replace ind80 = 130 if ind70 == 299 
replace ind80 = 132 if ind70 == 307 
replace ind80 = 140 if ind70 == 308
replace ind80 = 141 if ind70 == 309 
replace ind80 = 142 if ind70 == 317 
replace ind80 = 150 if ind70 == 318
replace ind80 = 151 if ind70 == 319
replace ind80 = 152 if ind70 == 327 
replace ind80 = 160 if ind70 == 328 
replace ind80 = 161 if ind70 == 329 
replace ind80 = 162 if ind70 == 337 
replace ind80 = 171 if ind70 == 338 
replace ind80 = 172 if ind70 == 339 
replace ind80 = 180 if ind70 == 349 //348
replace ind80 = 181 if ind70 == 357 
replace ind80 = 182 if ind70 == 358 
replace ind80 = 190 if ind70 == 359
replace ind80 = 191 if ind70 == 347 //367 
replace ind80 = 192 if ind70 == 49  //347;348;359;368;369
replace ind80 = 200 if ind70 == 377 
replace ind80 = 201 if ind70 == 378 
replace ind80 = 210 if ind70 == 379 
replace ind80 = 211 if ind70 == 379 //387
replace ind80 = 212 if ind70 == 387 //348
replace ind80 = 220 if ind70 == 388
replace ind80 = 221 if ind70 == 389 
replace ind80 = 222 if ind70 == 397
replace ind80 = 230 if ind70 == 107 
replace ind80 = 231 if ind70 == 108
replace ind80 = 232 if ind70 == 237 //108
replace ind80 = 241 if ind70 == 109 
replace ind80 = 242 if ind70 == 118 
replace ind80 = 250 if ind70 == 119
replace ind80 = 251 if ind70 == 127 
replace ind80 = 252 if ind70 == 128 
replace ind80 = 261 if ind70 == 137 
replace ind80 = 262 if ind70 == 138 
replace ind80 = 270 if ind70 == 139 //147
replace ind80 = 271 if ind70 == 147 
replace ind80 = 272 if ind70 == 148 
replace ind80 = 280 if ind70 == 149 
replace ind80 = 281 if ind70 == 157 
replace ind80 = 282 if ind70 == 158 
replace ind80 = 290 if ind70 == 159 
replace ind80 = 291 if ind70 == 917 //147;167
replace ind80 = 292 if ind70 == 258 
replace ind80 = 300 if ind70 == 168 
replace ind80 = 301 if ind70 == 169 
replace ind80 = 310 if ind70 == 177 
replace ind80 = 311 if ind70 == 178 //238
replace ind80 = 312 if ind70 == 179 
replace ind80 = 320 if ind70 == 187 
replace ind80 = 321 if ind70 == 188 
replace ind80 = 322 if ind70 == 189 
replace ind80 = 331 if ind70 == 197
replace ind80 = 332 if ind70 == 198 
replace ind80 = 340 if ind70 == 199 
replace ind80 = 341 if ind70 == 207 //258
replace ind80 = 342 if ind70 == 208
replace ind80 = 350 if ind70 == 209 
replace ind80 = 351 if ind70 == 219 
replace ind80 = 352 if ind70 == 227 
replace ind80 = 360 if ind70 == 228 
replace ind80 = 361 if ind70 == 229 
replace ind80 = 362 if ind70 == 227 //258
replace ind80 = 370 if ind70 == 258 //237;238
replace ind80 = 371 if ind70 == 239 //208
replace ind80 = 372 if ind70 == 247 
replace ind80 = 380 if ind70 == 248 
replace ind80 = 381 if ind70 == 249 
replace ind80 = 382 if ind70 == 257 
replace ind80 = 390 if ind70 == 259 
replace ind80 = 391 if ind70 == 259 
replace ind80 = 392 if ind70 == 398 
replace ind80 = 400 if ind70 == 407
replace ind80 = 401 if ind70 == 408
replace ind80 = 402 if ind70 == 409
replace ind80 = 410 if ind70 == 417 
replace ind80 = 411 if ind70 == 418 
replace ind80 = 412 if ind70 == 907
replace ind80 = 420 if ind70 == 419 
replace ind80 = 421 if ind70 == 427 
replace ind80 = 422 if ind70 == 428
replace ind80 = 432 if ind70 == 429
replace ind80 = 440 if ind70 == 447 
replace ind80 = 441 if ind70 == 448 
replace ind80 = 442 if ind70 == 449 
replace ind80 = 460 if ind70 == 467
replace ind80 = 461 if ind70 == 469 
replace ind80 = 462 if ind70 == 468 
replace ind80 = 470 if ind70 == 477 //479 
replace ind80 = 471 if ind70 == 478 
replace ind80 = 472 if ind70 == 479
replace ind80 = 500 if ind70 == 507
replace ind80 = 501 if ind70 == 587
replace ind80 = 502 if ind70 == 569 //557
replace ind80 = 510 if ind70 == 587 
replace ind80 = 511 if ind70 == 557 
replace ind80 = 512 if ind70 == 529 //607
replace ind80 = 521 if ind70 == 537 //607
replace ind80 = 522 if ind70 == 538 
*replace ind80 = 530 if ind70 == 529 | ind70 == 539 | ind70 == 608 | ind70 == 697 //529;539;608;697
replace ind80 = 531 if ind70 == 559 
replace ind80 = 532 if ind70 == 539 //587
replace ind80 = 540 if ind70 == 568 
replace ind80 = 541 if ind70 == 508
replace ind80 = 542 if ind70 == 509 
replace ind80 = 550 if ind70 == 527 //587
replace ind80 = 551 if ind70 == 528 //18;587;679
replace ind80 = 552 if ind70 == 558 //697
replace ind80 = 560 if ind70 == 567 
replace ind80 = 561 if ind70 == 587 //679
replace ind80 = 562 if ind70 == 508 //587
replace ind80 = 571 if ind70 == 588 
replace ind80 = 580 if ind70 == 607
replace ind80 = 581 if ind70 == 608 //679
replace ind80 = 582 if ind70 == 679 //608
replace ind80 = 590 if ind70 == 649
replace ind80 = 591 if ind70 == 609 
replace ind80 = 592 if ind70 == 617 
replace ind80 = 600 if ind70 == 627 
replace ind80 = 601 if ind70 == 628 
replace ind80 = 602 if ind70 == 629 
replace ind80 = 610 if ind70 == 637 
replace ind80 = 611 if ind70 == 638 
replace ind80 = 612 if ind70 == 639 
replace ind80 = 620 if ind70 == 647 
replace ind80 = 621 if ind70 == 648 
replace ind80 = 622 if ind70 == 649 
replace ind80 = 630 if ind70 == 657 //697
replace ind80 = 631 if ind70 == 658 
replace ind80 = 632 if ind70 == 667 //627
replace ind80 = 640 if ind70 == 668 
replace ind80 = 641 if ind70 == 669 
replace ind80 = 642 if ind70 == 677
replace ind80 = 650 if ind70 == 678 
replace ind80 = 651 if ind70 == 697
replace ind80 = 652 if ind70 == 697
replace ind80 = 660 if ind70 == 687
replace ind80 = 661 if ind70 == 627
replace ind80 = 662 if ind70 == 609 
replace ind80 = 670 if ind70 == 618 
replace ind80 = 671 if ind70 == 619 
replace ind80 = 672 if ind70 == 688
replace ind80 = 681 if ind70 == 689 
replace ind80 = 682 if ind70 == 697
replace ind80 = 691 if ind70 == 698 
replace ind80 = 700 if ind70 == 707
replace ind80 = 701 if ind70 == 708
replace ind80 = 702 if ind70 == 748 //707;708;917
replace ind80 = 710 if ind70 == 709 
replace ind80 = 711 if ind70 == 717 
replace ind80 = 712 if ind70 == 718 
replace ind80 = 721 if ind70 == 727 
replace ind80 = 722 if ind70 == 728 
replace ind80 = 730 if ind70 == 729 
replace ind80 = 731 if ind70 == 737 //848
replace ind80 = 732 if ind70 == 738 
replace ind80 = 740 if ind70 == 739 //889
replace ind80 = 741 if ind70 == 747 
replace ind80 = 742 if ind70 == 748 //738;798;897
replace ind80 = 750 if ind70 == 749 
replace ind80 = 751 if ind70 == 757 
replace ind80 = 752 if ind70 == 758 //759
replace ind80 = 760 if ind70 == 759 
replace ind80 = 761 if ind70 == 769 
replace ind80 = 762 if ind70 == 777 //778
replace ind80 = 770 if ind70 == 778 
replace ind80 = 771 if ind70 == 779
replace ind80 = 772 if ind70 == 787
replace ind80 = 780 if ind70 == 788
replace ind80 = 781 if ind70 == 798
replace ind80 = 782 if ind70 == 789 
replace ind80 = 790 if ind70 == 797
replace ind80 = 791 if ind70 == 798
replace ind80 = 800 if ind70 == 807
replace ind80 = 801 if ind70 == 808
replace ind80 = 802 if ind70 == 809 //408
replace ind80 = 812 if ind70 == 828 
replace ind80 = 820 if ind70 == 829 
replace ind80 = 821 if ind70 == 837 
replace ind80 = 822 if ind70 == 847 
replace ind80 = 830 if ind70 == 848 //847
replace ind80 = 831 if ind70 == 838 
replace ind80 = 832 if ind70 == 839 
*replace ind80 = 840 if ind70 == 838 | ind70 == 848 
replace ind80 = 841 if ind70 == 849 //878
replace ind80 = 842 if ind70 == 857 
replace ind80 = 850 if ind70 == 858 
replace ind80 = 851 if ind70 == 867 //857
replace ind80 = 852 if ind70 == 859 
replace ind80 = 860 if ind70 == 868 //749;867
replace ind80 = 861 if ind70 == 878 //848;867
replace ind80 = 862 if ind70 == 857 
replace ind80 = 870 if ind70 == 879 //848;927;937
*replace ind80 = 871 if ind70 == 887 | ind70 == 897 //878;887;
replace ind80 = 872 if ind70 == 869 //927
replace ind80 = 880 if ind70 == 877
replace ind80 = 881 if ind70 == 887
replace ind80 = 882 if ind70 == 888 //937
replace ind80 = 890 if ind70 == 889 
replace ind80 = 891 if ind70 == 897 
replace ind80 = 892 if ind70 == 897 
replace ind80 = 900 if ind70 == 927 //917;937
replace ind80 = 901 if ind70 == 937 //917;927
*replace ind80 = 910 if ind70 == 878 | ind70 == 917 | ind70 == 927 | ind70 == 937 
*replace ind80 = 921 if ind70 == 917 | ind70 == 927 | ind70 == 937 
*replace ind80 = 922 if ind70 == 848 | ind70 == 867 | ind70 == 878 | ind70 == 917 | ind70 == 927 | ind70 == 937
*replace ind80 = 930 if ind70 == 917 | ind70 == 927 | ind70 == 937
*replace ind80 = 931 if ind70 == 708 | ind70 == 917 | ind70 == 927 | ind70 == 937 
*replace ind80 = 932 if ind70 == 917 | ind70 == 927 | ind70 == 937 

// #7
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
replace ind90 = 891 if ind80 == 730 //891
replace ind90 = 893 if ind80 == 892

*-------------------------------------------------------------------------------------------------------------------------------
* SECTION 3. generating jobn variable and coding it based on 1971-1982 occ codes
*-------------------------------------------------------------------------------------------------------------------------------
***CODE BASED ON OCCUPATION CODES FOR 1971-1982, FOUND HERE: https://cps.ipums.org/cps/codes/occ_19711982_codes.shtml

// #
// generating new variable jobn
gen jobn = 0

// #
// replacing jobn to correspond to JANITOR & JANITOR (LIGHT) 
replace jobn = 1 if occ1971 == 903

// #
// replacing jobn to correspond to MATERIAL HANDLER
replace jobn = 3 if occ1971 == 753

// #
// replacing jobn to correspond to MAINTENANCE LABORER
replace jobn = 4 if occ1971 == 522 | occ1971 == 510 | occ1971 == 472 | occ1971 == 562 | occ1971 == 486 | occ1971 == 410 | occ1971 == 762

// #
// replacing jobn to correspond to PACKER
replace jobn = 5 if occ1971 == 625 | occ1971 == 631 | occ1971 == 643

// #
// replacing jobn to correspond to HELPER (TRADES) 
replace jobn = 6 if occ1971 == 750

// #
// replacing jobn to correspond to WAREHOUSEMAN
replace jobn = 7 if occ1971 == 770 //warehouse laborers, n.e.c.

// #
// replacing jobn to correspond to FORKLIFT OPERATOR
replace jobn = 8 if occ1971 == 706

// #
// replacing jobn to correspond to MATERIAL HANDLING EQUIPMENT OPERATOR
replace jobn = 9 if occ1971 == 412 | occ1971 == 424 | occ1971 == 436 

// #
// replacing jobn to correspond to TRUCK DRIVER (MEDIUM) & TRUCK DRIVER (HEAVY)
replace jobn = 10 if occ1971 == 715

// #
// replacing jobn to correspond to MACHINE TOOL OPERATOR I & MACHINE TOOL OPERATOR II 
replace jobn = 12 if occ1971 == 342 | occ1971 == 344 | occ1971 == 350 | occ1971 == 355 | occ1971 == 651 | occ1971 == 652 | occ1971 == 653 | occ1971 == 656 | occ1971 == 664 | occ1971 == 690 | occ1971 == 692

// #
// replacing jobn to correspond to CARPENTER
replace jobn = 14 if occ1971 == 415

// #
// replacing jobn to correspond to ELECTRICIAN
replace jobn = 15 if occ1971 == 430

// #
// replacing jobn to correspond to AUTOMOTIVE MECHANIC
replace jobn = 16 if occ1971 == 473 

// #
// replacing jobn to correspond to SHEET METAL MECHANIC
replace jobn = 17 if occ1971 == 535

// #
// replacing jobn to correspond to PIPEFITTER
replace jobn = 18 if occ1971 == 522 //Plumbers and pipe fitters

// #
// replacing jobn to correspond to WELDER
replace jobn = 19 if occ1971 == 680 

// #
// replacing jobn to correspond to MACHINIST
replace jobn = 20 if occ1971 == 461

// #
// replacing jobn to correspond to ELECTRONICS MECHANIC
replace jobn = 21 if occ1971 == 153

// #
// replacing jobn to correspond to TOOL MAKER
replace jobn = 22 if occ1971 == 561

// #
// replacing jobn to correspond to AIRCRAFT STRUCTURES ASSEMBLER
replace jobn = 24 if occ1971 == 006
//602

// #
// replacing jobn to correspond to AIRCRAFT MECHANIC
replace jobn = 26 if occ1971 == 170 

// #
// replacing jobn to correspond to SHIPFITTER
replace jobn = 29 if occ1971 == 540 

// #
// replacing jobn to correspond to ELECTRICAL LINEMAN
replace jobn = 32 if occ1971 == 554

// #
// replacing jobn to correspond to ELECTRICIAN (POWERPLANT) 
*replace jobn = 33 if occ1990 == NO CORRESPONDING CODES
replace jobn = 33 if occ1971 == 525 //Power station operators

// #
// replacing jobn to correspond to INDUSTRIAL ELECTRONIC CONTROLS REPAIRER
*replace jobn = 34 if occ1971 == 495
replace jobn = 34 if occ1971 == 394 
//154

// #
// replacing jobn to correspond to ELECTRONIC TEST EQUIPMENT REPAIRER
*replace jobn = 35 if occ1990 == NO CORRESPONDING CODES
replace jobn = 35 if occ1971 == 433 //electric power line and cable operators

// #
// replacing jobn to correspond to TELEPHONE INSTALLER-REPAIRER
replace jobn = 52 if occ1971 == 552

// #
// replacing jobn to correspond to HEAVY MOBILE EQUIPMENT OPERATOR
replace jobn = 55 if occ1971 == 412

// #
// replacing jobn to correspond to DIESEL ENGINE MECHANIC
replace jobn = 111 if occ1971 == 486 | occ1971 == 495

// #
// replacing jobn to correspond to AIR CONDITIONING MECHANIC
replace jobn = 150 if occ1971 == 470 

*-------------------------------------------------------------------------------------------------------------------------------
* SECTION 3. appending & cleaning dataset
*-------------------------------------------------------------------------------------------------------------------------------

// #
// renaming relevant variables 
rename x28 ahrsworkt
rename x67 age
rename x62 classwkr
rename x80 earnwt

drop if empstat > 2 //3504 obs deleted
recode empstat (2 = 1)

// #
// saving new dataset
save created/cps/cpsmay74to82, replace

// #
// appending morg dataset
append using created/cps/1983_1991morg.dta
**region=2,317,407 obs

// #
// coding ind90 to sic3d
gen sic3d =.
replace sic3d = 010 if ind90 == 010 //no obs in DoD
replace sic3d = 020 if ind90 == 011 //no obs in DoD
replace sic3d = 074 if ind90 == 012 //no obs in DoD
replace sic3d = 078 if ind90 == 020 //no obs in DoD
replace sic3d = 071 | 072 | 075 | 076 if ind90 == 030 //no obs in DoD
replace sic3d = 080 if ind90 == 031 //no obs in DoD
replace sic3d = 090 if ind90 == 032 //no obs in DoD
replace sic3d = 101 if ind90 == 040 //most obs; also 102, 105, 108, 109 in DoD 
replace sic3d = 121 if ind90 == 041 //most obs; also 122 in DoD
replace sic3d = 138 if ind90 == 042 //most obs; also 131, 132
replace sic3d = 145 if ind90 == 050 //most obs; 142, 144, 149 
replace sic3d = 162 if ind90 == 060 //most obs; 152, 154, 161, 171, 173, 174, 175, 176, 179 
replace sic3d = 201 if ind90 == 100 
replace sic3d = 202 if ind90 == 101
replace sic3d = 203 if ind90 == 102
replace sic3d = 204 if ind90 == 110
replace sic3d = 205 if ind90 == 111
replace sic3d = 206 if ind90 == 112
replace sic3d = 208 if ind90 == 120
replace sic3d = 209 if ind90 == 121 //most obs; 207
replace sic3d = 211 if ind90 == 130 //most obs; 212 213 214
replace sic3d = 225 if ind90 == 132
replace sic3d = 226 if ind90 == 140
replace sic3d = 227 if ind90 == 141
replace sic3d = 221 if ind90 == 142 //most obs; 222 223 224 228
replace sic3d = 229 if ind90 == 150 
replace sic3d = 232 if ind90 == 151 //most obs; 231 233 234 235 236 237 238
replace sic3d = 239 if ind90 == 152
replace sic3d = 262 if ind90 == 160 //most obs; 261 263
replace sic3d = 267 if ind90 == 161
replace sic3d = 265 if ind90 == 162
replace sic3d = 271 if ind90 == 171
replace sic3d = 275 if ind90 == 172 //most obs; 272 273 274 276 277 278 279
replace sic3d = 282 if ind90 == 180 
replace sic3d = 283 if ind90 == 181
replace sic3d = 284 if ind90 == 182
replace sic3d = 285 if ind90 == 190 
replace sic3d = 287 if ind90 == 191
replace sic3d = 281 if ind90 == 192 //most obs; 286 289 
replace sic3d = 291 if ind90 == 200 
replace sic3d = 295 if ind90 == 201 //most obs; 299
replace sic3d = 301 if ind90 == 210 
replace sic3d = 306 if ind90 == 211 //most obs; 302 303 304 305 
replace sic3d = 308 if ind90 == 212 
replace sic3d = 311 if ind90 == 220 
replace sic3d = 314 if ind90 == 221 //most obs; 313
replace sic3d = 317 if ind90 == 222 //most obs; 315 316 319 
replace sic3d = 241 if ind90 == 230 
replace sic3d = 243 if ind90 == 231 //most obs; 242
replace sic3d = 245 if ind90 == 232
replace sic3d = 249 if ind90 == 241 //most obs; 244
replace sic3d = 251 if ind90 == 242 //most obs; 252 253 254 257 258 259
replace sic3d = 322 if ind90 == 250 //most obs; 321 323
replace sic3d = 327 if ind90 == 251 //most obs; 324
replace sic3d = 325 if ind90 == 252 
replace sic3d = 326 if ind90 == 261
replace sic3d = 329 if ind90 == 262 //most obs; 328 
replace sic3d = 331 if ind90 == 270 
replace sic3d = 332 if ind90 == 271
replace sic3d = 333 if ind90 == 272 | ind90 == 280
replace sic3d = 342 if ind90 == 281
replace sic3d = 344 if ind90 == 282
replace sic3d = 345 if ind90 == 290 
replace sic3d = 346 if ind90 == 291
replace sic3d = 348 if ind90 == 292
replace sic3d = 349 if ind90 == 300 //most obs; 341 343 347 
replace sic3d = 351 if ind90 == 310
replace sic3d = 352 if ind90 == 311
replace sic3d = 353 if ind90 == 312
replace sic3d = 354 if ind90 == 320
replace sic3d = 357 if ind90 == 321 | ind90 == 322
replace sic3d = 356 if ind90 == 331
replace sic3d = 363 if ind90 == 340 
replace sic3d = 366 if ind90 == 341 //most obs; 365
replace sic3d = 367 if ind90 == 342 //most obs; 361 362 364 369
replace sic3d = 371 if ind90 == 351
replace sic3d = 372 if ind90 == 352
replace sic3d = 373 if ind90 == 360
replace sic3d = 374 if ind90 == 361
replace sic3d = 376 if ind90 == 362
replace sic3d = 379 if ind90 == 370 //most obs; 375
replace sic3d = 382 if ind90 == 371 //most obs; 381
replace sic3d = 384 if ind90 == 372 //most obs; 385
replace sic3d = 386 if ind90 == 380
replace sic3d = 387 if ind90 == 381
replace sic3d = 394 if ind90 == 390 
replace sic3d = 399 if ind90 == 391 //most obs; all 39 except 394
replace sic3d = 401 if ind90 == 400 //most obs; 402 404 
replace sic3d = 411 if ind90 == 401 //most obs; 413 414 415 417
replace sic3d = 412 if ind90 == 402
replace sic3d = 421 if ind90 == 410 //most obs; 423
replace sic3d = 422 if ind90 == 411
replace sic3d = 430 if ind90 == 412 //no obs in DoD
replace sic3d = 446 if ind90 == 420 //most obs; 442
replace sic3d = 451 if ind90 == 421 //most obs; 452 458
replace sic3d = 460 if ind90 == 422 //no obs in DoD
replace sic3d = 474 if ind90 == 432 //most obs; 472 478 
replace sic3d = 483 if ind90 == 440 //most obs; 484
replace sic3d = 481 if ind90 == 441
replace sic3d = 489 if ind90 == 442 //most obs; 482
replace sic3d = 491 if ind90 == 450 
replace sic3d = 492 if ind90 == 451
replace sic3d = 493 if ind90 == 452
replace sic3d = 494 if ind90 == 470 //most obs; 497 
replace sic3d = 495 if ind90 == 471
replace sic3d = 501 if ind90 == 500
replace sic3d = 502 if ind90 == 501
replace sic3d = 503 if ind90 == 502
replace sic3d = 504 if ind90 == 510 
replace sic3d = 505 if ind90 == 511
replace sic3d = 506 if ind90 == 512
replace sic3d = 507 if ind90 == 521
replace sic3d = 508 if ind90 == 530
replace sic3d = 509 if ind90 == 532 //skipped 531 because coded to 5093
replace sic3d = 511 if ind90 == 540 
replace sic3d = 512 if ind90 == 541
replace sic3d = 513 if ind90 == 542
replace sic3d = 514 if ind90 == 550 
replace sic3d = 515 if ind90 == 551 
replace sic3d = 517 if ind90 == 552
replace sic3d = 518 if ind90 == 560 
replace sic3d = 519 if ind90 == 561 | ind90 == 562 
replace sic3d = 521 if ind90 == 580 //most obs; 523
replace sic3d = 525 if ind90 == 581
replace sic3d = 526 if ind90 == 582
replace sic3d = 527 if ind90 == 590 
replace sic3d = 531 if ind90 == 591
replace sic3d = 533 if ind90 == 592
replace sic3d = 539 if ind90 == 600 
replace sic3d = 541 if ind90 == 601
replace sic3d = 545 if ind90 == 602
replace sic3d = 546 if ind90 == 610 
replace sic3d = 542 if ind90 == 611 //no obs in DoD
replace sic3d = 551 if ind90 == 612
replace sic3d = 553 if ind90 == 620
replace sic3d = 554 if ind90 == 621
replace sic3d = 559 if ind90 == 622 
replace sic3d = 566 if ind90 == 630
replace sic3d = 571 if ind90 == 631
replace sic3d = 572 if ind90 == 632
replace sic3d = 573 if ind90 == 633 | ind90 == 640
replace sic3d = 581 if ind90 == 641
replace sic3d = 591 if ind90 == 642
replace sic3d = 592 if ind90 == 650 
replace sic3d = 594 if ind90 == 651 | ind90 == 652 | ind90 == 660 | ind90 == 661 | ind90 == 662 
replace sic3d = 596 if ind90 == 663 | ind90 == 670 | ind90 == 671 
replace sic3d = 598 if ind90 == 672
replace sic3d = 599 if ind90 == 681 | ind90 == 682 
replace sic3d = 602 if ind90 == 700 //most obs; 605
replace sic3d = 603 if ind90 == 701 //no obs in DoD
replace sic3d = 610 if ind90 == 702 //no obs in DoD
replace sic3d = 671 if ind90 == 710 
replace sic3d = 633 if ind90 == 711 
replace sic3d = 650 if ind90 == 712 //no obs in DoD
replace sic3d = 731 if ind90 == 721 //no obs in DoD
replace sic3d = 734 if ind90 == 722 
replace sic3d = 736 if ind90 == 731
replace sic3d = 737 if ind90 == 732
replace sic3d = 738 if ind90 == 740 | ind90 == 741
replace sic3d = 751 if ind90 == 742
replace sic3d = 752 if ind90 == 750 //no obs in DoD
replace sic3d = 753 if ind90 == 751 
replace sic3d = 762 if ind90 == 752
replace sic3d = 769 if ind90 == 760 
replace sic3d = 880 if ind90 == 761 //no obs in DoD
replace sic3d = 701 if ind90 == 762 
replace sic3d = 702 if ind90 == 770 //no obs in DoD
replace sic3d = 721 if ind90 == 771 //also ind90 == 790 
replace sic3d = 723 if ind90 == 772
replace sic3d = 724 if ind90 == 780 //no obs in DoD
replace sic3d = 726 if ind90 == 781 //no obs in DoD
replace sic3d = 725 if ind90 == 782 //no obs in DoD
replace sic3d = 722 if ind90 == 791 //no obs in DoD
replace sic3d = 781 if ind90 == 800 //no obs in DoD
replace sic3d = 784 if ind90 == 801 //no obs in DoD
replace sic3d = 793 if ind90 == 802 //no obs in DoD
replace sic3d = 799 if ind90 == 810 //most obs; 791 794
replace sic3d = 801 if ind90 == 812 //no obs in DoD
replace sic3d = 802 if ind90 == 820 //no obs in DoD
replace sic3d = 804 if ind90 == 821 | ind90 == 822 | ind90 == 830 //no obs in DoD
replace sic3d = 806 if ind90 == 831
replace sic3d = 805 if ind90 == 832
replace sic3d = 809 if ind90 == 840 //most obs; 807
replace sic3d = 810 if ind90 == 841 //no obs in DoD
replace sic3d = 821 if ind90 == 842 //no obs in DoD
replace sic3d = 822 if ind90 == 850 //no obs in DoD
replace sic3d = 824 if ind90 == 851 //no obs in DoD
replace sic3d = 823 if ind90 == 852 //no obs in DoD
replace sic3d = 829 if ind90 == 860 //no obs in DoD
replace sic3d = 833 if ind90 == 861 
replace sic3d = 835 if ind90 == 862 | ind90 == 863 //no obs in DoD
replace sic3d = 836 if ind90 == 870 //no obs in DoD
replace sic3d = 832 if ind90 == 871 //no obs in DoD
replace sic3d = 840 if ind90 == 872 //no obs in DoD
replace sic3d = 863 if ind90 == 873 //no obs in DoD
replace sic3d = 866 if ind90 == 880 //no obs in DoD
replace sic3d = 861 if ind90 == 881 //no obs in DoD
replace sic3d = 871 if ind90 == 882 //no obs in DoD
replace sic3d = 872 if ind90 == 890 //no obs in DoD
replace sic3d = 873 if ind90 == 891 
replace sic3d = 874 if ind90 == 892 
replace sic3d = 899 if ind90 == 893 //no obs in DoD
replace sic3d = 911 if ind90 == 900 
replace sic3d = 919 if ind90 == 901 //no obs in DoD
replace sic3d = 920 if ind90 == 910 //most obs; 921 928
replace sic3d = 938 if ind90 == 921 //most obs; 934 939 
replace sic3d = 940 if ind90 == 922 //no obs in DoD
replace sic3d = 950 if ind90 == 930 //no obs in DoD
replace sic3d = 960 if ind90 == 931 //no obs in DoD
replace sic3d = 970 if ind90 == 932 //no obs in DoD

*cleaning the dataset after appending

// #
// keeping relevant years
*keep if year > 1973 & year < 1992

// #
//recode missing data for wages and salaries
*replace incwage =. if incwage == 9999999 | incwage == 9999998
replace hourwagetc =. if hourwagetc ==999.99
drop if hourwagetc==. 
drop if hourwagetc<0

// dropping missing values 
drop if jobn ==. | hourwagetc==. | year ==. //1,820,558 obs deleted
drop if jobn == 0 //117,583 obs deleted
drop if hourwagetc == 0 //154,546 obs deleted

// #
// generating new variable counting number of total employees
bys jobn region sic3d : gen totalnumempcps=_N

// Bottom code 
drop if hourwagetc<1

// #
// collapsing data
collapse (mean) hourwagetc [aw=earnwt], by (jobn year region sic3d totalnumempcps)

merge 1:1 jobn year region sic3d using created/cps/fullworkingcoll_ind_region_occ_year.dta

// #
// saving merged datasets
save created/cps/fullcpsmerged.dta, replace 


// exit
