function [peak1x, data] = checkAnestheticAdmin(T, inBandSmooth, data)

Fs=round(1/mean(diff(T)));

prompt = { 'When did the needle go it? (seconds)', 'About what time was anesthetic given? (seconds)'};
dlgtitle = 'Input';
dims = [1 35];
if isfield(data,'anesthetic_time')
    definput={num2str(data.needle_time), num2str(data.anesthetic_time)};
else
    definput = {'990', '1000'};
end
answer = inputdlg(prompt,dlgtitle,dims,definput);

needleTime=str2double(answer{1});
anestheticTime=str2double(answer{2});
deltaTime=abs(anestheticTime-needleTime);

needleTimeIdx=needleTime*Fs;
anestheticTimeIdx=anestheticTime*Fs;
bufferTimeIdx=max(deltaTime, 30)*Fs;
peak1x=anestheticTime;

%separate smooth bands
inBand1Smooth=inBandSmooth{1};
inBand2Smooth=inBandSmooth{2};
inBand3Smooth=inBandSmooth{3};
inBand4Smooth=inBandSmooth{4};

%plot baseline region
fig=figure(193);
fig.Units='normalized';
fig.Position = [0.05 0.3 0.3 0.45];
clf
title('anesthetic plots')
plotRange= needleTimeIdx-bufferTimeIdx:anestheticTimeIdx+deltaTime*Fs+bufferTimeIdx;
plot(T(plotRange),inBand1Smooth(plotRange), 'LineWidth',2)
hold on
plot(T(plotRange),inBand2Smooth(plotRange), 'LineWidth',2)
hold on
plot(T(plotRange),inBand3Smooth(plotRange), 'LineWidth',2)
hold on
plot(T(plotRange),inBand4Smooth(plotRange), 'LineWidth',2)
ax=axis;
hold on
plot([T(needleTimeIdx) T(needleTimeIdx)], [ax(3) ax(4)],'k--','LineWidth',2);
hold on
plot([T(anestheticTimeIdx) T(anestheticTimeIdx)], [ax(3) ax(4)],'k-.','LineWidth',2);
legend('band 1', 'band 2', 'band 3', 'band 4', 'needle time', 'anesthetic time', 'Location', 'southwest')
title('smoothed bands')
xlabel('time (s)')
ylabel('Power (dB)')

%%
% GUI input
w=1;

prompt = { 'Do you want to select a new anesthetic admin time? (y/n)'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'n'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

if lower(answer{1})=='n'
    w=0;
end

hold on

disp('  ** press SPACE when ready to select peak **'); disp(' ')
while w~=0
  w = waitforbuttonpress;
  while w==0
        w = waitforbuttonpress;
  end
  cfg = gcf();
  ch = double(get(cfg, 'CurrentCharacter'));
  if ch == 13 % ENTER button
        disp(['New anesthetic time is ', num2str(peak1x),' seconds'])
        data.anesthetic_time_new=peak1x;
        break
  end
  if ch == 32 % SPACE button
        disp('  ** press ENTER when done selecting peak **'); disp(' ')
  end
  if ch == 8 % Backspace button
        children = get(gca, 'children');
        if length(children)>6
            delete(children(1));
        end
  end

f6b=waitbar(.5,'*** Select peak in anesthetic admin period ***');
        th = findall(f6b, 'Type', 'Text');
        th.FontSize = 14;
[peak1x,~] = ginput(1); close(f6b)

plot([peak1x peak1x], [ax(3) ax(4)],'k-','LineWidth',2);

% record data
data.anesthetic_time=anestheticTime;
data.needle_time = needleTime;
end



