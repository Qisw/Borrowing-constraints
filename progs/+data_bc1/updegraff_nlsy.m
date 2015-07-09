function updegraff_nlsy

setNo = 7;
saveFigures = 01;
cS = const_bc1(setNo);
figS = const_fig_bc1;

entry_qyM = [
22.5 16.8 18.4 21.8 25.3 36.5 
32.7 21.3 34.8 29.9 29.9 37.1 
31.8 40.1 39.0 30.2 46.2 45.3 
45.0 46.7 43.3 47.5 58.8 70.2 
52.0 50.7 72.4 59.4 79.4 77.0 
79.4 71.2 79.6 77.0 80.9 88.9] ./ 100;

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