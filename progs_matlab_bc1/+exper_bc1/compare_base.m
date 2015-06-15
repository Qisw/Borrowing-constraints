function compare_base(setNo, expNo)
% Compare experiment with baseline

cS = const_bc1(setNo, expNo);
expNoV = [expNo, cS.expBase];
nx = length(expNoV);

paramV = cell([nx, 1]);
aggrV = cell([nx, 1]);
for ix = 1 : nx
   cxS = const_bc1(setNo, expNoV(ix));
   paramV{ix} = param_load_bc1(setNo, expNoV(ix));
   aggrV{ix} = var_load_bc1(cS.vAggregates, cxS);
end


%% Summary table

% cExp = 2;
% cBase = 3;
nc = 3;

nr = 50;
tbM = cell([nr, nc]);
tbS.rowUnderlineV = zeros([nr, 1]);


% Header row
ir = 1;
tbM(ir, :) = {'Variable', 'Experiment', 'Base'};


% *********  Body
for ix = 1 : nx
   ic = 1 + ix;
   ir = 1;
   
   ir = ir + 1;
   tbM{ir,1} = 'Drivers';
   ir = ir + 1;
   tbM{ir,1} = 'PV of lifetime earnings by s';
   tbM{ir, ic} = string_lh.string_from_vector(log(paramV{ix}.pvEarn_sV), '%.2f');
   ir = ir + 1;
   tbM{ir,1} = 'Premium relative to HSG';
   tbM{ir,ic} = string_lh.string_from_vector(diff(log(paramV{ix}.pvEarn_sV)), '%.2f');
   ir = ir + 1;
   tbM{ir,1} = 'Mean college cost';
   [~, tbM{ir,ic}] = string_lh.dollar_format(paramV{ix}.pMean * cS.unitAcct, ',', 0);
   ir = ir + 1;
   tbM{ir,1} = 'Borrowing limit';
   [~, tbM{ir,ic}] = string_lh.dollar_format(paramV{ix}.kMin_aV(end) * cS.unitAcct, ',', 0);
   
   ir = ir + 1;
   tbM{ir,1} = 'Outcomes';
   ir = ir + 1;
   tbM{ir,1} = 'Fraction dropouts / graduates';
   tbM{ir, ic} = string_lh.string_from_vector(aggrV{ix}.frac_sV([cS.iCD, cS.iCG]), '%.2f');
   ir = ir + 1;
   tbM{ir,1} = 'Fraction with debt';
   ir = ir + 1;
   tbM{ir,1} = 'Mean debt (unconditional)';
   ir = ir + 1;
   tbM{ir,1} = 'Mean transfer';
end


% *******  Write table

tbS.rowUnderlineV = tbS.rowUnderlineV(1 : ir);
tbFn = 'compare_base';
latex_lh.latex_texttb_lh(fullfile(cS.tbDir, tbFn), tbM(1:ir,:), 'Caption', 'Label', tbS);



end