function [model, points]=AddUnknownToModelAndPoints(unknown,model,points,features,idFrame)
% Model
model_object=cell2mat(model.sift);
ind_cell2mat=[];
for i=1:size(model.sift,2)
    num1=size(model.sift{1,i},2);
    ind_cell2mat=[ind_cell2mat, repmat(i,[1,num1])];
end
% Threshold to decide if a new point is similar to old points, according to
% the sift descriptors
% threshold=12500;
threshold=45000;

%%
% Descriptors of Unknown points
Allpoints=features.points{idFrame};
[dummy idUnseenPoints]=ismember(unknown,Allpoints,'rows');

SiftAllPoints=features.sift{idFrame};
model_unknow =SiftAllPoints(idUnseenPoints);


%%
% match model of new points and object model
% model_unseen=single(cell2mat(model_unknow));
unknow=[]; new_object=[]; id=[];
if ~isempty(model_object)
    for j=1:size(model_unknow,2)
        sw=0;
        dim1=size(model_unknow{1,j},2);
        value=zeros(1,dim1); idx=ones(1,dim1);
        for id_unknow=1:dim1
            [dummy scores] = vl_ubcmatch(model_object,model_unknow{1,j}(:,id_unknow));
            [value(1,id_unknow), idx(1,id_unknow)]=min(scores);
        end
        [min_score id1]=min(value);
        if (min_score<threshold)
            sw=1;
            new_object=[new_object; unknown(j,:)];
            % update models
            id=[id; ind_cell2mat(1,idx(1,id1))];
        end
        if (sw==0)
            unknow=[unknow; unknown(j,:)];
        end
    end
end
% Update points and model id
numPreviousPoints=size(points.position,1);
numNewObjectPoints=size(new_object,1);
numNewUnknowPoints=size(unknow,1);

points.position=[points.position; new_object; unknow];
points.type.object=[points.type.object; true(numNewObjectPoints,1); false(numNewUnknowPoints,1)];
points.type.scene=[points.type.scene; false(numNewObjectPoints,1); false(numNewUnknowPoints,1)];
points.type.unknown=[points.type.unknown; false(numNewObjectPoints,1); true(numNewUnknowPoints,1)];
points.type.dead=[points.type.dead; false(numNewObjectPoints,1); false(numNewUnknowPoints,1)];
points.model_idx=[points.model_idx; id; zeros(numNewUnknowPoints,1)];

for i=1:numel(id)
    model.points_idx{1,id(i)}=[model.points_idx{1,id(i)}; numPreviousPoints+i];
end