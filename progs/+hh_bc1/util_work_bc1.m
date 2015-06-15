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

Test:
   directly implements model equations. No test.

Checked: 2015-Feb-18
%}

%% Input check
if cS.dbg > 10
   validateattributes(cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive'})
end


%% Main

pSigma = paramS.workSigma;
pWt = paramS.prefWtWork;

if pSigma == 1
   utilV = paramS.prefWtWork .* log(cV);
   muV = pWt ./ cV;
else
   sig1 = 1 - pSigma;
   utilV = pWt .* (cV .^ sig1) ./ sig1 - 1;
   muV = pWt .* cV .^ (-pSigma);
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