function aggrS = aggregates(hhS, paramS, cS)
% Compute aggregates
%{

Checked: 2015-Apr-3
%}


dbg = cS.dbg;
nIq = length(cS.iqUbV);
% Pr(IQ | j)
prIq_jM = paramS.prIq_jM(:, :);
frac_qV = diff([0; cS.iqUbV]);
% Scale factor
aggrS.totalMass = 100;


%% By j

% Prob grad conditional on entry = sum of Pr(a|j) * Pr(grad|a)
aggrS.prGrad_jV = nan([cS.nTypes, 1]);
for j = 1 : cS.nTypes
   aggrS.prGrad_jV(j) = sum(paramS.prob_a_jM(:,j) .* paramS.prGrad_aV);
end
if dbg > 10
   validateattributes(aggrS.prGrad_jV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'positive', '<', 1, 'size', [cS.nTypes, 1]})
end

% Defines total mass
aggrS.mass_jV = paramS.prob_jV * aggrS.totalMass;


%% By [s, j]

% Mass in college by j
aggrS.massColl_jV = aggrS.mass_jV .* hhS.v0S.probEnter_jV;

sizeV = [cS.nSchool, cS.nTypes];
aggrS.mass_sjM = zeros(sizeV);
aggrS.mass_sjM(cS.iHSG,:) = aggrS.mass_jV .* (1 - hhS.v0S.probEnter_jV);
aggrS.mass_sjM(cS.iCD,:) = aggrS.massColl_jV .* (1 - aggrS.prGrad_jV);
aggrS.mass_sjM(cS.iCG,:) = aggrS.massColl_jV .* aggrS.prGrad_jV;

if dbg > 10
   validateattributes(aggrS.mass_sjM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0, 'size', sizeV})
   sumV = sum(aggrS.mass_sjM);
   if any(abs(sumV(:) - aggrS.mass_jV) > 1e-6)
      error('Invalid');
   end
end


% Prob s | j = Prob(s and j) / (prob j)
aggrS.probS_jM = aggrS.mass_sjM ./ (ones([cS.nSchool,1]) * aggrS.mass_jV(:)');


if dbg > 10
   validateattributes(aggrS.massColl_jV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0, 'size', [cS.nTypes, 1]})
end


%% By [school, abil]

aggrS.mass_asM = nan([cS.nAbil, cS.nSchool]);

% HSG: Mass(HSG,j) * Pr(a | j)
for iAbil = 1 : cS.nAbil
   aggrS.mass_asM(iAbil, cS.iHSG) = aggrS.mass_sjM(cS.iHSG, :) * paramS.prob_a_jM(iAbil, :)';
end

% College: 
for iAbil = 1 : cS.nAbil
   % Mass college with this a
   massColl = paramS.prob_a_jM(iAbil,:) * aggrS.massColl_jV;
   %  CG: mass(college,a) * pr(grad|a)
   aggrS.mass_asM(iAbil, cS.iCG) = paramS.prGrad_aV(iAbil) * massColl;
   aggrS.mass_asM(iAbil, cS.iCD) = (1 - paramS.prGrad_aV(iAbil)) * massColl;
end

if dbg > 10
   validateattributes(aggrS.mass_asM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0, 'size', [cS.nAbil, cS.nSchool]})
   mass_aV = sum(aggrS.mass_asM, 2);
   if any(abs(mass_aV(:) ./ (aggrS.totalMass .* paramS.prob_aV) - 1) > 1e-4)
      error_bc1('Invalid sum', cS);
   end
end


