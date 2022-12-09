function data = maxDiff(Fs, inBands, data)

prompt = { 'In what range do you want to find the maximum difference? (seconds)'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'20'};
answer = inputdlg(prompt,dlgtitle,dims,definput);
seconds=answer{1};

k=seconds*Fs;

inBandsMean = cellfun(@(x) movmean(x,k), inBands, 'UniformOutput', false);
inBandsMin = cellfun(@(x) min(x(k:end-k)), inBandsMean, 'UniformOutput', false);
inBandsMinIndex = cellfun(@(x,y) find(x==y), inBandsMean, inBandsMin, 'UniformOutput', false);

offset=mat2cell(data.offset_mean,[1 1 1 1]);

inBandsOffset= cellfun(@(x,y) x-y, inBands, offset, 'UniformOutput', false);

inBandsMinRange = cellfun(@(x) x-k/2:x+k/2, inBandsMinIndex, 'UniformOutput', false);

inBandsMaxDiff = cellfun(@(x,y) mean(x(y)), inBandsOffset, inBandsMinRange, 'UniformOutput', false);

data.maxDiff_index = cell2mat(inBandsMinIndex);
data.maxDiff = cell2mat(inBandsMaxDiff);

%% awful stuff, please ignore

% % not far off from maxDiff anyways
% inBandsMeanSum = inBandsMean{1}+inBandsMean{2}+inBandsMean{3}+inBandsMean{4};
% inBandsMeanSumMinIndex = find(inBandsMeanSum==min(inBandsMeanSum));
% data.maxDiff_cum_min_index = inBandsMeanSumMinIndex;
% inBandsSumMaxDiff = cellfun(@(x) mean(x(inBandsMeanSumMinIndex-k/2:inBandsMeanSumMinIndex+k/2 )), inBandsOffset, 'UniformOutput', false);

% % scary scalar stuff
% inBandsScalar = cellfun(@(x) dB2scalar(x), inBands, 'UniformOutput', false);
% inBandsScalarSum = inBandsScalar{1}+inBandsScalar{2}+inBandsScalar{3}+inBandsScalar{4};
% inBandsScalarSumMean=movmean(inBandsScalarSum,k);
% inBandsScalarSumMeanMinIndex= find(inBandsScalarSumMean==min(inBandsScalarSumMean));

% %% checking movmean
% k=20*Fs;
% 
% %separate out bands for plotting
% 
% inBand1Smooth=movmean(inBandSmooth{1},k);
% inBand2Smooth=movmean(inBandSmooth{2},k);
% inBand3Smooth=movmean(inBandSmooth{3},k);
% inBand4Smooth=movmean(inBandSmooth{4},k);
% 
% inBand1Clean=movmean(inBandClean{1},k);
% inBand2Clean=movmean(inBandClean{2},k);
% inBand3Clean=movmean(inBandClean{3},k);
% inBand4Clean=movmean(inBandClean{4},k);
% 
% inBand1Raw=movmean(inBands{1},k);
% inBand2Raw=movmean(inBands{2},k);
% inBand3Raw=movmean(inBands{3},k);
% inBand4Raw=movmean(inBands{4},k);
% 
% inBand1Filled=movmean(inBandFilled{1},k);
% inBand2Filled=movmean(inBandFilled{2},k);
% inBand3Filled=movmean(inBandFilled{3},k);
% inBand4Filled=movmean(inBandFilled{4},k);
% 
% %downsample
% 
% fig=figure(191);
% fig.Units='normalized';
% fig.Position = [0.05 0.3 0.9 0.55];
% clf
% tile=tiledlayout(2,2);
% title(tile,'whole signals')
% 
% % original plot
% ax1=nexttile;
% plot(T(idxSample),inBand1Smooth(idxSample), 'LineWidth',2)
% hold on
% plot(T(idxSample),inBand2Smooth(idxSample), 'LineWidth',2)
% hold on
% plot(T(idxSample),inBand3Smooth(idxSample), 'LineWidth',2)
% hold on
% plot(T(idxSample),inBand4Smooth(idxSample), 'LineWidth',2)
% hold on
% ax=axis;
% plot([T(anestheticEnd) T(anestheticEnd)], [ax(3) ax(4)],'k',...
%     'LineWidth',3, 'HandleVisibility','off');
% legend('band 1', 'band 2', 'band 3', 'band 4')
% title('moving mean of smoothed bands')
% xlabel('time (s)')
% ylabel('Power (dB)')
% 
% %smooth plot
% ax2=nexttile;
% plot(T(idxSample),inBand1Clean(idxSample), 'LineWidth',2)
% hold on
% plot(T(idxSample),inBand2Clean(idxSample), 'LineWidth',2)
% hold on
% plot(T(idxSample),inBand3Clean(idxSample), 'LineWidth',2)
% hold on
% plot(T(idxSample),inBand4Clean(idxSample), 'LineWidth',2)
% hold on
% ax=axis;
% plot([T(anestheticEnd) T(anestheticEnd)], [ax(3) ax(4)],'k',...
%     'LineWidth',3, 'HandleVisibility','off');
% legend('band 1', 'band 2', 'band 3', 'band 4')
% title('moving mean of cleaned smoothed bands')
% xlabel('time (s)')
% ylabel('Power (dB)')
% 
% % derivative plot
% ax3=nexttile;
% plot(T(idxSample),inBand1Raw(idxSample), 'LineWidth',2)
% hold on
% plot(T(idxSample),inBand2Raw(idxSample), 'LineWidth',2)
% hold on
% plot(T(idxSample),inBand3Raw(idxSample), 'LineWidth',2)
% hold on
% plot(T(idxSample),inBand4Raw(idxSample), 'LineWidth',2)
% hold on
% ax=axis;
% plot([T(anestheticEnd) T(anestheticEnd)], [ax(3) ax(4)],'k',...
%     'LineWidth',3, 'HandleVisibility','off');
% legend('band 1', 'band 2', 'band 3', 'band 4')
% title('moving mean of raw bands')
% xlabel('time (s)')
% ylabel('Power/time (dB/s)')
% 
% ax4=nexttile;
% plot(T(idxSample),inBand1Filled(idxSample), 'LineWidth',2)
% hold on
% plot(T(idxSample),inBand2Filled(idxSample), 'LineWidth',2)
% hold on
% plot(T(idxSample),inBand3Filled(idxSample), 'LineWidth',2)
% hold on
% plot(T(idxSample),inBand4Filled(idxSample), 'LineWidth',2)
% hold on
% ax=axis;
% plot([T(anestheticEnd) T(anestheticEnd)], [ax(3) ax(4)],'k',...
%     'LineWidth',3, 'HandleVisibility','off');
% legend('band 1', 'band 2', 'band 3', 'band 4')
% title('moving mean of filled raw bands')
% xlabel('time (s)')
% ylabel('Power/time (dB/s)')
% 
% linkaxes([ax1 ax2 ax3 ax4],'x');
end