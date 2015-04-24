function cS = const_bc1(setNo, expNo)
% Set constants
%{
Index order: k, age, school, iq, yp, abil, j, cohort
   iq: q
   age: t
   ability: a

Checked: 2015-Mar-18
%}
% -----------------------------

% Default set and exp numbers
cS.setDefault = 1;
cS.expBase = 1;
if isempty(setNo)
   setNo = cS.setDefault;
end
if nargin < 2
   expNo = cS.expBase;
end
if isempty(expNo)
   expNo = cS.expBase;
end
cS.setNo = setNo;
cS.expNo = expNo;
setStr = sprintf('set%03i', setNo);
expStr = sprintf('exp%03i', expNo);

cS.dbg = 111;
cS.missVal = -9191;
cS.pauseOnError = 1;
% How often to run full debug mode during calibration?
cS.dbgFreq = 0.5;  


%% Miscellaneous

% 1 = $unitAcct
cS.unitAcct = 1e3;

% params are calibrated never / only for base exper / also for other exper
cS.calNever = 0;
cS.calBase = 1;
cS.calExp = 2;
cS.doCalValueV = [cS.calNever, cS.calBase, cS.calExp];

% Collection of calibrated parameters
cS.pvector = pvector(30, cS.doCalValueV);

cS.male = 1;
cS.female = 2;
cS.both = 3;
cS.sexStrV = {'men', 'women', 'both'};

% fzero options for finding EE equation zeros
cS.fzeroOptS = optimset('fzero');
cS.fzeroOptS.TolX = 1e-7;

% fminbnd options for maximizing value functions
cS.fminbndOptS = optimset('fminbnd');
cS.fminbndOptS.TolX = 1e-7;

% cS.raceWhite = 23;

% Set some constants. For this we need to create a dummy pstruct object
% p = pstruct('temp', 'temp', 'temp', 1, 0, 2, 0);

% Bounds for transformed guesses
cS.guessLb = 1;
cS.guessUb = 2;

% Gross interest rate (if not calibrated)
cS.R = 1.04;


%% Default parameters: Demographics, Preferences

% Age at model age 1
cS.age1 = 18;
% Last physical age
cS.physAgeLast = 75;
% Retirement age
% cS.physAgeRetire = 65;

% Discount factor
cS.pvector = cS.pvector.change('prefBeta', '\beta', 'Discount factor', 0.98, 0.8, 1.1, cS.calNever);
% Weight on u(c) at work. To prevent overconsumption
cS.pvector = cS.pvector.change('prefWtWork', '\omega_{w}', 'Weight on u(c) at work', 3, 1, 10, cS.calBase);
% Same for college. Normalize to 1
cS.pvector = cS.pvector.change('prefWt', '\omega_{c}', 'Weight on u(c)', 1, 0.01, 1.1, cS.calNever);
% Curvature of u(c)
cS.pvector = cS.pvector.change('prefSigma', '\varphi_{c}', 'Curvature of utility', 2, 1, 5, cS.calNever);
% Curvature of u(leisure)
cS.pvector = cS.pvector.change('prefRho', '\varphi_{l}', 'Curvature of utility', 2, 1, 5, cS.calNever);
% Weight on leisure
cS.pvector = cS.pvector.change('prefWtLeisure', '\omega_{l}', 'Weight on leisure', 0.5, 0.01, 5, cS.calBase);
% Consumption floor
cS.cFloor = 500 ./ cS.unitAcct;
% Leisure floor
cS.lFloor = 0.01;

% Parental preferences
cS.pvector = cS.pvector.change('puSigma', '\varphi_{p}', 'Curvature of parental utility', 0.35, 0.1, 5, cS.calBase);
% Time varying: to match transfer data
cS.pvector = cS.pvector.change('puWeight', '\omega_{p}', 'Weight on parental utility', 1, 0.001, 2, cS.calBase);

