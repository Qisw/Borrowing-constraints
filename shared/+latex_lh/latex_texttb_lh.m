function latex_texttb_lh(fid, dataM, captionStr, labelStr, tbS, dbg)
% Write a latex table to an open file
% ---------------------------------------------------------------------
%{
USAGE:
   Open a document with
      fid = fopen(name, 'w');
   Call this routine for each table to be created
   Close the file

IN:
   fid
      File id  OR  string with path to be opened
   dataM
    Cell array of strings
    Includes all headers
   captionStr
    Caption string
   labelStr
    Label string
   tbS
      Optional arguments
      .noteV
         Cell array with table notes. Simply added at bottom of table
         To add spacing: put \n at end of each line
       .lineStrV
          Allows overriding an entire line with a literal string
          Useful for headers
       .showOnScreen
          Show table also on screen? Default: yes
       .alignV
          Cell array with characters describing column alignment
          For data columns only. Header column is always left aligned
       .placement
          Where to place floating table. E.g. 'hp'
       .floating
          Does table float? Default: 0
       .rowUnderlineV
          For each row: Underline this row? Default: zeros
       .colLineV
          Which columns have a line on the LEFT
          If 1st has one on left, then last has one on right
       .colWidthV
          Column width in inches. Set to <= 0 to ignore for particular columns
%}

%% Input check

if nargin < 6
   dbg = 1;
end
if nargin < 5
   error('Invalid nargin');
end
[nRows, nCols] = size(dataM);


%% Open file if necessary
if ischar(fid)
   closeFileAtEnd = 1;
   fPath = fid;
   fid = fopen(fPath, 'w');
   if fid < 0
      error('Cannot open file');
   end
else
   closeFileAtEnd = 0;
end


%% Set defaults

if ~isfield(tbS, 'lineStrV')
   tbS.lineStrV = cell([nRows,1]);
end
if ~isfield(tbS, 'alignV')
   tbS.alignV(1 : nCols) = {'r'};
   tbS.alignV(1) = {'l'};
end
if ~isfield(tbS, 'colWidthV')
   tbS.colWidthV = -99 .* ones(1, nCols);
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
if ~isfield(tbS, 'showOnScreen')
   tbS.showOnScreen = 1;
end
if ~isfield(tbS, 'colLineV')
   tbS.colLineV = zeros(1, nCols);
end


%% Write table

if tbS.floating == 1
   % Write the code that starts a floating table
   fprintf(fid, '%s\n', ['\begin{table}[' tbS.placement, '] \centering%']);
end


% Alignment of header columns
fprintf(fid, '%s', '\begin{tabular}{');
for ic = 1 : nCols
   if tbS.colLineV(ic) == 1
      fprintf(fid, '|');
   end
   if tbS.colWidthV(ic) > 0.001
      fprintf(fid, 'p{%3.2fin}', tbS.colWidthV(ic));
   else
      fprintf(fid, '%s', tbS.alignV{ic});
   end
end
if tbS.colLineV(1) == 1
   fprintf(fid, '|');
end
fprintf(fid, '%s\n', '}');
fprintf(fid, '%s\n', '\hline');


% Write the table body
for ir = 1 : nRows
   if isempty(tbS.lineStrV{ir})
      fprintf(fid, '%s', dataM{ir,1});
      for ic = 2 : nCols
         fprintf(fid, ' & %s ', dataM{ir,ic});
      end
   else
      fprintf(fid, '%s', tbS.lineStrV{ir});
   end
   fprintf(fid, '%s\n', ' \\');
   % Underline this row
   if tbS.rowUnderlineV(ir) == 1
      fprintf(fid, '%s\n', '\hline');
   end
end

% Closing underline
fprintf(fid, '%s\n', '\hline');
fprintf(fid, '%s\n', '\end{tabular}%');


% ****  Table notes
if isfield(tbS, 'noteV')
   fprintf(fid, '\n \\vspace{5 mm} \n');
   fprintf(fid, '\\small \n');
   for i1 = 1 : length(tbS.noteV)
      fprintf(fid, tbS.noteV{i1});
      fprintf(fid, '\n');
   end
   fprintf(fid, '\\normalsize \n');
end


if tbS.floating == 1
   % Write caption and label
   fprintf(fid, '\\caption{%s}\\label{%s}%% \n',  captionStr, labelStr);
   fprintf(fid, '%s\n', '\end{table}%');
end


if tbS.showOnScreen == 1
   text_table_lh(dataM, tbS);
end


%% Clean up

if closeFileAtEnd == 1
   fclose(fid);
   [~, fName] = fileparts(fPath);
   disp(['Saved table ', fName]);
end

end
