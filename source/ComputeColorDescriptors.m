function color_histogram = ComputeColorDescriptors(Image,labels)
% Compute descriptors for segments of Image
nbins=8; %256/8;
NumSegments=max(max(labels));
color_histogram=zeros(NumSegments,nbins^3);

for i=1:NumSegments
    % Color(RGB) 3-dimensional histogram
    R_segment = Image(:,:,1);
    R_segment = R_segment(labels==i);
    
    G_segment = Image(:,:,2);
    G_segment = G_segment(labels==i);
    
    B_segment = Image(:,:,3);
    B_segment = B_segment(labels==i);
    
    segment_pixels = cat(3, R_segment, G_segment, B_segment);
    segment_pixels = reshape(segment_pixels, [],3);
    hist_segment=ndHistc(double(segment_pixels),0:256/nbins:256, 0:256/nbins:256, 0:256/nbins:256);
    color_hist_segment=reshape(hist_segment(:),1,[]);
    % normalized histogram
    color_histogram(i,:)=color_hist_segment/sum(color_hist_segment);
    
    sw=0; % Show color histogram to every segment
    if sw
        %Visualize 3D histogram to every segment
        figure (70)
        for j=1:nbins
            subplot(2,4,j)
            bar3(hist_segment(:,:,j))
        end
        % Plot 3D histogram
        % plot cuboid of color histogram
        % hist_segment => [n x n x n]
        bins=1:nbins;
        
        x=reshape(repmat(bins,nbins,nbins),1,[]);
        y=repmat(bins,1,nbins*nbins);
        z=reshape(repmat(bins,nbins*nbins,1),1,[]);
        
        % View every points, including with zero value
        s=hist_segment(:)+1;
        
        color=0:256/nbins:255;
        cx=reshape(repmat(color,nbins,nbins),[],1);
        cy=reshape(repmat(color,1,nbins*nbins),[],1);
        cz=reshape(repmat(color,nbins*nbins,1),[],1);
        
        c=[cx,cy,cz];
        c=c/256;
        
        figure(71),
        scatter3(x,y,z,s,c,'filled'), view(175,35)
    end
end
