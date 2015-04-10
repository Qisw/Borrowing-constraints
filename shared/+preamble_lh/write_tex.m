function tbFn = write_tex(fn)
% Write tex file for a preamble
%{
OUT
   name of 'tex' file
%}
% ------------------------------

m = load(fn);
pS = m.pS;

tbFn = pS.texFn;
fp = fopen(tbFn, 'w');
if fp <= 0
   error('Cannot open file %s', fn);
end


for i1 = 1 : pS.nFields
   % Write comment, if any
   if length(pS.commentV{i1}) > 1
      % Replace single \ with double for fprintf
      commentStr = regexprep(pS.commentV{i1}, '\\{1}', '\\\\');
      fprintf(fp, ['%% ',  commentStr,  '\n']);
   end
   % Replace single \ with double for fprintf
   commandStr = regexprep(pS.commandV{i1}, '\\{1}', '\\\\');
   fprintf(fp, ['\\newcommand{\\',  pS.nameV{i1},  '}{', commandStr, '}\n']);
end

fclose(fp);
% type(tbFn);

end