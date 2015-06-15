function hoursV = hh_static_bc1(cV, wColl, paramS, cS)
% Solve static hh condition while in college
%{
Possible corner: leisure = 1.

OUT: 
   hoursV
      work hours (NOT leisure)

Checked: 2015-Feb-24
%}

%% Input check
if cS.dbg > 10
   validateattributes(cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive'})
   validateattributes(wColl, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'scalar', 'positive'})
end


%% Main

hoursV = max(0, 1 - (cV .^ (paramS.prefSigma ./ paramS.prefRho)) .* ...
   (paramS.prefWtLeisure ./ paramS.prefWt ./ wColl) .^ (1/paramS.prefRho));


%% Self test
if cS.dbg > 10
   validateattributes(hoursV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, ...
      '<=', 1, 'size', size(cV)})
   
   % Direct EE equation
   [~, muCV, muLV] = hh_bc1.hh_util_coll_bc1(cV, 1 - hoursV, paramS.prefWt, paramS.prefSigma, ...
      paramS.prefWtLeisure, paramS.prefRho);
   eeDevV = (muCV .* wColl - muLV) ./ max(1e-2, muLV);
   if any(eeDevV > 1e-4)
      error_bc1('eeDev > 0', cS);
   end
   if any(abs(eeDevV) > 1e-4  &  (hoursV > 1e-4))
      error_bc1('eeDev should be 0 for interior', cS);
   end
end


end