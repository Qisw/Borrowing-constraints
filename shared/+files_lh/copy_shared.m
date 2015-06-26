function copy_shared(dirV, nameV, overWrite, sourceBaseDir, tgBaseDir)
% Copy shared programs
%{
IN
   dirV
      list of dirs to be copied entirely
      or: empty (skip copying dirs)
   nameV
      list of files to be copied
      or: empty
%}
% -----------------------------------------

if nargin ~= 5
   error('Invalid nargin');
end



%% Copy entire directories
if ~isempty(dirV)
   for i1 = 1 : length(dirV)
      srcDir = fullfile(sourceBaseDir, dirV{i1});
      tgDir  = fullfile(tgBaseDir,  dirV{i1});
      if ~exist(srcDir, 'dir')
         error('Src dir does not exist');
      end
      if ~exist(tgDir, 'dir')
         files_lh.mkdir_lh(tgDir);
      end
      fprintf('Copying  %s    to    %s \n', srcDir, tgDir);
      copyfile(srcDir, tgDir);
   end
end



%% Copy individual files
if ~isempty(nameV)
   for i1 = 1 : length(nameV)
      nameStr = [nameV{i1}, '.m'];
      disp(['Copying  ',  nameStr]);

      srcPath = fullfile(sourceBaseDir, nameStr);
      tgPath  = fullfile(tgBaseDir, nameStr);

      if exist(srcPath, 'file')
         % Check that tg dir exists
         tgDir1 = fileparts(tgPath);
         if ~exist(tgDir1, 'dir')
            fprintf('Target dir does not exist\n');
            fprintf('  %s \n', tgDir1);
            files_lh.mkdir_lh(tgDir1);
         end
         files_lh.filecopy1(srcPath, tgPath, overWrite);
      else
         warning('Cannot copy %s \nFile does not exist.', srcPath);
      end
   end
end

end