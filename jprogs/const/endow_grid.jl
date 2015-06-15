function endow_grid(muV :: Vector{Float64}, stdV :: Vector{Float64}, wtM :: Matrix{Float64},
  nTypes :: Int, dbg :: Int)
# Construct the endowment grid
#=
IN
  muV(iVar), stdV(iVar)
     mean and std dev of marginals
     variances may be 0
  wtM
     weight each var puts on each random variable
=#
# ---------------------------------------------

n = nTypes;
nVar = length(muV);

srand(3);
randM = randn(n, nVar);


## Input check
if dbg > 10
   check_lh.check(muV);
   check_lh.check(stdV, sizeV = (nVar,));
   check_lh.check(wtM, sizeV = (nVar, nVar), lb = -10.0, ub = 10.0);
end


# Make wt matrix to get N(0,1) marginals
#wt2M = zeros(nVar, nVar)
gridM = zeros(n, nVar);
for iVar = 1 : nVar
   wtV = vec(wtM[iVar,:]);
   wtV = wtV ./ sqrt( sum(wtV .^ 2)) * stdV[iVar];
   gridM[:,iVar] = muV[iVar] + randM * wtV;
end

if dbg > 10
   check_lh.check(gridM);
end


return gridM
end
