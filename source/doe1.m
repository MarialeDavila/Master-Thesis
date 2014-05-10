% Design of Experiments
% Analysis for significance of factors 
% High=1 => 1   Low=-1 => 0.1
% Factors: w => omega  a => alpha   b => beta  g => gamma
% Output = Overlap [0,1]

% Compute data to execute design of experiments

levels=[0.1 1];
num_levels=numel(levels);
params=struct;

output=struct();
output.mask=cell(num_levels,num_levels,num_levels,num_levels);
output.overlap=cell(num_levels,num_levels,num_levels,num_levels);

% -------- compute overlap -------------
% images gt
list_gt=dir('./video01/*.pgm');
name_gt={list_gt.name};
numGT=numel(name_gt);
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
for i=1:num_levels
    params.omega=levels(i);
    for j=1:num_levels
        params.alpha=levels(j);
        for k=1:num_levels
            params.beta=levels(k);
            for l=1:num_levels
                params.gamma=levels(l);
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
        end
    end
end

