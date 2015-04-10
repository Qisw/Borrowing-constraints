function cpiV = cpi(yearV, cS)
%{
Returns cpi for each year
with cS.cpiBaseYear = 1
%}

loadS = var_load_bc1(cS.vCpi, cS);

yrIdxV = yearV - loadS.yearV(1) + 1;
if ~isequal(loadS.yearV(yrIdxV), yearV(:))
   error('Not implemented');
end

cpiV = loadS.cpiV(yrIdxV);

validateattributes(cpiV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   'size', [length(yearV), 1]})


end