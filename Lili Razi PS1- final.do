// Data Management - ps1//
* Lili Razi 

clear
import excel https://www2.census.gov/programs-surveys/demo/tables/p60/266/tableB-1.xls
drop in 1/5
rename A characteristic
rename B total2017
rename C belowpoverty2017
drop D 
rename E Percent2017
drop F 
rename G total2018
rename H belowpoverty2018
Rename J percent2018
drop L
drop m 
drop I 
drop K 
export delimited total2017 total2018 belowpoverty2017 belowpoverty2018 using "poverty20172018", replace
export excel total2017 belowpoverty2017 Percent2017 total2018 belowpoverty2018 using "poverty20172018"
outfile total2017 belowpoverty2017 Percent2017 total2018 belowpoverty2018 using "poverty20172018", replace
