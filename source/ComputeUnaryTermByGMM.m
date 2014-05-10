function [data_term model]=ComputeUnaryTermByGMM(Image1,Image2,labels_frame1,labels,id_label_fg, target_score, params, model)

% Parameters - Number of Components
FgNumStates=5;
BgNumStates=5;
% Learn fg and bg model
[FgData,BgData] = GetDataPerSegments(Image1,labels_frame1,id_label_fg);
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
data_term_withoutP=zeros(2,NumSegments);
for i=1:NumSegments
    idx=find(labels==i);
    data_term_withoutP(1,i)=mean(BgPerImage(idx));
    data_term_withoutP(2,i)=mean(FgPerImage(idx));  
end

% Penalize according to Target Score
% Sum the target score for each segment, to the opposite class to
% increase the distance value
min_ts=-1; range_ts=2;
ts=(target_score'-(min_ts))/range_ts; % normalized ts [0 - 1]
target_score_penalty=[ts; 1-ts];
data_term = (params.alpha)*data_term_withoutP + (1-params.alpha)*target_score_penalty;
