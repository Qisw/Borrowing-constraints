function util_parent(cV :: Vector{Float64}, prefS :: constBC.prefParamS,
  returnMu :: Bool)
# Parental utility; per period

uWt = prefS.puWeight;
muV = zeros(1);

if abs(prefS.puSigma - 1.0) < 1e-5
   utilV = uWt .* log(cV);
   if returnMu
     muV = uWt ./ cV;
   end
else
   sig1 = 1 - prefS.puSigma;
   utilV = uWt .* (cV .^ sig1) ./ sig1 - 1.0;
   if returnMu
     muV = uWt .* (cV .^ (-prefS.puSigma));
   end
end

return utilV, muV
end
