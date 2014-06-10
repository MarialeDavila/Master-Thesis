list=[1237, 1318, 1316, 823, 395];
parfor i=1:numel(list)
    ArrayId=list(i);
    IndexingArrayId(ArrayId);
    disp(['Done: Array Id = ' num2str(ArrayId)])
end