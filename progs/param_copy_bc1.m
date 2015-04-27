function param_copy_bc1(setNo1, expNo1, setNo2, expNo2)
% Copy parameters from one set to another

% Ask for confirmation
ans1 = input('Copy parameters?  ', 's');
if ~strcmpi(ans1, 'yes')
   return;
end

% copy
paramS = param_load_bc1(setNo1, expNo1);

c2S = const_bc1(setNo2, expNo2);
var_save_bc1(paramS, c2S.vParams, c2S);

end