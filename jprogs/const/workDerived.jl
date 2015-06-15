function workDerived!(paramS :: paramAllS)

  constS = paramS.constS;
  cS = paramS.cS;
  workS = paramS.workS;
  prefS = paramS.prefS;

  # These should go in derived param struct +++
  workS.ageWorkStart_sV = [1, 3, cS.collLength+1];
  # Length of work phase by s
  workS.workYears_sV = cS.ageMax - workS.ageWorkStart_sV + 1;


  # Consumption growth rate during work phase
  workS.gC = (prefS.beta * cS.R) ^ (1 / prefS.collSigma);
  # Growth factors for consumption by age
  workS.cFactorV = workS.gC .^ (0 : (maximum(workS.workYears_sV) - 1));

  # Present value factor
  #  Present value of consumption = c at work start * pvFactor
  #  Tested in value work
  workS.cPvFactor_sV = zeros(constS.nSchool);
  for iSchool = 1 : constS.nSchool
     workS.cPvFactor_sV[iSchool] = sum((workS.gC / cS.R) .^ (0 : (workS.workYears_sV[iSchool]-1)));
  end

  return nothing
end
