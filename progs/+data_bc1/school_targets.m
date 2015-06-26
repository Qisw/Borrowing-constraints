function [tgS, schoolS] = school_targets(n79S, tgS, cS)
% Add targets for schooling by [iq, yp]
%{
Graduation fractions are NOT conditional on entry
%}

%% Allocate outputs

nIq = length(cS.iqUbV);
nYp = length(cS.ypUbV);

% Fraction of HSG in each cell. Sums to 1
tgS.fracHsg_qycM = nan([nIq, nYp, cS.nCohorts]);

% Fraction enter / grad by [iq, yp, cohort]
tgS.fracEnter_qycM = nan([nIq, nYp, cS.nCohorts]);
tgS.fracGrad_qycM  = nan([nIq, nYp, cS.nCohorts]);

% Fraction enter / graduate by IQ
%  frac grad not conditional on entry
tgS.fracEnter_qcM = nan([nIq, cS.nCohorts]);
tgS.fracGrad_qcM  = nan([nIq, cS.nCohorts]);
tgS.fracEnter_ycM = nan([nYp, cS.nCohorts]);
tgS.fracGrad_ycM  = nan([nYp, cS.nCohorts]);



%%  Early cohorts

for iCohort = 1 : 2
   bYear = cS.bYearV(iCohort);
   if abs(bYear - 1940) < 3
      % Project talent
      dataFn = 'flanagan 1971.csv';
   elseif abs(bYear - 1915) < 3
      % Updegraff
      dataFn = 'updegraff 1936.csv';
   else
      error('Invalid');
   end
   
   loadS = data_bc1.load_income_iq_college(dataFn, cS.setNo);
   
   tgS.fracHsg_qycM(:,:,iCohort) = loadS.mass_qyM ./ sum(loadS.mass_qyM(:));

   tgS.fracEnter_qycM(:,:,iCohort) = loadS.entry_qyM;
   tgS.fracEnter_qcM(:,iCohort) = loadS.entry_qV;
   tgS.fracEnter_ycM(:,iCohort) = loadS.entry_yV;
   if ~isempty(loadS.grad_qyM)
      tgS.fracGrad_qycM(:,:,iCohort)  = loadS.grad_qyM;
      tgS.fracGrad_qcM(:,iCohort) = loadS.grad_qV;
      tgS.fracGrad_ycM(:,iCohort) = loadS.grad_yV;
   end
end

