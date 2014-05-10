function [ImageSegOut VideoObject] = visualize_output_GCM(labels,labels_out,Image,NumSegments,FlagFigures,VideoObject)
% Visualize output GCM - labels in the image segmented

ImageSegOut=zeros(size(labels));
Image_out=Image;
for i=1:NumSegments
    ImageSegOut(labels==i)=labels_out(i);
    for j=1:3
        Image_out(:,:,j)=ImageSegOut.*double(Image(:,:,j));
    end
end

writeVideo(VideoObject,Image_out);
% currentFrame.cdata=uint8(Image_out);
% currentFrame.colormap=[];

if FlagFigures
    figure(40)
    imshow(ImageSegOut)
    title('Segments labeled like Foreground by the output of GCM')
    figure(41)
    imshow(Image_out)
    title('Region of the image labeled like Foreground by the output of GCM')
    figure(42)
    imshow(Image)
    hold on, contour(ImageSegOut), hold off
end

