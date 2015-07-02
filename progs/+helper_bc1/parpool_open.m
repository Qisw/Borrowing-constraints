function parpool_open(cS)
% Open parallel pool

if cS.runParallel == 1
   if cS.runLocal == 1
      % new syntax
      pPool = gcp('nocreate');
      if isempty(pPool)
         pPool = parpool(cS.parProfileStr, cS.nNodes);
      end
   else
      % old syntax
      if matlabpool('size') < 2
         if isempty(cS.parProfileStr)
            % Default profile
            matlabpool(cS.nNodes);
         else
            matlabpool(cS.parProfileStr, cS.nNodes);
         end
      end
   end
end


end