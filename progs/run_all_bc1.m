function run_all_bc1(setNo)
% Run everything in sequence

cS = const_bc1(setNo);
expNo = cS.expBase;
paramS = param_load_bc1(setNo, expNo);
saveFigures = 1;


%% Prepare the set
if 0
   
   data_all_bc1(setNo);
   return;
end


%% Test routines
if 01
   test_all_bc1(setNo);
end



%% Calibration
if 01
   % Copy params from intermediate guess
   % param_from_guess_bc1(setNo, expNo);
   
   calibr_bc1.calibr('none', setNo, expNo);   
   
   % Run experiment (potentially without recalibrating parameters)
   % exper_bc1(setNo, expNo);
end


%% Results
if 0
   results_all_bc1(setNo, expNo);
end



end