function IndexingArrayId(ArrayId)
NumAlphaValues=3;
NumBetaValues=3;
NumOmegaValues=5;
NumVideos=26;
sizeAllValues=[NumAlphaValues,NumBetaValues,NumOmegaValues,NumVideos];
[IdAlpha,IdBeta,IdOmega,idVideo]=ind2sub(sizeAllValues,ArrayId);

% Call function to execute tracking and evaluate the overlap
Test_GetOverlapAllParameters_MultipleIdx(idVideo,IdAlpha,IdBeta,IdOmega)
