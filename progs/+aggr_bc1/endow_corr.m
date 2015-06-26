function outS = endow_corr(paramS, cS)
% Endowment correlations, by simulation

[abilV, jV, iqV] = calibr_bc1.endow_sim(1e4, paramS, cS);

% Correlation matrix
outS.varNameV = {'$a$', '$m$', '$IQ$', '$p$', '$\ln(y)$'};
outS.iAbil = 1;
outS.iSignal = 2;
outS.iIq = 3;
outS.iCost = 4;
outS.iYp = 5;

outS.corrM = corrcoef([abilV, paramS.m_jV(jV), iqV, paramS.pColl_jV(jV), log(paramS.yParent_jV(jV))]);

   
end
