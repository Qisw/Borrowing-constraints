function util_work(cV :: Vector{Float64}, prefS :: constBC.prefParamS, returnMu :: Bool,
  returnLifetime :: Bool, dbg :: Int)
# Utility at work
#
#OUT
#   utilV
#      for each cV
#   muV
#      marginal utilities
#   utilLifetime
#      lifetime utility
#
#Checked: 2015-Feb-18
#

## Input check
if dbg > 10
   check_lh.check(cV, lb = 0.001);
end


## Main
utilV :: Vector{Float64}
muV = zeros(1);

if abs(prefS.collSigma - 1.0) < 1e-4
   utilV = prefS.workWt .* log(cV);
   if returnMu
     muV = prefS.workWt ./ cV;
   end
else
   sig1 = 1 - prefS.collSigma;
   utilV = prefS.workWt .* (cV .^ sig1) ./ sig1 - 1.0;
   if returnMu
     muV = prefS.workWt .* cV .^ (-prefS.collSigma);
   end
end


# Lifetime utility
#  now interpreting cV as c over time
utilLifetime = 0.0;
if returnLifetime
   T = length(cV);
   utilLifetime = sum((prefS.beta .^ (0 : (T-1))) .* utilV);
else
   utilLifetime  = 0.0;
end


## Self-test
if dbg > 10
   check_lh.check(muV, Vector{Float64}, lb = 0.0001);
   if returnLifetime
     check_lh.check(utilLifetime, Float64);
   end
end

return utilV, muV, utilLifetime
end
