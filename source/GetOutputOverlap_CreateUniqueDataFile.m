% load output file and create unique data file
OutputPath='./../results/experiments/moseg_dataset/SLICsegmentation/';
list=dir(OutputPath);
NameFiles={list(4:end).name};
NumFiles=numel(NameFiles);

AlphaValues=[0.25, 0.5, 0.75, 1];
BetaValues=[0.25, 0.5, 0.75, 1];
OmegaValues=[0.5, 1, 1.5, 2];
NumAlphaValues=numel(AlphaValues);
NumBetaValues=numel(BetaValues);
NumOmegaValues=numel(OmegaValues);

for i=1:NumFiles
    Name=NameFiles{i};
    strName=textscan(Name,'%s','Delimiter','_:');
    
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
    
    load([OutputPath Name])
    OverlapGlobal.(NameVideo){idAlpha,idBeta,idOmega}=Overlap;
    IdFramesGtGlobal.(NameVideo){idAlpha,idBeta,idOmega}=IdFramesWithGT;
end
savename=[OutputPath,'OverlapGlobal','.mat'];
save(savename,'OverlapGlobal','IdFramesGtGlobal');