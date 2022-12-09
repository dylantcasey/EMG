function inBandSmooth=smoothBands(inBands, framelen,b)
%function takes inBands and smooths the signal
%
%INPUTS 
%   inBands == cells containing inBand data
%   framelen == size of smoothing window
%   b == parameter from sgolay filter
%
%OUTPUT
%   inBands == 4x1 cell of each smoothed inBand
%  
%call example: smoothBands(inBand(1:2), 1001, b);
%
%%

disp(' begin smoothing '); disp(' ')
n=length(inBands);
inBandSmooth=cell(n,1);

for i = 1:n
    inBand=inBands{i};
    ycenter = conv(inBand,b((framelen+1)/2,:),'valid');
    ybegin = b(end:-1:(framelen+3)/2,:) * inBand(framelen:-1:1);
    yend = b((framelen-1)/2:-1:1,:) * inBand(end:-1:end-(framelen-1));
    inBandSmooth{i}=[ybegin; ycenter; yend];
%     inBandSmooth{i}=sgolayfilt(inBand,3,framelen);
end
disp(' end smoothing '); disp(' ')
end