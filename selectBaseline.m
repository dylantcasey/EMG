function [index, data] = selectBaseline(T, inBandSmooth, inBandDerivative, baselineEnd, data)
%function plots all 4 inBands with their derivatives. Allows manipulation
%of the plots, pressing *space* to continue. Allows to select a beginning
%and end points with the mouse, pressing *enter* to finish. Returns their
%indices
%
%INPUTS 
%   T == full time matrix
%   inBandSmooth == smoothed inBand data
%   inBandDerivatives == derivatives of inBand data
%   baselineEnd == this is the time the anesthetic went in
%
%OUTPUT
%   index == 2x1 matrix of start and end indices
%  
%call example: selectBaseline(time, Smooth, Derivative, 1500);
%
% CHECK FOR PREVIOUS SELECTION OR WRITE A NEW ONE
%%
disp('  Time to choose your baseline! Carefully.'); disp(' ')

Fs=round(1/mean(diff(T)));
%separate smooth bands
inBand1Smooth=inBandSmooth{1};
inBand2Smooth=inBandSmooth{2};
inBand3Smooth=inBandSmooth{3};
inBand4Smooth=inBandSmooth{4};

%separate derivatives
inBand1Der=inBandDerivative{1};
inBand2Der=inBandDerivative{2};
inBand3Der=inBandDerivative{3};
inBand4Der=inBandDerivative{4};
%%
%plot baseline region
fig=figure(193);
fig.Units='normalized';
fig.Position = [0.05 0.3 0.9 0.45];
clf
tile=tiledlayout(2,1);
title(tile,'Baseline plots')

baselineRange = baselineEnd-300*2000:baselineEnd;
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

%%
% GUI input
hold on

disp('  ** press SPACE when ready to select points **'); disp(' ')
w=1;
while w~=0
  disp('  ** Try to find a section where derivative is close to 0 **'); disp(' ')
  disp('  ** preferably greater than 10 seconds **'); disp(' ')
  w = waitforbuttonpress;
  while w==0
    w = waitforbuttonpress;
  end
  cfg = gcf();
  ch = double(get(cfg, 'CurrentCharacter'));
  if ch == 13 % ENTER button
      %Check to make sure that the start time is before the end time OR swap them
        if end1x < strt1x
            disp('  Swapping start and end times'); disp(' ')
            end_temp = end1x;
            end1x = strt1x;
            strt1x = end_temp;
        end
        
        %Compute the duration of the baseline segment
        delta1x = end1x - strt1x;

        disp(['baseline segment is ', num2str(delta1x),' seconds'])
        break
%         if delta1x>10
%             disp('  Exiting baseline selection'); disp(' ')
%             break;
%         else
%             disp('baseline segment is not long enough, idiot. Try again. >10 SECONDS this time!!'); disp(' ')
%             children = get(gca, 'children');
%             delete(children(1));
%             delete(children(2));
%             disp('  ** press ENTER when done selecting points **'); disp(' ')
%         end
  end
  if ch == 32 % SPACE button
      disp('  ** press ENTER when done selecting points **'); disp(' ')
  end

f6b=waitbar(.5,'*** Click on the START of the Baseline period ***');
        th = findall(f6b, 'Type', 'Text');
        th.FontSize = 14;
[strt1x,~] = ginput(1); close(f6b)

plot([strt1x strt1x], [ax(3) ax(4)],'k--','LineWidth',2);

f6b=waitbar(1,'*** Click on the END of the Baseline period ***');
        th = findall(f6b, 'Type', 'Text');
        th.FontSize = 14;
[end1x,~] = ginput(1); close(f6b)

plot([end1x end1x], [ax(3) ax(4)],'k-.','LineWidth',2);


end

hold off

%set start and end index

idxStart = find(T>strt1x,1);      %Start index
idxEnd = find(T<end1x, 1, 'last' ); 

index = [idxStart; idxEnd];

disp('  I guess you are going with that... '); disp(' ')
close(193)

%save data
% save data
data.baseline_start_index = idxStart; 
data.baseline_start_time = idxStart/Fs; 
data.baseline_end_index = idxEnd; 
data.baseline_end_time = idxEnd/Fs; 
data.baseline_duration = idxEnd/Fs - idxStart/Fs;

end