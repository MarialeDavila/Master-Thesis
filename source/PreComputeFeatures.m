% Pre-compute features per frame to  moseg-dataset
% Save results on files in format .mat
function [] = PreComputeFeatures(idVideo)
% add libraries paths
AddLibrariesPath();

dataset_path='./../../dataset/moseg_dataset/';
list=dir(dataset_path);
id_folders=[list.isdir];
name_folders={list(id_folders).name};
name_folders=name_folders(3:end);
%Num_Folders=numel(name_folders);

%for idVideo=3:Num_Folders % begin in 3 
    % Get video frames and extract features per image
    NameVideo=name_folders{1,idVideo};
    VideoPath=[dataset_path, NameVideo, '/'];
    data = GetVideoFrames(VideoPath);
    features = GetFeaturesPerFrame(data,NameVideo);
    clear features data
%end
