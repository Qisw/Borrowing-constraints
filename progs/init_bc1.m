function init_bc1

fprintf('\nStartup borrowing constraints model 1\n');

cS = const_bc1([]);

addpath(cS.progDir);
addpath(cS.sharedDir);
addpath(fullfile(cS.sharedDir, 'export_fig'));

setNo = cS.setDefault;
expNo = cS.expBase;
cS = const_bc1(setNo, expNo);

helper_bc1.parpool_open(cS);

end