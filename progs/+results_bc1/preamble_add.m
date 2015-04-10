function preamble_add(fieldNameStr, valueStr, commentStr, cS)
% Add a field to the results preamble
% ------------------------------------------------

if ~ischar(valueStr)
   error('Value must be string');
end

% Remove special characters from field names (so latex does not choke)
fieldNameStr = regexprep(fieldNameStr, '[_\\]', '');

preamble_lh.add_field(fieldNameStr,  valueStr, var_fn_bc1(cS.vPreambleData, cS), commentStr);

fprintf('Preamble: added field %s  with value %s \n',  fieldNameStr, valueStr);

end