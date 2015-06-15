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
   output_bc1.fig_save('cpi_year', saveFigures, cS);   
end


%% College costs by year
if 1
   costS = var_load_bc1(cS.vCollCosts, cS);
   fh = output_bc1.fig_new(saveFigures, []);
   plot(costS.yearV, costS.tuitionV, figS.lineStyleDenseV{1}, 'color', figS.colorM(1,:));
   xlabel('Year');
   ylabel('Mean college cost');
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save('collcost_year', saveFigures, cS);
end


end