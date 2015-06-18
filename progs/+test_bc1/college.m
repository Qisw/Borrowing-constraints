function college(setNo)
% Test college routines

cS = const_bc1(setNo);
expNo = cS.expBase;
cS.dbg = 111;
fprintf('\nTesting college code\n');

paramS = param_load_bc1(setNo, expNo);

% iCohort = randi(cS.nCohorts, [1,1]);
j = randi(cS.nTypes, [1,1]);
iAbil = randi(cS.nAbil, [1,1]);

k = randn([1,1]) * paramS.kMax;
wColl = paramS.wColl_jV(j);
pColl = paramS.pColl_jV(j);


% Test beliefs in college
hh_bc1.prob_a_jgrad_test;

% Test saved hh solution
test_entry(paramS, cS);
test_saved12(paramS, cS);
test_saved34(paramS, cS);

% Syntax test
hh_bc1.coll_pd3_test(setNo);


%% Budget constraint

hoursV = rand([3,1]);
kPrimeV = randn([3,1]);
kV = rand([3,1]);
cV = hh_bc1.coll_bc(kPrimeV, hoursV, kV, wColl, pColl, paramS.R, cS);

kPrime2V = hh_bc1.coll_bc_kprime(cV, hoursV, kV, wColl, pColl, paramS.R, cS);

if any(abs(kPrime2V - kPrimeV) > 1e-6)
   error_bc1('Invalid bc', cS);
end


%% Utility

fprintf('Test hh utility in college\n');
n = 5;
cV = linspace(1, 2, n);
leisureV = linspace(0.1, 0.9, n);
j = round(cS.nTypes / 2);
[utilV, muCV, muLV] = hh_bc1.hh_util_coll_bc1(cV, leisureV, paramS.cColl_jV(j), paramS.lColl_jV(j),  ...
   paramS.prefWt, paramS.prefSigma,   paramS.prefWtLeisure, paramS.prefRho);

% Inverse of u(c)
% c2V = hh_bc1.hh_uprimec_inv_bc1(muCV, paramS, cS);
% if max(abs(c2V - cV)) > 1e-6
%    error('Invalid inverse marginal utility');
% end

% MU(l)
dLeisure = 1e-5;
util2V = hh_bc1.hh_util_coll_bc1(cV, leisureV + dLeisure, paramS.cColl_jV(j), paramS.lColl_jV(j), ...
   paramS.prefWt, paramS.prefSigma,   paramS.prefWtLeisure, paramS.prefRho);
if max(abs(((util2V - utilV) ./ dLeisure - muLV) ./ max(0.1, muLV))) > 1e-4
   error_bc1('Invalid mu(l)', cS);
end

% Mu(c)
dc = 1e-5;
util2V = hh_bc1.hh_util_coll_bc1(cV + dc, leisureV, paramS.cColl_jV(j), paramS.lColl_jV(j), ...
   paramS.prefWt, paramS.prefSigma,   paramS.prefWtLeisure, paramS.prefRho);
if max(abs(((util2V - utilV) ./ dc - muCV) ./ max(0.1, muCV))) > 1e-4
   error_bc1('Invalid mu(c)', cS);
end


fprintf('hh college, c from kPrime \n');
kPrime = k - 0.1;
c = hh_bc1.hh_coll_c_from_kprime_bc1(kPrime, k, wColl, pColl, j, paramS, cS);



fprintf('Static condition in college \n');
cV = linspace(0.05, 5, 10);
hoursV = hh_bc1.hh_static_bc1(cV, wColl, j, paramS, cS);
fprintf('l = ');
fprintf('  %.2f', hoursV);
fprintf('\n');


% fprintf('Utility in college by c, k, j\n');
% collUtilS = coll_util_ckj(paramS, cS);
% collUtilS = coll_util_kkj(paramS, cS);

% fprintf('Euler deviation in college (syntax only)\n');
% kPrimeV = linspace(2, 3, length(cV))';
% eeDevV = hh_bc1.hh_eedev_coll3_bc1(cV, hoursV, kPrimeV, iAbil, vWorkS, paramS, cS);

