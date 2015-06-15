function upload(setNoV, expNoV)
% Upload mat files for several sets
% -----------------------------------------

% if nargin == 1
%    expNoV = 1;
% end

ans1 = input('Upload these sets?', 's');
if ~strcmpi(ans1, 'yes')
   return
end

kure_bc1.updownload(setNoV, expNoV, 'up')


%    % *****  Also upload data
%    % No extra confirmation
% 
%    % Collect all data set no's used
%    dataSetNoV = zeros(size(setNoV));
%    dataExpNoV = zeros(size(setNoV));
%    for i1 = 1 : length(setNoV)
%       cS = const_bc1(setNoV(i1));
%       dataSetNoV(i1) = cS.dataSetNo;
%       dataExpNoV(i1) = cS.dataExpNo;
%    end

%    dataExpNo = unique(dataExpNoV);
%    if length(dataExpNo) ~= 1
%       error('Not implemented');
%    end
%    dataSetNoV = unique(dataSetNoV);

%    fprintf('Uploading data sets ');
%    fprintf(' %i', dataSetNoV);
%    fprintf('  expNo %i \n', dataExpNo);
%    kure_bc1.updownload(dataSetNoV, dataExpNo, 'up');


end