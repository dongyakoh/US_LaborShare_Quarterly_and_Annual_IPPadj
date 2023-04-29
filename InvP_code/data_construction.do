clear
clear matrix
set more off,permanently


// SET A PATH TO A FOLDER WHERE DATA FILE IS STORED
cd ""


*-------------------------------------------------------------------------------  
*-------------------------------------------------------------------------------  
* STEP 1: IMPORT NIPA AND FAT DATA

// When expanding FAT annual data to quarterly, 
// we arbitrarily choose the annual value to represent Q4 of the year
local year_to_quarter q4

// FAT annual data goes upto 2021, the last date of our quarterly sample should be 
// 2021 + "year_to_quarter".
local last_date 2021q4


// IMPORT NIPA DATA
import excel "IPP_USLS_DATA_Q.xlsx", sheet("NIPA") cellrange(A1:R306) firstrow clear
gen quarter = quarterly(date, "YQ")
format quarter %tq
drop if quarter>tq(`last_date')
save nipa.dta, replace


// IMPORT FAT DATA AND CONVERT YEARLY DATA TO QUARTERLY DATA BY INTERPOLATION
import excel "IPP_USLS_DATA_Q.xlsx", sheet("FAT") cellrange(A1:W76) firstrow clear
tostring year, replace
gen qq = "`year_to_quarter'"
gen date = year + qq
gen quarter = quarterly(date, "YQ")
format quarter %tq
drop if quarter>tq(`last_date')
drop year qq date
tsset quarter
tsfill, full
foreach var of varlist _all{
	ipolate `var' quarter, generate(`var'_new)
	replace `var'_new = `var'_new
}
drop quarter_new
keep *_new quarter
rename *_new *
save fat.dta, replace


// MERGE ALL THE DATA
use nipa.dta, clear
merge 1:1 quarter using fat.dta, nogen

tsset quarter


*-------------------------------------------------------------------------------  
*-------------------------------------------------------------------------------  
* STEP 2: CONSTRUCTION OF PRICE OF CONSUMPTION

// COMPUTE CONSUMPTION SHARE
egen CONS_total = rsum(CONS_ND CONS_SV)
gen s_ND 		= CONS_ND/CONS_total
gen s_SV 		= CONS_SV/CONS_total

// PRICE INDEX FOR NONDURABLE AND SERVICES
gen P_ND 			= CONS_ND/QCONS_ND
gen P_SV 			= CONS_SV/QCONS_SV

// GROWTH RATE OF EACH PRICE INDEX
gen g_P_ND 	= (P_ND - P_ND[_n-1])/P_ND[_n-1]
gen g_P_SV 	= (P_SV - P_SV[_n-1])/P_SV[_n-1]

// GROWTH RATE OF CONSUMPTION PRICE (TORNQVIST)
gen g_Pc 	= g_P_ND*(s_ND + s_ND[_n-1])/2 + g_P_SV*(s_SV + s_SV[_n-1])/2

// CONSTRUCT INVESTMENT PRICE				  
gen Pc 	= exp(sum(log(1+g_Pc)))



*-------------------------------------------------------------------------------  
*-------------------------------------------------------------------------------  
* STEP 3: CONSTRUCT PRICE OF INVESTMENT

/*** AGGREGATE CAPITAL ***/
// DEPRECIATION OF CAPITAL
egen DPG_E  	= rsum(DEP_KP_EQ_Nres  DEP_KG_EQ_Nres	DEP_KP_EQ_Res 	DEP_KG_EQ_Res)
egen DPG_S  	= rsum(DEP_KP_ST_Nres  DEP_KG_ST_Nres	DEP_KP_ST_Res 	DEP_KG_ST_Res)
egen DPG_I  	= rsum(DEP_KP_IPP 	DEP_KG_IPP)
egen DPG_ES  	= rsum(DPG_E 	DPG_S DEP_CD)
egen DPG_ESI  	= rsum(DPG_E 	DPG_S 	DPG_I DEP_CD)

// CAPITAL STOCK
egen KPG_E   	= rsum(KP_EQ_Nres 	KG_EQ_Nres 	KP_EQ_Res KG_EQ_Res) 
egen KPG_S   	= rsum(KP_ST_Nres	KG_ST_Nres	KP_ST_Res KG_ST_Res) 
egen KPG_I   	= rsum(KP_IPP 		KG_IPP) 
egen KPG_ES   	= rsum(KPG_E 		KPG_S K_CD) 
egen KPG_ESI   	= rsum(KPG_E 		KPG_S 	KPG_I K_CD) 

// DEPRECIATION RATE
gen dPG_E 		= (DPG_E / KPG_E)/4
gen dPG_S 		= (DPG_S / KPG_S)/4
gen dPG_I 		= (DPG_I / KPG_I)/4
gen dPG_ES 		= (DPG_ES / KPG_ES)/4
gen dPG_ESI 	= (DPG_ESI / KPG_ESI)/4
gen dCD 		= (DEP_CD / K_CD)/4


