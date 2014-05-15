function [points, model]=UpdatePointsAndModel(ActualMask,points, model,features,idFrame)

% update_points_contour
points_alive=points.position(points.type.dead~=1,:);
ind_points=sub2ind(size(ActualMask),points.position(:,2),points.position(:,1));
% points inside region
id_points_inside_region=logical(ActualMask(ind_points));
% points inside region wasn't object type
id_points_inside_and_no_object=logical(id_points_inside_region.*(~points.type.object(points.type.dead~=1)));
% points outside region
id_points_outside_region=~id_points_inside_region;
% points outside region and object type point
id_points_outside_and_object=logical(id_points_outside_region.*(points.type.object(points.type.dead~=1)));

if any(id_points_inside_and_no_object)
    
    % compute descriptors to points inside region and point type No object
    PointsInsideAndNoObject=points_alive(id_points_inside_and_no_object,:);
    SiftAllPoints=features.sift{idFrame};
    model_sift =SiftAllPoints(PointsInsideAndNoObject);
    
    id=find(id_points_inside_and_no_object==1);
    k=1;
    for i=1:size(id,1)
        % this point belong to points in rectangle
        % update model
        new_pos_new_model=size(model.sift,2)+1;
        id_point_new_model=find(cumsum(~points.type.dead)==id(i),1);
        model.sift{1,new_pos_new_model}=model_sift{1,k};
        model.points_idx{1,new_pos_new_model}=id_point_new_model;
        points.model_idx(id_point_new_model,1)=new_pos_new_model;
        k=k+1;
    end
    
end

% Points outside region
id=find(id_points_outside_and_object==1);
for i=1:size(id,1)
    % this point belong to points out of rectangle and its object type
    % discard model associated with this point
    id_no_object_point=find(cumsum(~points.type.dead)==id(i),1);
    if points.model_idx(id_no_object_point,1)~=0
        id_x=points.model_idx(id(i));
        if id_x~=0
            points2discard=model.points_idx{1,id_x};
            model.points_idx{1,id_x}=[]; % 0
            points.model_idx(points2discard,1)=0;
        end
    end
end

% Changes indices to match with structure points
id_inside=false(size(points.position,1),1);
id_inside(points.type.dead==0)=id_points_inside_region;
id_outside=false(size(points.position,1),1);
id_outside(points.type.dead==0)=id_points_outside_region;
% Points Inside Region
points.type.object(id_inside,1)=1;  % flag object points
points.type.scene(id_inside,1)=0;  % flag scene points
points.type.unknown(id_inside,1)=0;  % flag unknown points
points.type.dead(id_inside,1)=0;  % flag dead points
% Points Outside Region
points.type.object(id_outside,1)=0;  % flag object points
points.type.scene(id_outside,1)=1;  % flag scene points
points.type.unknown(id_outside,1)=0;  % flag unknown points
points.type.dead(id_outside,1)=0;  % flag dead points