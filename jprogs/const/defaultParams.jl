function defaultParams()
#=
Set default params
Only for non-derived params

For each group of params:
1. allocate a type
2. fill in the non-derived values
Leave derived fields at nonsense values
=#

# Constants
constS = constParamS();
# 1 = $unitAcct
# cS.unitAcct = 1000.0;

# Miscellaneous
cS = miscParamS();

# Preferences
prefS = prefParamS();

# Work
pWorkS = workParamS();

endowS = endowParamS();
spS = schoolParamS();
tgS = calTgS();

dirS = dirParamS();
varNoS = varNoParamS();
pVector = calibratedParams();

# Collect all params here
paramS = paramAllS(constS, cS, prefS, pWorkS,   endowS, spS, tgS, dirS,
  varNoS, pVector);

return paramS;

end



#=

# Parental preferences
cS[:pvector] = cS[:pvector].change("puSigma', '\varphi_{p}', 'Curvature of parental utility", 0.35, 0.1, 5, cS[:calBase])
# Time varying: to match transfer data
cS[:pvector] = cS[:pvector].change("puWeight', '\omega_{p}', 'Weight on parental utility", 1, 0.001, 2, cS[:calBase])

# Pref shock at entry. For numerical reasons only. Fixed.
cS[:pvector] = cS[:pvector].change("prefScaleEntry', '\gamma', 'Preference shock at college entry", 0.1, 0.05, 1, cS[:calNever])
# Pref for working as HSG. Includes leisure. No good scale. +++
#  Calibrate in experiment to match schooling average
cS[:pvector] = cS[:pvector].change("prefHS', '\bar{\eta}', 'Preference for HS", 0, -5, 10, cS[:calBase])
# # Tax on HS earnings (a preference shock). 2 parameters. Intercept and slope. Both in (-1,1)
# cS[:pvector] = cS[:pvector].change("taxHSzero', '\tau{0}', 'Tax on college earnings",   0, -0.6, 0.6, cS[:calNever])
# cS[:pvector] = cS[:pvector].change("taxHSslope',  '\tau{1}', 'Tax on college earnings", 0, -0.8, 0.8, cS[:calNever])


# Endowment correlations
cS[:pvector] = cS[:pvector].change("alphaPY', '\alpha_{p,y}', 'Correlation, $p,y$", 0.3, -5, 5, cS[:calBase])
cS[:pvector] = cS[:pvector].change("alphaPM', '\alpha_{p,m}', 'Correlation, $p,m$", 0.4, -5, 5, cS[:calBase])
cS[:pvector] = cS[:pvector].change("alphaYM', '\alpha_{y,m}', 'Correlation, $y,m$", 0.5, -5, 5, cS[:calBase])
# Does not matter right now. Until we have a direct role for ability
#  But want to be able to change signal precision (rather than grad prob function) for experiments
cS[:pvector] = cS[:pvector].change("alphaAM', '\alpha_{a,m}', 'Correlation, $a,m$", 2, 0.1, 5, cS[:calBase])


# Marginal distributions
cS[:pvector] = cS[:pvector].change("pMean', '\mu_{p}', 'Mean of $p$", ...
   (5e3 ./ cS[:unitAcct]), (-5e3 ./ cS[:unitAcct]), (1.5e4 ./ cS[:unitAcct]), cS[:calBase])
cS[:pvector] = cS[:pvector].change("pStd', '\sigma_{p}', 'Std of $p$", 2e3 ./ cS[:unitAcct], ...
   5e2 ./ cS[:unitAcct], 1e4 ./ cS[:unitAcct], cS[:calBase])

# This will be taken directly from data (so not calibrated)
#  but is calibrated for other cohorts
cS[:pvector] = cS[:pvector].change("logYpMean', '\mu_{y}', 'Mean of $\log(y_{p})$", ...
   log(5e4 ./ cS[:unitAcct]), log(5e3 ./ cS[:unitAcct]), log(5e5 ./ cS[:unitAcct]), cS[:calNever])
# Assumed time invariant
cS[:pvector] = cS[:pvector].change("logYpStd', '\sigma_{y}', 'Std of $\log(y_{p})$", 0.3, 0.05, 0.6, cS[:calNever])

cS[:pvector] = cS[:pvector].change("sigmaIQ', '\sigma_{IQ}', 'Std of IQ noise",  0.35, 0.2, 2, cS[:calBase])



cS[:pvector] = cS[:pvector].change("prGradMin', '\pi_{0}', 'Min $\pi_{a}$", 0.1, 0.01, 0.5, cS[:calBase])
cS[:pvector] = cS[:pvector].change("prGradMax', '\pi_{1}', 'Max $\pi_{a}$", 0.8, 0.7, 0.99, cS[:calBase])
cS[:pvector] = cS[:pvector].change("prGradMult', '\pi_{a}', 'In $\pi_{a}$", 0.7, 0.1, 5, cS[:calBase])
cS[:pvector] = cS[:pvector].change("prGradExp', '\pi_{b}', 'In $\pi_{a}$",  1, 0.1, 5, cS[:calBase])
cS[:pvector] = cS[:pvector].change("prGradPower', '\pi_{c}', 'In $\pi_{a}$", 1, 0.1, 2, cS[:calNever])
cS[:pvector] = cS[:pvector].change("prGradABase', 'a_{0}', 'In $\pi_{a}$", 0, 0, 0.3, cS[:calNever])


cS[:pvector] = cS[:pvector].change("wCollMean', 'Mean w_{coll}', 'Maximum earnings in college", ...
   2e4 ./ cS[:unitAcct], 5e3 ./ cS[:unitAcct], 1e5 ./ cS[:unitAcct], cS[:calBase])


   cS[:pvector] = cS[:pvector].change("phiHSG', '\phi_{HSG}', 'Return to ability, HSG", 0.155,  0.02, 0.2, cS[:calNever])
   cS[:pvector] = cS[:pvector].change("phiCG',  '\phi_{CG}',  'Return to ability, CG",  0.194, 0.02, 0.2, cS[:calNever])

   # Scale factors of lifetime earnings (log)
   cS[:pvector] = cS[:pvector].change("eHatCD', '\hat_{e}_{CD}', 'Log skill price CD", 0, -3, 1, cS[:calBase])
   cS[:pvector] = cS[:pvector].change("dEHatHSG', 'd\hat_{e}_{HSG}', 'Skill price gap HSG", -0.1, -3, 0, cS[:calBase])
   cS[:pvector] = cS[:pvector].change("dEHatCG',  'd\hat_{e}_{CG}',  'Skill price gap CG",   0.1,  0, 3, cS[:calBase])
   # cS[:pvector] = cS[:pvector].change("eHatCG',  '\hat_{e_{CG}}',  'Log skill price CG",  -1, -4, 1, cS[:calBase])

   if cS[:abilAffectsEarnings] == 0
      cS[:pvector] = cS[:pvector].change("phiHSG', '\phi_{HSG}', 'Return to ability, HSG", 0,  0.02, 0.2, cS[:calNever])
      cS[:pvector] = cS[:pvector].change("phiCG',  '\phi_{CG}',  'Return to ability, CG",  0, 0.02, 0.2, cS[:calNever])
      cS[:pvector] = cS[:pvector].change("eHatCD", [], [], 0, [], [], cS[:calNever])
      cS[:pvector] = cS[:pvector].change("dEHatHSG", [], [], 0, [], [], cS[:calNever])
      cS[:pvector] = cS[:pvector].change("dEHatCG", [], [], 0, [], [], cS[:calNever])
   end

=#
