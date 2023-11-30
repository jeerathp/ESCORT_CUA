// codes for : Paffett et al. Economic evaluation of an integrated care program in addition to conventional care for chronic kidney disease patients in rural communities of Thailand

// Part1: ESCORT1 manipulation to calculate efficacy of the intervention

*cd : define dir

use ESCORT1_clean, clear

**# Linear mixed modelling with extra months to forcast CKD stage transitions
mixed gfr year i.groupctrl1case2#c.year || id:, reml
predict gfr_predict

// translating predicted gfr to ckd stage
gen ckd_stage_gfr_predict = ., after(gfr_predict) 
by id (month), sort: replace ckd_stage_gfr_predict = 1 if gfr_predict >= 60
by id (month), sort: replace ckd_stage_gfr_predict = 2 if gfr_predict < 60 & gfr_predict >= 45
by id (month), sort: replace ckd_stage_gfr_predict = 3 if gfr_predict < 45 & gfr_predict >= 30
by id (month), sort: replace ckd_stage_gfr_predict = 4 if gfr_predict < 30 & gfr_predict >= 15
by id (month), sort: replace ckd_stage_gfr_predict = 5 if gfr_predict < 15 & gfr_predict >=5
by id (month), sort: replace ckd_stage_gfr_predict = 6 if gfr_predict < 5
by id (month), sort: replace ckd_stage_gfr_predict = . if gfr_predict == .

by id (month), sort: replace gfr_predict = 0 if gfr_predict < 15
by id (month), sort: drop if gfr_predict[_n-1] == 0
by id (month), sort: drop if gfr_predict > 60 //*new* (backwards prediction)

order id month year groupctrl1case2 gfr gfr_predict ckd_stage_gfr_predict

drop if month == 1
drop if month == 3
drop if month == 6
drop if month == 9
drop if month == 15
drop if month == 18
drop if month == 21

xtset id year
by groupctrl1case2, sort: xttrans ckd_stage_gfr_predict, freq

save ESCORT1_analysed, replace

// Part2: combined ESCORT1 and ESCORT2 data to calculate the transitional probabilities of the present study

use ESCORT1_clean, clear
replace study_name = 0 if study_name == 1
drop if year < 0
save ESCORT1_clean_0years+, replace

append using ESCORT2_clean
format id %15.0g
save ESCORT_appended, replace

replace status_code = 0 if withdraw_sp == "ไตวายเรื้อรัง" & study_name == 1
replace status_code = 0 if withdraw_sp == "ไตวาย" & study_name == 1
replace status_code = 0 if withdraw_sp == "ไตวายเรื่อรัง" & study_name == 1

// dropping observations following death in ESCORT2 data, rather than censoring as for withdraw and lost follow up
by id (month), sort: drop if status_code == 1 & gfr == . & gfr[_n-1] == . & gfr[_n+1] == . & gfr[_n+2] == . & gfr[_n+3] == . & gfr[_n+4] == . & gfr[_n+5] == . & gfr[_n+6] == . & gfr[_n+7] == . & gfr[_n+8] == . & gfr[_n+9] == . & gfr[_n+10] == . & gfr[_n+11] == . & gfr[_n+12] == . & gfr[_n+13] == . & gfr[_n+14] == . & gfr[_n+15] == . & gfr[_n+16] == . & gfr[_n+17] == . & gfr[_n+18] == . & gfr[_n+19] == . & gfr[_n+20] == . & study_name == 1 // on-CKD related reasons

by id (month), sort: drop if status_code == 0 & gfr == . &gfr[_n-1] == . & gfr[_n+1] == . & gfr[_n+2] == . & gfr[_n+3] == . & gfr[_n+4] == . & gfr[_n+5] == . & gfr[_n+6] == . & gfr[_n+7] == . & gfr[_n+8] == . & gfr[_n+9] == . & gfr[_n+10] == . & gfr[_n+11] == . & gfr[_n+12] == . & gfr[_n+13] == . & gfr[_n+14] == . & gfr[_n+15] == . & gfr[_n+16] == . & gfr[_n+17] == . & gfr[_n+18] == . & gfr[_n+19] == . & gfr[_n+20] == . & study_name == 1 // CK failure, chronic renal failure, kidney disease

by id (month), sort: replace gfr = 0 if gfr == . & status_code == 0
by id (month), sort: replace gfr = 0 if gfr == . & status_code == 1

**# Transitional probs now that ESCORT2 is combined with ESCORT1 treatment group
drop if groupctrl1case2 == 0 // only looking at the trans prob of the treatment group, then apply RR found when analysing ESCORT1 to get new control group
mixed gfr year || study_name: || id:, reml
predict gfr_predict

// translating predicted gfr to ckd stage
gen ckd_stage_gfr_predict = ., after(gfr_predict) 
by id (month), sort: replace ckd_stage_gfr_predict = 1 if gfr_predict >= 60
by id (month), sort: replace ckd_stage_gfr_predict = 2 if gfr_predict < 60 & gfr_predict >= 45
by id (month), sort: replace ckd_stage_gfr_predict = 3 if gfr_predict < 45 & gfr_predict >= 30
by id (month), sort: replace ckd_stage_gfr_predict = 4 if gfr_predict < 30 & gfr_predict >= 15
by id (month), sort: replace ckd_stage_gfr_predict = 5 if gfr_predict < 15 & gfr_predict >= 5
by id (month), sort: replace ckd_stage_gfr_predict = 6 if gfr_predict < 5
by id (month), sort: replace ckd_stage_gfr_predict = . if gfr_predict == .

order id month year study_name groupctrl1case2 gfr gfr_predict ckd_stage_gfr_predict
by id (month), sort: replace gfr_predict = 0 if gfr_predict < 15
by id (month), sort: drop if gfr_predict[_n-1] == 0

drop if month == 1
drop if month == 3
drop if month == 6
drop if month == 9
drop if month == 15
drop if month == 18
drop if month == 21
drop if month == 27
drop if month == 30
drop if month == 33

xtset id year
xttrans ckd_stage_gfr_predict, freq

gen error_diff = gfr_predict - gfr_raw
sum error_diff // model validation for the interevention group of THIS study (ie. ESCORT1 treatment and ESCORT2 combined)
