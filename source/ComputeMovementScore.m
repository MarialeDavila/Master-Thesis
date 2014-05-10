function MovementScore = ComputeMovementScore(HOOF_new,model)
% Compute unary term for every node of the graph

% k - neighbors
k=2;
NumSegments=size(HOOF_new,1);
numSegments_fg=size(model.movement_fg,1);
numSegments_bg=size(model.movement_bg,1);
% distances to each segment to bg model
if numSegments_bg~=0
    % OF Histogram of background model                     
    hist_of_bg=model.movement_bg;
    % Calculate distances of movements model to each model of new segments
    distance_of_bg=pdist2(hist_of_bg,HOOF_new,'chisq');
    % Define minimum distances 
    if numSegments_bg<4
        MovementScoreBg=mean(distance_of_bg,1);
    else
        sort_distance_of_bg=sort(distance_of_bg,1);
        MovementScoreBg=mean(sort_distance_of_bg(1:k,:),1);
    end
else
    MovementScoreBg=ones(1,NumSegments);
end

% distances to each segment to fg model
if numSegments_fg~=0
    % Histogram of foreground model
    hist_of_fg=model.movement_fg;
    % Calculate distances of movements model to each model of new segments
    distance_of_fg=pdist2(hist_of_fg,HOOF_new,'chisq');
    % Define minimum distances of movements
    if numSegments_fg<4       
        MovementScoreFg=mean(distance_of_fg,1);
    else
        sort_distance_of_fg=sort(distance_of_fg,1);
        MovementScoreFg=mean(sort_distance_of_fg(1:k,:),1);
    end
else
    MovementScoreFg = ones(1,NumSegments);
end

% Distance => closer to 0 if belongs to this class
MovementScore=[MovementScoreBg; MovementScoreFg];
