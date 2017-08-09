function [ time, fr, var ] = extract_variable( fname, time_steps, sep_flag )
%[ time, fr, var ] = extract_variable( fname, sep_flag )
%Function takes file with data and extracts desired time_steps for each
%freq available
%
%   Inputs
%       fname - File name with NOAA data (in local folder
%       time_steps - Number of times steps from most recent to collect
%           (integer)
%       sep_flag - 'e.dat' contains extra column with NOAA's estimate of
%           the separation frequency between swell and seas. 
%           sep_flag = 1 for e.dat, and sep_flag = 0 for 
%           directional information
%           NOTE: NDBC inserts the value 9.999 if Sep_Freq is missing.
%
%   Outputs
%       time - vector of time stamps in MATLAB datenum format (A serial date number
%          represents the whole and fractional number of days from a fixed,
%          preset date (January 0, 0000) in the proleptic ISO calendar.)
%       fr - vector of frequencies extracted
%       var - matrix of extracted variable (e.g. e) (time x freq)

% Open file for reading
fid=fopen(fname,'r');

% Get header
hd=fgetl(fid);

% Get lines and extract variables
for tt = 1:time_steps    
    
    % Extract next line and convert to number format
    line=str2num(fgetl(fid));    
    
    % Make time stamp variable in datenum format
    time(tt) = datenum(line(1),line(2),line(3),line(4),line(5),0);
    
    % Grab frequencies and desired variable, and sep_freq in applicable
    if sep_flag == 1
        sep_fr(tt) = line(6);
        var(tt,:) = line(7:2:end);
        fr = line(8:2:end);
    else
        var(tt,:) = line(6:2:end);
        fr = line(7:2:end);
    end    
end

% Close file
fclose(fid);

end

