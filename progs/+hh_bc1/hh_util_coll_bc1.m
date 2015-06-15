function [utilV, muCV, muLV] = hh_util_coll_bc1(cV, leisureV, prefWt, prefSigma, ...
   prefWtLeisure, prefRho)
% Utility in college
%{
Must be extremely efficient

Test: test_bc1.college
%}

%% Input check
% if cS.dbg > 10
%    validateattributes(cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
%       'positive'})
%    validateattributes(leisureV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
%       'positive'})
% end


%% Consumption part

muCV = 0;

if prefSigma == 1
   % Log utility
   utilCV = prefWt .* log(cV);
   if nargout > 1
      muCV = prefWt ./ cV;
   end
else
   sig1 = 1 - prefSigma;
   utilCV = prefWt .* cV .^ sig1 ./ sig1 - 1;
   if nargout > 1
      muCV = prefWt .* cV .^ (-prefSigma);
   end
end


%% Leisure part

muLV = 0;

if prefRho == 1
   utilLV = prefWtLeisure .* log(leisureV);
   if nargout > 2
      muLV = prefWtLeisure ./ leisureV;
   end
else
   sig2 = 1 - prefRho;
   utilLV = prefWtLeisure .* ((leisureV .^ sig2) ./ sig2 - 1);
   if nargout > 2
      muLV = prefWtLeisure .* leisureV .^ (-prefRho);
   end
end

utilV = utilCV + utilLV;


%% Self-test
% if cS.dbg > 10
%    sizeV = size(cV);
%    if nargout > 1
%       validateattributes(muCV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
%          'size', sizeV})
%    end
%    if nargout > 2
%       validateattributes(muLV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
%          'size', sizeV})
%    end
%    validateattributes(utilV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
%       'size', sizeV})
% end

end