% Pre-compute features per frame to  moseg-dataset
% Save results on files in format .mat

% path libraries
libs_PATH='./../libs/';
% add libraries paths
addpath(genpath(libs_PATH));

actual_path=pwd;
dataset_path='./../../dataset/moseg_dataset/';
list=dir(dataset_path);
id_folders=[list.isdir];
name_folders={list(id_folders).name};
Num_Folders=numel(name_folders);

for i=26:Num_Folders % begin in 3 
    % Get video frames and extract features per image
    NameVideo=name_folders{1,i};
    VideoPath=[dataset_path, NameVideo, '/'];
    data = GetVideoFrames(VideoPath);
    features = GetFeaturesPerFrame(data,NameVideo);
    clear features data
end