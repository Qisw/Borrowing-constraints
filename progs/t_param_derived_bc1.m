function t_param_derived_bc1(setNo)

cS = const_bc1(setNo);
figS = const_fig_bc1;
saveFigures = 0;

paramS = param_load_bc1(setNo, cS.expBase);

fprintf('\nTesting param_derived\n');


%% Test endowments

fprintf('Testing endowments \n');

% Simulate endowments
nSim = 1e5;
[abilV, jV, iqV] = calibr_bc1.endow_sim(nSim, paramS, cS);

% IQ quartiles
nIq = length(cS.iqUbV);
iqClV = distrib_lh.class_assign(iqV, ones(size(iqV)), cS.iqUbV, cS.dbg);
validateattributes(iqClV, {'double'}, {'finite', 'nonnan', 'nonempty', 'integer', '>=', 1, '<=', nIq, ...
   'size', [nSim, 1]})



% *******  Test pr(IQ | j)

fprintf('Testing Pr(IQ | j) \n');

cnt_qjM = accumarray([iqClV, jV], 1, [nIq, cS.nTypes]);

% Pr(q | j) = Pr(q and j) ./ Pr(j)
cnt_jV = sum(cnt_qjM);
pr_q_jM = cnt_qjM ./ (ones([nIq,1]) * cnt_jV(:)');

regrS = regress_lh.regr_stats_lh(paramS.prIq_jM(:),  [ones(size(pr_q_jM(:))), pr_q_jM(:)], 0.05, cS.dbg);
fprintf('Regress pr(IQ|j) against simulated probs \n');
fprintf('  Intercept: %.3f (%.3f)  slope: %.3f (%.3f) \n',  regrS.betaV(1), regrS.seBetaV(1), ...
   regrS.betaV(2), regrS.seBetaV(2));

if 1
   fh = output_bc1.fig_new(saveFigures, []);
   plot(pr_q_jM(:),  paramS.prIq_jM(:), '.', 'color', figS.colorM(1,:));
   xlabel('Simulated pr(IQ|j)');
   ylabel('True pr(IQ|j)');
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save('test_pr_iq_j', saveFigures, cS);   
end


end