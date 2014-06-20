% %% execute algorithm
% matlabpool open
% list=[1237, 1318, 1316, 823, 395];
% parfor i=1:numel(list)
%     ArrayId=list(i);
%     IndexingArrayId(ArrayId);
%     disp(['Done: Array Id = ' num2str(ArrayId)])
% end
% matlabpool close

%% pre-compute features
matlabpool open
parfor i=1:6
    ArrayId=i;
    PreComputeFeatures(ArrayId);
    disp(['Done: Array Id = ' num2str(ArrayId)])
end
matlabpool close

%%