function [AppearanceScore model]=ComputeAppearanceScoreGMM(Image1,Image2,labels_frame1,labels,idSegmentsFg_previous, model)

% Parameters - Number of Components
FgNumStates=5;
BgNumStates=5;
% Learn fg and bg model
[FgData,BgData] = GetMeanValuePerSegmentsFgBg(Image1,labels_frame1,idSegmentsFg_previous);
if ~isempty(FgData); GMMfg = GmmKeySegments(FgData,FgNumStates); end
if ~isempty(BgData); GMMbg = GmmKeySegments(BgData,BgNumStates); end

if isfield (model,'GMMfg')
    if ~isempty(FgData);
        % Multiply old and new distributions
        fg=mixture_product(GMMfg,model.GMMfg);
        % Apply KDA
        [GMMfg.mean,GMMfg.covariance,GMMfg.weight, GMMfg.numComponents] = KDA(fg.mean, fg.covariance, fg.weight);
        
    end
    
    if ~isempty(BgData);
        % Multiply old and new distributions
        bg=mixture_product(GMMbg,model.GMMbg);
        % Apply KDA
        [GMMbg.mean,GMMbg.covariance,GMMbg.weight, GMMbg.numComponents] = KDA(bg.mean, bg.covariance, bg.weight);
    end
end

% Update model
if ~isempty(FgData); model.GMMfg=GMMfg; end
if ~isempty(BgData); model.GMMbg=GMMbg; end

% compute posteriors probabilities per segments
Data = GetMeanValuePerSegments(Image2,labels);
[FgProb,BgProb] = ComputePosteriorProb(Data,model.GMMfg,model.GMMbg);
% Get appearance score per segment
% It would be a similitud score, the opposite to probability
AppearanceScore(1,:)=1-BgProb;
AppearanceScore(2,:)=1-FgProb;

