function [ActualMask, model,VideoObject]=ComputeSegmentsFeatures(PreviousMask,data,features,points,model,groups,idFrame,FlagFigures,params,VideoObject)
%% Get data
Image1 = data.Image{idFrame-1};
Image2 = data.Image{idFrame};

%% Image Segmentation
% Segmentation method
SegmentationMethod='SLIC';
% Image Segmentation Actual Frame
labels=features.Segmentation.(SegmentationMethod){idFrame};
NumSegments=double(max(max(labels)));  % Number of segments on image

% View image segmented
img_out=VisualizeSegmentation(Image2,labels, FlagFigures);

% Segmentation previous frame
labelsPrevious=features.Segmentation.(SegmentationMethod){idFrame-1};
NumSegmentsGT=max(max(labelsPrevious)); %number of segments in GT

%% CRF parameters
% Visualize segments overlap with GT more than 50% of his area.
segment_fg=visualize_segments_overlap_gt(labelsPrevious,PreviousMask,NumSegmentsGT,FlagFigures);
% Indicator of every segment in groundtruth => fg=1  bg=0
idSegmentsFg_previous=false(1,NumSegmentsGT);
idSegmentsFg_previous(segment_fg)=1;

% Compute Descriptors
[model color_histogram_new HOOF_new]=ComputeDescriptors(data,labelsPrevious,labels,idSegmentsFg_previous, model,features,idFrame);

% Compute Unary term
[UnaryTerm model]=ComputeUnaryTerm(data,labelsPrevious,labels,idSegmentsFg_previous,color_histogram_new, HOOF_new, params, model, points, groups, idFrame,FlagFigures);

% Compute Pairwise Term
PairwiseTerm = compute_pairwise_term(color_histogram_new, HOOF_new,labels, params);

% Label Cost
% Value fixed for the labels of each adjacent node in the graph
LabelCost=[0 1; 1 0];

% Choose segments overlaped with foreground
% Visualize segments overlap with GT more than 50% of his area.
idSegmentsFg=visualize_segments_overlap_gt(labels,PreviousMask,NumSegments,FlagFigures);
% Initial label to each node of the graph
% 1 => Foreground       0 => Background
Class=zeros(1,NumSegments);
Class(idSegmentsFg)=1;

% Visualize Graph edges on the image segmented
if FlagFigures;
    visualize_graph(PairwiseTerm,labels,img_out,NumSegments,Class)
end

%% Optimization with CRF
% GCMEX: An efficient graph-cut based energy minimization
[labels_out E_out Eafter_out] = GCMex(Class, single(UnaryTerm), PairwiseTerm, single(LabelCost),0);


% Visualize output GCM - labels in the image segmented
[ActualMask VideoObject]=visualize_output_GCM(labels,labels_out,Image2,FlagFigures,VideoObject);

% %% Output mask without GCmex 
% ActualMask = GetOutputMaskbyFeatures(UnaryTerm,labels,VideoObject);