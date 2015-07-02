function delete_results(setNo, expNo, noConfirm)
% Delete all results for an experiment
% To ensure that no old files stick around

cS = const_bc1(setNo, expNo);

if nargin < 3
   noConfirm = 'x';
end
if ~ischar(noConfirm)
   noConfirm = 'x';
end

if ~strcmp(noConfirm, 'noConfirm')
   % Ask for confirmation
   disp('Delete this folder:');
   disp(cS.outDir);
   ans1 = input('Confirm deletion?  ', 's');
   if ~strcmp(ans1, 'yes')
      return;
   end
end

% Remove the whole folder including sub-folders
rmdir(cS.outDir, 's');

% Make the folder again
files_lh.mkdir_lh(cS.outDir);

end