function cal_targets(setNo)
% Make and save calibration targets
%{
All targets are in model units
Not all cohorts have all targets

All dollar figures are scaled to be stationary

Checked: +++
%}

fprintf('\nMaking calibration targets \n');


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

% CPS data
tgS.frac_scM = var_load_bc1(cS.vCohortSchooling, cS);


tgS.fracEnter_qycM = nan([nIq, nYp, cS.nCohorts]);
tgS.fracGrad_qycM  = nan([nIq, nYp, cS.nCohorts]);

% Fraction enter / graduate by IQ
%  frac grad not conditional on entry
tgS.fracEnter_qcM = nan([nIq, cS.nCohorts]);
tgS.fracGrad_qcM  = nan([nIq, cS.nCohorts]);
tgS.fracEnter_ycM = nan([nYp, cS.nCohorts]);
tgS.fracGrad_ycM  = nan([nYp, cS.nCohorts]);



% ***  Early cohorts

for iCohort = 1 : 2
   bYear = cS.bYearV(iCohort);
   if abs(bYear - 1940) < 3
      % Project talent
      dataFn = 'flanagan 1971.csv';
   elseif abs(bYear - 1915) < 3
      % Updegraff
      dataFn = 'updegraff 1936.csv';
   else
      error('Invalid');
   end
   
   loadS = data_bc1.load_income_iq_college(dataFn, setNo);

   tgS.fracEnter_qycM(:,:,iCohort) = loadS.entry_qyM;
   tgS.fracEnter_qcM(:,iCohort) = loadS.entry_qV;
   tgS.fracEnter_ycM(:,iCohort) = loadS.entry_yV;
   if ~isempty(loadS.grad_qyM)
      tgS.fracGrad_qycM(:,:,iCohort)  = loadS.grad_qyM;
      tgS.fracGrad_qcM(:,iCohort) = loadS.grad_qV;
      tgS.fracGrad_ycM(:,iCohort) = loadS.grad_yV;
   end
end

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


% *****  Nlsy79

tgS.fracEnter_qcM(:, icNlsy79) = n79S.attend_college_byafqt;
tgS.fracGrad_qcM(:, icNlsy79)  = n79S.grad_college_byafqt;

tgS.fracEnter_ycM(:, icNlsy79) = n79S.attend_college_byinc;
tgS.fracGrad_ycM(:, icNlsy79)  = n79S.grad_college_byinc;

for iCohort = 1 : cS.nCohorts
   if ~isnan(tgS.fracEnter_qcM(1,iCohort))
      validateattributes(tgS.fracEnter_qcM(:,iCohort), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
         'positive', '<', 0.9})
   end
   if ~isnan(tgS.fracGrad_qcM(1,iCohort))
      validateattributes(tgS.fracGrad_qcM(:,iCohort), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
         'positive', '<', 0.8})
   end
end


% *****  Implied: Fraction by s
% For samples with micro data

% Fraction in each IQ group
qFracV = diff([0; cS.iqUbV]);
for iCohort = 1 : cS.nCohorts
   % check consistency with cps data +++++
   if ~isnan(tgS.fracGrad_qcM(1,iCohort))
      fracEnter = sum(tgS.fracEnter_qcM(:, iCohort) .* qFracV(:));
      fracGrad  = sum(tgS.fracGrad_qcM(:, iCohort) .* qFracV(:));
      tgS.frac_scM(:, iCohort) = [1-fracEnter,  fracEnter-fracGrad,  fracGrad];

      % Check
      validateattributes(tgS.frac_scM(:,iCohort), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
         '<', 1, 'size', [cS.nSchool, 1]})
      pSumV = sum(tgS.frac_scM(:,iCohort));
      if any(abs(pSumV - 1) > 1e-6)
         error('Invalid');
      end
   end
end



%% Construct a scale factor for each cohort
%  Multiply all dollar figures by this factor to make model stationary

% Load profiles (units of account, not scaled), by model age
earn_tscM = var_load_bc1(cS.vCohortEarnProfiles, cS);

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
   earnM = earn_tscM(ageV, :, iCohort);
   meanEarn_cV(iCohort) = sum(earnM(:) .* wt_asM(:)) ./ sum(wt_asM(:));
