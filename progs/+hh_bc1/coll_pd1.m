function [c, hours, kPrime, vColl] = coll_pd1(k, wColl, pColl, vmFct, paramS, cS)
% Solve college decision periods 1-2
%{
If he cannot afford college, he gets cFloor and lFloor

Do not permit k' > kMax

IN
   vmFct
      continuation value(k)

OUT
   c, hours
      consumption , hours
   vColl
      lifetime utility

Checked: 2015-Mar-20
%}

if cS.dbg > 10
   validateattributes(wColl, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'scalar', 'positive'})
end

% Extract fields for speed
R = paramS.R;
onePlusBeta = 1 + paramS.prefBeta;
betaSquared = paramS.prefBeta .^ 2;
prefSigma = paramS.prefSigma;
prefRho = paramS.prefRho;
prefWtLeisure = paramS.prefWtLeisure;
prefWt = paramS.prefWt;


%% Find c and l
% Bound c so that k' lies in [borrowing limit, kMax]

% Borrowing limit
kMin = paramS.kMin_aV(cS.ageWorkStart_sV(cS.iCD));

% Get (c, l) that attain kMin = kPrime
cMax = hh_bc1.hh_coll_c_from_kprime_bc1(kMin, k, wColl, pColl, paramS, cS);

if isnan(cMax)
   % Cannot afford anything
   kPrime = kMin;
   c = cS.cFloor;
   hours = 1 - cS.lFloor;
   % Not exactly correct (b/c of k') +++
   %  bellman does not impose borrowing limit
   %  not a major issue b/c these students rarely go to college anyway
   vOut = bellman(c);
   vColl = -vOut;
   
else
   % Value of c that goes with max permitted kPrime
   cMin = hh_bc1.hh_coll_c_from_kprime_bc1(paramS.kMax, k, wColl, pColl, paramS, cS);
   if isnan(cMin)
      % Cannot attain kMax
      cMin = cS.cFloor;
   else
      cMin = max(cS.cFloor, cMin);
   end
   
   % This may find a corner
   [c, fVal, exitFlag] = fminbnd(@bellman, cMin, cMax, cS.fminbndOptS);
   
   % Check convergence
   if exitFlag <= 0
      cV = linspace(cS.cFloor, cMax, 100);
      plot(cV, bellman(cV), '.');
      error_bc1('no convergence', cS);
   end
   
   [vOut, hours, kPrime] = bellman(c);
   vColl = -vOut;
end

% Make sure that numerical issues do not increase kPrime outside of acceptable range
if kPrime > paramS.kMax
   if kPrime > paramS.kMax + 1e-5
      error_bc1('should not happen', cS);
   else
      kPrime = paramS.kMax;
   end
end

if kPrime < kMin
   if kPrime < kMin - 1e-4
      disp([kPrime, kMin, kPrime - kMin]);
      error_bc1('should not happen', cS);
   else
      kPrime = kMin;
   end
end


%% Self test
if cS.dbg > 10
   validateattributes(c, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'scalar', ...
      '>=', cS.cFloor})
   validateattributes(hours, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'scalar', ...
      '>=', 0, '<', 1})
   validateattributes(kPrime, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'scalar', '>=', kMin})
   validateattributes(vColl, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'scalar'})
   
   % Check budget constraint
   if c > cS.cFloor + 1e-6
      kPrime2 = hh_bc1.coll_bc_kprime(c, hours, k, wColl, pColl, paramS.R, cS);
      if abs(kPrime2 - kPrime) > 1e-5
         error_bc1('bc violated', cS);
      end
   end
end


%% Nested: negative RHS of bellman
%{ 
Must be extremely efficient
Repeats code for periods 3-4, but hard to avoid
%}
   function [vOutV, hoursV, kPrimeV] = bellman(cV)
      % Hours from static condition
      hoursV = max(0, 1 - (cV .^ (prefSigma ./ prefRho)) .* ...
         (prefWtLeisure ./ prefWt ./ wColl) .^ (1/prefRho));
      %hoursV = hh_bc1.hh_static_bc1(cV, wColl, paramS, cS);

      utilV = hh_bc1.hh_util_coll_bc1(cV, 1-hoursV, prefWt, prefSigma, ...
         prefWtLeisure, prefRho);

      % Get k' from budget constraint
      kPrimeV = R * k + 2 * (wColl * hoursV - cV - pColl);
      %       kPrimeV = hh_bc1.coll_bc_kprime(cV, hoursV, k, wColl, pColl, paramS.R, cS);

      vOutV = -(onePlusBeta .* utilV + betaSquared .* vmFct(kPrimeV));
      
%       if cS.dbg > 10
%          validateattributes(vOutV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
%             'size', size(cV)})
%       end
   end

end