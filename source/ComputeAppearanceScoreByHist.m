function AppearanceScore = ComputeAppearanceScoreByHist(color_histogram_new,model)

% Compute Appearance Score using the 3-Dimensional Color Histogram
AppearanceScore = ComputeBasedHistScore(color_histogram_new,model.color_fg,model.color_bg);