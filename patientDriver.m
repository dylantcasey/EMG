% names with numbers in them will refer to their band

% GUI input
% find your patient and select the "Analyzed Data" file
dirName=uigetdir;

prompt = {'What time was anesthetic given? (seconds)'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'1000'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

baselineEnd = str2double(answer{1})*2000; %2000 is 1 second

% sampling frequency
Fs=2000;
framelen=1001;

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
%% OFFSET

inBandOffset = offsetBands(inBands, inBandSmooth,idxBaseline);

%% plotting full timeline

%separate out bands for plotting
inBand1Offset=inBandOffset{1};
inBand2Offset=inBandOffset{2};
inBand3Offset=inBandOffset{3};
inBand4Offset=inBandOffset{4};

inBand1Der=inBandDerivatives{1};
inBand2Der=inBandDerivatives{2};
inBand3Der=inBandDerivatives{3};
inBand4Der=inBandDerivatives{4};

%downsample
idxSample=1:1000:length(T);

figure(190)
clf
tile=tiledlayout(2,1);
title(tile,'whole signals')

% smooth plot
nexttile
plot(T(idxSample),inBand1Offset(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand2Offset(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand3Offset(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand4Offset(idxSample), 'LineWidth',2)
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
