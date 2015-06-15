function coll_costs(setNo)
% Read file with college costs by year
%{
Save in base year prices

Checked: 2015-Mar-18
%}


cS = const_bc1(setNo);

% Read data from xls
% public and private colleges
xlsFn = fullfile(cS.dataDir, 'college costs herrington.xlsx');
numM = xlsread(xlsFn);

yearV = numM(:, 1);
validateattributes(yearV, {'double'}, {'finite', 'nonnan', 'nonempty', 'integer', '>', 1800, ...
   '<', 2020})
% Nominal amount per student
%  Product of revenue * (fraction of revenue from tuition)
tuitionV = numM(:,3) .* numM(:,2);


% ******  Make into base year prices

% Load cpi data (to get common year range)
cpiS = var_load_bc1(cS.vCpi, cS);

% Common year range
year1 = max(cpiS.yearV(1), yearV(1));
year2 = min(cpiS.yearV(end), yearV(end));
fprintf('College cost year range: %i to %i \n', year1, year2);

saveS.yearV = (year1 : year2)';

cpiYrIdxV = saveS.yearV - cpiS.yearV(1) + 1;
yrIdxV = saveS.yearV - yearV(1) + 1;

saveS.tuitionV = tuitionV(yrIdxV) ./ cpiS.cpiV(cpiYrIdxV);

validateattributes(saveS.tuitionV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>', 100, ...
   '<', 2e4})

var_save_bc1(saveS, cS.vCollCosts, cS);



end