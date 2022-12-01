
*THIS DO FILE DOES THE FOLLOWING: 
*(1) cleans/asseses phase 2 non-public prelim 100 data for CEI, SDP, and CEI F/U for BF, KE, and NG
*(2) creates analytical variables - similar to those from PMA_QoC_Outcome.do as much as possible
*(3) analysis 
			
* Table of Contents
* 	A. SETTING 
* 	B. DATA PREP 
*		SDP, CQ, and CQ follow up data are all prelim, accessed via the dropbox link from Aisha
* 		Theses datafiles are saved in different directory: ~/Dropbox/0Data/PMA/PMA_prelim100/
*		- SDP datasets are re-recoded using YJ's PMA recode code. (B.1)
*		- CQ and CQ follow up data are cleaned/processed here		 		
		*** B.1. Take care of SDP files 
		*** B.2. Bring CR Prelim 100 data to the folder  
		*** B.3A. RENAME CR var names to names in PHASE 1 BASELINE PUBLIC FILES 
		*** B.3. Gen var for CR (constructed variables start with y)
		*** B.4. Gen var for CR_follow up (constructed variables start with yy, given variables now begin with "pf")
		*** B.5. MERGE 
		*** B.5.A. More gen var that require both baseline and fololw up data
		*** B.5.B. Create analytical weight for LTFU  - N/A for this study
		*** B.6. APPEND ALL SURVEYS
* 	C. ANALYSIS: survey level descriptive 
* 	D. ANALYSIS: multivariate regression 

* 	E. TABLE FOR SANKEY DIAGRAM 

clear
clear matrix
clear mata
capture log close
set more off
numlabel, add

*set scheme s1color

************************************************************************y
* A. SETTING 
************************************************************************

cd "~/Dropbox/0iSquared/iSquared_PMA/PMA_QoC_Followup/"
global dataprelim 	"~/Dropbox/0Data/PMA/PMA_prelim100/"
global data			"~/Dropbox/0Data/PMA/"
global dataanalysis			"~/Dropbox/0iSquared/iSquared_PMA/PMA_QoC_Followup/Data/"
	
local today=c(current_date)
local c_today= "`today'"
global date=subinstr("`c_today'", " ", "",.)

#delimit;
global surveylist " 
	BFP2 KEP2 NGKanoP2 NGLagosP2 
	";
	#delimit cr

*
************************************************************************
* B. DATA PREP: 
************************************************************************

***
*** B.1. Take care of SDP and CEI files 
********* by running country-specific createPMA_SR_***.do first AND the general createPMA_SR.do
********* for CEI, just run one general createPMA_CR.do
********* THESE DO FILES ARE AVAILABLE HERE: https://github.com/yoonjoung/PMA_recode
********* SAVE DO FILES AND SDP FILES IN A SAME DIRECTORY 
********* BUT ALSO SAVE THEM IN THE SHARED DROPBOX FOLDER, DTAANALYSIS, SO THAT CELIA CAN RUN THIS FILE EASILY 
***
{
*
cd "~/Dropbox/0Data/PMA/"

		do createPMA_SR_BurkinaFaso.do
		do createPMA_SR_CotedIvoire.do
		do createPMA_SR_DRC.do
		do createPMA_SR_Ethiopia.do     
		do createPMA_SR_India.do
		do createPMA_SR_Kenya.do
		do createPMA_SR_Niger.do
		do createPMA_SR_Nigeria.do
		do createPMA_SR_Uganda.do 
		
		do createPMA_SR.do /*this is a cross-survey program*/
		
		do createPMA_CR.do /*this is a cross-survey program for CEI baseline and endline*/
		
*SAVE THEM ALSO IN THE SHARED DROPBOX FOLDER, DTAANALYSIS, SO THAT CELIA CAN RUN THIS FILE TOO		

global surveylist "BFP2 KEP2 NGKanoP2 NGLagosP2"

	set more off
	foreach survey in $surveylist{
		use "$data/SR_`survey'.dta", clear		
		save  "$dataanalysis/SR_`survey'.dta", replace
		
		use "$data/CR_`survey'.dta", clear		
		save  "$dataanalysis/CR_`survey'.dta", replace

		use "$data/CRFU_`survey'.dta", clear		
		save  "$dataanalysis/CRFU_`survey'.dta", replace
	}

cd "~/Dropbox/0iSquared/iSquared_PMA/PMA_QoC_followup/"

*/
}

