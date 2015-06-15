function aggr_show(saveFigures, setNo, expNo)

cS = const_bc1(setNo, expNo);
figS = const_fig_bc1;
paramS = param_load_bc1(setNo, expNo);
% hhS = var_load_bc1(cS.vHhSolution, cS);
aggrS = var_load_bc1(cS.vAggregates, cS);

outFn = fullfile(cS.outDir, 'aggr_stats.txt');
fp = fopen(outFn, 'w');

debt_stats(fp, aggrS, paramS, cS);

fclose(fp);
type(outFn);

end



%% Debt stats computed both ways
function debt_stats(fp, aggrS, paramS, cS)
   fprintf(fp, 'Debt stats computed both ways \n');

   fprintf(fp, '  Fraction in debt by IQ: \n');
   fprintf(fp, '    Transfer paid out t=1:     ');
   fprintf(fp, '%6.2f', aggrS.debtFrac_qV);
   fprintf(fp, '\n');
   fprintf(fp, '    Transfer paid out each t:  ');
   fprintf(fp, '%6.2f', aggrS.debtFracTrue_qV);
   fprintf(fp, '\n');
   
   fprintf(fp, '  Mean in debt by IQ: \n');
   fprintf(fp, '    Transfer paid out t=1:     ');
   fprintf(fp, '%6.1f', aggrS.debtMean_qV);
   fprintf(fp, '\n');
   fprintf(fp, '    Transfer paid out each t:  ');
   fprintf(fp, '%6.1f', aggrS.debtMeanTrue_qV);
   fprintf(fp, '\n');

   fprintf(fp, '  Fraction in debt by yp: \n');
   fprintf(fp, '    Transfer paid out t=1:     ');
   fprintf(fp, '%6.2f', aggrS.debtFrac_yV);
   fprintf(fp, '\n');
   fprintf(fp, '    Transfer paid out each t:  ');
   fprintf(fp, '%6.2f', aggrS.debtFracTrue_yV);
   fprintf(fp, '\n');
   
   fprintf(fp, '  Mean in debt by yp: \n');
   fprintf(fp, '    Transfer paid out t=1:     ');
   fprintf(fp, '%6.1f', aggrS.debtMean_yV);
   fprintf(fp, '\n');
   fprintf(fp, '    Transfer paid out each t:  ');
   fprintf(fp, '%6.1f', aggrS.debtMeanTrue_yV);
   fprintf(fp, '\n');
end

