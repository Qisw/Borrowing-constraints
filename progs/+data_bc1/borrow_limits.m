function bLimit_acM = borrow_limits(cS)
% Construct borrowing limits by [year in college, cohort]
%{
Base year dollar amounts, at the START of each year in college

Checked: 2015-Mar-19
%}

figS = const_fig_bc1;
saveFigures = 1;


%% CPI

cpiYearV = cS.firstDataYear : cS.lastDataYear;
cpiV = data_bc1.cpi(cpiYearV, cS);


%% Data

% Finaid.org: Aggregate borrowing limits
% Start year and aggregate amount
% dataM = [1967, 9000;
%    1973, 7500;
%    1977, 7500;
%    1981, 12500;
%    1987, 17250;
%    1992, 23000;
%    1994, 46000];


% finaid.org
% Subsidized + unsubsidized loan limits by year
% and lifetime max

dataM = [
1967	1500	1500	1500	1500	6000;
1973	1000	1500	2500	2500	7500;
1977	2500	2500	2500	2500	10000;
1987	6625	6625	8000	8000	29250;
1993	6625	7500	10500	10500	35125;
2007	9500	10500	12500	12500	45000;
2012	9500	10500	12500	12500	45000];

% No loans before 1967
dataM = [zeros([1, size(dataM, 2)]); dataM];
dataM(1,1) = 1900;

yLbV = dataM(:,1);
limitByYearM = dataM(:, 2:5);
lifetimeMaxV = dataM(:, 6);

% Cumulative borrowin limits, imposing lifetime max
bLimitM = nan(size(limitByYearM));
for iy = 1 : size(limitByYearM, 1)
   bLimitM(iy, :) = min(lifetimeMaxV(iy), cumsum(limitByYearM(iy,:), 2));
end


%% Plot by year
if 1
   fh = output_bc1.fig_new(saveFigures, []);
   hold on;
   
   for i1 = 1 : length(yLbV)
      if i1 < length(yLbV)
         yUb = yLbV(i1 + 1);
      else
         yUb = yLbV(i1) + 1;
      end      
      yearPlotV = max(1960, yLbV(i1)) : yUb;
      
      % CPI for these years
      cpiIdxV = yearPlotV - cpiYearV(1) + 1;
      plot(yearPlotV,  lifetimeMaxV(i1) ./ cpiV(cpiIdxV),  figS.lineStyleDenseV{1}, 'color', figS.colorM(1,:));
   end
   
   hold off;
   xlabel('Year');
   ylabel(sprintf('Borrowing limit, %i prices', cS.cpiBaseYear));
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save(fullfile(cS.dataOutDir, 'borrow_limit_year'), saveFigures, cS);
end


%% Plot by cohort
if 1
   bYearV = cS.bYearV(1) : cS.bYearV(end);
   yearV  = bYearV + 23;
   dataV  = zeros(size(bYearV));
   for ic = 1 : length(bYearV)
      if yearV(ic) >= yLbV(1)
         % Find the applicable year bracket
         bracketIdxV = find(yearV(ic) >= yLbV);
         
         % CPI for this years
         cpiIdx = yearV(ic) - cpiYearV(1) + 1;
         dataV(ic) = lifetimeMaxV(bracketIdxV(end)) ./ cpiV(cpiIdx);
      end
   end
   
   fh = output_bc1.plot_by_cohort(bYearV(:), dataV(:), saveFigures, cS);
   ylabel(sprintf('Borrowing limit, %i prices', cS.cpiBaseYear));
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save(fullfile(cS.dataOutDir, 'borrow_limit_cohort'), saveFigures, cS);
end


%% Make into borrowing limits by [year, cohort]

% No of years in college
ny = cS.ageWorkStart_sV(cS.iCG) - 1;
bLimit_acM = nan([ny+1, cS.nCohorts]);
% No borrowing at start of year 1
bLimit_acM(1, :) = 0;
for iCohort = 1 : cS.nCohorts
   for iy = 1 : ny
      % First year in college
      year1 = cS.bYearV(iCohort) + 18;
      % CPIs by year in college
      cpiIdx = find(cpiYearV == year1);
      cpiCohortV = cpiV(cpiIdx - 1 + (1 : ny));
      % Matching time period for borrowing limits
      yrIdx = find(year1 >= yLbV);
      yrIdx = yrIdx(end);
      bLimit_acM(2:end, iCohort) = -bLimitM(yrIdx, :)' ./ cS.unitAcct ./ cpiCohortV;
   end
end

validateattributes(bLimit_acM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '<=', 0, ...
   'size', [ny+1, cS.nCohorts]})


end