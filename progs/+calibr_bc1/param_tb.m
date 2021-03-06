function param_tb(showCalibrated, setNo, expNo)
% Table with calibrated or with fixed parameters
%{
Dollar figures are in units of account

IN
   showCalibrated
      0 or 1, show calibrated or fixed params?
%}
% ----------------------------------

cS = const_bc1(setNo, expNo);
symS = helper_bc1.symbols;
paramS = param_load_bc1(setNo, expNo);
% dFactor = cS.unitAcct ./ cS.dollarScale;

validateattributes([showCalibrated, setNo, expNo], {'double'}, {'finite', 'nonnan', 'nonempty', 'integer', ...
   'size', [1,3]})

% To make sure that everything is shown
pNameV = cS.pvector.nameV;


%%  Table layout

nc = 0;
nc = nc + 1;   cName = nc;
nc = nc + 1;   cRole = nc;
nc = nc + 1;   cValue = nc;

nr = 30;
tbM = cell([nr, nc]);
tbS.rowUnderlineV = zeros([nr, 1]);
tbS.showOnScreen = 1;

% Header
ir = 1;
tbS.rowUnderlineV(ir) = 1;
tbM{ir,cName} = 'Parameter';
tbM{ir,cRole} = 'Description';
tbM{ir,cValue} = 'Value';


%% Demographics
if showCalibrated == 0
   ir = ir + 1;
   tbM{ir, cName} = 'Demographics';
   
   row_add_direct(['$', symS.ageMax, '$'], 'Lifespan', sprintf('%i', cS.ageMax));
   row_add_direct(['$', symS.tSchool, '$'], 'School durations', ...
      string_lh.string_from_vector(cS.ageWorkStart_sV - 1, '%i'));
end



%% Endowments

ir = ir + 1;
tbM{ir, cName} = 'Endowments';


% Endowment correlations
% nameV = {'alphaPY', 'alphaPM', 'alphaYM', 'alphaPuM'};
% % if (paramS.puWeightStd > 1e-4)  ||  1
% %    nameV = [nameV, 'alphaPuM'];
% % end
% row_add_vector(nameV, 'Endowment correlations', '%.2f', []);
pNameV = mark_done(pNameV, 'alphaPY');
pNameV = mark_done(pNameV, 'alphaPM');
pNameV = mark_done(pNameV, 'alphaYM');
pNameV = mark_done(pNameV, 'alphaPuM');

% Signal noise
% row_add('alphaAM', '%.2f', []);
pNameV = mark_done(pNameV, 'alphaAM');


% Marginal distributions
row_add_vector({'pMean', 'pStd'}, ['Marginal distribution of $', symS.collCost, '$'], '%.1f', []);
row_add_vector({'logYpMean', 'logYpStd'}, ['Marginal distribution of $', symS.famIncome, '$'], '%.2f', []);
row_add_vector({'sigmaIQ'}, [symS.IQ, ' noise'], '%.2f', []);



%% Preferences

ir = ir + 1;
tbM{ir, cName} = 'Preferences';

row_add('prefBeta', '%.2f', []);
row_add('prefSigma', '%.2f', [])
if cS.ucCurvatureSame == 0
   row_add('workSigma', '%.2f', [])
else
   pNameV = mark_done(pNameV, 'workSigma');
end
row_add('prefWt', '%.2f', []);
row_add('prefRho', '%.2f', []);
row_add('prefWtLeisure', '%.2f', []);
row_add('prefWtWork', '%.2f', []);
row_add('puSigma', '%.2f', []);
row_add('puWeightMean', '%.2f', []);
row_add('puWeightStd', '%.2f', []);
row_add('prefScaleEntry', '%.2f', []);
row_add('prefHS', '%.2f', []);
row_add('cCollMax', '%.1f', []);
row_add('lCollMax', '%.2f', []);


%% Other

ir = ir + 1;
tbM{ir, cName} = 'Other';

row_add_vector({'phiHSG', 'phiCG'},  'Returns to ability', '%.3f', []);
if showCalibrated == 1
   row_add_direct(['$', symS.pvEarnSchool, '_{s}$'], 'Log skill prices', ...
      string_lh.string_from_vector(paramS.eHat_sV, '%.2f'));
end
% Not directly used
pNameV = mark_done(pNameV, 'eHatCD');
pNameV = mark_done(pNameV, 'dEHatHSG');
pNameV = mark_done(pNameV, 'dEHatCG');

