function [yV, yLim] = logistic_bc1(xV, pInter, pSlope)
% Logistic function. Positive or negative slope.
% Bounded between -1 and +1

if pSlope > 0
   pMult = 1 - pInter;
else
   pMult = abs(-1 - pInter);
end

yV = pInter + pSlope * pMult ./ (1 + exp(-xV));

% Also return the limit as xV -> infinity
yLim = pInter + pSlope * pMult;

end