function loadM = load_yc(dataFn, yearV, cCodesV, yearPrefix, missVal, dbg)
% Load one variable, by [year, country]
%{
Input file is a matlab dataset created by stat/transfer
Rows are country codes
Columns are years with variable names [yearPrefix, '1999'] etc
Arbitrary years and country codes are allowed
Missing values must be numeric or NaN
   I.e.: the data columns must be numeric

IN:
   dataFn
      e.g. 'gdp_percapita_current_usd'

Checked: 
%}
% ----------------------------------------------


%% Input check

ny = length(yearV);
nc = length(cCodesV);

if dbg > 10
   validateattributes(yearV, {'numeric'}, {'finite', 'nonnan', 'nonempty', 'integer', '>', 1700, ...
      '<', 2020})
end


%% Load

% Load matlab dataset
m = load([dataFn, '.mat']);
m = m.st_dataset;
% Get variables
varNameV = get(m, 'VarNames');
% Get country codes
cIdx = find(strncmpi(varNameV, 'Country', 7));
if length(cIdx) ~= 1
   error('Cannot find country column');
end
mCCodeV = m.(varNameV{cIdx});


% Find each country's row number
countryRowV = zeros([nc, 1]);
for ic = 1 : nc
   cRow = find(strcmpi(mCCodeV, cCodesV{ic}));
   if ~isempty(cRow)
      countryRowV(ic) = cRow;
   end
end
% These countries have data
cIdxV = find(countryRowV >= 1);


%% Write

% Output matrix
loadM = repmat(missVal, [ny, nc]);

% Loop over years
for iy = 1 : ny
   yearStr = [yearPrefix, sprintf('%i', yearV(iy))];
   % Does this year exist?
   if any(strcmpi(varNameV, yearStr))
      % Data for this year
      yearDataV = m.(yearStr);
      % Replace missing value codes
      yearDataV(isnan(yearDataV)) = missVal;
      loadM(iy, cIdxV) = yearDataV(countryRowV(cIdxV));
   end
end


%% Self test
if 1
   validateattributes(loadM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [ny, nc]})
end


end