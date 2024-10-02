% names with numbers in them will refer to their band

% GUI input
% find your patient and select the "Analyzed Data" file
dirName=uigetdir;

baselineEnd = 1500*2000; %2000 is 1 second

% sampling frequency
Fs=2000;
framelen=10001;

inBands=loadPatient(dirName);

% define time
T=0.0005:0.0005:length(inBands{1})/Fs';
T=T';

%% signal smoothing
[b,g] = sgolay(3,framelen); % 3 is somewhat arbitrary (5 turned out bad and 
% I don't want to use an even function. lower it is the smoother the function will be

inBandSmooth=smoothBands(inBands, framelen, b);

%% derivatives

degree=1; % dervitative number e.g. p=1 is the first derivative 
inBandDerivatives=calculateBandDerivatives(inBandSmooth, Fs, degree, g);


%% selecting baseline

idxBaseline = selectBaseline(T,inBandSmooth, inBandDerivatives, baselineEnd);

% fig=figure(143);
% clf
% 
% bandTemp=inBandSmooth{1};
% 
% p1=plot(T,bandTemp, 'LineWidth',2);
% % ylim([y1 y2])
% % legend('band 1', 'band 2', 'band 3', 'band 4')
% title('inBand 1')
% xlabel('time (s)')
% ylabel('Power (dB)')
inBand1=inBands{1};
inBand1Mean=mean(inBand1(idxBaseline(1):idxBaseline(2)));
bandTemp=inBandSmooth{1};
bandOG=bandTemp;
brushedSections = zeros(1,length(bandTemp));
w=1;
i=1;
while w~=0
    %replot
    disp('  ** press SPACE to remove brushed section **')
    fig=figure(143);
    clf
    p1=plot(T,bandTemp, 'LineWidth',2);
    % ylim([y1 y2])
    % legend('band 1', 'band 2', 'band 3', 'band 4')
    title('inBand 1')
    xlabel('time (s)')
    ylabel('Power (dB)')
    brush on

    w = waitforbuttonpress;
    while w==0
        w = waitforbuttonpress;
    end
    cfg = gcf();
    ch = double(get(cfg, 'CurrentCharacter'));
    if ch == 13 % ENTER button
      break
    end
    if ch == 32 % SPACE button
      disp('  ** press ENTER when done brushing section **')
      if ~isempty(p1.BrushData)
          brushedLocs = logical(p1.BrushData);
          bandTemp(brushedLocs)=NaN;
            
          refreshdata
          drawnow
    
          %store locations so they can be deleted
          brushedSections(i,:)=brushedLocs;
          i=i+1;
      end
    end
    if ch == 8 % Backspace button
        if i>1
            disp('  ** Restoring previously brushed section **')
            restoreIndex=logical(brushedSections(i-1,:));
            bandTemp(restoreIndex)=bandOG(restoreIndex);
            brushedSections(i-1,:)=[];
            i=i-1;

            refreshdata
            drawnow
        end
    end
end

brushedIndex = logical(sum(brushedSections,1));
brushedIndexThres=inBand1>inBand1Mean;
indexThreshold = logical(brushedIndexThres.*brushedIndex');
inBand1(indexThreshold)=NaN;
inBand1Fill= fillmissing(inBand1,'pchip');
inBand1Smooth=smoothBands({inBand1Fill}, framelen, b);

figure
plot(T, inBandSmooth{1})
hold on
plot(T,inBand1Smooth{1})

%offset
% inBandOffset = offsetBands(inBands, inBandSmooth,idxBaseline);

%% plotting full timeline

idxSample=1:1000:length(T);

figure(190)
clf
tile=tiledlayout(2,1);
title(tile,'whole signals')

% smooth plot
nexttile
plot(T(idxSample),inBand1SmoothOffset(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand2SmoothOffset(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand3SmoothOffset(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand4SmoothOffset(idxSample), 'LineWidth',2)
legend('band 1', 'band 2', 'band 3', 'band 4')
title('smoothed bands')
xlabel('time (s)')
ylabel('Power (dB)')

% derivative plot
nexttile
plot(T(idxSample),abs(inBand1Der(idxSample)), 'LineWidth',2)
hold on
plot(T(idxSample),abs(inBand2Der(idxSample)), 'LineWidth',2)
hold on
plot(T(idxSample),abs(inBand3Der(idxSample)), 'LineWidth',2)
hold on
plot(T(idxSample),abs(inBand4Der(idxSample)), 'LineWidth',2)
legend('band 1', 'band 2', 'band 3', 'band 4')
title('derivatives')
xlabel('time (s)')
ylabel('Power/time (dB/s)')
