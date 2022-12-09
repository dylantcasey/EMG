function inBandFill=cleanBands(T, inBandSmooth, inBands, idxBaseline, anestheticIndex)


colorMat=["#0072BD", "#D95319", "#EDB120", "#7E2F8E"];
disp('  Cut out errors '); disp(' ')
inBandFill=cell(4,1);

for j=1:4
    inBandOG=inBandSmooth{j};
    inBandTemp=inBandOG;
    inBandRaw=inBands{j};
    inBandMean=mean(inBandRaw(idxBaseline(1):idxBaseline(2)));
    brushedSections = zeros(1,length(inBandTemp));
    w=1;
    i=1;
    disp('  ** press SPACE to remove brushed section **'); disp(' ')
    disp('  ** press ENTER when done brushing section **'); disp(' ')
    disp('  ** press BACKSPACE to remove previously brushed section **'); disp(' ')
    while w~=0
        %replot
        fig=figure(143);
        fig.Units='normalized';
        fig.Position = [0.05 0.3 0.9 0.4];
        clf
        p1=plot(T,inBandTemp, 'LineWidth',2, 'Color', colorMat(j));
        ax=axis;
        hold on
        plot([T(anestheticIndex) T(anestheticIndex)], [ax(3) ax(4)],'k','LineWidth',3);
        title(['inBand ', num2str(j)])
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
          if ~isempty(p1.BrushData)
              brushedLocs = logical(p1.BrushData);
              inBandTemp(brushedLocs)=NaN;
                
              refreshdata
              drawnow
        
              %store locations so they can be deleted
              brushedSections(i,:)=brushedLocs;
              i=i+1;
          end
        end
        if ch == 8 % Backspace button
            if i>1
                disp(' Restoring previously brushed section'); disp(' ')
                restoreIndex=logical(brushedSections(i-1,:));
                inBandTemp(restoreIndex)=inBandOG(restoreIndex);
                brushedSections(i-1,:)=[];
                i=i-1;
    
                refreshdata
                drawnow
            end
        end
    end
    brushedIndex = logical(sum(brushedSections,1));
    brushedIndexThres=inBandRaw>inBandMean;
    indexThreshold = logical(brushedIndexThres.*brushedIndex');
    inBandRaw(indexThreshold)=NaN;
    inBandFill{j} = fillmissing(inBandRaw,'pchip');
    disp('   Onto the next inBand! '); disp(' ')
end
    disp(' Someone should figure out how to automate that '); disp(' ')
    close(143)
end
