function fit(saveFigures, setNo, expNo)

cS = const_bc1(setNo, expNo);
outS = var_load_bc1(cS.vCalResults, cS);
nIq = length(cS.iqUbV);


%% Prob enter college | IQ  /  prob grad | IQ
if 1
   for iPlot = 1 : 2
      if iPlot == 1
         nameStr = 'enter/iq';
         yStr = 'Fraction entering college';
         figFn = 'fit_enter_iq';
      elseif iPlot == 2
         nameStr = 'grad/iq';
         yStr = 'Fraction graduating from college';
         figFn = 'fit_grad_iq';
      else
         error('Invalid');
      end
      ds = outS.devV.dev_by_name(nameStr);
      
      if ~isempty(ds)
         % Not all cohorts have this target
         fh = output_bc1.fig_new(saveFigures, []);
         bar(1 : nIq, [ds.modelV(:), ds.dataV(:)]);
         xlabel('IQ group');
         ylabel(yStr);
         figures_lh.axis_range_lh([NaN NaN 0 1]);
         output_bc1.fig_format(fh, 'bar');
         output_bc1.fig_save(figFn, saveFigures, cS);
      end
   end
end



end