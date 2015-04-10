function [muCV, muLV, utilV] = hh_util_coll_bc1(cV, leisureV, paramS, cS)
% Utility in college
%{
Test: test_bc1.college
%}

%% Input check
if cS.dbg > 10
   validateattributes(cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'positive'})
   validateattributes(leisureV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'positive'})
end


%% Main

% Consumption part
if paramS.prefSigma == 1
   % Log utility
   utilCV = paramS.prefWt .* log(cV);
   muCV = paramS.prefWt ./ cV;
else
   sig1 = 1 - paramS.prefSigma;
   utilCV = paramS.prefWt .* cV .^ sig1 ./ sig1 - 1;
   muCV = paramS.prefWt .* cV .^ (-paramS.prefSigma);
end

% Leisure part
if paramS.prefRho == 1
   utilLV = paramS.prefWtLeisure .* log(leisureV);
   muLV = paramS.prefWtLeisure ./ leisureV;
else
   sig2 = 1 - paramS.prefRho;
   utilLV = paramS.prefWtLeisure .* ((leisureV .^ sig2) ./ sig2 - 1);
   muLV = paramS.prefWtLeisure .* leisureV .^ (-paramS.prefRho);
end

utilV = utilCV + utilLV;

%% Self-test
if cS.dbg > 10
   sizeV = size(cV);
   validateattributes(muCV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      'size', sizeV})
   validateattributes(muLV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      'size', sizeV})
   validateattributes(utilV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', sizeV})
end

end