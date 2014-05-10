function unknow=DetectFeatures(points,I2)

NewPoints = corner(I2, 'MinimumEigenvalue',1000);  % [X Y]
matrix_distance=pdist2(NewPoints,points.position(points.type.dead~=1,:));
min_dist_new_pts=min(matrix_distance,[],2);
id_unknow_points=find(min_dist_new_pts>100);
unknow=[NewPoints(id_unknow_points,1) NewPoints(id_unknow_points,2)];