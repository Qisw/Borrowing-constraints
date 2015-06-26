function exper_results_bc1(setNo)
% After running all experiments, show results
%{
If any experiments are not available, return with a warning
%}

cS = const_bc1(setNo);

% Compare cohort outcomes
cfExpNoV = fliplr(cS.bYearExpNoV(~isnan(cS.bYearExpNoV)));
expNoV = [cS.expBase, cfExpNoV];  
exper_bc1.compare(setNo .* ones(size(expNoV)), expNoV, 'cohort_compare');


% For experiments that vary one variable at a time: show key outcomes
for iCohort = 1 : size(cS.expS.decomposeExpNoM, 2)
   expNoV = [cS.expBase; cS.expS.decomposeExpNoM(:, iCohort)];
   tbFn = sprintf('cohort%i', cS.bYearV(iCohort));
   exper_bc1.compare(setNo .* ones(size(expNoV)), expNoV, tbFn);
end



end