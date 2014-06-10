function PlotPointsAndContour(Image, points, Mask)
imshow(Image)
hold on;
plot(points.position(points.type.object>0,1),points.position(points.type.object>0,2),'o','Color', [1 0 0]);
plot(points.position(points.type.scene>0,1),points.position(points.type.scene>0,2),'o','Color', [0 0 1]);
plot(points.position(points.type.unknown>0,1),points.position(points.type.unknown>0,2),'o','Color', [0 1 0]);
contour(Mask, 'LineColor',[1 1 0])
title('Object, Scene and Unknow points')
legend('Object Points','Scene Points','Unknow Points') %'Location','NorthEastOutside'
hold off;
end