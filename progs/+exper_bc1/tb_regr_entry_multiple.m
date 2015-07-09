function tb_regr_entry_multiple(outFn, setTitleV, expTitleV, setNoM, expNoM)
% Table: beta_IQ and beta_yp
%{
   setNoM(iCase, iModel), expNoM(iCase, iModel)
      each column is a model
      each row is a case of the decomposition / comparison
%}

cS = const_bc1(setNoM(1,1), expNoM(1,1));
symS = helper_bc1.symbols;
[nx, nm] = size(setNoM);
fmtStr = '%.2f';



%% Input check

if ~isequal(size(setNoM), size(expNoM))
   error('Not equal size');
end
if length(setTitleV) ~= nm
   error('Invalid');
end
if length(expTitleV) ~= nx
   error('Invalid');
end


%% Table structure
% Models are columns

nc = 1 + nm * 2;
nr = 2 + nx;

tbM = cell([nr, nc]);
tbS.rowUnderlineV = zeros([nr, 1]);
tbS.lineStrV = cell([nr, 1]);

% Headerline
ir = 1;
nameV = cell([nm, 1]);
alignV = cell([nm, 1]);
widthV = ones([nm, 1]);
for im = 1 : nm
   nameV{1 + im} = setTitleV{im};
   alignV{1 + im} = 'c';
   widthV(1 + im) = 2;
end
tbS.lineStrV{ir} = latex_lh.multicolumn(nameV, widthV, alignV);



%% Table body

% Loop over models
for im = 1 : nm
   % Header with model descriptions
   ir = 2;
   % Columns for this model
   ic = 2 + 2 * (im-1);
   icV = ic : (ic + 1);

   tbM(ir, icV) = {['$', symS.betaIq, '$'], ['$', symS.betaYp, '$']};
   tbS.rowUnderlineV(ir) = 1;

   for ix = 1 : nx
      % Header
      ir = ir + 1;
      tbM{ir,1} = expTitleV{ix};
      
      setNo = setNoM(ix, im);
      expNo = expNoM(ix, im);
      cS = const_bc1(setNo, expNo);
      aggrS = var_load_bc1(cS.vAggregates, cS);
      if cS.regrEntryIqYpWeighted == 1
         mBetaIq = aggrS.qyS.betaIqWeighted;
         mBetaYp = aggrS.qyS.betaYpWeighted;
      else
         mBetaIq = aggrS.qyS.betaIq;
         mBetaYp = aggrS.qyS.betaYp;
      end
      
      tbM(ir, icV) = {sprintf(fmtStr, mBetaIq),  sprintf(fmtStr, mBetaYp)};
   end
end

latex_lh.latex_texttb_lh(outFn, tbM, 'Caption', 'Label', tbS);


end
