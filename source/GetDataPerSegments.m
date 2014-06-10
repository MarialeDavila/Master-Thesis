function [FgData,BgData] = GetDataPerSegments(Image1,labelsPrevious,id_label_fg)

FgData = [];
BgData = [];
[row,cols,channels] = size(Image1);
NumSegments=max(max(labelsPrevious));  % Number of segments on image
for i=1:NumSegments        
    Idx = find(labelsPrevious==i);
    if id_label_fg(i)==1
        FgData=[FgData; Image1(Idx) Image1(Idx+row*cols) Image1(Idx+2*row*cols)];
    else
        BgData=[BgData; Image1(Idx) Image1(Idx+row*cols) Image1(Idx+2*row*cols)];
    end
end
FgData = double(FgData);
BgData = double(BgData);
FgData=permute(FgData,[2 1]);
BgData=permute(BgData,[2 1]);