% Partition NOAA Buoy Data, S. C. Crosby 7/9/2016
%
% Description:
%   Script downloads NOAA buoy data and extracts swell and seas partition
%   data including, Hs [feet], Peak_period [sec], Mean_dir [deg]. Note
%   that direction is always compass heading, indicating direction waves
%   are arriving from. (e.g. NW or SW swell is most common in SoCal).
%
%   NOAA buoys tested include, Pt. Loma site, 46232. Testing was
%   done for several days of data this month.
%
%   Input is simply two raw NOAA buoy data files, including
%		noaaID.data_spec 	- energy(f)
%		noaaID.swdir		- direction(f)
%
%   Output is generated for full spectra (_full) and partitioned spectra
%       Significant Wave Height, Hs [feet]
%       Peak Period, Tp [sec]
%       Mean Period, Tm [sec] <- I recommend using mean over peak
%       Mean Direction, Dm [deg]
%
% Main Script: 
%   PartitionScript.m
%
% Functions Used:
%   extract_variable.m
%   find_peaks_valleys.m
%   integrate_spectra.m
%   check_combine_partition.m


% Clear workspace
clearvars
clc

% Choose NOAA site
noaa_ID = '46232'; % Pt. Loma
%noaa_ID = '46025';  % Santa Monica Basin
%noaa_ID = '46054';  % West Santa Barbara
%noaa_ID = '46053';  % East Santa Barbara, note 2.3 discuss weather platform


% Point to NOAA's ftp site
ftp_string = ['http://www.ndbc.noaa.gov/data/realtime2/' noaa_ID];

% Download the data pages from NOAA to files
urlwrite([ftp_string '.data_spec'],'e.dat');  % a0 - Energy(f) [m^2/Hz]
urlwrite([ftp_string '.swdir'],'alpha1.dat'); % alpha1 - Mean_Dir(f) [deg]

% Load in data
time_steps = 3; %Select number of time steps to collect, each 1-hour
sep_flag = 1;   %e.dat file (energy) has sep_freq,
% Load in raw spectra energy as a fxn of frequency
[ time1, fr1, e ] = extract_variable( 'e.dat', time_steps, sep_flag);

sep_flag = 0; %alpha1.dat (mean direction) does not have sep_freq
% Load in raw direction as a fxn of frequency
[ time2, fr2, alp1 ] = extract_variable ( 'alpha1.dat', time_steps, sep_flag);

% Check data integrity, time and freq steps should be same
time_diff = (1/24)*(1/60); %Max time difference of 1 minute
if max(abs(time1-time2)) > time_diff
    textstr = 'Time steps not consistent between energy and direcitonal data';
    err_msg = sprintf('%s \n Energy date \t Direction date \n%s\t%s\n%s\t%s\n%s\t%s',...
        textstr,datestr(time1(1)),datestr(time2(1)),datestr(time1(2)),datestr(time2(2)),datestr(time1(3)),datestr(time2(3)));
    error(err_msg)
end
fr_diff = .00001; % Max freq difference [Hz]
if max(abs(fr1-fr2)) > fr_diff
    txtstr = 'Frequency steps not consistent between energy and direcitonal data';
    headstr = sprintf('Energy Freq \t Direction Freq'); 
    freqstr = sprintf('%4.3f Hz \t %4.3f Hz \n',[fr1' fr2']');
    err_msg = sprintf('%s\n%s\n%s',txtstr,headstr,freqstr);
    error(err_msg)
end

% Average energy in time, this is used to estimate peaks. More reliable
% with increased data, and lower statistical uncertainty. Downside may be a
% possible time lag, however swell conditions are typically stable for 3+
% hours
eA = (e(1,:)+0.75*e(2,:)+.25*e(3,:))/2; %forward weighted average

% Call peak finder, use averaged energy for peak IDs
[ peak, peak_start, peak_end ] = find_peaks_valleys( eA );

% Discard High Freq uency Chop (Defined here as < 3 seconds)
isave = fr1(peak) < 0.3;
peak = peak(isave);
peak_start = peak_start(isave);
peak_end = peak_end(isave);

% Discard previous time steps, keep only most recent time step for actual
% integration of partitions
e = e(1,:);
alp1 = alp1(1,:);

% Integrate each partition
%       Hs - Signficant Wave height [feet]
%       Tp - Peak period [sec]
%       Tm - Mean period [sec]
%       Dm - Mean direction [deg]
for pp=1:length(peak);
    [ Hs(pp), Tp(pp), Tm(pp), Dm(pp) ] = integrate_spectra( ...
        fr1(peak_start(pp):peak_end(pp)), e(peak_start(pp):peak_end(pp)), ...
        alp1(peak_start(pp):peak_end(pp)) );
end

% Combine partitions that are very close in period and direction
% Here close is defined as: within 2 seconds, and 15 degrees
% We look left to right, starting with swell and moving to higher
% freqeuency. If partitions get combined, reintegrate them. Stop when
% partitions are no longer being combined. 

if length(peak) < 2
    stop_search = 1;    %If only one partition, we are done
else
    stop_search = 0;    %If two or more, see what needs to be combined
end
pp = 2; % Initilize 
while stop_search == 0
    % First compare peaks, if too similar, combine_flag = 1 and we combine
    combine_flag = check_combine_partition(Tm(pp-1),Tm(pp),Dm(pp-1),Dm(pp));
    if combine_flag == 1        
        % Here we combine two similar peaks, to set the overall peak we
        % compare the first and second, if the second is bigger we move it
        % to first position (we will be deleting the 2nd peak soon)       
        if e(peak(pp)) > e(peak(pp-1))
            peak(pp-1) = peak(pp);
        end
        % Keep first peak start point, but change end point to second peak
        peak_end(pp-1) = peak_end(pp);
        % And now remove 2nd peak from our peak variables
        peak(pp) = [];
        peak_start(pp) = [];
        peak_end(pp) = [];
        
        % Recalculate Paritions After Merge
        clear Hs Tp Tm Dm       %clear old copies
        for pp=1:length(peak);
            [ Hs(pp), Tp(pp), Tm(pp), Dm(pp) ] = integrate_spectra( ...
                fr1(peak_start(pp):peak_end(pp)), e(peak_start(pp):peak_end(pp)), ...
                alp1(peak_start(pp):peak_end(pp)) );
        end
        
        % Reset pp to beginning if needed
        pp = 2;
        
    end
    
    % step to next peak
    pp = pp+1;
    
    % if we have stepped past the total number of peaks, stop
    if pp > length(peak)   
        stop_search = 1;
    end
    
end


% Integrate Full Spectra
[Hs_full, Tp_full, Tm_full, Dm_full] = integrate_spectra(fr1,e,alp1);


% Print to file
outfile_name = sprintf('output_%s.txt',noaa_ID);
fid = fopen(outfile_name,'w');

% Print full spectra wave properties 
fprintf(fid,'Total Waves, Hs = %3.1f, Tp = %3.1f, Tm = %3.1f, Dm = %3.0f \n',...
    Hs_full, Tp_full, Tm_full, Dm_full);

% Print partitioned spectra wave properties
for pp=1:length(peak)
    fprintf(fid,'Partition #%d, Hs = %3.1f, Tp = %3.1f, Tm = %3.1f, Dm = %3.0f \n',...
        pp,Hs(pp), Tp(pp), Tm(pp), Dm(pp));
end

fclose(fid);

