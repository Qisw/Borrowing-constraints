function target_summary(iCohort, setNo)
% Summarize calibration targets by cohort

cS = const_bc1(setNo);
tgS = var_load_bc1(cS.vCalTargets, cS);

outFn = fullfile(cS.dataOutDir, sprintf('target_summary_coh%i.txt', cS.bYearV(iCohort)));
fp = fopen(outFn, 'w');

nYp = length(cS.ypUbV);
nIq = length(cS.iqUbV);

% Scale factor for dollar figures
% Undoes the stationary transformation 
dollarFactor = 1 / tgS.dollarFactor_cV(iCohort) * cS.unitAcct;

fprintf(fp, '\nSummary of calibration targets for %i cohort\n\n',  cS.bYearV(iCohort));
fprintf(fp, 'All in year %i prices\n', cS.cpiBaseYear);


%% Unconditional stats

age1 = 40;
earn_sV = tgS.earn_tscM(age1 - cS.age1 + 1, :, iCohort);
earn_sV = earn_sV(:);
fprintf(fp, 'Mean earnings by schooling (age %i, thousands): ', age1);
fprintf(fp, '  %.1f  ',  earn_sV .* dollarFactor ./ 1e3);
fprintf(fp, '\n');

fprintf(fp, 'Log skill premiums: ');
fprintf(fp, '  %.2f  ',  diff(log(earn_sV)));
fprintf(fp, '\n');

fprintf(fp, 'College cost: mean / std  %.1f / %.1f \n',  tgS.pMean_cV(iCohort) * dollarFactor ./ 1e3, ...
   tgS.pStd_cV(iCohort) * dollarFactor ./ 1e3);

fprintf(fp, 'In college: mean hours: %.2f   mean earnings: %.1f \n', ...
   tgS.hoursS.hoursMean_cV(iCohort),  mean(tgS.collEarnS.mean_qcM(:,iCohort)) * dollarFactor ./ 1e3);



%% By parental income quartile

fprintf(fp, '\nBy parental income quartile\n');
fprintf(fp, '%4s  %6s  %6s\n',  'Q', 'ypMean', 'zMean');
for i1 = 1 : nYp
   fprintf(fp, '%4i  %6.1f  %6.1f\n', i1, ...
      exp(tgS.logYpMean_ycM(i1,iCohort)) * dollarFactor ./ 1e3,  tgS.transferMean_ycM(i1,iCohort) * dollarFactor / 1e3);
end


%% By IQ quartile

fprintf(fp, '\n\nBy IQ quartile\n');
fprintf(fp, '%4s  %5s %5s  %6s %6s\n',  'Q',  'CD+CG', 'CG',  'ypMean', 'zMean');

for i1 = 1 : nIq
   fprintf(fp, '%4i  %5.2f %5.2f  %6.1f %6.1f\n',  i1, ...
      tgS.fracEnter_qcM(i1,iCohort), tgS.fracGrad_qcM(i1,iCohort),  ...
      exp(tgS.logYpMean_qcM(i1,iCohort)) * dollarFactor ./ 1e3, tgS.transferMean_qcM(i1,iCohort) * dollarFactor ./ 1e3);
end

fclose(fp);
type(outFn);


end