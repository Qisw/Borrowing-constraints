function midV = midpoints(xV)
% Return midpoints of points given in vector xV
% Just the means of each pair of adjacent points

midV = 0.5 .* (xV(1 : (end-1)) + xV(2 : end));

end