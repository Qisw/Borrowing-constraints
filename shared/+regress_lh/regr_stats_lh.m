function rsS = regr_stats_lh(y, X, rAlpha, dbg)
% Regression statistics. Also runs the regression
%{
% The code comes verbatim from the Matlab regress routine
% which fails to return these variables

% IN:
%  y           n x 1    vector
%  X           n x p    regressor matrix
%  alpha       Confidence level

% OUT:   rsS   Structure containing the following:
%  betaV
%     Regression coefficients
%  seBetaV
%     Standard errors of the betas
%  bIntM
%     Confidence bands for betaV
%  rmse
%     Root mean squared error (std dev of residual)
%  rSquare
%     R ^ 2
%  nObs
%     No of observations
%  F
%     F statistic for regression
%}
% -------------------------------------------------

if nargin == 3
   dbg = 1;
elseif nargin ~= 4
   error('Invalid nargin');
end

rsS.nObs = length(y);

%% Input check

if rsS.nObs < 3
   error([ mfilename, ':  Too few obs' ]);
end
if ~isequal(size(y), [rsS.nObs,1])
   error([ mfilename, ':  Wrong size of y' ]);
end
if ~isequal(size(y,1), size(X,1))
   error([ mfilename, ':  Invalid size of X' ]);
end

if any(isnan(X(:)))  ||  any(isinf(X(:)))
   error([ mfilename, ':  Regressors Nan or Inf encountered' ]);
end


% Make sure regressor matrix is not close to singular
if cond(X) > 1e6
   error([ mfilename, ':  Poorly conditioned regressor matrix' ]);
end


%% Run the regression and compute stats
% Code from regstats.m

[Q,R]=qr(X,0);
beta = R\(Q'*y);
rsS.betaV = beta(:);
yhat = X*beta;
residuals = y - yhat;
nobs = length(y);
p = min(size(R));

if nobs - p - 1 < 0
   error([ mfilename, ':  No degrees of freedom' ]);
end

% Residual variance
mse = sum(residuals.*residuals)./(nobs-p);

% Some residual related computations that produce unused variables
%E = X/R;
%h = sum((E.*E)')';

%s_sqr_i = ((nobs-p)*mse - residuals.*residuals./(1-h))./(nobs-p-1);

%e_i = residuals./sqrt(s_sqr_i.*(1-h));

%Inverse of R
ri = R\eye(p);

% inv(X'X)
xtxi = ri*ri';

% Covariance of Regression Coefficients
covb = xtxi * mse;
rsS.seBetaV = sqrt(diag(covb));


%r = y - X * bb;

% Std dev of residual
rsS.rmse = sqrt(mse);      % norm(r) / sqrt(n-p);


% Confidence intervals for beta
% Code from regress.m
[n, p] = size(X);
nu = n - p;
tval = tinv((1-rAlpha/2),nu);
xdiag=sqrt(sum((ri .* ri)',1))';
rmse = rsS.rmse;
rsS.bIntM = [beta-tval*xdiag*rmse, beta+tval*xdiag*rmse];


% R squared
% Code from regress

RSS = norm(yhat-mean(y))^2;  % Regression sum of squares.
TSS = norm(y-mean(y))^2;     % Total sum of squares.
rsS.rSquare = RSS/TSS;       % R-square statistic.

% Alternative R squared
if 0
   residSS = norm(residuals) .^ 2;
   totalSS = norm(y) .^ 2 - length(y) .* mean(y) .^ 2;
   rsS.rSquareAlt = 1 - residSS ./ totalSS;
end

% F statistic
s2 = rmse^2;                    % Estimator of error variance.
if (p>1)
   F = (RSS/(p-1))/s2;       % F statistic for regression
else
   F = NaN;
end
rsS.F = F;


rsS.prob = 1 - fcdf(F,p-1,nu);   % Significance probability for regression


%% Output check
if 1
   validateattributes(rsS.betaV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'size', [p,1]})
end

end
