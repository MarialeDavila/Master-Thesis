function [ImageSegOut VideoObject] = visualize_output_GCM(labels,labels_out,Image,FlagFigures,VideoObject)
% Visualize output GCM - labels in the image segmented

IdSegmentsGt=find(labels_out);
ImageSegOut=ismember(labels,IdSegmentsGt);
ImageSegOut=double(ImageSegOut);
Image_out=Image;
for j=1:3
    Image_out(:,:,j)=ImageSegOut.*double(Image(:,:,j));
end

writeVideo(VideoObject,ImageSegOut);
% writeVideo(VideoObject,Image_out);

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