% 
% % HSB data, hsb_fam_income.xlsx
% fracEnter_yqM = [0.1910305	0.3404084	0.4616973	0.7431248
%    0.2746048	0.3476628	0.5838453	0.8174849
%    0.3067916	0.4374966	0.6217784	0.8587366
%    0.2960698	0.5814796	0.7817845	0.9273478];
% % Fraction graduate conditional on entry
% fracGrad_yqM = [0.1987562	0.1296711	0.4773349	0.6385519
%    0.0779666	0.3380288	0.5016366	0.7053534
%    0.1137461	0.3146327	0.5340976	0.7627105
%    0.0291045	0.2856211	0.5979195	0.8423696];
% fracHSG_yqM = 1 - fracEnter_yqM;
% fracCG_yqM  = fracEnter_yqM .* fracGrad_yqM;
% fracCD_yqM  = 1 - fracHSG_yqM - fracCG_yqM;
% tgS.fracS_qycM(cS.iHSG, :, :, icHSB) = fracHSG_yqM';
% tgS.fracS_qycM(cS.iCD,  :, :, icHSB) = fracCD_yqM';
% tgS.fracS_qycM(cS.iCG,  :, :, icHSB) = fracCG_yqM';
% 
% validateattributes(tgS.fracS_qycM(:,:,:,icHSB), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
%    '>', 0', '<', 1, 'size', [cS.nSchool, nIq, nYp]})


%%  Nlsy79
% In original file and in output: frac grad not conditional on entry

tgS.fracHsg_qycM(:,:, tgS.icNlsy79) = n79S.hsgrad_dist_byinc_and_byafqt' ./ sum(n79S.hsgrad_dist_byinc_and_byafqt(:));

tgS.fracEnter_qycM(:,:, tgS.icNlsy79) = n79S.attend_college_byinc_and_byafqt';
tgS.fracGrad_qycM(:,:, tgS.icNlsy79)  = n79S.grad_college_byinc_and_byafqt';

tgS.fracEnter_qcM(:, tgS.icNlsy79) = n79S.attend_college_byafqt;
tgS.fracGrad_qcM(:, tgS.icNlsy79)  = n79S.grad_college_byafqt;

tgS.fracEnter_ycM(:, tgS.icNlsy79) = n79S.attend_college_byinc;
tgS.fracGrad_ycM(:, tgS.icNlsy79)  = n79S.grad_college_byinc;


%% Validation

for iCohort = 1 : cS.nCohorts
   if ~isnan(tgS.fracEnter_qcM(1,iCohort))
      validateattributes(tgS.fracEnter_qcM(:,iCohort), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
         'positive', '<', 0.9})
   end
   if ~isnan(tgS.fracGrad_qcM(1,iCohort))
      validateattributes(tgS.fracGrad_qcM(:,iCohort), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
         'positive', '<', 0.8})
   end
   
   % Check consistency of marginals with joint distribution
   if ~isnan(tgS.fracEnter_qycM(1,1,iCohort))  &&  ~isnan(tgS.fracHsg_qycM(1,1,iCohort))
      [fracEnter_qV, fracEnter_yV] = ...
         helper_bc1.marginals(tgS.fracEnter_qycM(:,:,iCohort), tgS.fracHsg_qycM(:,:,iCohort), cS.dbg);
      if ~check_lh.approx_equal(fracEnter_qV, tgS.fracEnter_qcM(:,iCohort), 1e-2, [])
         error('fracEnter_qV does not match');
      end
      if ~check_lh.approx_equal(fracEnter_yV, tgS.fracEnter_ycM(:,iCohort), 1e-2, [])
         error('fracEnter_yV does not match');
      end
   end
   
   if ~isnan(tgS.fracGrad_qycM(1,1,iCohort))  &&  ~isnan(tgS.fracHsg_qycM(1,1,iCohort))
      [fracGrad_qV, fracGrad_yV] = ...
         helper_bc1.marginals(tgS.fracGrad_qycM(:,:,iCohort), tgS.fracHsg_qycM(:,:,iCohort), cS.dbg);
      if ~check_lh.approx_equal(fracGrad_qV, tgS.fracGrad_qcM(:,iCohort), 1e-2, [])
         error('fracGrad_qV does not match');
      end
      if ~check_lh.approx_equal(fracGrad_yV, tgS.fracGrad_ycM(:,iCohort), 1e-2, [])
         error('fracGrad_yV does not match');
      end
   end
end


%% Regress college entry on [iq, yp] groups
% Original data and quartiles
% Weighted and unweighted

schoolS.iWeighted = 1;
schoolS.iUnweighted = 2;
schoolS.betaIqM = nan(2, cS.nCohorts);
schoolS.betaYpM = nan(2, cS.nCohorts);

for iCohort = 1 : cS.nCohorts
   if ~isnan(tgS.fracEnter_qycM(1,1,iCohort))
      for iWeighted = [schoolS.iWeighted, schoolS.iUnweighted]
         if iWeighted == schoolS.iWeighted
            wt_qyM = sqrt(tgS.fracHsg_qycM(:,:,iCohort));
         else
            wt_qyM = [];
         end
         [schoolS.betaIqM(iWeighted, iCohort), schoolS.betaYpM(iWeighted, iCohort)] = ...
            results_bc1.regress_qy(tgS.fracEnter_qycM(:,:,iCohort), wt_qyM, ...
            cS.iqUbV(:), cS.ypUbV(:), cS.dbg);
      end
   end
end


%%  Implied: Fraction by s
% For samples with micro data

% Fraction in each IQ group
qFracV = diff([0; cS.iqUbV]);
for iCohort = 1 : cS.nCohorts
   % check consistency with cps data +++++
   if ~isnan(tgS.fracGrad_qcM(1,iCohort))
      fracEnter = sum(tgS.fracEnter_qcM(:, iCohort) .* qFracV(:));
      fracGrad  = sum(tgS.fracGrad_qcM(:, iCohort) .* qFracV(:));
      tgS.frac_scM(:, iCohort) = [1-fracEnter,  fracEnter-fracGrad,  fracGrad];

      % Check
      validateattributes(tgS.frac_scM(:,iCohort), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', ...
         '<', 1, 'size', [cS.nSchool, 1]})
      pSumV = sum(tgS.frac_scM(:,iCohort));
      if any(abs(pSumV - 1) > 1e-6)
         error('Invalid');
      end
   end
   
   % Check consistency of fracEnter and fracGrad by iq and yp with joint by [iq,yp]
   % For this I need to know Pr(q,y)
   % Pr(x | q) = sum over y  Pr(x | q,y) * Pr(y|q)
   % Pr(y | q) = Pr(q,y) / Pr(q)
   % Pr(q,y) is joint distribution of (q,y) among HSG
   
end


end