function IndexingArrayId(ArrayId)
NumAlphaValues=4;
NumBetaValues=4;
NumOmegaValues=4;
NumVideos=10;
sizeAllValues=[NumAlphaValues,NumBetaValues,NumOmegaValues,NumVideos];
[IdAlpha,IdBeta,IdOmega,idVideo]=ind2sub(sizeAllValues,ArrayId);

% Call function to execute tracking and evaluate the overlap
Test_GetOverlapAllParameters_MultipleIdx(IdAlpha,IdBeta,IdOmega,idVideo);
