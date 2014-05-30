function Test_GetOverlapAllParameters_MultipleIdx(IdAlpha,IdBeta,IdOmega,idVideo)
% Initializate
NameDataset='moseg_dataset';
dataset_path=['./../../dataset/',NameDataset,'/'];
list=dir(dataset_path);
id_folders=[list.isdir];
NameFolders={list(id_folders).name};
NameFolders=NameFolders(3:end); % Delete '.' and '..'
NameVideo=NameFolders{idVideo};

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
IdFramesWithGT=zeros(1,NumGtFrames-1);
GT=cell(1,NumGtFrames-1);
for id=2:NumGtFrames % id=1 frame initial, groundtruth selected to track, don't get an output of algorithm
    NameGtFrame=NameGt{id};
    GT{id-1}=im2double(imread([dataset_path,NameVideo,'/',NameGtFrame]));
    strNameGt=textscan(NameGtFrame,'%s','Delimiter','_.');
    IdFramesWithGT(id-1)=str2double(strNameGt{1}(2));
end

% ----- Compute overlap --------
Overlap=zeros(1,numel(IdFramesWithGT));
for m=1:numel(IdFramesWithGT)
    id=IdFramesWithGT(m);
    NumPixelsIntersection=sum(sum(Mask{id}.*GT{m}));
    SumMaskGT=Mask{id}+GT{m};
    NumPixelsUnion=sum(sum(SumMaskGT~=0));
    Overlap(m)=NumPixelsIntersection./NumPixelsUnion;
end

% Save Output 
savepath=['./../results/experiments/',NameDataset,'/SLICsegmentation/'];
parameters=['_a:',num2str(params.alpha),'_b:',num2str(params.beta),'_w:',num2str(params.omega)];
OverlapFileName=[savepath,'OutputOverlap_', NameVideo, parameters, '.mat'];
save(OverlapFileName,'Overlap','IdFramesWithGT');
