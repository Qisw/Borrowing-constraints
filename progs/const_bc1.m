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

% How many nodes to use on kure
cS.kureS.nNodes = 4;
% Run parallel on kure?
cS.kureS.parallel = 1;
% Profile to use (local: no need to start multiple matlab instances)
cS.kureS.profileStr = 'local';


% 1 = $unitAcct
cS.unitAcct = 1e3;

% params are calibrated never / only for base exper / also for other exper
cS.calNever = 0;
cS.calBase = 1;
cS.calExp = 2;
cS.doCalValueV = [cS.calNever, cS.calBase, cS.calExp];

% Collection of calibrated parameters
pvec = pvector(30, cS.doCalValueV);

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

% Bounds for transformed guesses
cS.guessLb = 1;
cS.guessUb = 2;

% Gross interest rate (if not calibrated)
cS.R = 1.04;


%% Default parameters: Demographics, Preferences

% Cohorts modeled
cS.bYearV = [1915, 1940, 1961, 1979]';
% For each cohort: calibrate time varying parameters with these experiments
cS.bYearExpNoV = [203, 202, NaN, NaN];
% Cross sectional calibration for this cohort
cS.iRefCohort = find(cS.bYearV == 1961);
cS.nCohorts = length(cS.bYearV);


% Age at model age 1
cS.age1 = 18;
% Last physical age
cS.physAgeLast = 75;
% Retirement age
% cS.physAgeRetire = 65;

% Is curvature of u(c) the same in college / at work?
cS.ucCurvatureSame = 1;

% Discount factor
pvec = pvec.change('prefBeta', '\beta', 'Discount factor', 0.98, 0.8, 1.1, cS.calNever);
% Curvature of u(c) at work
pvec = pvec.change('workSigma', '\varphi_{w}', 'Curvature of utility', 2, 1, 5, cS.calNever);
% Weight on u(c) at work. To prevent overconsumption
pvec = pvec.change('prefWtWork', '\omega_{w}', 'Weight on u(c) at work', 3, 1, 10, cS.calBase);
% Same for college. Normalize to 1
pvec = pvec.change('prefWt', '\omega_{c}', 'Weight on u(c)', 1, 0.01, 1.1, cS.calNever);
% Curvature of u(c) in college
pvec = pvec.change('prefSigma', '\varphi_{c}', 'Curvature of utility', 2, 1, 5, cS.calNever);
% Curvature of u(leisure) in college
pvec = pvec.change('prefRho', '\varphi_{l}', 'Curvature of utility', 2, 1, 5, cS.calNever);
% Weight on leisure
pvec = pvec.change('prefWtLeisure', '\omega_{l}', 'Weight on leisure', 0.5, 0.01, 5, cS.calBase);
% Consumption floor
cS.cFloor = 500 ./ cS.unitAcct;
% Leisure floor
cS.lFloor = 0.01;

% Parental preferences
pvec = pvec.change('puSigma', '\varphi_{p}', 'Curvature of parental utility', 0.35, 0.1, 5, cS.calBase);
% Time varying: to match transfer data
pvec = pvec.change('puWeight', '\omega_{p}', 'Weight on parental utility', 1, 0.001, 2, cS.calBase);

% Pref shock at entry. For numerical reasons only. Fixed.
pvec = pvec.change('prefScaleEntry', '\gamma', 'Preference shock at college entry', 0.1, 0.05, 1, cS.calNever);
% Pref for working as HSG. Includes leisure. No good scale. +++
%  Calibrate in experiment to match schooling average
pvec = pvec.change('prefHS', '\bar{\eta}', 'Preference for HS', 0, -5, 10, cS.calBase);
% % Tax on HS earnings (a preference shock). 2 parameters. Intercept and slope. Both in (-1,1)
% pvec = pvec.change('taxHSzero', '\tau{0}', 'Tax on college earnings',   0, -0.6, 0.6, cS.calNever);
% pvec = pvec.change('taxHSslope',  '\tau{1}', 'Tax on college earnings', 0, -0.8, 0.8, cS.calNever);


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
pvec = pvec.change('alphaPY', '\alpha_{p,y}', 'Correlation, $p,y$', 0.3, -5, 5, cS.calBase);
pvec = pvec.change('alphaPM', '\alpha_{p,m}', 'Correlation, $p,m$', 0.4, -5, 5, cS.calBase);
pvec = pvec.change('alphaYM', '\alpha_{y,m}', 'Correlation, $y,m$', 0.5, -5, 5, cS.calBase);
% Does not matter right now. Until we have a direct role for ability
%  But want to be able to change signal precision (rather than grad prob function) for experiments
pvec = pvec.change('alphaAM', '\alpha_{a,m}', 'Correlation, $a,m$', 2, 0.1, 5, cS.calBase);

