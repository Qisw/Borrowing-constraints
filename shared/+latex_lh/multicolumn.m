function outStr = multicolumn(textV, widthV, alignV)
% Return a latex multicolumn command for making a table

outStr = '';
for i1 =  1 : length(textV)
   if widthV(i1) == 1
      % Single column
      outStr = [outStr, ' ', textV{i1}, ' '];
   else
      outStr = [outStr, '\multicolumn', sprintf('{%i}{|%s|}{%s}',  widthV(i1),  alignV{i1},  textV{i1})];
   end
   
   if i1 < length(textV)
      % Start next column
      outStr = [outStr, ' & '];
   end
end

outStr = [outStr, ' \\'];


end