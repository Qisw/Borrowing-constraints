function sNewS = merge(s1S, s2S, dbg)
% Merge 2 structures
%{
% Does not handle structure arrays
% If fields are common, values of s1S are used
% Essentially the fields of s1S are copied into s2S
%}
% ---------------------------------------------------

if ~isstruct(s1S) || ~isstruct(s2S)
   error('Inputs must be structures');
end

% Get all fields of s2S in one step
sNewS = s2S;

% Add fields of s1S one by one
% Cell array with field names
fNameV = fieldnames(s1S);

for i1 = 1 : length(fNameV)
   sNewS.(fNameV{i1}) = s1S.(fNameV{i1});
end

end