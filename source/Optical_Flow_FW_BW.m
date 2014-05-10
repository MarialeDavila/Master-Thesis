function [of_dx of_dy reliability]=Optical_Flow_FW_BW(I1,I2)
% Compute Optical Flow (Piotr's toolbox)
% Optical Flow forward
[of_x_fwd of_y_fwd reliab_fwd]=opticalFlow(I1, I2,'type','LK');
% Optical Flow backward
[of_x_bwd of_y_bwd reliab_bwd]=opticalFlow(I2, I1,'type','LK');

% Verify costraints to get Optical Flow of high reliability
r_fwd=abs(reliab_fwd);
r_bwd=abs(reliab_bwd);
% mean_rf=mean(mean(r_fwd));
% mean_rb=mean(mean(r_bwd));

% If Reliability of OF_Forward is higher than its mean and this is higher
% than OF_Backward, is taken this OF value
relfwd=(r_fwd>=r_bwd); % .*(r_fwd>=mean_rf); 
ofx_fwd=of_x_fwd.*relfwd;
ofy_fwd=of_y_fwd.*relfwd;
% If Reliability of OF_Backward is higher than its mean and this is higher
% than OF_Forward, is taken this OF value
relbwd=(r_bwd>r_fwd); % .*(r_bwd>=mean_rb);
ofx_bwd=-1.*of_x_bwd.*relbwd;
ofy_bwd=-1.*of_y_bwd.*relbwd;
% Get a result collecting the OF obtained
reliability=relfwd+relbwd;
of_dx=ofx_fwd+ofx_bwd;
of_dy=ofy_fwd+ofy_bwd;