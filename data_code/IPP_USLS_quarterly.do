clear
clear matrix
set more off,permanently


// SET A PATH TO A FOLDER WHERE DATA FILE IS STORED
cd ""


*-------------------------------------------------------------------------------  
*------------------------------------------------------------------------------- 
* IMPORT ANNUAL DATA AND CONVERT IT TO QUARTERLY
import excel "IPP_USLS_DATA_quarterly.xlsx", sheet("Annual") cellrange(A1:Z76) firstrow clear

sort Year
gen quarter = 4
gen year_quarter = yq(Year,quarter)
format year_quarter %tq
tsset year_quarter
drop Year quarter
tsfill

* LINEARLY INTERPOLATE TO CONVERT ANNUAL TO QUARTERLY
foreach var of varlist _all{
	ipolate `var' year_quarter, gen(`var'_q)
}
keep *_q
ren *_q *

* AGGREGATE CAPITAL
egen KP_ESI			= rsum(KP_EQ_Nres KP_ST_Nres KP_Res KP_IPP)
egen KG_ESI			= rsum(KG_EQ_Nres KG_ST_Nres KG_Res KG_IPP)
egen KP_ES			= rsum(KP_EQ_Nres KP_ST_Nres KP_Res)
egen KG_ES			= rsum(KG_EQ_Nres KG_ST_Nres KG_Res)
gen dep_CD 			= DEP_CD / CD

save quarterly_data, replace


*-------------------------------------------------------------------------------  
*------------------------------------------------------------------------------- 
* IMPORT QUARTERLY DATA
import excel "IPP_USLS_DATA_quarterly.xlsx", sheet("Quarterly") cellrange(A1:T304) firstrow clear
gen year_quarter = quarterly(date, "YQ")
format year_quarter %tq

* MERGE INTERPOLATED QUARTERLY DATA
merge 1:1 year_quarter using quarterly_data, nogen
erase quarterly_data.dta
drop date


* CONSTRUCT DIFFERENT DEFINITIONS OF LS
gen I_IPP 		= IP_IPP - I_NP_RD + DEP_NP_RD + DEP_KG_IPP

/*********** LS1 = CE/GDP ************/
gen LS0 		= CE/GNP
gen LS0_adj	 	= CE/(GNP - I_IPP)


/*********** LS2 = CE/(GDP - TAX + SUBSIDY) ************/
gen LS1 		= CE/(GNP - Tax + Sub)
gen LS1_adj  	= CE/(GNP - Tax + Sub - I_IPP)


/*********** LS3 = CE/(GDP - TAX + SUBSIDY - PI) ************/
gen LS2 		= CE/(GNP - Tax + Sub - PI)
gen LS2_adj  	= CE/(GNP - Tax + Sub - PI - I_IPP)


/*********** LS4: SOPHISTICATED LS = 1 - YK/Y ************/
gen UCI_ESI 	= RI + CP + NI + GE + (Tax - Sub - Exc_Tax - Sale_Tax) + BCTP + SDis
gen UI_ESI  	= UCI_ESI + CFC + CE
gen theta_ESI 	= (UCI_ESI + CFC) / UI_ESI
gen AI_ESI  	= PI + Exc_Tax + Sale_Tax
gen ACI_ESI  	= theta_ESI * AI_ESI
gen YKP_ESI    	= UCI_ESI + CFC + ACI_ESI
gen r_ESI 		= (YKP_ESI - CFC) / KP_ESI
gen YKD_ESI 	= (r_ESI + dep_CD)*CD
gen YKG_ESI 	= r_ESI*KG_ESI
gen YK_ESI		= YKP_ESI + YKD_ESI + YKG_ESI
gen GNP_ESI 	= GNP + YKD_ESI + YKG_ESI
gen LS3			= 1 - YK_ESI / GNP_ESI

gen r_ES 		= (YKP_ESI - CFC) / KP_ES
gen YKD_ES 		= (r_ES + dep_CD)*CD
gen YKG_ES 		= r_ES*KG_ES
gen YK_ES     	= YKP_ESI + YKD_ES + YKG_ES - I_IPP
gen GNP_ES 		= GNP + YKD_ES + YKG_ES - I_IPP
gen LS3_adj		= 1 - YK_ES / GNP_ES


/*********** LS5: CORPORATE LS = CE/(GDP - TAX + SUBSIDY) ************/
gen CLS1 		= CE_C/(GVA_C - TS_C)
gen CLS1_adj 	= CE_C/(GVA_C - TS_C - I_IPP_C)


/*********** LS6: CORPORATE Nonfinancial LS = CE/(GDP - TAX + SUBSIDY) ************/
gen CLS2 		= CE_NF/(GVA_NF - TS_NF)
gen CLS2_adj 	= CE_NF/(GVA_NF - TS_NF - I_IPP_NF)


*-------------------------------------------------------------------------------  
*------------------------------------------------------------------------------- 
* PLOT CURRENT LS WITH PRE-1999 REVISION ACCOUNTING LS

