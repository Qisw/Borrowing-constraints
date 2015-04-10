function md = weighted_median(xV, wtV, dbg)
% Median for weighted data
%{
% TASK:
%  Uses interpolation
%  Weights need not sum to one

% IN:
%  xV(n)       data
%  wtV(n)      weights

% OUT:
%  md          median

% AUTHOR: Lutz Hendricks, 1999
% TEST: t_wt_median.m
%}
% ---------------------------------------

if nargin < 3
   dbg = 1;
end

if dbg > 10
   n = length(xV);
   if ~v_check( xV(:),  'f', [n,1], [], [], [] )
      error('Invalid x');
   end
   if ~v_check( wtV(:), 'f', [n,1], 0, [], [] );
      error('Invalid wt');
   end
end


sortM = sortrows([xV(:), wtV(:)./sum(wtV(:))], 1);

% Cannot use interp1 here (x may have duplicate values)
md = intrp_1( cumsum(sortM(:,2)), sortM(:,1), 0.5, dbg );


end
