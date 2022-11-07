function inBandDerivatives=calculateBandDerivatives(inBandSmooth, Fs, p, g)
%function takes smoothed inBands and calculates their derivatives
%
%INPUTS 
%   inBandSmooth == cells containing smoothed inBand data
%   Fs == sampling frequency
%   p == degree of derivative
%   g == parameter from sgolay filter
%
%OUTPUT
%   inBandDerivatives == 4x1 cell of each inBand derivative
%  
%call example: calculateBandDerivatives(inBandSmooth(1:2), 2000, 1, g);
%
%%
n=length(inBandSmooth);
dt=1/Fs;
inBandDerivatives=cell(n,1);

for i = 1:n
    inBand=inBandSmooth{i};
    inBandDerivatives{i}= conv(inBand, factorial(p)/(-dt)^p * g(:,p+1), 'same');
end

end