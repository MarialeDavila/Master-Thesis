function [points] = PropagatePoints(points,data,features,idFrame,FlagFigures)

% Load Optical Flow of Image I1 (wrt I2)
of_dx=features.OpticalFlow.dx{idFrame};
of_dy=features.OpticalFlow.dy{idFrame};
reliability=features.OpticalFlow.reliability{idFrame};

%  Image dimensions
[rows cols c]=size(data.Image{1});

% Use unique index for points in format row,col (Piotr's toolbox)
points_alive=points.position(points.type.dead~=1,:);
ind_pts=sub2ind2([rows cols],fliplr(points_alive));

% Discard the points with Optical Flow of low reliability
pos_pts=find(reliability(ind_pts)==0);
indice2delete=unique(pos_pts);
points.type.object(indice2delete)=0;
points.type.scene(indice2delete)=0;
points.type.unknown(indice2delete)=0;
points.type.dead(indice2delete)=1;

% Find unique index for new points
points_alive=points.position(points.type.dead~=1,:);
ind_pts=sub2ind2([rows cols],fliplr(points_alive));

% Get new positions of set of points
NewPoints(:,1)=round(points_alive(:,1)+of_dx(ind_pts));
NewPoints(:,2)=round(points_alive(:,2)+of_dy(ind_pts));

% Constraints about size of video frames
w=cols; % width image
h=rows; % high image
NewPoints(NewPoints(:,1)>w,1)=w;
NewPoints(NewPoints(:,2)>h,2)=h;
NewPoints(NewPoints(:,1)<1,1)=1;
NewPoints(NewPoints(:,2)<1,2)=1;

% Visualize Propagated Points
if FlagFigures
    I1=data.Image{idFrame-1};
    I2=data.Image{idFrame};
    plot_show_propagated_points(I1, I2, points_alive, NewPoints)
end

points.position(~points.type.dead,:)=NewPoints;
