%% execute algorithm
% matlabpool open 3
list=[22,97,40];
NameDataset='SegTrack'; % 'MCCD' 'CarsMoseg'
for i=1:numel(list)    
    ArrayId=list(i);
    IndexingArrayId(ArrayId,NameDataset);
    disp(['Done: Array Id = ' num2str(ArrayId)])
end
% matlabpool close
% 
% %% pre-compute features
% matlabpool open
% parfor i=1:6
%     ArrayId=i;
%     PreComputeFeatures(ArrayId);
%     disp(['Done: Array Id = ' num2str(ArrayId)])
% end
% matlabpool close

%%