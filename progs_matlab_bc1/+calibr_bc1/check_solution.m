function check_solution(setNo, expNo)
% Check computed equilibrium

cS = const_bc1(setNo, expNo);
paramS = param_load_bc1(setNo, expNo);
aggrS = var_load_bc1(cS.vAggregates, cS);
hhS = var_load_bc1(cS.vHhSolution, cS);

fp = 1;

fprintf(fp, '\nChecking equilibrium\n');


%% Are value functions monotonic?

% too strict: schooling could reduce value of work for low ability +++
outM = ismonotonic(hhS.vWorkS.value_ksaM);
if any(~outM(:))
   error_bc1('value of working by [k,s,a] not monotonic', cS);
end

for j = 1 : cS.nTypes
   % too strict: schooling could reduce value of work for low ability +++
   outM = ismonotonic(hhS.vWorkS.value_ksjM(:,:,j), 0, 'INCREASING');
   if any(~outM(:))
      error_bc1('value of working by [k,s,j] not monotonic', cS);
   end
   
   outM = ismonotonic(hhS.vColl3S.value_kajM(:,:,j), 0, 'INCREASING');
   if any(~outM(:))
      error_bc1('value of coll3 by [k,a,j] not monotonic', cS);
   end
   
   outM = ismonotonic(hhS.v1S.value_kjM(:,j), 0, 'INCREASING');
   if any(~outM(:))
      error_bc1('value of collM by [k] not monotonic', cS);
   end
end



%% How often is kMax reached?
% Is grid too narrow

fprintf(fp, '\nkMax is binding this often in each period: \n');
fprintf(fp, '  %i',  sum(aggrS.k_tjM > paramS.kMax - 1e-6, 2));
fprintf(fp, '\n');
fprintf(fp, 'Highest k chosen:  %.0f    kMax: %.0f \n',  max(aggrS.k_tjM(:)), paramS.kMax);






end