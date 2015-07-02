function results_all_bc1(setNo, expNo)
% Show all results

cS = const_bc1(setNo, expNo);
paramS = param_load_bc1(setNo, expNo);
saveFigures = 1;

% Make dirs
helper_bc1.mkdir(setNo, expNo);
% If on the server: delete all existing out files
if cS.runLocal == 0
   results_bc1.delete_results(setNo, expNo, 'noconfirm');
end

preamble_lh.initialize(var_fn_bc1(cS.vPreambleData, cS), cS.preambleFn);

% Fit
% Figures
results_bc1.fit(saveFigures, setNo, expNo);
% Table with all deviations from cal targets
results_bc1.fit_tb(setNo, expNo);

for showCalibrated = [0 1]
   calibr_bc1.param_tb(showCalibrated, setNo, expNo);
end
results_bc1.param_show(saveFigures, setNo, expNo);
% Show policy functions
results_bc1.hh_show(saveFigures, setNo, expNo);
% Show value functions
results_bc1.value_show(saveFigures, setNo, expNo);
% Show aggregates
results_bc1.aggr_show(saveFigures, setNo, expNo);
results_bc1.aggr_qy_show(saveFigures, setNo, expNo);

results_bc1.prob_show(saveFigures, setNo, expNo);



%% Diagnostics

calibr_bc1.check_solution(setNo, expNo);

% Show how leisure varies across types for given consumption 
%  b/c of free consumption / leisure
results_bc1.static_show(saveFigures, setNo, expNo);

% Which params are close to bounds?
cS.pvector.show_close_to_bounds(paramS, cS.doCalV);

% For given j: show history
results_bc1.history_show(setNo, expNo);

results_bc1.preamble_make(setNo, expNo);


end