function iq_yp_entry(setNo)
% Characterize importance of [iq, yp] for college entry
% Historical studies

cS = const_bc1(setNo);



one_study('flanagan 1971.csv', cS)


end



%% Process one study
function one_study(sourceFn, cS)
   [~, entryS] = data_bc1.load_income_iq_college(sourceFn, cS.setNo);
   
   % Midpoints
   iqBoundsV = [0; entryS.iqUbV];
   iqMidV = 0.5 .* (iqBoundsV(2 : end) - iqBoundsV(1 : (end-1)));
   ypBoundsV = [0; entryS.ypUbV];
   ypMidV = 0.5 .* (ypBoundsV(2 : end) - ypBoundsV(1 : (end-1)));
   
   iqMid_qyM = iqMidV * ones(1, length(ypMidV));
   ypMid_qyM = ones(length(iqMidV), 1) * ypMidV';

   si = scatteredInterpolant(
%    outV = interp2(iqMid_qyM',  ypMid_qyM,  entryS.perc_coll_qyM, 0.5 * ones(size(cS.ypUbV)), ...
%       cS.ypUbV,  'linear');
%    % Not robust +++
%    percColl_qyM = reshape(outV, [length(iqMidV), length(ypMidV)]);

   outV
   keyboard;
end