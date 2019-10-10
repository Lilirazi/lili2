* Data Management in Stata
*Lili Razi, Fall 2019
*PS2

* notes : 
clear         
set matsize 800 
version 15
set more off
*--------------------------------------------------------------------
*--------------------------------------------------------------------





**--- cleaning data 
// This is the poverty data 
// Trying to find out where my data has been stored
cd 
cd "E:\PhD\3. Fall semester 2019\3. Data Management\w6" //prof. Adam use your own dc
cd

// I am using poverty rate and want to clean the data first 
import excel https://www2.census.gov/programs-surveys/saipe/datasets/time-series/model-tables/allpovu.xls

edit
// C is county name, D is state name, E is 2007 poverty for all ages, AS in the povert rate for 2017 for all ages
keep C D E AS
keep if D=="NJ"
// the first line shows the state of NJ that we don't need 
drop in 1
// because we don't have name for these data we name them
rename C countynames
rename D statename
rename E poverty2007
rename AS poverty2017
//sum poverty2007 // this shows though we have data but since they are string valuable they won't show up as stats/numbers 

// we use replace because we don't need the string variable anymore
destring poverty2007, replace 
destring poverty2017, replace 
// we want to put them in order for later merge
sort countynames
// I generated a new column named id based on the numesr acending 
gen countyid=_n
// move the countyid to countynames
move countyid countynames
save povertynj20072017, replace
clear 
** my dc won't change by clear





**--- cleaning second data
// I am opening unemployment rate and want to merge it with the povertyrate 
import excel "https://www.ers.usda.gov/webdocs/DataFiles/48747/Unemployment.xls?v=9115.7?v=9115.7",clear
edit
describe
keep J AX B C
drop in 1/7
rename B state 
rename C area_name 
rename J unemprate2007
rename AX unemprate2017
keep if state=="NJ" //we use " " because this is string variable if this one was numver we don't need " " //
drop in 1
sort area_name
gen countyid=_n // this should be exactly the same name we used for the last file because they should merge//
move countyid area_name
save unemplymentratenj20072017, replace
clear




**----merge 
use povertynj20072017 // I am loading my previous file and merge it by the common tab countyid and use the second file of unemployment 
merge 1:1 countyid using unemplymentratenj20072017
// all have matched but because we later on want to merge other vaiables we have to get rid of _merge now so it won't crash later 
drop _merge
save pov_unemp_2007_2017 // this is the merged file







**---manipulate 
clear
use pov_unemp_2007_2017


//we create a new variable 
clonevar jersey_region=countyid
// every county in the south will go under 1 and others-meaning north counties will be 2
// because Atlantic and Bergen countyid is 1 and 2 respectively and are in south and north we don't label them in the next line
recode jersey_region (3 4 5 6 8 15 17=1)(7 9 10 11 12 13 14 16 18 19 20 21=2)

//  label means that you categorize the items like Iranian= reg_lab and we have two different names like Lili and Maryam = south and north 
// we want these names like lili and maryam go under Iranian, here in our case it will be reg_lab goes under jersey_region 
label define reg_lab 1 "south" 2 "north"
label values jersey_region reg_lab 

save, replace // we want ths file to be saved as pov_unemp_2007_2017--- no new file 





**--- collapse

// first finding average unemployment in 2017 and 2007
// average of the above is shown down  
sum unemprate2007 unemprate2017 
edit
// I want to find the average unemployment by region (north and south) 
//This divides the whole data in two lines and just shows the mean amount, we can't see counties list and their rate
collapse (mean) unemprate2007 (mean) unemprate2017, by (jersey_region)

tab unemprate2007
tab unemprate2017 

tab jersey_region unemprate2007 
tab jersey_region unemprate2017 

clear





*--- better way to collapse without losing our original data
clear
use pov_unemp_2007_2017

// all the below commands  from preserve to restore should run together to work
// we are creating a virtual space to manipulate data without deleting the original data 
// then we get the info that we need based on the north and south jersey cause first we divided them by collapse to get the info

preserve
collapse (mean) unemprate2007 (mean) unemprate2017, by (jersey_region)
tab jersey_region unemprate2007
tab jersey_region unemprate2017
restore




*----merging income 
clear
// download 2007 info file from: https://factfinder.census.gov/faces/tableservices/jsf/pages/productview.xhtml?pid=ACS_17_1YR_S1902&prodType=table
// replace the below address with your computer dc
import delimited "https://drive.google.com/file/d/1kjFBQPooZzY1HuIjfQW6vKpW-KQjOp1v/view?usp=sharing"
edit 
keep v3 v4
drop in 1/2
rename v3 county_names
rename v4 householdincome
destring householdincome, replace 
sort county_names
gen countyid=_n
move countyid county_names
save incomenj2007
clear

use pov_unemp_2007_2017
merge 1:1 countyid using incomenj2007
drop _merge
save pov_unemp_income_2007_2017

clear 

use pov_unemp_income_2007_2017
sum householdincome // the average income now is  149995.7 we can collapse data based on this
clonevar average_income=householdincome // we have cloned household income into new variable average income

preserve
collapse (mean) householdincome, by (jersey_region)
// we have jersey_region from previous saved file
tab jersey_region householdincome
restore




