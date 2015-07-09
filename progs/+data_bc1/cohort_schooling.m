function cohort_schooling(setNo)
% Load schooling by cohort. CPS data
%{
Averages over all available ages. Not good for latest cohort. +++

use entry data instead +++++
%}

cS = const_bc1(setNo);
figS = const_fig_bc1;
saveFigures = 1;

% Load cps birth year stats
cpsS = const_cpsbc(cS.cpsSetNo);
% Use 3 year cohorts to increase sample size
% Not all cohorts have all ages
outS = byear_school_age_stats_cpsbc(cS.bYearV - 1, cS.bYearV + 1, 25 : 50, cS.cpsSetNo);

frac_s_cM = nan([cS.nSchool, cS.nCohorts]);
for iCohort = 1 : cS.nCohorts
   % CPS data also have HSD, omit them
   mass_stM = squeeze(outS.massM(iCohort, cpsS.iHSG : cpsS.iCG, :));
   tIdxV = find(~isnan(mass_stM(1,:))  &  ~isnan(mass_stM(end,:)));
   mass_sV  = sum(mass_stM(:, tIdxV), 2);
   frac_s_cM(:, iCohort) = mass_sV ./ sum(mass_sV);
end

validateattributes(frac_s_cM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>', 0.1, ...
   '<', 0.8, 'size', [cS.nSchool, cS.nCohorts]})

var_save_bc1(frac_s_cM, cS.vCohortSchooling, cS);



%% Plot: CPS school fractions and model cohorts
if 1
   % Not ideal: time varying age coverage +++
   bYearV = cS.bYearV(1) : 1 : cS.bYearV(end);
   nCohorts = length(bYearV);
   outS = byear_school_age_stats_cpsbc(bYearV - 1, bYearV + 1,  25 : 60, cS.cpsSetNo);
   
   frac_s_cM = nan([cS.nSchool, nCohorts]);
   for iCohort = 1 : nCohorts
      % CPS data also have HSD, omit them
      mass_stM = squeeze(outS.massM(iCohort, cpsS.iHSG : cpsS.iCG, :));
      tIdxV = find(~isnan(mass_stM(1,:))  &  ~isnan(mass_stM(end,:)));
      mass_sV  = sum(mass_stM(:, tIdxV), 2);
      frac_s_cM(:, iCohort) = mass_sV ./ sum(mass_sV);
   end

   validateattributes(frac_s_cM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>', 0.1, ...
      '<', 0.8, 'size', [cS.nSchool, nCohorts]})
   
   
   fracEnterV = sum(frac_s_cM(cS.iCD : cS.iCG, :));
   fracGradV  = frac_s_cM(cS.iCG, :);

   
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
      
      iLine = 1;
      plot(bYearV(plotIdxV), fracEnterV(plotIdxV),  lineStyleV{iLine}, 'Color', figS.colorM(iLine,:));
      iLine = iLine + 1;
      plot(bYearV(plotIdxV), fracGradV(plotIdxV),   lineStyleV{iLine}, 'Color', figS.colorM(iLine,:));
   end
   
   hold off;
   xlabel('Birth year');
   legend({'College entry', 'College graduation'}, 'Location', 'Best');
   ylabel('Fraction');
   output_bc1.fig_format(fh, 'line');

   output_bc1.fig_save(fullfile(cS.dataOutDir, 'cohort_college'), saveFigures, cS);   
end


end