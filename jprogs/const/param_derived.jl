function param_derived!(paramS)
# Derived parameters
#=
how to handle removing or adding params?
=#


# Unbundle paramS
cS = paramS.cS;
prefS = paramS.prefS;
workS = paramS.workS;
endowS = paramS.endowS;

nIq = length(endowS.iqUbV);
iCohort = cS.iCohort;

miscDerived!(cS);


# tgS = filesBC.load(cS.vCalTargets, cS)


# Remove unused params


# Fix all parameters that are not calibrated (doCal no in cS.doCalV)
#  also add missing params
# not needed here -- all params are set from defaults first
# paramS = cS.pvector.struct_update(paramS, cS.doCalV)


# Parameters taken from data; if not calibrated
# only if always taken from data (never calibrated)
# it does not make sense to have params that are sometimes taken from data
#=
  enable +++++
pNameV    = {"logYpMean", "logYpStd"}
tgNameV   = {"logYpMean_cV", "logYpStd_cV"}
byCohortV = [1, 1]
for i1 = 1 : length(pNameV)
   pName = pNameV{i1}
   ps = cS.pvector.retrieve(pName)
   if ps.doCal == cS.calNever
      tgV = tgS.(tgNameV{i1})
      if byCohortV(i1) == 1
         tgV = tgV[iCohort]
      end
      paramS.(pName) = tgV
   end
end
=#

# If not baseline experiment: copy all parameters that were calibrated in baseline but are not
# calibrated now from baseline params
#=
enable +++++
if cS.expNo != cS.expBase
   c0S = constBC.paramSet(cS.setNo, cS.expBase)
   param0S = filesBC.load(cS.vParams, c0S)
   paramS = cS.pvector.param_copy(paramS, param0S, cS.calBase)
end
=#


## -------------   Work

workDerived!(paramS);


#=
## College costs
#
#If not calibrated: copied from base expNo
#But can override by setting collCostExpNo
#

if ~isempty(cS.expS.collCostExpNo)
   c2S = constBC.paramSet(cS.setNo, cS.expS.collCostExpNo)
   param2S = filesBC.load(c2S.vParams, c2S)
   paramS.pMean = param2S.pMean
   paramS.pStd  = param2S.pStd
end
=#

# Endowments
endowDerived!(paramS);


#=
enable +++++

# # *****  Preference for work as HSG (expressed as tax rate on HS earnings)
#
# paramS.tax_jV = logistic_bc1(paramS.m_jV, paramS.taxHSzero, paramS.taxHSslope)
# if cS.dbg > 10
#    check_lh.check(paramS.tax_jV, {"double"}, {"finite", "nonnan", "nonempty", "real", ...
#       ">", -0.95, "<", 0.95, "size", [cS.nTypes, 1]})
# end

# Range of permitted assets in college (used for approximating value functions)
paramS.kMax = 2e5 ./ cS.unitAcct


## Ability grid

# Equal weighted bins
paramS.prob_aV = ones(cS.nAbil, 1) ./ cS.nAbil;

# Pr(a | type)
[paramS.prob_a_jM, paramS.abilGrid_aV] = ...
   calibr_bc1.normal_conditional(paramS.prob_aV, paramS.prob_jV, paramS.m_jV, ...
   paramS.alphaAM, cS.dbg)

if cS.dbg > 10
   check_bc1.prob_matrix(paramS.prob_a_jM,  [cS.nAbil, cS.nTypes],  cS)
   check_lh.check(paramS.abilGrid_aV, {"double"}, {"finite", "nonnan", "nonempty", "real", ...
      "size", [cS.nAbil, 1]})
end


# ******  Derived

# Pr(a) = sum over j (pr(j) * pr(a|j))
#  should very close to what was exogenously set
for iAbil = 1 : cS.nAbil
   prob_a_jV = paramS.prob_a_jM(iAbil,:)
   paramS.prob_aV(iAbil) = sum(paramS.prob_jV(:) .* prob_a_jV(:))
end

if cS.dbg > 10
   check_bc1.prob_matrix(paramS.prob_aV,  [cS.nAbil, 1], cS)
end



##  IQ

# Pr(iq group | j)
paramS.prIq_jM = calibr_bc1.pr_xgroup_by_type(paramS.m_jV, ...
   paramS.prob_jV, paramS.sigmaIQ, cS.iqUbV, cS.dbg)

if cS.dbg > 10
   check_bc1.prob_matrix(paramS.prIq_jM,  [length(cS.iqUbV), cS.nTypes],  cS)
end

# # Pr(iq group | a,c)
#    # wrong but not used +++
# paramS.prob_iq_acM = nan([length(cS.iqUbV), cS.nAbil, cS.nCohorts]);
# for iCohort = 1 : cS.nCohorts
#    paramS.prob_iq_acM(:,:,iCohort) = calibr_bc1.pr_xgroup_by_type(paramS.abilGrid_acM(:, iCohort), ...
#        paramS.prob_acM(:, iCohort), paramS.sigmaIQ_cV(iCohort), cS.iqUbV, cS.dbg)
# #    calibr_bc1.pr_iq_a(paramS.abilGrid_acM(:, iCohort), ...
# #       paramS.prob_acM(:, iCohort), paramS.sigmaIQ_cV(iCohort), cS.iqUbV, cS.dbg)
# end


