function updegraff_nlsy
% Bar graph for slides: NLSY replication of Updegraff
% Not robust, just for slides

setNo = 7;
saveFigures = 01;
cS = const_bc1(setNo);
figS = const_fig_bc1;


% Using SES
entry_qyM = [
   24.67552	31.54116	28.62975	40.02763	54.33677	64.00625
   30.64499	25.85996	60.81287	68.69203	31.22744	79.31603
   20.39589	32.83316	45.80353	57.92837	72.95082	69.06993
   34.22921	61.21851	51.82598	67.43656	75.32455	93.2047
   53.71689	63.79051	76.16116	81.50579	85.15569	94.44366
   49.58253	59.91279	89.46138	89.56895	95.18868	97.04963]' ./ 100;


% Using fam income
% entry_qyM = [
% 22.5 16.8 18.4 21.8 25.3 36.5 
% 32.7 21.3 34.8 29.9 29.9 37.1 
% 31.8 40.1 39.0 30.2 46.2 45.3 
% 45.0 46.7 43.3 47.5 58.8 70.2 
% 52.0 50.7 72.4 59.4 79.4 77.0 
% 79.4 71.2 79.6 77.0 80.9 88.9] ./ 100;

ypUbV = [31 45 61 73 86 100] ./ 100;
iqUbV = [32 47 62 74 85 100] ./ 100;


fh = output_bc1.fig_new(saveFigures, []);
output_bc1.bar_graph_qy(entry_qyM, 'Entry rate', saveFigures, cS)
xlabel(figS.ypGroupStr);
ylabel(figS.iqGroupStr);
set(gca, 'XTickLabel', string_lh.vector_to_string_array(ypUbV .* 100, '%.0f'));
set(gca, 'YTickLabel', string_lh.vector_to_string_array(iqUbV .* 100, '%.0f'));
% output_bc1.fig_format(fh, 'bar');
output_bc1.fig_save(fullfile(cS.dataOutDir, 'updegraff_nlsy'), saveFigures, cS);



end