***
*** B.3A. RENAME CR var names to names in PHASE 1 BASELINE PUBLIC FILES 
***
{	
set more off
foreach survey in $surveylist{	
	
	use "$dataanalysis/CR_`survey'.dta", clear	

	* 0. Argh, standardize variable names /*India and Uganda has different var name!*/
	
		* CEI_result
		lookfor result 
		capture confirm variable cei_result
			if !_rc {
			rename cei_result CEI_result
			}	
		
		* visit_reason_fp
		lookfor reason 
		capture confirm variable visit_reason_fp
			if !_rc {
			codebook visit_reason_fp
			}
		capture confirm variable fp_reason_yn
			if !_rc {
			tab country, m
			codebook fp_reason_yn
			rename fp_reason_yn visit_reason_fp
			}
	
		* visit_fp_given
		lookfor given 
		capture confirm variable fp_given
			if !_rc {
			codebook fp_given
			}
		capture confirm variable whatgiven_today 
			if !_rc {
			tab country, m
			codebook whatgiven_today 
			rename whatgiven_today  fp_given
			}	
			
		* hh_wealth_selfrank
		lookfor given 
		capture confirm variable hh_wealth_selfrank
			if !_rc {
			codebook hh_wealth_selfrank
			}
		capture confirm variable hh_location_ladder 
			if !_rc {
			tab country, m
			codebook hh_location_ladder 
			rename hh_location_ladder hh_wealth_selfrank
			}	

		* mtd_before
		lookfor before
		capture confirm variable mtd_before
			if !_rc {
			codebook mtd_before
			}
		capture confirm variable switch_method
			if !_rc {
			tab country, m
			codebook switch_method
			rename switch_method mtd_before
			}	
			
		* fp_given_type
		capture confirm variable fp_given_type
			if !_rc {
			codebook fp_given_type
			}
		capture confirm variable method_prescribed
			if !_rc {
			tab country, m
			codebook method_prescribed
			rename method_prescribed fp_given_type
			}				
			
		* pill and injectables specific counseling 
		capture confirm variable pill_counsel
			if !_rc {
			tab country, m
			rename pill_counsel prov_pill_couns
			}	
		capture confirm variable inj_counsel
			if !_rc {
			tab country, m
			rename inj_counsel prov_inj_couns
			}		
		
		* explain variables 
		capture confirm variable explain_method
			if !_rc {
			tab country, m
			rename explain_method explain_mtd
			}			
		capture confirm variable explain_side_effects
			if !_rc {
			tab country, m
			rename explain_side_effects explain_se
			}		
		capture confirm variable explain_problems
			if !_rc {
			tab country, m
			rename explain_problems explain_se_todo
			}		
		capture confirm variable explain_follow_up
			if !_rc {
			tab country, m
			rename explain_follow_up explain_fu
			}	
			
		* discuss variables 
		capture confirm variable discuss_other_fp 
			if !_rc {
			tab country, m
			rename discuss_other_fp disc_other_fp
			}			
		capture confirm variable discuss_hiv 
			if !_rc {
			tab country, m
			rename discuss_hiv disc_hiv
			}		
		capture confirm variable discuss_fp_prefs 
			if !_rc {
			tab country, m
			rename discuss_fp_prefs disc_fp_desired  
			}		
		capture confirm variable discuss_switch 
			if !_rc {
			tab country, m
			rename discuss_switch disc_fp_switch 
			}					
		capture confirm variable discuss_pro_con_delay 
			if !_rc {
			tab country, m
			rename discuss_pro_con_delay disc_mtd_pro_con 
			}	
		
		* Communications 
		capture confirm variable howclear_fp_info
			if !_rc {
			tab country, m
			rename howclear_fp_info fp_info_clarity
			}	
		capture confirm variable allow_question
			if !_rc {
			tab country, m
			rename allow_question prov_alllow_que
			}				
		capture confirm variable understand_answer
			if !_rc {
			tab country, m
			rename understand_answer understand_ans
			}									

		* experience 			
		capture confirm variable how_staff_treat
			if !_rc {
			tab country, m
			rename how_staff_treat staff_polite
			}					
		capture confirm variable time_wait_m
			if !_rc {
			tab country, m
			rename time_wait_m hf_wait_m
			}			
		capture confirm variable time_wait_h
			if !_rc {
			tab country, m
			rename time_wait_h hf_wait_h
			}			
						
		capture confirm variable satisfied_services_today
			if !_rc {
			tab country, m
			rename satisfied_services_today service_satisfied
			}	
		capture confirm variable return_to_facility 
			if !_rc {
			tab country, m
			rename return_to_facility return_hf
			}				

	
	save "$dataanalysis/CR_`survey'.dta", replace
	}
}
***
*** B.3. Gen var for CR 
***
	
	******************************************
	* Basic background characteristics 
	******************************************
/*
set more off
foreach survey in $surveylist{	
use "$dataanalysis/CR_`survey'.dta", clear	
	tab today xsurvey
}
*/	
	
