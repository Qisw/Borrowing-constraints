function compare(setNoV, expNoV, outDir)
% Compare experiments
%{
IN
   outDir
      Results are written to this dir
   tbFn
      file name for output table
%}

fprintf('\nComparing a set of experiments \n');
fprintf('    %i', setNoV);
fprintf('\n');
fprintf('    %i', expNoV);
fprintf('\n');

dbg = 111;
saveFigures = 1;
nx = length(expNoV);
cS = const_bc1(setNoV(1), expNoV(1));
figS = const_fig_bc1;
nIq = length(cS.iqUbV);
nYp = length(cS.ypUbV);
tgS = var_load_bc1(cS.vCalTargets, cS);

% Just in case we run this for the 1st time, make the directories for outputs
files_lh.mkdir_lh(outDir, cS.dbg);


%% Load all experiments

paramV = cell([nx, 1]);
aggrV = cell([nx, 1]);
statsV = cell([nx, 1]);
constV = cell([nx, 1]);
cohortStrV = cell([nx, 1]);
expStrV = cell([nx, 1]);
for ix = 1 : nx
   cxS = const_bc1(setNoV(ix), expNoV(ix));
   constV{ix} = cxS;
   paramV{ix} = param_load_bc1(setNoV(ix), expNoV(ix));
   aggrV{ix} = var_load_bc1(cS.vAggregates, cxS);
   statsV{ix} = var_load_bc1(cS.vAggrStats, cxS);
   cohortStrV{ix} = sprintf('%i', cS.cohYearV(constV{ix}.iCohort));
   expStrV{ix} = cxS.expS.expStr;
end

if any(isempty(aggrV))  ||  any(isempty(statsV))
   warning('Could not load all experiments');
   return;
end


%% Regression of entry rate on [iq, yp]
% With original bins, this is run in the data summary
if 1
   fprintf('\nRegress entry rate on [iq, yp]\n');
   exper_bc1.tb_regr_entry(outDir, setNoV, expNoV);
   fprintf('\nEntry gaps by iq and yp \n');
   exper_bc1.tb_entry_gaps(expNoV, outDir, cS);
end



%% By iq, yp: Entry and graduation rates
if 1
   entry_grad(aggrV, expStrV, outDir, saveFigures, cS);
end


%% Financing bar graph
if 1
   exper_bc1.college_finance(outDir, saveFigures, expStrV, setNoV, expNoV);
end


%% Summary table
% A column is an experiment

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
   
   %row_add('Cohort',  cS.bYearV(constV{ix}.iCohort),  '%i');
   ir = ir + 1;
   tbM{ir, 1} = 'Case';
   tbM{ir, ic} = constV{ix}.expS.expStr;
   
   ir = ir + 1;
   tbM{ir,1} = 'Drivers';
   ir = ir + 1;
   tbM{ir,1} = 'PV of lifetime earnings by s';
   tbM{ir, ic} = string_lh.string_from_vector(aggrS.pvEarnMeanLog_sV, '%.2f');
   ir = ir + 1;
   tbM{ir,1} = 'Premium relative to HSG';
   tbM{ir,ic} = string_lh.string_from_vector(diff(aggrS.pvEarnMeanLog_sV), '%.2f');
   
   xV = statsV{ix}.abilMean_sV .* paramV{ix}.phi_sV;
   row_add('Premium due to selection',  diff(xV),  '%.2f');
   
   ir = ir + 1;
   tbM{ir,1} = 'Mean college cost';
   [~, tbM{ir,ic}] = string_lh.dollar_format(paramV{ix}.pMean * cS.unitAcct, ',', 0);
   ir = ir + 1;
   tbM{ir,1} = 'Borrowing limit';
   [~, tbM{ir,ic}] = string_lh.dollar_format(paramV{ix}.kMin_aV(end) * cS.unitAcct, ',', 0);
   corrAM = statsV{ix}.endowCorrS.corrM(statsV{ix}.endowCorrS.iAbil, statsV{ix}.endowCorrS.iSignal);
   row_add('Corr ability signal',  corrAM, '%.2f');
   
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

outFn = fullfile(outDir, 'summary.tex');
% fp = fopen(outFn, 'w');
% fclose(fp);
% diary(outFn);
tbS.rowUnderlineV = tbS.rowUnderlineV(1 : ir);
latex_lh.latex_texttb_lh(outFn, tbM(1:ir,:), 'Caption', 'Label', tbS);
% diary off;


%% Nested: add a row
% Dollar values in model units!
   function row_add(descrStr, valueV, fmtStr)
      ir = ir + 1;
      tbM{ir, 1} = descrStr;
      tbM{ir, ic} = output_bc1.formatted_vector(valueV, fmtStr, cS);
   end


end


% ---------  end of main function




%% Local: By iq, yp: Entry and graduation rates
function entry_grad(aggrV, expStrV, outDir, saveFigures, cS)
   figS = const_fig_bc1;
   nIq = length(cS.iqUbV);
   nYp = length(cS.ypUbV);
   nx  = length(aggrV);

   % What is plotted in each figure?
   iIq = 1;
   iYp = 2;
   xTypeV = [iIq, iIq, iYp, iYp];
   yStrV = {'Fraction entering college',  'Fraction graduating from college', ...
      'Fraction entering college',  'Fraction graduating from college'};
   figFnV = {'iq_enter',   'iq_grad',    'yp_enter',    'yp_grad'};
   
   for iPlot = 1 : length(xTypeV)
      if xTypeV(iPlot) == iIq
         xStr = figS.iqGroupStr;
         xV = 1 : nIq;
      elseif xTypeV(iPlot) == iYp
         xStr = figS.ypGroupStr;
         xV = 1 : nYp;
      else
         error('Invalid');
      end
      
      yM = zeros([length(xV), nx]);
      for ix = 1 : nx
         if iPlot == 1
            yV = aggrV{ix}.fracEnter_qV;
         elseif iPlot == 2
            yV = aggrV{ix}.fracGrad_qV;
         elseif iPlot == 3
            yV = aggrV{ix}.ypS.fracEnter_yV;
         elseif iPlot == 4
            yV = aggrV{ix}.ypS.fracGrad_yV;
         else
            error('Invalid');
         end
         yM(:,ix) = yV;
      end      
      
      
      fh = output_bc1.fig_new(saveFigures, []);
      bar(xV, yM);
      xlabel(xStr);
      ylabel(yStrV{iPlot});
      legend(expStrV, 'location', 'northwest');
      figures_lh.axis_range_lh([NaN NaN 0 1]);
      output_bc1.fig_format(fh, 'bar');
      output_bc1.fig_save(fullfile(outDir, figFnV{iPlot}), saveFigures, cS);
   end
end
