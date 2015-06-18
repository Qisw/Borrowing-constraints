function cmdStr = kure_command_bc1(solverStr, setNoV, expNo)
% Create command for submitting a set of jobs on kure
%{
Also copies to clipboard, if run on a local machine

%}

cS = const_bc1(setNoV(1), expNo);

if isempty(solverStr)
   solverStr = 'fminsearch';
end

expStr = sprintf('%i', expNo);

if length(setNoV) == 1
   logStr = sprintf('set%i_%i', setNoV(1), expNo);
   setStr = sprintf('%i', setNoV(1));
else
   % Running multiple
   logStr = sprintf('set%i%i', setNoV(1), setNoV(end));

   % Make a string for set numbers
   if isequal(setNoV(:)', setNoV(1) : setNoV(end))
      % Sequential
      setStr = sprintf('%i:%i', setNoV(1), setNoV(end));
   else
      setStr = sprintf('%i,', setNoV);
      setStr = [ '[', setStr(1 : (end-1)), ']' ];
   end
end


% For parallel
parallelStr = '';
if cS.kureS.parallel == 1
   parallelStr = sprintf(' -n %i -R "span[hosts=1]" ',  cS.kureS.nNodes);
end
   
cmdStr = ['bsub ', parallelStr, ' matlab -nodesktop -nodisplay -nosplash -singleCompThread -r "run_batch_bc1(''',  ...
   solverStr,  ''',0,',  setStr, ',', expStr,  ')" -logfile ',  logStr,  '.out'];

if cS.runLocal
   clipboard('copy', cmdStr);
end
   
end