/*
set more off
foreach survey in $surveylist{	
use "$dataanalysis/CR_`survey'.dta", clear	
	tab xsurvey
	codebook fp_given_type if fp_given_type<10
	codebook fp_given_type if fp_given_type>=10
}
*/	
set more off
foreach survey in $surveylist{	
use "$dataanalysis/CR_`survey'.dta", clear	

	codebook metainstanceID
	*rename metainstanceID client_ID
	
	foreach var of varlist  age marital_status school hh_wealth_selfrank  visit_reason_fp{
		replace `var'=. if `var'<0
		}	
	
		gen byte yfpclient=visit_reason_fp==1
	
	keep if yfpclient==1
	
		gen yage=age
		egen yagegroup5 = cut(age), at(15,20,25,30,35,40,45,50)
		egen yagegroup10 = cut(age), at(15,20,30,40,50)
		tab yagegroup10, gen(yagegroup10_)
		
		gen byte yhhladder=hh_wealth_selfrank 
		*gen byte xurban=ur==1
		
		gen byte yunion=marital_status==1 | marital_status==2
		
			foreach var of varlist yunion{
			replace `var' =. if marital_status==. | marital_status<0
			}	
			
		gen yedu_never	=0 
		gen yedu_pri	=0
		gen yedu_sec	=0
		gen yedu_col	=0

			replace country = "Burkina Faso" if country=="Burkina"
			
			replace yedu_never	=1 if country=="Burkina Faso" & school==1
			replace yedu_pri	=1 if country=="Burkina Faso" & school==2
			replace yedu_sec	=1 if country=="Burkina Faso" & (school==3 | school==4)
			replace yedu_col	=1 if country=="Burkina Faso" & (school==5)			
						
			replace yedu_never	=1 if country=="Kenya" & school==1
			replace yedu_pri	=1 if country=="Kenya" & school==2
			replace yedu_sec	=1 if country=="Kenya" & (school==3 | school==4)
			replace yedu_col	=1 if country=="Kenya" & (school==5 | school==6)
			
			replace yedu_never	=1 if country=="Nigeria" & school==0
			replace yedu_pri	=1 if country=="Nigeria" & school==1
			replace yedu_sec	=1 if country=="Nigeria" & school==2
			replace yedu_col	=1 if country=="Nigeria" & school==3
						
			foreach var of varlist yedu_*{
			replace `var' =. if school==. | school<0
			}	
			
		gen byte yedu4=. 
			replace yedu4=0 if yedu_never==1
			replace yedu4=1 if yedu_pri==1
			replace yedu4=2 if yedu_sec==1			
			replace yedu4=3 if yedu_col==1	
		lab define yedu4 0"none" 1"primary" 2"secondary" 3"college+"
		lab values yedu4 yedu4

		gen byte yedu_pri_more = yedu4>= 1 & yedu4!=.
		gen byte yedu_sec_more = yedu4>= 2 & yedu4!=.
		
		gen byte yhhladder5=yhhladder>=5
			replace yhhladder5=. if yhhladder==. 
		gen byte yhhladder6=yhhladder>=6
			replace yhhladder6=. if yhhladder==. 			
						
		tab mtd_before fp_given, m	
		*Problem: previous methods asked to only those who received method/prescription 		
		gen byte ynewuser= mtd_before==0
		gen byte ynewmethod= mtd_before==2
		gen byte ynew= mtd_before==2 | mtd_before==0		
			foreach var of varlist ynew*{
			replace `var' =. if mtd_before==.
			}	
		
		gen ynew_neither=ynewuser==0 & ynewmethod==0
		gen ynew_user=ynewuser==1 & ynewmethod==0
		gen ynew_method=ynewuser==0 & ynewmethod==1
		
		/*	
		gen temp = dofc(FQdoi_correctedSIF)
		format %td temp
		gen tempmonth = month(temp)
		gen tempyear = year(temp)
		gen tempcmc 	= 12*(tempyear - 1900) + tempmonth
		*/
		
		gen tempyear  = substr(today, 1, 4)
		gen tempmonth = substr(today, 6, 2)
		destring tempmonth, replace
		destring tempyear, replace
		gen tempcmc 	= 12*(tempyear - 1900) + tempmonth

		egen cmc = median(tempcmc)
		egen year= mode(tempyear)
			drop temp*	
			
		lab var yage "client's age at interview" 
		lab var yagegroup10 "client's age at interview, 10-year group" 		
		lab var yagegroup5 "client's age at interview, 5-year group" 		
		lab var yhhladder "HH percceived economic ladder"
		lab var yhhladder5 "HH percceived economic ladder 5 or higher"

		lab var ynewuser "not using any methods just before the visit"
		lab var ynewmethod "using methods just before the visit, but different from method received/prescribed"
		lab var ynew "not using the method received/prescribed just before the visit"
		
		lab var yedu4 "4-category education ever attended"
		lab var yedu_pri_more "education primary or higher"
		lab var yedu_sec_more "education secondary or higher"
		lab var yedu_never "none"
		lab var yedu_pri "primary"
		lab var yedu_sec "secondary"
		lab var yedu_col "college+"
		
		lab var cmc "Interviw date in CMC, median per survey round"
		lab var year "Interviw year, mode per survey round"
			
	******************************************
	* FP methods received 
	******************************************
		
		*gen byte dpsp = country =="Burkina Faso" | country =="DRC" | country=="Nigeria" | country=="Uganda" 
		/*
		set more off
		foreach survey in $surveylist{	
			
			use "$dataanalysis/CR_`survey'.dta", clear	
			
			tab fp_given_type xsurvey, m
			codebook fp_given_type
			codebook fp_given_type if fp_given_type>=7
			}
		*/

		replace fp_given_type=. if fp_given_type<0
	
		gen ygiven_method = fp_given==1
		gen ygiven_prescription = fp_given==2
		gen ygiven_none = fp_given==3
		
		gen yeligible = ygiven_none==0
		
		gen ymethod_fster	  = fp_given_type==1
		gen ymethod_mster	  = fp_given_type==2
		gen ymethod_impl	  = fp_given_type==3
		gen ymethod_iud	  	  = fp_given_type==4
		gen ymethod_inj		  = fp_given_type==5
		
		gen ymethod_pill	  = fp_given_type==7
		gen ymethod_ec	  	  = fp_given_type==8
		gen ymethod_mcondom	  = fp_given_type==9		
		gen ymethod_fcondom	  = fp_given_type==10
		
		gen ymethod_diaph	  = fp_given_type==11
		gen ymethod_sdm	  = fp_given_type==13
		gen ymethod_lam	  = fp_given_type==14
		
		gen ymethod__st	  = ymethod_fster==1 | ymethod_mster==1 
		lab var ymethod__st "Sterilizatoin"
		
		gen ymethod__LARC	  = ymethod_impl==1 | ymethod_iud==1 
		lab var ymethod__LARC "LARC"

		gen ymethod__LARCPM	  = ymethod__LARC==1 | ymethod__st==1 
		lab var ymethod__LARCPM "LARC or Sterilization"

		gen ymethod__omodern = ymethod_fcondom==1 | ymethod_diaph==1 | ymethod_sdm==1 | ymethod_lam==1 
		lab var ymethod__omodern "other modern methods"				
		
		gen ymethod__trad	  = fp_given_type>=30 & fp_given_type!=.
		lab var ymethod__trad "traditional methods"		
						
		gen ymethod__none	  = fp_given_type==.
		lab var ymethod__none "no method: those who did not receive methods or prescription"
		
		rename fp_given_type ymethod
		
		****************************************************** ARGH BF code problem! 
		/*
		foreach var of varlist ymethod_*{
			replace `var'=0 if country=="Burkina" 
			}
		*/

save "$dataanalysis/CR_`survey'.dta", replace 	
}	

	******************************************
	* QoC indicators 
	******************************************

