function updownload(setNo, expNoV, upDownStr)
% Upload or download sets to kure
%{
Processes all experiments for all sets
%}
% ------------------------------------------------

validateattributes(setNo, {'numeric'}, {'finite', 'nonnan', 'nonempty', 'integer', '>=', 1})
validateattributes(expNoV, {'numeric'}, {'finite', 'nonnan', 'nonempty', 'integer', '>=', 1})

if strcmpi(upDownStr, 'up')
   upLoadStr = 'Upload';
elseif strcmpi(upDownStr, 'down')
   upLoadStr = 'Download';
else
   error('Invalid doUpload');
end



% Check that set is valid
const_bc1(setNo, expNoV(1));

cmdStr = ['osascript /Users/lutz/Dropbox/hc/borrow_constraints/model1/transmit_upload_mat.scpt ', ...
      upLoadStr,  sprintf(' set%03i ', setNo)];
for ix = 1 : length(expNoV)
   cmdStr = [cmdStr, sprintf(' exp%03i ', expNoV(ix))];
end
disp(cmdStr);
system([cmdStr,  ' &']);


end