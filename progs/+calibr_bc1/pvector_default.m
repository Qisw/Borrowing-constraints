function pvec = pvector_default(cS)
% Defaults: which params are calibrated?
%{
Only set calBase and calNever here
Experiments can override with calExper
%}

symS = helper_bc1.symbols;

% Collection of calibrated parameters
pvec = pvector(30, cS.doCalValueV);


%% Preferences

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


% Parental preferences
pvec = pvec.change('puSigma', '\varphi_{p}', 'Curvature of parental utility', 0.35, 0.1, 5, cS.calBase);
% Time varying: to match transfer data
pvec = pvec.change('puWeightMean', '\mu_{p}', 'Weight on parental utility', 1, 0.001, 2, cS.calBase);
pvec = pvec.change('puWeightStd',  '\sigma_{p}', 'Std of weight on parental utility', 0, 0.001, 2, cS.calBase);
pvec = pvec.change('alphaPuM', '\alpha_{p,m}', 'Correlation, $\omega_{p},m$', 0, -5, 5, cS.calBase);


% Pref shock at entry. For numerical reasons only. Fixed.
pvec = pvec.change('prefScaleEntry', '\gamma', 'Preference shock at college entry', 0.1, 0.05, 0.5, cS.calNever);
% Pref for working as HSG. Includes leisure. No good scale. +++
%  Calibrate in experiment to match schooling average
pvec = pvec.change('prefHS', '\bar{\eta}', 'Preference for HS', 0, -5, 10, cS.calBase);
% If not 0: prefHS(j) varies from prefHS - 0.5*dPrefHS to prefHS + 0.5*dPrefHS
pvec = pvec.change('dPrefHS', '\Delta\bar{\eta}', 'Range of HS preference', 0, 0, 5, cS.calNever);


%% Default: endowments


% Endowment correlations
pvec = pvec.change('alphaPY', '\alpha_{\tau,y}', 'Correlation, $\tau,y$', 0.3, -5, 5, cS.calBase);
pvec = pvec.change('alphaPM', '\alpha_{\tau,m}', 'Correlation, $\tau,m$', 0.4, -5, 5, cS.calBase);
pvec = pvec.change('alphaYM', '\alpha_{y,m}', 'Correlation, $y,m$', 0.5, -5, 5, cS.calBase);
% Does not matter right now. Until we have a direct role for ability
%  But want to be able to change signal precision (rather than grad prob function) for experiments
pvec = pvec.change('alphaAM', '\alpha_{a,m}', 'Correlation, $a,m$', 2, 0.1, 5, cS.calBase);

% Marginal distributions
pvec = pvec.change('pMean', '\mu_{\tau}', 'Mean of $\tau$', ...
   (5e3 ./ cS.unitAcct), (-5e3 ./ cS.unitAcct), (1.5e4 ./ cS.unitAcct), cS.calBase);
pvec = pvec.change('pStd', '\sigma_{\tau}', 'Std of $\tau$', 2e3 ./ cS.unitAcct, ...
   5e2 ./ cS.unitAcct, 1e4 ./ cS.unitAcct, cS.calBase);

% This will be taken directly from data (so not calibrated)
%  but is calibrated for other cohorts
pvec = pvec.change('logYpMean', '\mu_{y}', 'Mean of $\log(y_{p})$', ...
   log(5e4 ./ cS.unitAcct), log(5e3 ./ cS.unitAcct), log(5e5 ./ cS.unitAcct), cS.calNever);
% Assumed time invariant
pvec = pvec.change('logYpStd', '\sigma_{y}', 'Std of $\log(y_{p})$', 0.3, 0.05, 0.6, cS.calNever);

pvec = pvec.change('sigmaIQ', '\sigma_{IQ}', 'Std of IQ noise',  0.35, 0.2, 2, cS.calBase);


%% Default: schooling

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
pvec = pvec.change('wCollMean', 'w_{c}', 'College wage', ...
   2e4 ./ cS.unitAcct, 5e3 ./ cS.unitAcct, 1e5 ./ cS.unitAcct, cS.calBase);

% Free college consumption and leisure
% Specified as: how much does the highest m type get? The lowest m type gets 0
% In between: linear in m
pvec = pvec.change('cCollMax', [symS.cColl, '_{max}'], 'Max free consumption', ...
   0,  0,  1e4 ./ cS.unitAcct, cS.calBase);
pvec = pvec.change('lCollMax', [symS.lColl, '_{max}'], 'Max free leisure', ...
   0, 0, 0.5, cS.calBase);


%% Defaults: work

% Earnings are determined by phi(s) * (a - aBar)
%  phi(s) taken from gradpred
pvec = pvec.change('phiHSG', '\phi_{HSG}', 'Return to ability, HSG', 0.155,  0.02, 0.2, cS.calNever);
pvec = pvec.change('phiCG',  '\phi_{CG}',  'Return to ability, CG',  0.194, 0.02, 0.2, cS.calNever);

% Scale factors of lifetime earnings (log)
pvec = pvec.change('eHatCD', [symS.pvEarnSchool, '_{CD}'], 'Log skill price CD', 0, -3, 1, cS.calBase);
% Lifetime earnings premium (discounted to work start) for lowest ability
%  Should be < 0 for HSG (going to college raises earnings)
pvec = pvec.change('dEHatHSG', ['d', symS.pvEarnSchool, '_{HSG}'], 'Skill price gap HSG', -0.1, -1, 0, cS.calBase);
%  Should be > 0 for CG
pvec = pvec.change('dEHatCG',  ['d', symS.pvEarnSchool, '_{CG}'],  'Skill price gap CG',   0.1, 0, 2, cS.calBase);
% pvec = pvec.change('eHatCG',  '\hat{e}_{CG}',  'Log skill price CG',  -1, -4, 1, cS.calBase);

%% Other

% Gross interest rate
pvec = pvec.change('R', 'R', 'Interest rate', cS.R, 1, 1.1, cS.calNever);


end