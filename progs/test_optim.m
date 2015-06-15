function test_optim
% Test whether it is faster to max a function or to find a 0 of the slope

% Analytical derivative 0
% xOpt = 3;

lb = 1;
ub = 8;

% deriv0 = derivfct(xOpt);
% if abs(deriv0) > 1e-4
%    error('Invalid');
% end


fprintf('Try optimizing function\n');
fminbndOptS = optimset('fminbnd');
fminbndOptS.TolX = 1e-7;


tic
[soln, fVal, exitFlag, outS] = fminbnd(@objfct, lb, ub, fminbndOptS);
toc
disp(soln)
outS


fprintf('\nTry fzero on derivative\n');

fzeroOptS = optimset('fzero');
fzeroOptS.TolX = 1e-7;

tic
[soln, fVal, exitFlag, outS] = fzero(@derivfct, [lb, ub], fzeroOptS);
toc 
disp(soln)
outS


end



% Objective function
function valOut = objfct(xV)
%    valOut = xV - 5 * log(xV + 2);
   valOut = (xV-1) .^ 2 - 4 * log(xV + 1);
end

function derivOut = derivfct(xV)
%    derivOut = 1 - 5 / (xV+2);
   derivOut = 2 .* (xV - 1) - 4 ./ (xV+1);
end