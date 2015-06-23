function param_compare(setNo1, expNo1, setNo2, expNo2)
% Compare parameters between 2 sets

dbg = 111;
setNoV = [setNo1; setNo2];
expNoV = [expNo1; expNo2];
nx = length(expNoV);

% cSV = cell(nx, 1);
paramV = cell(nx, 1);
for ix = 1 : nx
%    cSV{ix} = const_bc1(setNoV(ix), expNoV(ix));
   paramV{ix} = param_load_bc1(setNoV(ix), expNoV(ix));
end


struct_lh.compare(paramV{1}, paramV{2}, dbg);




end