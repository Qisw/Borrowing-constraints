function paramS = param_derived_bc1(paramS, cS)
% Derived parameters
%{
Ref cohort

Checked: 2015-Mar-19
%}

nIq = length(cS.iqUbV);
iCohort = cS.iCohort;

tgS = var_load_bc1(cS.vCalTargets, cS);


% Remove unused params
removeV = {'logYpMean_cV', 'logYpStd_cV', 'ypClass_jcM', 'earn_ascM', 'kMin_acM', 'alphaAM_cV', ...
   'pMean_cV', 'pStd_cV', 'sigmaIQ_cV', 'wCollMean_cV', 'pColl_jcM', 'yParent_jcM', ...
   'm_jcM', 'wColl_jcM', 'prob_acM', 'prob_a_jcM', 'abilGrid_acM', 'prIq_jcM', 'prob_iq_acM', ...
   'prGrad_acM', 'pvEarn_scM', 'abilGridV'};
for i1 = 1 : length(removeV)
   if isfield(paramS, removeV{i1})
      paramS = rmfield(paramS, removeV{i1});
   end
end


% Fix all parameters that are not calibrated (doCal no in cS.doCalV)
%  also add missing params
paramS = cS.pvector.struct_update(paramS, cS.doCalV);


% Parameters taken from data, if not calibrated
% only if always taken from data (never calibrated)
% it does not make sense to have params that are sometimes taken from data
pNameV    = {'logYpMean', 'logYpStd'};
tgNameV   = {'logYpMean_cV', 'logYpStd_cV'};
byCohortV = [1, 1];
for i1 = 1 : length(pNameV)
   pName = pNameV{i1};
   ps = cS.pvector.retrieve(pName);
   if ps.doCal == cS.calNever
      tgV = tgS.(tgNameV{i1});
      if byCohortV(i1) == 1
         tgV = tgV(iCohort);
      end
      paramS.(pName) = tgV;
   end
end


% If not baseline experiment: copy all parameters that were calibrated in baseline but are not 
% calibrated now from baseline params
if cS.expNo ~= cS.expBase
   c0S = const_bc1(cS.setNo, cS.expBase);
   param0S = var_load_bc1(cS.vParams, c0S);
   paramS = cS.pvector.param_copy(paramS, param0S, cS.calBase);
end



%% Preferences: Derived

% Consumption growth rate during work phase
paramS.gC = (paramS.prefBeta * paramS.R) .^ (1 / paramS.prefSigma);
% Growth factors for consumption by age
paramS.cFactorV = paramS.gC .^ (0 : (max(cS.workYears_sV) - 1))';

% Present value factor
%  Present value of consumption = c at work start * pvFactor
%  Tested in value work
paramS.cPvFactor_sV = nan([cS.nSchool, 1]);
for iSchool = 1 : cS.nSchool
   paramS.cPvFactor_sV(iSchool) = sum((paramS.gC ./ paramS.R) .^ (0 : (cS.workYears_sV(iSchool)-1)));
end


%% College costs
%{
If not calibrated: copied from base expNo
But can override by setting collCostExpNo
%}

if ~isempty(cS.expS.collCostExpNo)
   c2S = const_bc1(cS.setNo, cS.expS.collCostExpNo);
   param2S = var_load_bc1(c2S.vParams, c2S);
   paramS.pMean = param2S.pMean;
   paramS.pStd  = param2S.pStd;
end


%% Endowments


% All types have the same probability
paramS.prob_jV = ones([cS.nTypes, 1]) ./ cS.nTypes;

% Order is [pColl, yp, m]
wtM = [1, 0, 0;    paramS.alphaPY, 1, 0;    ...
   paramS.alphaPM, paramS.alphaYM, 1];

gridM = calibr_bc1.endow_grid([paramS.pMean; paramS.logYpMean; 0], ...
   [paramS.pStd; paramS.logYpStd; 1],  wtM, cS);
paramS.pColl_jV      = gridM(:,1);
paramS.yParent_jV    = exp(gridM(:,2));
paramS.m_jV          = gridM(:,3);

if cS.dbg > 10
   % Moments of marginal distributions are checked in test fct for endow_grid
   validateattributes(paramS.yParent_jV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'positive', 'size', [cS.nTypes, 1]})
end


