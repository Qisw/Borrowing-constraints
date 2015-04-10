function [c, hours, kPrime, vColl] = coll_pd3(k, wColl, pColl, j, iCohort, paramS, cS)
% Solve college decision periods 3-4
%{
Student will graduate with certainty

If he cannot afford college, he gets cFloor and lFloor

OUT
   c, hours
      consumption , hours
   vColl
      lifetime utility
   kPrime
      

Checked: 2015-Mar-19
%}


%% Find c and l

% Borrowing limit
kMin = paramS.kMin_aV(cS.ageWorkStart_sV(cS.iCG));

% *****  Try k' corner

% Get (c, l) that attain kMin = kPrime
[cMax, hoursMax] = hh_bc1.hh_coll_c_from_kprime_bc1(kMin, k, wColl, pColl, paramS, cS);

if isnan(cMax)
   % Household cannot afford college and gets cFloor if he goes anyway
   kPrime = kMin;
   c = cS.cFloor;
   hours = 1 - cS.lFloor;
   
else
   % Euler equation for kMin
   eeDev = hh_bc1.hh_eedev_coll3_bc1(cMax, hoursMax, kMin, j, iCohort, paramS, cS);
   if eeDev >= 0
      % Corner solution
      kPrime = kMin;
      c = cMax;
      hours = hoursMax;

   else
      % ******  Interior solution

      % Find range
      cMin = cS.cFloor;

      if cS.dbg > 10
         devMin = devfct(cMin);
         devMax = devfct(cMax);
         if sign(devMin) == sign(devMax)
            error_bc1('No sign change', cS);
         end
      end

      [c, fVal, exitFlag] = fzero(@devfct, [cMin, cMax], cS.fzeroOptS);
      
      if exitFlag <= 0
         error_bc1('No convergence', cS);
      end

      [~,kPrime,hours] = devfct(c);
   end
end


%% Value

% Utility in college
[~,~, util] = hh_bc1.hh_util_coll_bc1(c, 1 - hours, paramS, cS);
% Utility when start working
[~, utilWork] = hh_bc1.hh_work_bc1(kPrime, cS.iCG, j, iCohort, paramS, cS);
vColl = (1 + paramS.prefBeta) .* util + (paramS.prefBeta .^ 2) * utilWork;


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
      kPrime2 = hh_bc1.hh_bc_coll_bc1(c, hours, k, wColl, pColl, paramS.R, cS);
      if abs(kPrime2 - kPrime) > 1e-3
         fprintf('c: %f    k: %f    hours: %f    kPrime: %f and %f \n', ...
            c, k, hours, kPrime, kPrime2);
         error_bc1('bc violated', cS);
      end
      % Euler
      eeDev = hh_bc1.hh_eedev_coll3_bc1(c, hours, kPrime, j, iCohort, paramS, cS);
      if kPrime > kMin + 1e-5
         if abs(eeDev) > 1e-4
            error_bc1('Euler violated', cS);
         end
      elseif kPrime <= kMin
         if eeDev < -1e-6
            error_bc1('Should be corner', cS);
         end
      end
   end
end


%% Nested: Euler dev
   function [eeDev, kPrimeV, hoursV] = devfct(cV)
      [eeDev, kPrimeV, hoursV] = hh_bc1.hh_euler_coll3_bc1(cV, k, wColl, pColl, kMin, j, iCohort, paramS, cS);
   end

end