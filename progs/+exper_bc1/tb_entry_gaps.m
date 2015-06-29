function tb_entry_gaps(expNoV, outDir, cS)
% Gap in entry rates by [iq, yp]
%{ 
Alternative to the regressions
%}

   setNo = cS.setNo;
   [modelIqV, modelYpV, dataIqV, dataYpV, bYearV] = exper_bc1.entry_gaps(setNo, expNoV);
   nx = length(expNoV);
   fmtStr = '%.2f';
   
   nc = 3;
   nr = 1 + 3 * nx;
   
   tbM = cell([nr, nc]);
   tbS.rowUnderlineV = zeros([nr, 1]);
   
   ir = 1;
   tbM(ir, :) = {'Entry gap', 'by IQ', 'by yp'};
   tbS.rowUnderlineV(ir) = 1;
   
   for ix = 1 : nx      
      cS = const_bc1(setNo, expNoV(ix));
      ir = ir + 1;
      tbM{ir, 1} = cS.expS.expStr;  % sprintf('Cohort %i',  bYearV(ix));
      
      ir = ir + 1;
      tbM(ir, :) = {'Model',  sprintf(fmtStr, modelIqV(ix)), sprintf(fmtStr, modelYpV(ix))};
      ir = ir + 1;
      tbM(ir, :) = {'Data',  sprintf(fmtStr, dataIqV(ix)), sprintf(fmtStr, dataYpV(ix))};
   end
   
   latex_lh.latex_texttb_lh(fullfile(outDir, 'entry_gap.tex'), tbM, 'Caption', 'Label', tbS);
end