end

% Scale factor to make model stationary
%  MULTIPLY by this factor to make data figures into model targets
tgS.dollarFactor_cV = meanEarn_cV(cS.iRefCohort) ./ meanEarn_cV;


%% Earnings profiles by [a,s,c]
% Made stationary

tgS.earn_tscM = nan(size(earn_tscM));
for iCohort = 1 : cS.nCohorts
   tgS.earn_tscM(:,:,iCohort) = earn_tscM(:,:,iCohort) .* tgS.dollarFactor_cV(iCohort);
end
if cS.dbg > 10
   validateattributes(tgS.earn_tscM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [cS.ageMax, cS.nSchool, cS.nCohorts]})
end

% This could fail if R is calibrated
ps = cS.pvector.retrieve('R');
if ps.doCal ~= 0
   error('R cannot be calibrated for this to work');
end
tgS.pvEarn_scM = nan([cS.nSchool, cS.nCohorts]);
for iCohort = 1 : cS.nCohorts
   for iSchool = 1 : cS.nSchool
      tgS.pvEarn_scM(iSchool,iCohort) = prvalue_bc1(tgS.earn_tscM(cS.ageWorkStart_sV(iSchool) : cS.ageMax, ...
         iSchool,iCohort), cS.R);
   end
end


%% Parental income
% Scaled to be stationary
% Also have medians

% Mean log parental income by IQ quartile
tgS.logYpMean_qcM = nan([nIq, cS.nCohorts]);
tgS.logYpMean_ycM = nan([nYp, cS.nCohorts]);

% NLSY 79
tgS.logYpMean_qcM(:, icNlsy79) = n79S.mean_parent_inc_byafqt - log(nlsyCpiFactor) - log(cS.unitAcct);
tgS.logYpMean_ycM(:, icNlsy79) = n79S.mean_parent_inc_byinc  - log(nlsyCpiFactor) - log(cS.unitAcct);

if cS.dbg > 10
   idxV = find(~isnan(tgS.logYpMean_qcM(1,:)));
   validateattributes(tgS.logYpMean_qcM(:,idxV), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      '<', 10})
   validateattributes(tgS.logYpMean_ycM(:,idxV), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      '<', 10})
end


% Mean and std by cohort
%  Directly sets the model params
% tgS.logYpMean_cV = nan([cS.nCohorts, 1]);
% tgS.logYpStd_cV  = nan([cS.nCohorts, 1]);

% Assumed time invariant
tgS.logYpMean_cV = n79S.mean_parent_inc .* ones([cS.nCohorts, 1]) - log(nlsyCpiFactor) - log(cS.unitAcct);
% Std log(yp) - no need to account for units
tgS.logYpStd_cV  = n79S.sd_parent_inc .* ones([cS.nCohorts, 1]); 


% Should perhaps construct mean from mean by q where feasible +++
% for consistency
% for iCohort = 1 : cS.nCohorts
%    tgS.logYpMean_cV(iCohort) = mean(tgS.logYpMean_qcM(:,iCohort));
% end

validateattributes(tgS.logYpMean_cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
validateattributes(tgS.logYpStd_cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>', 0.1, ...
   '<', 1})

% Check consistency with values by iq, yp


%% College costs
% Scaled to be stationary

% Means are available for all cohorts
costS = var_load_bc1(cS.vCollCosts, cS);

tgS.pMean_cV = nan([cS.nCohorts, 1]);
tgS.pStd_cV  = nan([cS.nCohorts, 1]);
% tgS.pNobs_cV = nan([cS.nCohorts, 1]);

for iCohort = 1 : cS.nCohorts
   % Year from which college costs are taken
   cYear = cS.bYearV(iCohort) + 20;
   tgS.pMean_cV(iCohort) = costS.tuitionV(costS.yearV == cYear) ./ cS.unitAcct .* tgS.dollarFactor_cV(iCohort);
end

% HS&B data, from gradpred, year 2 in college; men
% %  Mean is fairly close to Herrington series
% tgS.pMean_cV(icHSB) = 3892 ./ hsbCpiFactor ./ cS.unitAcct;
% tgS.pStd_cV(icHSB)  = 4397 ./ hsbCpiFactor ./ cS.unitAcct;
% % tgS.nObs_cV(icHSB)  = 1609;
% Take ratio of std / mean
hsbStdToMean = 4397 / 3892;

