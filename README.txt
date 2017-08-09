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

Partitioned output is printed to file: output.txt

Example of output from 7/29/2016, 22:30 PDT

Total Waves, Hs = 3.1, Tp = 9.9, Tm = 8.1, Dm = 222 
Partition #1, Hs = 1.0, Tp = 18.2, Tm = 17.9, Dm = 216 
Partition #2, Hs = 2.4, Tp = 9.9, Tm = 10.2, Dm = 200 
Partition #3, Hs = 1.8, Tp = 6.2, Tm = 4.5, Dm = 279 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%Algorithm Method Description%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

The algorithm here is designed to identify the various swell and seas components of the total wave energy. This is accomplished by identifying peaks of energy in frequency space. These peaks are integrated individually for bulk wave parameters: Hs, Tp, Tm, Dm

The frequency spectra, E(f), and direciton, dir(f) is downloaded for the past 3 observation hours for a given noaa buoy. These are averaged, with greater weight on the most recent observations. The averaging is needed as there is significant uncertainty in buoy observations for short time records. Additionally smoothing in frequency space is done with a convolution. 

The smoothed E(f) is used to identify the peaks. Peak identification is done by finding min and max locations in E(f). Min locations indicate cut-offs for each peak. Once peaks and cut-offs (start and end locations) are found for parition, integration of bulk parameters is performed.

Partition at high frequency, < 0.3Hz, or greater than 3-sec (wind chop) are ignore. Additionally paritioning that are very close in peak frequency and have similar mean directions are collapsed into single partition. This is frequently done for wind-waves those from 3-10 seconds in period. Once collapsed, the partions are reintegrated

There is no threshold of minimum wave height, e.g. Hs may be as small as 0.3 ft. The decision of whether to include very low energy paritions, and how to order partitions, is left up to the user.
