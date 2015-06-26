function fit(saveFigures, setNo, expNo)

cS = const_bc1(setNo, expNo);
outS = var_load_bc1(cS.vCalResults, cS);
nIq = length(cS.iqUbV);


%% Prob enter college | IQ  /  prob grad | IQ  /   also by yp
if 1
   nameV = {'enter/iq',    'grad/iq',    'enter/yp',    'grad/yp'};
   xStrV = {'IQ group',    'IQ group',   'yp group',    'yp group'};
   yStrV = {'Fraction entering college',  'Fraction graduating from college', ...
      'Fraction entering college',  'Fraction graduating from college'};
   figFnV = {'iq_enter',   'iq_grad',    'yp_enter',    'yp_grad'};
   
   for iPlot = 1 : length(nameV)
      ds = outS.devV.dev_by_name(nameV{iPlot});
      
      if ~isempty(ds)
         % Not all cohorts have this target
         fh = output_bc1.fig_new(saveFigures, []);
         bar(1 : nIq, [ds.modelV(:), ds.dataV(:)]);
         xlabel(xStrV{iPlot});
         ylabel(yStrV{iPlot});
         legend({'Model', 'Data'}, 'location', 'northwest');
         figures_lh.axis_range_lh([NaN NaN 0 1]);
         output_bc1.fig_format(fh, 'bar');
         output_bc1.fig_save(['fit_', figFnV{iPlot}], saveFigures, cS);
      end
   end
end



end