function [m_out, P_out, w_out, n_out] = KDA(m_in, P_in, w_in)
% Kernel Density Approximation
% Approximate input density function based on a Gaussian mixtures with
% n components into a compact representation, which has m Gaussian 
% components (n >> m).
%
% [m_out, P_out, w_out, n_out] = density_approx(m_in, P_in, w_in)
%
% input
%   m_in: mean of input Gaussians (d x n matrix)
%   P_in: covariance of input Gaussians (d x d x n matrix)
%   w_in: weight of input Gaussians (1 x n vector)
% output
%   m_out: mean of output Gaussian (d x m matrix)
%   P_out: covariance matrix of output Gaussian (d x d x m matrix)
%   w_out: weight of output Gaussian (1 x m vector)
%   n_out: number of components in output Gaussian mixture
%
% reference
% [1] B. Han, D. Comaniciu, Y. Zhu, and L.S. Davis, "Sequential Kernel
%     Density Approximation and Its Application to Real-Time Visual
%     Tracking, IEEE Transactions on Pattern Analysis and Machine
%     Intelligence, vol. 30, no. 7, pp.1186-1197, July, 2008
%
% written by Bohyung Han

[dim, num] = size(m_in);
I = eye(dim);
for i=1:num
	invP(:,:,i) = P_in(:,:,i)\I;
	invPv(:,i) = reshape(invP(:,:,i), [], 1);
    detP(i) = det(P_in(:,:,i));
end

params.dim = dim;
params.num = num;
params.converge = 0.01;
params.merge = 0.1;
params.th = 0.03;

[tm] = ms_mode_find(m_in, invPv, w_in, detP, params);
[m_out, w_out, n_out, assoc] = merge_gaussians(tm, w_in, params);
[P_out, chk] = estimate_cov(m_out, w_out, n_out, m_in, invP, w_in, invPv, detP, params);

if ~isempty(chk.pd)
    m_out = cat(2, m_out(:,chk.nd), m_in(:,cat(2, assoc{chk.pd})));
    P_out = cat(3, P_out(:,:,chk.nd), P_in(:,:,cat(2, assoc{chk.pd})));
    w_out = cat(2, w_out(chk.nd), w_in(cat(2, assoc{chk.pd})));
end

idx = find(w_out>params.th);
m_out = m_out(:,idx);
P_out = P_out(:,:,idx);
w_out = w_out(idx)/sum(w_out(idx));
n_out = length(idx);
