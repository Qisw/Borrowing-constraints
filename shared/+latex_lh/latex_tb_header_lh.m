function latex_tb_header_lh(fid, captionStr, labelStr, tbS, dbg);
% Write header into a Latex table
% File is open
% ----------------------------------------------

% USAGE:
%  Open a document with
%     fid = fopen(name, 'w');
%  Call this routine for each table to be created
%  Write the table body
%  Close the file
%  In Sciword:
%     \input{name}
%     This inserts the file containing the tables. It is displayed as
%     a nondescript field. But it typesets just fine.

% IN:
%  fid
%     File id
%  captionStr
%     Caption string
%  labelStr
%     Label string
%  tbS
%     .nCols
%        Number of columns
%     Optional arguments
%     .alignStr
%        String describing column alignment
%     .placement
%        Where to place floating table. E.g. 'hp'
%     .floating
%        Does table float? Default: 0
% ------------------------------------------------

if nargin ~= 5
   error('Invalid nargin');
end

nCols = tbS.nCols;


% ******  Set defaults  *********
if ~isfield(tbS, 'alignStr')
   tbS.alignStr = '|';
   for ic = 2 : nCols
      tbS.alignStr = [tbS.alignStr, 'l|'];
   end
end
% Where to place floating table?
if ~isfield(tbS, 'placement')
   tbS.placement = 'h';
end
if ~isfield(tbS, 'floating')
   tbS.floating = 0;
end


if tbS.floating == 1
   % Write the code that starts a floating table
   fprintf(fid, '%s\n', ['\begin{table}[' tbS.placement, '] \centering%']);
end

% Alignment of columns
fprintf(fid, '%s', '\begin{tabular}{');
fprintf(fid, '%s', tbS.alignStr);
fprintf(fid, '%s\n', '}');
fprintf(fid, '%s\n', '\hline');


% eof
