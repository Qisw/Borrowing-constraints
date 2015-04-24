function [cV, util, muK] = hh_work_bc1(k, iSchool, iAbil, paramS, cS)
% Household: work phase
%{
IN
   k
      initial assets
OUT
   cV
      consumption by age (during work phase)
   util
      utility = present value of u(c)
   pvEarn
      present value of lifetime earnings

Checked: 2015-Mar-19
%}

%% Input check
if cS.dbg > 10
   validateattributes(k, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'scalar'})
end


%% Main

% Present value of earnings
pvEarn = paramS.pvEarn_asM(iAbil, iSchool); 

% % Tax on earnings (only if HSG)
% taxFactor = 1 - paramS.tax_jV(j) * (iSchool ~= cS.iHSG);
taxFactor = 1;

% Consumption at work start = (pv income) / pvFactor
c1 = (paramS.R * k  +  taxFactor * pvEarn) ./ paramS.cPvFactor_sV(iSchool);
T = cS.workYears_sV(iSchool);
cV = c1 .* paramS.cFactorV(1 : T);

[~, muV, util] = hh_bc1.util_work_bc1(cV, paramS, cS);


%% Marginal value of k
% Can just assume that additional k is eaten at first date

muK = muV(1) .* paramS.R;



%% Self test
if cS.dbg > 10
   pvC = prvalue_bc1(cV, paramS.R);
   if abs((paramS.R * k + taxFactor * pvEarn) - pvC) > 1e-4
      error_bc1('Invalid budget constraint', cS);
   end
end


end