function [rowV, colV] = findstr_lh(findV, dataM, caseSensitive, dbg);
% Find the first occurrence of each element of findV
% in the cell array dataM

% strmatch does this for a single element
% ---------------------------------------

[nr, nc] = size(dataM);

nf = length(findV);

rowV = zeros(1, nf);
colV = zeros(1, nf);


% Loop over rows of dataM
for ir = 1 : nr
   % Loop over strings to find
   for i1 = 1 : nf
      % Has this element already been found?
      if rowV(i1) < 1
         % Search the columns of dataM
         for ic = 1 : nc
            if ~isempty(dataM{ir, ic})
               if caseSensitive == 1
                  found = (strcmp(findV{i1}, dataM{ir,ic}) == 1);
               else
                  found = (strcmp(lower(findV{i1}), lower(dataM{ir,ic})) == 1);
               end
               if found == 1
                  rowV(i1) = ir;
                  colV(i1) = ic;
                  break;
               end
            end
         end
      end
   end
end


% *******  eof  ******
