function [points]=InitializatePoints(I,InitialGT,features,FlagFigures) 

% Detect initial interest point
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
    % Visualize object and scene points (Points are corners detected in a grayscale image)
    figure(200); imshow(I)
    hold on;
    plot(points.position(points.type.object>0,1),points.position(points.type.object>0,2),'o','Color', [1 0 0]);
    plot(points.position(points.type.scene>0,1),points.position(points.type.scene>0,2),'o','Color', [0 0 1]);
    contour(InitialGT, 'LineColor',[0 0 1])
    title('Object and Scene points in a grayscale image','FontSize',12)
    legend('Object Points','Scene Points')
    hold off;
end