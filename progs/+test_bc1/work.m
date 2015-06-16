function work(setNo)

fprintf('\nTesting hh work routines\n\n');

cS = const_bc1(setNo);
expNo = 1;
cS.dbg = 111;

paramS = param_load_bc1(setNo, expNo);

k = randn([1,1]);
iSchool = randi(cS.nSchool, [1,1]);
% iCohort = randi(cS.nCohorts, [1,1]);
iAbil = randi(cS.nAbil, [1,1]);
% j = randi(cS.nTypes, [1,1]);


fprintf('Test utility at work \n');
[utilV, muV, utilLifetime] = hh_bc1.util_work_bc1(linspace(0.1, 10, 5), paramS, cS);

fprintf('Test hh_work \n');
[util, muK, cV] = hh_bc1.hh_work_bc1(k, iSchool, iAbil, paramS, cS);


[hhS, hhSuccess] = var_load_bc1(cS.vHhSolution, cS);
if hhSuccess == 1
   fprintf('Also testing saved hh value \n');
end


%% Test all work equations

for iSchool = 1 : cS.nSchool
   for iAbil = 1 : cS.nAbil
      k = rand(1);
      [util, muK, cV] = hh_bc1.hh_work_bc1(k, iSchool, iAbil, paramS, cS);
      
      % Euler
      cGrowthV = cV(2:end) ./ cV(1 : (end-1));
      eulerDevV = cGrowthV - (paramS.prefBeta .* paramS.R) .^ (1 / paramS.workSigma);
      if any(abs(eulerDevV > 1e-4))
         error_bc1('Euler violated', cS);
      end
      
      % Present value budget constraint tested in hh_work_bc1
      
      
      % Marginal utility of k
      dk = 1e-5;
      util2 = hh_bc1.hh_work_bc1(k + dk, iSchool, iAbil, paramS, cS);
      muK2 = (util2 - util) ./ dk;
      if abs(muK2 - muK) > 1e-4
         error_bc1('Invalid muK', cS);
      end
      
      % Lifetime utility: no test. Eqn is directly in hh code
      % But test that saved value function is correct
      if hhSuccess == 1
         vWorkS = hhS.vWorkS;
         for ik = 1 : length(vWorkS.kGridV)
            util = hh_bc1.hh_work_bc1(vWorkS.kGridV(ik), iSchool, iAbil, paramS, cS);
            if abs(vWorkS.value_ksaM(ik,iSchool,iAbil) - util > 1e-4)
               error_bc1('Invalid value of work', cS);
            end
         end
      end
   end
end


end