% 
% aggrS.mass_sajM = zeros([cS.nSchool, cS.nAbil, cS.nTypes]);
% 
% for j = 1 : cS.nTypes
%    % No college: Pr(HSG,j) * Pr(a | j)
%    aggrS.mass_sajM(cS.iHSG, :, j) = aggrS.mass_sjM(cS.iHSG,j) .* paramS.prob_a_jcM(:,j,iCohort);
%    
%    % College
%    mass = aggrS.massColl_jV(j);
%    if mass > 0
%       % Pr(enter,a,j) = mass(enter,j) * Pr(a|j)
%       mass_aV = mass .* paramS.prob_a_jcM(:,j,iCohort);
%       
%       for iSchool = [cS.iCD, cS.iCG]
%          if iSchool == cS.iCD
%             prob_s_aV = 1 - paramS.prGrad_acM(:,iCohort);
%          else
%             prob_s_aV = paramS.prGrad_acM(:,iCohort);
%          end
%          
%          % Pr(CD,a,j) = Pr(enter,a,j) * Pr(drop | enter,a)
%          aggrS.mass_sajM(iSchool,:,j) = mass_aV(:) .* prob_s_aV;
%       end
%    end   
% end
% 
% if dbg > 10
%    validateattributes(aggrS.mass_sajM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
%       '>=', 0, 'size', [cS.nSchool, cS.nAbil, cS.nTypes]})
% end
% 



%% By j - simulate histories in college

% Path of assets in college; at start, after periods 2, 4 in college
%  at START of each period
%  restrict kPrime to be inside k grid for t+1
aggrS.k_tjM = nan([3, cS.nTypes]);

% Hours in college (first 2 years, 2nd 2 years)
aggrS.hours_tjM = nan([2, cS.nTypes]);
% Consumption phases 1 and 2 in college
aggrS.cons_tjM = nan([2, cS.nTypes]);


% Everyone starts with the parental transfer
%  limited to inside of grid
aggrS.k_tjM(1,:) = max(hhS.v1S.kGridV(1), min(hhS.v1S.kGridV(end), hhS.v0S.k1Coll_jV));


% ******  Periods 1-2 (ability not known)

kV = nan([cS.nTypes, 1]);
for j = 1 : cS.nTypes
   % Current k
   k = aggrS.k_tjM(1,j);
   kV(j) = interp1(hhS.v1S.kGridV, hhS.v1S.kPrime_kjM(:,j), k, 'linear', 'extrap');
   aggrS.hours_tjM(1,j) = interp1(hhS.v1S.kGridV, hhS.v1S.hours_kjM(:,j), k, 'linear', 'extrap');
   aggrS.cons_tjM(1,j) = interp1(hhS.v1S.kGridV, hhS.v1S.c_kjM(:,j), k, 'linear', 'extrap');
end
% Restrict inside period 3 k grid
aggrS.k_tjM(2,:) = max(hhS.vColl3S.kGridV(1), min(hhS.vColl3S.kGridV(end), kV));


% *******  Periods 3-4 in college (ability known)

for j = 1 : cS.nTypes
   % Current k
   k = aggrS.k_tjM(2,j);
   
   % Prob(a | j, college)
   %  Prob(college | a) = prob(grad | a). Only those who graduate stay
   prob_aV = paramS.prob_a_jM(:,j) .* paramS.prGrad_aV;
   prob_aV = prob_aV ./ sum(prob_aV);
   
   kPrime_aV = nan([cS.nAbil, 1]);
   hours_aV = nan([cS.nAbil, 1]);
   cons_aV = nan([cS.nAbil, 1]);
   for iAbil = 1 : cS.nAbil
      kPrime_aV(iAbil) = interp1(hhS.vColl3S.kGridV, hhS.vColl3S.kPrime_kajM(:,iAbil,j), k, 'linear', 'extrap');
      hours_aV(iAbil)  = interp1(hhS.vColl3S.kGridV, hhS.vColl3S.hours_kajM(:,iAbil,j), k, 'linear', 'extrap');
      cons_aV(iAbil)   = interp1(hhS.vColl3S.kGridV, hhS.vColl3S.c_kajM(:,iAbil,j), k, 'linear', 'extrap');
   end
   
   % Average choices for each j type (conditional on staying in college)
   %  No need to restrict k' to be inside a grid
   aggrS.k_tjM(3,j) = sum(prob_aV .* kPrime_aV);
   aggrS.hours_tjM(2,j) = sum(prob_aV .* hours_aV);
   aggrS.cons_tjM(2,j) = sum(prob_aV .* cons_aV);
