# Default: which params are calibrated
#=
List all potentially calibrated params
Sets or experiments can override these defaults

To unpack
Pop each element from the list of calibrated params returned by pvector_lh
Assign with an if to the right parameter
(or assign using metaprogramming; replacing symbol with the right param struct)
=#
function calibratedParams()
  # Set up a pvector object
  pv = pvector_lh.pvector();

  # ---------  Preferences

  # Discount factor
  ps = pstruct_lh.pstruct(:prefS_beta, "\beta", "Discount factor",
    0.98, 0.8, 1.1, :calNever);
  pvector_lh.add!(pv, ps);

  # Weight on u(c) at work. To prevent overconsumption
  ps = pstruct_lh.pstruct(:prefS_workWt, "\omega_{w}", "Weight on u(c) at work",
    3.0, 1.0, 10.0, :calBase);
    pvector_lh.add!(pv, ps);
  # Same for college. Normalize to 1
  ps = pstruct_lh.pstruct(:prefS_collWt, "\omega_{c}", "Weight on u(c)",
    1.0, 0.01, 1.1, :calNever);
  pvector_lh.add!(pv, ps);
  # Curvature of u(c)
  ps = pstruct_lh.pstruct(:prefS_collSigma, "\varphi_{c}", "Curvature of utility",
    2.0, 1.0, 5.0, :calNever);
  pvector_lh.add!(pv, ps);
  # Curvature of u(leisure)
  ps = pstruct_lh.pstruct(:prefS_collRho, "\varphi_{l}", "Curvature of utility",
    2.0, 1.0, 5.0, :calNever);
  pvector_lh.add!(pv, ps);
  # Weight on leisure
  ps = pstruct_lh.pstruct(:prefS_collWtLeisure, "\omega_{l}", "Weight on leisure",
    0.5, 0.01, 5.0, :calBase);
  pvector_lh.add!(pv, ps);

  # add more from defaultParams.jl +++++

  return pv

end
