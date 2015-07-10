function cohort_summary(outDir, setNo)
% Summarize differences between cohorts in a latex table

cS = const_bc1(setNo);
symS = helper_bc1.symbols;

% Experiments to show (each cohort)
iCohortV = 1 : 3;
expNoV = cS.bYearExpNoV(iCohortV);
expNoV(3) = cS.expBase;    % Not robust
nx = length(expNoV);

tgS = var_load_bc1(cS.vCalTargets, cS);


%% Table layout

% Columns are experiments
nc = 1 : nx;

% Rows are variables
nr = 20;

tbM = cell([nr, nc]);
tbS.rowUnderlineV = zeros([nr, 1]);

% Header row
ir = 1;
tbM{ir, 1} = 'Cohort';
for ix = 1 : nx
   tbM{ir, 1 + ix} = cS.dataSource_cV{iCohortV(ix)};
end
% tbS.rowUnderlineV(ir) = 1;



%% Table body

for ix = 1 : nx
%    cxS = const_bc1(setNo, expNoV(ix));
   paramS = param_load_bc1(setNo, expNoV(ix));
   iCohort = iCohortV(ix);
   ir = 1;
   
   row_add(' ',  sprintf('%i', cS.cohYearV(ix)));
   tbS.rowUnderlineV(ir) = 1;
   
   collEntryRate = sum(tgS.frac_scM(cS.iCD : cS.iCG, iCohort));
   row_add('College entry rate', sprintf('%.2f', collEntryRate));
   
   collPrem = log(tgS.pvEarn_scM(cS.iCG, iCohort)) - log(tgS.pvEarn_scM(cS.iHSG, iCohort));
   row_add('College premium',  sprintf('%.2f', collPrem));
   
   [~, bLimitStr] = string_lh.dollar_format(-paramS.kMin_aV(end) .* cS.unitAcct, ',', 0);
   row_add('Borrowing limit',  bLimitStr);
   
   [~, collCost] = string_lh.dollar_format(tgS.pMean_cV(iCohort) .* cS.unitAcct, ',', 0);
   row_add('College cost',  collCost);
   
   tbS.rowUnderlineV(ir) = 1;
   
   if cS.regrEntryIqYpWeighted == 1
      dataIdx = tgS.schoolS.iWeighted;
   else
      dataIdx = tgS.schoolS.iWeighted;
   end
   row_add(['$', symS.betaIq, '$'],  sprintf('%.2f', tgS.schoolS.betaIqM(dataIdx,iCohort)));
   row_add(['$', symS.betaYp, '$'],  sprintf('%.2f', tgS.schoolS.betaYpM(dataIdx,iCohort)));

end



%% Write table

outFn = fullfile(outDir, 'cohort_summary.tex');
tbS.rowUnderlineV = tbS.rowUnderlineV(1 : ir);
latex_lh.latex_texttb_lh(outFn, tbM(1:ir,:), 'Caption', 'Label', tbS);

return


%% Nested: Add a row
   function row_add(descrStr, valueStr)
      ir = ir + 1;
      tbM{ir, 1} = descrStr;
      tbM{ir, 1 + ix} = valueStr;
   end

end