function rhsV = bellman_coll3(iAbil,j, cV, hoursV, kV, hhS, paramS, cS)
% Direct implementation of Bellman equation in college, periods 3-4
%{
Returns RHS of Bellman, for all k grid points
For testing
%}

% kPrimeV = hhS.vColl3S.kPrime_kajM(:,iAbil,j);

kPrimeV = hh_bc1.coll_bc_kprime(cV, hoursV, kV, paramS.wColl_jV(j), paramS.pColl_jV(j), paramS.R, cS);

% u in college today
utilCollV = hh_bc1.hh_util_coll_bc1(cV,  1 - hoursV, ...
   paramS.prefWt, paramS.prefSigma,  paramS.prefWtLeisure, paramS.prefRho);

% Value of working as CG
vWorkFct = hhS.vWorkS.vFct_saM{cS.iCG, iAbil};

rhsV = (1 + paramS.prefBeta) .* utilCollV + (paramS.prefBeta .^ 2) .* vWorkFct(kPrimeV);


end