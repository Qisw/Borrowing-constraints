function plot_sub_lh(xM, yM, optS, dbg);
% Plot xM(i,t) and yM(i,t) as scatter plots
% Subplots that contain optS.nSub lines

% Options
%  .saveFig
%  .figFn
%  .missVal
%  .nSub
%  .xlabel, .ylabel

% -------------------------------------------

[ni, nt] = size(xM);
if ~isequal(size(xM), size(yM))
   warnmsg([ mfilename, ':  Size mismatch' ]);
   keyboard;
end

lineStyleV = {'r-', 'b-', 'g-', 'k-', 'm-', 'c-', 'r--', 'b--', 'g--', 'k--', 'm--', 'c--'};
figOptS  = struct('preview', 'tiff', 'height', 4, 'width', 6, 'color', 'rgb');

% Dimension of plot
spRows = 2;
spCols = 2;
subPerPlot = spRows * spCols;


% *****  Default options  *******

if ~isfield(optS, 'nSub')
   optS.nSub = 5;
end
if ~isfield(optS, 'saveFig')
   optS.saveFig = 0;
end
if ~isfield(optS, 'figFn')
   optS.saveFig = 0;
end
if ~isfield(optS, 'missVal')
   optS.missVal = -919191;
end
if ~isfield(optS, 'labelV')
   optS.labelV = cell(1, ni);
   for ic = 1 : ni
      optS.labelV{ic} = sprintf('%i', ic);
   end
end
if ~isfield(optS, 'xlabel')
   optS.xlabel = 'x';
end
if ~isfield(optS, 'ylabel')
   optS.xlabel = 'y';
end


% Plot counter
iPlot = 0;
% Sub-plot counter
iSub = 0;
% Line counter within subplot
iLine = 0;
% Start new subplot?
newSubplot = 1;


for ic = 1 : ni
   idxV = find(xM(ic,:) ~= optS.missVal  &  yM(ic,:) ~= optS.missVal);
   if length(idxV) >= 1

      % Start new subplot?
      if newSubplot == 1
         iSub = iSub + 1;
         subplot(spRows, spCols, iSub);
         hold on;
         iLine = 0;
         clear legendV;
         newSubplot = 0;
      end

      iLine = iLine + 1;
      sortM = sortrows([xM(ic,idxV)', yM(ic,idxV)'], 1);
      plot(sortM(:, 1), sortM(:, 2), lineStyleV{iLine});
      legendV{iLine} = optS.labelV{ic};
   end

   % Finish subplot?
   if (iLine >= optS.nSub  |  ic >= ni)  &  (newSubplot == 0)
      hold off;
      legend(legendV, 0);
      xlabel(optS.xlabel);
      ylabel(optS.ylabel);
      grid on;
      iLine = 0;
      newSubplot = 1;

      % Finish plot?
      if iSub >= subPerPlot  |  ic >= ni
         if optS.saveFig == 1
            exportfig(gcf, optS.figFn, figOptS, dbg);
            close;
         else
            pause_print(0);
         end
         iSub = 0;
      end
   end
end


% eof
