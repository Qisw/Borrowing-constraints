function exitFlag = mkdir_lh(dirName, dbg)
% Make a directory, if it does not exist
%{
% Input is a full path
% Algorithm:
%  Break path into list of directories
%  Create sequentially all that are needed

% OUT:
%  exitFlag
%     1: created
%     0: exists
%     -1: failed
%}
% ------------------------------------------------

if nargin < 2
   dbg = 1;
end

% For testing: show but do not do anything
showOnly = 0;

fs = filesep;

if ~ischar(dirName)
   error('String required');
end

% Reject if name contains period. Then assume it is a file name
%  Cannot do that. Fails on Kure
% idxV = strfind(dirName, '.');
% if length(idxV) > 0
%    warnmsg([ mfilename, ':  Directory name contains period' ]);
%    keyboard;
% end

% If input dir does not end in '\', append it
if dirName(end) ~= fs
   dirName = [dirName, fs];
end

% Make sure this is a directory, not a file name
% Does not work: there is no way of telling this from a file name
if 0
   pathName = fileparts(dirName);
   if dirName(end) == fs
      pathName = [pathName, fs];
   end
   if length(pathName) ~= length(dirName)
      warnmsg([ mfilename, ':  Not a directory?' ]);
      keyboard;
   end
end

% Find all occurences of character separating subdirs
idxV = strfind(dirName, fs);
if length(idxV) < 1
   error('Not a valid dir');
end



% Does directory exist?
if exist(dirName, 'dir')
   exitFlag = 0;

else
   exitFlag = -1;

   % For each level, check whether it exists
   for i1 = 2 : length(idxV)
      currDirStr = dirName(1 : idxV(i1));
      if exist(currDirStr, 'dir')
         if showOnly == 1
            disp([currDirStr,  ' exists']);
         end
      else
         % Make the dir in its parent
         parentStr = dirName(1 : idxV(i1-1));
         newStr = dirName(idxV(i1-1) + 1 : idxV(i1));
         if length(newStr) < 2
            error('2 sequential backslashes');
         end
         disp(['Creating  ',  parentStr,  '  -  ',  newStr]);
         if showOnly == 1
            exitFlag = 1;
         else
            mkdir(parentStr, newStr);
            exitFlag = 1;
         end
      end
   end
end

end % eof
