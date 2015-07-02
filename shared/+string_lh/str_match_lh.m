function countM = str_match_lh(dataV, searchV, caseSensitive, dbg);
% Given cell arrays dataV and searchV
% For each element of searchV, count how often it
% occurs in each element of dataV

% OUT:
%  countM(id, is)
%     1 if searchV{is} is contained in dataV{id}

% ----------------------------------------------------

nd = length(dataV);
ns = length(searchV);

countM = zeros(nd, ns);

% Loop over data to search
for id = 1 : nd
   % Get current data string
   dataStr = dataV{id};
   % Can process only if data are string
   if isstr(dataStr)
      if caseSensitive == 0
         dataStr = lower(dataStr);
      end

      % Loop over search strings
      for is = 1 : ns
         if caseSensitive == 1
            countM(id, is) = length(strfind(dataStr, searchV{is}));
         else
            countM(id, is) = length(strfind(dataStr, lower(searchV{is})));
         end
      end
   end
end


% *****  eof  ******
