function result = approx_equal(x1M, x2M, absToler, relToler)
% Check whether 2 matrices are approximately equal

result = false;
if ~isequal(size(x1M), size(x2M))
   return;
end
if ~isempty(absToler)
   if any(abs(x1M(:) - x2M(:)) > absToler)
      return;
   end
end
if ~isempty(relToler)
   if any(abs(x2M(:) ./ max(1e-8, x1M(:)) - 1) > relToler)
      return;
   end
end

result = true;

end