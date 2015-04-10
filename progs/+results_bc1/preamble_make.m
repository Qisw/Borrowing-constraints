function preamble_make(setNo, expNo)
% Write data for preamble

cS = const_bc1(setNo, expNo);


%% Notation for model parameters
% Each potentially calibrated parameter gets a newcommand

for i1 = 1 : cS.pvector.np
   nameStr = cS.pvector.nameV{i1};
   if length(nameStr) > 1
      ps = cS.pvector.retrieve(nameStr);
      results_bc1.preamble_add(nameStr,  ps.symbolStr,  ps.descrStr,  cS);
   end
end

% Other model notation
% results_bc1.preamble_add('prefHS', '\bar{\eta}', 'Common preference for HS', cS);
results_bc1.preamble_add('prefShockEntry', '\eta', 'Preference shock at college entry', cS);


results_bc1.preamble_write(cS);

end