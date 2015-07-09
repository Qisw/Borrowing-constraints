function plots(saveFigures, setNo)

cS = const_bc1(setNo);
figS = const_fig_bc1;


%% CPI
if 1
   cpiS = var_load_bc1(cS.vCpi, cS);
   fh = output_bc1.fig_new(saveFigures, []);
   plot(cpiS.yearV, cpiS.cpiV, figS.lineStyleDenseV{1}, 'color', figS.colorM(1,:));
   xlabel('Year');
   ylabel('CPI');
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save(fullfile(cS.dataOutDir, 'cpi_year'), saveFigures, cS);   
end


%% College costs by year
% Constant prices
if 1
   costS = var_load_bc1(cS.vCollCosts, cS);
   fh = output_bc1.fig_new(saveFigures, []);
   plot(costS.yearV, costS.tuitionV, figS.lineStyleDenseV{1}, 'color', figS.colorM(1,:));
   xlabel('Year');
   ylabel('Mean college cost');
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save(fullfile(cS.dataOutDir, 'collcost_year'), saveFigures, cS);
end

%% College costs by cohort
% need to be detrended +++++
if 1
   costS = var_load_bc1(cS.vCollCosts, cS);
   
   bYearV = costS.yearV(:) - 23;
   dataV  = costS.tuitionV(:);
   % Only show reasonably recent years
   yrIdxV = find(bYearV >= cS.bYearV(1));

   fh = output_bc1.plot_by_cohort(bYearV(yrIdxV), dataV(yrIdxV), saveFigures, cS);
   ylabel(sprintf('Mean college cost, %i prices', cS.cpiBaseYear));
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save(fullfile(cS.dataOutDir, 'collcost_cohort'), saveFigures, cS);
   
end


end