function data = anestheticDuration(T, inBandOffset, data, framelen)

    prompt = { 'What percentage increase would you like to use to determine EMG duration  e.g. "100" is a 100% increase (value doubled)'};
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'50'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    dB = percent2dB(str2double(answer{1}));

    startIndex=data.maxDiff_index;
    dBincrease = data.maxDiff + dB;
    anestheticTime = data.anesthetic_time;
    endPoint=length(T)-(framelen-1);
    
    durIndex=zeros(4,1);
    durTime = zeros(4,1);
    for i=1:4
        inBand=inBandOffset{i};
        index=startIndex(i);

        resolutionPeak = inBand>dBincrease(i);
        resolutionConn = bwconncomp(resolutionPeak(index:endPoint));
        connCompNum=numel(resolutionConn.PixelIdxList);
        if connCompNum>0
            lastConnComp=resolutionConn.PixelIdxList{connCompNum}+index;
        else
            lastConnComp=[];
        end
        % check if end point is above 1.76 dB
        if ismember(endPoint,lastConnComp)
            resolutionStartIndex = lastConnComp(1);
            durIndex(i) = resolutionStartIndex;
            durTime(i) = T(resolutionStartIndex)-anestheticTime;
        else
            disp(['There is no increase of ', num2str(dB) ,' dB after maximum difference ' ...
                'in band ',num2str(i)])
            durTime(i)=NaN;
            durIndex(i)=NaN;
        end
    end

    data.duration_index=durIndex;
    data.duration_time_sec = durTime;
    data.duration_time_min = durTime/60;
    
end