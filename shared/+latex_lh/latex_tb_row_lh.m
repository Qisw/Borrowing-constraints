function latex_tb_row_lh(fid, dataV, underline, dbg);
% Write 1 row into a Latex table
% Table is open

% iN:
%  fid
%     File id
%  dataV
%     Cell array of string. Data to write
%  underline
%     Underline this row?
% ---------------------------------

nr = length(dataV);

% Write element 1
fprintf(fid, '%s', dataV{1});
% Write other elements
if nr > 1
   for ir = 2 : nr
      fprintf(fid, '& %s', dataV{ir});
   end
end

% End of line character
fprintf(fid, ' \\\\');
if underline == 1
   fprintf(fid, ' \\hline');
end

fprintf(fid, ' \n');


% *** eof  ***
