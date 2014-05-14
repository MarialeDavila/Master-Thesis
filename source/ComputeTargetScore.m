function target_score=ComputeTargetScore(points,groups,labels)
% Compute Dynamic Objectness Score and Target Score

% Clusters
% numCluster=max(groups);
% dim=size(groups,1);
% points2cluster=zeros(dim,numCluster);
% points_per_cluster=zeros(1,numCluster);
% for j=1:numCluster
%     points2cluster(:,j)=double(groups==j);
%     points_per_cluster(j)=sum(points2cluster(:,j));
% end
NumSegments=max(max(labels));
object_idx = points.type.object; % object(:,1)>0;
scene_idx = points.type.scene; % scene(:,1)>0;
target_score=zeros(NumSegments,1);
% dyn_objectness=zeros(NumSegments,1);
% new_score=zeros(NumSegments,1);
% mask=cell(1,NumSegments); % create mask by segment

points_alive=points.position(points.type.dead~=1,:);
rowIdx_points=points_alive(:,2);
colIdx_points=points_alive(:,1);

for j=1:NumSegments
    % create mask by segment
    mask=zeros(size(labels));
    mask(labels==j)=1;
    
    % points inside mask
    single_idx_points=sub2ind(size(labels), rowIdx_points, colIdx_points);
    idx_points_in_region=mask(single_idx_points);
    
    % target score
    n_rect = sum(idx_points_in_region);
    if n_rect == 0
        % scores already in zero, no need to set again.
        continue
    end;
    n_obj = sum(object_idx(idx_points_in_region==1));
    n_scene = sum(scene_idx(idx_points_in_region==1));
    target_score(j,1)=(n_obj-n_scene)/n_rect;
    
%     % dynamic objectness score
%     points_in_rect_per_cluster = sum(points2cluster((idx_points_in_region==1), :),1);
%     points_out_rect_per_cluster = points_per_cluster - points_in_rect_per_cluster;
%     ratio_points=min(points_in_rect_per_cluster, points_out_rect_per_cluster)./n_rect;
%     
%     dyn_objectness(j,1)=1-sum(ratio_points);
%     new_score(j,1)=max(points_in_rect_per_cluster./n_rect);
end
