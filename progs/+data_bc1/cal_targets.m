function cal_targets(setNo)
% Make and save calibration targets
%{
All targets are in model units

All dollar figures are scaled to be stationary

Checked: 2015-Apr-3
%}

fprintf('Making calibration targets \n');


cS = const_bc1(setNo);

nYp = length(cS.ypUbV);
nIq = length(cS.iqUbV);

cpiYearV = 1920 : 2010;
cpiV = data_bc1.cpi(cpiYearV, cS);

% HS&B cohort = NLSY79 cohort
[~, icNlsy79] = min(abs(cS.bYearV - 1961));
icHSB = icNlsy79;
validateattributes(icHSB, {'double'}, {'finite', 'nonnan', 'nonempty', 'integer', 'positive'})

% HS&B cpi factor (HS&B data are in year 2000 prices). DIVIDE by this
hsbCpiFactor = cpiV(cpiYearV == 2000) ./ cpiV(cpiYearV == cS.cpiBaseYear);
validateattributes(hsbCpiFactor, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive'})

% Divide by this for nlsy results provided by Chris
nlsyCpiFactor = cpiV(cpiYearV == 2010) ./ cpiV(cpiYearV == cS.cpiBaseYear);

% Load file with all NLSY79 targets
n79S = load(fullfile(cS.dataDir, 'nlsy79_moments.mat'));
n79S = n79S.all_targets;


%% College outcomes

% % Fraction in each school group by [iq, yp]
% % invented data targets +++
% tgS.fracS_qycM = repmat(cS.missVal, [cS.nSchool, nIq, nYp, cS.nCohorts]);
% for iCohort = 1 : cS.nCohorts
%    for iYp = 1 : nYp
%       for iIq = 1 : nIq
%          sFracV = ones([cS.nSchool,1]) ./ cS.nSchool;
%          tgS.fracS_qycM(:,iIq,iYp,iCohort) = sFracV;
%       end
%    end
% end
% 
% % HSB data, hsb_fam_income.xlsx
% fracEnter_yqM = [0.1910305	0.3404084	0.4616973	0.7431248
%    0.2746048	0.3476628	0.5838453	0.8174849
%    0.3067916	0.4374966	0.6217784	0.8587366
%    0.2960698	0.5814796	0.7817845	0.9273478];
% % Fraction graduate conditional on entry
% fracGrad_yqM = [0.1987562	0.1296711	0.4773349	0.6385519
%    0.0779666	0.3380288	0.5016366	0.7053534
%    0.1137461	0.3146327	0.5340976	0.7627105
%    0.0291045	0.2856211	0.5979195	0.8423696];
% fracHSG_yqM = 1 - fracEnter_yqM;
% fracCG_yqM  = fracEnter_yqM .* fracGrad_yqM;
% fracCD_yqM  = 1 - fracHSG_yqM - fracCG_yqM;
% tgS.fracS_qycM(cS.iHSG, :, :, icHSB) = fracHSG_yqM';
% tgS.fracS_qycM(cS.iCD,  :, :, icHSB) = fracCD_yqM';
% tgS.fracS_qycM(cS.iCG,  :, :, icHSB) = fracCG_yqM';
% 
% validateattributes(tgS.fracS_qycM(:,:,:,icHSB), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
%    '>', 0', '<', 1, 'size', [cS.nSchool, nIq, nYp]})


% Fraction enter / graduate by IQ
%  frac grad not conditional on entry
tgS.fracEnter_qcM = nan([nIq, cS.nCohorts]);
tgS.fracGrad_qcM  = nan([nIq, cS.nCohorts]);

tgS.fracEnter_qcM(:, icNlsy79) = n79S.attend_college_byafqt;
tgS.fracGrad_qcM(:, icNlsy79)  = n79S.grad_college_byafqt;

tgS.fracEnter_ycM = nan([nYp, cS.nCohorts]);
tgS.fracGrad_ycM  = nan([nYp, cS.nCohorts]);

tgS.fracEnter_ycM(:, icNlsy79) = n79S.attend_college_byinc;
tgS.fracGrad_ycM(:, icNlsy79)  = n79S.grad_college_byinc;


% Invented +++
tgS.fracEnter_qcM = tgS.fracEnter_qcM(:, icNlsy79) * ones([1, cS.nCohorts]);
tgS.fracGrad_qcM  = tgS.fracGrad_qcM(:, icNlsy79)  * ones([1, cS.nCohorts]);

tgS.fracEnter_ycM = tgS.fracEnter_ycM(:, icNlsy79) * ones([1, cS.nCohorts]);
tgS.fracGrad_ycM  = tgS.fracGrad_ycM(:, icNlsy79)  * ones([1, cS.nCohorts]);

validateattributes(tgS.fracEnter_qcM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
   'positive', '<', 0.9})
validateattributes(tgS.fracGrad_qcM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
   'positive', '<', 0.8})


