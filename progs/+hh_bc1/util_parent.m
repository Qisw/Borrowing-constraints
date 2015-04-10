function [muV, utilV] = util_parent(cV, paramS, cS)
% Parental utility, per period

uWt = paramS.puWeight;

if paramS.puSigma == 1
   utilV = uWt .* log(cV);
   muV = uWt ./ cV;
else
   sig1 = 1 - paramS.puSigma;
   utilV = uWt .* (cV .^ sig1) ./ sig1 - 1;
   muV = uWt .* (cV .^ (-paramS.puSigma));
end

end