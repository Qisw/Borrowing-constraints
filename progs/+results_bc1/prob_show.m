function prob_show(saveFigures, setNo, expNo)

if nargin < 2
   expNo = [];
end

cS = const_bc1(setNo, expNo);
figS = const_fig_bc1;
paramS = param_load_bc1(setNo, expNo);
aggrS = var_load_bc1(cS.vAggregates, cS);
tgS = var_load_bc1(cS.vCalTargets, cS);
% iCohort = cS.iCohort; 



%% Entry and Grad Probs by [q, y]
if 1
   for iPlot = 1 : 2
      if iPlot == 1
         model_qyM = aggrS.massColl_qyM ./ aggrS.mass_qyM;
         zStr = 'Entry rate';
         fnStr = 'prob_enter_qy';
      elseif iPlot == 2
         model_qyM = aggrS.massGrad_qyM ./ aggrS.mass_qyM;
         zStr = 'Graduation rate (unconditional)';
         fnStr = 'prob_grad_qy';
      else
         error('Invalid');
      end

      output_bc1.bar_graph_qy(model_qyM, zStr, saveFigures, cS);
      output_bc1.fig_save(fnStr, saveFigures, cS);

%       fh = output_bc1.fig_new(saveFigures, []);
%       bar3(model_qyM);
%       xlabel('Parental income quartile');
%       ylabel('IQ quartile');
%       zlabel(zStr);
%       colormap(figS.colorMap);
%       view([-135, 30]);
%       output_bc1.fig_format(fh, 'bar');
%       output_bc1.fig_save(fnStr, saveFigures, cS);
   end
end


%% Compare Entry and Grad Probs by [q, y] with data
if ~isnan(tgS.fracGrad_qycM(1,1,cS.iCohort))  &&  1
   for iPlot = 1 : 2
      if iPlot == 1
         data_qyM = tgS.fracEnter_qycM(:,:,cS.iCohort);
         model_qyM = aggrS.massColl_qyM ./ aggrS.mass_qyM;
         zStr = 'Entry rate';
         fnStr = 'fit_prob_enter_qy';
      elseif iPlot == 2
         data_qyM = tgS.fracGrad_qycM(:,:,cS.iCohort);
         model_qyM = aggrS.massGrad_qyM ./ aggrS.mass_qyM;
         zStr = 'Graduation rate (unconditional)';
         fnStr = 'fit_prob_grad_qy';
      else
         error('Invalid');
      end
      
      fh = output_bc1.fig_new(saveFigures, figS.figOpt4S);
      % One subplot per yp quartile
      for iy = 1 : length(cS.ypUbV)
         subplot(2,2,iy);
         bar([model_qyM(:,iy), data_qyM(:,iy)], 'grouped');      
         xlabel('IQ quartile');  
         zlabel(zStr);
         if iy == 1
            legend({'Model', 'Data'});
         end
         colormap(figS.colorMap);
         output_bc1.fig_format(fh, 'bar');
      end
      
      output_bc1.fig_save(fnStr, saveFigures, cS);
   end
end


%% Prob grad | j
if 1
   % Sort types by prob grad
   sortM = sortrows([aggrS.prGrad_jV, aggrS.mass_jV]);
   
   fh = output_bc1.fig_new(saveFigures, []);
   plot(cumsum(sortM(:,2)), sortM(:,1), 'o', 'color', figS.colorM(1,:));
   xlabel('Signal percentile');
   ylabel('Graduation probability');
   figures_lh.axis_range_lh([NaN NaN 0 1]);
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save('prob_grad_j', saveFigures, cS);
end


%% Prob grad | a
if 1
   fh = output_bc1.fig_new(saveFigures, []);
   plot(cumsum(paramS.prob_aV), paramS.prGrad_aV, figS.lineStyleV{1});
   xlabel('Ability percentile');
   ylabel('Graduation probability');
   figures_lh.axis_range_lh([NaN NaN 0 1]);
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save('prob_grad_a', saveFigures, cS);
end




end