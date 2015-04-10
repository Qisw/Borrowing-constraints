%{
Vector with deviation from cal targets
%}

classdef devvect

properties
   % no of entries preallocated
   nMax
   % no of entries filled
   n
   % name of each entry
   nameV
   % vector of devstruct; one for each entry
   dsV
   end
   
methods
   % constructor
   function v = devvect(nMax)
      v.nMax = nMax;
      v.n = 0;
      v.nameV = cell([nMax,1]);
      v.dsV = cell([nMax,1]);
   end
   
   % add a deviation
   %  ds is a devstruct
   function v = devadd(v, ds)
      v.n = v.n + 1;
      v.nameV{v.n} = ds.name;
      v.dsV{v.n} = ds;
   end
   
   % Show all deviations on screen
   %{
   short descriptions and scalar deviations
   %}
   function dev_display(v)
      for i1 = 1 : v.n
         shortStr = v.dsV{i1}.short_display;
         fprintf('  %s  ', shortStr);
         if (rem(i1, 5) == 0)  ||  (i1 == v.n)
            fprintf('\n');
         end
      end
   end
   
   % List of all scalar deviations
   function devV = scalar_devs(v)
      devV = nan([v.n, 1]);
      for i1 = 1 : v.n
         devV(i1) = v.dsV{i1}.scalar_dev;
      end
   end
   
   % Return a deviation struct by name
   function ds = dev_by_name(v, nameStr)
      i1 = find(strcmp(v.nameV, nameStr));
      if ~isempty(i1)
         ds = v.dsV{i1};
      else
         ds = [];
      end
   end
end


end