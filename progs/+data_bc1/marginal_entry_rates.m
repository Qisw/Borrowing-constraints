function marginal_entry_rates(iqYpStr, saveFigures, setNo)
% Marginal entry rates by [iq, yp]

cS = const_bc1(setNo);
byIq = strcmpi(iqYpStr, 'iq');
fprintf('\nMarginal entry rates ');

if byIq == 1
   entryDir = '/Users/lutz/Dropbox/borrowing constraints/data/iq x college';
   fprintf('by IQ \n');
   prefixStr = 'iq_';
else
   entryDir = '/Users/lutz/Dropbox/borrowing constraints/data/income x college';
   fprintf('by yp \n');
   prefixStr = 'yp_';
end
filesV = dir(fullfile(entryDir, '*.csv'));

boundV = [0.25, 0.75];

% Loop over files
n = length(filesV);
yearV = zeros(n, 1);
nameV = cell(n, 1);
entry25V = zeros(n, 1);
entry75V = zeros(n, 1);
validV = ones(n, 1);

for i1 = 1 : length(filesV)
   % Load the table
   tmpV = strsplit(filesV(i1).name, ' ');
   nameV{i1} = tmpV{1};
   tmpV = strsplit(tmpV{end}, '.');
   yearV(i1) = str2num(tmpV{1});
   fprintf('%s  %i  ',  nameV{i1}, yearV(i1));
   
   loadFn = fullfile(entryDir, filesV(i1).name);
   loadM = readtable(loadFn);

   % Only keep all reces / sexes
   idxV = find(strcmp(loadM.gender, 't')  &  strcmp(loadM.race, 't'));
   if length(idxV) < 4
      fprintf('Not enough bins \n');
      validV(i1) = 0;
   end
   if ~isnumeric(loadM.perc_coll)
      % This happens when there are data errors (divide by 0 etc)
      fprintf('perc_coll not numeric \n');
      validV(i1) = 0;
   end
      
   if validV(i1) == 1
      loadM = loadM(idxV, :);
      if byIq == 1
         ypUbV = loadM.upper_ac ./ 100; 
      else
         ypUbV = loadM.upper_fam ./ 100;
      end
      entryV = loadM.perc_coll ./ 100;
      
      if ypUbV(1) > boundV(1)  ||  ypUbV(end) < boundV(2)
         validV(i1) = 0;
         fprintf('Bins not wide enough:  %.2f to %.2f \n',  ypUbV(1), ypUbV(end));
      else
         % Interpolate
         yMidV = vector_lh.midpoints([0; ypUbV(:)]);
         interpV = interp1(yMidV, entryV,  boundV,  'linear');
         entry25V(i1) = interpV(1);
         entry75V(i1) = interpV(2);
         fprintf('\n');
      end
   end
end


%% Show

gapV = entry75V - entry25V;
sortM = sortrows([yearV, (1 : n)']);
idxV  = sortM(:, 2);

for i1 = idxV(:)'
   if validV(i1) == 1
      fprintf('%s  %i \n', nameV{i1}, yearV(i1));
      fprintf('    %5.2f -> %5.2f    gap: %.2f \n',  entry25V(i1), entry75V(i1),  entry75V(i1) - entry25V(i1));
   end
end


if 1
   fh = output_bc1.fig_new(saveFigures, []);
   idxV = find(validV == 1);
   plot(yearV(idxV),  gapV(idxV), 'o');
   xlabel('Year');
   ylabel('Entry rate gap');
   output_bc1.fig_format(fh, 'line');
   output_bc1.fig_save(fullfile(cS.dataOutDir, [prefixStr, 'entry_gaps']),  saveFigures, cS);
end


end