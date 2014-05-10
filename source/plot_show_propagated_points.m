function plot_show_propagated_points(I1, I2, points, new_points)

figure(1000);
clf
subplot(1,2,1);
imshow(I1);
hold on
for k=1:size(points,1)
    plot([points(k,1) new_points(k,1)], [points(k,2) new_points(k,2)], 'g-')
end
plot(points(:,1), points(:,2), 'rx')
plot(new_points(:,1), new_points(:,2), 'bo')
title('Points propagate by optical flow - frame 1')
hold off


subplot(1,2,2);
imshow(I2);
hold on
for k=1:size(points,1)
    plot([points(k,1) new_points(k,1)], [points(k,2) new_points(k,2)], 'g-')
end
plot(points(:,1), points(:,2), 'rx')
plot(new_points(:,1), new_points(:,2), 'bo')
title('Points propagate by optical flow - frame 2')
hold off

