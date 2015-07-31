function [yMin, yMax] = fig_yrange_lh(xV)
% Determine the y range for plotting xV
% --------------------------------------

xMax = max(xV(:));
yMax = ceil(xMax * 20) ./ 20;

xMin = min(xV(:));
yMin = floor(xMin * 20) ./ 20;


end