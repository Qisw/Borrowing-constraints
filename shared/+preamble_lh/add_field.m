function add_field(fieldName, commandStr, fn, commentStr)
% Add a field to an existing preamble
%{
IN
   commentStr
      can be omitted
      comment above new command
%}
% --------------------------------------

if nargin < 4
   commentStr = [];
end

% Load the preamble file
m  = load(fn);
pS = m.pS;


% Does field exist?
idx = find(strcmpi(pS.nameV, fieldName));

if isempty(idx)
   % Add new field
   pS.nFields = pS.nFields + 1;
   idx = pS.nFields;
   pS.nameV{idx} = fieldName;
end

pS.commandV{idx} = commandStr;
if length(commentStr) > 1
   pS.commentV{idx} = commentStr;
end


% Save the preamble file
save(fn, 'pS');

end