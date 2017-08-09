% Partition NOAA Buoy Data, S. C. Crosby 7/9/2016
%
% Description:
%   Script downloads NOAA buoy data and extracts swell and seas partition
%   data including, Hs [feet], Peak_period [sec], Mean_dir [deg. Note
%   that direction is always compass heading, indicating direction waves
%   are arriving from. (e.g. NW or SW swell is most common in SoCal).
%
%   Script, for testing, pulls from NOAA Pt. Loma site, 46232. Testing was
%   done for several days of data this month.
%
%   Input is simply raw NOAA buoy data file.
%
%   Output is generated for full spectra (_full) and partitioned spectra
%       Significant Wave Height, Hs [feet]
%       Peak Period, Tp [sec]
%       Mean Period, Tm [sec] <- I reccomend using mean over peak
%       Mean Direction, Dm [deg]
%
% Functions Used:
%   extract_variable.m
%   find_peaks_valleys.m
%   integrate_spectra.m
%


% Clear workspace
clearvars
clc

% Download the data pages from NOAA to files
% a0 - Energy(f) [m^2/Hz]
urlwrite('http://www.ndbc.noaa.gov/data/realtime2/46232.data_spec','e.dat');
% alpha1 - Mean_Direction(f) [deg]
urlwrite('http://www.ndbc.noaa.gov/data/realtime2/46232.swdir','alpha1.dat');

%%
clc
% extract energy, e(time,freq) [m^2/Hz]
% Get previous 2 hours, these are used to average spectrum and make
% identifying partitions easier. Original recent spectrum is used however
% for integration of partition properties (Hsig, Tp, D-mean)

time_steps = 58; %Select number of time steps to collect, each 1-hour
sep_flag = 1;   %e.dat file (energy) has sep_freq,
% Load in raw spectra energy as a fxn of frequency
[ time1, fr1, e ] = extract_variable( 'e.dat', time_steps, sep_flag);

sep_flag = 0; %alpha1.dat (mean direction) does not have sep_freq
% Load in raw direction as a fxn of frequency
[ time2, fr2, alp1 ] = extract_variable( 'alpha1.dat', time_steps, sep_flag);

% Check data integrity, time and freq steps should be same
if sum(time1==time2) < length(time1)
    error('Time Steps Not consistent')
end
if sum(fr1==fr2) < length(time1)
    error('Time Steps Not consistent')
end

%%%%TESTING%%%%
go_back = 33;
e = e(go_back:end,:);
alp1 = alp1(go_back:end,:);

% Average energy in time, this is used to estimate peaks. More reliable
% with increased data, and lower statistical uncertainty. Downside may be a
% possible time lag, however swell conditions are typically stable for 3+
% hours
eA = (e(1,:)+0.75*e(2,:)+.25*e(3,:))/2; %forward weighted average

% Call peak finder, use averaged energy for peak IDs
[ peak, peak_start, peak_end ] = find_peaks_valleys( eA );

% Discard High Frequency Chop ( Defined here as < 3 seconds)
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
adjust_flag = 0;
pp = 2;
while pp <= length(peak)
    if abs(Tm(pp-1)-Tm(pp)) <= 2 && abs(Dm(pp-1)-Dm(pp)) <= 15
        % Here we combine two peaks
        % if the second peak is bigger than the first, set it as peak
        if e(peak(pp)) > e(peak(pp-1))
            peak(pp-1) = peak(pp);
        end
        % Keep first peak start point, but change end point to second peak
        peak_end(pp-1) = peak_end(pp);
        % And now remove 2nd peak from our peak variables
        peak(pp) = [];
        peak_start(pp) = [];
        peak_end(pp) = [];
        adjust_flag = 1;
    else
        pp = pp+1;
    end
end

% Re-integrate adjusted partitions if neccesary
% The adjustment and re-integration process could be looped, but it is very
% rare that it would need to be. So for simplicity it is done just once.
if adjust_flag == 1;
    clear Hs Tp Tm Dm       %clear old copies
    for pp=1:length(peak);
        [ Hs(pp), Tp(pp), Tm(pp), Dm(pp) ] = integrate_spectra( ...
            fr1(peak_start(pp):peak_end(pp)), e(peak_start(pp):peak_end(pp)), ...
            alp1(peak_start(pp):peak_end(pp)) );
    end
    disp('re')
end

% Integrate Full Spectra
[Hs_full, Tp_full, Tm_full, Dm_full] = integrate_spectra( fr1,e,alp1);

% Print full (total) wave conditions
fprintf('Avg.   Waves, Hs = %3.1f, Tp = %3.1f, Tm = %3.1f, Dm = %3.0f \n',...
    Hs_full, Tp_full, Tm_full, Dm_full)

% Print partition information
for pp=1:length(peak)
    fprintf('Partition #%d, Hs = %3.1f, Tp = %3.1f, Tm = %3.1f, Dm = %3.0f \n',...
        pp,Hs(pp), Tp(pp), Tm(pp), Dm(pp))
end


% Plot frequency spectra with peaks/troughs marked
% clf
% plot(fr1,e)
% hold on
% plot(fr1,eA)
% plot(fr1(peak),e(peak),'o')
% plot(fr1(peak_start),e(peak_start),'*')
% xlim([0 .3])




