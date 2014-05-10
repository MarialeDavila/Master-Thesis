function []=Test_SetParameters(idVideo)

dataset_path='/../../dataset/moseg_dataset/';
% dataset_path='/share/storage/vision/mariale/dataset/moseg_dataset/';
list=dir(dataset_path);
id_folders=[list.isdir];
NameFolders={list(id_folders).name};
NameFolders=NameFolders(3:end); % Delete '.' and '..'
% NumFolders=numel(NameFolders);
NameVideo=NameFolders{idVideo};

% Parameters to evaluate
AlphaValues=0.1:0.1:1;
BetaValues=0.1:0.1:1;
OmegaValues=0.1:0.1:2;
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

%% testing
% run main() to every set of parameters analized in one video

params=struct();
values=linspace(0.1,1,7);
num_params=numel(values);

output=struct();
output.mask=cell(num_params,num_params,num_params,num_params);
output.overlap=cell(num_params,num_params,num_params,num_params);

% -------- compute overlap -------------
% images gt
list_gt=dir('./video01/*.pgm');
name_gt={list_gt.name};
numGT=2;%numel(name_gt);
idx_gt=zeros(1,numGT-1);
gt=cell(1,numGT-1);
for id=2:numGT % id=1 frame initial, groundtruth selected to track, don't get an output of algorithm
    name_img_gt=name_gt{id};
    gt{id-1}=im2double(imread(['./video01/',name_img_gt]));
    idx=textscan(name_img_gt,'%d');
    idx_gt(id-1)=idx{1};
end

temp=struct();
% Execute tracking code to video01 for each combination of parameters
for i=1:num_params
    params.omega=values(i);
    for j=1:num_params
        params.alpha=values(j);
        for k=1:num_params
            params.beta=values(k);
            for l=1:num_params
                params.gamma=values(l);
                mask=dyn_obj_contour('video01','MeanShift', 0, params);
                temp.mask_gamma{1,l}=mask;  
                temp.mask_beta_gamma{k,l}=mask;
                temp.mask_alpha_beta_gamma{j,k,l}=mask;
                output.mask{i,j,k,l}=mask;
                % overlap
                overlap=zeros(1,numel(idx_gt));
                for m=1:numel(idx_gt)
                    id=idx_gt(m);
                    mask_int=sum(sum(mask{id}.*gt{m}));
                    sum_gt=mask{id}+gt{m};
                    mask_union=sum(sum(sum_gt~=0));
                    overlap(m)=mask_int./mask_union;
                end
                temp.overlap_gamma{1,l}=overlap;  
                temp.overlap_beta_gamma{k,l}=overlap;
                temp.overlap_alpha_beta_gamma{j,k,l}=overlap;
                output.overlap{i,j,k,l}=overlap;
            end
            save_name=['./results/case2/overlap_w',num2str(params.omega),'_a',num2str(params.alpha),'_b',num2str(params.beta),'.mat','-v7.3'];
            save(save_name,'temp');
        end
        save_name=['./results/case2/overlap_w',num2str(params.omega),'_a',num2str(params.alpha),'.mat','-v7.3'];
        save(save_name,'temp');
    end
    save_name=['./results/case2/overlap_w',num2str(params.omega),'.mat','-v7.3'];
    save(save_name,'temp');
end
save('./results/case2/testing_video01.mat','output','-v7.3');

