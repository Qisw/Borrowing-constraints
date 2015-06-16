function prob_a_jgrad_test

fprintf('\nTesting Prob(a | j, grad) by simulation \n');

%% Parameters

rng(3);
dbg = 111;

nAbil = 9;
nTypes = 11;
prGrad_aV = linspace(0.1, 0.9, nAbil);
prGrad_aV = prGrad_aV(:) ./ sum(prGrad_aV);
pr_jV = linspace(2, 1, nTypes);
pr_jV = pr_jV(:) / sum(pr_jV);

prA_jM = linspace(2, 3, nAbil)' * linspace(4,3, nTypes);
for j = 1 : nTypes
   prA_jM(:,j) = prA_jM(:,j) / sum(prA_jM(:,j));
end


%% Test by sim

prA_jgradM = hh_bc1.prob_a_jgrad(prGrad_aV, pr_jV, prA_jM, dbg);

nSim = 5e6;
jV = random_lh.rand_discrete(pr_jV, rand([nSim,1]), dbg);
iAbilV = nan([nSim, 1]);
for j = 1 : nTypes
   jIdxV = find(jV == j);
   iAbilV(jIdxV) = random_lh.rand_discrete(prA_jM(:,j), rand([length(jIdxV), 1]), dbg);
end

gradV = nan([nSim, 1]);
for iAbil = 1 : nAbil
   aIdxV = find(iAbilV == iAbil);
   gradV(aIdxV) = (rand([length(aIdxV), 1]) <= prGrad_aV(iAbil));
end


prSimA_jgradM = zeros([nAbil, nTypes]);
for j = 1 : nTypes
   jIdxV = find((jV == j)  &  (gradV == 1));
   for iAbil = 1 : nAbil
      prSimA_jgradM(iAbil, j) = sum(iAbilV(jIdxV) == iAbil) ./ length(jIdxV);
   end
end

diff_ajM = prA_jgradM - prSimA_jgradM;

maxDiff = max(abs(diff_ajM(:)));
fprintf('  Max diff between simulated and true ability: %.3f \n',  maxDiff);

if maxDiff > 0.005
   error('Large differences');
end


end