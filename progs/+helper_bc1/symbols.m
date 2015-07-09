function outS = symbols
% Return struct with latex strings for symbols
% To make notation consistent
% Each field name must be a valid latex command!


%% Demographics

outS.age = 'a';
outS.ageMax = 'A';


%% Endowments

outS.ability = 'x';
outS.famIncome = 'y_{p}';
outS.cColl = '\bar{c}';
outS.lColl = '\bar{l}';
outS.IQ = 'AFQT';
outS.collCost = '\tau';
outS.abilSignal = 'm';


%% Work

outS.pvEarn = 'Y';


%% College 

outS.prGradParam = '\pi';
% Length of schooling
outS.tSchool = 'A_{s}';
outS.collLength = 'A_{CG}';
outS.prefShockEntry = '\eta';
% Parental transfer
outS.pTransfer = 'z';
% Wage while in college
outS.collegeWage = 'w_{coll}';


%% Data

outS.betaIq = '\beta_{A}';
outS.betaYp = '\beta_{F}';



end