function aggr_show(saveFigures, setNo, expNo)

cS = const_bc1(setNo, expNo);
figS = const_fig_bc1;
paramS = param_load_bc1(setNo, expNo);
% hhS = var_load_bc1(cS.vHhSolution, cS);
aggrS = var_load_bc1(cS.vAggregates, cS);

outFn = fullfile(cS.outDir, 'aggr_stats.txt');
fp = fopen(outFn, 'w');

fprintf(fp, '\nAggregate statistics\n');

debt_stats(fp, aggrS, paramS, cS);
financial_stats(fp, aggrS, cS);

fclose(fp);
type(outFn);

end



%% Financial stats
function financial_stats(fp, aggrS, cS)
   fprintf(fp, '\nFinancial stats\n');
   fprintf(fp, '  Fraction of spending paid by earnings: %.2f   debt: %.2f   transfers: %.2f \n', ...
      aggrS.finS.fracEarnings, aggrS.finS.fracDebt, aggrS.finS.fracTransfers);
end


%% Debt stats computed both ways
function debt_stats(fp, aggrS, paramS, cS)
   fprintf(fp, '\nDebt stats computed both ways \n');

   fprintf(fp, '  Fraction in debt by IQ: \n');
   fprintf(fp, '    Transfer paid out t=1:     ');
   fprintf(fp, '%6.2f', aggrS.debtEndOfCollegeS.frac_qV);
   fprintf(fp, '\n');
   fprintf(fp, '    Transfer paid out each t:  ');
   fprintf(fp, '%6.2f', aggrS.iqS.debtAltFrac_qV);
   fprintf(fp, '\n');
   
   fprintf(fp, '  Mean in debt by IQ: \n');
   fprintf(fp, '    Transfer paid out t=1:     ');
   fprintf(fp, '%6.1f', aggrS.debtEndOfCollegeS.mean_qV);
   fprintf(fp, '\n');
   fprintf(fp, '    Transfer paid out each t:  ');
   fprintf(fp, '%6.1f', aggrS.iqS.debtAltMean_qV);
   fprintf(fp, '\n');

   fprintf(fp, '  Fraction in debt by yp: \n');
   fprintf(fp, '    Transfer paid out t=1:     ');
   fprintf(fp, '%6.2f', aggrS.debtEndOfCollegeS.frac_yV);
   fprintf(fp, '\n');
   fprintf(fp, '    Transfer paid out each t:  ');
   fprintf(fp, '%6.2f', aggrS.debtAltS.debtFrac_yV);
   fprintf(fp, '\n');
   
   fprintf(fp, '  Mean in debt by yp: \n');
   fprintf(fp, '    Transfer paid out t=1:     ');
   fprintf(fp, '%6.1f', aggrS.debtEndOfCollegeS.mean_yV);
   fprintf(fp, '\n');
   fprintf(fp, '    Transfer paid out each t:  ');
   fprintf(fp, '%6.1f', aggrS.debtAltS.debtMean_yV);
   fprintf(fp, '\n');
end

