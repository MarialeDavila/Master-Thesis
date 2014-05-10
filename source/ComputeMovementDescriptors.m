function HOOF = ComputeMovementDescriptors(of_dx,of_dy,labels)
% Compute descriptors for segments of Image
bin_size=9;
NumSegments=max(max(labels));
HOOF=zeros(NumSegments,bin_size);

for i=1:NumSegments
    id_one_segment=find(labels==i);
    % Movement(OF) histogram
    hist_of=gradientHistogram(of_dx(id_one_segment), of_dy(id_one_segment), bin_size);
    hist_of=reshape(hist_of,1,[]);
    
    if sum(hist_of)==0
        HOOF(i,:)=hist_of;
    else
        HOOF(i,:)=hist_of/sum(hist_of);
    end
    
end