% For now: everyone gets the same college earnings
paramS.wColl_jV = ones([cS.nTypes, 1]) * paramS.wCollMean;
if cS.dbg > 10
   validateattributes(paramS.wColl_jV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'positive', 'size', [cS.nTypes, 1]})
end


% Parental income classes
paramS.ypClass_jV = distrib_lh.class_assign(paramS.yParent_jV, ...
   paramS.prob_jV, cS.ypUbV, cS.dbg);
if cS.dbg > 10
   validateattributes(paramS.ypClass_jV, {'double'}, {'finite', 'nonnan', 'nonempty', 'integer', ...
      'positive', '<=', length(cS.ypUbV)})
end


% % *****  Preference for work as HSG (expressed as tax rate on HS earnings)
% 
% paramS.tax_jV = logistic_bc1(paramS.m_jV, paramS.taxHSzero, paramS.taxHSslope);
% if cS.dbg > 10
%    validateattributes(paramS.tax_jV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
%       '>', -0.95, '<', 0.95, 'size', [cS.nTypes, 1]})
% end

% Range of permitted assets in college (used for approximating value functions)
paramS.kMax = 2e5 ./ cS.unitAcct;


%% Ability grid

% Equal weighted bins
paramS.prob_aV = ones([cS.nAbil, 1]) ./ cS.nAbil;  

% Pr(a | type)
[paramS.prob_a_jM, paramS.abilGrid_aV] = ...
   calibr_bc1.normal_conditional(paramS.prob_aV, paramS.prob_jV, paramS.m_jV, ...
   paramS.alphaAM, cS.dbg);

if cS.dbg > 10
   check_bc1.prob_matrix(paramS.prob_a_jM,  [cS.nAbil, cS.nTypes],  cS);
   validateattributes(paramS.abilGrid_aV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [cS.nAbil, 1]})
end


% ******  Derived

% Pr(a) = sum over j (pr(j) * pr(a|j))
%  should very close to what was exogenously set
for iAbil = 1 : cS.nAbil
   prob_a_jV = paramS.prob_a_jM(iAbil,:);
   paramS.prob_aV(iAbil) = sum(paramS.prob_jV(:) .* prob_a_jV(:));
end   

if cS.dbg > 10
   check_bc1.prob_matrix(paramS.prob_aV,  [cS.nAbil, 1], cS);
end



%%  IQ

% Pr(iq group | j)
paramS.prIq_jM = calibr_bc1.pr_xgroup_by_type(paramS.m_jV, ...
   paramS.prob_jV, paramS.sigmaIQ, cS.iqUbV, cS.dbg);

if cS.dbg > 10
   check_bc1.prob_matrix(paramS.prIq_jM,  [length(cS.iqUbV), cS.nTypes],  cS);
end

% % Pr(iq group | a,c)
%    % wrong but not used +++
% paramS.prob_iq_acM = nan([length(cS.iqUbV), cS.nAbil, cS.nCohorts]);   
% for iCohort = 1 : cS.nCohorts
%    paramS.prob_iq_acM(:,:,iCohort) = calibr_bc1.pr_xgroup_by_type(paramS.abilGrid_acM(:, iCohort), ...
%        paramS.prob_acM(:, iCohort), paramS.sigmaIQ_cV(iCohort), cS.iqUbV, cS.dbg);
% %    calibr_bc1.pr_iq_a(paramS.abilGrid_acM(:, iCohort), ...
% %       paramS.prob_acM(:, iCohort), paramS.sigmaIQ_cV(iCohort), cS.iqUbV, cS.dbg);
% end


% *******  Derived

% Pr(IQ and j) = Pr(iq | j) * Pr(j)
paramS.pr_qjM = paramS.prIq_jM .* (ones([nIq,1]) * paramS.prob_jV(:)');
if cS.dbg > 10
   prSum_jV = sum(paramS.pr_qjM);
   if any(abs(prSum_jV(:) - paramS.prob_jV) > 1e-4)
      error_bc1('Invalid', cS);
   end
   prSum_qV = sum(paramS.pr_qjM, 2);
   if any(abs(prSum_qV(:) - cS.pr_iqV) > 2e-3)  % why so inaccurate?
      error_bc1('Invalid', cS);
   end
end

% Pr(j | IQ) = Pr(j and IQ) / Pr(iq)
pr_qV = sum(paramS.pr_qjM, 2);
paramS.prJ_iqM = paramS.pr_qjM' ./ sum(paramS.pr_qjM(:)) ./ (ones([cS.nTypes,1]) * pr_qV(:)');
if cS.dbg > 10
   prSumV = sum(paramS.prJ_iqM);
   if any(abs(prSumV - 1) > 1e-2)      % Why so inaccurate? +++
      disp(prSumV);
      error_bc1('Probs do not sum to 1', cS);
   end
