function [inBandOffset,data]=offsetBands(inBands, inBandSmooth, index, data)
%function takes smoothed inBands to subtract off the mean of the raw data
%in the baseline range
%
%INPUTS 
%   inBands == cells containing original inBand data
%   inBandSmooth == cells containing smoothed inBand data
%   index == 2x1 matrix of start and end indices
%
%OUTPUT
%   inBandOffset == cells containing smoothed offset data
%  
%call example: calculateBandDerivatives(inBandSmooth(1:2), 2000, 1, g);
%
%%

disp('  Offsetting bands'); disp(' ')
n=length(inBandSmooth);
inBandOffset=cell(n,1);
offsetMat=zeros(4,1);
offsetSTD=offsetMat;
for i = 1:n
    raw=inBands{i};
    smooth=inBandSmooth{i};
    offsetMean=mean(raw(index(1):index(2)));
    offsetSTD = std(raw(index(1):index(2)));
    offsetMat(i)=offsetMean;
    inBandOffset{i}= smooth-offsetMean;
end

data.offset_mean=offsetMat;
data.offset_std=offsetSTD;
disp('  Did I even blink? '); disp(' ')

end