% load output file and create unique data file
function [OverlapGlobal,IdFramesGtGlobal,OutputMetricsGlobal] = GetOutputOverlap_CreateUniqueDataFile(NameDataset)
% NameDataset='moseg_dataset'; % 'SegTrack' 'CarsMoseg' 'MCCD'
OutputPath=['./../results/experiments/',NameDataset,'/GMM/'];
list=dir(OutputPath);
NameFiles={list(3:end).name};
NumFiles=numel(NameFiles);

if strcmp(NameDataset,'CarsMoseg')
    AlphaValues=[0.25, 0.5, 0.75, 1];
    BetaValues=[0.25, 0.5, 0.75, 1];
    OmegaValues=[0.5, 1, 1.5, 2];
else
    AlphaValues=[0.25, 0.5, 0.75];
    BetaValues=[0.25, 0.5, 0.75];
    OmegaValues=[0.5, 1];
end


for i=1:NumFiles
    Name=NameFiles{i};
    strName=textscan(Name,'%s','Delimiter','_:');
    if strcmp(strName{1},'OverlapGlobal.mat')
        break
    end
    if numel(strName{1})==5
        NameVideo=strName{1}{2};
        
        alpha=strName{1}{3};
        alpha=textscan(alpha,'%s','Delimiter','a');
        alpha=str2double(alpha{1}{2});
        [dummy idAlpha]=ismember(alpha,AlphaValues);
        
        beta=strName{1}{4};
        beta=textscan(beta,'%s','Delimiter','b');
        beta=str2double(beta{1}{2});
        [dummy idBeta]=ismember(beta,BetaValues);
        
        omega=strName{1}{5};
        omega=textscan(omega,'%s','Delimiter','w');
        omega=textscan(omega{1}{2},'%n');
        omega=omega{1};
        [dummy idOmega]=ismember(omega,OmegaValues);
    else
        NameVideo=strName{1}{2};
        
        alpha=strName{1}{4};
        alpha=str2double(alpha);
        [dummy idAlpha]=ismember(alpha,AlphaValues);
        
        beta=strName{1}{6};
        beta=str2double(beta);
        [dummy idBeta]=ismember(beta,BetaValues);
        
        omega=strName{1}{8};
        omega=textscan(omega,'%n');
        omega=omega{1};
        [dummy idOmega]=ismember(omega,OmegaValues);
    end
    load([OutputPath Name])
    OverlapGlobal.(NameVideo){idAlpha,idBeta,idOmega}=Overlap;
    IdFramesGtGlobal.(NameVideo){idAlpha,idBeta,idOmega}=IdFramesWithGT;
    OutputMetricsGlobal.(NameVideo){idAlpha,idBeta,idOmega}=OutputMetrics;
end
savename=[OutputPath,'OverlapGlobal','.mat'];
save(savename,'OverlapGlobal','IdFramesGtGlobal');