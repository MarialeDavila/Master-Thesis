function Data = GetMeanValuePerSegments(Image2,labels)

[row,cols,channels] = size(Image2);
NumSegments=max(max(labels));  % Number of segments on image
Data = zeros(NumSegments,3);
for i=1:NumSegments        
    Idx = find(labels==i);
    Data(i,:)=[mean(Image2(Idx)) mean(Image2(Idx+row*cols)) mean(Image2(Idx+2*row*cols))];
end
Data = round(Data);
Data = permute(Data,[2 1]);