% *****  Implied

% Fraction in each IQ group
qFracV = diff([0; cS.iqUbV]);
tgS.frac_scM = nan([cS.nSchool, cS.nCohorts]);
for iCohort = 1 : cS.nCohorts
   fracEnter = sum(tgS.fracEnter_qcM(:, iCohort) .* qFracV(:));
   fracGrad  = sum(tgS.fracGrad_qcM(:, iCohort) .* qFracV(:));
   tgS.frac_scM(:, iCohort) = [1-fracEnter,  fracEnter-fracGrad,  fracGrad];
end

validateattributes(tgS.frac_scM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   '<', 1, 'size', [cS.nSchool, cS.nCohorts]})
pSumV = sum(tgS.frac_scM);
if any(abs(pSumV - 1) > 1e-6)
   error('Invalid');
end


%% Construct a scale factor for each cohort
%  Multiply all dollar figures by this factor to make model stationary

% Load profiles (units of account, not scaled), by model age
earn_ascM = var_load_bc1(cS.vCohortEarnProfiles, cS);

% Average earnings over this age range
ageV = (30 : 50) - cS.age1 + 1;

% Weights by [age, school] (arbitrary)
%  Would make sense to use actual population weights +++
wt_asM = ones([length(ageV), 1]) * tgS.frac_scM(:, cS.iRefCohort)';
validateattributes(wt_asM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   'size', [length(ageV), cS.nSchool]})

% Mean earnings by cohort, constant weights, constant prices
meanEarn_cV = nan([cS.nCohorts, 1]);
for iCohort = 1 : cS.nCohorts
   earnM = earn_ascM(ageV, :, iCohort);
   meanEarn_cV(iCohort) = sum(earnM(:) .* wt_asM(:)) ./ sum(wt_asM(:));
end

% Scale factor to make model stationary
%  MULTIPLY by this factor to make data figures into model targets
tgS.dollarFactor_cV = meanEarn_cV(cS.iRefCohort) ./ meanEarn_cV;


%% Earnings profiles by [a,s,c]
% Made stationary

tgS.earn_ascM = nan(size(earn_ascM));
for iCohort = 1 : cS.nCohorts
   tgS.earn_ascM(:,:,iCohort) = earn_ascM(:,:,iCohort) .* tgS.dollarFactor_cV(iCohort);
end
if cS.dbg > 10
   validateattributes(tgS.earn_ascM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [cS.ageMax, cS.nSchool, cS.nCohorts]})
end


%% Parental income
% Scaled to be stationary
% Also have medians

% Mean log parental income by IQ quartile
tgS.logYpMean_qcM = nan([nIq, cS.nCohorts]);
tgS.logYpMean_qcM(:, icNlsy79) = n79S.mean_parent_inc_byafqt - log(nlsyCpiFactor) - log(cS.unitAcct);


tgS.logYpMean_ycM = nan([nYp, cS.nCohorts]);
tgS.logYpMean_ycM(:, icNlsy79) = n79S.mean_parent_inc_byinc  - log(nlsyCpiFactor) - log(cS.unitAcct);

% invented data targets +++
% make stationary
for iCohort = 1 : cS.nCohorts
   tgS.logYpMean_qcM(:, iCohort) = tgS.logYpMean_qcM(:, icNlsy79);
   tgS.logYpMean_ycM(:, iCohort) = tgS.logYpMean_ycM(:, icNlsy79);
end

if cS.dbg > 10
   validateattributes(tgS.logYpMean_qcM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      '<', 10, 'size', [nIq, cS.nCohorts]})
end


% Mean and std by cohort
%  Directly sets the model params
tgS.logYpMean_cV = nan([cS.nCohorts, 1]);
tgS.logYpStd_cV  = nan([cS.nCohorts, 1]);

% Chris
% Assumed time invariant
tgS.logYpStd_cV  = n79S.sd_parent_inc .* ones([cS.nCohorts, 1]); 

% Assumed time invariant (stationary transformation)
for iCohort = 1 : cS.nCohorts
   tgS.logYpMean_cV(iCohort) = mean(tgS.logYpMean_qcM(:,iCohort));
end

validateattributes(tgS.logYpMean_cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
validateattributes(tgS.logYpStd_cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>', 0.1, ...
   '<', 1})



%% College costs
% Scaled to be stationary