foreach survey in $surveylist{
use "$dataanalysis/CR_`survey'.dta", clear	

		* QCC 4-scale **********
		
		sum qcc_info_*
		sum qcc_interp_*
		sum qcc_disresp_*
		sum qcc_counsel_*
		
		sum qcc_info_* qcc_interp_* qcc_disresp_*
		bysort xsurvey: alpha qcc_info_* qcc_interp_* qcc_disresp_*

		codebook qcc_info_personal
		
		* OMG CODE IS IN OPPOSITE DIRECTIONS BETWEEN THE Q AND DATA!!!!!!!!!!!!
		* CHANGE TO FOLLOW PAPER Q - I.E., COMPLETELY AGREE ==4 
		foreach var of varlist qcc_info_* qcc_interp_* qcc_disresp_* {
			recode `var' 1=4 2=3 3=2 4=1
			}
		
		gen qcc_resp_pressure = qcc_disresp_pressure 
		gen qcc_resp_marital = qcc_disresp_marital
		
			recode qcc_resp_pressure 1=4 2=3 3=2 4=1
			recode qcc_resp_marital 1=4 2=3 3=2 4=1
			
			tab qcc_resp_pressure qcc_disresp_pressure, m
			tab qcc_resp_marital qcc_disresp_marital, m
		
		foreach var of varlist qcc_*{
			replace `var'=. if `var'<0
			}
			
		sum qcc_info_* qcc_interp_* qcc_resp_* 
						
		pca qcc_info_* qcc_interp_* qcc_resp_* 
		predict qcc__score
		xtile qcc__score5 = qcc__score, nq(5) 
		xtile qcc__score3 = qcc__score, nq(3) 
		
		tab qcc__score3, gen(qcc__score3_)
		tab qcc__score5, gen(qcc__score5_)
		
		/*
		pca qcc_info_* qcc_interp_* qcc_disresp_* 
		predict qcc__score2
		corr qcc__score qcc__score2
		*NOTE: confirm score 1 and score 2 are identical. 
		*/
		
		capture drop qcc__mean
		egen qcc__mean=rowtotal(qcc_info_* qcc_interp_* qcc_resp_*)
			replace qcc__mean=qcc__mean/10
			
		xtile qcc__mean5 = qcc__mean, nq(5) 
		xtile qcc__mean3 = qcc__mean, nq(3) 
		
		capture drop temp
		egen qcc__meaninformation=rowtotal(qcc_info_*)
			replace qcc__meaninformation =qcc__meaninformation/5
				
		capture drop temp
		egen qcc__meaninteraction=rowtotal(qcc_interp_* qcc_resp_*)
			replace qcc__meaninteraction =qcc__meaninteraction/5
		
		* 2021/10/26 make sure to use only cases where women responded to all 10 questions! 
		foreach var of varlist qcc__mean*{
			replace `var'=. if qcc__score==.
			}
	
		* QCC binary **********
					
		foreach var of varlist qcc_info_* qcc_interp_* qcc_resp_* qcc_disresp_*{
			gen byte q`var'=`var'==4
			replace  q`var'=. if `var'==.
			tab q`var' `var', m
			}

		pca qqcc_info_* qqcc_interp_* qqcc_resp_* 
		predict qqcc__score
		xtile qqcc__score5 = qqcc__score, nq(5) 
		xtile qqcc__score3 = qqcc__score, nq(3) 
		
		egen qqcc__mean=rowtotal(qqcc_info_* qqcc_interp_* qqcc_resp_* )
			replace qqcc__mean=qqcc__mean/10
		xtile qqcc__mean5 = qqcc__mean, nq(5) 
		xtile qqcc__mean3 = qqcc__mean, nq(3)		
		
		tab qqcc__score3, gen(qqcc__score3_)
		tab qqcc__score5, gen(qqcc__score5_)
		
		capture drop temp
		egen qqcc__meaninformation=rowtotal(qqcc_info_*)
			replace qqcc__meaninformation =qqcc__meaninformation/5
				
		capture drop temp
		egen qqcc__meaninteraction=rowtotal(qqcc_interp_* qqcc_resp_*)
			replace qqcc__meaninteraction =qqcc__meaninteraction/5		
	
		* 2021/10/26 make sure to use only cases where women responded to all 10 questions! 
		foreach var of varlist qqcc__mean*{
			replace `var'=. if qqcc__score==.
			}
			
		* QCC FROM PHASE 1 ANALYSIS **********
		
		/*
		explain_mtd - explain_fu
		disc_other_fp - disc_mtd_pro_con 
		*/
		
		#delimit;
		foreach var of varlist 
				fp_obtain_desired fp_obtain_desired_whynot
				prov_pill_couns prov_inj_couns
				service_satisfied refer_hf return_hf
				{;
				#delimit cr
			replace `var'=. if `var'<0
			}

		* overall outcome				
		gen byte ywant= fp_obtain_desired==1 | fp_obtain_desired==3
		gen byte yrecommend= fp_obtain_desired_whynot>=4 & fp_obtain_desired_whynot<=6
			replace yrecommend=. if fp_obtain_desired!=2 
		gen byte ywantrec= ywant==1 | yrecommend==1
		
		* technical: counseling  
		gen byte ycounsel_pill=prov_pill_couns==1
			replace ycounsel_pill=. if ymethod_pill!=1 
		gen byte ycounsel_inj=prov_inj_couns==1
			replace ycounsel_inj=. if ymethod_inj!=1
		gen byte ycounsel=prov_pill_couns==1 |  prov_inj_couns==1
			replace ycounsel=. if (ymethod_pill!=1 & ymethod_inj!=1)
				
		* experiential 
		gen byte ywait15=hf_wait_m>15
		gen byte ywait30=hf_wait_m>30
		gen byte ywait60=hf_wait_m>60
		gen byte ywait_onehour=hf_wait_h>1
		
		* Outcome 
		gen ysatisfied5	=service_satisfied
		tab ysatisfied5, gen(ysatisfied5_)

		gen byte ysatisfiedvery	=service_satisfied==1
		gen byte ysatisfied		=service_satisfied<=2
		gen byte yrefer			=refer_hf==1
		gen byte yreturn		=return_hf==1	
		gen byte yreferreturn	=yrefer==1 & yreturn==1
			
		lab var ywant 			"received initially wanted method" 
		lab var yrecommend 		"did not receive initially wanted method because of three potentially acceptable reasons"
		lab var ywantrec 		"received initially wanted method OR did not because of three potentially acceptable reasons" 
		
		lab var ycounsel 		"pill/injectables specific counseling on pregnancy chance if not taken correctly"
		*lab var ydisc_procon 	"discussed advantage/disadvantage of her method"
		*lab var ymii_score 		"technical counseling score about informed choice (0-9)"
		
		*lab var ycommunication_all 	"clear, allowed question, and understandable"
		lab var ywait15			"waited more than 15 minutes"
		lab var ywait30			"waited more than 30 minutes"
		lab var ywait60			"waited more than 60 minutes"
		lab var ywait_onehour	"waited more than one hour (based on hour reporting)"
		
		lab var ysatisfiedvery		"very satisfied"
		lab var ysatisfied			"satisfied or very satisfied"		
		lab var yrefer			"would refer friends/relatives"
		lab var yreturn			"would return"		
		lab var yreferreturn	"would refer AND return"
		
save "$dataanalysis/CR_`survey'.dta", replace 	
}	

	******************************************
	* Follow up variables  
	******************************************
