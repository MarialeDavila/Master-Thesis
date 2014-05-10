function Score = ComputeBasedHistScore(HistNew,model_hist_fg,model_hist_bg)
% Compute unary term for every node of the graph

% k - neighbors
k=2;
NumSegments=size(HistNew,1);
numSegments_fg=size(model_hist_fg,1);
numSegments_bg=size(model_hist_bg,1);

% distances to each segment to bg model
if numSegments_bg~=0                 
    % Calculate distances of model to each descriptor of new segments
    distance2bg=pdist2(model_hist_bg,HistNew,'chisq');
    % Define minimum distances 
    if numSegments_bg<4
        ScoreBg=mean(distance2bg,1);
    else
        sort_distance_bg=sort(distance2bg,1);
        ScoreBg=mean(sort_distance_bg(1:k,:),1);
    end
else
    ScoreBg=ones(1,NumSegments);
end

% distances to each segment to fg model
if numSegments_fg~=0
    % Calculate distances of model to each descriptor of new segments
    distance2fg=pdist2(model_hist_fg,HistNew,'chisq');
    % Define minimum distances of movements
    if numSegments_fg<4       
        ScoreFg=mean(distance2fg,1);
    else
        sort_distance_fg=sort(distance2fg,1);
        ScoreFg=mean(sort_distance_fg(1:k,:),1);
    end
else
    ScoreFg = ones(1,NumSegments);
end

% Distance => closer to 0 if belongs to this class
Score=[ScoreBg; ScoreFg];
