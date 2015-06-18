function [dev, outS, hhS, aggrS] = cal_dev(tgS, paramS, cS)
% Calibration objective function for reference cohort
%{
Checked: 2015-Apr-3
%}

% Debug or not?
%  Cannot use rand (b/c seed is always the same)
x = clock;
% Seconds
secs = x(6);
if secs < cS.dbgFreq * 60
   cS.dbg = 111;
else
   cS.dbg = 1;
end
if secs < 60 / 2
   doShow = 1;
else
   doShow = 0;
end
% Save intermediate results
if (secs < 60 / 20)   &&  (cS.runParallel == 0)
   doSave = 1;
else
   doSave = 0;
end

% For this cohort
iCohort = cS.iCohort;

% Solve equilibrium
[hhS, aggrS] = equil_solve_bc1(paramS, cS);


%% Construct deviations from calibration targets

% Scale factor for dollar amount deviations (arbitrary)
dollarFactor = 25 ./ (35000 ./ cS.unitAcct);
% Scale factor for percentiles (arbitrary)
pctFactor = 10;

% Array with all deviations, so they can be displayed
outS.devV = devvect(100);


%% College outcomes

% Overall
outS.devFracS = dev_add(tgS.frac_scM(:, iCohort), aggrS.frac_sV, 1, pctFactor, cS.tgFracS, ...
   'frac s', 'Fraction by schooling', '%.2f');

% by IQ
outS.devFracEnterIq = dev_add(tgS.fracEnter_qcM(:, iCohort), aggrS.fracEnter_qV, 1, 1.5 * pctFactor, cS.tgFracEnterIq, ...
   'enter/iq',  'Fraction entering college by IQ quartile', '%.2f');
outS.devFracGradIq  = dev_add(tgS.fracGrad_qcM(:, iCohort),  aggrS.fracGrad_qV,  1, 1.5 * pctFactor, cS.tgFracGradIq , ...
   'grad/iq',  'Fraction graduating by IQ quartile', '%.2f');

% By yParent
outS.devFracEnterYp = dev_add(tgS.fracEnter_ycM(:, iCohort), aggrS.fracEnter_yV, 1, 1.5 * pctFactor, cS.tgFracEnterYp, ...
   'enter/yp',  'Fraction entering college by y quartile', '%.2f');
outS.devFracGradYp  = dev_add(tgS.fracGrad_ycM(:, iCohort),  aggrS.fracGrad_yV,  1, 1.5 * pctFactor, cS.tgFracGradYp , ...
   'grad/yp',  'Fraction graduating by y quartile', '%.2f');


%% Lifetime earnings

outS.devPvLty = dev_add(log(paramS.tgS.pvEarn_sV),  log(aggrS.pvEarn_sV), 1,  4, ...
   cS.tgPvLty,  'pvLty',  'Lifetime earnings by s',  'dollar');


%% Parental income

% Parental income and IQ
outS.devYpIq = dev_add(tgS.logYpMean_qcM(:,iCohort), aggrS.logYpMean_qV, 1, 1, cS.tgYpIq, 'yp/iq', ...
   'Mean log parental income by IQ quartile', '%.2f');

% By yp quartile
outS.devYpYp = dev_add(tgS.logYpMean_ycM(:,iCohort), aggrS.logYpMean_yV, 1, 1, cS.tgYpYp, 'yp/yp', ...
   'Mean log parental income by y quartile', '%.2f');


%% College costs
% First 2 years in college

% Change to mean by pq, yp

% College costs
% Mean and std dev among college students
outS.devPMean = dev_add(paramS.tgS.pMean, aggrS.pMeanYear2, 1, dollarFactor, cS.tgPMean, 'pMean', ...
   'Mean of college cost', 'dollar');
outS.devPStd  = dev_add(paramS.tgS.pStd,  aggrS.pStd,  1, dollarFactor, cS.tgPStd,  'pStd', ...
   'Std of college cost', 'dollar');

outS.devPMeanIq = dev_add(tgS.pMean_qcM(:,iCohort), aggrS.pMean_qV, 1, dollarFactor, ...
   cS.tgPMeanIq, 'pMean/iq',  'Mean of college cost by IQ', 'dollar');



