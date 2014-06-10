function [AppearanceScore model]=ComputeAppearanceScoreByGMM(Image1,Image2,labels_frame1,labels,idSegmentsFg_previous, model)

% Parameters - Number of Components
FgNumStates=5;
BgNumStates=5;
% Learn fg and bg model
[FgData,BgData] = GetDataPerSegments(Image1,labels_frame1,idSegmentsFg_previous);
GMMfg = GmmKeySegments(FgData,FgNumStates);
GMMbg = GmmKeySegments(BgData,BgNumStates);

if isfield (model,'GMMfg')
    % Multiply old and new distributions
    fg=mixture_product(GMMfg,model.GMMfg);
    bg=mixture_product(GMMbg,model.GMMbg);
    
    % Apply KDA
    [GMMfg.mean,GMMfg.covariance,GMMfg.weight, GMMfg.numComponents] = KDA(fg.mean, fg.covariance, fg.weight);
    [GMMbg.mean,GMMbg.covariance,GMMbg.weight, GMMbg.numComponents] = KDA(bg.mean, bg.covariance, bg.weight);
end

% Update model
model.GMMfg=GMMfg;
model.GMMbg=GMMbg;

% compute posteriors probabilities
dataR=Image2(:,:,1);
dataG=Image2(:,:,2);
dataB=Image2(:,:,3);
data=[dataR(:); dataG(:); dataB(:)];
data=double(reshape(data,3,[]));
[FgProb,BgProb] = ComputePosteriorProb(data,GMMfg,GMMbg);
% Reshape probabilities per pixels in image size
[rows,cols,channels]=size(Image2);
FgPerImage=reshape(FgProb,[rows cols]);
BgPerImage=reshape(BgProb,[rows cols]);
% Get average probability per segment
NumSegments=max(max(labels));
AppearanceScore=zeros(2,NumSegments);
for i=1:NumSegments
    idx=find(labels==i);
    AppearanceScore(1,i)=mean(BgPerImage(idx));
    AppearanceScore(2,i)=mean(FgPerImage(idx));  
end

