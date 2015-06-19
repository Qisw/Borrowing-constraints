function bar_graph_qy(model_qyM, zStr, saveFigures, cS)
% Show a bar graph by [IQ, yp] quartile

figS = const_fig_bc1;

fh = output_bc1.fig_new(saveFigures, []);
bar3(model_qyM);
xlabel('Parental income quartile');
ylabel('IQ quartile');
colormap(figS.colorMap);
view([-135, 30]);
zlabel(zStr);
output_bc1.fig_format(fh, 'bar');
      
end