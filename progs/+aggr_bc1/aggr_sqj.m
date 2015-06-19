% Aggregates:  By [school, IQ, j]
function [sqS, mass_sqjM, fracEnter_qV, fracGrad_qV] = ...
   aggr_sqj(aggrS, hhS, paramS, cS)

frac_qV = diff([0; cS.iqUbV]);
nIq = length(cS.iqUbV);

% Mass by [s, iq, j]
sizeV = [cS.nSchool, cS.nIQ, cS.nTypes];
mass_sqjM = zeros(sizeV);

for j = 1 : cS.nTypes
   for iSchool = 1 : cS.nSchool
      for iIQ = 1 : cS.nIQ
         % Mass(s,iq,j) = mass(s,j) * pr(iq|j)
         %  because IQ is not correlated with anything other than j (not with decisions and grad
         %  probs)
         mass_sqjM(iSchool,iIQ,j) = aggrS.mass_sjM(iSchool,j) * paramS.prIq_jM(iIQ,j);
      end
   end
end

% Mass by [s, iq]
sqS.mass_sqM = sum(mass_sqjM, 3);

% Fraction s | iq = mass(s,q) / mass(q)
sqS.fracS_iqM = nan([cS.nSchool, nIq]);
for i1 = 1 : nIq
   sqS.fracS_iqM(:,i1) = sqS.mass_sqM(:,i1) ./ sum(sqS.mass_sqM(:,i1));
end

% Fraction that enters / grads | IQ
%  grad not conditional on entry
fracEnter_qV = 1 - sqS.fracS_iqM(cS.iHSG, :)';
fracGrad_qV  = sqS.fracS_iqM(cS.iCG, :)';

   
%%  Means by [s,q]

% prJ_sqM = nan([cS.nTypes, cS.nSchool, nIq]);
% for j = 1 : cS.nTypes
%    % Pr(j | s,q) = Pr(s,q,j) / Pr(s,q)
%    %  Ratio of probs = ratio of masses (b/c total mass is the same)
%    prJ_sqM(j, :,:) = mass_sqjM(:,:, j) ./ max(1e-6, sqS.mass_sqM);
% end
% 
% validateattributes(prJ_sqM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, ...
%    '<=', 1})
% prSumV = sum(prJ_sqM, 1);
% if any(abs(prSumV(:) - 1) > 1e-4)
%    error_bc1('Invalid', cS);
% end
% 
% 
% % ******  Compute means
% % Over first 2 years in college
% 
% sqS.zMean_sqM = nan([cS.nSchool, nIq]);
% sqS.consMean_sqM = nan([cS.nSchool, nIq]);
% sqS.earnMean_sqM = nan([cS.nSchool, nIq]);
% sqS.hoursMean_sqM = nan([cS.nSchool, nIq]);
% for iSchool = 1 : cS.nSchool
%    for iIq = 1 : nIq
%       pr_jV = prJ_sqM(:, iSchool, iIq);
%       pr_jV = pr_jV ./ sum(pr_jV);
%       sqS.zMean_sqM(iSchool, iIq) = sum(pr_jV .* hhS.v0S.zColl_jV);
%       sqS.consMean_sqM(iSchool, iIq) = sum(pr_jV .* aggrS.cons_tjM(1,:)');
%    end
% end
   

   
%% Self test   
if cS.dbg > 10
   validateattributes(mass_sqjM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0, 'size', sizeV})
   validateattributes(sqS.mass_sqM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0, 'size', [cS.nSchool, nIq]})
   validateattributes(sqS.fracS_iqM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [cS.nSchool, nIq], 'positive', '<', 1})
   % Mass(s,q) should sum to mass by iq
   sumV = sum(sqS.mass_sqM);
   if any(abs(sumV(:) ./ aggrS.totalMass - frac_qV) > 1e-3)    % why so imprecise? +++
      error('Invalid');
   end

   % Another way of computing frac enter | IQ
   %  Prob(enter \ IQ) = sum over j  (Pr(J | IQ) * Pr(enter | j))
   %  Not super accurate b/c pr(j | iq) is not (see param_derived)
   for iIq = 1 : nIq
      fracEnter = sum(paramS.prJ_iqM(:, iIq) .* hhS.v0S.probEnter_jV);
      if abs(fracEnter - fracEnter_qV(iIq)) > 2e-3
         error_bc1('Invalid', cS);
      end
   end
end

end