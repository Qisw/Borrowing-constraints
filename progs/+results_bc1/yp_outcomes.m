function yp_outcomes(saveFigures, setNo, expNo)

cS = const_bc1(setNo, expNo);
nYp = length(cS.ypUbV);
iCohort = cS.iCohort;
% figS = const_fig_bc1;
% paramS = param_load_bc1(setNo, expNo);
aggrS = var_load_bc1(cS.vAggregates, cS);
tgS = var_load_bc1(cS.vCalTargets, cS);


%% Bar graphs
if 1
   yStrV = {'Fraction entering college',  'Fraction graduating from college'};
   figFnV = {'yp_enter',   'yp_grad'};
   modelV = {aggrS.ypS.fracEnter_yV, aggrS.ypS.fracGrad_yV};
   dataV = {tgS.fracEnter_ycM(:, iCohort), tgS.fracGrad_ycM(:,iCohort)};
   
   for iPlot = 1 : length(modelV)
      fh = output_bc1.fig_new(saveFigures, []);
      mV = modelV{iPlot};
      dV = dataV{iPlot};
      bar(1 : nYp, [mV(:), dV(:)]);
      xlabel('yp group');
      ylabel(yStrV{iPlot});
      legend({'Model', 'Data'}, 'location', 'northwest');
      figures_lh.axis_range_lh([NaN NaN 0 1]);
      output_bc1.fig_format(fh, 'bar');
      output_bc1.fig_save(fullfile(cS.outDir, figFnV{iPlot}), saveFigures, cS);
   end
end


end