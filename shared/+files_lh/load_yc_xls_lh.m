function [dataM, loadYearV, textV] = load_yc_xls_lh(xlsFn, sheetName, yearV, cCodesV, missVal, dbg);
% Load a data matrix indexed by [year, country] from an
% xls file.
% Col 1 is year
% Row 1 is country code
% Cell (1,1) is not used

% IN:
%  sheetName
%     Optional. Set to [] to ignore.

% OUT:
%  dataM(year, country)
%     Loaded data
%     Note that missing value codes from original data are not replaced
%  loadYearV
%     Years in xls file
%  textV
%     Country codes in xls file
% ----------------------------------

if nargin ~= 6
   error('Invalid nargin');
end

% Import excel file (text and data)
% textV is a cell array with country codes.
% numM is the numeric block of the sheet
% Col 1 is year header
if length(sheetName) >= 1
   [numM, textV] = xlsread(xlsFn, sheetName);
else
   [numM, textV] = xlsread(xlsFn);
end

loadYearV = numM(:,1)';
% Check that years are correct
v_check( loadYearV, 'i', [], 1500, 2020 );

% Stip extra blanks from country labels
textV = deblank(textV);

% Data matrix by [year, country]
nYr = length(yearV);
nCountries = length(cCodesV);
dataM = repmat(missVal, [nYr, nCountries]);


% For each year to be loaded, find column in loaded data (if any)
% loadYrIdxV(iy) is row in numM that matches row iy in dataM
loadYrIdxV = zeros(1, nYr);
for iy = 1 : nYr
   idx = find(yearV(iy) == loadYearV);
   if length(idx) == 1
      loadYrIdxV(iy) = idx;
   elseif length(idx) > 1
      warnmsg([ mfilename, ':  Years repeated in data file' ]);
      keyboard;
   end
end
% Find years with matches
dYrIdxV = find(loadYrIdxV >= 1);

if length(dYrIdxV) > 0
   loadYrIdxV = loadYrIdxV(dYrIdxV);

   % Loop over countries
   for ic = 1 : nCountries
      cCode = cCodesV{ic};
      % Find this country by code in loaded data
      cIdx = missVal;
      for rt = 1 : length(textV)
         if strcmp(textV(rt), cCode) == 1
            cIdx = rt;
            break;
         end
      end

      % If country found: copy its data
      if cIdx >= 1
         dataM(dYrIdxV,ic) = numM(loadYrIdxV,cIdx);
      end
   end

% else: no years overlap
end

%disp(mfilename);
%keyboard;


% ******* eof *******
