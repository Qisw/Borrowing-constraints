function [c_kV, hours_kV, kPrime_kV, vColl_kV] = coll_pd3(kV, wColl, pColl, kMin, evWorkFct, j, paramS, cS)
% Solve college decision periods 3-4  OR  periods 1-2
%{
The only difference between period 1/2 or 3/4 is
- borrowing limit
- continuation value when working

Periods 3-4:
Student will graduate with certainty
Ability is NOT known

If he cannot afford college, he gets cFloor and lFloor
and associated vCollege

This code is key for efficiency

IN
   evWorkFct
      expected value at work as CG (continuous approximation)
      using beliefs Pr(a | j, grad)
   kMin
      borrowing limit for kPrime

OUT
   c, hours
      consumption , hours
   vColl
      lifetime utility
   kPrime
      

Checked: 2015-Mar-19
%}


%% Constants

% Extract for speed
cFloor = cS.cFloor;
lFloor = cS.lFloor;
R = paramS.R;
onePlusBeta = 1 + paramS.prefBeta;
betaSquared = (paramS.prefBeta .^ 2);
prefSigma = paramS.prefSigma;
prefRho = paramS.prefRho;
prefWtLeisure = paramS.prefWtLeisure;
prefWt = paramS.prefWt;
cBar = paramS.cColl_jV(j); 
lBar = paramS.lColl_jV(j);


%% Allocate outputs

nk = length(kV);
c_kV = nan([nk, 1]);
hours_kV = nan([nk, 1]);
kPrime_kV = nan([nk, 1]);
vColl_kV = nan([nk, 1]);

% Borrowing limit
% kMin = paramS.kMin_aV(cS.ageWorkStart_sV(cS.iCG));
kMax = paramS.kMax;



%% Feasible range of c for each k

cMax_kV = nan([nk,1]);
cMin_kV = nan([nk,1]);

for ik = 1 : nk
   % Max c level that makes borrowing limit bind
   cMax_kV(ik) = hh_bc1.hh_coll_c_from_kprime_bc1(kMin, kV(ik), wColl, pColl, j, paramS, cS);
   % Value of c that goes with max permitted kPrime
   cMin_kV(ik) = hh_bc1.hh_coll_c_from_kprime_bc1(kMax, kV(ik), wColl, pColl, j, paramS, cS);
end

% cMin = NaN: hh cannot attain kMax
cMin_kV(isnan(cMin_kV)) = cS.cFloor;
cMin_kV = max(cS.cFloor, cMin_kV);


%% Optimize state by state

   % Find ks for which hh can afford college
   kBellV = kV;
   [vMinV, ~, kPrimeMinV] = bellman_pd3(cS.cFloor);

   
   % These households cannot afford college
   %  They get the value associated with cFloor, lFloor
   kIdxV = find(kPrimeMinV <= kMin);
   if ~isempty(kIdxV)
      c_kV(kIdxV) = cFloor;
      hours_kV(kIdxV) = 1 - lFloor;
      kPrime_kV(kIdxV) = kMin;
      % The value assigned is essentially arbitrary
      % But it should not be ridiculous b/c the pref shocks force a small fraction of persons into
      % college (sometimes)
      vColl_kV(kIdxV) = -vMinV(kIdxV);
   end
   
   
   % These households can afford college
   kIdxV = find(kPrimeMinV >= kMin);
   for ik = kIdxV(:)'
      % This may find a corner
      kBellV = kV(ik);
      [c, fVal, exitFlag] = fminbnd(@bellman_pd3, cMin_kV(ik), cMax_kV(ik), cS.fminbndOptS);

      % Check convergence
      if exitFlag <= 0
         %cV = linspace(cMin, cMax2, 100);
         %plot(cV, bellman_pd3(cV), '.');
         error_bc1('no convergence', cS);
      end

      [vOut, hours_kV(ik), kPrime_kV(ik)] = bellman_pd3(c);
      vColl_kV(ik) = -vOut;
      c_kV(ik) = c;
   end


% Make sure that borrowing constraints are not violated
if any(kPrime_kV(:) < kMin - 1e-3)
   error_bc1('BC violated', cS);
end

% Ensure that rounding did not place kPrime outside of grid
kPrime_kV = max(kMin, kPrime_kV);


%% Output check
if cS.dbg > 10
   validateattributes(c_kV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'positive', 'size', [nk, 1]})
   validateattributes(hours_kV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0, '<', 1, 'size', [nk, 1]})
   validateattributes(kPrime_kV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [nk, 1]})
  validateattributes(vColl_kV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [nk, 1]}) 
end



%% Nested: Objective function
% No penalty for violating borrowing limit
%{
This must be extremely efficient
Precomputing u(c,k) is tempting
- but not clear evaluating the resulting function is much faster than calling the static condition
and the utility function
Testing shows that it would be faster to find fzero of the slope of the value function (perhaps
factor 2)

IN:
   cV
      consumption
   kBellV
      k today
   vWorkFct(kPrime)
      value of work by kPrime
%}
   function [objOutV, hoursV, kPrimeBellV] = bellman_pd3(cV)      
      % Hours from static condition
      % Impose bounds
      hoursV = max(0, min(1 - lFloor, 1 + lBar - ((cV + cBar) .^ (prefSigma ./ prefRho)) .* ...
         (prefWtLeisure ./ prefWt ./ wColl) .^ (1/prefRho)));
      % hoursV = hh_bc1.hh_static_bc1(cV, wColl, j, paramS, cS);
      
      utilV = hh_bc1.hh_util_coll_bc1(cV, 1 - hoursV, cBar, lBar,  prefWt, prefSigma, ...
         prefWtLeisure, prefRho);
      
      % kPrime from budget constraint
      kPrimeBellV = R * kBellV + 2 * (wColl * hoursV - cV - pColl);
      % kPrimeBellV = hh_bc1.coll_bc_kprime(cV, hoursV, k, wColl, pColl, paramS.R, cS);
      
      objOutV = -(onePlusBeta .* utilV + betaSquared .* evWorkFct(kPrimeBellV));
   end


end