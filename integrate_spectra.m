function [ Hs, Tp, Tm, Dm ] = integrate_spectra( fr, e, dir )
%[ Hs ] = integrate_Hs( fr, e )
%Integrates given frequency spectrum 
% 
%   Inputs (all a fxn of freq)
%       fr - frequency [Hz]
%       e - energy [m^2/Hz]
%       dir - direction [deg]
%
%   Output
%       Hs - Signficant Wave height [feet]
%       Tp - Peak period [sec]
%       Tm - Mean period [sec]
%       Dm - Mean direction [deg]
%

% Integrate Hs
eT = 0; %intialize total energy 
for ff = 2:length(fr)
    %Integrate withTrapezoid Rule
    eT = eT + 0.5*(e(ff)+e(ff-1))*(fr(ff)-fr(ff-1)); 
end

Hs = 4*sqrt(eT);        % in meters [m]

Hs = 3.28084*Hs;        % in feet [ft]


% Calc Tp
[~, maxI] = max(e);     %max() fxn returns location of e maximum
Tp = 1/fr(maxI);        %Peak period, T = 1/fr

% Calc Tm
frm = sum(fr.*e)/sum(e);    %Weighted average of freq with energy
Tm = 1/frm;

% Calc Dm
Dm = sum(dir.*e)/sum(e);    %Weighted average of dir with energy


end

