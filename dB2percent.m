function percent= dB2percent(dB)
    percent=(10.^(dB./10)-1).*100;
end