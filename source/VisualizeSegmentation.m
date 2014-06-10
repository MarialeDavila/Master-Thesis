function img_out=VisualizeSegmentation(Image2,labels, FlagFigures)
% Image Segmented where each segment was colored with the average color of the region

NumSegments=double(max(max(labels)));  % Number of segments on image
sizeLabels=numel(labels); 
Rsegment=zeros(size(labels));Gsegment=zeros(size(labels));Bsegment=zeros(size(labels));
for i=1:NumSegments    
    id=find(labels==i);        
    Rsegment(id)=round(sum(Image2(id))/numel(id));
    Gsegment(id)=round(sum(Image2(id+sizeLabels))/numel(id));
    Bsegment(id)=round(sum(Image2(id+2*sizeLabels))/numel(id));
end

img_out(:,:,1)=Rsegment; img_out(:,:,2)=Gsegment; img_out(:,:,3)=Bsegment;
img_out=uint8(img_out);
if FlagFigures
    figure(5001),
    imshow(img_out);
end