foreach survey in $surveylist{
use "$dataanalysis/CR_`survey'.dta", clear	
	
	gen byte ypfwilling = fu_agree==1
	gen byte yphone = fu_phone==1
	tab xsurvey
	sum ypfwilling yphone 
	
save "$dataanalysis/CR_`survey'.dta", replace 	
}	

***
*** B.4. Gen var for CR_follow up 
***

set more off
foreach survey in $surveylist{	
use "$dataanalysis/CRFU_`survey'.dta", clear	
			
			sum correct_person call_consent CEI_result 
			/*in the public data, no variation in these variables...*/
			*gen yycontact = correct_person==1
			*gen yyconsent = call_consent==1
			gen yycomplete= CEI_result==1
				
		keep CQmetainstanceID metainstanceID yy* todaySIF
		
		rename todaySIF todaySIFpf

		capture drop _merge
			
		sort CQmetainstanceID
		
save "$dataanalysis/CRFU_`survey'.dta", replace 		
}

***
*** B.5. MERGE 
***

*** Prep SR
set more off
foreach survey in $surveylist{
use "$dataanalysis/SR_`survey'.dta", clear
	tab xsurvey, m

	*tostring(facility_ID), replace
	sort facility_ID
save  "$dataanalysis/SR_`survey'.dta", replace
}

