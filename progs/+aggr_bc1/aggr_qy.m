function qyS = aggr_qy(aggrS, hhS, paramS, cS)
% Aggregates by [IQ, yp] quartile

dbg = cS.dbg;
nIq = length(cS.iqUbV);
nyp = length(cS.ypUbV);


%% Probabilities

% Prob j among college entrants
pr_jV = paramS.prob_jV .* hhS.v0S.probEnter_jV;
pr_jV = pr_jV ./ sum(pr_jV);


% Pr(j, q) among entrants = Pr(j) * Pr(q|j)
pr_jqM = nan([cS.nTypes, nIq]);
for j = 1 : cS.nTypes
   for iIq = 1 : nIq
      pr_jqM(j, iIq) = pr_jV(j) * paramS.prIq_jM(iIq, j);
   end
end
if dbg > 10
   check_bc1.prob_matrix(pr_jqM(:), [cS.nTypes * nIq, 1], cS);
end
prSum = sum(pr_jqM(:));
pr_jqM = pr_jqM ./ prSum;


% Prob q among entrants
pr_qV = sum(pr_jqM, 1);
if dbg > 10
   check_bc1.prob_matrix(pr_qV(:), [nIq, 1], cS);
end
pr_qV = pr_qV(:) ./ sum(pr_qV);


% Prob j | q  among entrants  =  Pr(j,q) / Pr(q)
prJ_qM = pr_jqM ./ (ones([cS.nTypes, 1]) * pr_qV');
if dbg > 10
   check_bc1.prob_matrix(prJ_qM, [cS.nTypes, nIq], cS);
end


%% Means by [q,y]

qyS.zMeanYear2_qyM = nan([nIq, nyp]);
% Consumption, earnings, hours, debt in first 2 years
qyS.consMeanYear2_qyM = nan([nIq, nyp]);
qyS.earnMeanYear2_qyM = nan([nIq, nyp]);
qyS.debtMeanYear2_qyM = nan([nIq, nyp]);
qyS.debtMeanYear4_qyM = nan([nIq, nyp]);
qyS.pMeanYear2_qyM = nan([nIq, nyp]);

% Mass by [IQ, yp]
qyS.mass_qyM = nan([nIq, nyp]);
qyS.massColl_qyM = nan([nIq, nyp]);
qyS.massGrad_qyM = nan([nIq, nyp]);


debt_tjM = max(0, -aggrS.k_tjM(2:3, :));

for iy = 1 : nyp
   % j in this class
   jIdxV = find(paramS.ypClass_jV == iy);
   % Their masses in college
   massColl_jV = aggrS.massColl_jV(jIdxV);
   % Mass of grad
   massGrad_jV = massColl_jV .* aggrS.prGrad_jV(jIdxV);
   
   % Mass (q,y) = sum over j in y group  Pr(iq|j) * mass(j)
   qyS.mass_qyM(:, iy) = sum(paramS.prIq_jM(:, jIdxV) .* (ones([nIq,1]) * aggrS.mass_jV(jIdxV)'), 2);

   % Mass in college by [iq, j] for the right yp group
   qyS.massColl_qyM(:, iy) = sum(paramS.prIq_jM(:, jIdxV) .* (ones([nIq,1]) * massColl_jV(:)'), 2);

   % Mass graduating college by [iq, j] for the right yp group
   qyS.massGrad_qyM(:, iy) = sum(paramS.prIq_jM(:, jIdxV) .* (ones([nIq,1]) * massGrad_jV(:)'), 2);

   for iIq = 1 : nIq
      % E(x | q,y) = sum over j in y class:  Prob(j | q) * x(j)
      probV = prJ_qM(jIdxV, iIq);
      probV = probV ./ sum(probV);
      
      qyS.zMeanYear2_qyM(iIq, iy) = sum(probV .* hhS.v0S.zColl_jV(jIdxV));
      qyS.pMeanYear2_qyM(iIq, iy) = sum(probV .* paramS.pColl_jV(jIdxV));
      qyS.consMeanYear2_qyM(iIq, iy) = sum(probV .* aggrS.cons_tjM(1, jIdxV)');
      qyS.earnMeanYear2_qyM(iIq, iy) = sum(probV .* aggrS.earn_tjM(1, jIdxV)');
      qyS.hoursMeanYear2_qyM(iIq, iy) = sum(probV .* aggrS.hours_tjM(1, jIdxV)');
      qyS.debtMeanYear2_qyM(iIq, iy) = sum(probV .* debt_tjM(1, jIdxV)');
      qyS.debtMeanYear4_qyM(iIq, iy) = sum(probV .* debt_tjM(2, jIdxV)');
   end
end

% Fraction college
qyS.fracEnter_qyM = qyS.massColl_qyM ./ qyS.mass_qyM;
% Fraction graduating, NOT conditional on entry
qyS.fracGrad_qyM = qyS.massGrad_qyM ./ qyS.mass_qyM;

if dbg > 10
   validateattributes(qyS.fracGrad_qyM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0,  '<=', 1})
end


%% Regression: college entry on [iq, yp] quartiles

for i1 = 1 : 2
   if i1 == 1
      wt_qyM = [];
   elseif i1 == 2
      wt_qyM = sqrt(qyS.mass_qyM);
   else
      error('Invalid');
   end
   
   [betaIq, betaYp] = results_bc1.regress_qy(qyS.fracEnter_qyM, wt_qyM, cS.iqUbV(:), cS.ypUbV(:), dbg);
   
   if i1 == 1
      qyS.betaIq = betaIq;
      qyS.betaYp = betaYp;
   elseif i1 == 2
      qyS.betaIqWeighted = betaIq;
      qyS.betaYpWeighted = betaYp;
   else
      error('Invalid');
   end
end



end