% fprintf('Corner solution in college; period 3 \n');
% kMin = -0.5;
% [eeDev, c, l] = hh_corner_coll3_bc1(k, wColl, pColl, kMin, iCohort, paramS, cS);
% fprintf('c = %.3f    l = %.3f \n', c, l);

% fprintf('Hh in college; period 3 \n');
% [c, l, kPrime, vColl] = hh_bc1.coll_pd3(k, wColl, pColl, iAbil, vWorkS, paramS, cS);
% fprintf('c = %.3f    l = %.3f    kPrime: %3.f \n',  c, l, kPrime);


if 0
   fprintf('Hh solution\n');
   tic
   saveS = hh_bc1.hh_solve(paramS, cS);
   toc
end


end


%% Test entry
function test_entry(paramS, cS)
   [hhS, success] = var_load_bc1(cS.vHhSolution, cS);
   if success == 0
      return;
   end
   fprintf('Testing college entry \n');
   v0S = hhS.v0S;

   % Budget constraint
   if any((v0S.zWork_jV .* cS.collLength - v0S.k1Work_jV) > 1e-4)
      error('Wrong k1 work');
   end
   if any(abs(v0S.zColl_jV .* cS.collLength - v0S.k1Coll_jV) > 1e-4)
      error('Wrong k1 college');
   end
end


%% Test saved solution: periods 1-2
function test_saved12(paramS, cS)
   [hhS, success] = var_load_bc1(cS.vHhSolution, cS);
   if success == 0
      return;
   end
   fprintf('Testing saved hh solution for college period 1-2 \n');
   
   for j = 1 : cS.nTypes
      cV = hhS.v1S.c_kjM(:,j);
      hoursV = hhS.v1S.hours_kjM(:,j);
      kV = hhS.v1S.kGridV;

      % RHS of Bellman by ik
      rhsV = hh_bc1.bellman_coll1(j, cV, hoursV, kV, hhS, paramS, cS);
      lhsV = hhS.v1S.value_kjM(:, j);
      if any(abs(rhsV - lhsV) > 1e-3)
         error_bc1('Wrong value', cS);
      end

      % Check optimization
      dcV = [1e-4, -1e-4, 0, 0];
      dhV = [0, 0, 1e-4, -1e-4];
      for iCase = 1 : 4
         rhs2V = hh_bc1.bellman_coll1(j, cV + dcV(iCase), hoursV + dhV(iCase), kV, hhS, paramS, cS);
         if any(rhs2V - rhsV > 1e-3)
            error_bc1('Invalid', cS);
         end
      end
   end

end


%% Test saved hh solution: periods 3-4
function test_saved34(paramS, cS)
   [hhS, success] = var_load_bc1(cS.vHhSolution, cS);
   if success == 0
      return;
   end
   fprintf('Testing saved hh solution for college period 3-4 \n');
   
   for j = 1 : cS.nTypes
      for iAbil = 1 : cS.nAbil
         % No longer depends on ability +++
         cV = hhS.vColl3S.c_kajM(:,iAbil,j);
         hoursV = hhS.vColl3S.hours_kajM(:,iAbil,j);
         kV = hhS.vColl3S.kGridV;

         % RHS of Bellman by ik
         rhsV = hh_bc1.bellman_coll3(j, cV, hoursV, kV, hhS, paramS, cS);
         lhsV = hhS.vColl3S.value_kajM(:, iAbil, j);
         if any(abs(rhsV - lhsV) > 1e-4)
            error_bc1('Wrong value', cS);
         end
         
         % Check optimization
         dcV = [1e-4, -1e-4, 0, 0];
         dhV = [0, 0, 1e-4, -1e-4];
         for iCase = 1 : 4
            rhs2V = hh_bc1.bellman_coll3(j, cV + dcV(iCase), hoursV + dhV(iCase), kV, hhS, paramS, cS);
            if any(rhs2V - rhsV > 1e-4)
               error_bc1('Invalid', cS);
            end
         end
      end
   end

end