*** Merge CR & SR

set more off
foreach survey in $surveylist{
use "$dataanalysis/CR_`survey'.dta", clear

			capture drop _merge	
			sort facility_ID
			
		merge facility_ID using "$dataanalysis/SR_`survey'.dta", keep(essential* SDP* xsurvey)
			
			tab _merge xsurvey, m
			rename _merge merge_crsr /*merge results for CR-SR merge*/
										
		*drop if merge_sdp==1 /*DROP CEIs that did not have SDPs - NONE*/	
		*drop if merge_sdp==2 /*DROP SDPs that did not have CEI*/
				
save "$dataanalysis/CRSR_`survey'.dta", replace 	
}	

*** Merge CRSR & CRFU

set more off
foreach survey in $surveylist{
use "$dataanalysis/CRSR_`survey'.dta", clear
		
			capture drop _merge
			
			rename metainstanceID CQmetainstanceID 
			sort CQmetainstanceID
			
		merge CQmetainstanceID using "$dataanalysis/CRFU_`survey'.dta", keep(yy* today*)
		
			tab _merge xsurvey, col
			rename _merge merge_pf /*merge results for baseline-follow up merge*/
		
		*drop if merge_pf==2			
		gen yypf=merge_pf==3
					
save "$dataanalysis/CRSRFU_`survey'.dta", replace 	
}	

*** Document/summarize merge results 

set more off
foreach survey in $surveylist{
use "$dataanalysis/CRSRFU_`survey'.dta", clear
		
	tab xsurvey
	tab merge_*, m
		
		gen mresult_sdpnocei = 1 if merge_crsr==2 /*SDPs that did not have CEI*/
		gen mresult_ceifuunknown = 1 if merge_pf==2 /*CRFU that could not be linked to baseline*/
		
		gen byte ceifu = yycomplete==1 

	tab ceifu, m
		
save "$dataanalysis/CRSRFU_`survey'.dta", replace 	
}

***
*** B.5.A GENERATE VARIABLES THAT REQUIRE BOTH BASELINE AND FOLLOW UP DATA
***

set more off
foreach survey in $surveylist{
use "$dataanalysis/CRSRFU_`survey'.dta", clear

		*** create the interval in days ***
		codebook todaySIF*
		
		gen interval = todaySIFpf - todaySIF
		bysort merge_pf: sum interval today*
	
save "$dataanalysis/CRSRFU_`survey'.dta", replace 		
}

***
*** B.5.B Create analytical weight for LTFU 
***

*Not relevant for this analysis, 
* 	since we assess baseline measures (which should not have any weight)
*	by follow up status. 
	
***
*** B.6. APPEND ALL SURVEYS
***	
use "$dataanalysis/CRSRFU_BFP2.dta", clear 
	append using "$dataanalysis/CRSRFU_KEP2.dta", force
	append using "$dataanalysis/CRSRFU_NGLagosP2.dta", force
	append using "$dataanalysis/CRSRFU_NGKanoP2.dta", force 	
	
	drop if merge_crsr==2 /*DROP SDPs that do not have CEI */
	drop if merge_pf==2 /*DROP CR that we cannot link with baseline */
	
		tab yeligible yycomplete, m
		
		bysort yeligible: sum yeligible yycomplete ceifu 

		foreach var of varlist yycomplete  {
			replace `var' = 0 if `var'==. & yeligible==0
			replace `var' = 0 if `var'==. & yeligible==1
			}			
			
		bysort yeligible: sum yeligible yycomplete ceifu   
	
	tab yeligible yypf, m	

	gen obs=1
		
save CRall_allsurveys.dta, replace

