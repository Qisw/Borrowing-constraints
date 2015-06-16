function prA_jgradM = prob_a_jgrad(prGrad_aV, pr_jV, prA_jM, dbg)
% Prob(a | j, graduation draw successful)
%{
Beliefs of household at start of period 3 who has drawn positive graduation outcome

OUT
   prA_jgradM(a, j)
      prob(a | j and graduation)
%}

nAbil = length(prGrad_aV);
nTypes = length(pr_jV);

% Pr(a | j, grad)
prA_jgradM = nan([nAbil, nTypes]);
for j = 1 : nTypes
   % Pr(j | grad) = sum over a: pr(a | j) pr(grad | a)
   prJ_grad = sum(prA_jM(:,j) .* prGrad_aV);
   % Pr(j, grad) = Pr(j|grad) * Pr(j)
   pr_jgrad = prJ_grad * pr_jV(j);
   for iAbil = 1 : nAbil
      % Pr(a,j,grad) = Pr(j) * Pr(a|j) * Pr(grad|a)
      pr_ajg = pr_jV(j) * prA_jM(iAbil,j) * prGrad_aV(iAbil);
      prA_jgradM(iAbil, j) = pr_ajg / pr_jgrad;
   end
end


%% Output check
if dbg > 10
   validateattributes(prA_jgradM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, ...
      '<', 1, 'size', [nAbil, nTypes]})
   pSumV = sum(prA_jgradM);
   if any(abs(pSumV - 1) > 1e-5)
      error('probs do not sum to 1');
   end
end


end