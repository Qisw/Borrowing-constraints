function parpool_close(cS)

% If a parallel pool is open: close it
if cS.runLocal == 1
   % new syntax
   delete(gcp('nocreate'));
else
   % old syntax
   if matlabpool('size') > 0
      matlabpool close;
   end
end


end