function outS = college_hours(n79S, tgS, cS)
% Calibration targets: hours in college

nIq = length(cS.iqUbV);
nYp = length(cS.ypUbV);
[~, icNlsy79] = min(abs(cS.bYearV - 1961));

% Annual hours for total time endowment that is split between work and leisure
% 16 hours per day - study time (Babcock Marks) -> 90 hours per week
% outS.timeEndow = 16 * 365 - 32 * 35.6
% how to set this? +++
outS.timeEndow = 52 * 84;


%% Hours by iq or yp

outS.hoursMean_qcM = nan([nIq, cS.nCohorts]);
outS.hoursMean_ycM = nan([nYp, cS.nCohorts]);

% NLSY79
outS.hoursMean_qcM(:, icNlsy79) = n79S.mean_hours_byafqt ./ outS.timeEndow;
outS.hoursMean_ycM(:, icNlsy79) = n79S.mean_hours_byinc ./ outS.timeEndow;

% Check
idxV = find(~isnan(outS.hoursMean_qcM(1,:)));
validateattributes(outS.hoursMean_ycM(:,idxV), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   '<', 1})
validateattributes(outS.hoursMean_qcM(:,idxV), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   '<', 1})


%%  Average hours across all students
% Where possible set from hours by q or y (for consistency

outS.hoursMean_cV = nan([cS.nCohorts, 1]);
% outS.hoursMean_cV(icNlsy79) = n79S.mean_hours ./ outS.timeEndow;

for iCohort = 1 : cS.nCohorts
   if isnan(tgS.fracEnter_ycM(1,iCohort))  ||  isnan(outS.hoursMean_ycM(1,iCohort))
      % Set to 20 hours per week (based on vague data)
      outS.hoursMean_cV(iCohort) = 20 * 50 ./ outS.timeEndow;
   else
      % Set from hours by yp
      mass_yV = tgS.fracEnter_ycM(:, iCohort) .* cS.pr_ypV;
      outS.hoursMean_cV(iCohort) = sum(outS.hoursMean_ycM(:,iCohort) .* mass_yV(:)) ./ sum(mass_yV);
      
      % Alternative calculation should give same result
      mass_qV = tgS.fracEnter_qcM(:, iCohort) .* cS.pr_iqV;
      hoursMean = sum(outS.hoursMean_qcM(:,iCohort) .* mass_qV(:)) ./ sum(mass_qV);
      if abs(outS.hoursMean_cV(iCohort) - hoursMean) / hoursMean > 1e-2
         error_bc1('Mean hours not consistent', cS);
      end
   end
end

validateattributes(outS.hoursMean_cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   'size', [cS.nCohorts, 1]})
      

end