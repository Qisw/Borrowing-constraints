function run_all_bc1(setNo)
% Run everything in sequence

cS = const_bc1(setNo);


%% Prepare the set
if 0
   
   data_all_bc1(setNo);
   return;
end


%% Test routines
if 01
   test_all_bc1(setNo);
end



%% Calibration and experiments
if 01
   % Copy params from intermediate guess
   % param_from_guess_bc1(setNo, expNo);
   
   % Calibrate for base cohort (all params)
   calibr_bc1.calibr('none', setNo, cS.expBase);
   % Run all experiments that do not require recalibration
   exper_all_bc1(setNo, cS.expBase);
   
   % Calibrate time varying parameters for other cohorts
   for iCohort = 1 : cS.nCohorts
      if ~isnan(cS.bYearExpNoV(iCohort))
         calibr_bc1.calibr('none', setNo, cS.bYearExpNoV(iCohort));
      end
   end   
end


%% Results
if 0
   % Calibration runs this
   results_all_bc1(setNo, cS.expBase);
   
   % Compare experiments
   expNoV = [cS.expBase, 202, 203];   % hard coded +++
   exper_bc1.compare(setNo .* ones(size(expNoV)), expNoV, 'cohort_compare')
end



end