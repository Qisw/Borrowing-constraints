function compare(setNoV, expNoV, tbFn)
% Compare experiments
%{
IN
   tbFn
      file name for output table
%}

nx = length(expNoV);
cS = const_bc1(setNoV(1), expNoV(1));

paramV = cell([nx, 1]);
aggrV = cell([nx, 1]);
constV = cell([nx, 1]);
for ix = 1 : nx
   cxS = const_bc1(setNoV(ix), expNoV(ix));
   constV{ix} = cxS;
   paramV{ix} = param_load_bc1(setNoV(ix), expNoV(ix));
   aggrV{ix} = var_load_bc1(cS.vAggregates, cxS);
end


%% Summary table

% cExp = 2;
% cBase = 3;
nc = 1 + nx;

nr = 50;
tbM = cell([nr, nc]);
tbS.rowUnderlineV = zeros([nr, 1]);


% Header row
ir = 1;
tbM{ir, 1} = 'Variable';
for ix = 1 : nx
   tbM{ir, ix+1} = sprintf('%i/%i',  setNoV(ix), expNoV(ix));
end


% *********  Body
for ix = 1 : nx
   ic = 1 + ix;
   ir = 1;
   
   aggrS = aggrV{ix};
   
   row_add('Cohort',  cS.bYearV(constV{ix}.iCohort),  '%i');
   
   ir = ir + 1;
   tbM{ir,1} = 'Drivers';
   ir = ir + 1;
   tbM{ir,1} = 'PV of lifetime earnings by s';
   tbM{ir, ic} = string_lh.string_from_vector(log(aggrS.pvEarn_sV), '%.2f');
   ir = ir + 1;
   tbM{ir,1} = 'Premium relative to HSG';
   tbM{ir,ic} = string_lh.string_from_vector(diff(log(aggrS.pvEarn_sV)), '%.2f');
   ir = ir + 1;
   tbM{ir,1} = 'Mean college cost';
   [~, tbM{ir,ic}] = string_lh.dollar_format(paramV{ix}.pMean * cS.unitAcct, ',', 0);
   ir = ir + 1;
   tbM{ir,1} = 'Borrowing limit';
   [~, tbM{ir,ic}] = string_lh.dollar_format(paramV{ix}.kMin_aV(end) * cS.unitAcct, ',', 0);
   
   tbS.rowUnderlineV(ir) = 1;
   ir = ir + 1;
   tbM{ir,1} = 'Schooling';
   ir = ir + 1;
   tbM{ir,1} = 'Fraction dropouts / graduates';
   tbM{ir, ic} = string_lh.string_from_vector(aggrS.frac_sV([cS.iCD, cS.iCG]), '%.2f');
   ir = ir + 1;
   tbM{ir,1} = 'By IQ: frac enter';
   tbM{ir, ic} = string_lh.string_from_vector(aggrS.fracEnter_qV, '%.2f');
   ir = ir + 1;
   tbM{ir,1} = '- frac grad';
   tbM{ir, ic} = string_lh.string_from_vector(aggrS.fracGrad_qV, '%.2f');
   ir = ir + 1;
   tbM{ir,1} = 'By yp: frac enter';
   tbM{ir, ic} = string_lh.string_from_vector(aggrS.ypS.fracEnter_yV, '%.2f');
   row_add('- frac grad',  aggrS.ypS.fracGrad_yV,  '%.2f');
   
   tbS.rowUnderlineV(ir) = 1;
   ir = ir + 1;
   tbM{ir,1} = 'College Finances';
   
   row_add('Earnings by IQ',  aggrS.iqS.earnCollMean_qV,  '%.2f');
   row_add('- by yp',  aggrS.ypS.earnCollMean_yV,  '%.2f');
   row_add('Transfers by IQ',  aggrS.iqS.transfer_qV,  '%.2f');
   row_add('- by yp',  aggrS.ypS.transfer_yV,  '%.2f');
   
   % This is currently for 2nd year in college
   total_qV = aggrS.iqS.consCollMean_qV + aggrS.iqS.pMean_qV;
   row_add('Fraction paid out of earnings by IQ',  aggrS.iqS.earnCollMean_qV ./ total_qV, '%.2f');
   total_yV = aggrS.ypS.consCollMean_yV + aggrS.ypS.pColl_yV;
   row_add('- by yp',  aggrS.ypS.earnCollMean_yV ./ total_yV, '%.2f');
   
   
   row_add('By IQ: fraction in debt at eoc',  aggrS.debtEndOfCollegeS.frac_qV,  '%.2f');
   row_add('- mean debt at eoc',  aggrS.debtEndOfCollegeS.mean_qV,  'dollar');
   row_add('By yp: fraction in debt at eoc',  aggrS.debtEndOfCollegeS.frac_yV,  '%.2f');
   row_add('- mean debt at eoc',  aggrS.debtEndOfCollegeS.mean_yV,  'dollar');
   
%    ir = ir + 1;
%    tbM{ir,1} = 'Fraction with debt';
%    ir = ir + 1;
%    tbM{ir,1} = 'Mean debt (unconditional)';
%    ir = ir + 1;
%    tbM{ir,1} = 'Mean transfer';
end


% *******  Write table

outFn = fullfile(cS.tbDir, [tbFn, '.txt']);
fp = fopen(outFn, 'w');
fclose(fp);
diary(outFn);
tbS.rowUnderlineV = tbS.rowUnderlineV(1 : ir);
latex_lh.latex_texttb_lh(fullfile(cS.tbDir, [tbFn, '.tex']), tbM(1:ir,:), 'Caption', 'Label', tbS);
diary off;


%% Nested: add a row
% Dollar values in model units!
   function row_add(descrStr, valueV, fmtStr)
      ir = ir + 1;
      tbM{ir, 1} = descrStr;
      tbM{ir, ic} = output_bc1.formatted_vector(valueV, fmtStr, cS);
   end


end