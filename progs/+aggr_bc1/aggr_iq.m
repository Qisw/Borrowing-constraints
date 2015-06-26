%% By IQ
function [iqS, debtFracEoc_qV, debtMeanEoc_qV] = aggr_iq(aggrS, hhS, paramS, cS)

% For consistency: copy these
iqS.fracEnter_qV = aggrS.fracEnter_qV;
iqS.fracGrad_qV  = aggrS.fracGrad_qV;

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
iqS.transfer_qV = nan([nIq, 1]);

% Fraction in debt at end of college
debtFracEoc_qV = nan([nIq, 1]);
% Mean debt, NOT conditional on being in debt (end of college)
debtMeanEoc_qV = nan([nIq, 1]);
% Same assuming that transfers are paid out each period
iqS.debtAltFrac_qV = nan([nIq, 1]);
iqS.debtAltMean_qV = nan([nIq, 1]);
% Debt at end of year 2
iqS.debtMeanYear2_qV = nan([nIq, 1]);
iqS.debtFracYear2_qV = nan([nIq, 1]);

% Debt at end of year 4
iqS.debtFracYear4_qV = zeros([nIq, 1]);
iqS.debtMeanYear4_qV = zeros([nIq, 1]);

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
   iqS.transfer_qV(iIq) = sum(wt_jV .* hhS.v0S.zColl_jV);
   
   % Debt at end of year 2
   iqS.debtMeanYear2_qV(iIq) = sum(wt_jV .* debt_tjM(1,:)');
   iqS.debtFracYear2_qV(iIq) = sum(wt_jV .* (debt_tjM(1,:)' > 0));
   
   
   % *** Debt stats at end of college
   % Mass that exits at end of years 2 / 4, by j
   mass_tjM = squeeze(aggrS.mass_sqjM([cS.iCD, cS.iCG], iIq,:));
%    % debt at end of years 2 and 4
%    debt_tjM = max(0, -aggrS.k_tjM(2:3, :));
   debtFracEoc_qV(iIq) = sum(mass_tjM(:) .* (debt_tjM(:) > 0)) ./ sum(mass_tjM(:));
   % Meand debt (not conditional)
   debtMeanEoc_qV(iIq) = sum(mass_tjM(:) .* debt_tjM(:)) ./ sum(mass_tjM(:));
 
   % Debt at end of year 4
   mass_jV = mass_tjM(2,:);
   debt_jV = debt_tjM(2,:);
   iqS.debtFracYear4_qV(iIq) = sum(mass_jV .* (debt_jV > 0)) ./ sum(mass_jV);
   iqS.debtMeanYear4_qV(iIq) = sum(mass_jV .* debt_jV) ./ sum(mass_jV);

   % debt at end of years 2 and 4 (transfers paid out each period)
   iqS.debtAltFrac_qV(iIq) = sum(mass_tjM(:) .* (debtAlt_tjM(:) > 0)) ./ sum(mass_tjM(:));
   % Meand debt (not conditional)
   iqS.debtAltMean_qV(iIq) = sum(mass_tjM(:) .* debtAlt_tjM(:)) ./ sum(mass_tjM(:));
end


if cS.dbg > 10
   validateattributes(iqS.pMean_qV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [nIq, 1]})
   validateattributes(iqS.debtMeanYear2_qV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0})
   validateattributes(iqS.debtFracYear2_qV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0, '<=', 1})
   validateattributes(iqS.debtMeanYear4_qV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0})
   validateattributes(iqS.debtFracYear4_qV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0, '<=', 1})
end


end
