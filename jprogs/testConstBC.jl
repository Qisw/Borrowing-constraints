module testConstBC

reload( joinpath(Main.cJuliaProgDir, "pstruct_lh.jl"))
using check_lh
reload( joinpath(Main.cJuliaProgDir, "displayLH.jl"));
using displayLH

reload("constBC.jl")
using constBC

function test_all()
  paramS = constBC.paramSet(1,1);
  constBC.param_derived!(paramS);

  return paramS
end

end
