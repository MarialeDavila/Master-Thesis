function visualize_clustering(I2,groups,points,method)

% visualize clusters
l1=size(points,1);
dim1=size(groups,1);
numClust=max(groups);
J= repmat(I2,[1 1 3]);
color=uniqueColors(1,numClust);

switch method
    case 'MeanShift'
        figure(2001); clf;
        imshow(J);
        hold on;
        for j=1:l1
            plot(points(j,1),points(j,2),'o','Color', color(groups(j,1),:));
        end
        title('Clustering Mean Shift')
        hold off;
        %     F = getframe(h1);
        %     cluster_meanshift = addframe(cluster_meanshift,F);
        % currFrame1 = getframe;
        % writeVideo(vidobj_meanshift,currFrame1);
        
    case 'Graph-Based'
        figure(2002);  clf; imshow(J);
        hold on;
        for j=1:dim1
            plot(points(j,1),points(j,2),'o','Color', color(groups(j,1),:));
        end
        title('Clustering Graph - Based')
        hold off;
        % currFrame2 = getframe;
        % writeVideo(vidobj_graph_based,currFrame2);
        
    case 'GANC'
        figure(2003); clf;  imshow(J);
        hold on;
        for j=1:dim1
            plot(points(j,1),points(j,2),'o','Color', color(groups(j,1),:));
        end
        title('Clustering GANC')
        hold off;
        % currFrame3 = getframe;
        % writeVideo(vidobj_ganc,currFrame3);
    case 'EDISON'
        figure(2004); clf;  imshow(J);
        hold on;
        for j=1:dim1
            plot(points(j,1),points(j,2),'o','Color', color(groups(j,1),:));
        end
        title('Clustering EDISON')
        hold off;
        % currFrame3 = getframe;
        % writeVideo(vidobj_ganc,currFrame3);
    otherwise
        close;
        fprintf('%s','Invalid Method')
end