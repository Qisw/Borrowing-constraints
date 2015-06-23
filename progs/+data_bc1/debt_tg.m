function debtS = debt_tg(tgS, cS)
% Construct debt targets

icNlsy79 = tgS.icNlsy79;

% Load file with all NLSY79 targets
n79S = load(fullfile(cS.dataDir, 'nlsy79_moments.mat'));
n79S = n79S.all_targets;



%% By schooling

% Fraction with debt at end of college (cd, cg)
debtS.debtFracEndOfCollege_scM = nan([2, cS.nCohorts]);
% Mean debt (not conditional on having debt)
debtS.debtMeanEndOfCollege_scM = nan([2, cS.nCohorts]);


% ******  Nlsy79

% Fraction in debt at end of college (dropouts, grads)
debtS.debtFracEndOfCollege_scM(:,tgS.icNlsy79) = [n79S.dropouts_share_with_loans; n79S.grads_share_with_loans];
% Mean debt at end of college (NOT conditional on being in debt)
debtS.debtMeanEndOfCollege_scM(:,tgS.icNlsy79) = ...
   [n79S.mean_dropouts_loans; n79S.mean_grads_loans] ./ tgS.nlsyCpiFactor ./ cS.unitAcct;
% Make not conditional 
debtS.debtMeanEndOfCollege_scM(:,tgS.icNlsy79) = ...
   debtS.debtMeanEndOfCollege_scM(:,tgS.icNlsy79) .* debtS.debtFracEndOfCollege_scM(:,tgS.icNlsy79);

validateattributes(debtS.debtFracEndOfCollege_scM(~isnan(debtS.debtFracEndOfCollege_scM)), {'double'}, ...
   {'nonempty', 'real', 'positive', '<', 0.8})
validateattributes(debtS.debtMeanEndOfCollege_scM(~isnan(debtS.debtMeanEndOfCollege_scM)), {'double'}, ...
   {'nonempty', 'real',  'positive', '<', 2e4 ./ cS.unitAcct})



%% By IQ

% ********  Fraction with debt by IQ

nIq = length(cS.iqUbV);
debtS.debtFracEndOfCollege_qcM = nan([nIq, cS.nCohorts]);
debtS.debtMeanEndOfCollege_qcM = nan([nIq, cS.nCohorts]);

debtS.fracGrads_qcM = nan([nIq, cS.nCohorts]);
debtS.meanGrads_qcM = nan([nIq, cS.nCohorts]);



% *** Nlsy 79

debtS.fracGrads_qcM(:,icNlsy79) = n79S.grads_share_with_loans_byafqt;
debtS.meanGrads_qcM(:,icNlsy79) = n79S.grads_mean_loans_byafqt ./ tgS.nlsyCpiFactor ./ cS.unitAcct;


debtS.debtFracEndOfCollege_qcM(:,tgS.icNlsy79) = n79S.share_with_loans_byafqt;
% Mean debt not conditional
% debtV = [6900, 11200, 16300, 22000]' .* tgS.debtFrac_qcM(:,tgS.icNlsy79) ./ 17400 .* 10200;
debtS.debtMeanEndOfCollege_qcM(:,tgS.icNlsy79) = n79S.mean_loans_byafqt(:) ./ tgS.nlsyCpiFactor ./ cS.unitAcct;

validateattributes(debtS.debtFracEndOfCollege_qcM(~isnan(debtS.debtFracEndOfCollege_qcM)), {'double'}, ...
   {'nonempty', 'real', 'positive', '<', 2e4 ./ cS.unitAcct,  '<', 1})


%% By yP

nYp = length(cS.ypUbV);

debtS.fracGrads_ycM = nan([nYp, cS.nCohorts]);
debtS.meanGrads_ycM = nan([nYp, cS.nCohorts]);

debtS.fracGrads_ycM(:,icNlsy79) = n79S.grads_share_with_loans_byinc;
debtS.meanGrads_ycM(:,icNlsy79) = n79S.grads_mean_loans_byinc ./ tgS.nlsyCpiFactor ./ cS.unitAcct;


% **********  Fraction with debt by yP

debtS.debtFracEndOfCollege_ycM = nan([nYp, cS.nCohorts]);
debtS.debtMeanEndOfCollege_ycM = nan([nYp, cS.nCohorts]);

debtS.debtFracEndOfCollege_ycM(:,tgS.icNlsy79) = n79S.share_with_loans_byinc;
debtS.debtMeanEndOfCollege_ycM(:,tgS.icNlsy79) = n79S.mean_loans_byinc(:) ./ tgS.nlsyCpiFactor ./ cS.unitAcct;


%% Aggregate debt

% *******  Average debt across all students
% Not at end of college but across all enrolled students

debtS.debtMean_cV = nan([cS.nCohorts, 1]);

% Trends in student aid
loadS = var_load_bc1(cS.vStudentDebtData, cS);
% Take average debt at year 2 in college 
%  Early cohorts have 0 debt (year 1)
yrIdxV = max(1, cS.yearStartCollege_cV - loadS.yearV(1) + 3);
debtS.debtMean_cV = loadS.avgDebtV(yrIdxV) ./ tgS.nlsyCpiFactor ./ cS.unitAcct;

validateattributes(debtS.debtMean_cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, ...
   'size', [cS.nCohorts, 1]})


end