% Means are available for all cohorts
costS = var_load_bc1(cS.vCollCosts, cS);

tgS.pMean_cV = nan([cS.nCohorts, 1]);
tgS.pStd_cV  = nan([cS.nCohorts, 1]);
tgS.pNobs_cV = nan([cS.nCohorts, 1]);

for iCohort = 1 : cS.nCohorts
   % Year from which college costs are taken
   cYear = cS.bYearV(iCohort) + 20;
   tgS.pMean_cV(iCohort) = costS.tuitionV(costS.yearV == cYear) ./ cS.unitAcct .* tgS.dollarFactor_cV(iCohort);
end

% HS&B data, from gradpred, year 2 in college; men
%  Mean is fairly close to Herrington series, so we keep it
tgS.pMean_cV(icHSB) = 3892 ./ hsbCpiFactor ./ cS.unitAcct;
tgS.pStd_cV(icHSB)  = 4397 ./ hsbCpiFactor ./ cS.unitAcct;
% tgS.nObs_cV(icHSB)  = 1609;

% Assume std/mean stays constant over time
tgS.pStd_cV = tgS.pStd_cV(icHSB) ./ tgS.pMean_cV(icHSB) .* tgS.pMean_cV;

validateattributes(tgS.pMean_cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
   '>', 100 ./ cS.unitAcct, '<', 1e4 ./ cS.unitAcct, 'size', [cS.nCohorts, 1]})
validateattributes(tgS.pStd_cV,  {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
   '>', 100 ./ cS.unitAcct, '<', 1e4 ./ cS.unitAcct, 'size', [cS.nCohorts, 1]})


% Mean p by IQ
% NELS (gradpred, Table 17)
pMeanV = [3550; 3362; 3449; 4119];
tgS.pMean_qcM = nan([nIq, cS.nCohorts]);
tgS.pMean_qcM = pMeanV(:) * ones([1, cS.nCohorts]) ./ hsbCpiFactor ./ cS.unitAcct;

% Need to construct by yp +++
tgS.pMean_ycM = nan([nYp, cS.nCohorts]);


%% Hours in college
% Average hours in college

% Annual hours for total time endowment that is split between work and leisure
% 16 hours per day - study time (Babcock Marks) -> 90 hours per week
% tgS.timeEndow = 16 * 365 - 32 * 35.6
% how to set this? +++
tgS.timeEndow = 52 * 84;

tgS.hoursMean_cV = nan([cS.nCohorts, 1]);

% Chris
tgS.hoursMean_cV(icHSB) = n79S.mean_hours ./ tgS.timeEndow;
% invented +++
tgS.hoursMean_cV = tgS.hoursMean_cV(icHSB) .* ones([cS.nCohorts, 1]);

validateattributes(tgS.hoursMean_cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   '<', 0.7})

tgS.hoursMean_qcM = nan([nIq, cS.nCohorts]);
tgS.hoursMean_qcM(:, icNlsy79) = n79S.mean_hours_byafqt ./ tgS.timeEndow;

tgS.hoursMean_ycM = nan([nYp, cS.nCohorts]);
tgS.hoursMean_ycM(:, icNlsy79) = n79S.mean_hours_byinc ./ tgS.timeEndow;

% invented +++
tgS.hoursMean_ycM = tgS.hoursMean_ycM(:,icNlsy79) * ones([1, cS.nCohorts]);
tgS.hoursMean_qcM = tgS.hoursMean_qcM(:,icNlsy79) * ones([1, cS.nCohorts]);

validateattributes(tgS.hoursMean_ycM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   '<', 1,  'size', [nYp, cS.nCohorts]})
validateattributes(tgS.hoursMean_qcM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   '<', 1,  'size', [nIq, cS.nCohorts]})


%% College earnings
% Scaled to be stationary

% Average earnings
%  should be 1st 2 years in college
collEarnS.mean_qcM = nan([nIq, cS.nCohorts]);
collEarnS.mean_qcM(:, icNlsy79) = n79S.mean_earnings_byafqt ./ nlsyCpiFactor ./ cS.unitAcct;

collEarnS.mean_ycM = nan([nYp, cS.nCohorts]);
collEarnS.mean_ycM(:, icNlsy79) = n79S.mean_earnings_byinc ./ nlsyCpiFactor ./ cS.unitAcct;

% invented +++
collEarnS.mean_ycM = collEarnS.mean_ycM(:, icNlsy79) * ones([1, cS.nCohorts]);
collEarnS.mean_qcM = collEarnS.mean_qcM(:, icNlsy79) * ones([1, cS.nCohorts]);


