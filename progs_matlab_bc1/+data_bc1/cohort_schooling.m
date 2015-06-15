function cohort_schooling(setNo)
% Load schooling by cohort. CPS data
%{
Averages over all available ages. Not good for latest cohort. +++
%}

cS = const_bc1(setNo);

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


end