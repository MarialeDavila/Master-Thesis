function [model color_histogram_new HOOF_new]=ComputeDescriptors(data,labels_frame1,labels,id_label_fg, model,features,idFrame)
% Compute descriptors

%Get Data
Image1=data.Image{idFrame-1};
Image2=data.Image{idFrame};

% Load pre-computed Optical Flow
of_dx=features.OpticalFlow.dx{idFrame};
of_dy=features.OpticalFlow.dy{idFrame};

% image with groundtruth
% Compute descriptors for segments of initial frame
color_histogram_gt = ComputeColorDescriptors(Image1,labels_frame1);
HOOF_gt = ComputeMovementDescriptors(of_dx,of_dy,labels_frame1);
% Merge descriptors to build Color and Movement Models
% to Background and Foreground

% if ~isfield(model,'color_fg'); model.color_fg=[]; end
% model.color_fg=[model.color_fg; color_histogram_gt(id_label_fg,:)];
model.color_fg=color_histogram_gt(id_label_fg,:);

% if ~isfield(model,'color_bg'); model.color_bg=[]; end
% model.color_bg=[model.color_bg; color_histogram_gt(~id_label_fg,:)];
model.color_bg=color_histogram_gt(~id_label_fg,:);

% if ~isfield(model,'movement_fg'); model.movement_fg=[]; end
% model.movement_fg=[model.movement_fg; HOOF_gt(id_label_fg,:)];
model.movement_fg=HOOF_gt(id_label_fg,:);

% if ~isfield(model,'movement_bg'); model.movement_bg=[]; end
% model.movement_bg=[model.movement_bg; HOOF_gt(~id_label_fg,:)];
model.movement_bg=HOOF_gt(~id_label_fg,:);

% Compute Descriptors to actual frame
color_histogram_new = ComputeColorDescriptors(Image2,labels);
HOOF_new = ComputeMovementDescriptors(of_dx,of_dy,labels);
