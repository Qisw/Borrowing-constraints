function exportfig_lh(fh, fileName, figOptS, dbg);
% Export a figure to a file
% Similar to exportfig, but attempts to
% avoid some problems

% IN:
%  figOptS
%     Structure with options. All are optional.
%     All are case sensitive.
%     format
%        File format. Must be a valid argument for print
%        Default: deps2
%     resolution
%        Resolution in dpi. Default: r600.
%     axisFontSize
%        Default: no change
%     width, height
%        Size of figure in inches
%        Default: 6 x 3 inches

% --------------------------------------------------

axes_handle = gca;


% ******** Required options ***********
% Set to defaults if not assigned

if isfield(figOptS, 'format')
   formatStr = figOptS.format;
else
   formatStr = '-depsc2';
end

if isfield(figOptS, 'resolution')
   resStr = figOptS.resolution;
else
   resStr = '-r600';
end

if isfield(figOptS, 'width')
   width = figOptS.width;
else
   width = 6;
end

if isfield(figOptS, 'height')
   height = figOptS.height;
else
   height = 3;
end



% **********  Options that are left unchanged if not specified  **********

if isfield(figOptS, 'axisFontSize')
   set(axes_handle, 'FontSize', figOptS.axisFontSize);
end


% Set figure size
set(fh, 'PaperUnits', 'inches');
paperSizeV = get(fh, 'PaperSize');
left = (paperSizeV(1) - width) ./ 2;
bottom = (paperSizeV(2) - height) ./ 2;
set(fh, 'PaperPositionMode', 'manual');
figureSizeV = [left, bottom, width, height];
set(fh, 'PaperPosition', figureSizeV);



print(formatStr, resStr, '-loose', '-tiff', fileName);


% *******  eof  *********
