function var_save_bc1(saveS, varNo, cS)
% Save a variable file
% ------------------------------------------

% Check consistency
if varNo >= 400  &&  varNo < 500
   if cS.expNo ~= cS.expBase
      error('Only for base expNo');
   end
end


[fn, fDir] = var_fn_bc1(varNo, cS);

if ~exist(fDir, 'dir')
   files_lh.mkdir_lh(fDir, cS.dbg);
end

save(fn, 'saveS');

fprintf('Saved variable %i  / set %i exp %i \n',  varNo, cS.setNo, cS.expNo);

end