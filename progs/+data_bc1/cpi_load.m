function cpi_load(setNo)
% Load cpi data and save as matrix file
%{
Checked: 2015-Mar-18
%}

cS = const_bc1(setNo);
if cS.expNo ~= cS.expBase
   error('Only for base expNo');
end

% Load file with [year, cpi]
dataM = csvread(fullfile(cS.dataDir, 'cpi_all_urban.txt'));

saveS.yearV = dataM(:,1);
validateattributes(saveS.yearV, {'double'}, {'finite', 'nonnan', 'nonempty', 'integer', '>', 1900, ...
   '<', 2020})

saveS.cpiV = dataM(:,2);

% Convert so that base year has cpi of 1
baseIdx = find(saveS.yearV == cS.cpiBaseYear);
saveS.cpiV = saveS.cpiV ./ saveS.cpiV(baseIdx);

validateattributes(saveS.cpiV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
   'size', [length(saveS.yearV), 1]})

var_save_bc1(saveS, cS.vCpi, cS);

end