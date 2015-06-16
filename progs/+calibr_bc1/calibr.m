function calibr(solverStr, setNo, expNo)
% Run calibration for reference cohort
%{
Can be run with solver 'none' for 0 calibrated params

Checked: 2015-Mar-19
%}

cS = const_bc1(setNo, expNo);
% Load param guesses. Impose exogenous params. Copy params from baseline if needed
paramS = param_load_bc1(setNo, expNo);
tgS = var_load_bc1(cS.vCalTargets, cS);
% This determines which params are calibrated
doCalV = cS.doCalV;

fprintf('\nCalibration %i / %i\n', setNo, expNo);


%% Make guesses (and test them)

% Make guesses from param vector
guessV = cS.pvector.guess_make(paramS, doCalV);
fprintf('  %i calibrated parameters \n', length(guessV));

% Test guess extraction
if rand_time < 0.01
   fprintf('Testing guess extraction \n');
   % Try running directly with paramS
   [dev, outS, hhS, aggrS] = calibr_bc1.cal_dev(tgS, paramS, cS);
   % Now the same with the guess
   dev2 = cal_dev_nested(guessV);

   if abs(dev2 - dev) > 1e-6
      error_bc1('Guesses not correct', cS);
   end
end

% Make sure that each guess affects the objective function
if 0
   fprintf('\nChecking that all guesses affect objective\n');
   dGuess = 0.1;
   dev0 = cal_dev_nested(guessV);
   devV = zeros(size(guessV));
   for i1 = 1 : length(guessV)
      guess2V = guessV;
      if guessV(i1) < cS.guessUb - dGuess
         guess2V(i1) = guessV(i1) + dGuess;
      else
         guess2V(i1) = guessV(i1) - dGuess;
      end
      devV(i1) = cal_dev_nested(guess2V);
      fprintf('  Change in dev for guess %i: %.4f \n',  i1, devV(i1) - dev0);
      if abs(devV(i1) - dev0) < 1e-3
         warning('Small change');
      end
   end
   keyboard;  
end


%% Optimization

if cS.runParallel == 1
   pPool = parpool(cS.nNodes);
end

if strcmpi(solverStr, 'fminsearch');
   optS = optimset('fminsearch');
   optS.TolFun = 1e-2;
   optS.TolX = 1e-2;
   [solnV, fVal, exitFlag] = fminsearch(@cal_dev_fminsearch, guessV, optS);

elseif strcmpi(solverStr, 'none')
   % No solver. Just generate results.
   solnV = guessV;
end


% Recover parameter vector etc
[~, paramS] = cal_dev_nested(solnV);
[dev, outS, hhS, aggrS] = calibr_bc1.cal_dev(tgS, paramS, cS);


fprintf('Calibration done. Terminal deviation: %.3f \n', dev);


% If a parallel pool is open: close it
delete(gcp('nocreate'));


%% Save

var_save_bc1(paramS, cS.vParams, cS);
var_save_bc1(outS, cS.vCalResults, cS);
var_save_bc1(hhS, cS.vHhSolution, cS);
var_save_bc1(aggrS, cS.vAggregates, cS);

% Generate results
results_all_bc1(cS.setNo, cS.expNo);

% Run all experiments
if ~strcmpi(solverStr, 'none')
   exper_all_bc1(cS.setNo, cS.expNo);
end


%% Nested: objective function
   function [dev, param2S] = cal_dev_nested(guessV)
      %fprintf('  %.3f  ', guessV(1:8));
      %fprintf('\n');
      
      % Extract the guesses
      param2S = cS.pvector.guess_extract(guessV, paramS, doCalV);
      param2S = param_derived_bc1(param2S, cS);
      dev = calibr_bc1.cal_dev(tgS, param2S, cS);
   end

   % Same, but reject out of bounds guesses
   function [dev, param2S] = cal_dev_fminsearch(guessV)
      if any(guessV < cS.pvector.guessMin)  ||  any(guessV > cS.pvector.guessMax)
         dev = 1e8;
         param2S = nan;
      else
         [dev, param2S] = cal_dev_nested(guessV);
      end
   end


end