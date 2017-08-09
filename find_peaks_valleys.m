function [ peak, peak_start, peak_end ] = find_peaks_valleys( e )
%[ peak, peak_start, peak_end ] = find_peaks_valleys( e )
%Function takes e(f) and find peak locations as well as start and stop
%locations defining the peak width. Take forward and backward differences 
%to find peaks/valleys
%
%   Inputs
%       e - energy(f)
%       
%   Outputs
%       peak - Vector with indices of peaks
%       peak_start - Vector with start indices
%       peak_end - Vector with end indices


% conv is a matlab convolve function, equivalent to Python numpy.convolve
% Note boundary effects are neglible for peak identification
% The convolution smooths out features that might not be significant peaks
e = conv(e,[.05 .1 .7 .1 .05],'same');

% forward difference, subtract 1st from 2nd, 3rd from 2nd, and so on
diff_forward = e(2:end)-e(1:end-1);

% backward difference
diff_backward = e(1:end-1)-e(2:end);

% Convert differences to -0.5, +0.5 if negative or positive
diff_forward(diff_forward<0)=-.5;
diff_forward(diff_forward>0)=.5;
diff_backward(diff_backward<0)=-.5;
diff_backward(diff_backward>0)=.5;

% Add to find peaks/valleys, peaks are +1, valleys -1, -.5 are flat regions
diff_sum = diff_forward(1:end-1)+diff_backward(2:end);

% Find peaks and valleys, add 1 due to offset by missing end points of diff
peak = find(diff_sum==1)+1; 
valley = find(diff_sum==-1)+1;

% if we start with a valley, add a peak at first low freq. Unlikely
if peak(1) > valley(1)
    peak = [1 peak];
end

% Start at lowest frequency for first peak
peak_start(1) = 1;
peak_end(1) = valley(1);

% Set rest of peak start and end locations, Likely high frequency peaks
% will be discarded later
for ii = 1:length(valley)-1
    peak_start(ii+1) = valley(ii);
    peak_end(ii+1) = valley(ii+1);
end

% If more peaks than peak starts/end, we are missing the end frequency
if length(peaks) > length(peak_start)
    peak_start(ii+2) = peak_end(ii);
    peak_end(ii+2) = length(e);
end

end

