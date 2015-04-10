function [covar, corrCoeff, xMean, yMean, xVar, yVar, nValid] = ...
   cov_w(xV, yV, wtV, missVal, dbg)
% Covariance for weighted data
% Also returns means and variances, correlation coefficient

% IN:
%  wtV
%     Weights. Need not sum to 1
% ---------------------------------------

sizeV = size(xV);
if dbg > 10
   if ~isequal(size(yV), sizeV)
      error('Invalid size of yV');
   end
   if ~isequal(size(wtV), sizeV)
      error('Invalid size of wtV');
   end
end


% Find valid data
idxV = find(xV ~= missVal  &  yV ~= missVal  &  wtV > 0);
if length(idxV) < 2
   error('No valid data');
end

% Weights for valid data. Scaled.
totalWt = sum(wtV(idxV));
if totalWt <= 0
   error('Zero weight');
end
wtNewV = wtV(idxV) ./ totalWt;

% Means
xMean = sum(xV(idxV) .* wtNewV);
yMean = sum(yV(idxV) .* wtNewV);

% Covariance
covar = sum( wtNewV .* (xV(idxV) - xMean) .* (yV(idxV) - yMean) );

% These only need to be computed if they are returned
if nargout > 1
   % Variances
   xVar = sum( wtNewV .* (xV(idxV) - xMean) .^ 2 );
   yVar = sum( wtNewV .* (yV(idxV) - yMean) .^ 2 );

   % Number of valid observations
   nValid = length(idxV);

   corrCoeff = covar ./ sqrt(xVar) ./ sqrt(yVar);
end


end
