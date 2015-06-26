function [prX_qV, prX_yV] = marginals(prX_qyM, mass_qyM, dbg)
% Compute marginal distribution Pr(x | q) from Pr(x | qy) and mass(q,y)

[nq, nYp] = size(prX_qyM);
prX_qV = nan([nq, 1]);
for iq = 1 : nq
   % Pr(x | q) * Pr(q) = sum over y  of  Pr(x | q,y) * Pr(q,y)
   prX_qV(iq) = sum(prX_qyM(iq,:) .* mass_qyM(iq,:)) ./ sum(mass_qyM(iq,:));
end

prX_yV = nan([nYp, 1]);
for iy = 1 : nYp
   % Pr(x | y) * Pr(y) = sum over q  of  Pr(x | q,y) * Pr(q,y)
   prX_yV(iy) = sum(prX_qyM(:,iy) .* mass_qyM(:,iy)) ./ sum(mass_qyM(:,iy));
end

end