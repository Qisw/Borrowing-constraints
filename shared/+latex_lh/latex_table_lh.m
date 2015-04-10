function latex_table_lh(fid, dataM, rowHeaderV, colHeaderM, captionStr, labelStr, ...
   fmtStrV, tbS, dbg);
% Write a latex table to an open file
% Written for SciWord floating tables
% Table layout is simple: header row and column. Numbers in the body.

% USAGE:
%  Open a document with
%     fid = fopen(name, 'w');
%  Call this routine for each table to be created
%  Close the file
%  In Sciword:
%     \input{name}
%     This inserts the file containing the tables. It is displayed as
%     a nondescript field. But it typesets just fine.

% IN:
%  fid
%     File id
%  colHeaderM, rowHeaderV
%     Cell array with headers
%     colHeader M can contain several rows
%  dataM
%     Data to write (numeric). May contain NaN
%     May be cell array of strings
%  captionStr
%     Caption string
%  labelStr
%     Label string
%  fmtStrV
%     Format strings describing how numbers are displayed
%  tbS
%     Optional arguments
%     .topLeftLabelV
%        Labels for top left cells in table (header rows)
%     .alignV
%        Cell array with characters describing column alignment
%        For data columns only. Header column is always left aligned
%     .placement
%        Where to place floating table. E.g. 'hp'
%     .floating
%        Does table float? Default: 0
%     .rowUnderlineV
%        For each row: Underline this row? Default: zeros
% ------------------------------------------------

if nargin ~= 9
   error('Invalid nargin');
end
[nRows, nCols] = size(dataM);


% ******  Set defaults  *********
if ~isfield(tbS, 'topLeftLabelV')
   tbS.topLeftLabelV = repmat({' '}, [1, rows(colHeaderM)]);
end
if ~isfield(tbS, 'alignV')
   tbS.alignV(1 : nCols) = {'r'};
end
% Where to place floating table?
if ~isfield(tbS, 'placement')
   tbS.placement = 'h';
end
if ~isfield(tbS, 'floating')
   tbS.floating = 0;
end
if ~isfield(tbS, 'rowUnderlineV')
   tbS.rowUnderlineV = zeros(1, nRows);
end
tbS.rowUnderlineV(nRows) = 0;


% **** Input check  *******
if cols(colHeaderM) ~= nCols
   warnmsg([ mfilename, ':  Invalid number of col headers' ]);
   keyboard;
end


if tbS.floating == 1
   % Write the code that starts a floating table
   %fprintf(fid, '%s\n', ...
   %   ['%TCIMACRO{\TeXButton{B}{\begin{table}[', tbS.placement, '] \centering}}%']);
   %fprintf(fid, '%s\n', '%BeginExpansion');
   fprintf(fid, '%s\n', ['\begin{table}[' tbS.placement, '] \centering%']);
   %fprintf(fid, '%s\n', '%EndExpansion');
end

% Alignment of header columns
fprintf(fid, '%s', '\begin{tabular}{|l|');
for ic = 1 : nCols
   fprintf(fid, '%s', [tbS.alignV{ic}, '|']);
end
fprintf(fid, '%s\n', '}');
fprintf(fid, '%s\n', '\hline');


% Header rows
for ir = 1 : rows(colHeaderM)
   % First col header
   fprintf(fid, '\\textbf{%s} ', tbS.topLeftLabelV{ir});

   % Other column headers
   for ic = 1 : nCols
      fprintf(fid, ' & \\textbf{%s} ', colHeaderM{ir,ic});
   end
   fprintf(fid, '%s\n', ' \\');
end
% Underline the header rows
fprintf(fid, '%s\n', '\hline');


% Write the table body
for ir = 1 : nRows
   fprintf(fid, '%s ', rowHeaderV{ir});
   for ic = 1 : nCols
      if iscell(dataM(ir,ic))
         cellData = dataM{ir,ic};
      else
         cellData = dataM(ir,ic);
      end
      if isnan(cellData)
         fprintf(fid, [' &  %s'], 'n/a');
      else
         fprintf(fid, [' & ', fmtStrV{ic}], cellData);
      end
   end
   fprintf(fid, '%s\n', ' \\');
   % Underline this row
   if tbS.rowUnderlineV(ir) == 1
      fprintf(fid, '%s\n', '\hline');
   end
end

fprintf(fid, '%s\n', '\hline');
fprintf(fid, '%s\n', '\end{tabular}%');

if tbS.floating == 1
   % Write caption and label
   fprintf(fid, '\\caption{%s}\\label{%s}%% \n',  captionStr, labelStr);

   %fprintf(fid, '%s\n', '%TCIMACRO{\TeXButton{E}{\end{table}}}%');
   %fprintf(fid, '%s\n', '%BeginExpansion');
   fprintf(fid, '%s\n', '\end{table}%');
   %fprintf(fid, '%s\n', '%EndExpansion');
end

% ***** eof  ****
