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

% Find ks for which hh can afford college
kPrimeV = hh_bc1.hh_bc_coll_bc1(cS.cFloor, 1 - cS.lFloor, kV, wColl, pColl, R, cS);

% These households cannot afford college
% Right now this means they cannot enter (or must choose higher k)
kIdxV = find(kPrimeV < kMin);
if ~isempty(kIdxV)
   c_kaM(kIdxV,:) = cS.cFloor;
   hours_kaM(kIdxV,:) = 1 - cS.lFloor;
   kPrime_kaM(kIdxV,:) = kMin;
   % Not exactly correct b/c of borrowing limit +++
   vColl_kaM(kIdxV, :) = -bellman_pd3(cS.cFloor);
end

% These households can afford college
kIdxV = find(kPrimeV >= kMin);
for ik = kIdxV(:)'
   k = kV(ik);
   for iAbil = 1 : cS.nAbil
      % Value of working by kPrime
      vWorkFct = vWorkS.vFct_saM{cS.iCG, iAbil};  
      
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
      [c, fVal, exitFlag] = fminbnd(@bellman_pd3, cMin, cMax2, cS.fminbndOptS);

      % Check convergence
      if exitFlag <= 0
         cV = linspace(cMin, cMax2, 100);
         plot(cV, bellman_pd3(cV), '.');
         error_bc1('no convergence', cS);
      end

      [vOut, hours_kaM(ik,iAbil), kPrime_kaM(ik,iAbil)] = bellman_pd3(c);
      vColl_kaM(ik,iAbil) = -vOut;
      c_kaM(ik,iAbil) = c;
   end
end

% Make sure that borrowing constraints are not violated
if any(kPrime_kaM(:) < kMin - 1e-4)
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
%}
   function [objOut, hoursV, kPrimeBellV] = bellman_pd3(cV)
      % This could be precomputed +++
      % Repeats Bellman from period 1 +++
      
      % Hours from static condition
      hoursV = max(0, 1 - (cV .^ (paramS.prefSigma ./ paramS.prefRho)) .* ...
         (paramS.prefWtLeisure ./ paramS.prefWt ./ wColl) .^ (1/paramS.prefRho));
      % hoursV = hh_bc1.hh_static_bc1(cV, wColl, paramS, cS);
      
      utilV = hh_bc1.hh_util_coll_bc1(cV, 1 - hoursV, paramS, cS);
      
      % kPrime from budget constraint
      kPrimeBellV = R * k + 2 * (wColl * hoursV - cV - pColl);
      % kPrimeBellV = hh_bc1.hh_bc_coll_bc1(cV, hoursV, k, wColl, pColl, paramS.R, cS);
      
      objOut = -(onePlusBeta .* utilV + betaSquared .* vWorkFct(kPrimeBellV));
   end



