function endowDerived!(paramS :: paramAllS)
# Derived endowment paramS
#=
Must first set all calibrated params etc that affect endowment draws
=#

cS = paramS.cS;
endowS = paramS.endowS;

endowS.nIQ = length(endowS.iqUbV);
endowS.pr_iqV = diff([0, endowS.iqUbV]);
endowS.pr_ypV = diff([0, endowS.ypUbV])


# All types have the same probability
endowS.prob_jV = ones(endowS.nTypes) ./ endowS.nTypes;


# ---------  Grids

# Order is [pColl, yp, m]
wtM = [1.0  0.0  0.0;    endowS.alphaPY  1.0  0.0;
   endowS.alphaPM  endowS.alphaYM  1.0];

gridM = constBC.endow_grid([endowS.pMean, endowS.logYpMean, 0],
   [endowS.pStd, endowS.logYpStd, 1],  wtM, endowS.nTypes, cS.dbg);
endowS.pColl_jV      = gridM[:,1];
endowS.yParent_jV    = exp(gridM[:,2]);
endowS.m_jV          = gridM[:,3];

if cS.dbg > 10
   # Moments of marginal distributions are checked in test fct for endow_grid
   check_lh.check(endowS.yParent_jV, Vector{Float64}, lb = 0.001);
end


# For now: everyone gets the same college earnings
endowS.wColl_jV = ones(endowS.nTypes) .* endowS.wCollMean;


# Parental income classes
endowS.ypClass_jV :: Vector{Int};
endowS.ypClass_jV = distribLH.class_assign(endowS.yParent_jV,
   endowS.prob_jV, endowS.ypUbV, cS.dbg);
if cS.dbg > 10
   check_lh.check(endowS.ypClass_jV, lb = 1, ub = length(endowS.ypUbV));
end

end
