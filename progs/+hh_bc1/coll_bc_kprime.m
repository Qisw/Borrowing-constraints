function kPrimeV = coll_bc_kprime(cV, hoursV, kV, wColl, pColl, R, cS)
% Budget constraint in college

if cS.dbg > 10
   validateattributes(wColl, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', 'scalar'})
end

kPrimeV = R * kV + 2 * (wColl * hoursV - cV - pColl);

if cS.dbg > 10
   validateattributes(kPrimeV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
end

end