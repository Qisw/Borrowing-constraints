function [probM, yGridV, yUbV] = normal_conditional(yProbV, xProbV, xGridV, wt, dbg)
% Compute Prob(y | x) where y|x ~ Normal
%{
Given x ~ N(0,1) on grid xGridV
y = (wt * x + eps) / sqrt(wt^2 + 1) ~ N(0,1)
Construct a y grid with probabilities yProbV
Compute Prob(y grid point | xGridV)

IN
   xProbV
      prob of each x grid point
      used to ensure that yProbV is exactly matched

OUT
   probM(y,x)
      Prob(y | x)
   yGridV
      y grid
   yUbV
      upper bounds of y intervals that form grid
%}
% -------------------------------------------------------------

ny = length(yProbV);
nx = length(xGridV);

%% Input check
if dbg > 10
   validateattributes(yProbV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [ny,1], '>=', 0, '<=', 1})
   validateattributes(xGridV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [nx,1]})
end

pSum = sum(yProbV);
if abs(pSum - 1) > 1e-5
   error('Probs must sum to 1');
end


%% Main

% Make y grid
[yGridV, yUbV] = distrib_lh.norm_grid(0, 1, yProbV, dbg);
yUbV = [yUbV; 1e6];


% Prob(y | x)
probM = zeros([ny, nx]);

% Scale factor for bounds: 
z = ((wt ^ 2 + 1) ^ 0.5);

for ix = 1 : nx
   cdfV = normcdf(yUbV .* z - wt .* xGridV(ix), 0, 1);
   probM(:, ix) = cdfV - [0; cdfV(1 : (end-1))];
end



% ****  Make sure yProbV is matched
for iter = 1 : 50
   % Make sure probs sum to 1
   %  This could mess up Pr(y). How to solve that recursion? +++
   pSumV = sum(probM);
   probM = probM .* (ones([ny,1]) * (1 ./ pSumV(:)'));

   % Check Pr(y)
   % Pr(y) = sum_x  Pr(y|x) * Pr(x)
   prYV = probM * xProbV; 
%    prYV = zeros([ny, 1]);
%    for iy = 1 : ny
%       prYV(iy) = probM(iy,:) * xProbV;
%       probM(iy,:) = probM(iy,:) ./ prY .* yProbV(iy);
%    end

   % Stop if y probs close enough
   if max(abs(prYV - yProbV)) < 1e-3
      break;
   else
      % Scale Pr(y|x) to match pr(y)
      probM = probM .* ((yProbV ./ prYV) * ones([1,nx]));
   end
end


%% Output check
if dbg > 10
   validateattributes(probM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      '>=', 0, '<=', 1, 'size', [ny,nx]})
   
   % ****  Make sure yProbV is matched
   for iy = 1 : ny
      % Pr(y) = sum_x  Pr(y|x) * Pr(x)
      prY = probM(iy,:) * xProbV;
      if abs(prY - yProbV(iy)) > 1e-3
         error('wrong PrY');
      end
   end
   
   % **** Make sure probs sum to 1
   if max(abs(sum(probM) - 1)) > 1e-5
      error('Probs do not sum to 1');
   end
end

end