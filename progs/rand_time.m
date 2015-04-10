function x = rand_time(clockV)
% Return a random number based on current time
% in [0, 1]
% Only random over longer intervals

if nargin < 1
   clockV = [];
end
if isempty(clockV)
   xV = clock;
else
   xV = clockV;
end


x = xV(6) ./ 60;

end