function beta_iq_yp_sequence(outDir, iCohort1, iCohort2, setNoV, expNoV)
% Decompose time series changes in betaIq, betaYp
%{
One set of experiments + initial and terminal cohort

IN
   outDir
      experiment directory for figure
   iCohort1, iCohort2
      if not []: show these as top / bottom rows
      based on cal targets
   setNoV, expNoV
      cases to show
%}

cS = const_bc1(setNoV(1));
figS = const_fig_bc1;
symS = helper_bc1.symbols;
tgS = var_load_bc1(cS.vCalTargets, cS);
nx = length(setNoV);


%% Gather model results

% Also allocate space for cohorts 1 and 2 (at start and end of vectors)
caseStrV = cell([nx + 2, 1]);
betaIqV = zeros([nx + 2, 1]);
betaYpV = zeros([nx + 2, 1]);

for ix = 1 : nx
   cxS = const_bc1(setNoV(ix), expNoV(ix));
   aggrS = var_load_bc1(cxS.vAggregates, cxS);
   
   if cxS.regrEntryIqYpWeighted == 1
      betaIqV(ix+1) = aggrS.qyS.betaIqWeighted;
      betaYpV(ix+1) = aggrS.qyS.betaYpWeighted;
   else
      betaIqV(ix+1) = aggrS.qyS.betaIq;
      betaYpV(ix+1) = aggrS.qyS.betaYp;
   end

   caseStrV{ix+1} = cxS.expS.expStr;
end



%% Data

if cxS.regrEntryIqYpWeighted == 1
   dataIdx = tgS.schoolS.iWeighted;
else
   dataIdx = tgS.schoolS.iWeighted;
end

% cohStrV = cell([2,1]);
% betaIqDataV = zeros([2,1]);
% betaYpDataV = zeros([2, 1]);

for i1 = 1 : 2
   if i1 == 1
      iCohort = iCohort1;
      ix = 1;
   else
      iCohort = iCohort2;
      ix = nx + 2;
   end
   if ~isempty(iCohort)
      betaIqV(ix) = tgS.schoolS.betaIqM(dataIdx,iCohort);
      betaYpV(ix) = tgS.schoolS.betaYpM(dataIdx,iCohort);
      caseStrV{ix} = sprintf('%i', cS.cohYearV(iCohort));
   end
end


%% Graph

saveFigures = 1;

% Omit blanks (which will be omitted data cohorts)
showIdxV = find(betaIqV ~= 0);

for iPlot = 1 : 2
   if iPlot == 1
      yV = betaIqV(showIdxV);
      xStr = symS.betaIq;
      figFn = 'beta_iq_decomp';
   else
      yV = betaYpV(showIdxV);
      xStr = symS.betaYp;
      figFn = 'beta_yp_decomp';
   end
      
   % Must be wide because of long labels
   figOptS = figS.figOptS;
   if iPlot == 1
      figOptS.width = figOptS.width * 1.5;
   end
   fh = output_bc1.fig_new(saveFigures, figOptS);
   barh(yV);
   if iPlot == 1
      % graphs are shown side-by-side; only 1 needs case descriptions
      set(gca, 'YTickLabel', caseStrV(showIdxV));
   end
   xlabel(xStr);
   output_bc1.fig_format(fh, 'bar');
   output_bc1.fig_save(fullfile(outDir, figFn), saveFigures, cS);
end



end