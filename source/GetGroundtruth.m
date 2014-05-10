function MaskGT = GetGroundtruth(VideoPath)

ListGT=dir([VideoPath,'*.pgm']);
NumFramesWithGT=numel(ListGT);
MaskGT=cell(1,NumFramesWithGT);
for idMask=1:NumFramesWithGT
    GT=imread([VideoPath, ListGT(idMask).name]);
    GT = im2single(GT);
    % Change mask to get unique object in groud truth
    GT(GT~=1)=0; 
    GT(GT~=0)=1;    
    MaskGT{1,idMask}=GT;
end
