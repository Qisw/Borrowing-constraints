function [numStringV, numString1] = dollar_format(numberV, separator, decimalspaces)
%{
Based on separatethousands

OUT
   numStringV
      cell array
   numString1
      first string, so fct can be used with 1 input
%}
% ---------------------------------------------------------------

n = length(numberV);
numStringV = cell([n, 1]);
    
for i1 = 1 : n
   number = numberV(i1);
   
   % Check if negative
   if number < 0
      modified_number = -number;
      minus = 1;
   else
      modified_number = number;
      minus = 0;
   end
    
    % Pull out decimals
    if decimalspaces > 0
        decimals = modified_number - fix(modified_number);
        modified_number = fix(modified_number);
    end
    
    % Get each block of numbers
    count = 1;
    while modified_number(count) >= 1000
        modified_number(count+1) = fix(modified_number(count)/1000);
        modified_number(count) = modified_number(count) - modified_number(count+1)*1000;
        count = count+1;
    end
    
    % Sign if negative
    if minus
        numstring = sprintf('-%1.0f',modified_number(end));
    else
        numstring = sprintf('%1.0f',modified_number(end));
    end
    
    % Add blocks
    for i2 = 1 : (count-1)
        numstring = sprintf('%s%s%03.0f',...
            numstring,separator,modified_number(end-i2));
    end
    
    % Add decimals
    if decimalspaces > 0
        decimalformat = sprintf('%%0.%1.0ff',decimalspaces);
        decimalstring = sprintf(decimalformat,decimals);
        decimalstring = decimalstring(2:end); % Get rid of the leading zero
        numStringV{i1} = [numstring decimalstring];
    else
       numStringV{i1} = numstring;
    end
   
end

numString1 = numStringV{1};

end