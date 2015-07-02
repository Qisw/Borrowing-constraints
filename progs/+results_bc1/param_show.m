function param_show(saveFigures, setNo, expNo)


cS = const_bc1(setNo, expNo);
figS = const_fig_bc1;
paramS = param_load_bc1(setNo, expNo);
statsS = var_load_bc1(cS.vAggrStats, cS);
% aggrS = var_load_bc1(cS.vAggregates, cS);
% tgS = var_load_bc1(cS.vCalTargets, cS);
% iCohort = cS.iCohort; 
nIq = length(cS.iqUbV);
outDir = cS.paramDir;

% Mean ability by m
mean_abil_j(saveFigures, paramS, cS);



%% Return to schooling by ability
if 1
   legendV = cell([2,1]);
   % Log pv earn difference by [a,s]
   dLogPv_asM = diff(log(paramS.pvEarn_asM), 1, 2);
   
   fh = output_bc1.fig_new(saveFigures, []);
   hold on;
   
   for i1 = 1 : 2
      iLine = i1;
      plot(cumsum(paramS.prob_aV), dLogPv_asM(:,i1), figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));
      legendV{iLine} = [cS.sLabelV{i1+1}, ' vs ', cS.sLabelV{i1}];
   end
   
   hold off;
   xlabel('Ability percentile');
   ylabel('Log lifetime earnings gap');
   legend(legendV, 'location', 'south');
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save(fullfile(outDir, 'lty_return_a'), saveFigures, cS);
end


%% Endowment correlations
% By simulation
if 01
   corrS = statsS.endowCorrS;

   [tbM, tbS] = latex_lh.corr_table(corrS.corrM, corrS.varNameV);
   latex_lh.latex_texttb_lh(fullfile(outDir, 'endow_corr.tex'), tbM, 'Caption', 'Label', tbS);
   clear corrS;
end


%%  Plot(pr(iq | j))
if 1
   sortM = sortrows([paramS.prob_jV, paramS.prIq_jM']);
   xV = cumsum(sortM(:,1));
   legendV = cell([nIq, 1]);

   fh = output_bc1.fig_new(saveFigures, []);
   hold on;
   
   for i1 = 1 : nIq
      iLine = i1;
      plot(xV,  sortM(:, 1+i1), figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));
      legendV{iLine} = sprintf('IQ %i', i1);
   end
   
   hold off;
   xlabel('Ability signal');
   ylabel('Pr(IQ | m)');
   legend(legendV, 'location', 'north');
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save(fullfile(outDir, 'endow_pr_iq_m'), saveFigures, cS);
end



%% Distribution of endowments (joint)
if 1
   for iPlot = 1 : 3
      if iPlot == 1
         % m / yp
         xV = paramS.m_jV;
         xStr = 'Ability signal';
         yV = log(paramS.yParent_jV);
         yStr = 'Log yParent';
         wtV = paramS.prob_jV;
         figName = 'endow_yp_m';
      elseif iPlot == 2
         % m / p
         xV = paramS.m_jV;
         xStr = 'Ability signal';
         yV = paramS.pColl_jV;
         yStr = 'College cost';
         wtV = paramS.prob_jV;
         figName = 'endow_p_m';
      elseif iPlot == 3
         % yp / p
         xV = log(paramS.yParent_jV);
         xStr = 'Log yParent';
         yV = paramS.pColl_jV;
         yStr = 'College cost';
         wtV = paramS.prob_jV;
         figName = 'endow_p_yp';
      else
         error('Invalid');
      end
      
      [~, corrCoeff] = distrib_lh.cov_w(xV, yV, wtV, cS.missVal, cS.dbg);
      
      fh = output_bc1.fig_new(saveFigures, []);
      plot(xV, yV, 'o', 'color', figS.colorM(1,:));
      xlabel(xStr);
      ylabel(yStr);
      text(0.1, 0.1, sprintf('Correlation %.2f', corrCoeff), 'Units', 'normalized');
      output_bc1.fig_format(fh, 'line');
      output_bc1.fig_save(fullfile(outDir, figName), saveFigures, cS);
   end
end



% %% tax(m)
% if 1
%    sortM = sortrows([paramS.m_jV, paramS.prob_jV, paramS.tax_jV]);
%    fh = output_bc1.fig_new(saveFigures, []);
%    plot(cumsum(sortM(:,2)), sortM(:,3), figS.lineStyleV{1});
%    xlabel('Ability signal percentile');
%    ylabel('Tax on HS earnings');
%    output_bc1.fig_format(fh, 'line');
%    output_bc1.fig_save('tax_m', saveFigures, cS);
% end



end


%% E(a|j)
function mean_abil_j(saveFigures, paramS, cS)
   figS = const_fig_bc1;
   
   % Compute E(a | j)
   meanA_jV = nan([cS.nTypes, 1]);
   for j = 1 : cS.nTypes
      meanA_jV(j) = sum(paramS.prob_a_jM(:, j) .* paramS.abilGrid_aV);
   end
   
   fh = output_bc1.fig_new(saveFigures, []);
   hold on
   plot(paramS.m_jV,  meanA_jV, 'o', 'color', figS.colorM(1,:));
   plot([-2,2], [-2,2], 'k-');
   hold off;
   xlabel('m');
   ylabel('E(a|j)');
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save(fullfile(cS.paramDir, 'endow_eOfa_j'), saveFigures, cS);
end