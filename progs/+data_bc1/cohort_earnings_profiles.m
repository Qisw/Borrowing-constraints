function cohort_earnings_profiles(setNo)
% Earnings by [model age, school, cohort]
% Including skill price
%{
Use median rather than mean log
Takes into account participation
Easier to be consistent over time
%}

cS = const_bc1(setNo);
expNo = cS.expBase;
useMedian = 1;

% Load cps profiles (in constant dollars), by model age
cpsS = const_cpsbc(cS.cpsSetNo);
if useMedian == 1
   loadS = var_load_cpsbc(cpsS.vCohortEarnProfilesMedian, [], cS.cpsSetNo);
else
   error('Not updated');
end


%% Extract the right ages, convert into model ages
% drop HSD

T = min(size(loadS.logEarn_ascM, 1), cS.physAgeRetire);

% By model age, drop HSD
data_ascM = loadS.logEarn_ascM(cS.age1 : T, 2:end, :);
medianEarn_ascM = exp(data_ascM);
medianEarn_ascM(data_ascM == cS.missVal) = cS.missVal;
if cS.dbg > 10
   validateattributes(medianEarn_ascM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [T - cS.age1 + 1, cS.nSchool, cS.nCohorts]})
end
T = size(medianEarn_ascM, 1);


%% Convert into units of account
% Fill in missing ages

earn_ascM = repmat(cS.missVal, [cS.ageRetire, cS.nSchool, cS.nCohorts]);

% Convert into units of account
if useMedian == 1
   valid_ascM = (medianEarn_ascM > 0);
   earn_ascM(1 : T, :, :) = (valid_ascM .* medianEarn_ascM) ./ cS.unitAcct;
else
   valid_ascM = (medianEarn_ascM > -10);
   earn_ascM(1 : T, :, :) = (valid_ascM .* medianEarn_ascM) ./ cS.unitAcct;
end



% Set values outside of acceptable age ranges to 0 or missing
for iSchool = 1 : cS.nSchool
   age1 = cS.ageWorkStart_sV(iSchool);
   if age1 > 1
      earn_ascM(1 : (age1-1), iSchool, :) = cS.missVal;
   end
end


% Ages past what can be constructed from data are set to 0 earnings
% Or past model retirement age
if T < cS.ageRetire
   earn_ascM((T+1) : cS.ageRetire, :, :) = 0;
end


var_save_bc1(earn_ascM, cS.vCohortEarnProfiles, cS);


%% Output check

if cS.dbg > 10
   validateattributes(earn_ascM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [cS.ageRetire, cS.nSchool, cS.nCohorts]})
   
   for iCohort = 1 : cS.nCohorts
      for iSchool = 1 : cS.nSchool
         earnV = earn_ascM(:, iSchool, iCohort);
         age1 = cS.ageWorkStart_sV(iSchool);
         if any(earnV(age1 : end) < 0)
            error_bc1('Invalid', cS)
         end
         if age1 > 1
            if any(earnV(1 : (age1-1)) ~= cS.missVal)
               error_bc1('Invalid', cS);
            end
         end
         if any(earnV(age1 + (0 : 30)) < 1e-3)
            error('Invalid');
         end
      end
   end
end


end