% Prob grad(a) -- only show graph
% row_add_vector({'prGradMin', 'prGradMax', 'prGradMult', 'prGradExp', 'prGradPower', 'prGradABase'}, ...
%    'Governing $\pi(a)$', '%.2f', []);
pNameV = mark_done(pNameV, 'prGradMin');
pNameV = mark_done(pNameV, 'prGradMax');
pNameV = mark_done(pNameV, 'prGradMult');
pNameV = mark_done(pNameV, 'prGradExp');
pNameV = mark_done(pNameV, 'prGradPower');
pNameV = mark_done(pNameV, 'prGradABase');

row_add('wCollMean', '%.1f', []);

row_add('R', '%.2f', []);

% if showCalibrated == 0
%    [~, valueStr] = string_lh.dollar_format(cS.cFloor, ',', 2);
%    row_add_direct('$c_{Floor}$', 'Consumption floor', valueStr);
% end


%%  Write table

nr = ir;
tbM = tbM(1 : nr, :);
tbS.rowUnderlineV = tbS.rowUnderlineV(1 : nr);

if showCalibrated == 1
   tbFn = 'param_tb.tex';
else
   tbFn = 'param_fixed_tb.tex';
end
latex_lh.latex_texttb_lh(fullfile(cS.paramDir, tbFn), tbM(1:ir,:), 'Caption', 'Label', tbS);


% Check that all params are taken care of
if ~isempty(pNameV)
   warning('Not all parameters in table');
   for i2 = 1 : length(pNameV)
      fprintf('    %s', pNameV{i2});
   end
   fprintf('\n');
end

return;


%% ********  Nested functions follow


%% Nested: Add row to table, values directly provided

   function row_add_direct(nameStr, roleStr, valueStr)
      if ~ischar(valueStr)
         error('not string');
      end
      ir = ir + 1;
      tbM{ir, cName} = nameStr;
      tbM{ir, cRole} = roleStr;
      tbM{ir, cValue} = valueStr;
      % Mark as done
      pNameV = mark_done(pNameV, nameStr);
   end


%% Nested: Add row to table
%{
IN:
   nameStr
      parameter name, such as 'prefBeta'
   fmtStr
      sprintf format string
   showIdx
      if not [], show only 1 entry of a vector
%}

   function row_add(nameStr, fmtStr, showIdx)
      ps = cS.pvector.retrieve(nameStr);
      if show_param(ps)
         ir = ir + 1;
         tbM{ir,cName} = ['$', ps.symbolStr, '$'];
         tbM{ir,cRole} = ps.descrStr;
         valueV = paramS.(nameStr);
         if ~isempty(showIdx)
            valueV = valueV(showIdx);
         end
         if length(valueV) == 1
            valueStr = sprintf(fmtStr, valueV);
         else
            % Vector
            valueStr = string_lh.string_from_vector(valueV, fmtStr);
         end
         tbM{ir,cValue} = ['$', valueStr, '$'];
      end
      pNameV = mark_done(pNameV, nameStr);
   end
   

%% Nested: Add row to table from a vector
%{
IN:
   showIdx
      if not [], show only 1 element of the value for each entry
%}
   
   function row_add_vector(nameV, roleStr, fmtStr, showIdx)
      nameStr = '';
      valueStr = '';
      for i1 = 1 : length(nameV)
         ps = cS.pvector.retrieve(nameV{i1});
         pNameV = mark_done(pNameV, nameV{i1});
         if show_param(ps)
            nameStr  = [nameStr,  ', ', ps.symbolStr];
            
            valueV = paramS.(nameV{i1});
            if ~isempty(showIdx)
               valueV = valueV(showIdx);
            end
            valueStr = [valueStr, ', ', sprintf(fmtStr, valueV)];
         end
      end      
      if ~isempty(nameStr)
         ir = ir + 1;
         tbM{ir, cName} = ['$', nameStr(3:end), '$'];
         tbM{ir, cRole} = roleStr;
         tbM{ir, cValue} = ['$', valueStr(3:end), '$'];
      end
   end


%% Nested: Show this parameter?
   function doShow = show_param(ps)
      % Is this parameter calibrated?
      isCal = ismember(ps.doCal, cS.doCalV);     %  &&  (ps.doCal ~= cS.calNever);
      doShow = (isCal == showCalibrated);
      %fprintf('%s    doCal: %i    show: %i \n',  ps.name, ps.doCal, doShow);
   end

end


%% Mark a parameter as done
function nameV = mark_done(nameV, nameStr)
   idx = find(strcmp(nameV, nameStr));
   if length(idx) == 1
      nameV(idx) = [];
   elseif length(idx) > 1
      error('Not possible');
%    else
%       warning(sprintf('Parameter %s not found', nameStr));
   end
end
