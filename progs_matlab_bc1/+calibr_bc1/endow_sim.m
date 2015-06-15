function [abilV, jV, iqV] = endow_sim(nSim, paramS, cS)
% Simulate endowments
% Mainly for testing and diagnostics

% Draw types
rng(6);
jV = random_lh.rand_discrete(paramS.prob_jV, rand([nSim,1]), cS.dbg);
mV = paramS.m_jV(jV);

% Draw ability and IQ
abilV = nan([nSim, 1]);
iqV = nan([nSim, 1]);
for j = 1 : cS.nTypes
   jIdxV = find(jV == j);
   n = length(jIdxV);
   % This is needed to make histc in rand_discrete work (all probs must be > 0)
   prob_aV = paramS.prob_a_jM(:,j);
   prob_aV = max(1e-8, prob_aV);
   prob_aV = prob_aV ./ sum(prob_aV);
   abilV(jIdxV) = paramS.abilGrid_aV(random_lh.rand_discrete(prob_aV, rand([n, 1]), cS.dbg));
   iqV(jIdxV) = mV(jIdxV) + paramS.sigmaIQ .* randn([n,1]);
end

% Transform to N(0,1)
iqV = (iqV - mean(iqV)) ./ std(iqV);


%% Self test
if cS.dbg > 10
   validateattributes(iqV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'size', [nSim,1]})
end

   
end