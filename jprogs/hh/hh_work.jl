function hh_work(k :: FloatingPoint, R :: FloatingPoint, iSchool :: Integer, iAbil :: Integer,
  pPrefS :: constBC.prefParamS, pWorkS :: constBC.workParamS, dbg :: Integer)
# Household: work phase
#=
IN
  k
     initial assets
OUT
  cV
     consumption by age (during work phase)
  util
     utility = present value of u(c)
  pvEarn
     present value of lifetime earnings

Checked: 2015-Mar-19
=#

## Input check


## Main

# Present value of earnings
pvEarn = pWorkS.pvEarn_asM[iAbil, iSchool];

# # Tax on earnings (only if HSG)
# taxFactor = 1 - paramS[:tax_jV](j) * (iSchool != cS[:iHSG])
taxFactor = 1.0;

# Consumption at work start = (pv income) / pvFactor
c1 = (R * k  +  taxFactor * pvEarn) / pWorkS.cPvFactor_sV[iSchool];
T = pWorkS.workYears_sV[iSchool];
cV = c1 .* pWorkS.cFactorV[1 : T];

# Get marginal and lifetime utility
_, muV, util = hhBC.util_work(cV, pPrefS, true, true);


## Marginal value of k
# Can just assume that additional k is eaten at first date

muK = muV[1] * R;



## --------  Self test
if dbg > 10
   pvC = prvalue(cV, R);
   if abs((R * k + taxFactor * pvEarn) - pvC) > 1e-4
      error("Invalid budget constraint");
   end
end


return cV, util, muK
end
