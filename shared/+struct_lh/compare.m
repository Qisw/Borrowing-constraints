function compare(s1, s2, dbg)
% Compare 2 structures. Produce a report
%{
%}
% ------------------------------------

valueToler = 1e-5;
fn1V = fieldnames(s1);
fn2V = fieldnames(s2);


%% Non-matching fiels

for iCase = 1:2
   if iCase == 1
      name1V = fn1V;
      name2V = fn2V;
      hdStr  = 'Fields only in s1 \n';
   else
      name1V = fn2V;
      name2V = fn1V;
      hdStr  = 'Fields only in s2 \n';
   end

   hdShown = 0;
   for i1 = 1 : length(name1V)
      fn = name1V{i1};
      idxV = strcmp(fn, name2V);
      if ~any(idxV)
         if hdShown == 0
            fprintf(hdStr);
            hdShown = 1;
         end
         fprintf('    %s \n', fn);
      end
   end
end


%% Non-matching field values

for i1 = 1 : length(fn1V)
   fn = fn1V{i1};
   idxV = strcmp(fn, fn2V);
   if any(idxV)
      value1 = s1.(fn);
      value2 = s2.(fn);
      if isnumeric(value1)
         if isnumeric(value2)
            if isequal(size(value1), size(value2))
               if max(abs(value1(:) - value2(:))) > valueToler
                  fprintf('    %s  differs in value \n',  fn);
               end
            else
               fprintf('    %s  size mismatch \n',  fn);
            end
         else
            fprintf('    %s  numeric in s1, not numeric in s2 \n',  fn);
         end
      end
   end
end



end