end
% % Pr(j | IQ)
% %  surprisingly inaccurate +++
% paramS.prJ_iqM = nan([cS.nTypes, nIq]);
% for iIq = 1 : nIq
%    for j = 1 : cS.nTypes
%       paramS.prJ_iqM(j, iIq) = paramS.prIq_jM(iIq,j) * paramS.prob_jV(j) ./ cS.pr_iqV(iIq);
%    end
%    prSum = sum(paramS.prJ_iqM(:, iIq));
%    if abs(prSum - 1) > 1e-3
%       error_bc1('Invalid', cS);
%       % why not more accurate?
%    end
%    paramS.prJ_iqM(:, iIq) = paramS.prJ_iqM(:, iIq) ./ prSum;
% end



%% Graduation probs

% *****  Derived

paramS.prGrad_aV = pr_grad_a_bc1(1 : cS.nAbil, iCohort, paramS, cS);

if cS.dbg > 10
   validateattributes(paramS.prGrad_aV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0, '<=', 1, 'size', [cS.nAbil, 1]})
end



%% Earnings by [model age, school]
% Including skill price

% Returns to ability by s
paramS.phi_sV = [paramS.phiHSG; paramS.phiHSG; paramS.phiCG];
paramS.eHat_sV = paramS.eHatCD + [paramS.dEHatHSG; 0; paramS.dEHatCG];

if isempty(cS.expS.earnExpNo)
   % Targets
   paramS.tgS.pvEarn_sV = tgS.pvEarn_scM(:, cS.iCohort);

   % Present value by [ability, school]
   %  discounted to work start age
   if cS.abilAffectsEarnings == 0
      % Ability does not affect earnings
      paramS.pvEarn_asM = ones([cS.nAbil, 1]) * paramS.tgS.pvEarn_sV';
   else
      dAbilV = (paramS.abilGrid_aV - cS.aBar);
      paramS.pvEarn_asM = nan([cS.nAbil, cS.nSchool]);
      for iSchool = 1 : cS.nSchool
         paramS.pvEarn_asM(:,iSchool) = paramS.tgS.pvEarn_sV(cS.iHSG) * ...
            exp(paramS.eHat_sV(iSchool) + dAbilV .* paramS.phi_sV(iSchool));
      end
   end

else
   % Copy from another experiment
   c2S = const_bc1(cS.setNo, cS.expS.earnExpNo);
   param2S = var_load_bc1(cS.vParams, c2S);
   paramS.tgS.pvEarn_sV = param2S.tgS.pvEarn_sV;
   paramS.pvEarn_asM = param2S.pvEarn_asM;
end
   
if cS.dbg > 10
   validateattributes(paramS.pvEarn_asM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'positive', 'size', [cS.nAbil, cS.nSchool]})
   % Check that log earnings gains are increasing in ability
   % Log gains by schooling
   diffM = diff(log(paramS.pvEarn_asM), 1, 2);
   % Change of those by ability
   diff2M = diff(diffM);
   if any(diff2M(:) < -1e-3)
      disp(log(paramS.pvEarn_asM));
      error_bc1('Earnings gains decreasing in ability', cS);
   end
end



%% Borrowing limits

% Min k at start of each period (detrended)
% kMin_acM = -calibr_bc1.borrow_limits(cS);
% May be taken from base cohort
if isempty(cS.expS.bLimitCohort)
   blCohort = cS.iCohort;
else
   blCohort = cS.expS.bLimitCohort;
end
% blCohort = cS.expS.bLimitBaseCohort * cS.iRefCohort + (1 - cS.expS.bLimitBaseCohort) * iCohort;
paramS.kMin_aV = tgS.kMin_acM(:, blCohort);

if cS.dbg > 10
   validateattributes(paramS.kMin_aV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '<=', 0, 'size', [cS.ageWorkStart_sV(cS.iCG), 1]});
end

end