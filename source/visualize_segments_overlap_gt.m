function label_segment_fg = visualize_segments_overlap_gt(labels,mask_initial,NumSegments,FlagFigures)
% Choose segments overlaped with foreground

segments_label_fg=zeros(size(labels));
label_segment_fg=[];
for i=1:NumSegments   % Number of segments in this frame
    fg_segment=zeros(size(labels));
    fg_segment(labels==i)=1;            % mask segment
    area_segment=sum(sum(fg_segment));  % area segment
    overlapped_area_segment=sum(sum(fg_segment.*mask_initial)); % overlap
    s =overlapped_area_segment/area_segment;
    threshold=0.5;
    if (s >= threshold)
        label_segment_fg=[label_segment_fg i];
        segments_label_fg(labels==i)=1; % Image with segments of groundtruth
    end
end
% Visualize segments overlap with GT more than 50% of his area.
if FlagFigures
    figure(11), imshow(segments_label_fg)
    title('Segments labeled foreground according to previous mask')    
end