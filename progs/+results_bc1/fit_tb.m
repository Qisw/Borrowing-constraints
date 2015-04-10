function fit_tb(setNo, expNo)
% Table with model fit
%{
Table structure
   Description | model | data
%}

cS = const_bc1(setNo, expNo);
% tgS = var_load_bc1(cS.vCalTargets, cS);
outS = var_load_bc1(cS.vCalResults, cS);


%% Table structure

nr = 1 + outS.devV.n;
nc = 3;

tbM = cell([nr, nc]);
tbS.rowUnderlineV = zeros([nr,1]);

tbM(1,:) = {'Description', 'Model', 'Data'};
tbS.rowUnderlineV(1) = 1;

%% Body

ir = 1;

for i1 = 1 : outS.devV.n
   % Get deviation structure
   devS = outS.devV.dsV{i1};
   ir = ir + 1;
   tbM{ir,1} = devS.longStr;

   modelV = devS.modelV;
   if length(modelV) <= 4  && isvector(modelV)
      % Show directly
      tbM{ir,2} = formatted_vector(modelV, devS.fmtStr, cS);
      tbM{ir,3} = formatted_vector(devS.dataV, devS.fmtStr, cS);
   end
end


%% Write table

latex_lh.latex_texttb_lh(fullfile(cS.tbDir, 'fit.tex'), tbM, 'Caption', 'Label', tbS);


end


%% Local: Format a vector
function outStr = formatted_vector(dataV, fmtStr, cS)
   if strcmpi(fmtStr, 'dollar')
      [numStringV, numString1] = string_lh.dollar_format(dataV .* cS.unitAcct, ',', 0);
      if length(dataV) == 1
         outStr = numString1;
      else
         outStr = strjoin(numStringV, ', ');
      end
   else
      outStr = string_lh.string_from_vector(dataV, fmtStr);
   end

end