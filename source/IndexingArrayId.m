function params=IndexingArrayId(ArrayId)
NumAlphaValues=10;
NumBetaValues=10;
NumOmegaValues=20;
[IdAlpha,IdBeta,IdOmega]=ind2sub([NumAlphaValues,NumBetaValues,NumOmegaValues],ArrayId);
params.alpha=IdAlpha;
params.beta=IdBeta;
params.omega=IdOmega;
