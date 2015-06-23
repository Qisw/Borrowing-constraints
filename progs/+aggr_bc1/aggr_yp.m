% Aggregates: By parental income class
function [ypS, debtFrac_yV, debtMean_yV, debtFracTrue_yV, debtMeanTrue_yV, ...
   logYpMean_yV] = aggr_yp(aggrS, hhS, paramS, cS)

   nIq = length(cS.iqUbV);
   nyp = length(cS.ypUbV);
   
   % Fin stats for *first 2 years* in college
   % Initialize all with zeros so that deviation is valid when nobody goes to college in a group
   ypS.pColl_yV = zeros([nyp, 1]);
   % ANNUAL transfer (to be comparable with data targets
   ypS.transfer_yV = zeros([nyp, 1]);
   ypS.fracEnter_yV = zeros([nyp, 1]);
   ypS.fracGrad_yV = zeros([nyp, 1]);
   ypS.hoursCollMean_yV = zeros([nyp, 1]);
   ypS.earnCollMean_yV = zeros([nyp, 1]);
   ypS.consCollMean_yV = zeros([nyp, 1]);
   
   % Debt at end of college
   debtFrac_yV = zeros([nyp, 1]);
   debtMean_yV = zeros([nyp, 1]);
   % Assuming that transfers are paid out each period
   debtFracTrue_yV = zeros([nyp, 1]);
   debtMeanTrue_yV = zeros([nyp, 1]);
   % Debt at end of year 4 (these are CG)
   ypS.debtFracYear4_yV = zeros([nyp, 1]);
   ypS.debtMeanYear4_yV = zeros([nyp, 1]);

   % This is NOT conditional on college
   logYpMean_yV = zeros([nyp, 1]);

%    % Mass by [IQ, yp]
%    mass_qyM = nan([nIq, nyp]);
%    massColl_qyM = nan([nIq, nyp]);
%    massGrad_qyM = nan([nIq, nyp]);


   for iy = 1 : nyp
      % Types in this class
      jIdxV = find(paramS.ypClass_jV == iy);
      totalMass = sum(aggrS.mass_jV(jIdxV));

      % Average parental income (not conditional on college)
      logYpMean_yV(iy) = sum(aggrS.mass_jV(jIdxV) .* log(paramS.yParent_jV(jIdxV))) ./ totalMass;

      % Their masses in college
      massColl_jV = aggrS.massColl_jV(jIdxV);
%       % Mass of grad
%       massGrad_jV = massColl_jV .* aggrS.prGrad_jV(jIdxV);
      if any(massColl_jV > 0)
         jMass = sum(massColl_jV);

         % Fraction that enters = mass in college / mass
         ypS.fracEnter_yV(iy) = jMass ./ totalMass;
         % Fraction that graduates, not conditional on entry = mass CG / mass
         ypS.fracGrad_yV(iy) = sum(aggrS.mass_sjM(cS.iCG,jIdxV)) ./ totalMass;

         ypS.pColl_yV(iy) = sum(massColl_jV .* paramS.pColl_jV(jIdxV)) ./ jMass;
         % Transfer (annualized)
         ypS.transfer_yV(iy) = sum(massColl_jV .* hhS.v0S.zColl_jV(jIdxV)) ./ jMass;
         ypS.hoursCollMean_yV(iy) = sum(massColl_jV .* aggrS.hours_tjM(1,jIdxV)') ./ jMass;
         ypS.earnCollMean_yV(iy) = sum(massColl_jV .* aggrS.earn_tjM(1,jIdxV)') ./ jMass;
         ypS.consCollMean_yV(iy) = sum(massColl_jV .* aggrS.cons_tjM(1,jIdxV)') ./ jMass;

         % *** Debt stats at end of college
         % Mass that exits at end of years 2 / 4
         mass_tjM = aggrS.mass_sjM([cS.iCD, cS.iCG],jIdxV);
         
         % debt at end of years 2 and 4
         debt_tjM = max(0, -aggrS.k_tjM(2:3, jIdxV));
         debtFrac_yV(iy) = sum(mass_tjM(:) .* (debt_tjM(:) > 0)) ./ sum(mass_tjM(:));
         % Meand debt (not conditional)
         debtMean_yV(iy) = sum(mass_tjM(:) .* debt_tjM(:)) ./ sum(mass_tjM(:));

         % Debt at end of year 4
         mass_jV = mass_tjM(2,:);
         debt_jV = debt_tjM(2,:);
         ypS.debtFracYear4_yV(iy) = sum(mass_jV .* (debt_jV > 0)) ./ sum(mass_jV);
         ypS.debtMeanYear4_yV(iy) = sum(mass_jV .* debt_jV) ./ sum(mass_jV);
         clear debt_tjM;

         % debt at end of years 2 and 4 (transfers paid out each period)
         debt_tjM = max(0, -aggrS.kTrue_tjM(2:3, jIdxV));
         debtFracTrue_yV(iy) = sum(mass_tjM(:) .* (debt_tjM(:) > 0)) ./ sum(mass_tjM(:));
         % Meand debt (not conditional)
         debtMeanTrue_yV(iy) = sum(mass_tjM(:) .* debt_tjM(:)) ./ sum(mass_tjM(:));
         clear debt_tjM;
         

         % ******  Stats by [iq, yp]
         % should be in aggr_qy.m

%          % Mass (q,y) = sum over j in y group  Pr(iq|j) * mass(j)
%          mass_qyM(:, iy) = sum(paramS.prIq_jM(:, jIdxV) .* (ones([nIq,1]) * aggrS.mass_jV(jIdxV)'), 2);
% 
%          % Mass in college by [iq, j] for the right yp group
%          massColl_qyM(:, iy) = sum(paramS.prIq_jM(:, jIdxV) .* (ones([nIq,1]) * massColl_jV(:)'), 2);
% 
%          % Mass in college by [iq, j] for the right yp group
%          massGrad_qyM(:, iy) = sum(paramS.prIq_jM(:, jIdxV) .* (ones([nIq,1]) * massGrad_jV(:)'), 2);
      end
   end


   if cS.dbg > 10
      validateattributes(ypS.pColl_yV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
         'size', [nyp,1]})
      validateattributes(ypS.transfer_yV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
         '>=', 0, 'size', [nyp,1]})
      validateattributes(ypS.debtFracYear4_yV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
         '>=', 0, '<=', 1, 'size', [nyp,1]})
      validateattributes(ypS.debtMeanYear4_yV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
         '>=', 0, 'size', [nyp,1]})
   end

end
