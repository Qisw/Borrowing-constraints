function pr_iq_a

fprintf('Testing pr_iq_a \n');

dbg = 111;
nAbil = 7;
abilV = linspace(-1, 1, nAbil)';
prob_aV = rand([nAbil, 1]);
prob_aV = prob_aV ./ sum(prob_aV);
sigmaIQ = 0.3;
iqUbV = linspace(0.1, 1, 6);

pr_iq_aM = calibr_bc1.pr_iq_a(abilV, prob_aV, sigmaIQ, iqUbV, dbg);


%% Simulate

n = 1e6;
nIqV = round(prob_aV .* n);
ubV = cumsum(nIqV);
ubV(end) = n;
lbV = [1; ubV(1 : (end-1)) + 1];

iAbilV = nan([n,1]);
iqV = nan([n,1]);
for ia = 1 : nAbil
   iAbilV(lbV(ia) : ubV(ia)) = ia;
   iqV(lbV(ia) : ubV(ia)) = abilV(ia) + sigmaIQ .* randn([ubV(ia) - lbV(ia) + 1, 1]);
end

% fprintf('mean IQ by ability class: \n');
% accumarray(iAbilV, iqV, [nAbil, 1], @mean)

% IQ classes
iqClV = distrib_lh.class_assign(iqV, ones(size(iqV)), iqUbV, dbg);

cnt_qaM = accumarray([iqClV, iAbilV], 1);


%% Compare

pr_iq_a_simM = cnt_qaM ./ (ones([length(iqUbV), 1]) * sum(cnt_qaM));

pDiffM = pr_iq_a_simM - pr_iq_aM;

maxDiff = max(abs(pDiffM(:)));
fprintf('Max diff between simulated and calibrated probabilities: %.3f \n', maxDiff);

if maxDiff > 1e-2
   error('Not correct');
end

end