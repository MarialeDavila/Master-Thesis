function IndexingArrayId(ArrayId,NameDataset)

switch NameDataset
    case 'CarsMoseg'
        NumAlphaValues=3;
        NumBetaValues=3;
        NumOmegaValues=2;
        NumVideos=10;
    case 'SegTrack'
        NumAlphaValues=3;
        NumBetaValues=3;
        NumOmegaValues=2;
        NumVideos=10;
    case 'MCCD'
        NumAlphaValues=3;
        NumBetaValues=3;
        NumOmegaValues=2;
        NumVideos=10;
    otherwise
        error('Dataset not found')
end

sizeAllValues=[NumAlphaValues,NumBetaValues,NumOmegaValues,NumVideos];
[IdAlpha,IdBeta,IdOmega,idVideo]=ind2sub(sizeAllValues,ArrayId);

% Call function to execute tracking and evaluate the overlap
Test_GetOverlapAllParameters_MultipleIdx(IdAlpha,IdBeta,IdOmega,idVideo,NameDataset);
