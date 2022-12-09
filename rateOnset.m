function [U,data]=rateOnset(T, inBandsSmooth, inBands, idxStart, data)

Fs=round(1/mean(diff(T)));

prompt = {'How many seconds after anesthetic is given do you want to observe for rate? (seconds)'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'15'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

idxEnd = str2double(answer{1})*Fs; %2000 is 1 second
idxRange=idxStart-idxEnd/2:idxStart+1.5*idxEnd;
idxSubRange=idxStart:idxStart+idxEnd;
uRange=(idxEnd/2:1.5*idxEnd);
iter=[50 100 150 200];
alph=9*10^3;
dt=1/Fs;

colorMat=["#0072BD", "#D95319", "#EDB120", "#7E2F8E"];

%% test iterations
v=1;
if isfield(data,'onset_best_iteration')
    prompt = {append('A previous run has determined ', num2str(data.onset_best_iteration), ...
        ' to be optimal. Would you like to use that value? (y/n)') };
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'y'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);

    if lower(answer{1})=='y'
        iterBest=data.onset_best_iteration;
        v=0;
    else
        v=1;
    end
end

while v==1
    disp(' Checking which number of iterations look best'); disp('')
    U2=cell(4,1);
    fig=figure(188);
    clf
    fig.Units='normalized';
    fig.Position = [0.05 0.3 0.9 0.55];
    clf
    tile=tiledlayout(length(iter),2);
    title(tile,'onset')
    bandExample=2;
    inBand=inBands{bandExample};
    inBandSmooth=inBandsSmooth{bandExample};
    SSR=zeros(length(iter),1);
    for jj=1:length(iter)
        tic
        u = TVRegDiff( inBand(idxRange), iter(jj), alph, [], [], [], dt, 0, 0);
        U2{jj}=u(uRange);
    
        uAnti=cumtrapz(u)/Fs;
        uAnti=uAnti+(inBandSmooth(idxStart)-uAnti(idxEnd/2));
        
        nexttile;
        plot(T(idxSubRange),inBandSmooth(idxSubRange), 'LineWidth',2, 'Color', colorMat(jj))
        hold on
        plot(T(idxSubRange),uAnti(uRange), '--', 'LineWidth',2, 'Color', colorMat(jj))
        title(['smooth band ',num2str(bandExample) ,' at iteration ',num2str(iter(jj))]) 
        legend('original', 'antiderivative','Location','southwest')
        xlabel('time (s)')
        ylabel('Power (dB)')
        
        nexttile
        plot(T(idxSubRange), u(uRange), 'LineWidth',2, 'Color', colorMat(jj))
    %         hold on 
    %         plot(T(idxRange), gradient(inBandSmooth(idxRange))*Fs, 'LineWidth',2)
        title(['derivative of band ', num2str(bandExample) ,' at iteration ',num2str(iter(jj))])
        xlabel('time (s)')
        ylabel('Power/time (dB/s)')
    
        drawnow
        
        SSR(jj)=sum((inBandSmooth(idxSubRange)-uAnti(uRange)).^2);
        toc
    end
    
    iterBest=iter(min(SSR)==SSR);
    data.onset_SSR=SSR;
    disp([' We determined that ', num2str(iterBest),' is the best number of iterations']); disp('')
    v=0;
    close(188)
end

%% final plot of each band and derivative
U=cell(4,1);
ax=zeros(4,2);
w=1;
while w~=0
    fig=figure(198);
    clf
    fig.Units='normalized';
    fig.Position = [0.05 0.3 0.9 0.55];
    clf
    tile=tiledlayout(4,2);
    title(tile,'onset')
    
    for ii=1:4
        inBand=inBands{ii};
        inBandSmooth=inBandsSmooth{ii};
        u = TVRegDiff( inBand(idxRange), iterBest, alph, [], [], [], dt, 0, 0);
        U{ii}=u(uRange);

        uAnti=cumtrapz(u)/Fs;
        uAnti=uAnti+(inBandSmooth(idxStart)-uAnti(idxEnd/2));
        
        nexttile;
        plot(T(idxSubRange),uAnti(uRange), '--', 'LineWidth',2, 'Color', colorMat(ii))
        hold on
        plot(T(idxSubRange),inBandSmooth(idxSubRange), 'LineWidth',2, 'Color', colorMat(ii))
        axTemp=axis;
        ax(ii,1)=axTemp(3);
        ax(ii,2)=axTemp(4);
        title(['smooth band ',num2str(ii)]) 
        xlabel('time (s)')
        ylabel('Power (dB)')
        
        nexttile
        plot(T(idxSubRange), u(uRange), 'LineWidth',2, 'Color', colorMat(ii))
