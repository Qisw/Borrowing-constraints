function [c_kaM, hours_kaM, kPrime_kaM, vColl_kaM] = coll_pd3(kV, wColl, pColl, vWorkS, paramS, cS)
% Solve college decision periods 3-4
%{
Student will graduate with certainty
Ability is known

If he cannot afford college, he gets cFloor and lFloor
and associated vCollege

This code is key for efficiency

IN
   vWorkS
      value at work (continuous approximation)

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


%% Allocate outputs

nk = length(kV);
c_kaM = nan([nk, cS.nAbil]);
hours_kaM = nan([nk, cS.nAbil]);
kPrime_kaM = nan([nk, cS.nAbil]);
vColl_kaM = nan([nk, cS.nAbil]);

% Borrowing limit
kMin = paramS.kMin_aV(cS.ageWorkStart_sV(cS.iCG));
kMax = paramS.kMax;



%% Feasible range of c for each k

cMax_kV = nan([nk,1]);
cMin_kV = nan([nk,1]);

for ik = 1 : nk
   % Max c level that makes borrowing limit bind
   cMax_kV(ik) = hh_bc1.hh_coll_c_from_kprime_bc1(kMin, kV(ik), wColl, pColl, paramS, cS);
   % Value of c that goes with max permitted kPrime
   cMin_kV(ik) = hh_bc1.hh_coll_c_from_kprime_bc1(kMax, kV(ik), wColl, pColl, paramS, cS);
end

% cMin = NaN: hh cannot attain kMax
cMin_kV(isnan(cMin_kV)) = cS.cFloor;
cMin_kV = max(cS.cFloor, cMin_kV);


%% Optimize state by state
% efficiency: exploit when value work does not depend on ability +++
%  in that case the entire ability loop is unnecessary

for iAbil = 1 : cS.nAbil
   % Find ks for which hh can afford college
   vWorkFct = vWorkS.vFct_saM{cS.iCG, iAbil};  
   kBellV = kV;
   [vMinV, ~, kPrimeMinV] = bellman_pd3(cS.cFloor);

   % kPrimeV = hh_bc1.coll_bc_kprime(cS.cFloor, 1 - cS.lFloor, kV, wColl, pColl, R, cS);

   
   % These households cannot afford college
   %  They get the value associated with cFloor, lFloor
   kIdxV = find(kPrimeMinV <= kMin);
   if ~isempty(kIdxV)
      c_kaM(kIdxV,iAbil) = cFloor;
      hours_kaM(kIdxV,iAbil) = 1 - lFloor;
      kPrime_kaM(kIdxV,iAbil) = kMin;
      % The value assigned is essentially arbitrary
      % But it should not be ridiculous b/c the pref shocks force a small fraction of persons into
      % college (sometimes)
      vColl_kaM(kIdxV,iAbil) = -vMinV(kIdxV);
   end
   
   
   % These households can afford college
   kIdxV = find(kPrimeMinV >= kMin);
   for ik = kIdxV(:)'
      % Everything inside this loop is very expensive
%       k = kV(ik);

%       % Max c level that makes borrowing limit bind
%       cMax2 = hh_bc1.hh_coll_c_from_kprime_bc1(kMin, k, wColl, pColl, paramS, cS);
%       % Value of c that goes with max permitted kPrime
%       cMin = hh_bc1.hh_coll_c_from_kprime_bc1(paramS.kMax, k, wColl, pColl, paramS, cS);
%       if isnan(cMin)
%          % Cannot attain kMax
%          cMin = cS.cFloor;
%       else
%          cMin = max(cS.cFloor, cMin);
%       end

      % This may find a corner
      kBellV = kV(ik);
      [c, fVal, exitFlag] = fminbnd(@bellman_pd3, cMin_kV(ik), cMax_kV(ik), cS.fminbndOptS);

      % Check convergence
      if exitFlag <= 0
         %cV = linspace(cMin, cMax2, 100);
         %plot(cV, bellman_pd3(cV), '.');
         error_bc1('no convergence', cS);
      end

      [vOut, hours_kaM(ik,iAbil), kPrime_kaM(ik,iAbil)] = bellman_pd3(c);
      vColl_kaM(ik,iAbil) = -vOut;
      c_kaM(ik,iAbil) = c;
   end

end % for iAbil

% Make sure that borrowing constraints are not violated
if any(kPrime_kaM(:) < kMin - 1e-3)
   error_bc1('BC violated', cS);
end

% Ensure that rounding did not place kPrime outside of grid
kPrime_kaM = max(kMin, kPrime_kaM);


%% Output check
if cS.dbg > 10
   validateattributes(c_kaM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'positive', 'size', [nk, cS.nAbil]})
   validateattributes(hours_kaM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0, '<', 1, 'size', [nk, cS.nAbil]})
   validateattributes(kPrime_kaM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [nk, cS.nAbil]})
  validateattributes(vColl_kaM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [nk, cS.nAbil]}) 
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
      % Repeats Bellman from period 1 +++
      
      % Hours from static condition
      hoursV = 1 - (cV .^ (prefSigma ./ prefRho)) .* ...
         (prefWtLeisure ./ prefWt ./ wColl) .^ (1/prefRho);
      % Impose bounds
      hoursV = max(0, min(1 - lFloor, hoursV));
      % hoursV = hh_bc1.hh_static_bc1(cV, wColl, paramS, cS);
      
      utilV = hh_bc1.hh_util_coll_bc1(cV, 1 - hoursV, prefWt, prefSigma, ...
         prefWtLeisure, prefRho);
      
      % kPrime from budget constraint
      kPrimeBellV = R * kBellV + 2 * (wColl * hoursV - cV - pColl);
      % kPrimeBellV = hh_bc1.coll_bc_kprime(cV, hoursV, k, wColl, pColl, paramS.R, cS);
      
      objOutV = -(onePlusBeta .* utilV + betaSquared .* vWorkFct(kPrimeBellV));
   end


end