end

aggrS.earn_tjM = aggrS.hours_tjM .* (ones([2,1]) * paramS.wColl_jV(:)');

if dbg > 10
   validateattributes(aggrS.k_tjM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [3, cS.nTypes]})
   validateattributes(aggrS.hours_tjM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, ...
      '<=', 1, 'size', [2, cS.nTypes]})
   validateattributes(aggrS.earn_tjM,  {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, ...
      'size', [2, cS.nTypes]})
end


%% By [school, IQ, j]

% Mass by [s, iq, j]
sizeV = [cS.nSchool, cS.nIQ, cS.nTypes];
aggrS.mass_sqjM = zeros(sizeV);

for j = 1 : cS.nTypes
   for iSchool = 1 : cS.nSchool
      for iIQ = 1 : cS.nIQ
         % Mass(s,iq,j) = mass(s,j) * pr(iq|j)
         aggrS.mass_sqjM(iSchool,iIQ,j) = aggrS.mass_sjM(iSchool,j) * paramS.prIq_jM(iIQ,j);
      end
   end
end

% Mass by [s, iq]
aggrS.mass_sqM = sum(aggrS.mass_sqjM, 3);

% Fraction s | iq = mass(s,q) / mass(q)
aggrS.fracS_iqM = nan([cS.nSchool, nIq]);
for i1 = 1 : nIq
   aggrS.fracS_iqM(:,i1) = aggrS.mass_sqM(:,i1) ./ sum(aggrS.mass_sqM(:,i1));
end

% Fraction that enters / grads | IQ
%  grad not conditional on entry
aggrS.fracEnter_qV = 1 - aggrS.fracS_iqM(cS.iHSG, :)';
aggrS.fracGrad_qV  = aggrS.fracS_iqM(cS.iCG, :)';


if dbg > 10
   validateattributes(aggrS.mass_sqjM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0, 'size', sizeV})
   validateattributes(aggrS.mass_sqM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0, 'size', [cS.nSchool, nIq]})
   validateattributes(aggrS.fracS_iqM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [cS.nSchool, nIq], 'positive', '<', 1})
   % Mass(s,q) should sum to mass by iq
   sumV = sum(aggrS.mass_sqM);
   if any(abs(sumV(:) ./ aggrS.totalMass - frac_qV) > 1e-3)    % why so imprecise? +++
      error('Invalid');
   end
   
   % Another way of computing frac enter | IQ
   %  Prob(enter \ IQ) = sum over j  (Pr(J | IQ) * Pr(enter | j))
   %  Not super accurate b/c pr(j | iq) is not (see param_derived)
   for iIq = 1 : nIq
      fracEnter = sum(paramS.prJ_iqM(:, iIq) .* hhS.v0S.probEnter_jV);
      if abs(fracEnter - aggrS.fracEnter_qV(iIq)) > 2e-3
         error_bc1('Invalid', cS);
      end
   end
end



%% By IQ quartile


% Mean parental income by IQ quartile
aggrS.logYpMean_qV = nan([nIq, 1]);
% Mean college cost
aggrS.pMean_qV = nan([nIq, 1]);
% Average hours, first 2 years in college
aggrS.hoursCollMean_qV = nan([nIq, 1]);
% Average earnings, first 2 years in college
aggrS.earnCollMean_qV = nan([nIq, 1]);
% Fraction in debt at end of college
aggrS.debtFrac_qV = nan([nIq, 1]);
% Mean debt, NOT conditional on being in debt
aggrS.debtMean_qV = nan([nIq, 1]);
% Average annual transfer
aggrS.transfer_qV = nan([nIq, 1]);

