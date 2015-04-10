function saveS = hh_solve(iCohort, paramS, cS)
% Solve hh problem. 1 cohort
%{
kPrime is not restricted to lie within the grid

Change
   how to set k grids +++

Checked: 2015-Mar-20
%}
% -----------------------------------------


% Value work: closed form (hh_work)
%  does not include pref for HS


%% Value of periods 3-4 in college
%  kPrime need not be restricted to grid range

age = cS.ageWorkStart_sV(cS.iCD);

nk = 50;
vColl3S.kGridV = linspace(paramS.kMin_aV(age), paramS.kMax, nk)';

% Compute on a k grid. 
sizeV = [nk, cS.nTypes];
vColl3S.c_kjM = nan(sizeV);
vColl3S.hours_kjM = nan(sizeV);
vColl3S.kPrime_kjM = nan(sizeV);
vColl3S.value_kjM = nan(sizeV);

for j = 1 : cS.nTypes
   for ik = 1 : nk
      [vColl3S.c_kjM(ik,j), vColl3S.hours_kjM(ik,j), vColl3S.kPrime_kjM(ik,j), vColl3S.value_kjM(ik,j)] = ...
         hh_bc1.coll_pd3(vColl3S.kGridV(ik), paramS.wColl_jV(j), paramS.pColl_jV(j), ...
         j, iCohort, paramS, cS);
   end
end

saveS.vColl3S = vColl3S;

if cS.dbg > 10
   validateattributes(vColl3S.value_kjM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [nk, cS.nTypes]})
end


%% Value at end of period 2, before learning ability

prGrad_aV = paramS.prGrad_aV;

vmS.kGridV = vColl3S.kGridV;
vmS.value_kjM = nan([nk, cS.nTypes]);

for ik = 1 : nk
   for j = 1 : cS.nTypes
      % Value of working as a dropout (independent of j)
      [~, vDrop] = hh_bc1.hh_work_bc1(vmS.kGridV(ik), cS.iCD, j, iCohort, paramS, cS);
      % Value of studying in period 3-4
      vStudy = vColl3S.value_kjM(ik, j);
      % Value = E_a of (prob grad * study + prob drop * work)
      vmS.value_kjM(ik, j) = ...
         sum(paramS.prob_a_jM(:,j) .* ((1 - prGrad_aV) .* vDrop + prGrad_aV .* vStudy));
   end
end

saveS.vmS = vmS;

if cS.dbg > 10
   validateattributes(vmS.value_kjM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [nk, cS.nTypes]})
end



%% Periods 1-2 in college

sizeV = [nk, cS.nTypes];
v1S.kGridV = vmS.kGridV;
v1S.value_kjM = nan(sizeV);   % Does not include pref shocks
v1S.c_kjM = nan(sizeV);
v1S.hours_kjM = nan(sizeV);
v1S.kPrime_kjM = nan(sizeV);


for j = 1 : cS.nTypes
   % Continuous approx of V_m(k', j) (continuation value)
   vmFct = griddedInterpolant(vmS.kGridV, vmS.value_kjM(:,j), 'pchip', 'linear');
   for ik = 1 : nk
      [v1S.c_kjM(ik,j), v1S.hours_kjM(ik,j), v1S.kPrime_kjM(ik,j), v1S.value_kjM(ik,j)] = ...
         hh_bc1.coll_pd1(vmS.kGridV(ik), paramS.wColl_jV(j), paramS.pColl_jV(j), ...
         iCohort, vmFct, paramS, cS);
   end
end

saveS.v1S = v1S;



%% College entry decision

v0S.vWork_jV = nan([cS.nTypes, 1]); % does not include pref for HS
v0S.vColl_jV = nan([cS.nTypes, 1]);
% Transfers (per year)
v0S.zWork_jV = nan([cS.nTypes, 1]);
v0S.zColl_jV = nan([cS.nTypes, 1]);

for j = 1 : cS.nTypes
   [v0S.vWork_jV(j), v0S.vColl_jV(j), v0S.zWork_jV(j), v0S.zColl_jV(j)] = ...
      hh_bc1.college_entry(v1S, j, iCohort, paramS, cS);
end

% Capital endowments
%  Restricted to lie inside kGrid
v0S.k1Work_jV = min(v1S.kGridV(end), max(v1S.kGridV(1), cS.collLength .* v0S.zWork_jV));
v0S.k1Coll_jV = min(v1S.kGridV(end), max(v1S.kGridV(1), cS.collLength .* v0S.zColl_jV));

% Fraction that enters college
v0S.probEnter_jV = exp(v0S.vColl_jV ./ paramS.prefScaleEntry) ./ ...
   (exp(v0S.vColl_jV ./ paramS.prefScaleEntry) + exp((v0S.vWork_jV + paramS.prefHS) ./ paramS.prefScaleEntry));

% Make sure someone always enters college
v0S.probEnter_jV = min(0.999, max(1e-3, v0S.probEnter_jV));

validateattributes(v0S.probEnter_jV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
   'positive', '<', 1, 'size', [cS.nTypes, 1]})

% Bound entry probs from both sides to prevent cases where all / nobody goes to college during
% calibration
% But do not force those who cannot afford college to enter +++
v0S.probEnter_jV = max(0.005, min(0.995, v0S.probEnter_jV));

saveS.v0S = v0S;


end