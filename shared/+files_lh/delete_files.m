function fileListV = delete_files(baseDir, fileMask, inclSubDir, minAge, askConfirm)
%{
Delete all files in a directory 

IN:
   baseDir
      directory from which to start searching
   fileMask :: String
      file mask such as '*.pdf'
   inclSubDir (bool)
      also search sub dirs?
   minAge :: Integer
      minimum age in days
   askConfirm :: Any
      ask for confirmation unless set to 'noConfirm'

OUT:
   fileListV
      array of struct with info for all deleted files

Depends on rdir
%}


%% Confirmation

if isempty(askConfirm)
   askConfirm = 'x';
end
if ~ischar(askConfirm)
   askConfirm = 'x';
end

if ~strcmpi(askConfirm, 'noConfirm')
   ans1 = input('Delete files?  ', 's');
   if ~strcmpi(ans1, 'yes')
      return;
   end
end



%% List all files in directory
% Would logically be a separate function

fs = filesep;
if inclSubDir
   fileSpec = [baseDir, fs, '**'];
else
   fileSpec = baseDir;
end

if isempty(minAge)
   testStr = [];
else
   testStr = sprintf('datenum < now - %i', minAge);
end

fileListV = rdir(fullfile(fileSpec, fileMask),  testStr);


%% Delete

if length(fileListV) > 0
   for i1 = 1 : length(fileListV)
      delete(fileListV(i1).name);
   end
end

end