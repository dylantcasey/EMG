% names with numbers in them will refer to their band
data=struct;

tic 

% GUI input
% find your patient and select the "Analyzed Data" file
dirName=uigetdir;

% sampling frequency
Fs=2000;
data.frequency=Fs;
framelen=32001; % don't make this larger than 32001. It's a waste of time.
[b,g]=sgolay(3,framelen);

[inBands,data]=loadPatient(dirName, data);

% define time
T=0.0005:0.0005:length(inBands{1})/Fs';
T=T';

%% signal smoothing

inBandSmooth=smoothBands(inBands, framelen, b);

%% derivatives

inBandDerivatives=calculateBandDerivatives(inBands, Fs, 1, g);

%% check anesthetic administration

[anestheticTime, data] = checkAnestheticAdmin(T, inBandSmooth, data);
anestheticEnd = round(anestheticTime*Fs); %2000 is 1 second

%% selecting baseline

[idxBaseline, data] = selectBaseline(T,inBandSmooth, inBandDerivatives, anestheticEnd, data);

%% Clean
inBandFilled = cleanBands(T,inBandSmooth, inBands, idxBaseline, anestheticEnd);

inBandClean = smoothBands(inBandFilled, framelen, b);

[inBandOnset, data]=rateOnset(T, inBandSmooth, inBands, anestheticEnd, data);

%% OFFSET

[inBandOffset, data] = offsetBands(inBands, inBandClean,idxBaseline, data);

data = maxDiff(Fs, inBands, data);

[inBandSmoothOffset, ~] = offsetBands(inBands, inBandSmooth, idxBaseline, data);

data = anestheticDuration(T, inBandSmoothOffset, data, framelen);

%% plotting full timeline

%separate out bands for plotting
inBand1Offset=inBandOffset{1};
inBand2Offset=inBandOffset{2};
inBand3Offset=inBandOffset{3};
inBand4Offset=inBandOffset{4};

inBand1OG=inBandSmooth{1};
inBand2OG=inBandSmooth{2};
inBand3OG=inBandSmooth{3};
inBand4OG=inBandSmooth{4};


inBand1Der=inBandDerivatives{1};
inBand2Der=inBandDerivatives{2};
inBand3Der=inBandDerivatives{3};
inBand4Der=inBandDerivatives{4};

%downsample
idxSample=1:100:length(T);

fig=figure(190);
fig.Units='normalized';
fig.Position = [0.05 0.3 0.9 0.55];
clf
tile=tiledlayout(3,1);
title(tile,'whole signals')

% original plot
ax1=nexttile;
plot(T(idxSample),inBand1OG(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand2OG(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand3OG(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand4OG(idxSample), 'LineWidth',2)
hold on
ax=axis;
plot([T(anestheticEnd) T(anestheticEnd)], [ax(3) ax(4)],'k',...
    'LineWidth',3, 'HandleVisibility','off');
legend('band 1', 'band 2', 'band 3', 'band 4')
title('original smoothed bands')
xlabel('time (s)')
ylabel('Power (dB)')

%smooth plot
ax2=nexttile;
plot(T(idxSample),inBand1Offset(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand2Offset(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand3Offset(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand4Offset(idxSample), 'LineWidth',2)
hold on
ax=axis;
plot([T(anestheticEnd) T(anestheticEnd)], [ax(3) ax(4)],'k',...
    'LineWidth',3, 'HandleVisibility','off');
legend('band 1', 'band 2', 'band 3', 'band 4')
title('cleaned smoothed bands')
xlabel('time (s)')
ylabel('Power (dB)')

% derivative plot
ax3=nexttile;
plot(T(idxSample),inBand1Der(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand2Der(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand3Der(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand4Der(idxSample), 'LineWidth',2)
hold on
ax=axis;
plot([T(anestheticEnd) T(anestheticEnd)], [ax(3) ax(4)],'k',...
    'LineWidth',3, 'HandleVisibility','off');
legend('band 1', 'band 2', 'band 3', 'band 4')
title('derivatives')
xlabel('time (s)')
ylabel('Power/time (dB/s)')

linkaxes([ax1 ax2 ax3],'x');

%% save data

filename = append('caseData_', string(datetime('now','Format','yyMMdd_HH-mm')), '.mat');
save(fullfile(dirName,filename), 'data')

toc