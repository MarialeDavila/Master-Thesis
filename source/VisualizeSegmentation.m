function img_out=VisualizeSegmentation(Image2,labels, FlagFigures)
% Image Segmented where each segment was colored with the average color of the region

NumSegments=double(max(max(labels)));  % Number of segments on image
average_color=zeros(3,NumSegments);
imgR=zeros(size(labels));imgG=zeros(size(labels));imgB=zeros(size(labels));
for i=1:NumSegments
    id=find(labels==i);
    for j=1:3
        img_channel=Image2(:,:,j);
        average_color(j,i)=sum(img_channel(id))/numel(id); % average color
    end
    imgR(id)=fix(average_color(1,i));
    imgG(id)=fix(average_color(2,i));
    imgB(id)=fix(average_color(3,i));
end
img_out(:,:,1)=imgR; img_out(:,:,2)=imgG; img_out(:,:,3)=imgB;
img_out=uint8(img_out);
if FlagFigures
    figure(5001), 
    imshow(img_out);
end
