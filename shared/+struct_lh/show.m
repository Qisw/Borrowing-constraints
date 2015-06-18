function show(xS, containStr)
% Show a struct
%{
Only fields whose names contain containStr
%}

nameV = fieldnames(xS);

for i1 = 1 : length(nameV)
   if strfind(lower(nameV{i1}), lower(containStr))
      fprintf('  %8s:   ',  nameV{i1});
      % Can this be shown?
      % Has to be short
      sizeV = size(xS.(nameV{i1}));
      if length(sizeV) == 2  &&  (sizeV(1) < 5)  &&  (sizeV(2) < 8)  && isnumeric(xS.(nameV{i1}))
         fprintf('\n');
         valueM = xS.(nameV{i1});
         % Vector?
         if min(sizeV) == 1
            valueM = valueM(:)';
            sizeV = size(valueM);
         end
         for iRow = 1 : sizeV(1)
            fprintf('    ');
            fprintf('%.3f  ', valueM(iRow, :));
            fprintf('\n');
         end
         
      else
         % Cannot be shown
         fprintf('  Matrix of size  ');
         fprintf('%i  ', sizeV);
         fprintf('\n');
      end
   end
end


end