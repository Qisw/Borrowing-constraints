function [utilV, muV] = util_parent(cV, jV, paramS, cS)
% Parental utility, per period
%{
jV may be scalar
%}

uWtV = paramS.puWeight_jV(jV);

if paramS.puSigma == 1
   utilV = uWtV .* log(cV);
   muV = uWtV ./ cV;
else
   sig1 = 1 - paramS.puSigma;
   utilV = uWtV .* (cV .^ sig1) ./ sig1 - 1;
   muV = uWtV .* (cV .^ (-paramS.puSigma));
end

end