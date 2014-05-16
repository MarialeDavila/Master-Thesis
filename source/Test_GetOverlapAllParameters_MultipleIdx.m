function Test_GetOverlapAllParameters_MultipleIdx(IdAlpha,IdBeta,IdOmega,idVideo)
% Initializate
dataset_path='./../../dataset/moseg_dataset/';
list=dir(dataset_path);
id_folders=[list.isdir];
NameFolders={list(id_folders).name};
NameFolders=NameFolders(3:end); % Delete '.' and '..'
NameVideo=NameFolders{idVideo};

% Load Overlap file if exist, else create new variables
NameDataset='moseg_dataset';
savepath=['./../results/experiments/',NameDataset,'/SLICsegmentation/'];
OverlapFileName=[savepath,'OutputOverlap_', NameVideo, '.mat'];
if exist(OverlapFileName,'file')==2   % if exist file .mat
    load(OverlapFileName)
else
    NumAlphaValues=4;
    NumBetaValues=4;
    NumOmegaValues=4;
    Overlap=cell(NumAlphaValues,NumBetaValues,NumOmegaValues);
    IdFramesWithGT=cell(NumAlphaValues,NumBetaValues,NumOmegaValues);
end

% Create params structure
AlphaValues=[0.25, 0.5, 0.75, 1];
BetaValues=[0.25, 0.5, 0.75, 1];
OmegaValues=[0.5, 1, 1.5, 2];
params.alpha=AlphaValues(IdAlpha);
params.beta=BetaValues(IdBeta);
params.omega=OmegaValues(IdOmega);

% --------- Execute Tracking Algorithm with specific parameters ------
Mask=TrackingArticulatedObject(NameVideo,params);

% -------- Get GroundTruth files -------------
% images gt
ListGt=dir([dataset_path,NameVideo,'/*.pgm']);
NameGt={ListGt.name};
NumGtFrames=numel(NameGt);
IdFramesGT=zeros(1,NumGtFrames-1);
GT=cell(1,NumGtFrames-1);
for id=2:NumGtFrames % id=1 frame initial, groundtruth selected to track, don't get an output of algorithm
    NameGtFrame=NameGt{id};
    GT{id-1}=im2double(imread([dataset_path,NameVideo,'/',NameGtFrame]));
    strNameGt=textscan(NameGtFrame,'%s','Delimiter','_.');
    IdFramesGT(id-1)=str2double(strNameGt{1}(2));
end

% ----- Compute overlap --------
OverlapPerVideo=zeros(1,numel(IdFramesGT));
for m=1:numel(IdFramesGT)
    id=IdFramesGT(m);
    NumPixelsIntersection=sum(sum(Mask{id}.*GT{m}));
    SumMaskGT=Mask{id}+GT{m};
    NumPixelsUnion=sum(sum(SumMaskGT~=0));
    OverlapPerVideo(m)=NumPixelsIntersection./NumPixelsUnion;
end

% Save
Overlap{IdAlpha,IdBeta,IdOmega}=OverlapPerVideo;
IdFramesWithGT{IdAlpha,IdBeta,IdOmega}=IdFramesGT;
save(OverlapFileName,'Overlap','IdFramesWithGT','-v7.3');
