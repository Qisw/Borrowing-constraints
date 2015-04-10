function gridM = endow_grid(muV, stdV, wtM, cS)
% Construct the endowment grid
%{
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


%% Input check
if cS.dbg > 10
   validateattributes(muV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'size', [nVar, 1]})
   validateattributes(stdV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'size', [nVar, 1], '>=', 0})
   validateattributes(wtM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'size', [nVar, nVar], ...
      '>', -10, '<', 10})
end


% Make wt matrix to get N(0,1) marginals
%wt2M = zeros([nVar, nVar]);
gridM = zeros([n, nVar]);
for iVar = 1 : nVar
   wtV = wtM(iVar,:);
   wtV = wtV ./ sqrt(sum(wtV .^ 2)) .* stdV(iVar);
   gridM(:,iVar) = muV(iVar) + randM * wtV(:);
end

if cS.dbg > 10
   validateattributes(gridM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'size', [n, nVar]})
end



end