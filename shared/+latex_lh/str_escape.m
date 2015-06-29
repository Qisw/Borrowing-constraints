function xStr = str_escape(inStr)
% Escape characteris in a latex string so it can be sent to fprintf

xStr = strrep(inStr,'\','\\');
xStr = strrep(xStr,'%','%%');

end