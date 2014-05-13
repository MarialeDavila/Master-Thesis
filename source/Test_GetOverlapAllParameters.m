function Test_GetOverlapAllParameters(idVideo)

dataset_path='./../../dataset/moseg_dataset/';
list=dir(dataset_path);
id_folders=[list.isdir];
NameFolders={list(id_folders).name};
NameFolders=NameFolders(3:end); % Delete '.' and '..'
% NumFolders=numel(NameFolders);
NameVideo=NameFolders{idVideo};

% -------- compute overlap -------------
% images gt
ListGt=dir([dataset_path,NameVideo,'/*.pgm']);
NameGt={ListGt.name};
NumGtFrames=numel(NameGt);
idx_gt=zeros(1,NumGtFrames-1);
GT=cell(1,numGT-1);
for id=2:NumGtFrames % id=1 frame initial, groundtruth selected to track, don't get an output of algorithm
    NameGtFrame=NameGt{id};
    GT{id-1}=im2double(imread([dataset_path,NameVideo,'/',name_img_gt]));
    idx=textscan(NameGtFrame,'%d');
    idx_gt(id-1)=idx{1};
end
% Parameters to evaluate
AlphaValues=0.5;
BetaValues=0.7;
OmegaValues=0.7;
NumAlphaValues=numel(AlphaValues);
NumBetaValues=numel(BetaValues);
NumOmegaValues=numel(OmegaValues);
OutputMask=cell(NumAlphaValues,NumBetaValues,NumOmegaValues);

for i=1:NumAlphaValues
    params.alpha=AlphaValues(i);
    for j=1:NumBetaValues
        params.beta=BetaValues(j);
        for k=1:NumOmegaValues
            params.omega=OmegaValues(k);
            Mask=TrackingArticulatedObject(NameVideo,params);
            %OutputMask{i,j,k}=Mask;                           
            % overlap
            overlap=zeros(1,numel(idx_gt));
            for m=1:numel(idx_gt)
                id=idx_gt(m);
                NumPixelsIntersection=sum(sum(Mask{id}.*gt{m}));
                Sum_MaskGT=Mask{id}+GT{m};
                NumPixelsUnion=sum(sum(SumMask_GT~=0));
                Overlap(m)=NumPixelsIntersection./NumPixelsUnion;
            end 
	    OutputOverlap{i,j,k}=overlap;
        end
    end
end
%savename=['./../results/experiments/SLICsegmentation/OutputMask_', NameVideo, '.mat'];
%save(savename,'OutputMask','-v7.3');

savename=['./../results/experiments/SLICsegmentation/OutputOverlap_', NameVideo, '.mat'];
save(savename,'OutputOverlap','-v7.3');
