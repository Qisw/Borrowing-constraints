function util_college(cV :: Vector{Float64}, leisureV :: Vector{Float64},
  prefS :: constBC.prefParamS,  returnMuC :: Bool, returnMuL :: Bool)
# Utility in college
#=
Must be extremely efficient

Test: test_bc1.college
=#

## Input check
# if cS.dbg > 10
#    validateattributes(cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
#       'positive'})
#    validateattributes(leisureV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
#       'positive'})
# end


## Consumption part

muCV = zeros(1);

if abs(prefS.collSigma - 1.0) < 1e-6
   # Log utility
   utilCV = prefS.collWt .* log(cV);
   if returnMuC
      muCV = prefS.collWt ./ cV;
   end
else
   sig1 = 1 - prefS.collSigma;
   utilCV = prefS.collWt .* (cV .^ sig1) ./ sig1 - 1;
   if returnMuC
      muCV = prefS.collWt .* cV .^ (-prefS.collSigma);
   end
end


## Leisure part

muLV = 0;

if abs(prefS.collRho - 1) > 1e-5
   utilLV = prefS.collWtLeisure .* log(leisureV);
   if returnMuL
      muLV = prefS.collWtLeisure ./ leisureV;
   end
else
   sig2 = 1 - prefS.collRho;
   utilLV = prefS.collWtLeisure .* ((leisureV .^ sig2) ./ sig2 - 1);
   if nargout > 2
      muLV = prefS.collWtLeisure .* (leisureV .^ (-prefS.collRho));
   end
end

utilV = utilCV + utilLV;


## Self-test
# if cS.dbg > 10
#    sizeV = size(cV);
#    if nargout > 1
#       validateattributes(muCV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
#          'size', sizeV})
#    end
#    if nargout > 2
#       validateattributes(muLV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
#          'size', sizeV})
#    end
#    validateattributes(utilV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
#       'size', sizeV})
# end

return utilV, muCV, muLV
end
