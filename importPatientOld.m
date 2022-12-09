%% DO NOT USE
% just for archival purposes

disp('DO NOT USE IDIOT!!')
disp('you deserve this')
quit

% names with numbers in them will refer to their band

% GUI input
% find your patient and select the "Analyzed Data" file
dirName=uigetdir;dReports=dir(dirName);

prompt = {'Time start (seconds):','Time End (seconds):', 'frame length (must be odd):'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'3000','4000','10001'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

tStart = str2num(answer{1}); %2000 is 1 second
tEnd = str2num(answer{2});
framelen=str2num(answer{3}); %must be odd

tStart=tStart*2000;
tEnd=tEnd*2000;

% don't change these
dReportsCell=struct2cell(dReports);
n=length(find(contains(dReportsCell(1,:),'Report')));
reportNum=1:n;
% sampling frequency
Fs=2000;

inBand1Cell=cell(1,numel(reportNum));
inBand2Cell=cell(1,numel(reportNum));
inBand3Cell=cell(1,numel(reportNum));
inBand4Cell=cell(1,numel(reportNum));

cellLength=zeros(length(reportNum),1);

%% importing

% %this will get files with an extension in a specific level subfolder
for i=1:numel(reportNum)
    d=dir([dirName,'/Report ', num2str(reportNum(i)), '/InBand/*.mat']);
    dCell=struct2cell(d);
    idx1=find(contains(dCell(1,:),'in_bandBPF1'));
    idx2=find(contains(dCell(1,:),'in_bandBPF2'));
    idx3=find(contains(dCell(1,:),'in_bandBPF3'));
    idx4=find(contains(dCell(1,:),'in_bandBPF4'));

    fileName1=[dCell{2,idx1},'/', dCell{1,idx1}];
    %this mess is because we don't always know the variable name, hence "who"
    load1=matfile(fileName1);
    varlist1=who(load1);
    inBand1Cell{i}=load1.(varlist1{1});

    fileName2=[dCell{2,idx2},'/', dCell{1,idx2}];
    load2=matfile(fileName2);
    varlist2=who(load2);
    inBand2Cell{i}=load2.(varlist2{1});

    fileName3=[dCell{2,idx3},'/', dCell{1,idx3}];
    load3=matfile(fileName3);
    varlist3=who(load3);
    inBand3Cell{i}=load3.(varlist3{1});

    fileName4=[dCell{2,idx4},'/', dCell{1,idx4}];
    load4=matfile(fileName4);
    varlist4=who(load4);
    inBand4Cell{i}=load4.(varlist4{1});

    %keep track of total length in order to preallocate later
    cellLength(i)=length(load1.(varlist1{1})); 
end

%% combine cells into one matrix for each band
% these are data that you can work with
inBand1=zeros(sum(cellLength),1);
inBand2=zeros(sum(cellLength),1);
inBand3=zeros(sum(cellLength),1);
inBand4=zeros(sum(cellLength),1);

runningIndex=0;
for i=1:numel(reportNum)
    currentLength=cellLength(i);
    inBand1(runningIndex+1:runningIndex+currentLength)=inBand1Cell{i};
    inBand2(runningIndex+1:runningIndex+currentLength)=inBand2Cell{i};
    inBand3(runningIndex+1:runningIndex+currentLength)=inBand3Cell{i};
    inBand4(runningIndex+1:runningIndex+currentLength)=inBand4Cell{i};
    runningIndex=runningIndex+currentLength;
end

% define time
T=0.0005:0.0005:sum(cellLength)/Fs';
T=T';

%% signal smoothing
dt=1/Fs;
[b,g] = sgolay(3,framelen); % 3 is somewhat arbitrary (5 turned out bad and 
% I don't want to use an even function. lower it is the smoother the function will be

ycenter1 = conv(inBand1,b((framelen+1)/2,:),'valid');
ybegin1 = b(end:-1:(framelen+3)/2,:) * inBand1(framelen:-1:1);
yend1 = b((framelen-1)/2:-1:1,:) * inBand1(end:-1:end-(framelen-1));
inBand1Smooth=[ybegin1; ycenter1; yend1];

ycenter2 = conv(inBand2,b((framelen+1)/2,:),'valid');
ybegin2 = b(end:-1:(framelen+3)/2,:) * inBand2(framelen:-1:1);
yend2 = b((framelen-1)/2:-1:1,:) * inBand2(end:-1:end-(framelen-1));
inBand2Smooth=[ybegin2; ycenter2; yend2];

ycenter3 = conv(inBand3,b((framelen+1)/2,:),'valid');
ybegin3 = b(end:-1:(framelen+3)/2,:) * inBand3(framelen:-1:1);
yend3 = b((framelen-1)/2:-1:1,:) * inBand3(end:-1:end-(framelen-1));
inBand3Smooth=[ybegin3; ycenter3; yend3];

ycenter4 = conv(inBand4,b((framelen+1)/2,:),'valid');
ybegin4 = b(end:-1:(framelen+3)/2,:) * inBand4(framelen:-1:1);
yend4 = b((framelen-1)/2:-1:1,:) * inBand4(end:-1:end-(framelen-1));
inBand4Smooth=[ybegin4; ycenter4; yend4];

%% derivatives

p=1; % dervitative number e.g. p=1 is the first derivative 
inBand1Der= conv(inBand1Smooth, factorial(p)/(-dt)^p * g(:,p+1), 'same');
inBand2Der= conv(inBand2Smooth, factorial(p)/(-dt)^p * g(:,p+1), 'same');
inBand3Der= conv(inBand3Smooth, factorial(p)/(-dt)^p * g(:,p+1), 'same');
inBand4Der= conv(inBand4Smooth, factorial(p)/(-dt)^p * g(:,p+1), 'same');

%% this turned out not to change but I still wrote it and we might want it later
%% Fourier transform
% converts into the frequency domain

% for full time line
L2=length(T);
inBand1full_Y = fft(inBand1);
inBand1full_P2 = abs(inBand1full_Y/L2);
inBand1full_P1 = inBand1full_P2(1:L2/2+1);

inBand2full_Y = fft(inBand2);
inBand2full_P2 = abs(inBand2full_Y/L2);
inBand2full_P1 = inBand2full_P2(1:L2/2+1);

inBand3full_Y = fft(inBand3);
inBand3full_P2 = abs(inBand3full_Y/L2);
inBand3full_P1 = inBand3full_P2(1:L2/2+1);

inBand4full_Y = fft(inBand4);
inBand4full_P2 = abs(inBand4full_Y/L2);
inBand4full_P1 = inBand4full_P2(1:L2/2+1);

% for desired time band
L1=tEnd-tStart;

inBand1_Y = fft(inBand1(tStart:tEnd));
inBand1_P2 = abs(inBand1_Y/L1);
inBand1_P1 = inBand1_P2(1:L1/2+1);

inBand2_Y = fft(inBand2(tStart:tEnd));
inBand2_P2 = abs(inBand2_Y/L1);
inBand2_P1 = inBand2_P2(1:L1/2+1);

inBand3_Y = fft(inBand3(tStart:tEnd));
inBand3_P2 = abs(inBand3_Y/L1);
inBand3_P1 = inBand3_P2(1:L1/2+1);

inBand4_Y = fft(inBand4(tStart:tEnd));
inBand4_P2 = abs(inBand4_Y/L1);
inBand4_P1 = inBand4_P2(1:L1/2+1);

f1 = Fs*(0:(L1/2))/L1;
f1=f1';
f2 = Fs*(0:(L2/2))/L2;
f2=f2';

%% plotting full timeline

idxSample=1:1000:length(T);

figure(190)
clf
tile=tiledlayout(3,1);
title(tile,'whole signals')

% smooth plot
nexttile
plot(T(idxSample),inBand1Smooth(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand2Smooth(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand3Smooth(idxSample), 'LineWidth',2)
hold on
plot(T(idxSample),inBand4Smooth(idxSample), 'LineWidth',2)
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

% change tiledlayout from 2 to 3 to plot this
% frequency plot
nexttile
plot(f2,inBand1full_P1, 'LineWidth',2)
hold on
plot(f2,inBand2full_P1, 'LineWidth',2)
hold on
plot(f2,inBand3full_P1, 'LineWidth',2)
hold on
plot(f2,inBand4full_P1, 'LineWidth',2)
legend('band 1', 'band 2', 'band 3', 'band 4')
xlim([100 150])
title('fourier transform')
xlabel('frequency (Hz)')
ylabel('(Power spectrum (arbitrary units)')
set(gca,'YScale','log')


%% plotting time points

idxT=tStart:tEnd;

figure(379)
clf
tile=tiledlayout(3,1);
title(tile,['signals from time point ', num2str(tStart/Fs) , ' seconds to ', num2str(tEnd/Fs) , ' seconds' ])

% smooth plot
nexttile
plot(T(idxT),inBand1Smooth(idxT), 'LineWidth',2)
hold on
plot(T(idxT),inBand2Smooth(idxT), 'LineWidth',2)
hold on
plot(T(idxT),inBand3Smooth(idxT), 'LineWidth',2)
hold on
plot(T(idxT),inBand4Smooth(idxT), 'LineWidth',2)
xlim([tStart/Fs tEnd/Fs])
legend('band 1', 'band 2', 'band 3', 'band 4')
title('smoothed bands')
xlabel('time (s)')
ylabel('Power (dB)')

% derivative plot
nexttile
plot(T(idxT),inBand1Der(idxT), 'LineWidth',2)
hold on
plot(T(idxT),inBand2Der(idxT), 'LineWidth',2)
hold on
plot(T(idxT),inBand3Der(idxT), 'LineWidth',2)
hold on
plot(T(idxT),inBand4Der(idxT), 'LineWidth',2)
legend('band 1', 'band 2', 'band 3', 'band 4')
xlim([tStart/Fs tEnd/Fs])
title('derivatives')
xlabel('time (s)')
ylabel('Power/time (dB/s)')

% change tiledlayout from 2 to 3 to plot this
% frequency plot
nexttile
plot(f1,inBand1_P1, 'LineWidth',2)
hold on
plot(f1,inBand2_P1, 'LineWidth',2)
hold on
plot(f1,inBand3_P1, 'LineWidth',2)
hold on
plot(f1,inBand4_P1, 'LineWidth',2)
legend('band 1', 'band 2', 'band 3', 'band 4')
xlim([100 150])
title('fourier transform')
xlabel('frequency (Hz)')
ylabel('(Power spectrum (arbitrary units)')
set(gca,'YScale','log')
