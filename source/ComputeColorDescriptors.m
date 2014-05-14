function color_histogram = ComputeColorDescriptors(Image,labels)
% Compute descriptors for segments of Image
nbins=8; %256/8;
NumSegments=max(max(labels));
color_histogram=zeros(NumSegments,nbins^3);
sizeLabels=numel(labels);
for i=1:NumSegments
    % Color(RGB) 3-dimensional histogram
    idx=find(labels==i);
    
    R_segment=Image(idx);
    G_segment=Image(idx+sizeLabels);
    B_segment=Image(idx+2*sizeLabels);
    
    SegmentsPixels=cat(3,R_segment,G_segment,B_segment);
    SegmentsPixels = reshape(SegmentsPixels, [],3);
    
    hist_segment=ndHistc(double(SegmentsPixels),0:256/nbins:256, 0:256/nbins:256, 0:256/nbins:256);
    color_hist_segment=reshape(hist_segment(:),1,[]);
    % normalized histogram
    color_histogram(i,:)=color_hist_segment/sum(color_hist_segment);
    
    sw=0; % Show color histogram to every segment
    if sw
        % Plot 3D histogram to every segment        
        % Plot cuboid of color histogram 3D
        Plot3DHist(hist_segment);        
    end
end
