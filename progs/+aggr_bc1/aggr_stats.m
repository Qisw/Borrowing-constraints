function aggr_stats(setNo, expNo)
% Compute aggregates once calibration is done

cS = const_bc1(setNo, expNo);
paramS = param_load_bc1(setNo, expNo);
aggrS = var_load_bc1(cS.vAggregates, cS);

% Endowment correlations
outS.endowCorrS = aggr_bc1.endow_corr(paramS, cS);


%% By schooling

% Mean ability | s
outS.abilMean_sV = nan([cS.nSchool, 1]);
for iSchool = 1 : cS.nSchool
   mass_aV = aggrS.mass_asM(:, iSchool);
   outS.abilMean_sV(iSchool) = sum(mass_aV .* paramS.abilGrid_aV) ./ sum(mass_aV);
end


var_save_bc1(outS, cS.vAggrStats, cS);

end