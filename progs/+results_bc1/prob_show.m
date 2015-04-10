function prob_show(saveFigures, setNo, expNo)

if nargin < 2
   expNo = [];
end

cS = const_bc1(setNo, expNo);
figS = const_fig_bc1;
paramS = param_load_bc1(setNo, expNo);
aggrS = var_load_bc1(cS.vAggregates, cS);
% tgS = var_load_bc1(cS.vCalTargets, cS);
% iCohort = cS.iCohort; 



%% Prob grad | j
if 1
   % Sort types by prob grad
   sortM = sortrows([aggrS.prGrad_jV, aggrS.mass_jV]);
   
   fh = output_bc1.fig_new(saveFigures, []);
   plot(cumsum(sortM(:,2)), sortM(:,1), 'o', 'color', figS.colorM(1,:));
   xlabel('Signal percentile');
   ylabel('Graduation probability');
   figures_lh.axis_range_lh([NaN NaN 0 1]);
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save('prob_grad_j', saveFigures, cS);
end


%% Prob grad | a
if 1
   fh = output_bc1.fig_new(saveFigures, []);
   plot(cumsum(paramS.prob_aV), paramS.prGrad_aV, figS.lineStyleV{1});
   xlabel('Ability percentile');
   ylabel('Graduation probability');
   figures_lh.axis_range_lh([NaN NaN 0 1]);
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save('prob_grad_a', saveFigures, cS);
end



end