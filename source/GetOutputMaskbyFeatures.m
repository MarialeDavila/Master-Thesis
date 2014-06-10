function [ImageSeg_DataTerm] = GetOutputMaskbyFeatures(data_term,labels,VideoObject)

[min1 id_min]=min(data_term);
labels_data_term=id_min-1;
ImageSeg_DataTerm=zeros(size(labels));
NumSegments=(max(max(labels)));
for i=1:NumSegments
    ImageSeg_DataTerm(labels==i)=labels_data_term(i);
end

figure(150),
%     subplot(211)
imshow(ImageSeg_DataTerm)
title('Segments with potentials closely to foreground according to data term' ...
    ,'fontSize', 10)

% OutputMask=imerode(ImageSeg_DataTerm)
writeVideo(VideoObject,ImageSeg_DataTerm);