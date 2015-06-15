# Type definitions
#=
For each
- default constructor sets default param values
- function that computes derived params

All derived parameters are set in param_derived!
=#


# This holds primitives that never change
# Most efficient for scalars
immutable constParamS
  setDefault :: Int
  expBase :: Int
  unitAcct :: Float64
  # Consumption floor
  cFloor :: Float64   # = 500 ./ cS[:unitAcct]
  # Leisure floor
  lFloor :: Float64
  # Last year with data for anything
  lastDataYear :: Int
  # First year with data for anything (cpi starts in 1913)
  firstDataYear :: Int
  # Schooling
  iHSG :: Int
  iCD :: Int
  iCG :: Int
  nSchool :: Int
end

function constParamS()
  return constParamS(1, 1,   1000.0, 500.0 ./ 1000.0, 0.01,   2014, 1913,
    1,2,3,3);
end



# ---------------  Collection of unclassified params
# This also stores set specific info
type miscParamS
  dbg :: Int
  dbgFreq :: Float64;
  setNo :: Int
  expNo :: Int
  # Descriptive string
  setStr :: String
  expStr :: String

  R :: Float64

  # Cohorts modeled
  bYearV :: Vector{Int}
  yearStartCollege_cV :: Vector{Int}
  bYearExpNoV :: Vector{Int}
  # Derived
  iRefCohort :: Int
  # Calibrate for this cohort
  iCohort :: Int
  nCohorts :: Int
  age1 :: Int
  ageMax :: Int
  physAgeLast :: Int

  # College lasts this many periods
  collLength :: Int

  # Set no for cps routines
  cpsSetNo :: Int

  doCalibrate :: Bool
  doCalV :: Vector{Symbol}
  runLocal :: Bool

  earnExpNo :: Int
  collCostExpNo :: Int

  bLimitCohort :: Int


  # --------  Constructor
  # Does not initialize derived fields
  function miscParamS()
    cS = new();

    cS.dbg = 111;
    cS.dbgFreq = 0.5;
    # cS.setNo = 0;
    # cS.expNo = 0;
    # cS.setStr = "0";
    # cS.expStr = "0";

    cS.R = 1.04;

    # Cohorts
    cS.bYearV = [1915, 1940, 1961, 1979];
    # Counterfactual expNo that go with each cohort
    cS.bYearExpNoV = [203, 202, -1, -1];
    # Cross sectional calibration for this cohort
    cS.iRefCohort = findfirst(cS.bYearV .== 1961);
    cS.nCohorts = length(cS.bYearV);

    # Age at model age 1
    cS.age1 = 18;
    # Last physical age
    cS.physAgeLast = 75;

    # College lasts this many periods
    cS.collLength = 4;
    cS.cpsSetNo = 1;

    # Does this experiment require recalibration?
    cS.doCalibrate = true;
    # Parameters with these values of doCal are calibrated
    cS.doCalV = [:calBase];
    if isdir("/Users/lutz")
       cS.runLocal = true;
    else
       cS.runLocal = false;
    end

    # Which data based parameters are from baseline cohort?
    # Earnings profiles (sets targets if calibrated, otherwise takes paramS[:pvEarn_asM] from base cohort)
    cS.earnExpNo = -1;
    cS.collCostExpNo = -1;
    # expS[:ypBaseCohort] = 0
    # Cohort from which borrowing limits are taken
    cS.bLimitCohort = -1;

    return cS
  end
end


# ===================  Miscellaneous
# function miscParamS()
#   cS = miscParamS(1, 0.5,   1, 1, "set0", "exp0", 0,0,0,   1.04,
#     zeros(1), zeros(1), zeros(Int,1),
#     1,0, 1, 1, 1, 0,    0,1, true,[:calBase],true);
# end

function miscDerived!(cS :: miscParamS)
  cS.nCohorts = length(cS.bYearV);
  # Lifespan
  cS.ageMax = cS.physAgeLast - cS.age1 + 1;
  # Year each cohort start college (age 19)
  cS.yearStartCollege_cV = cS.bYearV + 18;
  # cS[:ageRetire] = cS[:physAgeRetire] - cS[:age1] + 1

  return nothing
end


# ------------------  Preferences
type prefParamS
  # College Consumption
  collSigma :: Float64
  collWt :: Float64
  # College Leisure
  collRho :: Float64
  collWtLeisure :: Float64
  # Parent
  puSigma :: Float64
  puWeight :: Float64
  # work
  beta :: Float64
  workWt :: Float64

  # pref shocks
  prefHS :: Float64
  prefScaleEntry :: Float64
end

function prefParamS()
  prefS = prefParamS(1.0, 1.0, 1.0, 1.0,   1.0, 1.0, 1.0, 1.0,   1.0,1.0);
  prefS.collSigma = 2.0;
  prefS.collWt = 1.0;
  prefS.collRho = 2.0;
  prefS.collWtLeisure = 0.5;
  prefS.puSigma = 0.35;
  prefS.puWeight = 1.0;
  prefS.beta = 0.98;
  prefS.workWt = 3.0;
  prefS.prefHS = 0.0;
  prefS.prefScaleEntry = 0.1;
  return prefS
end


