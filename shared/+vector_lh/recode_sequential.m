function [xOutV, valueV] = recode_sequential(xV, numDigits)
% Take a vector with a limited number of values
% Return the set of values and recode xV to have values 1:n
%{
IN
   xV
      data vector
   numDigits
      to check for equality of values, round to this number of digits
      default: 8
%}

if isempty(numDigits)
   numDigits = 8;
end
x2V = round(xV, numDigits);

valueV = unique(x2V);

xOutV = zeros(size(xV));
for i1 = 1 : length(valueV)
   xOutV(x2V == valueV(i1)) = i1;
end

validateattributes(xOutV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'integer', '>=', 1, ...
   '<=', length(valueV)})

end