%% Hours in College

% Average hours and earnings (first 2 years in college)
outS.devHours = dev_add(tgS.hoursS.hoursMean_cV(iCohort),  aggrS.hoursCollMeanYear2, ...
   1, pctFactor, cS.tgHours, 'hours', 'Mean hours in college', '%.2f');

outS.devHoursIq = dev_add(tgS.hoursS.hoursMean_qcM(:,iCohort),  aggrS.hoursCollMean_qV, 1, pctFactor, cS.tgHoursIq, 'hours/iq', ...
   'Mean hours in college by IQ', '%.2f');
outS.devHoursYp = dev_add(tgS.hoursS.hoursMean_ycM(:,iCohort),  aggrS.hoursCollMean_yV, 1, pctFactor, cS.tgHoursYp, 'hours/yp', ...
   'Mean hours in college by y', '%.2f');


%% Earnings in college
% First 2 years in college

outS.devEarn  = dev_add(tgS.collEarnS.mean_cV(iCohort),  aggrS.earnCollMeanYear2, 1, dollarFactor, cS.tgEarn, 'earn', ...
   'Mean earnings in college', 'dollar');

outS.devEarnIq  = dev_add(tgS.collEarnS.mean_qcM(:, iCohort),  aggrS.earnCollMean_qV, 1, dollarFactor, ...
   cS.tgEarnIq, 'earn/iq',  'Mean earnings in college by IQ', 'dollar');
outS.devEarnYp  = dev_add(tgS.collEarnS.mean_ycM(:, iCohort),  aggrS.earnCollMean_yV, 1, dollarFactor, ...
   cS.tgEarnYp, 'earn/yp',  'Mean earnings in college by y', 'dollar');


%% Debt at end of college

% To use debt stats constructed under the assumption that transfers are paid out each period, 
% just replace this with debtAltS
% debtS = aggrS.debtS;

% Mean college debt across all students
%  at end of college
outS.devDebtMean = dev_add(tgS.debtS.debtMean_cV(iCohort),  aggrS.debtAllS.mean, ...
   1, 0.5 * pctFactor, cS.tgDebtMean, 'debtMean',  'Mean college debt', '%.2f');


% Fraction with debt (end of college)
outS.devDebtFracS = dev_add(tgS.debtS.debtFracEndOfCollege_scM(:,iCohort),  aggrS.debtEndOfCollegeS.frac_sV, ...
   1, 0.5 * pctFactor, cS.tgDebtFracS,  'debtFracS',  'Fraction with college debt', '%.2f');
% Mean debt, not conditional on having debt
outS.devDebtMeanS = dev_add(tgS.debtS.debtMeanEndOfCollege_scM(:,iCohort),  aggrS.debtEndOfCollegeS.mean_sV, ...
   1, 0.5 * dollarFactor,  cS.tgDebtMeanS, 'debtMeanS', 'Mean college debt (CD, CG)', 'dollar');

outS.devDebtFracIq = dev_add(tgS.debtS.debtFracEndOfCollege_qcM(:, iCohort),  aggrS.debtEndOfCollegeS.frac_qV, ...
   1, 0.5 * pctFactor,  cS.tgDebtFracIq, 'debtFrac/iq', 'Fraction with college debt by IQ', '%.2f');
outS.devDebtFracYp = dev_add(tgS.debtS.debtFracEndOfCollege_ycM(:, iCohort),  aggrS.debtEndOfCollegeS.frac_yV, ...
   1, 0.5 * pctFactor,  cS.tgDebtFracYp, 'debtFrac/yp', 'Fraction with college debt by y', '%.2f');

outS.devDebtMeanIq = dev_add(tgS.debtS.debtMeanEndOfCollege_qcM(:, iCohort),  aggrS.debtEndOfCollegeS.mean_qV, ...
   1, 0.5 * dollarFactor,  cS.tgDebtMeanIq, 'debtMean/iq', 'Mean college debt by IQ', 'dollar');
outS.devDebtMeanYp = dev_add(tgS.debtS.debtMeanEndOfCollege_ycM(:, iCohort),  aggrS.debtEndOfCollegeS.mean_yV, ...
   1, 0.5 * dollarFactor,  cS.tgDebtMeanYp, 'debtMean/yp', 'Mean college debt by y', 'dollar');


