function [inBands,data] = loadPatient(dirName, data)
%function extracts all 4 inBands from each report for a patient, combines
%them and returns them
%
%INPUTS 
%   dirName == directory path for the "Analyzed data" folder
%
%OUTPUT
%   inBands == 4x1 cell of each inBand
%  
%call example: loadPatient(dirName);
%
% dirName = /Users/dtcasey/Documents/MATLAB/EMG/20220913-UVM-EMG-028/Analyzed Data;
%%
disp(' Loading patient, so be patient'); disp(' ')

dReports=dir(dirName);
dReportsCell=struct2cell(dReports);
n=length(find(contains(dReportsCell(1,:),'Report')));
reportNum=1:n;

inBand1Cell=cell(1,numel(reportNum));
inBand2Cell=cell(1,numel(reportNum));
inBand3Cell=cell(1,numel(reportNum));
inBand4Cell=cell(1,numel(reportNum));

cellLength=zeros(length(reportNum),1);

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

inBands=cell(4,1);
inBands{1}=inBand1;
inBands{2}=inBand2;
inBands{3}=inBand3;
inBands{4}=inBand4;

% check if anesthetic times already exist
latestData = find(contains(dReportsCell(1,:),'caseData'), 1, 'last' );
if ~isempty(latestData)
    fileName=[dirName,'/',dReportsCell{1,latestData}];
    dataOld=load(fileName);
    data.anesthetic_time=dataOld.data.anesthetic_time;
    data.needle_time=dataOld.data.needle_time;
    data.onset_best_iteration=dataOld.data.onset_best_iteration;
end


disp(' Done loading patient. Not so bad, huh?'); disp(' ')
end