function param_from_guess_bc1(setNo, expNo)
% Load intermediate guess from a running calibration
% Save as parameter struct

cS = const_bc1(setNo, expNo);

ans1 = input(sprintf('Overwrite paramS with guesses for %i / %i?  ', setNo, expNo), 's');
if ~strcmp(ans1, 'yes')
   return;
end

paramS = var_load_bc1(cS.vCalDev, cS);

paramS = param_derived_bc1(paramS, cS);

var_save_bc1(paramS, cS.vParams, cS);

end