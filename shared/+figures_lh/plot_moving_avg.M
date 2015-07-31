function [maV, idxV] = plot_moving_avg(xV, maLen, missVal, doPlot, dbg);
% Plot moving average of a series
% ---------------------------------------
% TASK:
%  Missing values:  Only points with no missing values in the
%     MA interval are assigned. Otherwise assign missVal

% IN:
%  xV          Vector to be plotted
%  maLen       Length of window
%  missVal     All values <= missVal are missing values
%  doPlot      Show the graph?

% OUT:
%  maV         Moving average of xV (shorter than xV)
%  idxV        Index range corresponding to centers of maV (float, not integer!)

% TEST:        t_plot_moving_avg

% AUTHOR: Lutz Hendricks, 1998-99
% ---------------------------------------

global UNDEFINED

% ******  Input check  *********

if nargin ~= 5
   error('Invalid nargin');
end

xV = xV(:)';
n = length(xV);
if dbg > 5
   v_check( xV, 'f', [1,n], UNDEFINED, UNDEFINED );
   v_check( maLen, 'i', [1,1], 1, n-2 );
end



% **********  MAIN  ******************

% Mark valid observations
validV  = xV > missVal;
xValidV = xV .* validV;

mavLen = n - maLen + 1;
maV = ones(1, n-maLen+1) .* missVal;
for i = 1 : mavLen
   iV = i : i+maLen-1;
   % Only assign, if no missing values around
   if all( validV(iV) > 0.5 )
      maV(i) = sum(xValidV(iV)) / max(1, sum(validV(iV)));
   end
end


xOffset = (maLen-1) / 2;
idxV = xOffset + (1 : mavLen);

if doPlot == 1
   plot( 1:n, xV, 'bo',  idxV, maV, 'r-' );
   pause_print(0);
end


% *** end function ***
