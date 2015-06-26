function lock_file_lh(filePath, lockNo, maxTime)
% Lock a file. Wait until file available or maxTime seconds have passed
%{
IN:
   filePath
      path of file to be locked
   lockNo
      id of this lock
   maxTime
      max time to wait for other locks to be removed (seconds)
      this is per existing lock

Steps:
1. Create a lock file
2. Make a list of existing lock files
3. Remove "old" lock files (not implemented)
4. Wait until all existing lock files have been removed or maxTime elapsed
%}
% ==========================================

% Take file name apart
[pathStr, fnStr, extStr] = fileparts(filePath);
if ~isempty(pathStr)
   pathStr = [pathStr, filesep];
end

% Write the lock file to put us in line
fid = fopen(lock_fn_nested(pathStr, fnStr, extStr, lockNo), 'w');
fclose(fid);


% Make list of existing locks
nLocks = 20;
lockCount = 0;
lockNoV = zeros([nLocks,1]);
for i1 = 1 : nLocks
   if i1 ~= lockNo
      % Does lock i1 exist?
      if exist(lock_fn_nested(pathStr, fnStr, extStr, i1), 'file');
         % Record the lock
         lockCount = lockCount + 1;
         lockNoV(lockCount) = i1;
      end
   end
end


% Wait until existing locks are removed
%  or maxTime has elapsed
if lockCount > 0
   tStart = clock;
   done = 0;
   while done == 0
      pause(1);
      % Check whether any of the previous locks still exists
      foundLock = 0;
      for i1 = 1 : lockCount
         if exist(lock_fn_nested(pathStr, fnStr, extStr, lockNoV(i1)), 'file');
            foundLock = 1;
            break;
         end
      end
      % Are we done?
      if foundLock == 0
         done = 1;
      elseif etime(clock, tStart) > maxTime * nLocks
         done = 1;
      end
   end


   % Remove "old" locks
   %  should be based on creation time +++
            %  not clear how to do this
            %  can get file date using dir in datenum format, but how to
            %  compute how old the file is?
   for i1 = 1 : nLocks
      % Does lock exist?
      lockFn = lock_fn_nested(pathStr, fnStr, extStr, lockNoV(i1));
      if exist(lockFn, 'file');
         delete(lockFn);
      end
   end
end

end


%% **** Nested: construct lock file
function lockFnStr = lock_fn_nested(pathStr, fnStr, extStr, lockNo)
   lockFnStr = [pathStr, sprintf('lock%i_', lockNo), fnStr, extStr];
end