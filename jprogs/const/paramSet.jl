function paramSet(setNo, expNo)
# Set all (non-calibrated) parameters
#=
Also specifies default values for calibrated parameters

how to ensure that derived params are automatically correct +++++
=#

# Initialize all at defaults
paramS = defaultParams();
# Set all derived params (that do not depend on anything calibrated)
# derivedAll!(paramS);

# Unpack
# this does not copy sub-types; it just creates pointers
# so we modify paramS below
constS = paramS.constS;
cS = paramS.cS;

if isempty(setNo)
   setNo = constS.setDefault;
end
if isempty(expNo)
   expNo = constS.expBase;
end
cS.setNo = setNo;
cS.expNo = expNo;
cS.setStr = displayLH.sprintf("set%03i", [setNo]);
cS.expStr = displayLH.sprintf("exp%03i", [expNo])

# cS[:missVal] = -9191
# cS[:pauseOnError] = 1
# How often to run full debug mode during calibration?



## --------------   Parameter sets

if setNo == constS.setDefault
   cS.setStr = "Default"
   cS.iCohort = cS.iRefCohort;

elseif setNo == 2
   cS.setStr = "Ability does not affect earnings";
   cS.abilAffectsEarnings = false;

elseif setNo == 3
   # For testing. Calibrate to another cohort
   cS.setStr = "Test with another cohort";
   cS.iCohort = indmin(abs(cS.bYearV - 1940));

else
   error("Invalid")
end


# Experiment settings
experSettings!(expNo,  paramS);

# Impose all derived params
# derivedAll!(paramS);

return paramS
end
