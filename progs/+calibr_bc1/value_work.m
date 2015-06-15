function vWorkS = value_work(paramS, cS)
% Value of working. Presolve and make continuous approximations
%{
Test:
   test_bc1.work
%}

nk = 50;
vWorkS.kGridV = linspace(min(paramS.kMin_aV), paramS.kMax, nk)';


%% Value after learning ability

vWorkS.value_ksaM = nan([nk, cS.nSchool, cS.nAbil]);
% vWorkS.muK_ksaM = nan([nk, cS.nSchool, cS.nAbil]);
% Continuous approximation
vWorkS.vFct_saM = cell([cS.nSchool, cS.nAbil]);
% vWorkS.muFct_saM = cell([cS.nSchool, cS.nAbil]);
for iSchool = 1 : cS.nSchool
   for iAbil = 1 : cS.nAbil
      vWorkS.value_ksaM(:,iSchool,iAbil) = ...
         hh_bc1.hh_work_bc1(vWorkS.kGridV, iSchool, iAbil, paramS, cS);
      vWorkS.vFct_saM{iSchool,iAbil} = griddedInterpolant(vWorkS.kGridV, vWorkS.value_ksaM(:,iSchool,iAbil), ...
         'pchip', 'linear');
      % not needed 
      %vWorkS.muFct_saM{iSchool,iAbil} = griddedInterpolant(vWorkS.kGridV, vWorkS.muK_ksaM(:,iSchool,iAbil), ...
      %   'pchip', 'linear');
   end
end
if cS.dbg > 10
   validateattributes(vWorkS.value_ksaM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [nk, cS.nSchool, cS.nAbil]})
end


%%  Value function before learning ability

vWorkS.value_ksjM = nan([nk, cS.nSchool, cS.nTypes]);
% Continuous approximation
% vWorkS.vFct_sjM = cell([cS.nSchool, cS.nTypes]);

for j = 1 : cS.nTypes
   % Prob(a | j)
   pr_aV = paramS.prob_a_jM(:, j);
   for iSchool = 1 : cS.nSchool
      for ik = 1 : nk
         vWork_aV = vWorkS.value_ksaM(ik,iSchool,:);
         vWorkS.value_ksjM(ik,iSchool,j) = sum(pr_aV .* vWork_aV(:));
      end
      %       vWorkS.vFct_sjM{iSchool,j} = griddedInterpolant(vWorkS.kGridV, vWorkS.value_ksjM(:,iSchool,j), ...
      %          'pchip', 'linear');
   end
end
if cS.dbg > 10
   validateattributes(vWorkS.value_ksjM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [nk, cS.nSchool, cS.nTypes]})
end


end