function n79S = nlsy79_targets_load(cS)

if cS.tgS.useSesTargets == 1
   n79S = load('/Users/lutz/Dropbox/borrowing constraints/Calibration/July 2015/Results/all_targets_struct.mat');
   n79S = n79S.all_targets;
   
   % Need to rename all "byses" fields into "byinc"
   fnV = fieldnames(n79S);
   for i1 = 1 : length(fnV)
      oldName = fnV{i1};
      if ~isempty(strfind(oldName, 'byses'))
         newName = strrep(oldName, 'byses', 'byinc');
         n79S.(newName) = n79S.(oldName);
         n79S = rmfield(n79S, oldName);
      end
   end
   
else
   n79S = load(fullfile(cS.dataDir, 'nlsy79_moments.mat'));
   n79S = n79S.all_targets;
end


end