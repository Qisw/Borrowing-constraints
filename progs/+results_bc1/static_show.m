function static_show(saveFigures, setNo, expNo)
% Illustrate static foc
% Vary j, fix c

cS = const_bc1(setNo, expNo);
figS = const_fig_bc1;
paramS = param_load_bc1(setNo, expNo);

% Fix consumption at an arbitrary level
c = 12e3 ./ cS.unitAcct;

hours_jV = nan([cS.nTypes, 1]);
for j = 1 : cS.nTypes
   hours_jV(j) = hh_bc1.hh_static_bc1(c, paramS.wColl_jV(j), j, paramS, cS);
end


fh = output_bc1.fig_new(saveFigures, []);
plot(paramS.m_jV,  1 - hours_jV,  'o',  'color', figS.colorM(1,:));
xlabel('m');
ylabel('Leisure');
figures_lh.axis_range_lh([NaN NaN 0.5 1]);
output_bc1.fig_format(fh, 'line');
output_bc1.fig_save(fullfile(cS.hhDir, 'static_j'), saveFigures, cS);


end