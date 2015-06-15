function fig_format(fh, figType)

if nargin < 2
   figType = 'line';
end

figS = const_fig_bc1;

figures_lh.format(fh, figType, figS);


end