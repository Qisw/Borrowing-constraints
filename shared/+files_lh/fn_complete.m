function fOut = fn_complete(fName, fDir, fExt, dbg)
% Complete a file name
%{
IN:
   fName
      may contain dir and extension (or not)
      if no dir: prepend fDir
      if no ext: append fExt
%}

[fDir1, fName1, fExt1] = fileparts(fName);

if isempty(fDir1)  &&  ~isempty(fDir)
   fDir1 = fDir;
end
if isempty(fExt1)  &&  ~isempty(fExt)
   fExt1 = fExt;
   % Add the period if needed
   if ~isequal(fExt1(1), '.')
      fExt1 = ['.', fExt1];
   end
end

fOut = fullfile(fDir1, [fName1, fExt1]);



end