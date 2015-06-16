function calibr(setNo)
% Test of calibration routines

cS = const_bc1(setNo);
cS.dbg = 111;

fprintf('\nTesting calibration routines \n\n');

% test_bc1.pr_iq_a;

% Endowment grid
calibr_bc1.endow_grid_test(setNo);

% %% Endowment grid
% 
% fprintf('Testing endowment grid \n');
% 
% c2S = cS;
% c2S.nTypes = 1e5;
% nVar = 4;
% muV = randn([nVar, 1]);
% stdV = rand([nVar, 1]);
% wtM = randn([nVar, nVar]) .* 2;
% 
% gridM = calibr_bc1.endow_grid(muV, stdV, wtM, c2S);
% 
% muGridV = mean(gridM);
% stdGridV = std(gridM);
% muDiffV = muGridV(:) - muV;
% stdDiffV = stdGridV(:) - stdV;
% if max(abs(muDiffV)) > 1e-2  ||  max(abs(stdDiffV)) > 1e-2
%    error_bc1('Grid is off', cS);
% end
% 

end