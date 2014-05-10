function unknown=DetectUnknowPoints(points,features,idFrame)

NewPoints = features.points{idFrame};
matrix_distance=pdist2(NewPoints,points.position(points.type.dead~=1,:));
min_dist_new_pts=min(matrix_distance,[],2);
id_unknow_points=find(min_dist_new_pts>100);
unknown=[NewPoints(id_unknow_points,1) NewPoints(id_unknow_points,2)];