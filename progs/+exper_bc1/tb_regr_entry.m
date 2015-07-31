% Table and graph:  Regression of entry rate on [iq, yp]
%{
With original bins, this is run in the data summary

IN
%}

function tb_regr_entry(outDir, setNoV, expNoV)

cS = const_bc1(setNoV(1));
symS = helper_bc1.symbols;
tgS = var_load_bc1(cS.vCalTargets, cS);
nx = length(setNoV);
fmtStr = '%.2f';


%% Gather data 

caseStrV = cell([nx, 1]);
betaIqM = zeros([nx, 2]);
betaYpM = zeros([nx, 2]);

iModel = 1;
iData = 2;

for ix = 1 : nx
   cxS = const_bc1(setNoV(ix), expNoV(ix));
   aggrS = var_load_bc1(cxS.vAggregates, cxS);
   iCohort = cxS.iCohort;
   if cxS.regrEntryIqYpWeighted == 1
      betaIqM(ix, iModel) = aggrS.qyS.betaIqWeighted;
      betaYpM(ix, iModel) = aggrS.qyS.betaYpWeighted;
      dataIdx = tgS.schoolS.iWeighted;
   else
      betaIqM(ix, iModel) = aggrS.qyS.betaIq;
      betaYpM(ix, iModel) = aggrS.qyS.betaYp;
      dataIdx = tgS.schoolS.iUnweighted;
   end

   caseStrV{ix} = cxS.expS.expStr;

   betaIqM(ix, iData) = tgS.schoolS.betaIqM(dataIdx,iCohort);
   betaYpM(ix, iData) = tgS.schoolS.betaYpM(dataIdx,iCohort);
end


%%  Table

nc = 3;
nr = 1 + 3 * nx;

tbM = cell([nr, nc]);
tbS.rowUnderlineV = zeros([nr, 1]);

ir = 1;
tbM(ir, :) = {' ', ['$', symS.betaIq, '$'], ['$', symS.betaYp, '$']};
tbS.rowUnderlineV(ir) = 1;

for ix = 1 : nx
   ir = ir + 1;
   tbM{ir, 1} = caseStrV{ix};
      %sprintf('Cohort %i',  cS.bYearV(iCohort));

   ir = ir + 1;
   tbM(ir, :) = {'Model',  sprintf(fmtStr, betaIqM(ix, iModel)), sprintf(fmtStr, betaYpM(ix, iModel))};
   ir = ir + 1;
   tbM(ir, :) = {'Data',  sprintf(fmtStr, betaIqM(ix, iData)), sprintf(fmtStr, betaYpM(ix, iData))};
end

latex_lh.latex_texttb_lh(fullfile(outDir, 'regr_entry.tex'), tbM, 'Caption', 'Label', tbS);



%%  Graph

saveFigures = 1;

for iPlot = 1 : 2
   if iPlot == 1
      yM = betaIqM;
      yStr = symS.betaIq;
      figFn = 'beta_iq';
   else
      yM = betaYpM;
      yStr = symS.betaYp;
      figFn = 'beta_yp';
   end
   
   fh = output_bc1.fig_new(saveFigures, []);
   bar(yM);
   set(gca, 'XTickLabel', caseStrV);
   xlabel('Cohort');
   ylabel(yStr);
   figures_lh.axis_range_lh([NaN, NaN, 0, 0.8]);
   legend({'Model', 'Data'}, 'location', 'southoutside', 'orientation', 'horizontal');
   output_bc1.fig_format(fh, 'bar');
   output_bc1.fig_save(fullfile(outDir, figFn), saveFigures, cS);
end

end
