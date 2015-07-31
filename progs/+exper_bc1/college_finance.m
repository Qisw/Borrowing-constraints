function college_finance(outDir, saveFigures, expStrV, setNoV, expNoV)
% Show how college is financed for a set of experiments
%{
Across all college students: show consumption, tuition spending
   show income from transfers, earnings, debt

The accounting is not exactly right +++++
   not obvious how to do it right
   there is discounting to take care of
   should have present value of consumption, earnings, college costs

Treat transfers that are saved as paid out later

IN:
   expStrV
      short description of each experiment
      xlabel for bar graph
%}

cS = const_bc1(setNoV(1));
nx = length(setNoV);


%% Collect data

consV = zeros([nx, 1]);
transferV = zeros([nx, 1]);
earnV = zeros([nx, 1]);
debtV = zeros([nx, 1]);
collCostV = zeros([nx, 1]);
cohStrV = cell([nx, 1]);

for ix = 1 : nx
   cxS = const_bc1(setNoV(ix), expNoV(ix));
   aggrS = var_load_bc1(cS.vAggregates, cxS);
   consV(ix) = aggrS.consCollMean;
   earnV(ix) = aggrS.earnCollMean;
   transferV(ix) = aggrS.zMean;
   collCostV(ix) = aggrS.pMean;
   debtV(ix) = aggrS.debtAllS.mean;
   cohStrV{ix} = sprintf('%i', cxS.cohYearV(cxS.iCohort));
end
clear cxS;

spendingV = consV + collCostV;
incomeV = earnV + transferV + debtV;
% Saving = income - spending
savingV = incomeV - spendingV;


%% Plot spending and income

figNameV = {'spending', 'income'};
yLabelV  = {'Expenditure', 'Funding'};
legendV  = {{'Consumption', 'Tuition'},  {'Earnings', 'Transfers', 'Debt'}};

for iPlot = 1 : length(figNameV)
   if iPlot == 1
      yM = [consV, collCostV];
   else
      transferImpliedV = spendingV - earnV - debtV;
      yM = [earnV, transferImpliedV, debtV];
   end
   
   fh = output_bc1.fig_new(saveFigures, []);
   bar(yM, 'stacked');
   xlabel('Cohort');
   ylabel(yLabelV{iPlot});
   legend(legendV{iPlot}, 'location', 'southoutside',  'orientation', 'horizontal');
   set(gca, 'XTickLabel', expStrV);
   output_bc1.fig_format(fh, 'bar');
   output_bc1.fig_save(fullfile(outDir, figNameV{iPlot}), saveFigures, cS);
end


end