function delete_old_results(setNo, expNo, minAge, askConfirm)
% Delete result files older than minAge days in a set
%{
IN
   expNo
      if []: delete for all experiments (everything that hangs off set)
%}

validateattributes(minAge, {'double'}, {'finite', 'nonnan', 'nonempty', 'integer', '>', 1})



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


%% Delete

if isempty(expNo)
   cS = const_bc1(setNo);
   baseDir = cS.setOutDir;
else
   cS = const_bc1(setNo, expNo);
   baseDir = cS.outDir;
end

inclSubDir = true;
extV = {'pdf', 'tex', 'txt', 'fig'};
for i1 = 1 : length(extV)
   fileMask = ['*.', extV{i1}];
   files_lh.delete_files(baseDir, fileMask, inclSubDir, minAge, 'noConfirm');
end



end