% Marginal distributions
pvec = pvec.change('pMean', '\mu_{p}', 'Mean of $p$', ...
   (5e3 ./ cS.unitAcct), (-5e3 ./ cS.unitAcct), (1.5e4 ./ cS.unitAcct), cS.calBase);
pvec = pvec.change('pStd', '\sigma_{p}', 'Std of $p$', 2e3 ./ cS.unitAcct, ...
   5e2 ./ cS.unitAcct, 1e4 ./ cS.unitAcct, cS.calBase);

% This will be taken directly from data (so not calibrated)
%  but is calibrated for other cohorts
pvec = pvec.change('logYpMean', '\mu_{y}', 'Mean of $\log(y_{p})$', ...
   log(5e4 ./ cS.unitAcct), log(5e3 ./ cS.unitAcct), log(5e5 ./ cS.unitAcct), cS.calNever);
% Assumed time invariant
pvec = pvec.change('logYpStd', '\sigma_{y}', 'Std of $\log(y_{p})$', 0.3, 0.05, 0.6, cS.calNever);

pvec = pvec.change('sigmaIQ', '\sigma_{IQ}', 'Std of IQ noise',  0.35, 0.2, 2, cS.calBase);


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
pvec = pvec.change('prGradMin', '\pi_{0}', 'Min $\pi_{a}$', 0.1, 0.01, 0.5, cS.calBase);
pvec = pvec.change('prGradMax', '\pi_{1}', 'Max $\pi_{a}$', 0.8, 0.7, 0.99, cS.calBase);
pvec = pvec.change('prGradMult', '\pi_{a}', 'In $\pi_{a}$', 0.7, 0.1, 5, cS.calBase);
% Governs how steep the curve is. Don't allow too low. Algorithm will get stuck
pvec = pvec.change('prGradExp', '\pi_{b}', 'In $\pi_{a}$',  1, 0.3, 5, cS.calBase);
pvec = pvec.change('prGradPower', '\pi_{c}', 'In $\pi_{a}$', 1, 0.1, 2, cS.calNever);
pvec = pvec.change('prGradABase', 'a_{0}', 'In $\pi_{a}$', 0, 0, 0.3, cS.calNever);

% nCohorts = length(cS.bYearV);
pvec = pvec.change('wCollMean', 'Mean w_{coll}', 'Maximum earnings in college', ...
   2e4 ./ cS.unitAcct, 5e3 ./ cS.unitAcct, 1e5 ./ cS.unitAcct, cS.calBase);

% Free college consumption and leisure
% Specified as: how much does the highest m type get? The lowest m type gets 0
% In between: linear in m
pvec = pvec.change('cCollMax', 'Max cColl', 'Max free consumption', ...
   0,  0,  1e4 ./ cS.unitAcct, cS.calNever);
pvec = pvec.change('lCollMax', 'Max lColl', 'Max free leisure', ...
   0, 0, 0.5, cS.calNever);


%% Defaults: work

cS.abilAffectsEarnings = 1;

% Earnings are determined by phi(s) * (a - aBar)
%  phi(s) taken from gradpred
pvec = pvec.change('phiHSG', '\phi_{HSG}', 'Return to ability, HSG', 0.155,  0.02, 0.2, cS.calNever);
pvec = pvec.change('phiCG',  '\phi_{CG}',  'Return to ability, CG',  0.194, 0.02, 0.2, cS.calNever);

