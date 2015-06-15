function collUtilS = coll_util_kkj(paramS, cS)
% Precompute hh utility in college as function of k', k, j


nk = 50;
collUtilS.kGridV = linspace(min(paramS.kMin_aV), paramS.kMax, nk)';

sizeV = [nk, nk, cS.nTypes];
collUtilS.c_kPkjM = nan(sizeV);
collUtilS.hours_kPkjM = nan(sizeV);

for j = 1 : cS.nTypes
   for ik = 1 : nk
      for ikP = 1 : nk
         [collUtilS.c_kPkjM(ik,:,j), collUtilS.hours_kPkjM(ik,:,j)] = ...
            hh_bc1.hh_coll_c_from_kprime_bc1(collUtilS.kGridV(ikP), collUtilS.kGridV(ik), paramS.wColl_jV(j), ...
            paramS.pColl_jV(j), paramS, cS);
      end
   end
end

% Utility in college
collUtilS.util_kPkjM = hh_bc1.hh_util_coll_bc1(collUtilS.c_kPkjM, 1 - collUtilS.hours_kPkjM, ...
   paramS.prefWt, paramS.prefSigma,  paramS.prefWtLeisure, paramS.prefRho);

if cS.dbg > 10
   validateattributes(collUtilS.util_kPkjM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', sizeV})
end

end