# ------------------------  Work
type workParamS
  abilAffectsEarnings :: Bool

  phiHSG :: Float64
  phiCG :: Float64
  eHatCD :: Float64
  dEHatHSG :: Float64
  dEHatCG :: Float64

  # ------ Derived
  pvEarn_asM :: Matrix{Float64}
  ageWorkStart_sV :: Vector{Int}
  workYears_sV :: Vector{Float64}
  # Consumption growth rate during work phase
  gC :: Float64
  # Growth factors for consumption by age
  cFactorV :: Vector{Float64}
  # Present value factor
  #  Present value of consumption = c at work start * pvFactor
  cPvFactor_sV :: Vector{Float64}
end

function workParamS()
  workS = workParamS(true,    1.0,1.0,1.0,1.0,1.0,
  zeros(1,1), zeros(Int,1), zeros(Int,1),  1.0,  zeros(1), zeros(1));
  workS.abilAffectsEarnings = true;

  # Earnings are determined by phi(s) * (a - aBar)
  #  phi(s) taken from gradpred
  workS.phiHSG = 0.155;
  workS.phiCG = 0.194;
  # Scale factors of lifetime earnings (log)
  workS.eHatCD = 0.0;
  workS.dEHatHSG = -0.1;
  workS.dEHatCG = 0.1;

  return workS
end



# ------------------  Endowments
type endowParamS
  # Size of ability grid
  nAbil :: Int
  # Earnings are determined by phi(s) * (a - aBar)
  #  aBar determines for which abilities earnings gains from schooling MUST be positive
  aBar :: Float64

  # Number of types
  nTypes :: Int
  # IQ groups
  iqUbV :: Vector{Float64}
  pr_iqV :: Vector{Float64}
  nIQ :: Int

  # Parental income classes
  ypUbV :: Vector{Float64}
  pr_ypV :: Vector{Float64}

  # Endowments correlations
  alphaAM :: Float64
  alphaPY :: Float64
  alphaPM :: Float64
  alphaYM :: Float64

  pMean :: Float64
  pStd :: Float64
  logYpMean :: Float64
  logYpStd :: Float64
  sigmaIQ :: Float64
  wCollMean :: Float64

  # ------  Derived
  prob_jV :: Vector{Float64}
  pColl_jV :: Vector{Float64}
  yParent_jV :: Vector{Float64}
  m_jV :: Vector{Float64}
  wColl_jV :: Vector{Float64}
  ypClass_jV :: Vector{Int}
end

function endowParamS()
  constS = constParamS();
  endowS = endowParamS(1, 0.0,  1,  zeros(1), zeros(1), 1, zeros(1), zeros(1),
    1.0,1.0,1.0,1.0,     1.0,1.0,1.0,1.0,1.0,0.0,
    zeros(1), zeros(1), zeros(1), zeros(1), zeros(1), zeros(Int,1));

  endowS.nAbil = 9;
  endowS.aBar = -3.0; # how to set this? +++++

  endowS.nTypes = 80;

  # IQ groups
  endowS.iqUbV = [0.25 : 0.25 : 1];
  endowS.nIQ = length(endowS.iqUbV);

  # Parental income classes
  endowS.ypUbV = [0.25 : 0.25 : 1];

  endowS.alphaAM = 2.0;
  endowS.alphaPY = 0.4;
  endowS.alphaPM = 0.4;
  endowS.alphaYM = 0.4;

  endowS.pMean = 15000.0 / constS.unitAcct;
  endowS.pStd  = 2000.0 / constS.unitAcct;
  endowS.logYpMean  = log(5e4 ./ constS.unitAcct);
  endowS.logYpStd = 0.3;
  endowS.sigmaIQ = 0.35;
  endowS.wCollMean  = 20000.0 / constS.unitAcct;

  # endowDerived!(endowS);
  return endowS;
end

# function endowDerived!(endowS :: endowParamS)
# end



# ---------------------  Schooling
type schoolParamS
  # Parameters governing probGrad(a)
     # One of these has to be time varying
  prGradMin :: Float64
  prGradMax :: Float64
  prGradMult :: Float64
  prGradExp :: Float64
  prGradPower :: Float64
  prGradABase :: Float64
end

function schoolParamS()
  constS = constParamS();
  spS = schoolParamS(1.0,1.0,1.0,1.0,1.0,1.0);

  spS.prGradMin = 0.1;
  spS.prGradMax = 0.8;
  spS.prGradMult = 0.7;
  spS.prGradExp = 1.0;
  spS.prGradPower = 1.0;
  spS.prGradABase = 0.0;

  return spS
end

# function schoolDerived!(spS :: schoolParamS, cS :: miscParamS)
#   return nothing
# end


# Collects all params
type paramAllS
  constS :: constParamS
  cS :: miscParamS
  prefS :: prefParamS
  workS :: workParamS
  endowS :: endowParamS
  spS :: schoolParamS
  tgS :: calTgS
  dirS :: dirParamS
  varNoS :: varNoParamS
  pVectorS :: pvector_lh.pvector
end

# function paramAllS()
#   return paramAllS(constS, cS, prefS, workS, endowS);
# end


# ---------  Set all derived params
# function derivedAll!(paramS :: paramAllS)
#   miscDerived!(paramS.cS);
#   workDerived!(paramS.workS, paramS.cS);
#   endowDerived!(paramS.endowS);
#   # schoolDerived!(paramS.spS, paramS.cS);
#   return nothing
# end
