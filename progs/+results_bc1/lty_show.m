function lty_show(saveFigures, setNo, expNo)

cS = const_bc1(setNo, expNo);
figS = const_fig_bc1;
paramS = param_load_bc1(setNo, expNo);
outDir = cS.paramDir;



%% 3D plot: pvEarn_as
if 1
   discFactor_sV = paramS.R .^ (cS.ageWorkStart_sV - cS.age1);
   for iPlot = 1 : 2
      if iPlot == 1
         pvEarn_asM = paramS.pvEarn_asM;
         figFn = 'pvearn_as';
      elseif iPlot == 2
         % Discounted to age 1
         pvEarn_asM = paramS.pvEarn_asM ./ (ones([cS.nAbil, 1]) * discFactor_sV(:)');
         figFn = 'pvearn_age1_as';
      else
         error('Invalid');
      end
      
      fh = output_bc1.fig_new(saveFigures, []);
      bar3(log(pvEarn_asM) - log(pvEarn_asM(1,1)));
      xlabel('Schooling');
      ylabel('Ability');
      zlabel('Log lifetime earnings');
      colormap(figS.colorMap);
      view([-135, 30]);
      output_bc1.fig_format(fh, 'bar');
      output_bc1.fig_save(fullfile(outDir, figFn), saveFigures, cS);
   end
end


end