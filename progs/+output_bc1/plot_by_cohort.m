function fh = plot_by_cohort(bYearV, data_cvM, saveFigures, cS)
% Plot a data matrix by cohort
%{
Each column is a variable

Cohorts are shown by year of HS graduaton
%}

figS = const_fig_bc1;
nCohorts = length(bYearV);

% Difference between birth year and year of HSG
dYear = cS.cohYearV(1) - cS.bYearV(1);

fh = output_bc1.fig_new(saveFigures, []);
hold on;

for iCase = 1 : 2
   if iCase == 1
      % All cohorts as a line
      plotIdxV = 1 : nCohorts;
      lineStyleV = figS.lineStyleDenseV;
   else
      % Model cohorts as dots
      plotIdxV = zeros(size(cS.bYearV));
      for ic = 1 : length(cS.bYearV)
         [~, plotIdxV(ic)] = min(abs(bYearV - cS.bYearV(ic)));
      end
      lineStyleV = repmat({'o'}, size(figS.lineStyleDenseV));
   end

   for iLine = 1 : size(data_cvM, 2)
      plot(bYearV(plotIdxV) + dYear, data_cvM(plotIdxV, iLine),  lineStyleV{iLine}, 'Color', figS.colorM(iLine,:));
   end
end

hold off;
xlabel(figS.cohortXLabelStr);

   
end