# *******  Derived

# Pr(IQ and j) = Pr(iq | j) * Pr(j)
paramS.pr_qjM = paramS.prIq_jM .* (ones(nIq,1) * paramS.prob_jV(:)')
if cS.dbg > 10
   prSum_jV = sum(paramS.pr_qjM)
   if any(abs(prSum_jV(:) - paramS.prob_jV) > 1e-4)
      error_bc1("Invalid", cS)
   end
   prSum_qV = sum(paramS.pr_qjM, 2)
   if any(abs(prSum_qV(:) - cS.pr_iqV) > 2e-3)  # why so inaccurate?
      error_bc1("Invalid", cS)
   end
end

# Pr(j | IQ) = Pr(j and IQ) / Pr(iq)
pr_qV = sum(paramS.pr_qjM, 2)
paramS.prJ_iqM = paramS.pr_qjM" ./ sum(paramS.pr_qjM(:)) ./ (ones(cS.nTypes,1) * pr_qV(:)")
if cS.dbg > 10
   prSumV = sum(paramS.prJ_iqM)
   if any(abs(prSumV - 1) > 1e-2)      # Why so inaccurate? +++
      disp(prSumV)
      error_bc1("Probs do not sum to 1", cS)
   end
end
# # Pr(j | IQ)
# #  surprisingly inaccurate +++
# paramS.prJ_iqM = nan([cS.nTypes, nIq])
# for iIq = 1 : nIq
#    for j = 1 : cS.nTypes
#       paramS.prJ_iqM(j, iIq) = paramS.prIq_jM(iIq,j) * paramS.prob_jV(j) ./ cS.pr_iqV(iIq)
#    end
#    prSum = sum(paramS.prJ_iqM(:, iIq))
#    if abs(prSum - 1) > 1e-3
#       error_bc1("Invalid", cS)
#       # why not more accurate?
#    end
#    paramS.prJ_iqM(:, iIq) = paramS.prJ_iqM(:, iIq) ./ prSum
# end



## Graduation probs

# *****  Derived

paramS.prGrad_aV = pr_grad_a_bc1(1 : cS.nAbil, iCohort, paramS, cS)

if cS.dbg > 10
   check_lh.check(paramS.prGrad_aV, {"double"}, {"finite", "nonnan", "nonempty", "real", ...
      ">=", 0, "<=", 1, "size", [cS.nAbil, 1]})
end



## Earnings by [model age, school]
# Including skill price

# Returns to ability by s
paramS.phi_sV = [paramS.phiHSG; paramS.phiHSG; paramS.phiCG]
paramS.eHat_sV = paramS.eHatCD + [paramS.dEHatHSG; 0; paramS.dEHatCG]

if isempty(cS.expS.earnExpNo)
   # Targets
   paramS.tgS.pvEarn_sV = tgS.pvEarn_scM(:, cS.iCohort)

   # Present value by [ability, school]
   #  discounted to work start age
   if cS.abilAffectsEarnings == 0
      # Ability does not affect earnings
      paramS.pvEarn_asM = ones(cS.nAbil, 1) * paramS.tgS.pvEarn_sV'
   else
      dAbilV = (paramS.abilGrid_aV - cS.aBar)
      paramS.pvEarn_asM = nan([cS.nAbil, cS.nSchool])
      for iSchool = 1 : cS.nSchool
         paramS.pvEarn_asM(:,iSchool) = paramS.tgS.pvEarn_sV(cS.iHSG) * ...
            exp(paramS.eHat_sV(iSchool) + dAbilV .* paramS.phi_sV(iSchool))
      end
   end

else
   # Copy from another experiment
   c2S = constBC.paramSet(cS.setNo, cS.expS.earnExpNo)
   param2S = filesBC.load(cS.vParams, c2S)
   paramS.tgS.pvEarn_sV = param2S.tgS.pvEarn_sV
   paramS.pvEarn_asM = param2S.pvEarn_asM
end

if cS.dbg > 10
   check_lh.check(paramS.pvEarn_asM, {"double"}, {"finite", "nonnan", "nonempty", "real", ...
      "positive", "size", [cS.nAbil, cS.nSchool]})
   # Check that log earnings gains are increasing in ability
   # Log gains by schooling
   diffM = diff(log(paramS.pvEarn_asM), 1, 2)
   # Change of those by ability
   diff2M = diff(diffM)
   if any(diff2M(:) < -1e-3)
      disp(log(paramS.pvEarn_asM))
      error_bc1("Earnings gains decreasing in ability", cS)
   end
end

=#

## Borrowing limits
#=
  enable +++++

# Min k at start of each period (detrended)
# kMin_acM = -calibr_bc1.borrow_limits(cS)
# May be taken from base cohort
if cS.bLimitCohort < 1
   blCohort = cS.iCohort;
else
   blCohort = cS.bLimitCohort;
end
# blCohort = cS.expS.bLimitBaseCohort * cS.iRefCohort + (1 - cS.expS.bLimitBaseCohort) * iCohort
paramS.kMin_aV = tgS.kMin_acM[:, blCohort];

if cS.dbg > 10
   check_lh.check(paramS.kMin_aV, ub = 0.0,
      sizeV = (cS.ageWorkStart_sV[iCG], ));
end
=#

return nothing

end