% Assume std/mean stays constant over time
tgS.pStd_cV = hsbStdToMean .* tgS.pMean_cV;

validateattributes(tgS.pMean_cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
   '>', 100 ./ cS.unitAcct, '<', 1e4 ./ cS.unitAcct, 'size', [cS.nCohorts, 1]})
validateattributes(tgS.pStd_cV,  {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
   '>', 100 ./ cS.unitAcct, '<', 1e4 ./ cS.unitAcct, 'size', [cS.nCohorts, 1]})


% Mean p by IQ
% NELS (gradpred, Table 17)
pMeanV = [3550; 3362; 3449; 4119];
tgS.pMean_qcM = nan([nIq, cS.nCohorts]);
tgS.pMean_qcM(:,icHSB) = pMeanV(:) ./ hsbCpiFactor ./ cS.unitAcct;

% Need to construct by yp +++
tgS.pMean_ycM = nan([nYp, cS.nCohorts]);


%% Hours in college

tgS.hoursS = data_bc1.college_hours(n79S, tgS, cS);


%% College earnings
% Scaled to be stationary

% Average earnings
%  should be 1st 2 years in college
collEarnS.mean_qcM = nan([nIq, cS.nCohorts]);
collEarnS.mean_qcM(:, icNlsy79) = n79S.mean_earnings_byafqt ./ nlsyCpiFactor ./ cS.unitAcct;

collEarnS.mean_ycM = nan([nYp, cS.nCohorts]);
collEarnS.mean_ycM(:, icNlsy79) = n79S.mean_earnings_byinc ./ nlsyCpiFactor ./ cS.unitAcct;


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


% ********  Average earnings across all students

collEarnS.mean_cV = mean_by_yp(collEarnS.mean_ycM, tgS.fracEnter_ycM, cS);

% Check
% Alternative calculation
mean_cV = mean_by_yp(collEarnS.mean_qcM, tgS.fracEnter_qcM, cS);
idxV = find(~isnan(collEarnS.mean_cV));
for iCohort = idxV(:)'
   validateattributes(collEarnS.mean_cV(iCohort), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive'})
   maxDiff = max(abs(mean_cV(idxV) - collEarnS.mean_cV(idxV)) ./ collEarnS.mean_cV(idxV));
   if maxDiff > 2e-2
      error_bc1('Mean earnings not consistent', cS);
   end
end

tgS.collEarnS = collEarnS;


%% Debt stats

% Fraction with debt at end of college (cd, cg)
tgS.debtFrac_scM = nan([2, cS.nCohorts]);
% Mean debt (not conditional on having debt)
tgS.debtMean_scM = nan([2, cS.nCohorts]);


% ******  Nlsy79

% Fraction in debt at end of college (dropouts, grads)
tgS.debtFrac_scM(:,icNlsy79) = [n79S. dropouts_share_with_loans; n79S.grads_share_with_loans];
% Mean debt at end of college (NOT conditional on being in debt)
tgS.debtMean_scM(:,icNlsy79) = [n79S.mean_dropouts_loans; n79S.mean_grads_loans] ./ nlsyCpiFactor ./ cS.unitAcct;
% Make not conditional 
tgS.debtMean_scM(:,icNlsy79) = tgS.debtMean_scM(:,icNlsy79) .* tgS.debtFrac_scM(:,icNlsy79);

validateattributes(tgS.debtFrac_scM(~isnan(tgS.debtFrac_scM)), {'double'}, {'nonempty', 'real', 'positive', ...
   '<', 0.8})
validateattributes(tgS.debtMean_scM(~isnan(tgS.debtMean_scM)), {'double'}, {'nonempty', 'real', ...
   'positive', '<', 2e4 ./ cS.unitAcct})


% ********  Fraction with debt by IQ

tgS.debtFrac_qcM = nan([nIq, cS.nCohorts]);
tgS.debtMean_qcM = nan([nIq, cS.nCohorts]);


% *** Nlsy 79

tgS.debtFrac_qcM(:,icNlsy79) = n79S.share_with_loans_byafqt;
% Mean debt not conditional
% debtV = [6900, 11200, 16300, 22000]' .* tgS.debtFrac_qcM(:,icNlsy79) ./ 17400 .* 10200;
tgS.debtMean_qcM(:,icNlsy79) = n79S.mean_loans_byafqt(:) ./ nlsyCpiFactor ./ cS.unitAcct;

validateattributes(tgS.debtFrac_qcM(~isnan(tgS.debtFrac_qcM)), {'double'}, {'nonempty', 'real', 'positive', '<', 2e4 ./ cS.unitAcct, ...
   '<', 1})


% **********  Fraction with debt by yP

tgS.debtFrac_ycM = nan([nYp, cS.nCohorts]);
tgS.debtMean_ycM = nan([nYp, cS.nCohorts]);

tgS.debtFrac_ycM(:,icNlsy79) = n79S.share_with_loans_byinc;
tgS.debtMean_ycM(:,icNlsy79) = n79S.mean_loans_byinc(:) ./ nlsyCpiFactor ./ cS.unitAcct;


% *******  Average debt across all students
% Not at end of college but across all enrolled students

tgS.debtMean_cV = nan([cS.nCohorts, 1]);

% Trends in student aid
loadS = var_load_bc1(cS.vStudentDebtData, cS);
% Take average debt at year 2 in college 
%  Early cohorts have 0 debt (year 1)
yrIdxV = max(1, cS.yearStartCollege_cV - loadS.yearV(1) + 3);
tgS.debtMean_cV = loadS.avgDebtV(yrIdxV);

validateattributes(tgS.debtMean_cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, ...
   'size', [cS.nCohorts, 1]})


