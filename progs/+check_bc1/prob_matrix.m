function prob_matrix(probM, sizeV, cS)
% Check a matrix of probabilities. 1st dim must sum to 1

validateattributes(probM, {'double'}, {'finite', 'nonnan', 'real', '>=', 0,  '<=', 1, ...
   'size', sizeV})

prSumM = sum(probM);
if any(abs(prSumM(:) - 1) > 1e-5)
   error_bc1('Probs do not sum to 1', cS);
end


end