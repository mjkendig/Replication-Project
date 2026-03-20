global controls lnnumemp lnN_in_occ lnnemp union office coworkjobq sicwacunion lnminwage
global desccontrols numemp lnnumemp N_in_occ lnN_in_occ nemp lnnemp union office coworkjobq sicwacunion minwage lnminwage
global controls_no_size union office coworkjobq sicwacunion lnminwage
global weight invrowwt

global stars 0
if ($stars==1) global starcode star(* 0.05  ** 0.01  *** 0.001)
if ($stars==0) global starcode nostar