%% Parental transfers

% Mean transfer by parental income, conditional on college
% Ref cohort only
tgS.transferMean_ycM = nan([nYp, cS.nCohorts]);
tgS.transferMean_qcM = nan([nIq, cS.nCohorts]);

% HSB, hsb_fam_income.xlsx
%  Transfer PER YEAR
tgS.transferMean_ycM(:, icHSB) = [2358.477; 3589.882; 5313.561; 7710.767] ...
   ./ hsbCpiFactor ./ cS.unitAcct;

% validateattributes(tgS.transferMean_ycM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
%    '>', 500 ./ cS.unitAcct,  '<', 2e4 ./ cS.unitAcct})

% NELS
transferV = [2264; 3678; 4649; 5386];
tgS.transferMean_qcM(:,icHSB) = transferV ./ hsbCpiFactor ./ cS.unitAcct;


% Average for all college students
tgS.transferMean_cV = mean_by_yp(tgS.transferMean_ycM, tgS.fracEnter_ycM, cS);
mean_cV = mean_by_yp(tgS.transferMean_qcM, tgS.fracEnter_qcM, cS);
idxV = find(~isnan(tgS.transferMean_cV));
maxDiff = max(abs(mean_cV(idxV) - tgS.transferMean_cV(idxV)) ./ tgS.transferMean_cV(idxV));
if maxDiff > 2e-2
   warning('Mean transfers not consistent. Max diff %.3f', maxDiff);
end


%% Borrowing limits

% Borrowing limits at start of each year in college, constant dollars
% but not yet detrended, expressed as min assets (<= 0)
tgS.kMin_acM = data_bc1.borrow_limits(cS);
n1 = size(tgS.kMin_acM, 1);

% Detrend
tgS.kMin_acM = tgS.kMin_acM .* (ones([n1, 1]) * tgS.dollarFactor_cV(:)');

validateattributes(tgS.kMin_acM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '<=', 0, ...
   'size', [n1, cS.nCohorts]})


%% Save

var_save_bc1(tgS, cS.vCalTargets, cS);


end


%% Compute average of a variable for college entrants
function mean_cV = mean_by_yp(in_ycM, fracEnter_ycM, cS)

mean_cV = nan([cS.nCohorts, 1]);
for iCohort = 1 : cS.nCohorts
   mass_yV = fracEnter_ycM(:, iCohort) .* cS.pr_ypV;
   mean_cV(iCohort) = sum(in_ycM(:,iCohort) .* mass_yV) ./ sum(mass_yV);
end

end