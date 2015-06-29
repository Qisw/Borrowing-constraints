function outV = tex_figure_lh(captionStr, labelStr, figWidth, figPath, figName, fp, optS)
% Creates a cell array
% Each line contains the tex code to write a figure statement

% IN:
%  fp
%     file handle. If not empty, write lines to open file
%  optS
%     noteV
%        vector with strings containing figure notes

% ---------------------------------------------------

if nargin < 7
   optS.blank = 1;
end

outV = cell([10, 1]);

ir = 1;
outV{ir} = '\\begin{figure}';

ir = ir + 1;
outV{ir} = ['\\caption{', captionStr, '\\label{', labelStr, '}}'];

ir = ir + 1;
outV{ir} = ['\\noindent \\centering{}\\includegraphics', sprintf('[width = %3.1f in]', figWidth), '{', ...
   figPath, figName, '}'];

% Table notes, simply a blank line followed by lines of notes
if isfield(optS, 'noteV')
   % Blank line so that notes start a new paragraph
   ir = ir + 1;
   outV{ir} = ' ';
   for i1 = 1 : length(optS.noteV)
      ir = ir + 1;
      outV{ir} = optS.noteV{i1};
   end
end

ir = ir + 1;
outV{ir} = '\\end{figure}';

outV = outV(1 : ir);

if ~isempty(fp)
   for i1 = 1 : ir
      fprintf(fp, outV{i1});
      fprintf(fp, '\n');
   end
end


end