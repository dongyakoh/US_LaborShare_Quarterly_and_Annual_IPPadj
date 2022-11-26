clear
clear matrix
set more off,permanently


// SET A PATH TO A FOLDER WHERE DATA FILE IS STORED
cd ""


*-------------------------------------------------------------------------------  
*------------------------------------------------------------------------------- 
* IMPORT QUARTERLY DATA
import excel "IPP_USLS_DATA_annual.xlsx", sheet("Annual") cellrange(A1:AT122) firstrow clear
ren date year
format year %ty

* AGGREGATE CAPITAL
egen KP_ESI			= rsum(KP_EQ_Nres KP_ST_Nres KP_Res KP_IPP)
egen KG_ESI			= rsum(KG_EQ_Nres KG_ST_Nres KG_Res KG_IPP)
egen KP_ES			= rsum(KP_EQ_Nres KP_ST_Nres KP_Res)
egen KG_ES			= rsum(KG_EQ_Nres KG_ST_Nres KG_Res)
gen dep_CD 			= DEP_CD / CD


* CONSTRUCT DIFFERENT DEFINITIONS OF LS
/*********** LS1 = CE/GDP ************/
gen I_IPP 		= IP_IPP - I_NP_RD + DEP_NP_RD + DEP_KG_IPP

gen LS1_ESI 	= CE/GNP
gen LS1_ES	 	= CE/(GNP - I_IPP)


/*********** LS2 = CE/(GDP - TAX + SUBSIDY) ************/
gen LS2_ESI 	= CE/(GNP - Tax + Sub)
gen LS2_ES  	= CE/(GNP - Tax + Sub - I_IPP)


/*********** LS3 = CE/(GDP - TAX + SUBSIDY - PI) ************/
gen LS3_ESI 	= CE/(GNP - Tax + Sub - PI)
gen LS3_ES  	= CE/(GNP - Tax + Sub - PI - I_IPP)


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
gen LS4_ESI		= 1 - YK_ESI / GNP_ESI

gen r_ES 		= (YKP_ESI - CFC) / KP_ES
gen YKD_ES 		= (r_ES + dep_CD)*CD
gen YKG_ES 		= r_ES*KG_ES
gen YK_ES     	= YKP_ESI + YKD_ES + YKG_ES - I_IPP
gen GNP_ES 		= GNP + YKD_ES + YKG_ES - I_IPP
gen LS4_ES		= 1 - YK_ES / GNP_ES


/*********** LS5: CORPORATE LS = CE/(GDP - TAX + SUBSIDY) ************/
gen LS5_ESI 	= CE_C/(GVA_C - TS_C)
gen LS5_ES 		= CE_C/(GVA_C - TS_C - I_IPP_C)


/*********** LS6: CORPORATE Nonfinancial LS = CE/(GDP - TAX + SUBSIDY) ************/
gen LS6_ESI 	= CE_NF/(GVA_NF - TS_NF)
gen LS6_ES 		= CE_NF/(GVA_NF - TS_NF - I_IPP_NF)


drop if year<1929 | year>2021
*-------------------------------------------------------------------------------  
*------------------------------------------------------------------------------- 
* PLOT CURRENT LS WITH PRE-1999 REVISION ACCOUNTING LS

twoway (line LS1_ESI year, 		lcolor(blue) lwidth(thick)) || ///
	   (lfit LS1_ESI year, 		lcolor(blue) lwidth(thick) lpattern(dash)) || ///
	   (line LS1_ES year, 		lcolor(orange) lwidth(thick)) || ///
	   (lfit LS1_ES year, 		lcolor(orange) lwidth(thick) lpattern(dash)), ///	   
	   scheme(s1color) ytitle("Labor Share") ylabel(0.5(0.02)0.6, labsize(medium) angle(90)) ///
	   xtitle("") xlabel(1929(3)2021, labsize(medium) angle(90)) ///
	   legend(symxsize(8) region(lwidth(none) fcolor(none)) pos(6) ring(0) col(1) size(medium) order(1 "BEA LS" 3 "Pre-1999 Revision Accounting LS"))
graph export "LS1_annual.png", width(1400) height(1000) replace


