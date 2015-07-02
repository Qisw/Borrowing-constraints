function value_show(saveFigures, setNo, expNo)
% Show hh value functions

cS = const_bc1(setNo, expNo);
figS = const_fig_bc1;
paramS = param_load_bc1(setNo, expNo);
hhS = var_load_bc1(cS.vHhSolution, cS);
vWorkS = hhS.vWorkS;

xAbilV = cumsum(paramS.prob_aV);


%% Work: vary a | s
if 1
   fh = output_bc1.fig_new(saveFigures, figS.figOpt4S);
   axV = zeros([cS.nSchool, 1]);

   for iSchool = 1 : cS.nSchool
      axV(iSchool) = subplot(2,2,iSchool);
      hold on;
      for iAbil = 1 : cS.nAbil
         iLine = iAbil;
         plot(vWorkS.kGridV, vWorkS.value_ksaM(:, iSchool, iAbil), ...
            figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));
      end
      xlabel('Assets');
      ylabel(sprintf('Value work by ability, %s', cS.sLabelV{iSchool}));
      output_bc1.fig_format(fh, 'line');
   end
   
   linkaxes(axV, 'y');
   ylim([floor(min(vWorkS.value_ksaM(:))), ceil(max(vWorkS.value_ksaM(:)))]);
   
   output_bc1.fig_save(fullfile(cS.hhDir, 'value_work_abil'), saveFigures, cS);
end


%% Work: vary s | a
if 1
   fh = output_bc1.fig_new(saveFigures, figS.figOpt4S);
   axV = zeros([cS.nSchool, 1]);
   iAbilV = round(linspace(1, cS.nAbil, 4));

   for iPlot = 1 : length(iAbilV)
      iAbil = iAbilV(iPlot);
      axV(iPlot) = subplot(2,2,iPlot);
      hold on;
      for iSchool = 1 : cS.nSchool
         iLine = iSchool;
         plot(vWorkS.kGridV, vWorkS.value_ksaM(:, iSchool, iAbil), ...
            figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));
      end
      xlabel('Assets');
      ylabel(sprintf('Value work by schooling, ability %i', iAbil));
      if iPlot == 1
         legend(cS.sLabelV, 'location', 'southeast');
      end
      output_bc1.fig_format(fh, 'line');
   end
   
   yRangeV = [floor(min(vWorkS.value_ksaM(:))), ceil(max(vWorkS.value_ksaM(:)))];
   linkaxes(axV, 'y');
   ylim(yRangeV);
%    figures_lh.axes_same(axV, [NaN, NaN, yRangeV]);

   output_bc1.fig_save(fullfile(cS.hhDir, 'value_work_school'), saveFigures, cS);
   
   
end


end