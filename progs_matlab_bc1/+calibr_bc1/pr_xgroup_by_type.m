function [prX_jM, xUbV] = pr_xgroup_by_type(mGridV, pr_jV, sigmaX, xPctUbV, dbg)
% Prob of x being in percentile group, given each type
%{
x = m + eps
eps ~ N(0, sigmaX)

IN
   xPctUbV
      upper bounds of percentile classes for x

OUT
   prX_jM
      pr(x in each group | type j)
   xUbV
      x values corresponding to xPctUbV

TEST
   by sim
%}

%% Input check

nTypes = length(mGridV);

if dbg > 10
   validateattributes(pr_jV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, ...
      '<=', 1, 'size', [nTypes, 1]})
   if abs(sum(pr_jV) - 1) > 1e-6
      error_bc1('Invalid', cS);
   end
   validateattributes(xPctUbV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'positive', '<=', 1})
   if xPctUbV(end) ~= 1
      error('Invalid');
   end
end


%% Make cdf of X
% Approx on a grid

% Grid of X values
ng = 100;
xGridV = linspace(min(mGridV) - sigmaX, max(mGridV) + sigmaX, ng);

% Prob x <= each grid point | j
prXGrid_jM = nan([ng, nTypes]);
for j = 1 : nTypes
   prXGrid_jM(:, j) = normcdf((xGridV - mGridV(j)) ./ sigmaX);
end
if dbg > 10
   validateattributes(prXGrid_jM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, ...
      '<=', 1, 'size', [ng, nTypes]})
end


% Pr(x <= each grid point)
prXGridV = nan([ng, 1]);
for ig = 1 : ng
   % Pr(IQ <= point ig) = sum over j  pr(j) * pr(iq <= point ig | j)
   prXGridV(ig) = prXGrid_jM(ig,:) * pr_jV;
end

prXGridV = min(prXGridV, 1);
prXGridV(end) = 1.00001;


% Interpolate at desired percentiles
xUbV = interp1(prXGridV, xGridV, xPctUbV, 'linear');
xUbV(end) = 1e6;
xUbV = xUbV(:);

validateattributes(xUbV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})


%% Prob(x <= percentile value | j)
% Just normal cdf

cdfX_jM = ones([length(xPctUbV), nTypes]);
for i1 = 1 : (length(xPctUbV)-1)
   cdfX_jM(i1, :) = normcdf((xUbV(i1) - mGridV) ./ sigmaX);
end

% Pr of each IQ group | j
prX_jM = diff([zeros([1, nTypes]); cdfX_jM], 1, 1);


%% Self test
if dbg > 10
   validateattributes(prX_jM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, ...
      '<=', 1})
   prSumV = sum(prX_jM);
   if any(abs(prSumV - 1) > 1e-5)
      error_bc1('Do not sum to 1', cS);
   end
end


end