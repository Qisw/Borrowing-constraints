function [outM, nCountries, nYears] = ...
   load_year_country_lh(asciiFn, countryCodeV, yearV, delimChar, missVal, dbg);
% Load a data file indexed by year and country
% Row 1 contains WB country codes
% Col 1 contains years

% IN:
%  File name for ascii file
%     indexed by [year, country]
%  countryCodeV, yearV
%     Country codes and years to keep
%     Years must be contiguous
%  delimChar
%     Delimiter character
%     If tab delimited use delimChar = '\t';
%  missVal
%     Missing value code.
%     Used for data outside of loaded range.
%     Missing values in the loaded range are not replaced.

% OUT:
%  outM(year, country)
%  nYears, nCountries
%     Number of years/countries for which data were found

% ----------------------------------------

if nargin ~= 6
   error('Invalid nargin');
end

% Load ascii file
% Must be done one row at a time b/c of the header row
fid = fopen(asciiFn);

% Read header row into a single string
headerStr = fgetl(fid);

% Read the remaining rows into a number array
iRow = 0;
done = 0;
while done == 0
   % Read one row
   %xV = fscanf(fid, ['%f', delimChar]);
   rowStr = fgetl(fid);
   if feof(fid) == 1
      done = 1;
   else
      xV = sscanf(rowStr, ['%f', delimChar]);
      iRow = iRow + 1;
      if iRow == 1
         dataM = xV(:)';
      else
         dataM(iRow,:) = xV(:)';
      end
   end
end

fclose(fid);


% Break header row into fields
[headerFieldV, nf] = str_break_lh(headerStr, delimChar, dbg);
% Drop the corner cell
headerFieldV = headerFieldV(2:end);

% Years in dataM
dYearV = dataM(:,1)';
% Retain only the data
dataM = dataM(:, 2:end);


% ***  Year matches  ***
% Year range common to data and output
year1 = max(dYearV(1), yearV(1));
year2 = min(dYearV(end), yearV(end));
nYears = year2 - year1 + 1;
if year2 >= year1
   % Index into dataM
   dYearIdxV = year1 - dYearV(1) + (1 : (year2 - year1 + 1));
   % Index into outM
   yearIdxV  = year1 - yearV(1)  + (1 : (year2 - year1 + 1));
else
   warnmsg([ mfilename, ':  No common years' ]);
   keyboard;
end


% ***  Extract countries and years  ***
nc = length(countryCodeV);
outM = repmat(missVal, [length(yearV), nc]);
% Mark countries for which data were found
cHasDataV = zeros([1, nc]);
% Loop over requested countries
for ic = 1 : nc
   % Find country code in data
   for iData = 1 : length(headerFieldV)
      if strcmp(upper(headerFieldV{iData}), upper(countryCodeV{ic}))
         outM(yearIdxV, ic) = dataM(dYearIdxV, iData);
         cHasDataV(ic) = 1;
      end
   end
end

nCountries = length(find(cHasDataV == 1));


%disp(mfilename);
%keyboard;

% -----  eof  -------
