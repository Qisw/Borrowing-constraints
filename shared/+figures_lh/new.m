function fh = new(optS, visible)
% open a new figure window
%{
optS contains figure size
%}
% --------------------------

if visible == 1
   visStr = 'on';
else
   visStr = 'off';
end

fh = figure('Units','inches',...
   'Position',[1, 1, optS.width, optS.height],...
   'PaperPositionMode','auto',  'visible', visStr);



end