twoway (line LS0 year_quarter, 		lcolor(blue) lwidth(thick)) || ///
	   (lfit LS0 year_quarter, 		lcolor(blue) lwidth(thick) lpattern(dash)) || ///
	   (line LS0_adj year_quarter, 	lcolor(orange) lwidth(thick)) || ///
	   (lfit LS0_adj year_quarter, 	lcolor(orange) lwidth(thick) lpattern(dash)), ///	   
	   scheme(s1color) ytitle("Labor Share") ylabel(0.5(0.02)0.60, labsize(medium) angle(90)) ///
	   xtitle("") xlabel(, labsize(medium) angle(90)) ///
	   legend(symxsize(8) region(lwidth(none) fcolor(none)) pos(6) ring(0) col(1) size(medium) order(1 "BEA LS" 3 "Pre-1999 Revision Accounting LS"))
graph export "LS0_quarterly.png", width(1400) height(1000) replace


twoway (line LS1 year_quarter, 		lcolor(blue) lwidth(thick)) || ///
	   (lfit LS1 year_quarter, 		lcolor(blue) lwidth(thick) lpattern(dash)) || ///
	   (line LS1_adj year_quarter, 	lcolor(orange) lwidth(thick)) || ///
	   (lfit LS1_adj year_quarter, 	lcolor(orange) lwidth(thick) lpattern(dash)), ///	   
	   scheme(s1color) ytitle("Labor Share") ylabel(0.54(0.02)0.66, labsize(medium) angle(90)) ///
	   xtitle("") xlabel(, labsize(medium) angle(90)) ///
	   legend(symxsize(8) region(lwidth(none) fcolor(none)) pos(6) ring(0) col(1) size(medium) order(1 "BEA LS" 3 "Pre-1999 Revision Accounting LS"))
graph export "LS1_quarterly.png", width(1400) height(1000) replace


twoway (line LS2 year_quarter, 		lcolor(blue) lwidth(thick)) || ///
	   (lfit LS2 year_quarter, 		lcolor(blue) lwidth(thick) lpattern(dash)) || ///
	   (line LS2_adj year_quarter, 	lcolor(orange) lwidth(thick)) || ///
	   (lfit LS2_adj year_quarter, 	lcolor(orange) lwidth(thick) lpattern(dash)), ///	   
	   scheme(s1color) ytitle("Labor Share") ylabel(0.58(0.02)0.70, labsize(medium) angle(90)) ///
	   xtitle("") xlabel(, labsize(medium) angle(90)) ///
	   legend(symxsize(8) region(lwidth(none) fcolor(none)) pos(6) ring(0) col(1) size(medium) order(1 "BEA LS" 3 "Pre-1999 Revision Accounting LS"))
graph export "LS2_quarterly.png", width(1400) height(1000) replace


twoway (line LS3 year_quarter, 		lcolor(blue) lwidth(thick)) || ///
	   (lfit LS3 year_quarter, 		lcolor(blue) lwidth(thick) lpattern(dash)) || ///
	   (line LS3_adj year_quarter, 	lcolor(orange) lwidth(thick)) || ///
	   (lfit LS3_adj year_quarter, 	lcolor(orange) lwidth(thick) lpattern(dash)), ///	   
	   scheme(s1color) ytitle("Labor Share") ylabel(0.46(0.02)0.58, labsize(medium) angle(90)) ///
	   xtitle("") xlabel(, labsize(medium) angle(90)) ///
	   legend(symxsize(8) region(lwidth(none) fcolor(none)) pos(6) ring(0) col(1) size(medium) order(1 "BEA LS" 3 "Pre-1999 Revision Accounting LS"))
graph export "LS3_quarterly.png", width(1400) height(1000) replace


twoway (line CLS1 year_quarter, 		lcolor(blue) lwidth(thick)) || ///
	   (lfit CLS1 year_quarter, 		lcolor(blue) lwidth(thick) lpattern(dash)) || ///
	   (line CLS1_adj year_quarter, 	lcolor(orange) lwidth(thick)) || ///
	   (lfit CLS1_adj year_quarter, 	lcolor(orange) lwidth(thick) lpattern(dash)), ///	   
	   scheme(s1color) ytitle("Labor Share") ylabel(0.6(0.02)0.76, labsize(medium) angle(90)) ///
	   xtitle("") xlabel(, labsize(medium) angle(90)) ///
	   legend(symxsize(8) region(lwidth(none) fcolor(none)) pos(6) ring(0) col(1) size(medium) order(1 "BEA LS" 3 "Pre-1999 Revision Accounting LS"))
graph export "CLS1_quarterly.png", width(1400) height(1000) replace


twoway (line CLS2 year_quarter, 		lcolor(blue) lwidth(thick)) || ///
	   (lfit CLS2 year_quarter, 		lcolor(blue) lwidth(thick) lpattern(dash)) || ///
	   (line CLS2_adj year_quarter, 	lcolor(orange) lwidth(thick)) || ///
	   (lfit CLS2_adj year_quarter, 	lcolor(orange) lwidth(thick) lpattern(dash)), ///	   
	   scheme(s1color) ytitle("Labor Share") ylabel(0.62(0.02)0.76, labsize(medium) angle(90)) ///
	   xtitle("") xlabel(, labsize(medium) angle(90)) ///
	   legend(symxsize(8) region(lwidth(none) fcolor(none)) pos(6) ring(0) col(1) size(medium) order(1 "BEA LS" 3 "Pre-1999 Revision Accounting LS"))
graph export "CLS2_quarterly.png", width(1400) height(1000) replace


format LS* CLS* %6.3f
gen date = string(year_quarter, "%tq")

export excel date LS* CLS* using "US_LS.xlsx", sheet("Quarterly", replace) firstrow(variables) keepcellfmt
