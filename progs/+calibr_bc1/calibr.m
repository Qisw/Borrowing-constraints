function calibr(solverStr, setNo, expNo)
% Run calibration for reference cohort
%{
Can be run with solver 'none' for 0 calibrated params

Checked: 2015-Mar-19
%}

cS = const_bc1(setNo, expNo);

% Make dirs
helper_bc1.mkdir(setNo, expNo);

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

helper_bc1.parpool_open(cS);

if strcmpi(solverStr, 'fminsearch')   % &&  (length(guessV) > 1)
   optS = optimset('fminsearch');
   optS.TolFun = 1e-2;
   optS.TolX = 1e-2;
   [solnV, fVal, exitFlag] = fminsearch(@cal_dev_fminsearch, guessV, optS);


% fminbnd fails b/c it gets stuck at college entry rate = 1
% elseif strcmpi(solverStr, 'fminbnd')  ||  strcmpi(solverStr, 'fminsearch')
%    % Also when some solvers are called with 1 guess
%    optS = optimset('fminbnd');
%    optS.TolFun = 1e-2;
%    optS.TolX = 1e-2;
%    [solnV, fVal, exitFlag] = fminbnd(@cal_dev_nested, cS.guessLb * ones(size(guessV)), ...
%       cS.guessUb * ones(size(guessV)), optS);


elseif strcmpi(solverStr, 'none')  ||  strcmpi(solverStr, 'test')
   % No solver. Just generate results.
   solnV = guessV;

elseif strcmpi(solverStr, 'bobyqa')  ||  strcmpi(solverStr, 'cobyla')  ||  strcmpi(solverStr, 'sbplx')  ||  ...
       strcmpi(solverStr, 'nelder')
   % *****  NLopt solver
   % Initialize NLopt
   if cS.runLocal == 1
      locationStr = 'local';
   else
      locationStr = 'kure';
   end
   optim_lh.nlopt_initialize(locationStr);

   if strcmpi(solverStr, 'bobyqa')
      optS.algorithm = NLOPT_LN_BOBYQA;
      optS.initial_step = 1e-2 .* ones(size(guessV));
   elseif strcmpi(solverStr, 'cobyla')
      optS.algorithm = NLOPT_LN_COBYLA;
      optS.initial_step = 1e-2 .* ones(size(guessV));
   elseif  strcmpi(solverStr, 'sbplx')
      optS.algorithm = NLOPT_LN_SBPLX;
   elseif strcmpi(solverStr, 'nelder')
      optS.algorithm = NLOPT_LN_NELDERMEAD;
   else
      error('Invalid');
   end

   % Solver options
   optS.min_objective = @cal_dev_fminsearch;
   optS.ftol_abs = 1e-2;
   optS.xtol_abs = 1e-2 .* ones(size(guessV));
   optS.maxeval  = 1e3;
   optS.maxtime  = 60 * 3600; % in seconds
   optS.lower_bounds = cS.pvector.guessMin .* ones(size(guessV));
   optS.upper_bounds = cS.pvector.guessMax .* ones(size(guessV));

   [solnV, fVal, exitFlag] = nlopt_optimize(optS, guessV);
end


% Recover parameter vector etc
[~, paramS] = cal_dev_nested(solnV);
[dev, outS, hhS, aggrS] = calibr_bc1.cal_dev(tgS, paramS, cS);


fprintf('Calibration done. Terminal deviation: %.3f \n', dev);

if cS.runLocal == 0
   helper_bc1.parpool_close(cS);
end



%% Save

var_save_bc1(paramS, cS.vParams, cS);
var_save_bc1(outS, cS.vCalResults, cS);
var_save_bc1(hhS, cS.vHhSolution, cS);
var_save_bc1(aggrS, cS.vAggregates, cS);

aggr_bc1.aggr_stats(cS.setNo, cS.expNo);


% Generate results
if ~strcmpi(solverStr, 'test')
   results_all_bc1(cS.setNo, cS.expNo);
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
