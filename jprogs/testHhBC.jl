module testHhBC

using check_lh
reload("constBC.jl")
using constBC
reload("hhBC.jl")
using hhBC


function test_all()
  println("\nTesting hh routines\n")
  dbg = 111;
  setNo = 1;
  expNo = 1;
  paramS = constBC.paramSet(setNo, expNo);
  test_util_college(paramS);
  hhBC.util_parent(rand(4), paramS.prefS, true);
  hhBC.util_work(rand(4), paramS.prefS, true, true, dbg);
  test_work(paramS);
  println("Done")
end


function test_util_college(paramS :: constBC.paramAllS)
  println("Testing util college")
  hhBC.util_college(rand(4), rand(4), paramS.prefS,
    true, true);
end


function test_work(paramS :: constBC.paramAllS)
  dbg = 111;
  hhBC.hh_work(1.23, 1.04, 2, 3,  paramS.prefS, paramS.workS, dbg :: Int);
end

end
