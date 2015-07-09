function temp2

cS = const_bc1(7);

probEntry_qyM = load('/Users/lutz/Dropbox/borrowing constraints/Calibration/July 2015/Results/attend_college_byses_and_byafqt');
probEntry_qyM = probEntry_qyM';

probEntry_qyM

mass_qyM = load('/Users/lutz/Dropbox/borrowing constraints/Calibration/July 2015/Results/hsgrad_dist_byses_and_byafqt');
mass_qyM = mass_qyM';

mass_qyM


[betaIq, betaYp] = results_bc1.regress_qy(probEntry_qyM, mass_qyM, cS.iqUbV, cS.ypUbV, 111)

end