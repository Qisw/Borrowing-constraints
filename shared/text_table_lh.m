function text_table_lh(dataM, tbS)
% Show a text table on the screen

% dataM
%  The data to show. Text array
% tbS
%  .rowUnderlineV
%     Underline this row?
% ---------------------------------------

[nRows, nCols] = size(dataM);

if ~isfield(tbS, 'rowUnderlineV')
   tbS.rowUnderlineV = zeros(1, nRows);
end
if length(tbS.rowUnderlineV) ~= nRows
   warning([ mfilename, ':  Invalid tbS.rowUnderlineV' ]);
end



% Find the width for each column
colWidthV = zeros(1, nCols);
lengthM = zeros(nRows, nCols);
for ic = 1 : nCols
   for ir = 1 : size(dataM, 1)
      lengthM(ir,ic) = length(dataM{ir,ic});
      colWidthV(ic) = max(colWidthV(ic), lengthM(ir,ic));
   end
end

% Total width of table
tbWidth = sum(colWidthV) + 2 .* nCols + 1;

underlineStr = repmat('-', [1, tbWidth]);

disp(' ');
disp(underlineStr);
for ir = 1 : nRows
   % Make a string for this row
   strV = ' ';
   for ic = 1 : nCols
      nSpaces = colWidthV(ic) - lengthM(ir,ic) + 2;
      strV = [strV, repmat(' ', [1, nSpaces]), dataM{ir,ic}];
   end
   disp(strV);

   if tbS.rowUnderlineV(ir) == 1  ||  ir == nRows
      disp(underlineStr);
   end
end


end
