function [fh, rsS] = plot_w_labels_lh(xV, yV, labelM, optS, dbg)
% Create a scatter plot of yV against xV
% Instead of markers, plot text labels provided in labelM
%{

% The figure is left open. This can be embedded in a subplot.
% Hold is left ON, so that lines can be added to the plot.

% IN:
%  optS  Structure with options. May have omitted elements
%        May be set to []
%     FontSize    Size for labels
      FontName
%     Regress     Run regression and plot fitted line?
%     showRegr    Show regression stats on plot?
%     plot45      Plot 45 degree line?
      weighted    weighted least squares? Must provide wtV
%  labelM
%     Labels to place at data points
%     May be char array or vector of cells
%     May be empty. Then use marker 'o'

% OUT:
%  fh = Figure handle
%  rsS
%     Output from regr_stats_lh
%     Empty is Regress = 0

% TEST:  t_plot_w_labels_lh
%}
% -------------------------------------------------------

colorBlue = [0 0 0.7];
colorRed  = [0.6 0 0];
colorBlack = [0 0 0];

if nargin ~= 5
   error([ mfilename, ': Invalid nargin' ]);
end

if ~isreal(xV)
   error([ mfilename, ':  x not real' ]);
end
if ~isreal(yV)
   error([ mfilename, ':  y not real' ]);
end


%% ********  Figure options

if isempty(optS)
   optS.blank = 1;
end

if isfield( optS, 'FontSize' )
   fontSize = optS.FontSize;
else
   fontSize = 8;
end
if isfield( optS, 'FontName' )
   fontName = optS.FontName;
else
   fontName = 'Times';
end

% Run the regression?
if isfield( optS, 'Regress' )
   doRegress = optS.Regress;
else
   doRegress = 0;
end
% Plot the regression?
if doRegress == 1
   if isfield( optS, 'plotRegress' )
      plotRegress = optS.plotRegress;
   else
      plotRegress = 1;
   end
else
   plotRegress = 0;
end

if isfield( optS, 'plot45' )
   plot45 = optS.plot45;
else
   plot45 = 0;
end
if ~isfield(optS, 'showRegr')
   optS.showRegr = 1;
end
if ~isfield(optS, 'weighted')
   useWeights = 0;
else
   useWeights = optS.weighted;
end


%% Input check
if dbg > 10
   if useWeights == 1
      if ~v_check(optS.wtV, 'f', size(yV), 0, [], [])
         error('Invalid weights');
      end
   end
end


%% ******  Plot data

xV = xV(:);
yV = yV(:);
n = length(xV);


% ****  Scale the weights between 0 and 1
if useWeights
   wtScale = 1e3;
   wtV = optS.wtV .* (wtScale ./ max(optS.wtV));
end

hold on;
fh = plot( xV, yV, 'o' , 'MarkerEdgeColor', colorBlack);


% Plot the labels instead of the markers
if ~isempty(labelM)
   set(fh,'marker','none');      %Remove the marker

   for i1 = 1 : n
      if ~iscell(labelM)
         labelStr = deblank(labelM(i1,:));
      else
         labelStr = labelM{i1};
      end
      %labelStr = [sprintf('\\fontsize{%i}', fontSize), labelStr];
      if useWeights == 1
         % More intense for higher weigths
         colorStr = max(1e-3, min(0.7, 1 - wtV(i1) ./ wtScale .* ones([1,3])));
      else
         colorStr = zeros([1,3]);
      end
      text( xV(i1), yV(i1), labelStr, 'FontSize', fontSize, 'FontName', fontName, ...
         'HorizontalAlignment', 'center', 'color', colorStr );
   end
end

if plot45 == 1
   xMin = min(xV);
   xMax = max(xV);
   plot([xMin, xMax], [xMin, xMax], '-.', 'Color', colorBlue, 'LineWidth', 1);
end


%% *******  Run regression

rsS = [];
if doRegress == 1
   xM = [ones(size(xV)), xV];
   %[bV,bIntM, residV,rIntM, statsV] = regress(yV, xM, 0.05);
   if useWeights == 1
      % Weighted least squares
      rsS = regress_lh.lsq_weighted_lh(yV(:), xM, wtV, 0.05, dbg);
   else
      rsS = regress_lh.regr_stats_lh(yV(:), xM, 0.05, dbg);
   end
   
   disp(sprintf('Regression coefficient = %5.3f  (s.e. %5.3f)   R2 = %5.3f    N = %i', ...
      rsS.betaV(2), rsS.seBetaV(2), rsS.rSquare, length(yV) ));
   %disp(sprintf('Beta 5pct confidence band: %5.3f to %5.3f', bIntM(2,:) ));
end

if plotRegress == 1
   yPredV = xM * rsS.betaV;
   [xMin, idxMin] = min(xV);
   [xMax, idxMax] = max(xV);
   plot(xV([idxMin, idxMax]), yPredV([idxMin, idxMax]), '-', 'Color', colorRed, 'LineWidth', 1);
end

if doRegress == 1  &&  optS.showRegr == 1
   % Show regression stats on graph
   regrStr = ['\beta = ', sprintf('%4.2f', rsS.betaV(2)),  sprintf('  [s.e. %4.2f]', rsS.seBetaV(2)), ...
      '    R^{2} = ',  sprintf('%4.2f', rsS.rSquare),  sprintf('   N = %i', rsS.nObs)];
   % Where to show?
   axisV = axis;
   % Upper left corner
   xPos = axisV(1) + 0.05 * (axisV(2) - axisV(1));
   yPos = 0.95 * (axisV(4) - axisV(3)) + axisV(3);
   if rsS.betaV(2) < 0
      % Lower left corner
      %xPos = axisV(1) + 0.1 * (axisV(2) - axisV(1));
      yPos = axisV(3) + 0.05 * (axisV(4) - axisV(3));
   end
   text(xPos, yPos, regrStr, 'FontSize', fontSize, 'FontName', fontName, ...
         'color', colorStr);
end

%hold off;

end