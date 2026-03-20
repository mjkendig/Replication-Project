* All MORG data from: https://data.nber.org/morg/annual/
* All CPS May data from: https://data.nber.org/cps-may/

log using code/C0_cps_scatter_runner.log, replace 

do code/cps_scatter/C1_morg_build.do
do code/cps_scatter/C2_fullworkingcoll.do
do code/cps_scatter/C3_new_cps.do // makes  fullcpsmerged.dta
do code/cps_scatter/C4_cpsscatter.do 

log close 
