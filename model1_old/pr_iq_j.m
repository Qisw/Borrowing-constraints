function prIq_jM = pr_iq_j(mGridV, pr_jV, sigmaIQ, cS)
% Prob of each IQ quartile | j
%{
IQ = m + eps
eps ~ N(0, sigmaIQ)
%}

%% Input check
if cS.dbg > 10
   validateattributes(pr_jV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, ...
      '<=', 1, 'size', [cS.nTypes, 1]})
   if abs(sum(pr_jV) - 1) > 1e-6
      error_bc1('Invalid', cS);
   end
end


%% Make cdf of IQ
% Approx on a grid

% Grid of IQ values
ng = 100;
iqGridV = linspace(min(mGridV), max(mGridV), ng);

% Prob IQ <= each grid point | j
prIqGrid_jM = nan([ng, cS.nTypes]);
for j = 1 : cS.nTypes
   prIqGrid_jM(:, j) = normcdf((iqGridV - mGridV(j)) ./ sigmaIQ);
end
if cS.dbg > 10
   validateattributes(prIqGrid_jM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, ...
      '<=', 1, 'size', [ng, cS.nTypes]})
end


% Pr(iq <= each grid point)
prIqGridV = nan([ng, 1]);
for ig = 1 : ng
   % Pr(IQ <= point ig) = sum over j  pr(j) * pr(iq <= point ig | j)
   prIqGridV(ig) = prIqGrid_jM(ig,:) * pr_jV;
end

% Interpolate at desired percentiles
iqUbV = interp1(prIqGridV, iqGridV, cS.iqUbV, 'linear');
iqUbV(end) = 1e6;

validateattributes(iqUbV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})


%% Prob(IQ <= percentile value | j)
% Just normal cdf

cdfIq_jM = ones([length(cS.iqUbV), cS.nTypes]);
for i1 = 1 : (length(cS.iqUbV)-1)
   cdfIq_jM(i1, :) = normcdf((iqUbV(i1) - mGridV) ./ sigmaIQ);
end

% Pr of each IQ group | j
prIq_jM = diff([zeros([1, cS.nTypes]); cdfIq_jM], 1, 1);


%% Self test
if cS.dbg > 10
   validateattributes(prIq_jM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, ...
      '<=', 1})
   prSumV = sum(prIq_jM);
   if any(abs(prSumV - 1) > 1e-5)
      error_bc1('Do not sum to 1', cS);
   end
end


% test by sim +++++


end