function [eeDev, c, l] = hh_corner_coll3_bc1(k, wColl, pColl, kPrime, iCohort, paramS, cS)
% Try corner solution in college
%{
eeDev 
%}

% X = c - wColl l; from bc
x = (paramS.R .* k - kPrime) / 2 - pColl;

% Get work hours from static condition
% Try corner
dev = devfct(0);
if dev >= 0
   l = 0;
else
   l = fzero(@devfct, [0, 0.999]);
end

c = max(cS.cFloor, x + wColl * l);

% Euler deviation: check that sign is correct
eeDev = hh_eedev_coll3_bc1(c, l, k, wColl, pColl, iCohort, paramS, cS);


if cS.dbg > 10
   validateattributes(l, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'scalar', '>=', 0, '<', 1})
   validateattributes(c, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'scalar', '>', 0})
   validateattributes(eeDev, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'scalar'})
end


%% Nested: deviation


% %% Nested: deviation from static condition
% % dev < 0 implies: raise leisure (reduce l)
% % devfct(0) > 0 implies corner
%    function dev = devfct(l)
%       dev = (x + wColl * l)   -  ((paramS.prefPhi / wColl) .^ (-1 / cS.prefSigma)) ...
%          .* ((1 - l) .^ (cS.prefRho / cS.prefSigma));
%       
%       if cS.dbg > 10
%          validateattributes(dev, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'scalar'})
%       end
%    end
% 


end