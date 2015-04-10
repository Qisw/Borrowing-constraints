function college(setNo)
% Test college routines

cS = const_bc1(setNo);
expNo = cS.expBase;
cS.dbg = 111;

paramS = param_load_bc1(setNo, expNo);

iCohort = randi(cS.nCohorts, [1,1]);
j = randi(cS.nTypes, [1,1]);

k = randn([1,1]) * paramS.kMax;
wColl = paramS.wColl_jV(j);
pColl = paramS.pColl_jV(j);


%% Budget constraint

hoursV = rand([3,1]);
kPrimeV = randn([3,1]);
kV = rand([3,1]);
cV = hh_bc1.coll_bc(kPrimeV, hoursV, kV, wColl, pColl, paramS.R, cS);

kPrime2V = hh_bc1.hh_bc_coll_bc1(cV, hoursV, kV, wColl, pColl, paramS.R, cS);

if any(abs(kPrime2V - kPrimeV) > 1e-6)
   error_bc1('Invalid bc', cS);
end


%% Utility

fprintf('Test hh utility in college\n');
n = 5;
cV = linspace(1, 2, n);
leisureV = linspace(0.1, 0.9, n);
[muCV, muLV, utilV] = hh_bc1.hh_util_coll_bc1(cV, leisureV, paramS, cS);

% Inverse of u(c)
c2V = hh_bc1.hh_uprimec_inv_bc1(muCV, paramS, cS);
if max(abs(c2V - cV)) > 1e-6
   error('Invalid inverse marginal utility');
end

% MU(l)
dLeisure = 1e-5;
[~,~,util2V] = hh_bc1.hh_util_coll_bc1(cV, leisureV + dLeisure, paramS, cS);
if max(abs(((util2V - utilV) ./ dLeisure - muLV) ./ max(0.1, muLV))) > 1e-4
   error_bc1('Invalid mu(l)', cS);
end

% Mu(c)
dc = 1e-5;
[~,~,util2V] = hh_bc1.hh_util_coll_bc1(cV + dc, leisureV, paramS, cS);
if max(abs(((util2V - utilV) ./ dc - muCV) ./ max(0.1, muCV))) > 1e-4
   error_bc1('Invalid mu(c)', cS);
end


fprintf('hh college, c from kPrime \n');
kPrime = k - 0.1;
c = hh_bc1.hh_coll_c_from_kprime_bc1(kPrime, k, wColl, pColl, paramS, cS);



fprintf('Static condition in college \n');
cV = linspace(0.05, 5, 10);
hoursV = hh_bc1.hh_static_bc1(cV, wColl, paramS, cS);
fprintf('l = ');
fprintf('  %.2f', hoursV);
fprintf('\n');

fprintf('Euler deviation in college\n');
kPrimeV = linspace(2, 3, length(cV))';
eeDevV = hh_bc1.hh_eedev_coll3_bc1(cV, hoursV, kPrimeV, j, iCohort, paramS, cS);

% fprintf('Corner solution in college; period 3 \n');
% kMin = -0.5;
% [eeDev, c, l] = hh_corner_coll3_bc1(k, wColl, pColl, kMin, iCohort, paramS, cS);
% fprintf('c = %.3f    l = %.3f \n', c, l);

fprintf('Hh in college; period 3 \n');
[c, l, kPrime, vColl] = hh_bc1.coll_pd3(k, wColl, pColl, j, iCohort, paramS, cS);
fprintf('c = %.3f    l = %.3f    kPrime: %3.f \n',  c, l, kPrime);

fprintf('hh solution\n');
saveS = hh_bc1.hh_solve(iCohort, paramS, cS);


end