* Clear all files from created/ and created/fwsd ************************
cd created 
local list : dir  "."     files "*"
foreach f of local list {
	display "Deleting `f'"
	erase "`f'"
}

cd fwsd 
local list2 : dir "." files "*"
foreach f of local list2 {
	display "Deleting `f'"
	erase "`f'"
}
cd ../../results
local list3 : dir "." files "*"
foreach f of local list3 {
	display "Deleting `f'"
	erase "`f'"
}
cd ..