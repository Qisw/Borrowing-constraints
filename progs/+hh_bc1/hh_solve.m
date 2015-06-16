function saveS = hh_solve(paramS, cS)
% Solve hh problem. 1 cohort
%{
kPrime is not restricted to lie within the grid

Change
   how to set k grids +++

Checked: 2015-Mar-20
%}
% -----------------------------------------

nAbil = cS.nAbil;


%% Value of work
% Approx on k grid

vWorkS = calibr_bc1.value_work(paramS, cS);
saveS.vWorkS = vWorkS;


%% Precompute hh utility in college as function of (c,k,j)

% collUtilS = coll_util_ckj(paramS, cS);

% nk = 50;
% collUtilS.kGridV = linspace(min(paramS.kMin_aV), paramS.kMax, nk)';
% 
% sizeV = [nk, nk, cS.nTypes];
% collUtilS.c_kPkjM = nan(sizeV);
% collUtilS.hours_kPkjM = nan(sizeV);
% 
% for j = 1 : cS.nTypes
%    for ik = 1 : nk
%       for ikP = 1 : cS.nk
%          [collUtilS.c_kPkjM(ik,:,j), collUtilS.hours_kPkjM(ik,:,j)] = ...
%             hh_bc1.hh_coll_c_from_kprime_bc1(collUtilS.kGridV(ikP), collUtilS.kGridV(ik), paramS.wColl_jV(j), ...
%             paramS.pColl_jV(j), paramS, cS);
%       end
%    end
% end
% 
% % Utility in college
% collUtilS.util_kPkjM = hh_bc1.hh_util_coll_bc1(collUtilS.c_kPkjM, 1 - collUtilS.hours_kPkjM, paramS, cS);
% 
% if cS.dbg > 10
%    validateattributes(collUtilS.util_kPkjM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
%       'size', sizeV})
% end


%% Value of periods 3-4 in college
%  kPrime need not be restricted to grid range

age = cS.ageWorkStart_sV(cS.iCD);

nk = 50;
vColl3S.kGridV = linspace(paramS.kMin_aV(age), paramS.kMax, nk)';

% Compute on a k grid. 
sizeV = [nk, cS.nAbil, cS.nTypes];
c_kajM = nan(sizeV);
hours_kajM = nan(sizeV);
kPrime_kajM = nan(sizeV);
value_kajM = nan(sizeV);
kMin = paramS.kMin_aV(cS.ageWorkStart_sV(cS.iCG));

kGridV = vColl3S.kGridV;
evWorkCG_jV = vWorkS.evWorkCG_jV;
wColl_jV = paramS.wColl_jV;
pColl_jV = paramS.pColl_jV;

% if cS.runParallel == 1
%    matlabpool open 4;
% end

parfor j = 1 : cS.nTypes
   % Currently, choices and values do not depend on ability
   [cV, hoursV, kPrimeV, valueV] = ...
      hh_bc1.coll_pd3(kGridV, wColl_jV(j), pColl_jV(j), kMin, ...
      evWorkCG_jV{j}, j, paramS, cS);
   
   c_kajM(:,:,j) = cV(:) * ones([1, nAbil]);
   hours_kajM(:,:,j) = hoursV(:) * ones([1, nAbil]);
   kPrime_kajM(:,:,j) = kPrimeV(:) * ones([1, nAbil]);
   value_kajM(:,:,j) = valueV(:) * ones([1, nAbil]);
end

vColl3S.c_kajM = c_kajM;
vColl3S.hours_kajM = hours_kajM;
vColl3S.kPrime_kajM = kPrime_kajM;
vColl3S.value_kajM = value_kajM;

saveS.vColl3S = vColl3S;

if cS.dbg > 10
   validateattributes(vColl3S.value_kajM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [nk, cS.nAbil, cS.nTypes]})
   validateattributes(vColl3S.hours_kajM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0, '<', 1, 'size', sizeV})
   validateattributes(vColl3S.c_kajM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'positive', 'size', sizeV})
end


%% Value at end of period 2, before learning ability

vmS = calibr_bc1.coll_value_m(vColl3S, vWorkS, paramS, cS);
saveS.vmS = vmS;


%% Periods 1-2 in college

sizeV = [nk, cS.nTypes];
v1S.kGridV = vmS.kGridV;
value_kjM = nan(sizeV);   % Does not include pref shocks
c_kjM = nan(sizeV);
hours_kjM = nan(sizeV);
kPrime_kjM = nan(sizeV);

% Borrowing limit
kMin = paramS.kMin_aV(cS.ageWorkStart_sV(cS.iCD));
kGridV = v1S.kGridV;
vmFct_jV = vmS.vmFct_jV;

parfor j = 1 : cS.nTypes
   % Continuous approx of V_m(k', j) (continuation value)
   % vmFct = griddedInterpolant(vmS.kGridV, vmS.value_kjM(:,j), 'pchip', 'linear');
   %vmFct = vmS.vmFct_jV{j};
   [c_kjM(:,j), hours_kjM(:,j), kPrime_kjM(:,j), value_kjM(:,j)] = ...
      hh_bc1.coll_pd3(kGridV, wColl_jV(j), pColl_jV(j), kMin, ...
      vmFct_jV{j}, j, paramS, cS);
end

v1S.value_kjM = value_kjM;   % Does not include pref shocks
v1S.c_kjM = c_kjM;
v1S.hours_kjM = hours_kjM;
v1S.kPrime_kjM = kPrime_kjM;

saveS.v1S = v1S;


% if cS.runParallel == 1
%    matlabpool close;
% end


%% College entry decision

vWork_jV = nan([cS.nTypes, 1]); % does not include pref for HS
vColl_jV = nan([cS.nTypes, 1]);
% Transfers (per year)
zWork_jV = nan([cS.nTypes, 1]);
zColl_jV = nan([cS.nTypes, 1]);

for j = 1 : cS.nTypes
   [vWork_jV(j), vColl_jV(j), zWork_jV(j), zColl_jV(j)] = ...
      hh_bc1.college_entry(v1S, vWorkS, j, paramS, cS);
end


v0S.vWork_jV = vWork_jV; % does not include pref for HS
v0S.vColl_jV = vColl_jV;
% Transfers (per year)
v0S.zWork_jV = zWork_jV;
v0S.zColl_jV = zColl_jV;


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
% But do not force those who cannot afford college to enter
if all(v0S.probEnter_jV < 0.02)
   v0S.probEnter_jV = max(0.005, v0S.probEnter_jV);
elseif all(v0S.probEnter_jV > 0.98)
   v0S.probEnter_jV = min(0.995, v0S.probEnter_jV);
end

saveS.v0S = v0S;


end