%% Transfers
% First 2 years in college

outS.devTransfer = dev_add(tgS.transferMean_cV(iCohort), aggrS.transferMeanYear2, 1, dollarFactor, ...
   cS.tgTransfer, 'z mean', 'Mean transfer', 'dollar');

% Mean transfer (per year)
outS.devTransferYp = dev_add(tgS.transferMean_ycM(:, iCohort), aggrS.transfer_yV, 1, dollarFactor, ...
   cS.tgTransferYp, 'z/yp', 'Mean transfer by $y$ quartile', 'dollar');
outS.devTransferIq = dev_add(tgS.transferMean_qcM(:, iCohort), aggrS.transfer_qV, 1, dollarFactor, ...
   cS.tgTransferIq, 'z/iq', 'Mean transfer by IQ quartile', 'dollar');



%% Financing shares
% For cohorts when earnings and transfers are not available

outS.devFinEarnShare = dev_add(tgS.finShareS.workShare_cV(iCohort),  aggrS.finS.fracEarnings, ...
   1, pctFactor, cS.tgFinShares, 'earnShare', 'Share of college costs from earnings', '%.2f');
outS.devFinLoanShare = dev_add(tgS.finShareS.loanShare_cV(iCohort),  aggrS.finS.fracDebt, ...
   1, pctFactor, cS.tgFinShares, 'loanShare', 'Share of college costs from loans', '%.2f');


% *** Overall deviation

outS.dev = sum(outS.devV.scalar_devs);
% Return value
dev = outS.dev;

validateattributes(outS.devV.scalar_devs, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})

if doSave == 1
   var_save_bc1(paramS, cS.vCalDev, cS);
end


%% Show deviations

fprintf('\nDeviations    %s    %.2f \n',  datestr(now, 'HH:MM'),  outS.dev);

if doShow == 1
   outS.devV.dev_display;


   fprintf('Calibrated params\n');
   iShow = 0;
   for i1 = 1 : cS.pvector.np
      ps = cS.pvector.valueV{i1};
      if ismember(ps.doCal, cS.doCalV)
         fprintf('  %s: %s  ',  ps.name,  string_lh.string_from_vector(paramS.(ps.name), '%.3f'));
         iShow = iShow + 1;
         if (rem(iShow, 5) == 0)
            fprintf('\n');
         end
      end
   end
   if rem(iShow, 5) ~= 0
      fprintf('\n');
   end

   fprintf('Fraction entering / graduating: %.2f / %.2f \n',  sum(aggrS.frac_sV(cS.iCD : cS.nSchool)), ...
      aggrS.frac_sV(cS.iCG));
end

% keyboard;


%% Nested: add deviation
%{
Add a deviation to the deviation vector (a vector of devstruct)
If all targets are NaN: ignore (data not available)
   and return missVal deviation

Only targeted data moments are added to outS.devV

IN
   wtV
      relative weights of the different deviations
      sum to 1
   scaleFactor
      multiplied into modelV and dataV for taking scalar dev
   isTarget
      is this moment used as target in calibration?
   descrStr
      short descriptive label for iteration summary
   longDescrStr
      long description of target for fit tables
   fmtStr
      sprintf format string; for formatting  OR
      'dollar'
%}
   function scalarDev = dev_add(tgV, modelV, wtV, scaleFactor, isTarget, descrStr, longDescrStr, fmtStr)
      if all(isnan(tgV))
         scalarDev = cS.missVal;
         return;
      end
      validateattributes(tgV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
      validateattributes(modelV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
      
      % For display of dollar values
      if strcmp(fmtStr, 'dollar')
         modelV = modelV .* dollarFactor;
         tgV = tgV .* dollarFactor;
         fmtStr = '%.2f';
      end
      % Make a deviation struct
      ds = devstruct(descrStr, descrStr, longDescrStr, modelV, tgV, wtV, scaleFactor, fmtStr);
      scalarDev = ds.scalar_dev;
      
      if isTarget == 1
         % Add to deviation vector
         outS.devV = outS.devV.devadd(ds);
      end      
   end

end