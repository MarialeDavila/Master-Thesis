function [FgPim,BgPim] = ComputePosteriorProb(Data,fg,bg)

[nbVar,nbData] = size(Data);
FgPxi=zeros(nbData,fg.numComponents);
BgPxi=zeros(nbData,bg.numComponents);
for j=1:fg.numComponents
    %Compute the probability p(x|i)
    FgPxi(:,j) = gaussPDF(Data, fg.mean(:,j), fg.covariance(:,:,j));            
end

for j=1:bg.numComponents
    %Compute the probability p(x|i)
    BgPxi(:,j) = gaussPDF(Data, bg.mean(:,j), bg.covariance(:,:,j));            
end

%Compute posterior probability p(i|x)
fgPix_tmp = repmat(fg.weight,[nbData 1]).*FgPxi;
bgPix_tmp = repmat(bg.weight,[nbData 1]).*BgPxi;    

FgPix = fgPix_tmp ./ repmat(sum([sum(fgPix_tmp,2),sum(bgPix_tmp,2)],2),[1 fg.numComponents]);
BgPix = bgPix_tmp ./ repmat(sum([sum(fgPix_tmp,2),sum(bgPix_tmp,2)],2),[1 bg.numComponents]);

% Probability per Component
% [FgPim,Fgcomp] = max(FgPix,[],2);  
FgPim = sum(FgPix,2);  % mean(FgPix,2)
FgPim(isnan(FgPim))=0;

% [BgPim,Bgcomp] = max(BgPix,[],2); 
BgPim = sum(BgPix,2); % mean(BgPix,2); 
BgPim(isnan(BgPim))=0;
end