% Pref shock at entry. For numerical reasons only. Fixed.
cS.pvector = cS.pvector.change('prefScaleEntry', '\gamma', 'Preference shock at college entry', 0.1, 0.05, 1, cS.calNever);
% Pref for working as HSG. Includes leisure. No good scale. +++
%  Calibrate in experiment to match schooling average
cS.pvector = cS.pvector.change('prefHS', '\bar{\eta}', 'Preference for HS', 0, -5, 10, cS.calBase);
% % Tax on HS earnings (a preference shock). 2 parameters. Intercept and slope. Both in (-1,1)
% cS.pvector = cS.pvector.change('taxHSzero', '\tau{0}', 'Tax on college earnings',   0, -0.6, 0.6, cS.calNever);
% cS.pvector = cS.pvector.change('taxHSslope',  '\tau{1}', 'Tax on college earnings', 0, -0.8, 0.8, cS.calNever);

% Cohorts modeled
cS.bYearV = [1920, 1940, 1961, 1979]';
% Cross sectional calibration for this cohort
cS.iRefCohort = find(cS.bYearV == 1961);
cS.nCohorts = length(cS.bYearV);


%% Default: endowments

% Size of ability grid
cS.nAbil = 9;
% Earnings are determined by phi(s) * (a - aBar)
%  aBar determines for which abilities earnings gains from schooling MUST be positive
cS.aBar = 0;

% Number of types
cS.nTypes = 80;

% IQ groups
cS.iqUbV = (0.25 : 0.25 : 1)';
cS.nIQ = length(cS.iqUbV);

% Parental income classes
cS.ypUbV = (0.25 : 0.25 : 1)';

% Endowment correlations
cS.pvector = cS.pvector.change('alphaPY', '\alpha_{p,y}', 'Correlation, $p,y$', 0.3, -5, 5, cS.calBase);
cS.pvector = cS.pvector.change('alphaPM', '\alpha_{p,m}', 'Correlation, $p,m$', 0.4, -5, 5, cS.calBase);
cS.pvector = cS.pvector.change('alphaYM', '\alpha_{y,m}', 'Correlation, $y,m$', 0.5, -5, 5, cS.calBase);
% Does not matter right now. Until we have a direct role for ability
%  But want to be able to change signal precision (rather than grad prob function) for experiments
cS.pvector = cS.pvector.change('alphaAM', '\alpha_{a,m}', 'Correlation, $a,m$', 2, 0.1, 5, cS.calBase);

% Marginal distributions
cS.pvector = cS.pvector.change('pMean', '\mu_{p}', 'Mean of $p$', ...
   (5e3 ./ cS.unitAcct), (-5e3 ./ cS.unitAcct), (1.5e4 ./ cS.unitAcct), cS.calBase);
cS.pvector = cS.pvector.change('pStd', '\sigma_{p}', 'Std of $p$', 2e3 ./ cS.unitAcct, ...
   5e2 ./ cS.unitAcct, 1e4 ./ cS.unitAcct, cS.calBase);

% This will be taken directly from data (so not calibrated)
%  but is calibrated for other cohorts
cS.pvector = cS.pvector.change('logYpMean', '\mu_{y}', 'Mean of $\log(y_{p})$', ...
   log(5e4 ./ cS.unitAcct), log(5e3 ./ cS.unitAcct), log(5e5 ./ cS.unitAcct), cS.calNever);
% Assumed time invariant
cS.pvector = cS.pvector.change('logYpStd', '\sigma_{y}', 'Std of $\log(y_{p})$', 0.3, 0.05, 0.6, cS.calNever);

cS.pvector = cS.pvector.change('sigmaIQ', '\sigma_{IQ}', 'Std of IQ noise',  0.35, 0.2, 2, cS.calBase);


%% Default: schooling

% College lasts this many periods
cS.collLength = 4;

cS.iHSG = 1;
cS.iCD = 2;
cS.iCG = 3;
cS.nSchool = cS.iCG;
cS.sLabelV = {'HSG', 'CD', 'CG'};
cS.ageWorkStart_sV = [1; 3; cS.collLength+1];

% Parameters governing probGrad(a)
   % One of these has to be time varying
