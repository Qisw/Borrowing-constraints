function endow_grid_test(setNo)

cS = const_bc1(setNo);
rng(3);

fprintf('\nTesting endowment grid\n');

cS.dbg = 111;
cS.nTypes = 1e5;

n = 5;
muV = randn([n,1]) * 3;
stdV = rand([n,1]);

% Weight matrix
%  Row 1 is [1, 0, 0]
%  Row 2 is [x, 1, 0] etc
wtM = zeros([n,n]);
for i1 = 1 : n
   wtM(i1, 1 : i1) = 1 + 2 * randn([1, i1]);
   wtM(i1,i1) = 1;
end

fprintf('Weight matrix: \n');
disp(wtM)

gridM = calibr_bc1.endow_grid(muV, stdV, wtM, cS);

corrM = corrcoef(gridM);

fprintf('Correlation matrix: \n');
disp(corrM)


%% Check means

meanV = mean(gridM);
meanDiffV = meanV(:) - muV;
maxDiff = max(abs(meanDiffV));
fprintf('Max abs mean diff: %.3f \n',  maxDiff);
if maxDiff > 0.02
   error_bc1('Mean diff too high', cS);
end


%% Check std

stdGridV = std(gridM);
stdDiffV = stdGridV(:) - stdV;
maxDiff2 = max(abs(stdDiffV));
fprintf('Max abs std diff: %.3f \n', maxDiff2);
if maxDiff2 > 0.01
   error_bc1('Std diff too high', cS);
end


%% Check that raising a weight increases the correlation

for i1 = 1 : n
   i2V = 1 : n;
   i2V(i1) = [];
   for i2 = i2V(:)'
      wt2M = wtM;
      wt2M(i1,i2) = wtM(i1,i2) + 0.5;
      grid2M = calibr_bc1.endow_grid(muV, stdV, wt2M, cS);
      corr2M = corrcoef(grid2M);
      if corr2M(i1,i2) <= corrM(i1,i2)
         fprintf('Correlation %i / %i did not rise (%.3f to %.3f) \n', i1, i2,  corrM(i1,i2), corr2M(i1,i2));
      end
   end
end

end