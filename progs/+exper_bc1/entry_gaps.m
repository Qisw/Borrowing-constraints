function [modelIqV, modelYpV, dataIqV, dataYpV, bYearV] = entry_gaps(setNo, expNoV)
% For a set of experiments, return entry rate gaps by IQ, yp
%{
Also data targets for matching cohorts
%}

cS = const_bc1(setNo);
tgS = var_load_bc1(cS.vCalTargets, cS);

nx = length(expNoV);

bYearV = zeros(nx, 1);
modelIqV = zeros(nx, 1);
modelYpV = zeros(nx, 1);
dataIqV = zeros(nx, 1);
dataYpV = zeros(nx, 1);

for ix = 1 : nx
   cS = const_bc1(setNo, expNoV(ix));
   aggrS = var_load_bc1(cS.vAggregates, cS);

   iCohort = cS.iCohort;
   bYearV(ix) = cS.bYearV(iCohort);

   % Data to show: gap in entry rates by iq, and yp
   modelIqV(ix) = aggrS.fracEnter_qV(end) - aggrS.fracEnter_qV(1);
   modelYpV(ix) = aggrS.ypS.fracEnter_yV(end) - aggrS.ypS.fracEnter_yV(1);
   dataIqV(ix)  = tgS.fracEnter_qcM(end,iCohort) - tgS.fracEnter_qcM(1,iCohort);
   dataYpV(ix)  = tgS.fracEnter_ycM(end,iCohort) - tgS.fracEnter_ycM(1,iCohort);
end

end