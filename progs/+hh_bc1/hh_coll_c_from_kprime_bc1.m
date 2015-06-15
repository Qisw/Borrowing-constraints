function [c, hours] = hh_coll_c_from_kprime_bc1(kPrime, k, wColl, pColl, paramS, cS)
% Hh in college. Find c from k'
%{
Hours from static condition

If kPrime not feasible with positive consumption, return cFloor and leisure floor

Checked: 2015-Mar-19
%}

%% Input check
if cS.dbg > 10
   validateattributes([kPrime, k, wColl, pColl], {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [1,4]})
end


%% Main

% For speed
prefSigma = paramS.prefSigma;
prefRho = paramS.prefRho;
prefWtLeisure = paramS.prefWtLeisure;
prefWt = paramS.prefWt;
R = paramS.R;

% Try cFloor
devLow = devfct(cS.cFloor);
if devLow < 0
   % If this falls short of kPrime: no solution
   c = cS.cFloor;
   hours = 1 - cS.lFloor;
   
else
   % Highest c that may be required (working all the time)
   cMax = hh_bc1.coll_bc(kPrime, 1, k, wColl, pColl, paramS.R, cS);
   if cMax < cS.cFloor
      error_bc1('Should not happen', cS);
   end

   [c, fVal] = fzero(@devfct, [cS.cFloor, cMax], cS.fzeroOptS);   
   
   if abs(fVal) > 1e-3
      error_bc1('Cannot solve for c', cS);
   end
   
   [~, hours] = devfct(c);

   if cS.dbg > 10
      validateattributes(c, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'scalar', ...
         '>=', cS.cFloor})
      validateattributes(hours, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'scalar', ...
         '>=', 0, '<=', 1})
   end
end


%% Nested: deviation: k'(c) - k'(target)
%{
Must be very efficient
%}
   function [devV, hoursV] = devfct(cV)
      % static condition => hours
      hoursV = max(0, 1 - (cV .^ (prefSigma ./ prefRho)) .* ...
         (prefWtLeisure ./ prefWt ./ wColl) .^ (1/prefRho));
      % hoursV = hh_bc1.hh_static_bc1(cGuessV, wColl, paramS, cS);
      
      % Budget constraint
      kPrimeV = R * k + 2 * (wColl * hoursV - cV - pColl);
      % kPrimeV = hh_bc1.coll_bc_kprime(cGuessV, hoursV, k, wColl, pColl, paramS.R, cS);
      devV = kPrimeV - kPrime;
      
      %if cS.dbg > 10
      %   validateattributes(devV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'size', size(cGuessV)})
      %end
   end


end