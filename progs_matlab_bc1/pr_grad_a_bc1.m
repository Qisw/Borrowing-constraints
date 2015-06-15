function prGradV = pr_grad_a_bc1(abilIdxV, iCohort, paramS, cS)
% Prob of graduating | a
%{
Generalized logistic
%}
% -------------------------------------

pr0 = paramS.prGradMin;
pr1 = paramS.prGradMax;

prGradV = pr0 + (pr1 - pr0) ./ ...
   (1 + paramS.prGradMult ./ exp(paramS.prGradExp .* (paramS.abilGrid_aV(abilIdxV) - paramS.prGradABase))) ...
   .^ (1 / paramS.prGradPower);



%% Output check

if any(prGradV < 0)
   error('negative pr pass');
end
if any(prGradV > 1)
   error('pr > 1');
end


end