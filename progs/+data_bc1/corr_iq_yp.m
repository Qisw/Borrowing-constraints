function corr_iq_yp(setNo)
% Compute correlation of iq and fam income
% For all samples
%{
Change: write output to a file
%}

cS = const_bc1(setNo);

dirV = dir(fullfile(cS.studyEntryDir, '*.csv'));



%% Test by sim
if 0
   dbg = 111;
   rng(34);
   n = 1e3;
   xV = randn(n,1);
   yV = xV + 2 .* randn(n,1);
   trueCorr = corrcoef([xV, yV]);
   trueCorr = trueCorr(1,2);
   fprintf('True correlation: %.3f \n',  trueCorr);
   
   % Percentile upper bounds
   xUbV = (0.25 : 0.25 : 1)';
   xClV = distrib_lh.class_assign(xV, [], xUbV, dbg);
   yUbV = (0.2 : 0.2 : 1)';
   yClV = distrib_lh.class_assign(yV, [], yUbV, dbg);
   
   if unique(xClV) ~= (1 : length(xUbV))'
      error('Wrong x classes');
   end
   if unique(yClV) ~= (1 : length(yUbV))'
      error('Wrong y classes');
   end
   
   cnt_xyM = crosstab(xClV, yClV);
   pcnt_xyM = cnt_xyM ./ sum(cnt_xyM(:));
   
   optimize(pcnt_xyM, xUbV, yUbV)
   
   return;  
end


%% Nlsy 79
if 01
   for iCase = 1 : 2
      if iCase == 1
         fnStr = 'nlsy79';
         % Data from Belley / Lochner
         perc_qyM = [12.8 6.3 3.6 2.4; 
            6.4 6.8 6.3 5.4;
            4.0 6.6 7.4 7.2;
            2.2 4.6 8.0 10.0]';
      elseif iCase == 2
         fnStr = 'nlsy97';
         perc_qyM = [9.7  6  4.1  2.6;
            6.6  6.8  6.2  5.8;
            4.1  6.3  7.4  8;
            2.4  5.9  7.5  10.4]';
      else
         error('Invalid');
      end
      
      perc_qyM = perc_qyM ./ sum(perc_qyM(:));
      ypUbV = (0.25 : 0.25 : 1)';
      iqUbV = (0.25 : 0.25 : 1)';

      fprintf('%s \n',  fnStr);
      optimize(perc_qyM, iqUbV, ypUbV);
   end
end


%% Other datasets
for iFile = 1 : length(dirV)   
   % Read the data file (college entry rates)
   fnStr = dirV(iFile).name;
   if ~strcmpi(fnStr, 'gardner income 1987.csv')  &&  ~strcmpi(fnStr, 'goetsch 1940.csv') ...
      &&  ~strcmpi(fnStr, 'suny 1955.csv')
%          &&  ~strncmpi(fnStr, 'updegraff_quart', 13)
%          &&  ~strcmpi(fnStr, 'sibley 1948.csv')  &&  ...
%       
      fprintf('Loading %s \n',  fnStr);
      [~, entryS] = data_bc1.load_income_iq_college(fnStr, setNo);

      nyp = length(entryS.ypUbV);
      niq = length(entryS.iqUbV);

      if (niq >= 4)  &&  (nyp >= 4)  &&  (entryS.ypUbV(1) < 0.5)  &&  (entryS.iqUbV(1) < 0.5)
         fprintf('%s \n',  fnStr);
         optimize(entryS.perc_qyM, entryS.iqUbV, entryS.ypUbV);
         
         % Also estimate betaIq, and betaYp
         %  Not a big difference whether or not weights are used
         [betaIq, betaYp] = results_bc1.regress_qy(entryS.perc_coll_qyM, entryS.perc_qyM, ...
            entryS.iqUbV(:), entryS.ypUbV(:), cS.dbg);
         fprintf('  Data:  betaIq: %.3f    betaYp: %.3f \n',  betaIq, betaYp);
         
      end
   end
end

   
end



%% Local: optimization
function corrOpt = optimize(perc_qyM, iqUbV, ypUbV)
   nyp = length(ypUbV);
   niq = length(iqUbV);

   % Values that go with each yp upper bound
   ypValueV = [-10; norminv(ypUbV)];
   ypValueV(end) = 10;
   iqValueV = [-10; norminv(iqUbV)];
   iqValueV(end) = 10;


   optS = optimset('fminsearch');
   optS.TolFun = 1e-5;
   optS.TolX = 1e-5;
   [corrOpt, fVal, exitFlag] = fminsearch(@devfct, 0.3, optS);

%    fprintf('%s \n',  fnStr);
   fprintf('    nIq: %i    nYp: %i    Correlation: %.2f \n', ...
      niq, nyp, corrOpt);
   
   return;


%% Nested: deviation function
function dev = devfct(corr1)
   if corr1 > 0.8  ||  corr1 < -0.8
      dev = 1e6;
      return 
   end
   
   sigmaM = [1, corr1; corr1, 1];

   % Compute probabilities in each interval
   prob_qyM = zeros([niq, nyp]);
   for i1 = 1 : nyp
      for i2 = 1 : niq
         prob_qyM(i2, i1) = mvncdf([iqValueV(i2), ypValueV(i1)],  [iqValueV(i2+1), ypValueV(i1+1)], ...
            [0, 0],  sigmaM);
      end
   end

   % Check that marginals are right
   prSumV = sum(prob_qyM);
   if max(abs(prSumV(:) - diff([0; ypUbV])) > 1e-5)
      error_bc1('Invalid sum', cS);
   end
   prSumV = sum(prob_qyM, 2);
   if max(abs(prSumV(:) - diff([0; iqUbV])) > 1e-5)
      error_bc1('Invalid sum', cS);
   end

   % Compute likelihood (actually: sum of squared deviations between prob matrices)
   %  not optimal
   dev = sum((perc_qyM(:) - prob_qyM(:)) .^ 2) .* 100;
end

end