function [utilLifetimeV, muKV, c_ktM] = hh_work_bc1(kV, iSchool, iAbil, paramS, cS)
% Household: work phase
%{
IN
   kV
      initial assets
OUT
   c_ktM
      consumption by age (during work phase)
   utilLifetimeV
      utility = present value of u(c)
   muKV
      marginal utility of k(1)

Checked: 2015-Mar-19
%}

%% Input check

nk = length(kV);
if cS.dbg > 10
   validateattributes(kV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
end


%% Main

% Present value of earnings, discounted to work start
pvEarn = paramS.pvEarn_asM(iAbil, iSchool); 

% Length of work period
T = cS.workYears_sV(iSchool);

% Consumption at work start = (pv income) / pvFactor
c1V = (paramS.R * kV  +  pvEarn) ./ paramS.cPvFactor_sV(iSchool);

% Age consumption paths for each k
c_ktM = c1V(:) * paramS.cFactorV(1 : T)';

utilLifetimeV = nan([nk,1]);
muKV = nan([nk,1]);
for ik = 1 : nk
   [~, muV, utilLifetimeV(ik)] = hh_bc1.util_work_bc1(c_ktM(ik,:), paramS, cS);

   % Marginal value of k
   % Can just assume that additional k is eaten at first date
   % Test: test_bc1.work
   muKV(ik) = muV(1) .* paramS.R;
end



%% Self test
if cS.dbg > 10
   % Present value budget constraint
   for ik = 1 : nk
      pvC = prvalue_bc1(c_ktM(ik,:), paramS.R);
      if abs((paramS.R * kV(ik) + pvEarn) - pvC) > 1e-4
         error_bc1('Invalid budget constraint', cS);
      end
   end
   validateattributes(muKV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive'})
end


end