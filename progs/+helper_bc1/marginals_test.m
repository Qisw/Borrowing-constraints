function marginals_test

fprintf('Testing marginals \n');

rng(3);
dbg = 111;
nq = 3;
ny = 4;
nSim = 1e5;

prob_qV = rand(nq,1);
prob_qV = prob_qV / sum(prob_qV);
prob_yV = rand(ny,1);
prob_yV = prob_yV / sum(prob_yV);

probX_qyM = rand(nq, ny);

qV = random_lh.rand_discrete(prob_qV, rand(nSim,1), dbg);
yV = random_lh.rand_discrete(prob_yV, rand(nSim,1), dbg);
% latentV = 0.1 .* qV - 0.2 .* yV;
% xMean = mean(latentV);
% xV = (latentV > 0.4 .* xMean);

mass_qyM = zeros([nq, ny]);
xV = zeros(nSim, 1);
for iq = 1 : nq
   for iy = 1 : ny
      idxV = find(qV == iq  &  yV == iy);
      mass_qyM(iq, iy) = length(idxV);
      xV(idxV) = rand(size(idxV)) < probX_qyM(iq, iy);
   end
end

meanX_qV = accumarray(qV, xV, [nq,1], @mean);
meanX_yV = accumarray(yV, xV, [ny,1], @mean);

[prX_qV, prX_yV] = helper_bc1.marginals(probX_qyM, mass_qyM, dbg);

diff_qV = meanX_qV(:) - prX_qV(:);
diff_yV = meanX_yV(:) - prX_yV(:);

if any(abs(diff_qV) > 1e-2)  ||  any(abs(diff_yV) > 1e-2)
   error('Wrong marginals');
end


end