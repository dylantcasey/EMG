function inBandOffset=offsetBands(inBands, inBandSmooth, index)
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
n=length(inBandSmooth);
inBandOffset=cell(n,1);

for i = 1:n
    raw=inBands{1};
    smooth=inBandSmooth{i};
    offset=mean(raw(index(1):index(2)));
    inBandOffset{i}= smooth-offset;
end

end