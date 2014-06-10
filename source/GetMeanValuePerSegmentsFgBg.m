function [FgData,BgData] = GetMeanValuePerSegmentsFgBg(Image1,labelsPrevious,idSegmentsFg_previous)

[row,cols,channels] = size(Image1);
NumSegments=max(max(labelsPrevious));  % Number of segments on image
FgData = [];
BgData = [];
for i=1:NumSegments        
    Idx = find(labelsPrevious==i);
    if idSegmentsFg_previous(i)==1
        FgData=[FgData; mean(Image1(Idx)) mean(Image1(Idx+row*cols)) mean(Image1(Idx+2*row*cols))];
    else
        BgData=[BgData; mean(Image1(Idx)) mean(Image1(Idx+row*cols)) mean(Image1(Idx+2*row*cols))];
    end
end
FgData = round(FgData);
BgData = round(BgData);
FgData=permute(FgData,[2 1]);
BgData=permute(BgData,[2 1]);