% Scale factors of lifetime earnings (log)
pvec = pvec.change('eHatCD', '\hat_{e}_{CD}', 'Log skill price CD', 0, -3, 1, cS.calBase);
pvec = pvec.change('dEHatHSG', 'd\hat_{e}_{HSG}', 'Skill price gap HSG', -0.1, -3, 0, cS.calBase);
pvec = pvec.change('dEHatCG',  'd\hat_{e}_{CG}',  'Skill price gap CG',   0.1,  0, 3, cS.calBase);
% pvec = pvec.change('eHatCG',  '\hat_{e_{CG}}',  'Log skill price CG',  -1, -4, 1, cS.calBase);


%% Default: other

% Gross interest rate
pvec = pvec.change('R', 'R', 'Interest rate', cS.R, 1, 1.1, cS.calNever);

% Base year for prices
cS.cpiBaseYear = 2010;

% Last year with data for anything
cS.lastDataYear = 2014;
% First year with data for anything (cpi starts in 1913)
cS.firstDataYear = 1913;

% Set no for cps routines
cS.cpsSetNo = 1;


%% Which calibration targets to use?
% These are targets we would like to match. Targets that are NaN are ignored.

% PV of lifetime earnings by schooling
cS.tgPvLty = 1;

% College costs
   % add target by yp +++
cS.tgPMean  = 1;
cS.tgPStd   = 1;
cS.tgPMeanIq = 1;
cS.tgPMeanYp = 0;


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

% Financing shares (only constructed for cohorts where transfers etc not available)
cS.tgFinShares = 1;


%% Parameter sets

if setNo == cS.setDefault
   cS.setStr = 'Default';
   cS.iCohort = cS.iRefCohort;
   
elseif setNo == 2
   cS.setStr = 'Ability does not affect earnings';
   cS.abilAffectsEarnings = 0;
   
elseif setNo == 3
   % For testing. Calibrate to another cohort
   cS.setStr = 'Test with another cohort';
   [~, cS.iCohort] = min(abs(cS.bYearV - 1940));
   
elseif setNo == 4
   % Higher curvature of u(c) during college
   % Is curvature of u(c) the same in college / at work?
   cS.ucCurvatureSame = 0;
    % Curvature of u(c) in college
   pvec = pvec.change('prefSigma', '\varphi_{c}', 'Curvature of utility', 4, 1, 5, cS.calNever);
   
elseif setNo == 5
   cS.setStr = 'Free college consumption / leisure';
   pvec = pvec.calibrate('cCollMax', cS.calBase);
   pvec = pvec.calibrate('lCollMax', cS.calBase);
   
elseif setNo == 6
   cS.setStr = 'Alt debt stats';
   pvec = pvec.calibrate('cCollMax', cS.calBase);
   pvec = pvec.calibrate('lCollMax', cS.calBase);
   

else
   error('Invalid');
end


%% Experiment settings

[expS, pvec, cS.doCalV, cS.iCohort] = calibr_bc1.exp_settings(pvec, cS);


%% Derived constants

if exist('/Users/lutz', 'dir')
   cS.runLocal = 1;
   cS.runParallel = 1; 
   cS.nNodes = 4;
   cS.parProfileStr = 'local';
else
   cS.runLocal = 0;
   cS.runParallel = cS.kureS.parallel;
   cS.nNodes = cS.kureS.nNodes;
   % Default (empty) for killdevil. Local for kure
   cS.parProfileStr = cS.kureS.profileStr;
end


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
   pvec = pvec.change('phiHSG', '\phi_{HSG}', 'Return to ability, HSG', 0,  0.02, 0.2, cS.calNever);
   pvec = pvec.change('phiCG',  '\phi_{CG}',  'Return to ability, CG',  0, 0.02, 0.2, cS.calNever);
   pvec = pvec.change('eHatCD', [], [], 0, [], [], cS.calNever);
   pvec = pvec.change('dEHatHSG', [], [], 0, [], [], cS.calNever);
   pvec = pvec.change('dEHatCG', [], [], 0, [], [], cS.calNever);
end

if cS.ucCurvatureSame == 1
   % Do not calibrate curvature of work utility
   % It is the same as college utility
   pvec = pvec.calibrate('workSigma', cS.calNever);
end


%% Directories

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


%% Clean up

cS.expS = expS;
cS.pvector = pvec;


end