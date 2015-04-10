function [paramS, success] = param_load_bc1(setNo, expNo)
% Load saved model params and impose derived params
%{
If loading fails, just return default params
%}
% -------------------------------------------------

cS = const_bc1(setNo, expNo);
[paramS, success] = var_load_bc1(cS.vParams, cS);

if success == 0
   paramS.setNo = setNo;
end

paramS = param_derived_bc1(paramS, cS);


end