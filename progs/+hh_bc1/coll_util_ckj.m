function collUtilS = coll_util_ckj(paramS, cS)
% Precompute hh utility in college as function of c, k, j


nc = 100;
cMax = 200 .* 1e3 ./ cS.unitAcct;
collUtilS.cGridV = linspace(cS.cFloor, cMax, nc)';
nk = 50;
collUtilS.kGridV = linspace(min(paramS.kMin_aV), paramS.kMax, nk)';

sizeV = [nc, nk, cS.nTypes];
collUtilS.kPrime_ckjM = nan(sizeV);
collUtilS.hours_cjM = nan([nc, cS.nTypes]);
collUtilS.util_ckjM = nan([nc, nk, cS.nTypes]);

c_ckM = collUtilS.cGridV * ones([1,nk]);


for j = 1 : cS.nTypes
   % Hours implied by static condition
   collUtilS.hours_cjM(:,j) = hh_bc1.hh_static_bc1(collUtilS.cGridV, paramS.wColl_jV(j), paramS, cS);
   hours_ckM = collUtilS.hours_cjM(:,j) * ones([1, nk]);   
   
   % k' implied by budget constraint
   collUtilS.kPrime_ckjM(:,:,j) = hh_bc1.hh_bc_coll_bc1(c_ckM, hours_ckM, ones([nc,1]) * collUtilS.kGridV', ...
      paramS.wColl_jV(j), paramS.pColl_jV(j), paramS.R, cS);

   % Utility in college
   collUtilS.util_ckjM(:,:,j) = hh_bc1.hh_util_coll_bc1(c_ckM, 1 - hours_ckM, paramS, cS);
end


if cS.dbg > 10
   validateattributes(collUtilS.util_ckjM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', sizeV})
   validateattributes(collUtilS.kPrime_ckjM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', sizeV})
end

end