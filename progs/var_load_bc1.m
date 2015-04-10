function [loadS, success] = var_load_bc1(varNo, cS)
% Load a variable file
%{
Automatically ensures that variables that only exist for base expNo are loaded for that
%}

% Check consistency
if varNo >= 400  &&  varNo < 500
   % Need to reconstruct cS to load the file from the right dir
   cS = const_bc1(cS.setNo, cS.expBase);
end

fn = var_fn_bc1(varNo, cS);

if exist(fn, 'file')
   loadS = load(fn);
   loadS = loadS.saveS;
   success = 1;
else
   loadS = [];
   success = 0;
end

end