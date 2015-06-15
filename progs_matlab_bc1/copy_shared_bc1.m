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
         dirV = {'export_fig', '+preamble_lh'};
      else
         error('Invalid dirV');
      end
   end      
end



%% Copy individual files
if ~isempty(nameV)
   if ischar(nameV)
      if strcmpi(nameV, 'all')
         nameV = {'copy_shared_lh', 'ismonotonic', 'text_table_lh', ...
            '+distrib_lh/class_assign', '+distrib_lh/norm_grid', '+distrib_lh/truncated_normal_lh', ...
            '+distrib_lh/cov_w',  '+distrib_lh/weighted_median', ...
            '+figures_lh/axes_same',  '+figures_lh/axis_range_lh', '+figures_lh/const', '+figures_lh/new', ...
            '+figures_lh/format', ...
            '+figures_lh/plot45_lh',  '+figures_lh/fig_save_lh', ...
            '+files_lh/fn_complete', '+files_lh/mkdir_lh', ...
            '+latex_lh/corr_table',  '+latex_lh/latex_texttb_lh', '+latex_lh/latex_table_lh', ...
            '+random_lh/rand_discrete', ...
            '+regress_lh/regr_stats_lh',  '+regress_lh/lsq_weighted_lh', ...
            '+stats_lh/std_w', ...
            '+string_lh/dollar_format', '+string_lh/string_from_vector', ...
            '+struct_lh/comp_struct',  '+struct_lh/merge'};
      else
         error('Invalid nameV');
      end
   end
end

copy_shared_lh(dirV, nameV, overWrite, sourceBaseDir, tgBaseDir);

end