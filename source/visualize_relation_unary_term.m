function visualize_relation_unary_term(data_term,data_term_withoutP,min_distances,labels)
% Visualize relation data term - labels in the image segmented
data_term_bg=data_term(1,:);
data_term_fg=data_term(2,:);
data_term_wP_bg=data_term_withoutP(1,:);
data_term_wP_fg=data_term_withoutP(2,:);
min_distance_color_bg=min_distances(1,:);
min_distance_color_fg=min_distances(2,:);
min_distance_of_bg=min_distances(3,:);
min_distance_of_fg=min_distances(4,:);

[min1 id_min]=min(data_term);
labels_data_term=id_min-1;

% Initialization 
ImageSeg_DataTerm=zeros(size(labels));
ImageSeg_dist_color_bg=zeros(size(labels));
ImageSeg_dist_color_fg=zeros(size(labels));
ImageSeg_dist_of_bg=zeros(size(labels));
ImageSeg_dist_of_fg=zeros(size(labels));
ImageSeg_DataTerm_wP_bg=zeros(size(labels));
ImageSeg_DataTerm_wP_fg=zeros(size(labels));
ImageSeg_DataTerm_bg=zeros(size(labels));
ImageSeg_DataTerm_fg=zeros(size(labels));
NumSegments=max(max(labels));
for i=1:NumSegments
    ImageSeg_DataTerm(labels==i)=labels_data_term(i);
    
    ImageSeg_dist_color_bg(labels==i)=min_distance_color_bg(i);
    ImageSeg_dist_color_fg(labels==i)=min_distance_color_fg(i);
    ImageSeg_dist_of_bg(labels==i)=min_distance_of_bg(i);
    ImageSeg_dist_of_fg(labels==i)=min_distance_of_fg(i);
    
    ImageSeg_DataTerm_wP_bg(labels==i)=data_term_wP_bg(i);
    ImageSeg_DataTerm_wP_fg(labels==i)=data_term_wP_fg(i);
    
    ImageSeg_DataTerm_bg(labels==i)=data_term_bg(i);
    ImageSeg_DataTerm_fg(labels==i)=data_term_fg(i);
end
figure(150),
%     subplot(211)
imshow(ImageSeg_DataTerm)
title('Segments with potentials closely to foreground according to data term' ...
    ,'fontSize', 10)

figure(151), clims=[0 1];
subplot(221),
imagesc(ImageSeg_dist_color_bg,clims), axis image
title('Unary term related to Color in background model')
subplot(222), 
imagesc(ImageSeg_dist_color_fg,clims), axis image
title('Unary term related to Color in foreground model')
subplot(223),
imagesc(ImageSeg_dist_of_bg,clims), axis image
title('Unary term related to Movement in background model')
subplot(224), 
imagesc(ImageSeg_dist_of_fg,clims), axis image
title('Unary term related to Movement in foreground model')

figure(152), clims=[0 1];
subplot(221),
imagesc(ImageSeg_DataTerm_wP_bg,clims), axis image
title('Unary term of color and movement in background model')
subplot(222), 
imagesc(ImageSeg_DataTerm_wP_fg,clims), axis image
title('Unary term of color and movement in foreground model')
subplot(223),
imagesc(ImageSeg_DataTerm_bg,clims), axis image
title('Unary term overall in background model')
subplot(224), 
imagesc(ImageSeg_DataTerm_fg,clims), axis image
title('Unary term overall in foreground model')
