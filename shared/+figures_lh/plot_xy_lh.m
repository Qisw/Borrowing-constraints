function rsS = plot_xy_lh(xInV, yInV, missVal, optS, dbg)
% xy plot
%{
% Leave figure open

% IN:
%  optS
%     plot45
%     plotRegr
%     weighted
%        Weighted regression
%        Must then provide optS.wtV
%     grid
%     showRegr
%        Show regression stats on figure?

OUT:
   rsS
      Output of regr_stats_lh

Checked: 2014-Aug-13
%}
% ------------------------------------------------

%% Input check

if nargin ~= 5
   error('Invalid nargin');
end

if ~isequal(size(xInV), size(yInV))
   error('size mismatch');
end


%% Options

if ~isfield(optS, 'weighted')
   optS.weighted = 0;
end
if ~isfield(optS, 'plot45')
   optS.plot45 = 0;
end
if ~isfield(optS, 'plotRegr')
   optS.plotRegr = 0;
end
if ~isfield(optS, 'markerStr')
   optS.markerStr = 'b.';
end
if ~isfield(optS, 'grid')
   optS.grid = 1;
end
if ~isfield(optS, 'showRegr')
   optS.showRegr = 0;
end
if ~isfield(optS, 'markerSize')
   optS.markerSize = 15;
end


if optS.weighted == 1
   if any(optS.wtV < 0)
      error('Negative weights');
   end
   if ~isequal(size(optS.wtV), size(xInV))
      error('Wt has wrong size');
   end
   idxV = find(xInV ~= missVal  &  yInV ~= missVal  &  optS.wtV > 0);
   weightV = optS.wtV(idxV);
else
   idxV = find(xInV ~= missVal  &  yInV ~= missVal);
end

n = length(idxV);
if n < 2
   error('No data');
end

xV = xInV(idxV);
yV = yInV(idxV);


%% Plot

hold on;
if optS.weighted == 1
   maxWt = max(weightV);
   meanWt = mean(weightV);
   mkSizeV = max(0.1, min(100, 4 .* weightV ./ meanWt));
   colorM  = min(0.7, 1 - (weightV(:) ./ maxWt) * ones([1,3]));
   for i1 = 1 : length(xV)
%       mkSize = max(0.1, min(100, 5 .* weightV(i1) ./ meanWt));
%       colorV = min(0.7, 1 - weightV(i1) ./ maxWt .* ones([1,3]));
      plot(xV(i1), yV(i1), 'o', 'Markersize', mkSizeV(i1), 'color', colorM(i1,:));
   end
% Cannot use scatter. Figure then cannot be printed (matlab 2014)
%    scatter(xV, yV, mkSizeV, colorM, 'fill');
else
   plot(xV(:), yV(:), optS.markerStr, 'MarkerSize', optS.markerSize);
end

if optS.plot45 == 1
   x45V = [min(xV), max(xV)];
   plot(x45V, x45V, 'g-.');
end


% Regression statistics
xM = [ones([n,1]), xV(:)];
if optS.weighted == 1
   rsS = regress_lh.lsq_weighted_lh(yV(:), xM, weightV(:), 0.05, dbg);
else
   rsS = regress_lh.regr_stats_lh(yV(:), xM, 0.05, dbg);
end


% Plot regression line
if optS.plotRegr
   yHatV = xM * rsS.betaV;
   plot(xV(:), yHatV(:), 'b-');

   if optS.showRegr == 1
      % Show regression stats on graph
      regrStr = ['\beta = ', sprintf('%4.2f', rsS.betaV(2)),  sprintf('  [s.e. %4.2f]', rsS.seBetaV(2)), ...
         ';   {\itR}^2 = ',  sprintf('%4.2f', rsS.rSquare),  ';  {\itN} = ', sprintf('%i', rsS.nObs)];
      % Where to show?
      axisV = axis;
      yPos = 0.95 * (axisV(4) - axisV(3)) + axisV(3);
      %if rsS.betaV(2) > 0
         % Upper left corner
         xPos = axisV(1) + 0.05 * (axisV(2) - axisV(1));
      %else
      %   % Upper right corner
      %   xPos = axisV(1) + 0.1 * (axisV(2) - axisV(1));
      %end
      text(xPos, yPos, regrStr);
   end
end

if optS.grid == 1
   grid on;
end

%hold off;


end
