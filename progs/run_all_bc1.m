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
   % Needs to be done after calibrating for all cohorts!
   exper_all_bc1(setNo);
end


%% Results
if 0
   % Calibration runs this
   % results_all_bc1(setNo, cS.expBase);

   % Show results for experiments
   exper_results_bc1('all', setNo);
end



end