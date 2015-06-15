# ---------------  Calibration targets to use
# These are targets we would like to match. Targets that are NaN are ignored.
type calTgS
  # PV of lifetime earnings by schooling
  pvLty :: Bool

  # College costs
     # add target by yp +++
  pMean :: Bool
  pStd :: Bool
  pMeanIQ :: Bool
  pMeanYp :: Bool


  # ***** College outcomes
  fracS :: Bool
  # fraction entering college
  fracEnterIQ :: Bool
  # fraction graduating (not conditional on entry)
  fracGradIq  :: Bool
  fracEnterYp  :: Bool
  fracGradYp  :: Bool


  # *****  Parental income
  ypIq  :: Bool
  ypYp :: Bool


  # *****  Hours and earnings
  hours  :: Bool
  hoursIq  :: Bool
  hoursYp  :: Bool
  earn  :: Bool
  earnIq  :: Bool
  earnYp :: Bool


  # Debt at end of college by CD / CG
  debtFracS  :: Bool
  debtMeanS  :: Bool


  # Debt at end of college
  debtFracIq  :: Bool
  debtFracYp  :: Bool
  debtMeanIq  :: Bool
  debtMeanYp  :: Bool
  # Average debt per student
  debtMean  :: Bool


  # Mean transfer
  transfer  :: Bool
  transferYp  :: Bool
  transferIq :: Bool
end


# constructor
# Only need to change targets that are not calibrated
function calTgS()
  tgS = calTgS(trues(28)...)
  tgS.pMeanYp = false;

  tgS.debtFracS = false;
  tgS.debtMeanS = false;
  tgS.debtMean = false;
  return tgS
end