// GROSS INVESTMENT
egen IPG_E 		= rsum(IP_EQ_Nres 	IG_EQ)
egen IPG_S 		= rsum(IP_ST_Nres 	IP_ST_Res 	IG_ST)
egen IPG_I 		= rsum(IP_IPP 		IG_IPP)
egen IPG_ES 	= rsum(IPG_S IPG_E)
egen IPG_ESI 	= rsum(IPG_S IPG_E IPG_I)



/*********** ISTC ***********/
// NOMINAL SHARES OF EACH INVESTMENT TYPE WITHOUT IPP
gen s_S_ES		= IPG_S / IPG_ES
gen s_E_ES		= IPG_E / IPG_ES	

// NOMINAL SHARES OF EACH INVESTMENT TYPE WITH ENTERTAINMENT
gen s_S_ESI		= IPG_S / IPG_ESI
gen s_E_ESI		= IPG_E / IPG_ESI	
gen s_I_ESI		= IPG_I / IPG_ESI

// PRICE INDEX FOR EACH INVESTMENT TYPE
gen P_ST 		= Pc			// PRICE INDEX FOR STRUCTURE (USE CONSUMPTION PRICE)
gen P_EQ_Nres	= OPI_EQ_Nres	// PRICE INDEX FOR NON-RESIDENTIAL EQUIPMENT
gen P_EQ_Res	= OPI_EQ_Res	// PRICE INDEX FOR RESIDENTIAL EQUIPMENT
gen P_IPP		= OPI_IPP		// PRICE INDEX FOR RESIDENTIAL EQUIPMENT

// GROWTH RATE OF PRICE INDEX FOR NON-RESIDENTIAL AND RESIDENTIAL EQUIPMENT
gen g_P_EQ_Nres	= (P_EQ_Nres - P_EQ_Nres[_n-1])/P_EQ_Nres[_n-1]
gen g_P_EQ_Res	= (P_EQ_Res - P_EQ_Res[_n-1])/P_EQ_Res[_n-1]

// NOMINAL SHARES OF NON-RESIDENTIAL AND RESIDENTIAL EQUIPMENT INVESTMENT
gen IP_EQ_TOTAL	= IP_EQ_Nres + IP_EQ_Res
gen s_EQ_Nres	= IP_EQ_Nres / IP_EQ_TOTAL
gen s_EQ_Res	= IP_EQ_Res / IP_EQ_TOTAL

// GROWTH RATE OF EQUIPMENT PRICE (TORNQUIST)
gen g_P_EQ_Nres_Res		= g_P_EQ_Nres*(s_EQ_Nres + s_EQ_Nres[_n-1])/2 + g_P_EQ_Res*(s_EQ_Res + s_EQ_Res[_n-1])/2
gen P_EQ 	= exp(sum(log(1+g_P_EQ_Nres_Res)))

// GROWTH RATE OF PRICE INDEX
gen g_P_S 		= (P_ST - P_ST[_n-1])/P_ST[_n-1]
gen g_P_E 		= (P_EQ - P_EQ[_n-1])/P_EQ[_n-1]
gen g_P_I		= (P_IPP - P_IPP[_n-1])/P_IPP[_n-1]

// GROWTH RATE OF INVESTMENT PRICE (TORNQUIST)
gen g_Pi_ES 	= g_P_S*(s_S_ES + s_S_ES[_n-1])/2 + g_P_E*(s_E_ES + s_E_ES[_n-1])/2

gen g_Pi_ESI 	= g_P_S*(s_S_ESI + s_S_ESI[_n-1])/2 + g_P_E*(s_E_ESI + s_E_ESI[_n-1])/2 + ///
				  g_P_I*(s_I_ESI + s_I_ESI[_n-1])/2

// CONSTRUCT INVESTMENT PRICE				  
gen Pi_ES 		= exp(sum(log(1+g_Pi_ES)))
gen Pi_ESI 		= exp(sum(log(1+g_Pi_ESI)))

// RELATIVE PRICE OF INVESTMENT
gen P_ES 		= Pi_ES / Pc
gen P_ESI 		= Pi_ESI / Pc

twoway 	(line P_ES quarter, lcolor(blue) lwidth(medthick)) ///
		(line P_ESI quarter, lcolor(red) lwidth(medthick)), ///
		scheme(s1color) ytitle("Price of Investment") ylabel(, labsize(medium) angle(90)) ///
	   xtitle("") xlabel(, labsize(medium) angle(90)) yline(1,lcolor(gs10)) ///
	   legend(symxsize(8) region(lwidth(none) fcolor(none)) pos(8) ring(0) col(1) size(medium) order(1 "Price of Investment without IPP" 2 "Price of Investment With IPP"))
graph export "InvP_quarterly.png", width(1400) height(1000) replace
