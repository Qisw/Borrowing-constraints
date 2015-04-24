function axes_same(fhV, axisV)
% Set all figure axes the same
%{
Set the max axis range of all figures
axisV overrides that
%}
% ------------------------------------------

if ~isempty(axisV)
   if length(axisV) ~= 4
      error('Invalid axisV');
   end
end


% Find max axis dimensions of all figures
axisValV = axis(fhV(1));
if length(fhV) > 1
   for i1 = 2 : length(fhV)
      % Get x axis limits
      xV = get(fhV(i1), 'xlim');
      yV = get(fhV(i1), 'ylim');
      axisNewV = [xV, yV];
      axisValV([1,3]) = min(axisValV([1,3]), axisNewV([1,3]));
      axisValV([2,4]) = max(axisValV([2,4]), axisNewV([2,4]));
   end
end

% Override
if ~isempty(axisV)
   idxV = find(~isnan(axisV));
   if ~isempty(idxV)
      axisValV(idxV) = axisV(idxV);
   end
end


for i1 = 1 : length(fhV)
   axis(fhV(i1), axisValV);
end

end
