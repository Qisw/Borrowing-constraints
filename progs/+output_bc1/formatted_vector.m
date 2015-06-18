% Format a vector
function outStr = formatted_vector(dataV, fmtStr, cS)
   if strcmpi(fmtStr, 'dollar')
      [numStringV, numString1] = string_lh.dollar_format(dataV .* cS.unitAcct, ',', 0);
      if length(dataV) == 1
         outStr = numString1;
      else
         outStr = strjoin(numStringV, ', ');
      end
   else
      outStr = string_lh.string_from_vector(dataV, fmtStr);
   end

end