use "$dataanalysis/CRSRFU_BFP2.dta", clear 
	append using "$dataanalysis/CRSRFU_KEP2.dta", force
	append using "$dataanalysis/CRSRFU_NGLagosP2.dta", force
	append using "$dataanalysis/CRSRFU_NGKanoP2.dta", force 	
		
	drop if merge_pf==2 /*DROP CR that we cannot link with baseline */
	
	keep xsurvey SDP* merge* facility_ID

		gen byte client = merge_crsr ==3
		egen nclients = total(client) , by(xsurvey facility_ID)
		gen byte sdpcei = nclients>=1

	sort xsurvey facility_ID

		*egen temp = concat(xsurvey facility_ID)
		*codebook temp
		*codebook facility_ID
		
	keep if facility_ID !=  facility_ID[_n-1]
	
	drop if SDPpharmacy==1 /* DROP pharmacies*/
				
save SR_allsurveys.dta, replace

	bysort xsurvey sdpcei: sum nclients

*END OF DATA PREP

*/
	
************************************************************************
* C. ANALYSIS: survey level descriptive 
************************************************************************

clear
	set obs 1
	gen output_created="$date" in 1
	gen title="Table 1: Percentage of SDPs with CEI, overall and by facility type" in 1
	
	set obs 2
	replace title="Table 2: Percentage of baseline clients who completed follow-up interview" in 2
	set obs 3
	replace title="Table 3: Percentage of baseline clients who completed follow-up interview, detail" in 3	
	set obs 4
	replace title="Table 4: Among baseline clients, background characteristics by completion of follow-up interview" in 4	
	set obs 5
	replace title="Table 5: Among baseline clients, reported satisfaction and experience by completion of follow-up interview" in 5	
	
	export excel using "Understanding_CEI_Sample.xlsx", sheet("README") sheetreplace firstrow(variables) nolabel

*** Table 1	
{
use SR_allsurveys.dta, clear

		/*
		bysort SDPpub: tab SDPprimary SDPpharmacy, m
		bysort SDPpub: tab SDPlow, m
		bysort xsurvey: logit sdpcei SDPpub SDPlow
		*/
		bysort xsurvey: tab SDPlow sdpcei, chi row
		tab sdpcei xsurvey, m

	collapse (count) SDPall (mean) sdpcei, by(xsurvey)
	
		gen SDPtype = "All" 	
	
		save temp.dta, replace

use SR_allsurveys.dta, clear	
	
	collapse (count) SDPall (mean) sdpcei, by(xsurvey SDPlow)
	
		gen SDPtype = "" if SDPlow==.
			replace SDPtype = "Secondary/Tertiary" if SDPlow==0
			replace SDPtype = "Primary" if SDPlow==1
		
	append using temp.dta	
	
		foreach var of varlist sdpcei{
			replace `var' = round(`var'*100, 1)
			}	
		
		drop SDPlow
		
	order xsurvey SDPtype SDPall sdpcei
		
		rename SDPall n_facilities
		rename sdpcei pct_cei
			
	sort xsurvey SDPtype
	
	export excel using "Understanding_CEI_Sample.xlsx", sheet("Table1") ///
		sheetreplace firstrow(variables) nolabel
}

*** Table 2
use CRall_allsurveys.dta, clear
{		

	collapse (count) obs (mean) ceifu interval, by(xsurvey)
	
		foreach var of varlist ceifu{
			replace `var' = round(`var'*100, 1)
			}		
			
		foreach var of varlist interval{
			replace `var' = round(`var'/30, 0.1)
			}					

	order xsurvey 
	
		rename obs n_clients	
		rename ceifu pct_ceifu
		rename interval interval_in_months
		
	export excel using "Understanding_CEI_Sample.xlsx", sheet("Table2") ///
		sheetreplace firstrow(variables) nolabel
}	

*** Table 3
use CRall_allsurveys.dta, clear

	sum ypfwilling yphone yeligible ceifu
	egen outcome = concat(ypfwilling yphone ceifu)
		
		tab outcome, m
		tab outcome yeligible, m
			replace outcome="100_fpineligible" if outcome=="110" & yeligible==0
		tab outcome, m	
		
		tab outcome, gen(outcome_)
		sum outcome_*
		
save temp.dta, replace

use temp.dta, clear		

	collapse (count) obs (mean) outcome_* , 
	gen xsurvey="ALL"
	
	save temp2.dta, replace
	
use temp.dta, clear		
			
	collapse (count) obs (mean) outcome_* , by(xsurvey)

	append using temp2.dta, 
	
		foreach var of varlist outcome_* {
			replace `var' = round(`var'*100, 0.1)
			}
			
	order xsurvey obs
		rename obs n_clients	
		rename outcome_1 pct_noconsent
		rename outcome_2 pct_nophone
		rename outcome_3 pct_nomethod
		rename outcome_4 pct_lost
		rename outcome_5 pct_ceifu
	sort xsurvey 
		
	export excel using "Understanding_CEI_Sample.xlsx", sheet("Table3") /// 
		sheetreplace firstrow(variables) nolabel
		
		capture drop temp
		egen temp = rowtotal(pct_*)
		sum temp
		
		
