function exper_results_bc1(runStr, setNo)
% After running all experiments, show results
%{
If any experiments are not available, return with a warning
%}

cS = const_bc1(setNo);

if strcmpi(runStr, 'all')  || strcmpi(runStr, 'timeSeries')
   time_series(setNo);
end

if strcmpi(runStr, 'all')  || strcmpi(runStr, 'sequential')
   sequential_decomp(setNo);
end

if strcmpi(runStr, 'all')  || strcmpi(runStr, 'cumulative')
   cumulative_decomp(setNo);
end

return;

end


%% Time series calibration
function time_series(setNo)

cS = const_bc1(setNo);

% Compare cohort outcomes
cfExpNoV = fliplr(cS.bYearExpNoV(~isnan(cS.bYearExpNoV)));
expNoV = [cS.expBase, cfExpNoV];  
outDir = fullfile(cS.setOutDir, 'cohort_compare');
exper_bc1.compare(setNo .* ones(size(expNoV)), expNoV, outDir);

end


%% For experiments that vary one variable at a time: show key outcomes
function sequential_decomp(setNo)

cS = const_bc1(setNo);

for iCohort = 1 : size(cS.expS.decomposeExpNoM, 2)
   expNoV = [cS.expBase; cS.expS.decomposeExpNoM(:, iCohort)];
   outDir = fullfile(cS.setOutDir, sprintf('cohort%i', cS.bYearV(iCohort)));
   exper_bc1.compare(setNo .* ones(size(expNoV)), expNoV, outDir);
end

end


%% Cumulative change of parameter values for decomposition
function cumulative_decomp(setNo)

cS = const_bc1(setNo);

% For experiments that vary variables cumulatively
for iCohort = 1 : size(cS.expS.decomposeCumulExpNoM, 2)
   expNoV = [cS.expBase; cS.expS.decomposeCumulExpNoM(:, iCohort); cS.bYearExpNoV(iCohort)];
   outDir = fullfile(cS.setOutDir, sprintf('cumulative%i', cS.bYearV(iCohort)));
   exper_bc1.compare(setNo .* ones(size(expNoV)), expNoV, outDir);
end

end