for iIq = 1 : nIq
   % *******  All

   % Mass by j for this IQ
   wtV = aggrS.mass_jV .* prIq_jM(iIq, :)';
   
   aggrS.logYpMean_qV(iIq) = sum(wtV .* log(paramS.yParent_jV)) ./ sum(wtV);

   
   % *******  In college
   
   % Mass with IQ and j in college
   wtV = aggrS.massColl_jV .* prIq_jM(iIq, :)';
   totalWt = sum(wtV);
   
   aggrS.pMean_qV(iIq) = sum(wtV .* paramS.pColl_jV) ./ totalWt;
   
   aggrS.hoursCollMean_qV(iIq) = sum(wtV .* aggrS.hours_tjM(1,:)') ./ totalWt;
   
   aggrS.earnCollMean_qV(iIq) = sum(wtV .* aggrS.earn_tjM(1,:)') ./ totalWt;
   
   % Need to annualized
   aggrS.transfer_qV(iIq) = sum(wtV .* hhS.v0S.zColl_jV) ./ totalWt;
   
   % *** Debt stats at end of college
   % Mass that exits at end of years 2 / 4, by j
   mass_tjM = squeeze(aggrS.mass_sqjM([cS.iCD, cS.iCG], iIq,:));
   % debt at end of years 2 and 4
   debt_tjM = max(0, -aggrS.k_tjM(2:3, :));
   aggrS.debtFrac_qV(iIq) = sum(mass_tjM(:) .* (debt_tjM(:) > 0)) ./ sum(mass_tjM(:));
   % Meand debt (not conditional)
   aggrS.debtMean_qV(iIq) = sum(mass_tjM(:) .* debt_tjM(:)) ./ sum(mass_tjM(:));
end


if dbg > 10
   validateattributes(aggrS.pMean_qV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [nIq, 1]})
end

% Mass of entrants by q
mass_qV = sum(aggrS.mass_sqM(cS.iCD : cS.nSchool, :));
mass_qV = mass_qV(:) ./ sum(mass_qV);
aggrS.debtMean = sum(aggrS.debtMean_qV .* mass_qV(:));
aggrS.earnCollMean = sum(aggrS.earnCollMean_qV .* mass_qV(:));
aggrS.transferMean = sum(aggrS.transfer_qV .* mass_qV(:));
aggrS.hoursCollMean = sum(aggrS.hoursCollMean_qV .* mass_qV(:));
aggrS.pMean = sum(aggrS.pMean_qV .* mass_qV(:));


%% By [parental income class] (for those in college)

nyp = length(cS.ypUbV);
% Initialize all with zeros so that deviation is valid when nobody goes to college in a group
aggrS.pColl_yV = zeros([nyp, 1]);
% ANNUAL transfer (to be comparable with data targets
aggrS.transfer_yV = zeros([nyp, 1]);
aggrS.fracEnter_yV = zeros([nyp, 1]);
aggrS.fracGrad_yV = zeros([nyp, 1]);
aggrS.hoursCollMean_yV = zeros([nyp, 1]);
aggrS.earnCollMean_yV = zeros([nyp, 1]);
aggrS.debtFrac_yV = zeros([nyp, 1]);
aggrS.debtMean_yV = zeros([nyp, 1]);

% This is NOT conditional on college
aggrS.logYpMean_yV = zeros([nyp, 1]);


aggrS.mass_qyM = nan([nIq, nyp]);
aggrS.massColl_qyM = nan([nIq, nyp]);
aggrS.massGrad_qyM = nan([nIq, nyp]);


for iy = 1 : nyp
   % Types in this class
   jIdxV = find(paramS.ypClass_jV == iy);
   totalMass = sum(aggrS.mass_jV(jIdxV));
   
   % Average parental income (not conditional on college)
   aggrS.logYpMean_yV(iy) = sum(aggrS.mass_jV(jIdxV) .* log(paramS.yParent_jV(jIdxV))) ./ totalMass;

   % Their masses in college
   massColl_jV = aggrS.massColl_jV(jIdxV);
   % Mass of grad
   massGrad_jV = massColl_jV .* aggrS.prGrad_jV(jIdxV);
   if any(massColl_jV > 0)
      jMass = sum(massColl_jV);

      % Fraction that enters = mass in college / mass
      aggrS.fracEnter_yV(iy) = jMass ./ totalMass;
      % Fraction that graduates, not conditional on entry = mass CG / mass
      aggrS.fracGrad_yV(iy) = sum(aggrS.mass_sjM(cS.iCG,jIdxV)) ./ totalMass;
      
      aggrS.pColl_yV(iy) = sum(massColl_jV .* paramS.pColl_jV(jIdxV)) ./ jMass;
      % Transfer (annualized)
      aggrS.transfer_yV(iy) = sum(massColl_jV .* hhS.v0S.zColl_jV(jIdxV)) ./ jMass;
      aggrS.hoursCollMean_yV(iy) = sum(massColl_jV .* aggrS.hours_tjM(1,jIdxV)') ./ jMass;
      aggrS.earnCollMean_yV(iy) = sum(massColl_jV .* aggrS.earn_tjM(1,jIdxV)') ./ jMass;
      
      % *** Debt stats at end of college
      % Mass that exits at end of years 2 / 4
      mass_tjM = aggrS.mass_sjM([cS.iCD, cS.iCG],jIdxV);
      % debt at end of years 2 and 4
      debt_tjM = max(0, -aggrS.k_tjM(2:3, jIdxV));
      aggrS.debtFrac_yV(iy) = sum(mass_tjM(:) .* (debt_tjM(:) > 0)) ./ sum(mass_tjM(:));
      % Meand debt (not conditional)
      aggrS.debtMean_yV(iy) = sum(mass_tjM(:) .* debt_tjM(:)) ./ sum(mass_tjM(:));
      
      
      % ******  Stats by [iq, yp]
      
      % Mass (q,y) = sum over j in y group  Pr(iq,j) * mass(j)
      aggrS.mass_qyM(:, iy) = sum(prIq_jM(:, jIdxV) .* (ones([nIq,1]) * aggrS.mass_jV(jIdxV)'), 2);
      
      % Mass in college by [iq, j] for the right yp group
      aggrS.massColl_qyM(:, iy) = sum(prIq_jM(:, jIdxV) .* (ones([nIq,1]) * massColl_jV(:)'), 2);
      
      % Mass in college by [iq, j] for the right yp group
      aggrS.massGrad_qyM(:, iy) = sum(prIq_jM(:, jIdxV) .* (ones([nIq,1]) * massGrad_jV(:)'), 2);
   end
end


if dbg > 10
   validateattributes(aggrS.pColl_yV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [nyp,1]})
   validateattributes(aggrS.transfer_yV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0, 'size', [nyp,1]})
   
   % Compare with entry / grad rates by IQ
   probEnter_qV = sum(aggrS.massColl_qyM, 2) ./ sum(aggrS.mass_qyM, 2);
   if any(abs(probEnter_qV(:) - aggrS.fracEnter_qV) > 0.02)
      error_bc1('no match', cS);
   end
   probGrad_qV = sum(aggrS.massGrad_qyM, 2) ./ sum(aggrS.mass_qyM, 2);
   if any(abs(probGrad_qV(:) - aggrS.fracGrad_qV) > 0.02)
      error_bc1('no match', cS);
   end
   
   % Compare with entry / grad rates by yParent
   probEnter_yV = sum(aggrS.massColl_qyM) ./ sum(aggrS.mass_qyM);
   if any(abs(probEnter_yV(:) - aggrS.fracEnter_yV) > 0.02)
      error_bc1('no match', cS);
   end
   probGrad_yV = sum(aggrS.massGrad_qyM) ./ sum(aggrS.mass_qyM);
   if any(abs(probGrad_yV(:) - aggrS.fracGrad_yV) > 0.02)
      error_bc1('no match', cS);
   end
end


% *******  Aggregates across groups (for consistency)
if cS.dbg > 10
   % Mass of entrants by y
   mass_yV = aggrS.fracEnter_yV .* cS.pr_ypV;
   mass_yV = mass_yV(:) ./ sum(mass_yV);
   debtMean = sum(aggrS.debtMean_yV .* mass_yV);
   earnCollMean = sum(aggrS.earnCollMean_yV .* mass_yV);
   transferMean = sum(aggrS.transfer_yV .* mass_yV);
   hoursCollMean = sum(aggrS.hoursCollMean_yV .* mass_yV);
   pMean = sum(aggrS.pColl_yV .* mass_yV);
   denomV = [aggrS.debtMean, aggrS.earnCollMean, aggrS.transferMean, aggrS.hoursCollMean, aggrS.pMean];
   diffV = ([debtMean, earnCollMean, transferMean, hoursCollMean, pMean] - denomV) ./ ...
      max(1, denomV);
   maxDiff = max(abs(diffV));
   if maxDiff > 0.1    % why so imprecise? +++
      disp(maxDiff)
      error_bc1('Two ways of computing means do not match up', cS);
   end
end



%% By school

aggrS.mass_sV = sum(aggrS.mass_sjM, 2);
aggrS.mass_sV = aggrS.mass_sV(:);

aggrS.frac_sV = aggrS.mass_sV ./ sum(aggrS.mass_sV);


% Mean lifetime earnings
aggrS.pvEarn_sV = nan([cS.nSchool, 1]);
for iSchool = 1 : cS.nSchool
   mass_aV = aggrS.mass_asM(:, iSchool);
   aggrS.pvEarn_sV(iSchool) = sum(mass_aV .* paramS.pvEarn_asM(:,iSchool)) ./ sum(mass_aV);
end


%% By graduation status

% *****  Debt at end of college
% indexed by [dropout, graduate]

% Fraction in debt
aggrS.debtFrac_sV = zeros([2,1]);
% Mean debt (not conditional on being in debt)
aggrS.debtMean_sV = zeros([2,1]);

for i1 = 1 : 2
   if i1 == 1
      % Dropouts
      massColl_jV = aggrS.mass_sjM(cS.iCD, :);
      t = 2;
   elseif i1 == 2
      % Graduates
      massColl_jV = aggrS.mass_sjM(cS.iCG, :);
      t = 3;
   end
   
   % Mass of this school type by j
   massColl_jV = massColl_jV ./ sum(massColl_jV);
   % Assets at end of college by j
   k_jV = aggrS.k_tjM(t, :);

   % Find those types that are in debt
   dIdxV = find(k_jV < 0);
   if ~isempty(dIdxV)
      aggrS.debtFrac_sV(i1) = sum(massColl_jV(dIdxV));
      % Mean debt, not conditional on being in debt
      aggrS.debtMean_sV(i1) = -sum(massColl_jV(dIdxV) .* k_jV(dIdxV));
   end
end

% Avoid rounding errors
aggrS.debtFrac_sV = min(1, aggrS.debtFrac_sV);

if dbg > 10
   validateattributes(aggrS.debtFrac_sV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0, '<=', 1})
   validateattributes(aggrS.debtMean_sV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0})
end


% *****  Mean debt per student

frac_sV = aggrS.frac_sV(cS.iCD : cS.iCG);
aggrS.debtMean = sum(aggrS.debtMean_sV .* frac_sV) ./ sum(frac_sV);



%% For all college students
% Mostly computed earlier from stats by iq or yp

massColl = sum(aggrS.massColl_jV);
if massColl <= 0
   error_bc1('Invalid', cS);
end

% Mean and std of college costs (for those in college)
if any(aggrS.massColl_jV > 1e-6)
   aggrS.pStd = stats_lh.std_w(paramS.pColl_jV, aggrS.massColl_jV, dbg);
else
   aggrS.pStd = 0;
   %aggrS.pMean = 0;
end

% % Average hours and earnings
% %  first 2 years in college
% aggrS.hoursCollMean = sum(aggrS.massColl_jV .* aggrS.hours_tjM(1,:)') ./ massColl;
% aggrS.earnCollMean  = sum(aggrS.massColl_jV .* aggrS.earn_tjM(1,:)')  ./ massColl;


end