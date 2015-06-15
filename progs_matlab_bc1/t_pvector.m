function t_pvector
% Test code for pvector class

doCalV = 0 : 2;
n = 14;
pv = pvector(n, doCalV);

paramS.blank = 1;

% Add objects
for i1 = 1 : n
   nameStr = sprintf('var%i', i1);
   valueV = randn([i1,1]);
   doCal = randi([doCalV(1), doCalV(end)], [1,1]);
   pv = pv.change(nameStr, sprintf('x%i', i1), sprintf('descr %i', i1), valueV, ...
      -4 .* ones([i1,1]), 4 .* ones([i1,1]), doCal);
   paramS.(nameStr) = valueV;
end

% Make guess vector
guessV = pv.guess_make(paramS, doCalV(2));

% Make parameter struct from guess
param2S = pv.guess_extract(guessV, paramS, doCalV(2));

% Make guess vector again and check that it is unchanged
guess2V = pv.guess_make(param2S, doCalV(2));

if max(abs(guess2V - guessV)) > 1e-8
   error('Guess not correctly recovered');
end




end