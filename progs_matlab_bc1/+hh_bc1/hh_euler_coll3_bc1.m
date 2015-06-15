function [eeDevV, kPrimeV, hoursV] = hh_euler_coll3_bc1(cV, k, wColl, pColl, kMin, iAbil, vWorkS, paramS, cS)
% Euler equation deviation in college; periods 3-4
%{
Input is c
Use static condition to get hours and use bc to get k'

Assumes INTERIOR solution for k'

eeDev > 0  implies  u'(c) > V_k  =>  raise c

Checked: 2015-Mar-20
%}

if cS.dbg > 10
   validateattributes(wColl, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'scalar', 'positive'})
end

% Get work hours from static condition
hoursV = hh_bc1.hh_static_bc1(cV, wColl, paramS, cS);

% Get k' from budget constraint
kPrimeV = hh_bc1.hh_bc_coll_bc1(cV, hoursV, k, wColl, pColl, paramS.R, cS);

% Check that interior
if any(kPrimeV < kMin - 1e-4)
   error('Must be interior');
end

kPrimeV = max(kMin, kPrimeV);


% ***  EE dev

eeDevV = hh_bc1.hh_eedev_coll3_bc1(cV, hoursV, kPrimeV, iAbil, vWorkS, paramS, cS);

if cS.dbg > 10
   validateattributes(eeDevV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', size(cV)})
end

end