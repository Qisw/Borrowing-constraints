function exper_all_bc1(setNo)
% Run all experiments that do not require recalibration
%{
Need to first calibrate model for all cohorts!
%}

cS = const_bc1(setNo);


% Calibrate time varying parameters for other cohorts
for iCohort = 1 : cS.nCohorts
   if ~isnan(cS.bYearExpNoV(iCohort))
      calibr_bc1.calibr('fminsearch', setNo, cS.bYearExpNoV(iCohort));
   end
end
   

% Counterfactuals
for expNo2 = cS.expS.decomposeExpNoM(:)'
   if ~isnan(expNo2)
      exper_bc1(setNo, expNo2);
   end
end

% Cumulative changes for decomposition
for expNo2 = cS.expS.decomposeCumulExpNoM(:)'
   if ~isnan(expNo2)
      exper_bc1(setNo, expNo2);
   end
end

end