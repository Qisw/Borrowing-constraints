function cohort_earn_profiles_show(saveFigures, setNo)
% Show cohort earnings profiles
%{
The profiles are just copied from cps data
%}

cS = const_bc1(setNo);
expNo = cS.expBase;
figS = const_fig_bc1;
figOptS = figS.figOpt4S;

tgS = var_load_bc1(cS.vCalTargets, cS);

yMax = ceil(max(log(max(0.1, tgS.earn_ascM(:)))));

for iCohort = 1 : length(cS.bYearV)
   fh = output_bc1.fig_new(saveFigures, figOptS);
   hold on;
   
   for iSchool = 1 : cS.nSchool
      ageV = cS.ageWorkStart_sV(iSchool) : cS.ageMax;
      
      % Complete profile
      iLine = iSchool;
      earnV = tgS.earn_ascM(ageV, iSchool, iCohort);
      idxV = find(earnV > 0);
      plot(cS.age1 - 1 + ageV(idxV), log(earnV(idxV)), figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));
      
   end
   
   hold off;
   xlabel('Age');
   ylabel('Log earnings');
   legend(cS.sLabelV, 'location', 'south');
   figures_lh.axis_range_lh([NaN, NaN, 0, yMax]);
   output_bc1.fig_format(fh, 'line');
   
   output_bc1.fig_save(sprintf('earn_profile_coh%i', cS.bYearV(iCohort)), saveFigures, cS);
end


end