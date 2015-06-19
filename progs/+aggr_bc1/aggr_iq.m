%% By IQ
function [iqS, transfer_qV, ...
   fracDebtEoc_qV, meanDebtEoc_qV, fracDebtAlt_qV, meanDebtAlt_qV, ...
   fracDebtYear2_qV, meanDebtYear2_qV] = aggr_iq(aggrS, hhS, paramS, cS)

nIq = length(cS.iqUbV);

% Mean parental income by IQ quartile (for all)
iqS.logYpMean_qV = nan([nIq, 1]);

% Mean college cost (for entrants)
iqS.pMean_qV = nan([nIq, 1]);
% Average hours, first 2 years in college (for entrants)
iqS.hoursCollMean_qV = nan([nIq, 1]);
% Average earnings, first 2 years in college (for entrants)
iqS.earnCollMean_qV = nan([nIq, 1]);
iqS.consCollMean_qV = nan([nIq, 1]);
% Average annual transfer (for entrants)
transfer_qV = nan([nIq, 1]);

% Fraction in debt at end of college
fracDebtEoc_qV = nan([nIq, 1]);
% Mean debt, NOT conditional on being in debt (end of college)
meanDebtEoc_qV = nan([nIq, 1]);
% Same assuming that transfers are paid out each period
fracDebtAlt_qV = nan([nIq, 1]);
meanDebtAlt_qV = nan([nIq, 1]);
% Debt at end of year 2
meanDebtYear2_qV = nan([nIq, 1]);
fracDebtYear2_qV = nan([nIq, 1]);

% Debt levels (0 for those with positive k)
%  at end of years 2 and 4 in college
debt_tjM = max(0, -aggrS.k_tjM(2:3, :));
% Same, transfers paid out each period
debtAlt_tjM = max(0, -aggrS.kTrue_tjM(2:3, :));


for iIq = 1 : nIq
   % *******  All

   % Mass by j for this IQ
   wtV = aggrS.mass_jV .* paramS.prIq_jM(iIq, :)';
   % Parental income (not conditional on college)
   iqS.logYpMean_qV(iIq) = sum(wtV .* log(paramS.yParent_jV)) ./ sum(wtV);

   
   % *******  In college
   
   % Mass with IQ and j in college
   wt_jV = aggrS.massColl_jV .* paramS.prIq_jM(iIq, :)';
   wt_jV = wt_jV ./ sum(wt_jV);
   
   % First 2 years in college
   iqS.pMean_qV(iIq) = sum(wt_jV .* paramS.pColl_jV);   
   iqS.hoursCollMean_qV(iIq) = sum(wt_jV .* aggrS.hours_tjM(1,:)');
   iqS.earnCollMean_qV(iIq) = sum(wt_jV .* aggrS.earn_tjM(1,:)');
   iqS.consCollMean_qV(iIq) = sum(wt_jV .* aggrS.cons_tjM(1,:)');
   transfer_qV(iIq) = sum(wt_jV .* hhS.v0S.zColl_jV);
   
   % Debt at end of year 2
   meanDebtYear2_qV(iIq) = sum(wt_jV .* debt_tjM(1,:)');
   fracDebtYear2_qV(iIq) = sum(wt_jV .* (debt_tjM(1,:)' > 0));
   
   
   % *** Debt stats at end of college
   % Mass that exits at end of years 2 / 4, by j
   mass_tjM = squeeze(aggrS.mass_sqjM([cS.iCD, cS.iCG], iIq,:));
%    % debt at end of years 2 and 4
%    debt_tjM = max(0, -aggrS.k_tjM(2:3, :));
   fracDebtEoc_qV(iIq) = sum(mass_tjM(:) .* (debt_tjM(:) > 0)) ./ sum(mass_tjM(:));
   % Meand debt (not conditional)
   meanDebtEoc_qV(iIq) = sum(mass_tjM(:) .* debt_tjM(:)) ./ sum(mass_tjM(:));

   % debt at end of years 2 and 4 (transfers paid out each period)
   fracDebtAlt_qV(iIq) = sum(mass_tjM(:) .* (debtAlt_tjM(:) > 0)) ./ sum(mass_tjM(:));
   % Meand debt (not conditional)
   meanDebtAlt_qV(iIq) = sum(mass_tjM(:) .* debtAlt_tjM(:)) ./ sum(mass_tjM(:));
end


if cS.dbg > 10
   validateattributes(iqS.pMean_qV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [nIq, 1]})
   validateattributes(meanDebtYear2_qV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0})
   validateattributes(fracDebtYear2_qV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0, '<=', 1})
end


end
