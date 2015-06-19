function aggrS = aggregates_test(setNo)


cS = const_bc1(setNo);
expNo = cS.expNo;
cS.dbg = 111;

paramS = param_load_bc1(setNo, expNo);
% aggrS  = var_load_bc1(cS.vAggregates, cS);
hhS    = var_load_bc1(cS.vHhSolution, cS);


aggrS = aggr_bc1.aggregates(hhS, paramS, cS)

end