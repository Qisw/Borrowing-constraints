# -------------------  Variable numbers
type varNoParamS
  vParams :: Int
  vHhSolution :: Int
  vAggregates :: Int
  vPreambleData :: Int
  vCalResults :: Int

  vCalDev :: Int
  vCpi  :: Int
  vCollCosts  :: Int
  vCalTargets  :: Int
  vCohortEarnProfiles :: Int

  vCohortSchooling  :: Int
  vStudentDebtData :: Int
end

function varNoParamS()
  varNoS = varNoParamS(1,1,1,1,1,   1,1,1,1,1,   1,1);
  # Calibrated parameters
  varNoS.vParams = 1

  # Hh solution
  varNoS.vHhSolution = 2

  # Aggregates
  varNoS.vAggregates = 3

  # Preamble data
  varNoS.vPreambleData = 5

  # Calibration results
  varNoS.vCalResults = 6

  # Intermediate results from cal_dev
  #  so that interrupted calibration can be continued
  varNoS.vCalDev = 7


  ##  Variables that are always saved / loaded for base expNo
  #  varNo 400-499

  # CPI; base year = 1
  varNoS.vCpi = 401

  # College costs; base year prices
  varNoS.vCollCosts = 402

  # Calibration targets
  varNoS.vCalTargets = 403

  # Cohort earnings profiles (data)
  varNoS.vCohortEarnProfiles = 404

  varNoS.vCohortSchooling = 405

  # Avg student debt by year
  varNoS.vStudentDebtData = 406;

  return varNoS;
end
