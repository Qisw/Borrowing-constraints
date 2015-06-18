function data_summary(setNo)
% Across cohorts
%{
In model units
%}

cS = const_bc1(setNo);
tgS = var_load_bc1(cS.vCalTargets, cS);
% R = cS.R;

% outFn = fullfile(cS.tbDir, 'data_summary.txt');
fp = 1;

% nYp = length(cS.ypUbV);
% nIq = length(cS.iqUbV);
frac_qV = diff([0; cS.iqUbV]);

% Scale factor for dollar amounts
dollarFactor = cS.unitAcct ./ 1e3;

fprintf(fp, '\nSummary of calibration targets\n\n');
fprintf(fp, 'All in year %i prices and detrended\n', cS.cpiBaseYear);


%% Table layout

% columns are cohorts
nc = 1 : cS.nCohorts;

% rows are variables
nr = 50;

tbM = cell([nr, nc]);
tbS.rowUnderlineV = zeros([nr, 1]);

ir = 1;
for iCohort = 1 : cS.nCohorts
   tbM{ir, 1+iCohort} = sprintf('%i', cS.bYearV(iCohort));
end


%% Table body

for iCohort = 1 : cS.nCohorts
   ir = 1;
   ic = 1 + iCohort;
   
   ir = ir + 1;
   tbM{ir,1} = 'Lifetime earnings by s';
   tbM{ir,ic} = string_lh.string_from_vector(tgS.pvEarn_scM(:,iCohort) .* dollarFactor, '%.0f');
   
   ir = ir + 1;
   tbM{ir,1} = 'Premium relative to HSG';
   tbM{ir,ic} = string_lh.string_from_vector(diff(log(tgS.pvEarn_scM(:,iCohort))), '%.2f');
   
   ir = ir + 1;
   tbM{ir,1} = 'School fractions';
   tbM{ir,ic} = string_lh.string_from_vector(tgS.frac_scM(:,iCohort), '%.2f');
   
   ir = ir + 1;
   tbM{ir,1} = 'Parental income (exp mean log)';
   tbM{ir,ic} = sprintf('%.1f', exp(tgS.logYpMean_cV(iCohort)) .* dollarFactor);
   
   ir = ir + 1;
   tbM{ir,1} = 'College cost (mean)';
   tbM{ir,ic} = sprintf('%.1f', tgS.pMean_cV(iCohort) .* dollarFactor);
   
   ir = ir + 1;
   tbM{ir,1} = 'Mean hours worked in college';
   tbM{ir,ic} = sprintf('%.2f', tgS.hoursS.hoursMean_cV(iCohort));

   ir = ir + 1;
   tbM{ir,1} = 'Mean earnings in college';
   meanEarn = sum(frac_qV .* tgS.collEarnS.mean_qcM(:,iCohort)) .* dollarFactor;
   tbM{ir,ic} = sprintf('%.1f', meanEarn);
   
   ir = ir + 1;
   tbM{ir,1} = 'Mean transfers in college';
   meanTransfer = sum(frac_qV .* tgS.transferMean_qcM(:,iCohort)) .* dollarFactor;
   tbM{ir,ic} = sprintf('%.1f', meanTransfer);
   
   ir = ir + 1;
   tbM{ir,1} = 'Fraction with college debt';
   debtFrac = sum(frac_qV .* tgS.debtS.debtFracEndOfCollege_qcM(:,iCohort));
   tbM{ir,ic} = sprintf('%.2f', debtFrac);
   
   ir = ir + 1;
   tbM{ir,1} = 'Mean college debt';
   debtMean = sum(frac_qV .* tgS.debtS.debtMeanEndOfCollege_qcM(:, iCohort));
   tbM{ir,ic} = sprintf('%.1f',  debtMean * dollarFactor);
end


%% Write table

tbS.rowUnderlineV = tbS.rowUnderlineV(1 : ir);
latex_lh.latex_texttb_lh(fullfile(cS.tbDir, 'data_summary.tex'), tbM(1:ir,:), 'Caption', 'Label', tbS);


end


%% Cohort calculations
