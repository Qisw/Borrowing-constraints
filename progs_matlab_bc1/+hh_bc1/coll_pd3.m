function [c_kaM, hours_kaM, kPrime_kaM, vColl_kaM] = coll_pd3(kV, wColl, pColl, vWorkS, paramS, cS)
% Solve college decision periods 3-4
%{
Student will graduate with certainty
Ability is known

If he cannot afford college, he gets cFloor and lFloor
and associated vCollege

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

R = paramS.R;
onePlusBeta = 1 + paramS.prefBeta;
betaSquared = (paramS.prefBeta .^ 2);


%% Allocate outputs

nk = length(kV);
c_kaM = nan([nk, cS.nAbil]);
hours_kaM = nan([nk, cS.nAbil]);
kPrime_kaM = nan([nk, cS.nAbil]);
vColl_kaM = nan([nk, cS.nAbil]);

% Borrowing limit
kMin = paramS.kMin_aV(cS.ageWorkStart_sV(cS.iCG));


%% Optimize state by state
% efficiency: exploit when value work does not depend on ability +++
%  in that case the entire ability loop is unnecessary

for iAbil = 1 : cS.nAbil
   % Find ks for which hh can afford college
   vWorkFct = vWorkS.vFct_saM{cS.iCG, iAbil};  
   kBellV = kV;
   [vMinV, ~, kPrimeMinV] = bellman_pd3(cS.cFloor);

   % kPrimeV = hh_bc1.hh_bc_coll_bc1(cS.cFloor, 1 - cS.lFloor, kV, wColl, pColl, R, cS);

   
   % These households cannot afford college
   %  They get the value associated with cFloor, lFloor
   kIdxV = find(kPrimeMinV <= kMin);
   if ~isempty(kIdxV)
      c_kaM(kIdxV,iAbil) = cS.cFloor;
      hours_kaM(kIdxV,iAbil) = 1 - cS.lFloor;
      kPrime_kaM(kIdxV,iAbil) = kMin;
      % The value assigned is essentially arbitrary
      % But it should not be ridiculous b/c the pref shocks force a small fraction of persons into
      % college (sometimes)
      vColl_kaM(kIdxV,iAbil) = -vMinV(kIdxV);
   end
   
   
   % These households can afford college
   kIdxV = find(kPrimeMinV >= kMin);
   for ik = kIdxV(:)'
      k = kV(ik);

      % Max c level that makes borrowing limit bind
      cMax2 = hh_bc1.hh_coll_c_from_kprime_bc1(kMin, k, wColl, pColl, paramS, cS);
      % Value of c that goes with max permitted kPrime
      cMin = hh_bc1.hh_coll_c_from_kprime_bc1(paramS.kMax, k, wColl, pColl, paramS, cS);
      if isnan(cMin)
         % Cannot attain kMax
         cMin = cS.cFloor;
      else
         cMin = max(cS.cFloor, cMin);
      end

      % This may find a corner
      kBellV = k;
      [c, fVal, exitFlag] = fminbnd(@bellman_pd3, cMin, cMax2, cS.fminbndOptS);

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

IN:
   cV
      consumption
   kBellV
      k today
   vWorkFct(kPrime)
      value of work by kPrime
%}
   function [objOutV, hoursV, kPrimeBellV] = bellman_pd3(cV)
      % This could be precomputed +++
      % Repeats Bellman from period 1 +++
      
      % Hours from static condition
      hoursV = 1 - (cV .^ (paramS.prefSigma ./ paramS.prefRho)) .* ...
         (paramS.prefWtLeisure ./ paramS.prefWt ./ wColl) .^ (1/paramS.prefRho);
      % Impose bounds
      hoursV = max(0, min(1 - cS.lFloor, hoursV));
      % hoursV = hh_bc1.hh_static_bc1(cV, wColl, paramS, cS);
      
      utilV = hh_bc1.hh_util_coll_bc1(cV, 1 - hoursV, paramS, cS);
      
      % kPrime from budget constraint
      kPrimeBellV = R * kBellV + 2 * (wColl * hoursV - cV - pColl);
      % kPrimeBellV = hh_bc1.hh_bc_coll_bc1(cV, hoursV, k, wColl, pColl, paramS.R, cS);
      
      objOutV = -(onePlusBeta .* utilV + betaSquared .* vWorkFct(kPrimeBellV));
   end


end