cS.pvector = cS.pvector.change('prGradMin', '\pi_{0}', 'Min $\pi_{a}$', 0.1, 0.01, 0.5, cS.calBase);
cS.pvector = cS.pvector.change('prGradMax', '\pi_{1}', 'Max $\pi_{a}$', 0.8, 0.7, 0.99, cS.calBase);
cS.pvector = cS.pvector.change('prGradMult', '\pi_{a}', 'In $\pi_{a}$', 0.7, 0.1, 5, cS.calBase);
cS.pvector = cS.pvector.change('prGradExp', '\pi_{b}', 'In $\pi_{a}$',  1, 0.1, 5, cS.calBase);
cS.pvector = cS.pvector.change('prGradPower', '\pi_{c}', 'In $\pi_{a}$', 1, 0.1, 2, cS.calNever);
cS.pvector = cS.pvector.change('prGradABase', 'a_{0}', 'In $\pi_{a}$', 0, 0, 0.3, cS.calNever);

% nCohorts = length(cS.bYearV);
cS.pvector = cS.pvector.change('wCollMean', 'Mean w_{coll}', 'Maximum earnings in college', ...
   2e4 ./ cS.unitAcct, 5e3 ./ cS.unitAcct, 1e5 ./ cS.unitAcct, cS.calBase);


%% Defaults: work

cS.abilAffectsEarnings = 1;

% Earnings are determined by phi(s) * (a - aBar)
%  phi(s) taken from gradpred
cS.pvector = cS.pvector.change('phiHSG', '\phi_{HSG}', 'Return to ability, HSG', 0.155,  0.02, 0.2, cS.calNever);
cS.pvector = cS.pvector.change('phiCG',  '\phi_{CG}',  'Return to ability, CG',  0.194, 0.02, 0.2, cS.calNever);

% Scale factors of lifetime earnings (log)
cS.pvector = cS.pvector.change('eHatCD', '\hat_{e}_{CD}', 'Log skill price CD', 0, -3, 1, cS.calBase);
cS.pvector = cS.pvector.change('dEHatHSG', 'd\hat_{e}_{HSG}', 'Skill price gap HSG', -0.1, -3, 0, cS.calBase);
cS.pvector = cS.pvector.change('dEHatCG',  'd\hat_{e}_{CG}',  'Skill price gap CG',   0.1,  0, 3, cS.calBase);
% cS.pvector = cS.pvector.change('eHatCG',  '\hat_{e_{CG}}',  'Log skill price CG',  -1, -4, 1, cS.calBase);


%% Default: other

% Gross interest rate
cS.pvector = cS.pvector.change('R', 'R', 'Interest rate', cS.R, 1, 1.1, cS.calNever);

% Base year for prices
cS.cpiBaseYear = 2010;

% Last year with data for anything
cS.lastDataYear = 2014;
% First year with data for anything (cpi starts in 1913)
cS.firstDataYear = 1913;

% Set no for cps routines
cS.cpsSetNo = 1;


%% Which calibration targets to use?

% PV of lifetime earnings by schooling
cS.tgPvLty = 1;

% College costs
   % add target by yp +++
cS.tgPMean  = 1;
cS.tgPStd   = 1;
cS.tgPMeanIq = 1;


% ***** College outcomes
cS.tgFracS = 1;
% fraction entering college
cS.tgFracEnterIq = 1;
% fraction graduating (not conditional on entry)
cS.tgFracGradIq = 1;
cS.tgFracEnterYp = 1;
cS.tgFracGradYp = 1;

% *****  Parental income
cS.tgYpIq = 1;
cS.tgYpYp = 1;

% *****  Hours and earnings
cS.tgHours = 1;
cS.tgHoursIq = 1;
cS.tgHoursYp = 1;
cS.tgEarn = 1;
cS.tgEarnIq = 1;
cS.tgEarnYp = 1;

