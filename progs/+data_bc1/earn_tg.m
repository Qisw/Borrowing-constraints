% Earnings and dollar scale factors
function [dollarFactor_cV, tgEarn_tscM, pvEarn_scM] = earn_tg(tgS, cS)

%%  Construct a scale factor for each cohort
%  Multiply all dollar figures by this factor to make model stationary

% Load profiles (units of account, not scaled), by model age
earn_tscM = var_load_bc1(cS.vCohortEarnProfiles, cS);

% Average earnings over this age range
ageV = (30 : 50) - cS.age1 + 1;

% Weights by [age, school] (arbitrary)
%  Would make sense to use actual population weights +++
wt_asM = ones([length(ageV), 1]) * tgS.frac_scM(:, cS.iRefCohort)';
validateattributes(wt_asM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   'size', [length(ageV), cS.nSchool]})

% Mean earnings by cohort, constant weights, constant prices
meanEarn_cV = nan([cS.nCohorts, 1]);
for iCohort = 1 : cS.nCohorts
   earnM = earn_tscM(ageV, :, iCohort);
   validateattributes(earnM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive'})
   meanEarn_cV(iCohort) = sum(earnM(:) .* wt_asM(:)) ./ sum(wt_asM(:));
end

% Scale factor to make model stationary
%  MULTIPLY by this factor to make data figures into model targets
dollarFactor_cV = meanEarn_cV(cS.iRefCohort) ./ meanEarn_cV;


%%  Earnings profiles by [a,s,c]
% Made stationary

tgEarn_tscM = nan(size(earn_tscM));
for iCohort = 1 : cS.nCohorts
   tgEarn_tscM(:,:,iCohort) = earn_tscM(:,:,iCohort) .* dollarFactor_cV(iCohort);
end
if cS.dbg > 10
   validateattributes(tgEarn_tscM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [cS.ageRetire, cS.nSchool, cS.nCohorts]})
end


%% Present values
% discounted to start of work!

% This could fail if R is calibrated
ps = cS.pvector.retrieve('R');
if ps.doCal ~= 0
   error('R cannot be calibrated for this to work');
end

pvEarn_scM = nan([cS.nSchool, cS.nCohorts]);

for iCohort = 1 : cS.nCohorts
   for iSchool = 1 : cS.nSchool
      earnV = tgEarn_tscM(cS.ageWorkStart_sV(iSchool) : cS.ageRetire, iSchool,iCohort);
      validateattributes(earnV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0})
      pvEarn_scM(iSchool,iCohort) = prvalue_bc1(earnV, cS.R);
   end
end

validateattributes(pvEarn_scM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive'})

end