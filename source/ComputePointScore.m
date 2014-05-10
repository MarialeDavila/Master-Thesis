function TargetScorePenalty=ComputePointScore(points,groups,labels)

% Compute Target Score based on points model
target_score=ComputeTargetScore(points,groups,labels);

% Penalize according to Target Score
% Sum the target score for each segment, to the opposite class to
% increase the distance value
min_ts=-1; range_ts=2;
ts=(target_score'-(min_ts))/range_ts; % normalized ts [0 - 1]
TargetScorePenalty=[ts; 1-ts];


