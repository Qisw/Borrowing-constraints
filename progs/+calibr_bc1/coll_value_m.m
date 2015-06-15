function vmS = coll_value_m(vColl3S, vWorkS, paramS, cS)
% Value of college at end of periods 1-2, before ability is learned

vmS.kGridV = vColl3S.kGridV;
nk = length(vmS.kGridV);
vmS.value_kjM = nan([nk, cS.nTypes]);
vmS.vmFct_jV = cell([cS.nTypes, 1]);

% Value of dropping out by [k,a]
vDrop_kaM = nan([nk, cS.nAbil]);
for iAbil = 1 : cS.nAbil
   vDrop_kaM(:, iAbil) = vWorkS.vFct_saM{cS.iCD, iAbil}(vmS.kGridV);
end

% Prob of graduating by [k,a]
prGrad_kaM = ones([nk,1]) * paramS.prGrad_aV(:)';

for j = 1 : cS.nTypes
   % Value = (sum over a) of  [Prob(a) * {prGrad(a) * vWork(a)} + {(1-prGrad(a)} * vStudy(a)}]
   %  for each k
   vmS.value_kjM(:,j) = sum((ones([nk,1]) * paramS.prob_a_jM(:,j)') .* ...
      ((1 - prGrad_kaM) .* vDrop_kaM  +  prGrad_kaM .* vColl3S.value_kajM(:,:,j)), 2);
   
   % More explicit code
   if cS.dbg > 10
      vStudy_kaM = vColl3S.value_kajM(:,:,j);
      for ik = 1 : nk
         value_kj = sum(paramS.prob_a_jM(:,j) .* ((1 - paramS.prGrad_aV) .* vDrop_kaM(ik,:)' + ...
            paramS.prGrad_aV .* vStudy_kaM(ik,:)'));
         if abs(value_kj - vmS.value_kjM(ik,j)) > 1e-5
            error_bc1('Invalid code', cS);
         end
      end
   end
   
   % Continuous approx of V_m(k', j) (continuation value)
   vmS.vmFct_jV{j} = griddedInterpolant(vmS.kGridV, vmS.value_kjM(:,j), 'pchip', 'linear');
end




% for ik = 1 : nk
%    % Assumes that the grid is the same as for work
%    if cS.dbg > 10
%       if any(abs(vmS.kGridV - vWorkS.kGridV) > 1e-4)
%          error_bc1('Grids not the same', cS);
%       end
%    end
%    vDrop_aV = vWorkS.value_kasM(ik, cS.iCD, :);
%    vDrop_aV = nan([cS.nAbil, 1]);
%    for iAbil = 1 : cS.nAbil
%       % Value of working as a dropout 
%       [~, vDrop_aV(iAbil)] = hh_bc1.hh_work_bc1(vmS.kGridV(ik), cS.iCD, iAbil, paramS, cS);
%    end
%    for j = 1 : cS.nTypes
%       % Value of studying in period 3-4
%       vStudy_aV = vColl3S.value_kajM(ik, :, j);
%       % Value = E_a of (prob grad * study + prob drop * work)
%       vmS.value_kjM(ik, j) = ...
%          sum(paramS.prob_a_jM(:,j) .* ((1 - prGrad_aV) .* vDrop_kaM(ik,:)' + prGrad_aV .* vStudy_aV(:)));
%    end
% end

% saveS.vmS = vmS;

if cS.dbg > 10
   validateattributes(vmS.value_kjM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
      'size', [nk, cS.nTypes]})
end

end