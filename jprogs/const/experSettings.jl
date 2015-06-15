function experSettings!(expNo :: Int,  paramS :: paramAllS)
## Experiment settings
#=
This modifies elements of paramS

By default; non-calibrated params are copied from base expNo
Can override this by setting switches such as cS.earnExpNo]
Then pvEarn_asM is taken from that experiment (which would usually be the experiment
that calibrates everything for a particular cohort)
=#

constS = paramS.constS;
cS = paramS.cS;


# ******* Base experiments: calibrate everything to match all target
if expNo < 100
   if expNo == constS.expBase;
      cS.expStr = "Baseline";
      # Parameters with these values of doCal are calibrated
      cS.doCalV = [:calBase];
      cS.iCohort = cS.iRefCohort;

   else
      error("Invalid")
   end


# *******  Counterfactuals
# Nothing is calibrated. Just run exper_bc1
# Params are copied from base
elseif expNo < 200
   cS.doCalibrate = false;
   # Irrelevant
   cS.doCalV = [:calExp];
   # Taking parameters from this cohort
   cS.iCohort = cS.iRefCohort;

   # Pick out cohort from which counterfactuals are taken
   if expNo < 110
      cfBYear = 1940;   # Project talent
   elseif expNo < 120
      cfBYear = 1915;   # Updegraff
   else
      error("Invalid")
   end

   # Taking counterfactuals from this cohort (expNo)
   cfCohort = idxmin(abs(cS.bYearV - cfBYear));
   cfExpNo = cS.bYearExpNoV[cfCohort];

   if any(expNo .== [103, 113])
      cS.expStr = "Replicate base exper";    # for testing
      # Irrelevant
      cS.doCalV = [:calExp];
      cS.earnExpNo = constS.expBase;
      cS.bLimitCohort = cS.iCohort;
      cS.collCostExpNo = constS.expBase;

   elseif any(expNo .== [104, 114])
      cS.expStr = "Only change earn profiles";
      cS.earnExpNo = cfExpNo;

   elseif any(expNo .== [105, 115])
      cS.expStr = "Only change bLimit";    # when not recalibrated
      cS.bLimitCohort = cfCohort;

   elseif any(expNo .== [106, 116])
      # Change college costs
      cS.expStr = "College costs";
      # Need to calibrate everything for that cohort. Then impose pMean from there
      cS.collCostExpNo = cfExpNo;

   else
      error("Invalid")
   end


# ********  Calibrated experiments
# A subset of params is recalibrated. The rest is copied from baseline
elseif expNo < 300
   # Now fewer parameters are calibrated
   cS.doCalV = [:calExp];
   # Calibrate pMean; which is really a truncated data moment
   #  Should also do something about pStd +++
  #  cS.pvector] = cS.pvector].calibrate("pMean", cS.calExp])

   if any(expNo == cS.bYearExpNoV)
      # ******  Calibrate all time varying params
      cS.iCohort = findfirst(expNo .== cS.bYearExpNoV);
      cS.expStr = "Cohort  $(cS.bYearV[cS.iCohort])";

      # Signal noise
      # cS.pvector] = cS.pvector].calibrate("alphaAM", cS.calExp])
      # Match transfers
      # cS.pvector] = cS.pvector].calibrate("puWeight", cS.calExp])
      # Match overall college entry
      # cS.pvector] = cS.pvector].calibrate("prefHS", cS.calExp])
      # cS.pvector] = cS.pvector].calibrate("wCollMean", cS.calExp])


   elseif expNo == 211
      # This changes earnings; borrowing limits; pMean
      error("Not updated"); # +++++
      # cS.expStr] = "Only change observables";
      # cS.iCohort] = cS.iRefCohort] - 1;  # make one for each cohort +++
#       # Take all calibrated params from base
#       for i1 = 1 : cS.pvector].np
#          ps = cS.pvector].valueV{i1}
#          if ps.doCal == cS.calExp]
#             # Do not calibrate; but take from base exper
#             cS.pvector] = cS.pvector].calibrate(ps.name, cS.calBase])
#          end
#       end
      #cS.pvector] = cS.pvector].calibrate("logYpMean", cS.calExp])

   else
      error("Invalid")
   end

else
   error("Invalid")
end

return nothing

end