*** Table 4	
use CRall_allsurveys.dta, clear
{
	/*
	* Age
		graph box yage, over(ceifu) by(xsurvey, row(1)) 
		bysort xsurvey: ttest yage, by(ceifu) unequal 
		bysort xsurvey: tab yagegroup10 ceifu, chi 
		
			gen yagegroup3=0
				replace yagegroup3=1 if yage>=25
				replace yagegroup3=2 if yage>=35
				tab yagegroup3, gen(yagegroup3_)	
			
		bysort xsurvey: tab yagegroup3 ceifu, chi 
	
	* HH wealth ladder 
		graph box yhhladder, over(ceifu) by(xsurvey, row(1)) 
		bysort xsurvey: ttest yhhladder, by(ceifu) unequal 
		
		graph bar yhhladder5, over(ceifu) by(xsurvey, row(1)) 
		bysort xsurvey: tab yhhladder5 ceifu, chi 
		
		graph bar yhhladder6, over(ceifu) by(xsurvey, row(1)) 
		bysort xsurvey: tab yhhladder6 ceifu, chi 

	* Education 
		graph bar yedu_sec_more, over(ceifu) by(xsurvey, row(1)) 
		bysort xsurvey: tab yedu_sec_more ceifu, chi 
	
	* Phone ownership   
		graph bar yphone, over(ceifu) by(xsurvey, row(1)) 
		bysort xsurvey: tab yphone ceifu, chi 
	*/	
	}	

	collapse (count) obs ///
		(mean) yage yhhladder yhhladder5 yhhladder6 yedu_sec_more yphone, by(xsurvey ceifu)
	
		foreach var of varlist yhhladder5 yhhladder6 yedu_sec_more yphone {
			replace `var' = round(`var'*100, 0.1)
			}
			
		foreach var of varlist yage yhhladder {
			replace `var' = round(`var', 0.1)
			}		
		
	order xsurvey ceifu obs 
		
		rename obs n_clients
		rename yage mean_age_in_years
		rename yhhladder mean_hhladder
		rename yhhladder5 pct_hhladder_5higher
		rename yhhladder6 pct_hhladder_6higher
		rename yedu_sec_more pct_edu_sec_more
		rename yphone pct_ownphone
			
	sort xsurvey ceifu 
			
	export excel using "Understanding_CEI_Sample.xlsx", sheet("Table4") ///
		sheetreplace firstrow(variables) nolabel


*** Table 5		
use CRall_allsurveys.dta, clear		
{
	/*

	* Reported to be very satisfied 
		graph bar ysatisfiedvery, over(ceifu) by(xsurvey, row(1)) 
		bysort xsurvey: tab ysatisfiedvery ceifu, chi 
	
	* QCC 
		graph box qcc__mean, over(ceifu) by(xsurvey, row(1)) 	
		bysort xsurvey: ttest qcc__mean, by(ceifu) unequal 
		
		global covqcc "qcc__mean qcc__meaninformation qcc__meaninteraction"	
		
		foreach var of varlist $covqcc {		
			sum `var'
			bysort xsurvey: ttest `var', by(ceifu) unequal 
		}	
	*/	
	}	

{	
	collapse (count) obs ///
		(mean) ysatisfiedvery qcc__mean qcc__meaninformation qcc__meaninteraction, ///
		by(xsurvey ceifu)

		foreach var of varlist ysatisfiedvery {
			replace `var' = round(`var'*100, 1)
			}
			
		foreach var of varlist qcc__* {
			replace `var' = round(`var', 0.01)
			}			

	order xsurvey ceifu obs 
		
		rename obs n_clients
		rename ysatisfiedvery pct_verysatisfied
			
	sort xsurvey ceifu 
			
	export excel using "Understanding_CEI_Sample.xlsx", sheet("Table5") ///
		sheetreplace firstrow(variables) nolabel
}

************************************************************************
* D. ANALYSIS: multivariate regression 
************************************************************************
	
use CRall_allsurveys.dta, clear

	destring facility_ID, replace

	tab ceifu xsurvey, m
	
	foreach survey in $surveylist{	
		xtlogit ceifu yedu_sec_more yhhladder yage if xsurvey=="`survey'", or i(facility_ID) nolog
		estimates store M1_`survey'
	}		

	#delimit; 
	outreg2 [M1_*] 			
		using RegressionTables/Understanding_CEI_Sample_Regression.xls, 
		bdec(2) bfmt(f)  
		cdec(2) cfmt(f) 
		replace excel nocons aster label eform ci 
		sortvar($covage $covedu $covunion $covvisit $covmethod $covside $covready $covqcc $covqcc2 qcc_info_sideeffects qcc_disresp_pressure) 
		;
		#delimit cr		
		
erase temp.dta
erase temp2.dta		
		
GREAT JOB END OF DO FILE
