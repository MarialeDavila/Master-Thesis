function [model points]=BuildModelSIFT(points,features)

% Object points 
ObjectPoints=points.position((points.type.object),:);

% Number of Object Points
NumObjectPoints=size(ObjectPoints,1);

% Load Sift descriptors to every object points in frame 1
SiftAllPoints=features.sift{1};
model.sift =SiftAllPoints(points.type.object);

% Indicator of the points belong every model
idx_model=reshape(find(points.type.object),1,[]);
model.points_idx=num2cell(idx_model);

% Allocate the model id to every point of the object set (points structure)
points.model_idx=zeros(size(points.position,1),1);
points.model_idx(idx_model,1)=1:NumObjectPoints;
