function download(setNoV, expNoV)
% Down mat files for several sets
% -----------------------------------------

ans1 = input('Download these sets?', 's');
if ~strcmpi(ans1, 'yes')
   return
end

kure_bc1.updownload(setNoV, expNoV, 'down')


end