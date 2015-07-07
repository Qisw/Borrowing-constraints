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
   pvEarn_sV = tgS.pvEarn_scM(:, iCohort) .* dollarFactor;
   tbM{ir,ic} = string_lh.string_from_vector(pvEarn_sV, '%.0f');
   
   ir = ir + 1;
   tbM{ir,1} = 'Premium relative to HSG';
   pvGap_sV = log(pvEarn_sV(2 : cS.nSchool)) - log(pvEarn_sV(1));
   tbM{ir,ic} = string_lh.string_from_vector(pvGap_sV, '%.2f');
   
   ir = ir + 1;
   tbM{ir,1} = 'School fractions';
   tbM{ir,ic} = string_lh.string_from_vector(tgS.frac_scM(:,iCohort), '%.2f');
   
   row_add('Parental income (exp mean log)',  exp(tgS.logYpMean_cV(iCohort)),  'dollar');
   
   row_add('College cost (mean)', tgS.pMean_cV(iCohort), 'dollar');
   
   ir = ir + 1;
   tbM{ir,1} = 'Mean hours worked in college';
   tbM{ir,ic} = sprintf('%.2f', tgS.hoursS.hoursMean_cV(iCohort));

   meanEarn = sum(frac_qV .* tgS.collEarnS.mean_qcM(:,iCohort));
   row_add('Mean earnings in college', meanEarn, 'dollar');
   
   ir = ir + 1;
   tbM{ir,1} = 'Mean transfers in college';
   meanTransfer = sum(frac_qV .* tgS.transferMean_qcM(:,iCohort)) .* dollarFactor;
   tbM{ir,ic} = sprintf('%.1f', meanTransfer);
   
   row_add('Fraction income from work',  tgS.finShareS.workShare_cV(iCohort),  '%.2f');
   
   
   ir = ir + 1;
   tbM{ir,1} = 'College debt';
   
   row_add('Borrowing limit',  tgS.kMin_acM(end, iCohort),  'dollar');
   
   ir = ir + 1;
   tbM{ir,1} = 'Fraction CG with college debt';
   debtFrac = sum(frac_qV .* tgS.debtS.fracGrads_qcM(:,iCohort));
   tbM{ir,ic} = sprintf('%.2f', debtFrac);
   
   debtMean = sum(frac_qV .* tgS.debtS.meanGrads_qcM(:, iCohort));
   row_add('Mean CG debt', debtMean, 'dollar');
end


%% Write table

tbS.rowUnderlineV = tbS.rowUnderlineV(1 : ir);
latex_lh.latex_texttb_lh(fullfile(cS.dataOutDir, 'data_summary.tex'), tbM(1:ir,:), 'Caption', 'Label', tbS);

return;


%% Nested: Add a row
   function row_add(descrStr, valueV, fmtStr)
      ir = ir + 1;
      tbM{ir, 1} = descrStr;
      if strcmp(fmtStr, 'dollar')
         tbM{ir, ic} = output_bc1.formatted_vector(valueV, fmtStr, cS);
            % string_lh.dollar_format(valueV .* dollarFactor, ',', 0);
      else
         tbM{ir, ic} = sprintf(fmtStr, valueV);
      end
   end


end