% % Stats by [year in college, cohort]
% collEarnS.mean_tcM = nan([4, cS.nCohorts]);
% collEarnS.std_tcM  = nan([4, cS.nCohorts]);
% collEarnS.nObs_tcM = nan([4, cS.nCohorts]);
% 
% % Data from gradpred paper (NELS:88), year 2000 prices
% meanV = [4175	4789	6031	6440] ./ hsbCpiFactor ./ cS.unitAcct;
% stdV  = [4100	4465	5425	5864] ./ hsbCpiFactor ./ cS.unitAcct;
% nObsV = [1951	1662	1353	1202];
% 
% collEarnS.mean_tcM(:, icHSB) = meanV;
% collEarnS.std_tcM(:, icHSB)  = stdV;
% collEarnS.nObs_tcM(:, icHSB) = nObsV;
% 
% % Invented +++
% collEarnS.mean_tcM = collEarnS.mean_tcM(:, icHSB) * ones([1, cS.nCohorts]);
% collEarnS.std_tcM  = collEarnS.std_tcM(:, icHSB)  * ones([1, cS.nCohorts]);
% collEarnS.nObs_tcM = collEarnS.nObs_tcM(:, icHSB) * ones([1, cS.nCohorts]);
% 
% validateattributes(collEarnS.mean_tcM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
%    '>', 500 ./ cS.unitAcct,  '<', 1e4 ./ cS.unitAcct})
% validateattributes(collEarnS.std_tcM,  {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
%    '>', 500 ./ cS.unitAcct,  '<', 1e4 ./ cS.unitAcct})

tgS.collEarnS = collEarnS;


%% Debt stats

% Fraction in debt at end of college (dropouts, grads)
tgS.debtFrac_scM = [n79S. dropouts_share_with_loans; n79S.grads_share_with_loans] * ones([1,cS.nCohorts]);
% Mean debt at end of college (NOT conditional on being in debt)
tgS.debtMean_scM = [n79S.mean_dropouts_loans; n79S.mean_grads_loans] * ones([1,cS.nCohorts]) ./ nlsyCpiFactor ./ cS.unitAcct;
% Make not conditional 
tgS.debtMean_scM = tgS.debtMean_scM .* tgS.debtFrac_scM;


validateattributes(tgS.debtFrac_scM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   '<', 0.8})
validateattributes(tgS.debtMean_scM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
   'positive', '<', 2e4 ./ cS.unitAcct})

% Fraction with debt by IQ
%  chris
tgS.debtFrac_qcM = n79S.share_with_loans_byafqt * ones([1, cS.nCohorts]);
% Mean debt not conditional
% debtV = [6900, 11200, 16300, 22000]' .* tgS.debtFrac_qcM(:,icNlsy79) ./ 17400 .* 10200;
tgS.debtMean_qcM = n79S.mean_loans_byafqt(:) * ones([1, cS.nCohorts]) ./ nlsyCpiFactor ./ cS.unitAcct;

validateattributes(tgS.debtFrac_qcM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   '<', 1, 'size', [nIq, cS.nCohorts]})

% Fraction with debt by yP
%  chris
tgS.debtFrac_ycM = n79S.share_with_loans_byinc * ones([1, cS.nCohorts]);

% debtV = [14000; 17000; 18500; 19000] .* tgS.debtFrac_ycM(:,icNlsy79) ./ 17400 .* 10200;
tgS.debtMean_ycM = n79S.mean_loans_byinc(:) * ones([1, cS.nCohorts]) ./ nlsyCpiFactor ./ cS.unitAcct;


%% Parental transfers

% Mean transfer by parental income, conditional on college
% Ref cohort only
tgS.transferMean_ycM = repmat(cS.missVal, [nYp, cS.nCohorts]);

% HSB, hsb_fam_income.xlsx
%  Transfer PER YEAR
tgS.transferMean_ycM(:, icHSB) = [2358.477; 3589.882; 5313.561; 7710.767] ...
   ./ hsbCpiFactor ./ cS.unitAcct;

% Invented +++
tgS.transferMean_ycM = tgS.transferMean_ycM(:, icHSB) * ones([1, cS.nCohorts]);

validateattributes(tgS.transferMean_ycM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
   '>', 500 ./ cS.unitAcct,  '<', 2e4 ./ cS.unitAcct})


% NELS
transferV = [2264; 3678; 4649; 5386];
tgS.transferMean_qcM = transferV * ones([1, cS.nCohorts]) ./ hsbCpiFactor ./ cS.unitAcct;



%% Save

var_save_bc1(tgS, cS.vCalTargets, cS);


end