%         hold on 
%         plot(T(idxRange), gradient(inBandSmooth(idxRange))*Fs, 'LineWidth',2)
        title(['derivative of band ',num2str(ii)])
        xlabel('time (s)')
        ylabel('Power/time (dB/s)')

        drawnow
    end

prompt = {'Is this time range sufficient? (y/n)'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'y'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

if lower(answer{1})=='y'
    disp('  ** You will now be choosing rate of onset endpoints **');
    disp('  ** This will be done for each band **');
    disp('  ** MUST BE DONE IN ORDER!!! **'); disp(' ')
    disp('  ** press SPACE when ready to select endpoints **'); disp(' ')
    v=1;
    while v~=0
        v = waitforbuttonpress;
        while v==0
            v = waitforbuttonpress;
        end
        disp('  ** press SPACE when done selecting endpoint **'); disp(' ')
        disp('  ** press ENTER when done selecting endpoint **'); disp(' ')
        cfg = gcf();
        ch = double(get(cfg, 'CurrentCharacter'));
        if ch == 13 % ENTER button
%             disp(['Endpoint for rate of onset is ', num2str(valley1x),' seconds'])
            endOnset=[valley1x; valley2x; valley3x; valley4x];
            w=0;
            break
        end
        if ch == 32 % SPACE button
            disp('  ** press ENTER when done selecting endpoint **'); disp(' ')
        end
        if ch == 8 % Backspace button
            children = get(gca, 'children');
            if length(children)>6
                delete(children(1));
            end
        end
        
        % select for each band
        disp('*** Select the band 1 endpoint for rate of onset (should be local minimum) ***');
        [valley1x,~] = ginput(1);
        hold on 
        plot([valley1x valley1x], [ax(1,1) ax(1,2)],'k-','LineWidth',2);

        disp('*** Select the band 2 endpoint for rate of onset (should be local minimum) ***');
        [valley2x,~] = ginput(1); 
        hold on 
        plot([valley2x valley2x], [ax(2,1) ax(2,2)],'k-','LineWidth',2);

        disp('*** Select the band 3 endpoint for rate of onset (should be local minimum) ***');
        [valley3x,~] = ginput(1); 
        hold on 
        plot([valley3x valley3x], [ax(3,1) ax(3,2)],'k-','LineWidth',2);

        disp('*** Select the band 4 endpoint for rate of onset (should be local minimum) ***');
        [valley4x,~] = ginput(1);
        hold on 
        plot([valley4x valley4x], [ax(4,1) ax(4,2)],'k-','LineWidth',2);
    end
 
else
    prompt = {'How many seconds after anesthetic is given do you want to observe for rate? (seconds)'};
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'20'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    idxEnd = str2double(answer{1})*Fs; %2000 is 1 second
    idxRange=idxStart-idxEnd/2:idxStart+1.5*idxEnd;
    idxSubRange=idxStart:idxStart+idxEnd;
    uRange=(idxEnd/2:1.5*idxEnd);
end

delta = endOnset - T(idxStart);
meanDer = zeros(4,1);
stdDer = zeros(4,1);
for ii=1:4
    derivative=U{ii};
    rangeDer = 1:delta(ii)*Fs;
    onsetDer=derivative(rangeDer);
    meanDer(ii)=mean(onsetDer);
    stdDer(ii)=std(onsetDer);
end

data.onset_end=endOnset;
data.onset_delta=delta;
data.onset_mean=meanDer;
data.onset_std=stdDer;
data.onset_iteration=iter;
data.onset_best_iteration=iterBest;

close(198)

end