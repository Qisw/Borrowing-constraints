function aggr_stats(setNo, expNo)
% Compute aggregates once calibration is done

cS = const_bc1(setNo, expNo);
paramS = param_load_bc1(setNo, expNo);

% Endowment correlations
outS.endowCorrS = aggr_bc1.endow_corr(paramS, cS);

var_save_bc1(outS, cS.vAggrStats, cS);

end