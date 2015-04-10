function [utilV, muV, utilLifetime] = util_work_bc1(cV, paramS, cS)
% Utility at work
%{
OUT
   utilV
      for each cV
   muV
      marginal utilities
   utilLifetime
      lifetime utility

Checked: 2015-Feb-18
%}

%% Input check
if cS.dbg > 10
   validateattributes(cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive'})
end


%% Main

if paramS.prefSigma == 1
   utilV = paramS.prefWtWork .* log(cV);
   muV = paramS.prefWtWork ./ cV;
else
   sig1 = 1 - paramS.prefSigma;
   utilV = paramS.prefWtWork .* (cV .^ sig1) ./ sig1 - 1;
   muV = paramS.prefWtWork .* cV .^ (-paramS.prefSigma);
end

% Lifetime utility
%  now interpreting cV as c over time
if nargout > 2
   T = length(cV);
   utilLifetime = (paramS.prefBeta .^ (0 : (T-1))) * utilV(:);
else
   utilLifetime  = nan;
end


%% Self-test
if cS.dbg > 10
   validateattributes(utilV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', size(cV)})
   validateattributes(muV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      'size', size(cV)})
   
   if nargout > 2
      validateattributes(utilLifetime, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
         'scalar'})
   end
end

end