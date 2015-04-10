function pr_xgroup_by_type(setNo)

cS = const_bc1(setNo);
cS.nTypes = 100;
cS.dbg = 111;

mGridV = linspace(-2, 2, cS.nTypes)';
pr_jV  = rand([cS.nTypes, 1]);
pr_jV  = pr_jV ./ sum(pr_jV);

sigmaX = 0.25;

xPctUbV = (0.25 : 0.25 : 1)';
ng = length(xPctUbV);

[prX_jM, xUbV] = calibr_bc1.pr_xgroup_by_type(mGridV, pr_jV, sigmaX, xPctUbV, cS.dbg);


%% Test by simulation

nSim = 1e6;
rng(4);
jV = random_lh.rand_discrete(pr_jV, rand([nSim,1]), cS.dbg);
xV = mGridV(jV) + randn(size(jV)) .* sigmaX;

% *****  Prob of x <= xUbV

[prXUbV, xClassV] = histc(xV, [-1e8; xUbV]);
prXUbV(ng+1) = [];
prXUbV = cumsum(prXUbV(:) ./ nSim);
% prXUbV = nan(size(xUbV));
% for i1 = 1 : length(xUbV)
%    prXUbV(i1) = sum(xV <= xUbV(i1)) ./ nSim;
% end

prDiffV = prXUbV(:) - xPctUbV;
maxDiff = max(abs(prDiffV));
fprintf('Max deviation from prXUbV: %f \n', maxDiff);


% ******  Prob of x | j

cnt_xjM = accumarray([xClassV, jV], 1, [length(xPctUbV), cS.nTypes]);
prSimX_jM = cnt_xjM ./ (ones([ng,1]) * max(1, sum(cnt_xjM)));
validateattributes(prSimX_jM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'size', [ng, cS.nTypes]})

prDiffM = prSimX_jM - prX_jM;
maxDiff2 = max(abs(prDiffM(:)));
fprintf('Max deviation from pr(x|j): %f \n', maxDiff2);

% plot(prSimX_jM(:), prX_jM(:), '.');

[betaV, betaIntV] = regress(prX_jM(:), [ones([ng * cS.nTypes,1]), prSimX_jM(:)], 0.05);

fprintf('Regression betas: %.3f and %.3f \n', betaV);
if any(abs(betaV(:) - [0; 1]) > 0.01)
   error_bc1('Regression should yield 45 degree line', cS);
end


end