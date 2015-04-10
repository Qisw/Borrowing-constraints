function bLimit_acM = borrow_limits(cS)
% Construct borrowing limits by [year in college, cohort]
%{
Base year dollar amounts, at the START of each year in college

Checked: 2015-Mar-19
%}


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
      bLimit_acM(2:end, iCohort) = bLimitM(yrIdx, :)' ./ cS.unitAcct ./ cpiCohortV;
   end
end

validateattributes(bLimit_acM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, ...
   'size', [ny+1, cS.nCohorts]})


end