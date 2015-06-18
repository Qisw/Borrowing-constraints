function hoursV = hh_static_bc1(cV, wColl, j, paramS, cS)
% Solve static hh condition while in college
%{
Possible corner: leisure = 1.

IN:
   cBarV, lBarV
      free college consumption and leisure

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

hoursV = max(0, min(1 - cS.lFloor, 1 + paramS.lColl_jV(j) - ((cV + paramS.cColl_jV(j)) .^ (paramS.prefSigma ./ paramS.prefRho)) .* ...
   (paramS.prefWtLeisure ./ paramS.prefWt ./ wColl) .^ (1/paramS.prefRho)));


%% Self test
if cS.dbg > 10
   validateattributes(hoursV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, ...
      '<=', 1, 'size', size(cV)})
   
   % Direct EE equation
   % Leisure can now hit the lFloor corner (b/c of free leisure)
   leisureV = 1 - hoursV;
   [~, muCV, muLV] = hh_bc1.hh_util_coll_bc1(cV, leisureV,  paramS.cColl_jV(j), paramS.lColl_jV(j), ...
      paramS.prefWt, paramS.prefSigma,  paramS.prefWtLeisure, paramS.prefRho);
   eeDevV = (muCV .* wColl - muLV) ./ max(1e-2, muLV);
   vIdxV = find(leisureV > cS.lFloor + 1e-6);
   if ~isempty(vIdxV)
      if any(eeDevV(vIdxV) > 1e-4)
         error_bc1('eeDev > 0', cS);
      end
   end
   if any(abs(eeDevV) > 1e-4  &  (hoursV > 1e-4)  &  (leisureV > cS.lFloor + 1e-6))
      error_bc1('eeDev should be 0 for interior', cS);
   end
end


end