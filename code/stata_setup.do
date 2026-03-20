* *** Add required packages from SSC to this list ***
local ssc_packages "egenmore estout reghdfe require coefplot gtools binscatter addplot labutil strgroup cpigen _gwtmean ftools"
* *** Add required packages from SSC to this list ***

foreach pkg in `ssc_packages' {
	di "On `pkg'"
	cap n which `pkg'
	if _rc==111 {
		di "Not found. Installing `pkg'"
		ssc install `pkg', replace 
	}
}

* wordwrap 
net from https://mloeffler.github.io/stata/
net install wordwrap

* grc1leg (https://www.stata.com/statalist/archive/2003-06/msg00348.html)
net from http://www.stata.com
net cd users
net cd vwiggins
net install grc1leg

* egenmore 
ssc install egenmore 
