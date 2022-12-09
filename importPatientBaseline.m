% names with numbers in them will refer to their band

% GUI input
% find your patient and select the "Analyzed Data" file
dirName=uigetdir;
dReports=dir(dirName);

prompt = {'What time was anesthetic given? (seconds)'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'1000'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

baselineEnd = str2num(answer{1})*2000; %2000 is 1 second
% don't change these
dReportsCell=struct2cell(dReports);
n=length(find(contains(dReportsCell(1,:),'Report')));
reportNum=1:n;
% sampling frequency
Fs=2000;
framelen=1001;

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

%% selecting baseline

%plot baseline region
figure(193)
clf
tile=tiledlayout(2,1);
title(tile,'Baseline plots')

baselineRange= baselineEnd-300*2000:baselineEnd;
ax1=nexttile;
plot(T(baselineRange),inBand1Smooth(baselineRange), 'LineWidth',2)
hold on
plot(T(baselineRange),inBand2Smooth(baselineRange), 'LineWidth',2)
hold on
plot(T(baselineRange),inBand3Smooth(baselineRange), 'LineWidth',2)
hold on
plot(T(baselineRange),inBand4Smooth(baselineRange), 'LineWidth',2)
ax=axis;
legend('band 1', 'band 2', 'band 3', 'band 4')
title('smoothed bands')
xlabel('time (s)')
ylabel('Power (dB)')

ax2=nexttile;
plot(T(baselineRange),inBand1Der(baselineRange), 'LineWidth',2)
hold on
plot(T(baselineRange),inBand2Der(baselineRange), 'LineWidth',2)
hold on
plot(T(baselineRange),inBand3Der(baselineRange), 'LineWidth',2)
hold on
plot(T(baselineRange),inBand4Der(baselineRange), 'LineWidth',2)
hold on
yline(0, 'LineWidth',3,'HandleVisibility','off')
legend('band 1', 'band 2', 'band 3', 'band 4')
title('derivatives')
xlabel('time (s)')
ylabel('Power/time (dB/s)')

linkaxes([ax1 ax2],'x');


% GUI input
hold on

disp('  ** press SPACE when ready to select points **')
w=1;
while w~=0
  w = waitforbuttonpress;
  while w==0
    w = waitforbuttonpress;
  end
  cfg = gcf();
  ch = double(get(cfg, 'CurrentCharacter'));
  if ch == 13 % ENTER button
      %Check to make sure that the start time is before the end time OR swap them
        if end1x < strt1x
            disp('  ** Swapping start and end times **')
            end_temp = end1x;
            end1x = strt1x;
            strt1x = end_temp;
        end

        %Compute the duration of the baseline segment
        delta1x = end1x - strt1x;
        disp(['baseline segment is ', num2str(delta1x),' seconds'])
        if delta1x>10
            disp('  ** Exiting baseline selection **')
            break;
        else
            disp('baseline segment is not long enough, idiot. Try again. >10 SECONDS this time!!')
            children = get(gca, 'children');
            delete(children(1));
            delete(children(2));
            disp('  ** press ENTER when done selecting points **')
        end
  end
  if ch == 32 % SPACE button
      disp('  ** press ENTER when done selecting points **')
  end
f6b=waitbar(.5,'*** Click on the START of the Baseline period ***');
        th = findall(f6b, 'Type', 'Text');
        th.FontSize = 14;
[strt1x,strt1y] = ginput(1); close(f6b)

strtLine=plot([strt1x strt1x], [ax(3) ax(4)],'k--','LineWidth',2);

f6b=waitbar(1,'*** Click on the END of the Baseline period ***');
        th = findall(f6b, 'Type', 'Text');
        th.FontSize = 14;
[end1x,end1y] = ginput(1); close(f6b)

endLine=plot([end1x end1x], [ax(3) ax(4)],'k-.','LineWidth',2);


end

hold off

%set start and end index

idxStart = find(T>strt1x,1);      %Start index
idxEnd = find(T<end1x, 1, 'last' ); 
%% OFFSET

offset1=mean(inBand1(idxStart:idxEnd));
offset2=mean(inBand2(idxStart:idxEnd));
offset3=mean(inBand3(idxStart:idxEnd));
offset4=mean(inBand4(idxStart:idxEnd));

inBand1SmoothOffset=inBand1Smooth-offset1;
inBand2SmoothOffset=inBand2Smooth-offset2;
inBand3SmoothOffset=inBand3Smooth-offset3;
inBand4SmoothOffset=inBand4Smooth-offset4;

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
