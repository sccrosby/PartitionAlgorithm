function combine_flag = check_combine_partition( Tm1,Tm2,dir1,dir2 )
%combine_flag = check_combine_partition( Tm1,Tm2,dir1,dir )
%Function Takes Tm and dir for two parittions and determines whether they should
%be combined into a single parition. Peak 1 should always be the longer
%period (or lower freq) peak
%
%   Inputs
%       Tm1,Tm2 - Mean period [sec] for peaks 1,2
%       dir1,dir2 - Mean direction [deg] for peaks 1,2
%       
%   Outputs
%       combine_flag
%           1 - peaks should be combined
%           0 - peaks are distinct, and should not be combined

% If in seas band combine peaks further apart, than in the swell-band
% And similarily for direction
if Tm1 > 10 
    min_Tm_diff = 2; %Swell-band
    min_dir_diff = 15; 
else
    min_Tm_diff = 3.5; %Seas
    min_dir_diff = 25; 
end

% If peaks are within both minimum differences, combine. 
if abs(Tm1-Tm2) <= min_Tm_diff && abs(dir1-dir2) <= min_dir_diff
    combine_flag = 1;
else
    combine_flag = 0;
end

%combine_flag = 0;
    

end

