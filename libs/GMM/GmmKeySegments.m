function [GMMmodel] = GmmKeySegments(Data,NumStates)
% Function modified by Maria Alejandra Davila Salazar
% April 2014

GMMmodel.numComponents=NumStates;
[Weight, Mean, Covariance] = EM_init_kmeans(Data, NumStates);
[GMMmodel.weight, GMMmodel.mean, GMMmodel.covariance, Pix] = EM(Data, Weight, Mean, Covariance);
