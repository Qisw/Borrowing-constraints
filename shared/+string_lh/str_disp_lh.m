function [dispStr, scaleFactor, fmtStr, scaleStr] = ...
   str_disp_lh(varV, missVal, dbg);
% Given a vector to be displayed
% Return
%  scaleFactor
%     Divide by this scale factor before displaying
%     E.g. 1000 for values in the hundreds of thousands
%  fmtStr
%     A format string for sprintf
%  scaleStr
%     E.g. "thousands" for scaleFactor = 1e3
%  dispStr
%     A formatted string to display

% ------------------------------------------------

idxV = find(varV ~= missVal);

if length(idxV) > 0
   vMax = max(abs(varV(idxV)));

   if vMax > 1e7
      scaleFactor = 1e6;
      scaleStr = 'millions';
      fmtStr = ' %7.1f';

   elseif vMax > 1e4
      scaleFactor = 1e3;
      scaleStr = 'thousands';
      fmtStr = ' %7.1f';

   elseif vMax < 0.5
      scaleFactor = 0.01;
      scaleStr = 'pct';
      fmtStr = ' %7.1f';

   else
      scaleFactor = 1;
      scaleStr = ' ';
      fmtStr = ' %7.1f';
   end

   dispVarV = varV ./ scaleFactor;
   dispVarV(varV == missVal) = missVal;

   dispStr = sprintf(fmtStr, dispVarV);

else
   dispStr = 'No data';
   scaleFactor = 1;
   scaleStr = ' ';
   fmtStr = ' %7.1f';
end



% ****** eof ******
