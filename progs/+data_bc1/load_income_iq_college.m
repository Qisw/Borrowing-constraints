function [outS, entryS] = load_income_iq_college(sourceFn, setNo)
% Load college entry / grad rates by [iq, yp]
%{
Using csv files for each source
Not all years have graduation rates

IN
   sourceFn
      e.g. 'updegraff 1936.csv'

OUT
   entry_qyM, grad_qyM
      entry and graduation rates (not conditional on entry)
      by [iq, yp] quartile
   mass_qyM
      mass of HSG in each cell

Plot raw and interpolated data +++
%}

cS = const_bc1(setNo);
nq = length(cS.iqUbV);
nYp = length(cS.ypUbV);


%% Load csv files

% gradDir = '/Users/lutz/Dropbox/borrowing constraints/data/income x iq x college grad';
% entryDir = '/Users/lutz/Dropbox/borrowing constraints/data/income x iq x college';

% Entry rates
entryS = load_table(fullfile(cS.studyEntryDir, sourceFn), cS);

% Graduation rates are still conditional on entry
gradFn = fullfile(cS.studyGradDir, sourceFn);
if exist(gradFn, 'file')
   gradS  = load_table(gradFn, cS);
else
   gradS = [];
end


%%  Consistency check

frac_yV = sum(entryS.perc_qyM);
cumFrac_yV = cumsum(frac_yV);
diffV = cumFrac_yV(:) - entryS.ypUbV;
if any(abs(diffV) > 0.05) 
   fprintf('%s \n', sourceFn);
   error_bc1('Inconsistent', cS);
end

frac_qV = sum(entryS.perc_qyM, 2);
cumFrac_qV = cumsum(frac_qV);
diffV = cumFrac_qV(:) - entryS.iqUbV;
if any(abs(diffV) > 0.05) 
   fprintf('%s \n', sourceFn);
   error_bc1('Inconsistent', cS);
end



%% Interpolate to match cS.iqUbV and cS.ypUbV

mass_qyM  = interpolate(entryS.perc_qyM, entryS.iqUbV, entryS.ypUbV, cS);
outS.mass_qyM  = mass_qyM ./ sum(mass_qyM(:));

outS.entry_qyM = interpolate(entryS.perc_coll_qyM, entryS.iqUbV, entryS.ypUbV, cS);
validateattributes(outS.entry_qyM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   '<', 1})

if ~isempty(gradS)
   outS.grad_qyM  = interpolate(gradS.prob_grad_qyM, gradS.iqUbV, gradS.ypUbV, cS);
   % Make prob grad not conditional on entry
   outS.grad_qyM = outS.grad_qyM .* outS.entry_qyM;
   validateattributes(outS.grad_qyM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      '<', 1})
else
   outS.grad_qyM = [];
end



%%  Construct marginal distributions

[outS.entry_qV, outS.entry_yV] = helper_bc1.marginals(outS.entry_qyM, outS.mass_qyM, cS);
validateattributes(outS.entry_qV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   '<', 1, 'size', [nq, 1]})
validateattributes(outS.entry_yV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   '<', 1, 'size', [nYp, 1]})

if ~isempty(gradS)
   [outS.grad_qV,  outS.grad_yV] = helper_bc1.marginals(outS.grad_qyM, outS.mass_qyM, cS);
   validateattributes(outS.grad_qV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      '<', 0.9, 'size', [nq, 1]})
   validateattributes(outS.grad_yV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
      '<', 0.9, 'size', [nYp, 1]})
end


end



%% Make a loaded table into a matrix for each variable in the table
% by [q, y]
% only keep all race / all sex entries
function outS = load_table(loadFn, cS)
   % Load the table
   loadM = readtable(loadFn);
   % Variable names
   vnV = loadM.Properties.VariableNames;

   % Only keep all reces / sexes
   idxV = find(strcmp(loadM.gender, 't')  &  strcmp(loadM.race, 't'));
   loadM = loadM(idxV, :);
   nObs = length(idxV);

   [iYpV, ypUbV] = vector_lh.recode_sequential(loadM.upper_fam ./ 100, 5);
%    % Upper bounds of family income groups
%    [~, idxV] = unique(round(loadM.upper_fam));
%    ypUbV = loadM.upper_fam(idxV) ./ 100;
% 
%    % Recode as index values
%    iYpV = nan([nObs,1]);
%    for i1 = 1 : length(ypUbV)
%       iYpV(abs(loadM.upper_fam - 100 .* ypUbV(i1)) < 0.05) = i1;
%    end
   validateattributes(iYpV, {'double'}, {'finite', 'nonnan', 'nonempty', 'integer', 'positive', ...
      'size', [nObs,1]})

   [iIqV, iqUbV] = vector_lh.recode_sequential(loadM.upper_ac ./ 100, 5);
%    % Upper bounds of IQ groups
%    [~, idxV] = unique(round(loadM.upper_ac));
%    iqUbV = loadM.upper_ac(idxV) ./ 100;
% 
%    % Recode as index values
%    iIqV = nan([nObs,1]);
%    for i1 = 1 : length(iqUbV)
%       iIqV(abs(loadM.upper_ac - 100 .* iqUbV(i1)) < 0.05) = i1;
%    end
   validateattributes(iIqV, {'double'}, {'finite', 'nonnan', 'nonempty', 'integer', 'positive', ...
      'size', [nObs,1]})

   % Make each variable into a matrix by [q, y]
   outS.ypUbV = ypUbV;
   outS.iqUbV = iqUbV;
   for iVar = 1 : length(vnV)
      varName = vnV{iVar};
      if all(strcmpi(varName, {'race', 'gender', 'upper_fam', 'upper_ac'}) == 0)
         outS.([varName, '_qyM']) = accumarray([iIqV, iYpV], loadM.(varName)) ./ 100;
      end
   end
end


%% Interpolate to match common group bounds
% Assume that m_qyM applies to the interval midpoints
function int_qyM = interpolate(m_qyM, iqUbV, ypUbV, cS)
   % Make an interpolation object for the data
   % Midpoints
   qMidV = vector_lh.midpoints([0; iqUbV(:)]);
   yMidV = vector_lh.midpoints([0; ypUbV(:)]);
   yp_qyM = ones(length(qMidV),1) * yMidV';
   iq_qyM = qMidV * ones(1, length(yMidV));
   % Change: interpolation for values outside the grid in the data +++
   intS = scatteredInterpolant(iq_qyM(:),  yp_qyM(:),  m_qyM(:), 'linear', 'nearest');

   % Make midpoints for the desired [iq, yp] ranges
   q2MidV = vector_lh.midpoints([0; cS.iqUbV(:)]);
   y2MidV = vector_lh.midpoints([0; cS.ypUbV(:)]);
   % Interpolate to the new midpoints
   yp2_qyM = ones([length(q2MidV), 1]) * y2MidV';
   iq2_qyM = q2MidV * ones([1, length(y2MidV)]);

   int_qyM = intS([iq2_qyM(:), yp2_qyM(:)]);
   int_qyM = reshape(int_qyM, size(iq2_qyM));
   
   validateattributes(int_qyM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [length(cS.iqUbV),  length(cS.ypUbV)]})
end