% Debt at end of college by CD / CG
cS.tgDebtFracS = 0;
cS.tgDebtMeanS = 0;      
% Debt at end of college
cS.tgDebtFracIq = 1;
cS.tgDebtFracYp = 1;
cS.tgDebtMeanIq = 1;
cS.tgDebtMeanYp = 1;
% Average debt per student
cS.tgDebtMean = 0;

% Mean transfer
cS.tgTransfer = 1;
cS.tgTransferYp = 1;
cS.tgTransferIq = 1;


%% Parameter sets

if setNo == cS.setDefault
   cS.setStr = 'Default';
   
elseif setNo == 2
   cS.setStr = 'Ability does not affect earnings';
   cS.abilAffectsEarnings = 0;
   
elseif setNo == 3
   % For testing. Calibrate to another cohort
   cS.setStr = 'Test with another cohort';
   [~, cS.iCohort] = min(abs(cS.bYearV - 1940));
   
else
   error('Invalid');
end


%% Experiment settings
% For each param, specify from which cohort it is taken
% []: take from the sets base cohort

% Which data based parameters are from baseline cohort?
% Earnings profiles (sets targets if calibrated, otherwise takes paramS.pvEarn_asM from base cohort)
expS.earnCohort = [];
% expS.costBaseCohort = 0;
% expS.ypBaseCohort = 0;
% Cohort from which borrowing limits are taken
expS.bLimitCohort = [];
% Does this experiment require recalibration?
expS.doCalibrate = 1;

% ******* Base experiments: calibrate everything to match all target
if expNo < 100
   if expNo == cS.expBase
      cS.expStr = 'Baseline';
      % Parameters with these values of doCal are calibrated
      cS.doCalV = cS.calBase;
      cS.iCohort = cS.iRefCohort;      % change? +++++
   else
      error('Invalid');
   end
   
   
% *******  Counterfactuals
% Nothing is calibrated. Just run exp_bc1
% Params are copied from base
elseif expNo < 200
   expS.doCalibrate = 0;
   % Irrelevant
   cS.doCalV = cS.calExp;
   % Taking parameters from this cohort
   cS.iCohort = cS.iRefCohort;
   % Taking counterfactuals from this cohort
   cfCohort = find(cS.bYearV == 1940);

   if expNo == 103
      cS.expStr = 'Replicate base exper';    % for testing
      % Irrelevant
      cS.doCalV = cS.calExp;
      cS.iCohort = cS.iRefCohort;
      expS.earnCohort = cS.iCohort;
      expS.bLimitCohort = cS.iCohort;

   elseif expNo == 104
      % This only works if ability does not affect earnings
      if cS.abilAffectsEarnings ~= 0
         error_bc1('Not implemented', cS);
      end
      cS.expStr = 'Only change earn profiles'; 
      expS.earnCohort = cfCohort;

   elseif expNo == 105
      cS.expStr = 'Only change bLimit';    % when not recalibrated
      expS.bLimitCohort = cfCohort;

   elseif expNo == 106
      % Change college costs
      cS.expStr = 'College costs';
      % Need to calibrate everything for that cohort. Then impose pMean from there +++
      
   else
      error('Invalid');
   end
   
   
% ********  Calibrated experiments
% A subset of params is recalibrated. The rest is copied from baseline
elseif expNo < 300
   % Now fewer parameters are calibrated
   cS.doCalV = cS.calExp;
   cS.iCohort = cS.iRefCohort - 1;  % make one for each cohort +++++
   % Calibrate pMean, which is really a truncated data moment
   %  Should also do something about pStd +++
   cS.pvector = cS.pvector.calibrate('pMean', cS.calExp);

   if expNo == 202
      % Recalibrate all time-varying parameters
      cS.expStr = 'Time series';
      % Signal noise
      cS.pvector = cS.pvector.calibrate('alphaAM', cS.calExp);
      % Match transfers
      cS.pvector = cS.pvector.calibrate('puWeight', cS.calExp);
      % Match overall college entry
      cS.pvector = cS.pvector.calibrate('prefHS', cS.calExp);

   elseif expNo == 203
      % This changes earnings, borrowing limits, pMean
      cS.expStr = 'Only change observables';   
