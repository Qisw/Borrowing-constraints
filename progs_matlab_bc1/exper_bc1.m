function exper_bc1(setNo, expNo)
% Compute an experiment with baseline parameters

cS = const_bc1(setNo, expNo);
% Load baseline parameters
paramS = param_load_bc1(setNo, cS.expBase);
% Impose derived params
paramS = param_derived_bc1(paramS, cS);
% Save for experiment
var_save_bc1(paramS, cS.vParams, cS);

if cS.expS.doCalibrate == 1
   solverStr = 'fminsearch';
else
   solverStr = 'none';
end

% Solve without recalibrating
calibr_bc1.calibr(solverStr, setNo, expNo);

end