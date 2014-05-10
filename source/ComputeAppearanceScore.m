function AppearanceScore = ComputeAppearanceScore(color_histogram_new,model)
% Compute unary term for every node of the graph

% k - neighbors
k=2;
NumSegments=size(color_histogram_new,1);
numSegments_fg=size(model.color_fg,1);
numSegments_bg=size(model.color_bg,1);
% distances to each segment to bg model
if numSegments_bg~=0
    % Histograms of background model    
    hist_color_bg=model.color_bg;
    % Calculate distances
    distance_color_bg=pdist2(hist_color_bg,color_histogram_new,'chisq');
    % Define minimum distances of color 
    if numSegments_bg<4
        AppearanceScoreBg=mean(distance_color_bg,1);
    else
        sort_distance_color_bg=sort(distance_color_bg,1);
        AppearanceScoreBg=mean(sort_distance_color_bg(1:k,:),1);        
    end
else
    AppearanceScoreBg=ones(1,NumSegments);
end


% distances to each segment to fg model
if numSegments_fg~=0
    % Histograms of foreground model
    hist_color_fg=model.color_fg;
    % Calculate distances
    distance_color_fg=pdist2(hist_color_fg,color_histogram_new,'chisq');
    % Define minimum distances of color and movements
    if numSegments_fg<4
        AppearanceScoreFg=mean(distance_color_fg,1);
    else
        sort_distance_color_fg=sort(distance_color_fg,1);
        AppearanceScoreFg=mean(sort_distance_color_fg(1:k,:),1);
    end
else
    AppearanceScoreFg = ones(1,NumSegments);
end

% Distance => closer to 0 if belongs to this class
AppearanceScore=[AppearanceScoreBg; AppearanceScoreFg];
