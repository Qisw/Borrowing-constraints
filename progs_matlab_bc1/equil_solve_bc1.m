function [hhS, aggrS] = equil_solve_bc1(paramS, cS)
% Solve for equilibrium given params
%{
%}

if isempty(paramS)
   paramS = param_load_bc1(cS.setNo, cS.expNo);
end

hhS = hh_bc1.hh_solve(paramS, cS);
% var_save_bc1(hhS, cS.vHhSolution, cS);

aggrS = aggr_bc1.aggregates(hhS, paramS, cS);
% var_save_bc1(aggrS, cS.vAggregates, cS);

end