function [UnaryTerm model]=ComputeUnaryTerm(data,labelsPrevious,labels,idSegmentsFg_previous, color_histogram_new, HOOF_new, params, model, points, groups, FlagFigures)

% Compute AppearanceScore
ColorModelByGMM=0;
if ColorModelByGMM
    %Get Data
    Image1=data.Image{idFrame-1};
    Image2=data.Image{idFrame};
    
    [AppearanceScore model]=ComputeAppearanceScoreByGMM(Image1,Image2,labelsPrevious,labels,idSegmentsFg_previous, model);
else
    AppearanceScore = ComputeAppearanceScoreByHist(color_histogram_new,model);
end

% Compute Movement Score based on Optical Flow
MovementScore = ComputeMovementScoreByHist(HOOF_new,model);

% Combine the appearance and movement scores with a weighted value
SegmentScore = (params.beta)*AppearanceScore + (1-params.beta)*MovementScore;

% compute the score related to target points
PointScore=ComputePointScore(points,groups,labels);

% Define the unary term combining the scores based on segments and points
UnaryTerm = (params.alpha)*SegmentScore + (1-params.alpha)*PointScore;

% Visualize relation data term - labels in the image segmented
if FlagFigures
    MinDistances=[AppearanceScore; MovementScore];
    visualize_relation_unary_term(UnaryTerm,SegmentScore,MinDistances,labels)
end