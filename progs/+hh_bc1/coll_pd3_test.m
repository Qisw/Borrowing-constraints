function coll_pd3_test(setNo)
% Syntax test only

expNo = 1;
cS = const_bc1(setNo, expNo);
cS.dbg = 111;
paramS = param_load_bc1(setNo, expNo); 

nk = 100;
kV = linspace(-3, 5, nk);
wColl = 1.2;
pColl = 2.3;
kMin = -4;
j = 10;

evWorkFct = griddedInterpolant(kV, kV .^ (1 - 2) ./ (1-2), 'linear', 'linear');

[c_kV, hours_kV, kPrime_kV, vColl_kV] = hh_bc1.coll_pd3(kV, wColl, pColl, kMin, evWorkFct, j, paramS, cS);

end