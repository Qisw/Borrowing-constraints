function results_all_bc1(setNo, expNo)
% Show all results

cS = const_bc1(setNo, expNo);
paramS = param_load_bc1(setNo, expNo);
saveFigures = 1;

% If on the server: delete all existing out files
if cS.runLocal == 0
   delete(fullfile(cS.outDir, '*.*'));
end

preamble_lh.initialize(var_fn_bc1(cS.vPreambleData, cS), cS.preambleFn);

results_bc1.fit(saveFigures, setNo, expNo);
results_bc1.fit_tb(setNo, expNo);

for showCalibrated = [0 1]
   calibr_bc1.param_tb(showCalibrated, setNo, expNo);
end
results_bc1.param_show(saveFigures, setNo, expNo);
% Show policy functions
results_bc1.hh_show(saveFigures, setNo, expNo);
% Show value functions
results_bc1.value_show(saveFigures, setNo, expNo);

results_bc1.prob_show(saveFigures, setNo, expNo);



%% Diagnostics

calibr_bc1.check_solution(setNo, expNo);

% Which params are close to bounds?
cS.pvector.show_close_to_bounds(paramS, cS.doCalV);

% For a given j: show history
jV = round(linspace(1, cS.nTypes, 5));
results_bc1.history_show(jV, setNo, expNo);

results_bc1.preamble_make(setNo, expNo);


end