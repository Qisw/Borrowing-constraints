function cV = coll_bc(kPrimeV, hoursV, kV, wColl, pColl, R, cS)
% Budget constraint in college
%{
Does not ensure positive consumption
%}

if cS.dbg > 10
   validateattributes(wColl, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', 'scalar'})
end

cV = (R * kV - kPrimeV) ./ 2 + (wColl * hoursV - pColl);


end