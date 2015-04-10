function param_show(saveFigures, setNo, expNo)


cS = const_bc1(setNo, expNo);
figS = const_fig_bc1;
paramS = param_load_bc1(setNo, expNo);
% aggrS = var_load_bc1(cS.vAggregates, cS);
% tgS = var_load_bc1(cS.vCalTargets, cS);
% iCohort = cS.iCohort; 
nIq = length(cS.iqUbV);


%% Endowment correlations
% By simulation
if 01
   % Simulate endowments
   [abilV, jV, iqV] = calibr_bc1.endow_sim(1e4, paramS, cS);
%    % IQ classes
%    nIq = length(cS.iqUbV);
%    iqClV = distrib_lh.class_assign(iqV, ones(size(iqV)), cS.iqUbV, cS.dbg);


   % Correlation matrix
   corrM = corrcoef([abilV, paramS.m_jV(jV), iqV, paramS.pColl_jV(jV), log(paramS.yParent_jV(jV))]);

   fprintf('\nEndowment correlations: \n');
   fprintf('[a, m, IQ, p, log(y)] \n');
   
   % Write a nice table +++
   disp(corrM);   
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
   legend(legendV, 'location', 'south');
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save('endow_pr_iq_m', saveFigures, cS);
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
      output_bc1.fig_save(figName, saveFigures, cS);
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