function tgS = caltg_defaults(caseStr)
% Default: what moments are targeted?

% PV of lifetime earnings by schooling
tgS.tgPvLty = 1;

% College costs
   % add target by yp +++
tgS.tgPMean  = 1;
tgS.tgPStd   = 1;
tgS.tgPMeanIq = 1;
tgS.tgPMeanYp = 0;


% ***** College outcomes
tgS.tgFracS = 1;
% fraction entering college
tgS.tgFracEnterIq = 1;
% fraction graduating (not conditional on entry)
tgS.tgFracGradIq = 1;
tgS.tgFracEnterYp = 1;
tgS.tgFracGradYp = 1;
% Targets by [iq, yp]: entry and graduation rates
tgS.tgCollegeQy = 1;
% Regression coefficients of entry on [iq, yp]
tgS.tgRegrIqYp = 1;

% *****  Parental income
tgS.tgYpIq = 1;
tgS.tgYpYp = 1;

% *****  Hours and earnings
tgS.tgHours = 1;
tgS.tgHoursIq = 1;
tgS.tgHoursYp = 1;
tgS.tgEarn = 1;
tgS.tgEarnIq = 1;
tgS.tgEarnYp = 1;

% Debt at end of college by CD / CG
tgS.tgDebtFracS = 0;
tgS.tgDebtMeanS = 0;      
% Debt at end of college
tgS.tgDebtFracIq = 0;
tgS.tgDebtFracYp = 0;
tgS.tgDebtMeanIq = 0;
tgS.tgDebtMeanYp = 0;
% Average debt per student
tgS.tgDebtMean = 0;
% Debt stats among college grads only, by iq an yp
tgS.tgDebtFracGrads = 1;
% Penalty when too many students hit borrowing limit?
%  To avoid getting stuck at params where everyone maxes out borrowing limit
tgS.useDebtPenalty = 1;

% Mean transfer
tgS.tgTransfer = 1;
tgS.tgTransferYp = 1;
tgS.tgTransferIq = 1;
% Penalize transfers > data transfers?
tgS.tgPenalizeLargeTransfers = 1;

% Financing shares (only constructed for cohorts where transfers etc not available)
tgS.tgFinShares = 1;


%% Override for cases
if strcmpi(caseStr, 'default')
   % Nothing

elseif strcmpi(caseStr, 'timeSeriesFit')
   % Time series calibration. Try to match everything for each cohort
   % Not everything is available, of course

elseif strcmpi(caseStr, 'timeSeriesPartial')
   % Match everything but IQ, yp sorting
   % But need to target marginal entry rates -- otherwise model implies negative sorting
   % ad hoc +++
   tgS.tgRegrIqYp = 0;
   % fraction graduating (not conditional on entry)
   tgS.tgFracGradIq = 0;
   tgS.tgFracGradYp = 0;
   % Targets by [iq, yp]: entry and graduation rates
   tgS.tgCollegeQy = 0;
   
elseif strcmpi(caseStr, 'timeSeries')
   % Time series calibration
   % Do not target regression coefficients betaIq, betaYp
   %  We want to see how far we go without targeting them. We need to match frac_s and LTY(s)
   tgS.tgRegrIqYp = 0;
   % fraction entering college
   tgS.tgFracEnterIq = 0;
   % fraction graduating (not conditional on entry)
   tgS.tgFracGradIq = 0;
   tgS.tgFracEnterYp = 0;
   tgS.tgFracGradYp = 0;
   % Targets by [iq, yp]: entry and graduation rates
   tgS.tgCollegeQy = 0;
   
   
elseif strcmpi(caseStr, 'onlySchoolFrac')
   % Target only school fractions
   % For experiments
   % Check that this actually switches everything off!
   nameV = fieldnames(tgS);
   for i1 = 1 : length(nameV)
      tgS.(nameV{i1}) = 0;
   end
   tgS.tgFracS = 1;
   
else
   error('Invalid');
end


end