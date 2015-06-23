function hh_show(saveFigures, setNo, expNo)

cS = const_bc1(setNo, expNo);
if cS.runLocal == 0
   warning('Cannot run hh_show on served. Matlab version outdated.');
   return
end
figS = const_fig_bc1;
paramS = param_load_bc1(setNo, expNo);
hhS = var_load_bc1(cS.vHhSolution, cS);
aggrS = var_load_bc1(cS.vAggregates, cS);


% Collect info and sort by ability signal
dataM = table(paramS.m_jV, paramS.prob_jV, hhS.v0S.probEnter_jV, aggrS.prGrad_jV, ...
   hhS.v0S.zColl_jV,  aggrS.cons_tjM(1,:)',  aggrS.cons_tjM(2,:)',  aggrS.hours_tjM(1,:)', aggrS.hours_tjM(2,:)');
dataM.Properties.VariableNames = {'m', 'probJ', 'probEnter', 'prGradJ', ...
   'zColl', 'c1', 'c2', 'hours1', 'hours2'};
dataM = sortrows(dataM, 1);
dataM.cumProbJ = cumsum(dataM.probJ);


%% Simple x-y plots
if 1
   xStrV = {'m',     'm',     'm',     'm',     'm',     'm',   ...
      'c1',    'c2'};
   yStrV = {'entry', 'c1',    'c2', 'leisure1',  'leisure2', 'prGradJ', ...
      'leisure1', 'leisure2'};
   for iPlot = 1 : length(xStrV)
      [xV, xLabelStr, xFigStr] = fig_data(xStrV{iPlot}, dataM);
      [yV, yLabelStr, yFigStr] = fig_data(yStrV{iPlot}, dataM);
      
      
      fh = output_bc1.fig_new(saveFigures, []);
      hold on;
      plot(xV,  yV, 'o', 'color', figS.colorM(1,:));
      xlabel(xLabelStr);
      ylabel(yLabelStr);
      % Scale y axis for leisure plots
      if strncmpi(yLabelStr, 'leisure', 7)
         figures_lh.axis_range_lh([NaN NaN 0.5 1]);
      end
      output_bc1.fig_format(fh, 'line');
      output_bc1.fig_save(['hh_', yFigStr, '_', xFigStr], saveFigures, cS);
   end
end




%% Transfers and parental income
if 1
   fh = output_bc1.fig_new(saveFigures, []);
   hold on;
   xV = (paramS.yParent_jV);
   plot(xV,  (hhS.v0S.zColl_jV), 'o', 'color', figS.colorM(1,:));
   plot([min(xV), max(xV)], [min(xV), max(xV)], '--', 'color', figS.colorM(2,:));
   xlabel('Parental income');
   ylabel('Transfer (college)');
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save('z_yp', saveFigures, cS);
end


%% Marginal utility parent / college / work (by type)
if 1
   for iPlot = 1 : 2
      if iPlot == 1
         % Kids in college
         workStudyStr = 'college';
         transfer_jV = hhS.v0S.zColl_jV;
         t = 1;
         [~,uPrimeChild_jV] = hh_bc1.hh_util_coll_bc1(aggrS.cons_tjM(t,:)', 1 - aggrS.hours_tjM(t,:)', ...
            paramS.cColl_jV, paramS.lColl_jV, paramS.prefWt, paramS.prefSigma, paramS.prefWtLeisure, paramS.prefRho);

      else
         % Kids work as HSG
         workStudyStr = 'work';
         transfer_jV = hhS.v0S.zWork_jV;
         uPrimeChild_jV = nan([cS.nTypes, 1]);
         for j = 1 : cS.nTypes
            k1 = hhS.v0S.k1Work_jV(j);
            % Use ability level with highest probability
            [~, iAbil] = max(paramS.prob_a_jM(:,j));
            [~,~,cV] = hh_bc1.hh_work_bc1(k1, cS.iHSG, iAbil, paramS, cS);
            cChild = cV(1);
            [~, uPrimeChild_jV(j)] = hh_bc1.util_work_bc1(cChild, paramS, cS);
         end
      end
      
      % Parent
      cParent_jV = paramS.yParent_jV - transfer_jV;
      [~, uPrimeParent_jV] = hh_bc1.util_parent(cParent_jV, 1 : cS.nTypes, paramS, cS);
      
      
      fh = output_bc1.fig_new(saveFigures, []);
      hold on;
      for trPositive = [0, 1]
         idxV = find((transfer_jV > 1e-6) == trPositive);
         if ~isempty(idxV)
            plot(uPrimeParent_jV(idxV), uPrimeChild_jV(idxV), 'o', 'color', figS.colorM(1 + trPositive,:));
         end
      end
      figures_lh.plot45_lh;
      hold off;
      xlabel('MU(c) parent');
      ylabel('Mu(c) child');
      output_bc1.fig_format(fh, 'line');
      output_bc1.fig_save(['muc_parent_child_' workStudyStr], saveFigures, cS);
   end
end


%% Marginal utility: parent / college / work (by consumption)
if 1
   fh = output_bc1.fig_new(saveFigures, []);
   hold on;

   np = 50;
   j = round(cS.nTypes / 2);
   cV = linspace(5e3, 5e4, np) ./ cS.unitAcct;
   
   [~, mupV] = hh_bc1.util_parent(cV, j, paramS, cS);
   [~, muWorkV] = hh_bc1.util_work_bc1(cV, paramS, cS);
   [~,muCollV] = hh_bc1.hh_util_coll_bc1(cV, 0.7 .* ones(size(cV)), paramS.cColl_jV(j), paramS.lColl_jV(j), ...
      paramS.prefWt, paramS.prefSigma,  paramS.prefWtLeisure, paramS.prefRho);
   
   iLine = 1;
   plot(cV,  mupV, figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));

   iLine = iLine + 1;
   plot(cV,  muCollV, figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));

   iLine = iLine + 1;
   plot(cV,  muWorkV, figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));

   hold off;
   xlabel('Consumption');
   ylabel('Marginal utility');
   legend({'Parent', 'College', 'Work'}, 'location', 'northeast');
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save('pref_mu_c', saveFigures, cS);
end



end


%% Get info for figures
   function [dataV, labelStr, figStr] = fig_data(inStr, dataM)
      if strcmp(inStr, 'm')
         labelStr = 'Ability signal (cum pct)';
         dataV = dataM.cumProbJ;
         figStr = 'm';
      elseif strcmp(inStr, 'c1')
         labelStr = 'Cons period 1';
         dataV = dataM.c1;
         figStr = 'c1';
      elseif strcmp(inStr, 'c2')
         labelStr = 'Cons period 2';
         dataV = dataM.c2;
         figStr = 'c2';
      elseif strcmp(inStr, 'leisure1')
         labelStr = 'Leisure period 1';
         dataV = 1 - dataM.hours1;
         figStr = 'leisure1';
      elseif strcmp(inStr, 'leisure2')
         labelStr = 'Leisure period 2';
         dataV = 1 - dataM.hours2;
         figStr = 'leisure2';
      elseif strcmp(inStr, 'entry')
         labelStr = 'College entry rate';
         dataV = dataM.probEnter;
         figStr = 'probEnter';
      elseif strcmp(inStr, 'prGradJ')
         labelStr = 'Prob grad';
         dataV = dataM.prGradJ;
         figStr = 'probGrad';
      else
         error('Invalid');
      end
      
   end
