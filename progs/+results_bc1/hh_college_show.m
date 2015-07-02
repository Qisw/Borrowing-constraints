function hh_college_show(saveFigures, setNo, expNo)

cS = const_bc1(setNo, expNo);
figS = const_fig_bc1;
paramS = param_load_bc1(setNo, expNo);
hhS = var_load_bc1(cS.vHhSolution, cS);


%% Value functions
if 1
   j = round(cS.nTypes / 2);
   
   for iPlot = 1 : 3
      if iPlot == 1
         % Value period 3
         kV = hhS.vColl3S.kGridV;
         valueV = hhS.vColl3S.value_kjM(:, j);
         figName = 'vcollege3';
      elseif iPlot == 2
         % Value end of period 2 (before learning a)
         kV = hhS.vmS.kGridV;
         valueV = hhS.vmS.value_kjM(:, j);
         figName = 'vcollege2';
      elseif iPlot == 3
         % Value end of period 2 (before learning a)
         kV = hhS.v1S.kGridV;
         valueV = hhS.v1S.value_kjM(:, j);
         figName = 'vcollege1';
      else
         error('Invalid');
      end
      
      fh = output_bc1.fig_new(saveFigures, []);
      plot(kV, valueV, figS.lineStyleDenseV{1}, 'color', figS.colorM(1,:));
      xlabel('k');
      ylabel('Value');
      output_bc1.fig_format(fh, 'line');
      output_bc1.fig_save(fullfile(cS.hhDir, figName), saveFigures, cS);      
   end
end

end