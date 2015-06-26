function run_batch_bc1(solverStr, perturbGuess, setNoV, expNo)
% Runs batch code on kure
%{
For single setNo: run calibration
For multiple setNos: submit one batch job per calibration

IN:
   solverStr
      'exper'
         run all experiments without recalibrating the model
%}
% --------------------------------------------

init_bc1;

% Need to run this once (only) for parallel
% configCluster; 


cS = const_bc1(setNoV(1), expNo);
if cS.runLocal == 1
   error('Can only run on kure');
end

if length(setNoV) == 1
   if strcmpi(solverStr, 'exper')
      % Just run experiments
      % But also calibrate with 'none' so that we are sure to have current base results
      calibr_bc1.calibr('none', setNoV, cS.expBase);
      exper_all_bc1(setNoV);
      
   else
      % A single job
      calibr_bc1.calibr(solverStr, setNoV, expNo);
   end
   
else
   % Multiple jobs
   for setNo = setNoV(:)'
      fprintf('Submitting job for set %i /%i \n', setNo, expNo);
      submit_job(solverStr, perturbGuess, setNo, expNo)
   end
end


end




%% Local: submit a job as a separate job
function submit_job(solverStr, perturbGuess, setNo, expNo)
   error('Not implemented');
   cmdStr = kure_command_bc1(solverStr, setNo, expNo);
   system(cmdStr);
end