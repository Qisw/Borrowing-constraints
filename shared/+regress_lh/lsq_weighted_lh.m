function rsS = lsq_weighted_lh(yV, xM, wtV, rAlpha, dbg)
% Weighted least squares
%{
% Can use lscov, but that does not return std errors etc.

% IN:
%  xM, yV
%     Regression objects
%  wtV
%     Weights

% OUT:
%  rsS
%     Structure with stats, same as from unweighted regression
%     betaV
%}
% ------------------------------------------

if nargin ~= 5
   error('Invalid nargin');
end

[nObs, nk] = size(xM);

if ~isequal(size(wtV), size(yV))
   warnmsg([ mfilename, ':  Size mismatch' ]);
   keyboard;
end

% Premultiply everything by sqrt of weight
% Then run ols
wtFactorV = sqrt(wtV);

yTrV = wtFactorV .* yV;
xTrM = repmat(wtFactorV, 1, nk) .* xM;

rsS = regress_lh.regr_stats_lh(yTrV,  xTrM,  rAlpha, dbg);


% Need to compute R2 differently, because the transformed regression has no intercept
% Follow method suggested by Willett and Singer, American Statistician, 1988, 42(3).

% Residuals, not transformed. Using transformed beta
residV = yV - xM * rsS.betaV;
residSS = norm(residV) .^ 2;

% Total sum of squares
totalSS = norm(yV - mean(yV)) .^ 2;

rsS.rSquare = 1 - residSS ./ totalSS;


if 0
   % This method is not recommended. It can yield very large R2
   % in data that do not fit well

   % Residual sum of squares (weighted)
   residV = yTrV - xTrM * rsS.betaV;
   residSS = norm(residV) .^ 2;

   % Total sum of squares
   yMean = mean(yTrV);
   totalSS = norm(yTrV) .^ 2  -  nObs .* yMean .^ 2;

   rsS.rSquare = 1 - residSS ./ totalSS;
end

if 0     % direct code
   rsS.betaV = (repmat(wtV, 1, nk) .* xM) \ (wtV .* yV);

   % Predicted y's
   rsS.yHatV = xM * rsS.betaV;

   % Residual sum of squares
   totalWt = sum(wtV);
   residSS = sum(wtV .* (yV - rsS.yHatV) .^ 2) ./ totalWt;

   % Total sum of squares
   yMean = sum(wtV .* yV) ./ totalWt;
   totalSS = sum(wtV .* (yV - yMean) .^ 2) ./ totalWt;

   rsS.rSquare = (1 - residSS) ./ totalSS;
end

end