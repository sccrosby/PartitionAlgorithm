function [ a1, b1, a2, b2 ] = convertToMoments( alp1, alp2, r1, r2 )
%[ a1, b1, a2, b2 ] = convertToMoments( alp1, alp2, r1, r2 )
%   Take converted moments from NOAA, and convert back to original fourier
%   series moments. There uncertainty introduce, due to loss of information
%   however we attempt to fix this, but trying all 4 possible + {0,180}
%   combinations, picking the best fit back to original directions

a1 = r1.*cosd(alp1);
b1 = r1.*sind(alp1);

% set 1
a2_1 = r2.*cosd(270-(alp2/2+180));
b2_1 = r2.*sind(270-(alp2/2+180));
[md1_1, md2_1] = getmd(a1,b1,a2_1,b2_1);

% set 2
a2_2 = r2.*cosd(270-(alp2/2+0));
b2_2 = r2.*sind(270-(alp2/2+0));
[md1_2, md2_2] = getmd(a1,b1,a2_2,b2_2);

% set 3
a2_3 = r2.*cosd(270-(alp2/2+180));
b2_3 = r2.*sind(270-(alp2/2+0));
[md1_3, md2_3] = getmd(a1,b1,a2_3,b2_3);

% set 4
a2_4 = r2.*cosd(270-(alp2/2+0));
b2_4 = r2.*sind(270-(alp2/2+180));
[md1_4, md2_4] = getmd(a1,b1,a2_4,b2_4);


a2 = a2_1;
b2 = b2_1;

clf
plot(alp2,'k')
hold on
plot(md2_1)
plot(md2_2)
plot(md2_3)
plot(md2_4)

end

function  [md1, md2] = getmd(a1,b1,a2,b2)
% Following Kuik 1988, estimate mean directions from low order moments

% radians
md1r=atan2(b1,a1);

% degrees
md1=md1r*(180/pi);
% turn negative directions in positive directions
md1(md1 < 0)=md1(md1 < 0)+360;

% second moment mean direction in degrees
md2=0.5*atan2(b2,a2)*(180/pi);
% turn negative directions in positive directions
md2(md2 < 0)=md2(md2 < 0)+360;
% a2b2 mean dir has 180 deg amiguity. find one that is closest to
% a1b1 mean dir.
tdif=abs(md1-md2);
md2(tdif > 90)=md2(tdif > 90)-180;
md2(md2 < 0)=md2(md2 < 0)+360;

end