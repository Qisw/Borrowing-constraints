function exper_all_bc1(setNo, expNo)
% Run all experiments that do not require recalibration

cS = const_bc1(setNo, expNo);

if expNo == cS.expBase
   for expNo2 = 104 : 106   % Hard coded +++
      exper_bc1(setNo, expNo2);
   end
end

end