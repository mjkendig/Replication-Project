global full_run 1

* Edit these for partial run or set full_run to 1
global cps_weight_build 0
global other_series 0
global main_build 1
global cps_scatter 0
global analysis	0
global event_study 0
global robust 0

set linesize 200 
/*
Notes:
--All needed files should be in 
repkit/ 
repkit/raw

Folders which should begin empty for the full run:
repkit/created 
repkit/results 
*/

global start_time = "${S_TIME}" 

*** Set directory to repkit **************************************
// cd "/Users/wilmers/Dropbox (MIT)/stata/firmocc/repkit"   
cd "C:/Users/Matthew/OneDrive/Desktop/Replication"

******************************************************************
if ($full_run) do code/clear_folders 
************************************************************************

* Install needed Stata packages
do code/stata_setup.do 

* Define globals 
do code/set_parameters.do

if ($cps_weight_build | $full_run)  do code/cps_weight_build.do
if ($other_series     | $full_run)  do code/other_series.do
if ($main_build | $full_run)        do code/build.do
if ($cps_scatter | $full_run)       do code/cps_scatter/C0_cps_scatter_runner.do 
if ($analysis | $full_run)          do code/analysis_econ_r1.do
if ($event_study | $full_run)       do code/event_study.do
if ($robust | $full_run)            do code/robust_econ_r1.do

display "Start time: $start_time" 
display "End time: ${S_TIME}"       
