function outV = splice(mainV, altV, nOverlap, dbg)
% Splice 2 vectors together, matching levels for overlapping years
%{
We have a vector mainV with missing values (NaN)
We have a second vector altV without missing values
Keep mainV where available. 
Where not available, use altV
Adjust level of altV so that it matches mean level of mainV at first / last nOverlap observations

Assumes no Nan values in interior of mainV or altV
%}

outV = mainV;
if any(isnan(mainV))
   nIdxV = find(~isnan(mainV));
   
   % At the start
   if nIdxV(1) > 1
      % Range for matching levels
      mIdxV = (nIdxV(1) - 1) + (1 : nOverlap);
      mainMean = mean(mainV(mIdxV));
      altMean  = mean(altV(mIdxV));
      newIdxV = 1 : (nIdxV(1) - 1);
      outV(newIdxV) = altV(newIdxV) - altMean + mainMean;
   end
   
   % At the end
   n = length(mainV);
   if nIdxV(end) < n
      % Range for matching levels
      mIdxV = (nIdxV(end) - nOverlap) + (1 : nOverlap);
      mainMean = mean(mainV(mIdxV));
      altMean  = mean(altV(mIdxV));
      newIdxV = (nIdxV(end) + 1) : n;
      outV(newIdxV) = altV(newIdxV) - altMean + mainMean;
   end
end


if dbg > 10
   validateattributes(outV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
end


end