%% old code
% %% Find cases where college is not affordable
% 
% 
% % Get (c, l) that attain kMin = kPrime
% cMax_kV = hh_bc1.hh_coll_c_from_kprime_bc1(kMin, kV, wColl, pColl, paramS, cS);
% 
% kIdxV = find(isnan(cMax_kV));
% if ~isempty(kIdxV)
%    % Household cannot afford college and gets cFloor if he goes anyway
%    kPrime_kaM(kIdxV,:) = kMin;
%    c_kaM(kIdxV,:) = cS.cFloor;
%    hours_kaM(kIdxV,:) = 1 - cS.lFloor;
% end
% 
% 
% %% Cases where college is affordable
% 
% kIdxV = find(~isnan(cMax_kV));
% 
% for iAbil = 1 : cS.nAbil
%    % *****  Try k' corner
%    % Euler equation for kMin
%    eeDev_kV = hh_bc1.hh_eedev_coll3_bc1(cMax_kV(kIdxV), hoursMax, kMin, iAbil, vWorkS, paramS, cS);
%    
%    cornerIdxV = find(eeDev_kV >= 0);
%    if ~isempty(cornerIdxV)
%       % Corner solution
%       cornerIdxV = kIdxV(cornerIdxV);
%       kPrime_kaM(cornerIdxV,iAbil) = kMin;
%       c_kaM(cornerIdxV,iAbil) = cMax;
%       hours_kaM(cornerIdxV,iAbil) = hoursMax;
%    end
%    
%    
%    % ******  Interior solution
%    intIdxV = find(eeDev_kV < 0);
%    if ~isempty(intIdxV)
%       intIdxV = kIdxV(intIdxV);
%       
%       % Find range
%       cMin = cS.cFloor;
%       
%       for ik = intIdxV(:)'
%          cMax = cMax_kV(ik);
%          if cS.dbg > 10
%             devMin = devfct(cMin);
%             devMax = devfct(cMax);
%             if sign(devMin) == sign(devMax)
%                error_bc1('No sign change', cS);
%             end
%          end
% 
%          [c_kaM(ik,iAbil), fVal, exitFlag] = fzero(@devfct, [cMin, cMax], cS.fzeroOptS);
% 
%          if exitFlag <= 0
%             error_bc1('No convergence', cS);
%          end
% 
%          [~,kPrime_kaM(ik,iAbil),hours_kaM(ik,iAbil)] = devfct(c);
%       end
%    end
% end
% 
% 
% %% Value
% 
% % Utility in college
% util_kaM = hh_bc1.hh_util_coll_bc1(c_kaM, 1 - hours_kaM, paramS, cS);
% % Utility when start working
% %  cheaper to use continuous approximation +++
% utilWork_kaM = nan([nk, cS.nAbil]);
% for iAbil = 1 : cS.nAbil
%    for ik = 1 : nk
%       [~, utilWork_kaM(ik,iAbil)] = hh_bc1.hh_work_bc1(kPrime_kaM(ik,iAbil), cS.iCG, iAbil, paramS, cS);
%    end
% end
% % [~, utilWork] = hh_bc1.hh_work_bc1(kPrime, cS.iCG, iAbil, paramS, cS);
% vColl_kaM = (1 + paramS.prefBeta) .* util_kaM + (paramS.prefBeta .^ 2) * utilWork_kaM;
% 
% 
% 
% %% Self test
% if cS.dbg > 10
%    validateattributes(c_kaM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
%       '>=', cS.cFloor, 'size', [nk, cS.nAbil]})
%    validateattributes(hours_kaM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
%       '>=', 0, '<', 1, 'size', [nk, cS.nAbil]})
%    validateattributes(kPrime_kaM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
%       '>=', kMin, 'size', [nk, cS.nAbil]})
%    validateattributes(vColl_kaM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
%       'size', [nk, cS.nAbil]})
%    
%    % Check budget constraint
%    for ik = 1 : nk
%       for iAbil = 1 : cS.nAbil
%          if c > cS.cFloor + 1e-6
%             kPrime2 = hh_bc1.hh_bc_coll_bc1(c_kaM(ik,iAbil), hours_kaM(ik,iAbil), kV(ik), wColl, pColl, paramS.R, cS);
%             if abs(kPrime2 - kPrime_kaM(ik,iAbil)) > 1e-3
%                fprintf('c: %f    k: %f    hours: %f    kPrime: %f and %f \n', ...
%                   c_kaM(ik,iAbil), k_kaM(ik,iAbil), hours_kaM(ik,iAbil), kPrime_kaM(ik,iAbil), kPrime2);
%                error_bc1('bc violated', cS);
%             end
%             % Euler
%             eeDev = hh_bc1.hh_eedev_coll3_bc1(c_kaM(ik,iAbil), hours_kaM(ik,iAbil), kPrime_kaM(ik,iAbil), iAbil, vWorkS, paramS, cS);
%             if kPrime_kaM(ik,iAbil) > kMin + 1e-5
%                if abs(eeDev) > 1e-4
%                   error_bc1('Euler violated', cS);
%                end
%             elseif kPrime_kaM(ik,iAbil) <= kMin
%                if eeDev < -1e-6
%                   error_bc1('Should be corner', cS);
%                end
%             end
%          end
%       end
%    end
% end
% 
% 
% %% Nested: Euler dev
%    function [eeDev, kPrimeV, hoursV] = devfct(cV)
%       [eeDev, kPrimeV, hoursV] = hh_bc1.hh_euler_coll3_bc1(cV, k, wColl, pColl, kMin, ...
%          iAbil, vWorkS, paramS, cS);
%    end


end