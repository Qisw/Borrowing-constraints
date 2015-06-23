function corr_iq_yp(setNo)
% Compute correlation of iq and fam income
% For all samples

cS = const_bc1(setNo);

entryDir = '/Users/lutz/Dropbox/borrowing constraints/data/income x iq x college';
dirV = dir(fullfile(entryDir, '*.csv'));

optS = optimset('fminsearch');
optS.TolFun = 1e-5;
optS.TolX = 1e-5;


% Nlsy 79
if 01
   for iCase = 1 : 2
      if iCase == 1
         fnStr = 'nlsy79';
         % Data from Belley / Lochner
         outS.perc_qyM = [12.8 6.3 3.6 2.4; 
            6.4 6.8 6.3 5.4;
            4.0 6.6 7.4 7.2;
            2.2 4.6 8.0 10.0]';
      elseif iCase == 2
         fnStr = 'nlsy97';
         outS.perc_qyM = [9.7  6  4.1  2.6;
            6.6  6.8  6.2  5.8;
            4.1  6.3  7.4  8;
            2.4  5.9  7.5  10.4]';
      else
         error('Invalid');
      end
      
      outS.perc_qyM = outS.perc_qyM ./ sum(outS.perc_qyM(:));
      outS.ypUbV = (0.25 : 0.25 : 1)';
      outS.iqUbV = (0.25 : 0.25 : 1)';

      nyp = length(outS.ypUbV);
      niq = length(outS.iqUbV);

      if (niq >= 4)  &&  (nyp >= 4)
         % Values that go with each yp upper bound
         ypValueV = [-10; norminv(outS.ypUbV)];
         ypValueV(end) = 10;
         iqValueV = [-10; norminv(outS.iqUbV)];
         iqValueV(end) = 10;

         [corrOpt, fVal, exitFlag] = fminsearch(@devfct, 0.3, optS);

         fprintf('%s \n',  fnStr);
         fprintf('    nIq: %i    nYp: %i    Correlation: %.2f \n', ...
            niq, nyp, corrOpt);
      end
   end
end


for iFile = 1 : length(dirV)   
   % Read the data file (college entry rates)
   fnStr = dirV(iFile).name;
   if ~strcmpi(fnStr, 'flanagan 1964.csv')  &&  ~strcmpi(fnStr, 'gardner income 1987.csv')  && ...
      ~strcmpi(fnStr, 'goetsch 1940.csv')   &&  ~strcmpi(fnStr, 'sibley 1948.csv')  &&  ...
      ~strcmpi(fnStr, 'suny 1955.csv')
      [~, outS] = data_bc1.load_income_iq_college(fnStr, setNo);

      nyp = length(outS.ypUbV);
      niq = length(outS.iqUbV);

      if (niq >= 4)  &&  (nyp >= 4)

         % Values that go with each yp upper bound
         ypValueV = [-10; norminv(outS.ypUbV)];
         ypValueV(end) = 10;
         iqValueV = [-10; norminv(outS.iqUbV)];
         iqValueV(end) = 10;


         [corrOpt, fVal, exitFlag] = fminsearch(@devfct, 0.3, optS);

         fprintf('%s \n',  fnStr);
         fprintf('    nIq: %i    nYp: %i    Correlation: %.2f \n', ...
            niq, nyp, corrOpt);
      end
   end
end

   
return


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
   if max(abs(prSumV(:) - diff([0; outS.ypUbV])) > 1e-5)
      error_bc1('Invalid sum', cS);
   end
   prSumV = sum(prob_qyM, 2);
   if max(abs(prSumV(:) - diff([0; outS.iqUbV])) > 1e-5)
      error_bc1('Invalid sum', cS);
   end

   % Compute likelihood (actually: sum of squared deviations between prob matrices)
   %  not optimal
   dev = sum((outS.perc_qyM(:) - prob_qyM(:)) .^ 2) .* 100;
end

end