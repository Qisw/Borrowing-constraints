function initialize(dataFn, texFn)
% Initialize new preamble structure
%{
Drawback:
texFn contains a directory. This creates problems when initialize occurs on a different machine from
writing the preamble to tex
%}
% ----------------------------------

n = 100;
pS.nameV = cell([n,1]);
pS.commandV = cell([n,1]);
pS.commentV = cell([n,1]);
pS.nFields = 0;
pS.texFn = texFn;

save(dataFn, 'pS');

end