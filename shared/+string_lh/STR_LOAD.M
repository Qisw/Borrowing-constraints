function [strArray, strLen, nLines] = str_load(fname);
% Load an array of strings
% ---------------------------------------
% TASK:
%
% IN:
%   fname   path of file
% OUT:
%   strArray    array of strings loaded; padded with spaces (required by Matlab)
%   strLen      length of each string
%   nLines      no. of strings loaded
% REM:
% - Notes of fscanf
%   - interprets any space as a separator (end of string element).
%   - therefore you have to read the entire file in one go as a vector of characters!
%   - line feed is represented by a sequence of  str=10 and str=13
% ---------------------------------------

% REM:
%  The main point is to get around Matlab's inability to read a text file, if the
%  lines are not all of equal length
%
% CHANGE:
%  - allow larger text files. Read and write back to disk in portions. E.g. for processing
%    data files
% TEST:
%
% AUTHOR: Lutz Hendricks, 1994
% ---------------------------------------

% ************  CONSTANTS  *************************************

    % Max length of string allowed.
    strMax = 32000;

% ********  OPEN FILE  ************

    fh = fopen(fname);
    if fh < 0
        abort([ 'str_load: Cannot open ', fname ])
    end


% ********  LOAD ENTIRE FILE  ***********

%    [ str, len ] = fscanf( fh, '%s\r', 1 );
    [ str, len ] = fscanf( fh, '%c', strMax );
    fclose(fh);

% ********  DISASSEMBLE INTO AN ARRAY  ***********

    % Locate positions of all carriage return characters.
    lfPos = 0;
    for i = 1 : len
        if str(i) == 13
            lfPos = [lfPos, i];
        end
    end

    % no. of lines
    nLines = length(lfPos) - 1;
    % Compute the length of each string
    strLen = zeros(nLines,1);
    strLen(1) = lfPos(2) - 1;
    for i = 2 : nLines
        % Minus 2 because there is a PAIR of CR/LF as separators
        strLen(i) = lfPos(i+1) - lfPos(i) - 2;
    end
    % Max length of any string
    maxLen = max(strLen);

    % Get all lines
    % - char ensures that strArray is string
    strArray = char(zeros(nLines, maxLen));

    % Extract all strings
    strArray(1, 1:strLen(1)) = str(1:lfPos(2)-1);
    for i = 2 : nLines
        strArray(i, 1:strLen(i)) = str( lfPos(i)+2 : lfPos(i+1)-1 );
    end


%disp(mfilename)
%keyboard

% *** end function ***
