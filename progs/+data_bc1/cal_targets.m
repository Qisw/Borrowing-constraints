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
[~, tgS.icNlsy79] = min(abs(cS.bYearV - 1961));
icHSB = tgS.icNlsy79;
validateattributes(icHSB, {'double'}, {'finite', 'nonnan', 'nonempty', 'integer', 'positive'})

% HS&B cpi factor (HS&B data are in year 2000 prices). DIVIDE by this
hsbCpiFactor = cpiV(cpiYearV == 2000) ./ cpiV(cpiYearV == cS.cpiBaseYear);
validateattributes(hsbCpiFactor, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive'})

% Divide by this for nlsy results provided by Chris
tgS.nlsyCpiFactor = cpiV(cpiYearV == 2010) ./ cpiV(cpiYearV == cS.cpiBaseYear);

% Load file with all NLSY79 targets
n79S = load(fullfile(cS.dataDir, 'nlsy79_moments.mat'));
n79S = n79S.all_targets;


%% College outcomes

% CPS data
tgS.frac_scM = var_load_bc1(cS.vCohortSchooling, cS);

[tgS, schoolS] = data_bc1.school_targets(n79S, tgS, cS);
tgS.schoolS = schoolS;
clear schoolS;



%% Lifetime earnings and scale factors

[tgS.dollarFactor_cV, tgS.earn_tscM, tgS.pvEarn_scM] = earn_tg(tgS, cS);



%% Parental income
% Scaled to be stationary
% We actually use medians to avoid outlier effects

% Mean log parental income by IQ quartile
tgS.logYpMean_qcM = nan([nIq, cS.nCohorts]);
tgS.logYpMean_ycM = nan([nYp, cS.nCohorts]);

% NLSY 79
tgS.logYpMean_qcM(:, tgS.icNlsy79) = n79S.median_parent_inc_byafqt - log(tgS.nlsyCpiFactor) - log(cS.unitAcct);
tgS.logYpMean_ycM(:, tgS.icNlsy79) = n79S.median_parent_inc_byinc  - log(tgS.nlsyCpiFactor) - log(cS.unitAcct);

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
tgS.logYpMean_cV = n79S.median_parent_inc .* ones([cS.nCohorts, 1]) - log(tgS.nlsyCpiFactor) - log(cS.unitAcct);
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


%% Hours, earnings, debt in college

tgS.hoursS = data_bc1.college_hours(n79S, tgS, cS);
tgS.collEarnS = college_earn_tg(n79S, tgS, cS);
tgS.debtS = data_bc1.debt_tg(tgS, cS);
tgS.finShareS = finshare_tg(cS);


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


%% ***********  Local functions

%% Compute average of a variable for college entrants
function mean_cV = mean_by_yp(in_ycM, fracEnter_ycM, cS)

   mean_cV = nan([cS.nCohorts, 1]);
   for iCohort = 1 : cS.nCohorts
      mass_yV = fracEnter_ycM(:, iCohort) .* cS.pr_ypV;
      mean_cV(iCohort) = sum(in_ycM(:,iCohort) .* mass_yV) ./ sum(mass_yV);
   end

end


%% Earnings and dollar scale factors
function [dollarFactor_cV, tgEarn_tscM, pvEarn_scM] = earn_tg(tgS, cS)

   % ********  Construct a scale factor for each cohort
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
   dollarFactor_cV = meanEarn_cV(cS.iRefCohort) ./ meanEarn_cV;


   % *********  Earnings profiles by [a,s,c]
   % Made stationary

   tgEarn_tscM = nan(size(earn_tscM));
   for iCohort = 1 : cS.nCohorts
      tgEarn_tscM(:,:,iCohort) = earn_tscM(:,:,iCohort) .* dollarFactor_cV(iCohort);
   end
   if cS.dbg > 10
      validateattributes(tgEarn_tscM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
         'size', [cS.ageMax, cS.nSchool, cS.nCohorts]})
   end

   % This could fail if R is calibrated
   ps = cS.pvector.retrieve('R');
   if ps.doCal ~= 0
      error('R cannot be calibrated for this to work');
   end
   pvEarn_scM = nan([cS.nSchool, cS.nCohorts]);
   for iCohort = 1 : cS.nCohorts
      for iSchool = 1 : cS.nSchool
         pvEarn_scM(iSchool,iCohort) = prvalue_bc1(tgEarn_tscM(cS.ageWorkStart_sV(iSchool) : cS.ageMax, ...
            iSchool,iCohort), cS.R);
      end
   end

   validateattributes(pvEarn_scM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive'})

end



%% College earnings
% Scaled to be stationary
function collEarnS = college_earn_tg(n79S, tgS, cS)

   nIq = length(cS.iqUbV);
   nYp = length(cS.ypUbV);

   % Average earnings
   %  should be 1st 2 years in college
   collEarnS.mean_qcM = nan([nIq, cS.nCohorts]);
   collEarnS.mean_qcM(:, tgS.icNlsy79) = n79S.median_earnings_2yr_byafqt ./ tgS.nlsyCpiFactor ./ cS.unitAcct;

   collEarnS.mean_ycM = nan([nYp, cS.nCohorts]);
   collEarnS.mean_ycM(:, tgS.icNlsy79) = n79S.median_earnings_2yr_byinc ./ tgS.nlsyCpiFactor ./ cS.unitAcct;



   % ********  Average earnings across all students

   collEarnS.mean_cV = nan([cS.nCohorts, 1]);
   collEarnS.mean_cV(tgS.icNlsy79) = n79S.median_earnings_2yr ./ tgS.nlsyCpiFactor ./ cS.unitAcct;
   
   
   % Where missing: impute from values by yp
   for iCohort = 1 : cS.nCohorts
      if isnan(collEarnS.mean_cV(iCohort))  &&  ~isnan(collEarnS.mean_ycM(1,iCohort))
         collEarnS.mean_cV(iCohort) = mean_by_yp(collEarnS.mean_ycM(:,iCohort), tgS.fracEnter_ycM(:,iCohort), cS);

         % Check
         % Alternative calculation
         meanAlt = mean_by_yp(collEarnS.mean_qcM(:,iCohort), tgS.fracEnter_qcM(:,iCohort), cS);
         if abs(meanAlt / collEarnS.mean_cV(iCohort) - 1) > 1e-2
            error_bc1('Mean earnings not consistent', cS);
         end
      end
   end

end



%% Financing shares
function finShareS = finshare_tg(cS)
   % Read data
   % Each row is a study. We pick some out by hand
   tbM = readtable(fullfile(cS.dataDir, 'percent_from_source.xlsx'));
   % Get fields that could be Nan
   savingV = tbM.Savings;
   savingV(isnan(savingV)) = 0;
   grantV = tbM.Scholarships;
   grantV(isnan(grantV)) = 0;
   vetV = tbM.Veterans_Vocational;
   vetV(isnan(vetV)) = 0;
   loanV = tbM.Loans;
   loanV(isnan(loanV)) = 0;
   % Other will be split between family and work
   otherV = tbM.Other;
   otherV(isnan(otherV)) = 0;
   
   % Family includes savings
   familyV = tbM.Family + savingV + 0.5 * otherV;
   earnV = tbM.StudentWork + 0.5 * otherV;
   
   % Total subtracts scholarships and vet funding
   totalV = 100 - grantV - vetV;
   
   finShareS.familyShare_cV = nan([cS.nCohorts, 1]);
   finShareS.workShare_cV = nan([cS.nCohorts, 1]);
   finShareS.loanShare_cV = nan([cS.nCohorts, 1]);
   
   for iCohort = 1 : cS.nCohorts
      % Which study for this cohort?
      bYear = cS.bYearV(iCohort);
      if bYear <= 1950
         % Hollis for all of those
         iRow = find(strncmp(tbM.Study, 'Hollis', 6));
         if length(iRow) ~= 1
            error('Study not found');
         end
         
         validateattributes(totalV(iRow), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'scalar', ...
            '>', 80, '<=', 100})
         
         finShareS.familyShare_cV(iCohort) = familyV(iRow) / totalV(iRow);
         validateattributes(finShareS.familyShare_cV(iCohort), {'double'}, ...
            {'finite', 'nonnan', 'nonempty', 'real', '>', 0.20, '<', 1})
         finShareS.workShare_cV(iCohort) = earnV(iRow) / totalV(iRow);
         validateattributes(finShareS.workShare_cV(iCohort), {'double'}, ...
            {'finite', 'nonnan', 'nonempty', 'real', '>', 0.05, '<', 0.80})
         finShareS.loanShare_cV(iCohort) = loanV(iRow) / totalV(iRow);
      end
   end
end