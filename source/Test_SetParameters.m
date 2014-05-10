function Test_SetParameters(idVideo)

%dataset_path='/../../dataset/moseg_dataset/';
dataset_path='/share/storage/vision/mariale/dataset/moseg_dataset/';
list=dir(dataset_path);
id_folders=[list.isdir];
NameFolders={list(id_folders).name};
NameFolders=NameFolders(3:end); % Delete '.' and '..'
% NumFolders=numel(NameFolders);
NameVideo=NameFolders{idVideo};

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
            OutputMask{i,j,k}=TrackingArticulatedObject(NameVideo,params);
        end
    end
end
savename=['./../results/experiments/SLICsegmentation/OutputMask_', NameVideo, '.mat'];
save(savename,'OutputMask','-v7.3');