%       % Take all calibrated params from base
%       for i1 = 1 : cS.pvector.np
%          ps = cS.pvector.valueV{i1};
%          if ps.doCal == cS.calExp
%             % Do not calibrate, but take from base exper
%             cS.pvector = cS.pvector.calibrate(ps.name, cS.calBase);
%          end
%       end
      %cS.pvector = cS.pvector.calibrate('logYpMean', cS.calExp);
   
   else
      error('Invalid');
   end
   
else
   error('Invalid');
end

cS.expS = expS;


%% Derived constants

cS.pr_iqV = diff([0; cS.iqUbV]);
cS.pr_ypV = diff([0; cS.ypUbV]);

cS.nCohorts = length(cS.bYearV);
% Year each cohort start college (age 19)
cS.yearStartCollege_cV = cS.bYearV + 18;

% Lifespan
cS.ageMax = cS.physAgeLast - cS.age1 + 1;
% cS.ageRetire = cS.physAgeRetire - cS.age1 + 1;

% Length of work phase by s
cS.workYears_sV = cS.ageMax - cS.ageWorkStart_sV + 1;

if cS.abilAffectsEarnings == 0   
   cS.pvector = cS.pvector.change('phiHSG', '\phi_{HSG}', 'Return to ability, HSG', 0,  0.02, 0.2, cS.calNever);
   cS.pvector = cS.pvector.change('phiCG',  '\phi_{CG}',  'Return to ability, CG',  0, 0.02, 0.2, cS.calNever);
   cS.pvector = cS.pvector.change('eHatCD', [], [], 0, [], [], cS.calNever);
   cS.pvector = cS.pvector.change('dEHatHSG', [], [], 0, [], [], cS.calNever);
   cS.pvector = cS.pvector.change('dEHatCG', [], [], 0, [], [], cS.calNever);
end



%% Directories

if exist('/Users/lutz', 'dir')
   cS.runLocal = 1;
else
   cS.runLocal = 0;
end

if cS.runLocal == 1
   cS.baseDir = fullfile('/users', 'lutz', 'dropbox', 'hc', 'borrow_constraints');
else
   cS.baseDir = '/nas02/home/l/h/lhendri/bc';
   cS.dbgFreq = 0.1;    % Ensure that dbg is always low on the server
   cS.pauseOnError = 0;
end
cS.modelDir = fullfile(cS.baseDir, 'model1');
cS.progDir = fullfile(cS.modelDir, 'progs');
cS.matDir  = fullfile(cS.modelDir, 'mat', setStr, expStr);
cS.outDir  = fullfile(cS.modelDir, 'out', setStr, expStr);
cS.figDir  = cS.outDir;
cS.tbDir   = cS.outDir;
cS.sharedDir = fullfile(cS.modelDir, 'shared');
cS.dataDir = fullfile(cS.baseDir, 'data');

% Preamble data
cS.preambleFn = fullfile(cS.outDir, 'preamble1.tex');

cS.cpsDir = fullfile(cS.baseDir, 'cps');
cS.cpsProgDir = fullfile(cS.cpsDir, 'progs');


%%  Saved variables

% Calibrated parameters
cS.vParams = 1;

% Hh solution
cS.vHhSolution = 2;

% Aggregates
cS.vAggregates = 3;

% Preamble data
cS.vPreambleData = 5;

% Calibration results
cS.vCalResults = 6;

% Intermediate results from cal_dev
%  so that interrupted calibration can be continued
cS.vCalDev = 7;


%%  Variables that are always saved / loaded for base expNo
%  varNo 400-499

% CPI, base year = 1
cS.vCpi = 401;

% College costs, base year prices
cS.vCollCosts = 402;

% Calibration targets
cS.vCalTargets = 403;

% Cohort earnings profiles (data)
cS.vCohortEarnProfiles = 404;

cS.vCohortSchooling = 405;

% Avg student debt by year
cS.vStudentDebtData = 406;


end