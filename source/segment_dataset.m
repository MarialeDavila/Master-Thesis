% Pre-compute features per frame to  moseg-dataset
% Save results on files in format .mat
actual_path=pwd;
dataset_path='../dataset/moseg_dataset/';
list=dir(dataset_path);
id_folders=[list.isdir];
name_folders={list(id_folders).name};
Num_Folders=numel(name_folders);

for i=3:Num_Folders % begin in 3
    folder_path=[dataset_path, name_folders{1,i},'/'];
    list_images=dir([folder_path, '*jpg']);
    Num_images=numel(list_images);
    labels_video=cell(1,Num_images);
    for j=1:Num_images
        Image=imread([folder_path, list_images(j).name]);        
        [image_segmented, labels] = segmentation(Image,'contours2regions');
        labels_video{1,j}=labels;
    end
    save(['seg_', name_folders{1,i}, '.mat'],'labels_video')
    clear labels_video;
end

