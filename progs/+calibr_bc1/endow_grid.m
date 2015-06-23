function gridM = endow_grid(muV, stdV, wtM, cS)
% Construct the endowment grid
%{
Realized means and std can be quite far off the target ones for reasonably large numbers of types 
(e.g. 80)

IN
   muV(iVar), stdV(iVar)
      mean and std dev of marginals
      variances may be 0
   wtM
      weight each var puts on each random variable
%}
% ---------------------------------------------

n = cS.nTypes;
nVar = length(muV);

rng(3);
randM = randn([n, nVar]);

% % Try: scale random vars to get realized distribution of endowments closer to target
% rMeanV = mean(randM);
% rStdV  = std(randM);
% for iVar = 1 : nVar
%    randM(:, iVar) = (randM(:, iVar) - rMeanV(iVar)) / rStdV(iVar);
% end


%% Input check
if cS.dbg > 10
   validateattributes(muV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'size', [nVar, 1]})
   validateattributes(stdV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'size', [nVar, 1], '>=', 0})
   validateattributes(wtM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'size', [nVar, nVar], ...
      '>', -10, '<', 10})
end


% Make wt matrix to get N(0,1) marginals
gridM = zeros([n, nVar]);
for iVar = 1 : nVar
   wtV = wtM(iVar,:);
   wtV = wtV ./ sqrt(sum(wtV .^ 2)) .* stdV(iVar);
   gridM(:,iVar) = muV(iVar) + randM * wtV(:);
end

% Try: scale outputs so that means and stds are exactly right
gMeanV = mean(gridM);
gStdV = std(gridM);
for iVar = 1 : nVar
   gridM(:, iVar) = (gridM(:, iVar) - gMeanV(iVar)) / max(1e-5, gStdV(iVar)) * stdV(iVar)   +   muV(iVar);
end


if cS.dbg > 10
   validateattributes(gridM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'size', [n, nVar]})
end



end