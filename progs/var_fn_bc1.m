function [fn, fDir, fName] = var_fn_bc1(varNo, cS)
% Variable name
% ----------------------------------

fDir = cS.matDir;
fName = sprintf('v%03i.mat', varNo);
fn = fullfile(fDir, fName);


end