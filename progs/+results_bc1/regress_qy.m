function [betaIq, betaYp] = regress_qy(probEntry_qyM, mass_qyM, iqUbV, ypUbV, dbg)
% Regress prob entry on iq and yp percentiles
%{
From cross-tab

IN
   mass_qyM
      may be []; then unweighted regression
%}

%% Input check

nIq = length(iqUbV);
nYp = length(ypUbV);
validateattributes(probEntry_qyM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
   '>', 0, '<', 1,  'size',  [nIq, nYp]})


%% Regression

% Midpoints
iqBoundsV = [0; iqUbV];
iqMidV = 0.5 .* (iqBoundsV(2 : end) + iqBoundsV(1 : (end-1)));
ypBoundsV = [0; ypUbV];
ypMidV = 0.5 .* (ypBoundsV(2 : end) + ypBoundsV(1 : (end-1)));

iqMid_qyM = iqMidV * ones(1, length(ypMidV));
ypMid_qyM = ones(length(iqMidV), 1) * ypMidV';

xM = [ones(nIq * nYp, 1), iqMid_qyM(:), ypMid_qyM(:)];
yV = probEntry_qyM(:);

if isempty(mass_qyM)
   rsS = regress_lh.regr_stats_lh(yV, xM, 0.05, dbg);
else
   rsS = regress_lh.lsq_weighted_lh(yV, xM, sqrt(mass_qyM(:)), 0.05, dbg);
end

betaIq = rsS.betaV(2);
betaYp = rsS.betaV(3);

end