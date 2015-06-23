function aggr_check(aggrS, cS)
% Consistency checks

% move all consistency checks here +++++

ypS = aggrS.ypS;

%% By [q,y]

% Compare with entry / grad rates by IQ
probEnter_qV = sum(aggrS.qyS.massColl_qyM, 2) ./ sum(aggrS.qyS.mass_qyM, 2);
if any(abs(probEnter_qV(:) - aggrS.fracEnter_qV) > 0.02)
   error_bc1('no match', cS);
end

probGrad_qV = sum(aggrS.qyS.massGrad_qyM, 2) ./ sum(aggrS.qyS.mass_qyM, 2);
if any(abs(probGrad_qV(:) - aggrS.fracGrad_qV) > 0.02)
   error_bc1('no match', cS);
end

% Compare with entry / grad rates by yParent
probEnter_yV = sum(aggrS.qyS.massColl_qyM) ./ sum(aggrS.qyS.mass_qyM);
if any(abs(probEnter_yV(:) - aggrS.ypS.fracEnter_yV) > 0.02)
   error_bc1('no match', cS);
end
probGrad_yV = sum(aggrS.qyS.massGrad_qyM) ./ sum(aggrS.qyS.mass_qyM);
if any(abs(probGrad_yV(:) - aggrS.ypS.fracGrad_yV) > 0.02)
   error_bc1('no match', cS);
end


%% By y

% Mass of entrants by y
mass_yV = aggrS.ypS.fracEnter_yV .* cS.pr_ypV;
mass_yV = mass_yV(:) ./ sum(mass_yV);

% debtMean = sum(debtMean_yV .* mass_yV);
earnCollMean = sum(aggrS.ypS.earnCollMean_yV .* mass_yV);
transferMean = sum(aggrS.ypS.transfer_yV .* mass_yV);
hoursCollMean = sum(aggrS.ypS.hoursCollMean_yV .* mass_yV);
pMean = sum(ypS.pColl_yV .* mass_yV);
denomV = [earnCollMean, transferMean, hoursCollMean, pMean];
diffV = ([aggrS.earnCollMeanYear2, aggrS.transferMeanYear2, aggrS.hoursCollMeanYear2, aggrS.pMeanYear2] - denomV) ./ ...
   max(1, denomV);
maxDiff = max(abs(diffV));
if maxDiff > 0.1    % why so imprecise? +++
   disp(maxDiff)
   error_bc1('Two ways of computing means do not match up', cS);
end



end