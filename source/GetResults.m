% Get results - Compute Overlap and Number Pixels Misleading

resultsPath='./../results/experiments/';
list=dir(resultsPath);
id_folders=[list.isdir];
NameFolders={list(id_folders).name};
NameFolders=NameFolders(3:end);

OverlapGlobal=cell(1,3);
IdFramesGtGlobal=cell(1,3);
OutputMetricsGlobal=cell(1,3);
value_sum=cell(1,3);
value_avg=cell(1,3);
params_sum=cell(1,3);
params_avg=cell(1,3);
NumPixelsWrong=cell(1,3);
better_params=cell(1,3);
VideoNames=cell(1,3);

for i=1:3
    NameDataset=NameFolders{i};
    [OverlapGlobal{1,i},IdFramesGtGlobal{1,i},OutputMetricsGlobal{1,i}]=GetOutputOverlap_CreateUniqueDataFile(NameDataset);
    VideoNames{1,i}=fieldnames(OverlapGlobal{1,i});
    [value_sum{1,i},value_avg{1,i}, params_sum{1,i},params_avg{1,i},NumPixelsWrong{1,i},better_params{1,i}] = GetBetterParams(OverlapGlobal{1,i},OutputMetricsGlobal{1,i},NameDataset);    
end