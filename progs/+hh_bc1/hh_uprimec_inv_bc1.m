function cV = hh_uprimec_inv_bc1(ucV, paramS, cS)
% Inverse of u'(c) in college

cV = (ucV ./ paramS.prefWt) .^ (-1 ./ paramS.prefSigma);


if cS.dbg > 10
   validateattributes(cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', size(ucV)})
end

end