function copy_shared_bc1(dirV, nameV, overWrite)
% Copy shared programs
%{
IN
   dirV
      list of dirs to be copied entirely
      or: empty (skip copying dirs)
      or: 'all' (copy all dirs)
   nameV
      list of files to be copied
      or: empty
      or: 'all'

%}
% -----------------------------------------

if nargin ~= 3
   error('Invalid nargin');
end

global lhS;
sourceBaseDir = lhS.sharedDir;
cS = const_bc1([]);
tgBaseDir = cS.sharedDir;



%% Copy entire directories
if ~isempty(dirV)
   if ischar(dirV)
      if strcmpi(dirV, 'all')
         % Copy all
         dirV = {'export_fig', '+check_lh', '+files_lh', '+latex_lh', '+preamble_lh', '+string_lh', ...
            '+struct_lh'};
      else
         error('Invalid dirV');
      end
   end      
end



%% Copy individual files
if ~isempty(nameV)
   if ischar(nameV)
      if strcmpi(nameV, 'all')
         nameV = {'ismonotonic', 'rdir',  ...
            '+distrib_lh/class_assign', '+distrib_lh/norm_grid', '+distrib_lh/truncated_normal_lh', ...
            '+distrib_lh/cov_w',  '+distrib_lh/weighted_median', ...
            '+figures_lh/axes_same',  '+figures_lh/axis_range_lh', '+figures_lh/const', '+figures_lh/new', ...
            '+figures_lh/format', ...
            '+figures_lh/plot45_lh',  '+figures_lh/fig_save_lh', ...
            '+optim_lh/nlopt_initialize', ...
            '+random_lh/rand_discrete', ...
            '+regress_lh/regr_stats_lh',  '+regress_lh/lsq_weighted_lh', ...
            '+stats_lh/std_w', ...
            '+vector_lh/extrapolate',  '+vector_lh/midpoints',  '+vector_lh/recode_sequential',  '+vector_lh/splice'};
      else
         error('Invalid nameV');
      end
   end
end

files_lh.copy_shared(dirV, nameV, overWrite, sourceBaseDir, tgBaseDir);

end