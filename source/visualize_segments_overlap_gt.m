function label_segment_fg = visualize_segments_overlap_gt(labels,PreviousMask,NumSegments,FlagFigures)
% Choose segments overlaped with foreground
segments_label_fg=zeros(size(labels));
GtSeg_CommonArea=zeros(size(labels));
idGT=find(PreviousMask==1);
threshold=0.25; % 0.5
for i=1:NumSegments   % Number of segments in this frame  
    idSegment=find(labels==i);
    id_overlap_segment_gt=ismember(idSegment,idGT);
    AreaIntersection=sum(id_overlap_segment_gt);      % overlap segment and gt
    SegmentArea=numel(idSegment);           % area segment
    GtSeg_CommonArea(i)=AreaIntersection/SegmentArea;    
    if (GtSeg_CommonArea(i) >= threshold)        
        segments_label_fg(idSegment)=1; % Image with segments of groundtruth
    end
end
label_segment_fg=find(GtSeg_CommonArea>=threshold);

% Visualize segments overlap with GT more than 50% of his area.
if FlagFigures
    figure(11), imshow(segments_label_fg)
    title('Segments labeled foreground according to previous mask')
end