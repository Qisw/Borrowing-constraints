function [prIq_jM, pr_qjM, prJ_iqM] = iq_param(paramS, cS)
% Set IQ related derived params

nIq = length(cS.iqUbV);


% Pr(iq group | j)
prIq_jM = calibr_bc1.pr_xgroup_by_type(paramS.m_jV, ...
   paramS.prob_jV, paramS.sigmaIQ, cS.iqUbV, cS.dbg);

if cS.dbg > 10
   check_bc1.prob_matrix(prIq_jM,  [length(cS.iqUbV), cS.nTypes],  cS);
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


% Pr(IQ and j) = Pr(iq | j) * Pr(j)
pr_qjM = prIq_jM .* (ones([nIq,1]) * paramS.prob_jV(:)');

if cS.dbg > 10
   prSum_jV = sum(pr_qjM);
   if any(abs(prSum_jV(:) - paramS.prob_jV) > 1e-4)
      error_bc1('Invalid', cS);
   end
   prSum_qV = sum(pr_qjM, 2);
   if any(abs(prSum_qV(:) - cS.pr_iqV) > 2e-3)  % why so inaccurate?
      error_bc1('Invalid', cS);
   end
end


% Pr(j | IQ) = Pr(j and IQ) / Pr(iq)
pr_qV = sum(pr_qjM, 2);
prJ_iqM = pr_qjM' ./ sum(pr_qjM(:)) ./ (ones([cS.nTypes,1]) * pr_qV(:)');

if cS.dbg > 10
   validateattributes(prJ_iqM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, '<=', 1})
   prSumV = sum(prJ_iqM);
   if any(abs(prSumV - 1) > 1e-2)      % Why so inaccurate? +++
      disp(prSumV);
      error_bc1('Probs do not sum to 1', cS);
   end
end


% % Pr(j | IQ)
% %  surprisingly inaccurate +++
% prJ_iqM = nan([cS.nTypes, nIq]);
% for iIq = 1 : nIq
%    for j = 1 : cS.nTypes
%       prJ_iqM(j, iIq) = prIq_jM(iIq,j) * paramS.prob_jV(j) ./ cS.pr_iqV(iIq);
%    end
%    prSum = sum(prJ_iqM(:, iIq));
%    if abs(prSum - 1) > 1e-3
%       error_bc1('Invalid', cS);
%       % why not more accurate?
%    end
%    prJ_iqM(:, iIq) = prJ_iqM(:, iIq) ./ prSum;
% end




end