twoway (line LS2_ESI year, 		lcolor(blue) lwidth(thick)) || ///
	   (lfit LS2_ESI year, 		lcolor(blue) lwidth(thick) lpattern(dash)) || ///
	   (line LS2_ES year, 		lcolor(orange) lwidth(thick)) || ///
	   (lfit LS2_ES year, 		lcolor(orange) lwidth(thick) lpattern(dash)), ///	   
	   scheme(s1color) ytitle("Labor Share") ylabel(0.55(0.02)0.65, labsize(medium) angle(90)) ///
	   xtitle("") xlabel(1929(3)2021, labsize(medium) angle(90)) ///
	   legend(symxsize(8) region(lwidth(none) fcolor(none)) pos(6) ring(0) col(1) size(medium) order(1 "BEA LS" 3 "Pre-1999 Revision Accounting LS"))
graph export "LS2_annual.png", width(1400) height(1000) replace


twoway (line LS3_ESI year, 		lcolor(blue) lwidth(thick)) || ///
	   (lfit LS3_ESI year, 		lcolor(blue) lwidth(thick) lpattern(dash)) || ///
	   (line LS3_ES year, 		lcolor(orange) lwidth(thick)) || ///
	   (lfit LS3_ES year, 		lcolor(orange) lwidth(thick) lpattern(dash)), ///	   
	   scheme(s1color) ytitle("Labor Share") ylabel(0.6(0.02)0.7, labsize(medium) angle(90)) ///
	   xtitle("") xlabel(1929(3)2021, labsize(medium) angle(90)) ///
	   legend(symxsize(8) region(lwidth(none) fcolor(none)) pos(6) ring(0) col(1) size(medium) order(1 "BEA LS" 3 "Pre-1999 Revision Accounting LS"))
graph export "LS3_annual.png", width(1400) height(1000) replace


twoway (line LS4_ESI year, 		lcolor(blue) lwidth(thick)) || ///
	   (lfit LS4_ESI year, 		lcolor(blue) lwidth(thick) lpattern(dash)) || ///
	   (line LS4_ES year, 		lcolor(orange) lwidth(thick)) || ///
	   (lfit LS4_ES year, 		lcolor(orange) lwidth(thick) lpattern(dash)), ///	   
	   scheme(s1color) ytitle("Labor Share") ylabel(0.46(0.02)0.58, labsize(medium) angle(90)) ///
	   xtitle("") xlabel(1929(3)2021, labsize(medium) angle(90)) ///
	   legend(symxsize(8) region(lwidth(none) fcolor(none)) pos(6) ring(0) col(1) size(medium) order(1 "BEA LS" 3 "Pre-1999 Revision Accounting LS"))
graph export "LS4_annual.png", width(1400) height(1000) replace


twoway (line LS5_ESI year, 		lcolor(blue) lwidth(thick)) || ///
	   (lfit LS5_ESI year, 		lcolor(blue) lwidth(thick) lpattern(dash)) || ///
	   (line LS5_ES year, 		lcolor(orange) lwidth(thick)) || ///
	   (lfit LS5_ES year, 		lcolor(orange) lwidth(thick) lpattern(dash)), ///	   
	   scheme(s1color) ytitle("Labor Share") ylabel(0.62(0.04)0.78, labsize(medium) angle(90)) ///
	   xtitle("") xlabel(1929(3)2021, labsize(medium) angle(90)) ///
	   legend(symxsize(8) region(lwidth(none) fcolor(none)) pos(6) ring(0) col(1) size(medium) order(1 "BEA LS" 3 "Pre-1999 Revision Accounting LS"))
graph export "LS5_annual.png", width(1400) height(1000) replace


twoway (line LS6_ESI year, 		lcolor(blue) lwidth(thick)) || ///
	   (lfit LS6_ESI year, 		lcolor(blue) lwidth(thick) lpattern(dash)) || ///
	   (line LS6_ES year, 		lcolor(orange) lwidth(thick)) || ///
	   (lfit LS6_ES year, 		lcolor(orange) lwidth(thick) lpattern(dash)), ///	   
	   scheme(s1color) ytitle("Labor Share") ylabel(0.62(0.04)0.78, labsize(medium) angle(90)) ///
	   xtitle("") xlabel(1929(3)2021, labsize(medium) angle(90)) ///
	   legend(symxsize(8) region(lwidth(none) fcolor(none)) pos(6) ring(0) col(1) size(medium) order(1 "BEA LS" 3 "Pre-1999 Revision Accounting LS"))
graph export "LS6_annual.png", width(1400) height(1000) replace

format LS* %6.3f
export excel year LS* using "US_LS.xlsx", sheet("Annual", replace) firstrow(variables)
