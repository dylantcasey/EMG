function dB = percent2dB(percent)
    if (0<=percent)
        percent=percent/100;
        dB=10*log10(percent+1);
    else
        error('Must be positve')
    end
end