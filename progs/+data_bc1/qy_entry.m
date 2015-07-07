function qy_entry(saveFigures, setNo)
% For selected historical studies, show entry rates by [iq, yp]

cS = const_bc1(setNo);
figS = const_fig_bc1;

studyFnV = {'updegraff_quartiles', 'updegraff 1936',  'sibley 1948', 'flanagan 1964',  'flanagan 1971',  'nlsy79'};

for iStudy = 1 : length(studyFnV)
   if strcmp(studyFnV{iStudy}, 'nlsy79')
      % Load from cal targets
      tgS = var_load_bc1(cS.vCalTargets, cS);
      entryS.iqUbV = cS.iqUbV;
      entryS.ypUbV = cS.ypUbV;
      entryS.perc_coll_qyM = tgS.fracEnter_qycM(:,:,tgS.icNlsy79);
   else
      % Load the data nicely formatted
      [~, entryS] = data_bc1.load_income_iq_college([studyFnV{iStudy}, '.csv'], setNo);
   end
   
   output_bc1.bar_graph_qy(entryS.perc_coll_qyM, 'Entry rate', saveFigures, cS);
   xlabel(figS.ypGroupStr);
   ylabel(figS.iqGroupStr);
   set(gca, 'XTickLabel', string_lh.vector_to_string_array(entryS.ypUbV .* 100, '%.0f'));
   set(gca, 'YTickLabel', string_lh.vector_to_string_array(entryS.iqUbV .* 100, '%.0f'));
   output_bc1.fig_save(fullfile(cS.dataOutDir, ['qy_entry_', studyFnV{iStudy}]), saveFigures, cS);
end



end