function hh_show(saveFigures, setNo, expNo)

cS = const_bc1(setNo, expNo);
figS = const_fig_bc1;
paramS = param_load_bc1(setNo, expNo);
hhS = var_load_bc1(cS.vHhSolution, cS);
aggrS = var_load_bc1(cS.vAggregates, cS);


%% Entry probabilities by type
if 1
   sortM = sortrows([hhS.v0S.probEnter_jV, paramS.prob_jV]);
   fh = output_bc1.fig_new(saveFigures, []);
   hold on;
   plot(cumsum(sortM(:,2)),  sortM(:,1), 'o', 'color', figS.colorM(1,:));
   xlabel('Ability signal');
   ylabel('College entry rate');
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save('entry_m', saveFigures, cS);
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
         [~,uPrimeChild_jV] = hh_bc1.hh_util_coll_bc1(aggrS.cons_tjM(t,:), 1 - aggrS.hours_tjM(t,:), paramS, cS);

      else
         % Kids work as HSG
         workStudyStr = 'work';
         transfer_jV = hhS.v0S.zWork_jV;
         uPrimeChild_jV = nan([cS.nTypes, 1]);
         for j = 1 : cS.nTypes
            k1 = hhS.v0S.k1Work_jV(j);
            % Use ability level with highest probability
            [~, iAbil] = max(paramS.prob_a_jM(:,j));
            cV = hh_bc1.hh_work_bc1(k1, cS.iHSG, iAbil, paramS, cS);
            cChild = cV(1);
            [~, uPrimeChild_jV(j)] = hh_bc1.util_work_bc1(cChild, paramS, cS);
         end
      end
      
      % Parent
      cParent_jV = paramS.yParent_jV - transfer_jV;
      uPrimeParent_jV = hh_bc1.util_parent(cParent_jV, paramS, cS);
      
      
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
   cV = linspace(5e3, 5e4, np) ./ cS.unitAcct;
   
   mupV = hh_bc1.util_parent(cV, paramS, cS);
   [~, muWorkV] = hh_bc1.util_work_bc1(cV, paramS, cS);
   [~,muCollV] = hh_bc1.hh_util_coll_bc1(cV, 0.7 .* ones(size(cV)), paramS, cS);
   
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