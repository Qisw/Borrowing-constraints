function [outS, entryS] = load_income_iq_college(sourceFn, setNo)
% Load college entry / grad rates by [income, iq]
%{
Using csv files for each source
Not all years have graduation rates

OUT
   entry_yqM, grad_yqM
      entry and graduation rates (not conditional on entry)
      by [y parent, iq] quartile
   ypUbV, iqUbV
      ORIGINAL bounds in dataset

Plot raw and interpolated data +++
Add self-test code +++
   check that sum(entryS.perc_qyM) is close to entryS.ypUbV
interpolation is wrong +++++
   these are not cdfs
   need to compute fraction by quartile somehow
%}

cS = const_bc1(setNo);
nq = length(cS.iqUbV);
nYp = length(cS.ypUbV);


%% Load csv files

gradDir = '/Users/lutz/Dropbox/borrowing constraints/data/income x iq x college grad';
entryDir = '/Users/lutz/Dropbox/borrowing constraints/data/income x iq x college';

% Entry rates
entryS = load_table(fullfile(entryDir, sourceFn), cS);

% Consistency check
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

% Graduation rates are still conditional on entry
gradFn = fullfile(gradDir, sourceFn);
if exist(gradFn, 'file')
   gradS  = load_table(gradFn, cS);
else
   gradS = [];
end


% Interpolate to match cS.iqUbV and cS.ypUbV
mass_qyM  = interpolate(entryS.perc_qyM, entryS.iqUbV, entryS.ypUbV, cS);
outS.mass_qyM  = mass_qyM ./ sum(mass_qyM(:));
outS.entry_qyM = interpolate(entryS.perc_coll_qyM, entryS.iqUbV, entryS.ypUbV, cS);

if ~isempty(gradS)
   outS.grad_qyM  = interpolate(gradS.prob_grad_qyM, gradS.iqUbV, gradS.ypUbV, cS);
   % Make prob grad not conditional on entry
   outS.grad_qyM = outS.grad_qyM .* outS.entry_qyM;
else
   outS.grad_qyM = [];
end



% Construct marginal distributions
[outS.entry_qV, outS.entry_yV] = marginals(outS.entry_qyM, outS.mass_qyM, cS);
validateattributes(outS.entry_qV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   '<', 0.95, 'size', [nq, 1]})
validateattributes(outS.entry_yV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   '<', 0.95, 'size', [nYp, 1]})

if ~isempty(gradS)
   [outS.grad_qV,  outS.grad_yV] = marginals(outS.grad_qyM, outS.mass_qyM, cS);
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

   % Upper bounds of family income groups
   [~, idxV] = unique(round(loadM.upper_fam));
   ypUbV = loadM.upper_fam(idxV) ./ 100;
%    if length(ypUbV) ~= length(cS.ypUbV)
%       error('Not implemented');
%    end

   % Recode as index values
   iYpV = nan([nObs,1]);
   for i1 = 1 : length(ypUbV)
      iYpV(abs(loadM.upper_fam - 100 .* ypUbV(i1)) < 0.05) = i1;
   end
   validateattributes(iYpV, {'double'}, {'finite', 'nonnan', 'nonempty', 'integer', 'positive', ...
      'size', [nObs,1]})

   % Upper bounds of IQ groups
   [~, idxV] = unique(round(loadM.upper_ac));
   iqUbV = loadM.upper_ac(idxV) ./ 100;
%    if length(iqUbV) ~= length(cS.iqUbV)
%       error('Not implemented');
%    end

   % Recode as index values
   iIqV = nan([nObs,1]);
   for i1 = 1 : length(iqUbV)
      iIqV(abs(loadM.upper_ac - 100 .* iqUbV(i1)) < 0.05) = i1;
   end
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
function int_qyM = interpolate(m_qyM, iqUbV, ypUbV, cS)
   nIq = length(iqUbV);
   nYp = length(ypUbV);
   yp_qyM = ones([nIq, 1]) * ypUbV(:)';
   iq_qyM = iqUbV(:) * ones([1, nYp]);
   
   nIq2 = length(cS.iqUbV);
   nYp2 = length(cS.ypUbV);
   yp2_qyM = ones([nIq2, 1]) * cS.ypUbV(:)';
   iq2_qyM = cS.iqUbV(:) * ones([1, nYp2]);

   % Change: interpolation for values outside the grid in the data +++
   intS = scatteredInterpolant([iq_qyM(:), yp_qyM(:)], m_qyM(:), 'linear', 'nearest');
   int_qyM = intS([iq2_qyM(:), yp2_qyM(:)]);
   int_qyM = reshape(int_qyM, [nIq2, nYp2]);
end


%% Marginal distribution
function [m_qV, m_yV] = marginals(m_qyM, mass_qyM, cS)
   [nq, nYp] = size(m_qyM);
   m_qV = nan([nq, 1]);
   for iq = 1 : nq
      % Pr(x | q) * Pr(q) = sum over y  of  Pr(x | q,y) * Pr(q,y)
      m_qV(iq) = sum(m_qyM(iq,:) .* mass_qyM(iq,:)) ./ sum(mass_qyM(iq,:));
   end

   m_yV = nan([nYp, 1]);
   for iy = 1 : nYp
      % Pr(x | y) * Pr(y) = sum over q  of  Pr(x | q,y) * Pr(q,y)
      m_yV(iy) = sum(m_qyM(:,iy) .* mass_qyM(:,iy)) ./ sum(mass_qyM(:,iy));
   end
   
end