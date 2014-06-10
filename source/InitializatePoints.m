function [points]=InitializatePoints(I,InitialGT,features,FlagFigures) 

% Detect initial interest point
% Points are corners detected in a grayscale image
points.position = features.points{1}; % [X Y]

% Initial Ground Truth 
% image indexed like rows (y) an cols (x)
% sub2ind(SizeMatrix, RowIdx, ColIdx)
single_idx_points=sub2ind(size(I), points.position(:,2), points.position(:,1));
type_object=InitialGT(single_idx_points);

% classify points between scene - object - unseen
points.type.object = logical(type_object);
points.type.scene = ~points.type.object;
points.type.unknown = false(size(points.position,1),1);
points.type.dead = false(size(points.position,1),1);

if FlagFigures
    % Visualize object and scene points 
    figure(200);
    PlotPointsAndContour(I,points,InitialGT)
    title('Object and Scene points in a grayscale image','FontSize',12)
    legend('Object Points','Scene Points')
    hold off;
end