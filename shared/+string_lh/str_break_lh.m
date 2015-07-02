function [cArrayV, nStr] = str_break_lh(strV, delimChar, dbg);
% Break a string into a char array based a delimiter character.
% If delimiter character is tab, set delimChar = char(9)
% or delimChar = '\t'
% Multiple delimiters result in empty cArrayV. They are not treated as one delimiter.
% -------------------------------

if strcmp(delimChar, '\t')
   delimChar = char(9);
end

if dbg > 10
   if length(delimChar) ~= 1
      warnmsg([ mfilename, ':  Invalid delimChar' ]);
      keyboard;
   end
end

if isempty(strV)
   cArrayV = [];
   nStr = 0;

else
   % Find delimiters
   idxV = find(strV == delimChar);

   if length(idxV) == 0
      % Return a single string
      nStr = 1;
      cArrayV{1} = strV;

   else
      nStr = length(idxV) + 1;
      idxV = [idxV, length(strV) + 1];
      cArrayV = cell([1, nStr]);
      if idxV(1) > 1
         cArrayV{1} = strV(1 : idxV(1) - 1);
      else
         cArrayV{1} = '';
      end
      for ic = 2 : nStr
         idx1 = idxV(ic-1) + 1;
         idx2 = idxV(ic) - 1;
         if idx2 >= idx1
            cArrayV{ic} = strV(idx1 : idx2);
         else
            cArrayV{ic} = '';
         end
      end
   end
end


% --------  eof  --------
