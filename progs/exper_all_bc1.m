function exper_all_bc1(setNo)
% Run all experiments that do not require recalibration
%{
Need to first calibrate model for all cohorts!
%}

cS = const_bc1(setNo);

for expNo2 = cS.expS.decomposeExpNoM(:)'
   if ~isnan(expNo2)
      exper_bc1(setNo, expNo2);
   end
end

end