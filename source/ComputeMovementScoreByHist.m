function MovementScore = ComputeMovementScoreByHist(HOOF_new,model)

model_hist_fg=model.movement_fg;
model_hist_bg=model.movement_bg;
MovementScore = ComputeBasedHistScore(HOOF_new,model_hist_fg,model_hist_bg);