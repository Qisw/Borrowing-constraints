function pr_iq_aM = pr_iq_a(abilV, prob_aV, sigmaIQ, iqUbV, dbg)
% Pr(IQ in interval defined by iqUbV | a)
%{
a is drawn from a discrete distribution with values abilV and 
probabilities prob_aV

IQ = a + sigmaIQ * N(0,1)

IN
   iqUbV
      percentile upper bounds
      last one must be 1
%}

%% Input check
if dbg > 10
   validateattributes(abilV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
   validateattributes(prob_aV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'positive', '<', 1, 'size', size(abilV)})
   if abs(sum(prob_aV) - 1) > 1e-6
      error('Must sum to 1');
   end
   validateattributes(iqUbV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'positive', '<=', 1})
   if iqUbV(end) ~= 1
      error('Invalid');
   end
end


%% CDF of IQ

nAbil = length(abilV);
nIq = 100;

% Make an IQ grid on which to approximate the cdf
iqV = linspace(abilV(1) - 3 * sigmaIQ, abilV(nAbil) + 3 * sigmaIQ, nIq)';

% Prob IQ <= iqV(i1)
probV = nan([nIq, 1]);
for i1 = 1 : nIq
   % Std normal value of epsilon that yields IQ <= iqV(i1) for each a
   epsV = (iqV(i1) - abilV(:)) ./ sigmaIQ;
   probV(i1) = sum(prob_aV(:) .* normcdf(epsV, 0, 1));
end

validateattributes(probV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
   'size', size(iqV), '>=', 0, '<', 1.0001})

probV = min(probV, 1);
probV(end) = 1.00001;

% Interpolate to get cdf values at iqUbV
iqUbValueV = interp1(probV, iqV, iqUbV, 'linear');
validateattributes(iqUbValueV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
   '>', iqV(1) - 1e-5,  '<', iqV(end) + 1e-5,  'size', size(iqUbV)})


%% Find Pr(iq <= iqUbV percentile | a) for all a

pr_iq_aM = nan([length(iqUbV), nAbil]);

for ia = 1 : nAbil
   % IQ | a ~ N(a, sigmaIQ)
   cdfV = normcdf(iqUbValueV(:), abilV(ia), sigmaIQ);
   cdfV(end) = 1;
   % Prob in interval
   pr_iq_aM(:, ia) = cdfV - [0; cdfV(1 : (end-1))];
end

validateattributes(pr_iq_aM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
   '>=', 0, '<=', 1, 'size', [length(iqUbV), nAbil]})
if any(abs(sum(pr_iq_aM) - 1) > 1e-5)
   error('Probs do not sum to 1');
end


end