function data_all_bc1(setNo)
%{
Only results_all writes to preamble
%}

cS = const_bc1(setNo);

saveFigures = 1;

% Cpi data
data_bc1.cpi_load(setNo);

% Cohort earnings profiles
go_cpsbc;
data_bc1.cohort_earnings_profiles(setNo);
data_bc1.cohort_earn_profiles_show(saveFigures, setNo);

% College costs by year
data_bc1.coll_costs(setNo);
% Data plots
data_bc1.plots(saveFigures, setNo);
% Make calibration targets
data_bc1.cal_targets(setNo);

for iCohort = 1 : cS.nCohorts
   data_bc1.target_summary(iCohort, setNo);
end

   
end