function work(setNo)

fprintf('\nTesting hh work routines\n\n');

cS = const_bc1(setNo);
cS.dbg = 111;

paramS.setNo = setNo;
paramS = param_derived_bc1(paramS, cS);

k = randn([1,1]);
iSchool = randi(cS.nSchool, [1,1]);
iCohort = randi(cS.nCohorts, [1,1]);
j = randi(cS.nTypes, [1,1]);


fprintf('Test utility at work \n');
[utilV, muV, utilLifetime] = hh_bc1.util_work_bc1(linspace(0.1, 10, 5), paramS, cS);

fprintf('Test hh_work \n');
[cV, util, pvEarn, muK] = hh_bc1.hh_work_bc1(k, iSchool, j, iCohort, paramS, cS);

fprintf('Test marginal utility of k\n');
dk = 1e-5;
[~, util2] = hh_bc1.hh_work_bc1(k + dk, iSchool, j, iCohort, paramS, cS);
muK2 = (util2 - util) ./ dk;
if abs(muK2 - muK) > 1e-4
   error_bc1('Invalid muK', cS);
end


end