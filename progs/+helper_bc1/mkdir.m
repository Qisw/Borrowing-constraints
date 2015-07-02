function mkdir(setNo, expNo)
% Make all directories needed

cS = const_bc1(setNo, expNo);

files_lh.mkdir_lh(cS.matDir, cS.dbg);
files_lh.mkdir_lh(cS.outDir, cS.dbg);
files_lh.mkdir_lh(cS.fitDir, cS.dbg);
files_lh.mkdir_lh(cS.paramDir, cS.dbg);
files_lh.mkdir_lh(cS.dataOutDir, cS.dbg);
files_lh.mkdir_lh(cS.hhDir, cS.dbg);

end
