function eeDevV = hh_eedev_coll3_bc1(cV, hoursV, kPrimeV, iAbil, vWorkS, paramS, cS)
% Euler equation deviation in college; periods 3-4
%{
eeDev > 0  implies  u'(c) > V_k  =>  raise c

Checked: 2015-mar-20
%}

%% Input check
if cS.dbg > 10
   validateattributes(cV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive'})
   validateattributes(hoursV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '<', 1})
end



%% Main

muKV = vWorkS.muFct_saM{cS.iCG, iAbil}(kPrimeV);

% % Marginal value of capital, discounted to start of work
% muKV = nan(size(cV));
% for i1 = 1 : length(cV)
%    [~,~,~, muKV(i1)] = hh_bc1.hh_work_bc1(kPrimeV(i1), cS.iCG, iAbil, paramS, cS);
% end

ucV = hh_bc1.hh_util_coll_bc1(cV, 1 - hoursV, paramS.prefWt, paramS.prefSigma, ...
      paramS.prefWtLeisure, paramS.prefRho);

% Give up 1/2 c in each period to gain 1 k'
eeDevV = (1 + paramS.prefBeta) .* ucV / 2  -  (paramS.prefBeta .^ 2) .* muKV;


%% Output check
if cS.dbg > 10
   validateattributes(eeDevV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', size(cV)})
end

end