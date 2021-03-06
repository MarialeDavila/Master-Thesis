function visualize_graph(pairwise,labels,img_out,NumSegments,class)
% Visualize the graph in the image segmented, its show the links between
% nodes or segments

% compute centroids
cX=ones(1,NumSegments);
cY=ones(1,NumSegments);
for i=1:NumSegments
    [idx idy]=find(labels==i);
    idX=unique(idx);
    idY=unique(idy);
    cX(1,i)=fix(mean(idX));
    cY(1,i)=fix(mean(idY));
    % find pixel nearest to centroid within segment
    [dummy,id]=min(pdist2([idx idy],[mean(idX) mean(idY)]));
    cX(1,i)=idx(id);
    cY(1,i)=idy(id);
end
% find links between segments neighbors
[point_initial point_end WeigthEdges]=find(pairwise);
linksXin=cX(point_initial);
linksYin=cY(point_initial);
linksXend=cX(point_end);
linksYend=cY(point_end);
linksX=[linksXin; linksXend];
linksY=[linksYin; linksYend];
PointX=mean(linksX);
PointY=mean(linksY);

% Find indices of edges that belong to previous ground truth
id=find(class==1);
[idx dummy]=find(pairwise);
ind=zeros(1,numel(idx));
for i=1:numel(idx)
    if any(id==idx(i))
        ind(i)=1;
    end
end

% Visualizate the Graph on the image segmented
figure(220);
imshow(img_out)
hold on;

plot(cY,cX,'wo','MarkerSize', 6,'MarkerFaceColor',[1 1 1])
line(linksY,linksX,'Color',[1 1 1])

% for i=1:numel(WeigthEdges)
%     if ind(i)==1
%         % text
%         %         text(PointY(i),PointX(i),num2str(WeigthEdges(i)), ...
%         %             'HorizontalAlignment','center','BackgroundColor',[1 1 0] )      
%         line(linksY(:,i),linksX(:,i),'Color',[1 0 0])
%     end
% end
% 
% for i=1:NumSegments
%     if class(i)==1
%         plot(cY(i),cX(i),'wo','MarkerSize', 6,'MarkerFaceColor',[1 0 0])
%     end
% end
hold off;