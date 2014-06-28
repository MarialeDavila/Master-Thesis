function [P_out, chk] = estimate_cov(m_out, w_out, n_out, m_in, invP, w_in, invPv, detP, params)
% [P_out, chk] = estimate_cov(m_out, w_out, n_out, m_in, invP, w_in, invPv,
%                             detP, params)
%
% Estimate covariance for each detected mode by curvature analysis.
%
% NOTE: This code is modified to handle angles in the third dimension.

dim = params.dim;
num = params.num;
I = eye(dim);

pd = [];
nd = [];
Hes = zeros(dim, dim, n_out);
for i=1:n_out,
    cm1 = m_out(:, i);

    % align angles w.r.t. cm1
%     tm = m_in;
%     tm(3,:) = mod(m_in(3,:)-cm1(3), 360);
%     idx = find(tm(3,:)>180);
%     tm(3,idx) = tm(3,idx)-360;
%     cm1(3) = 0;

    wt = w_in.*gauss_prob_nd_mp(cm1, m_in, invPv, dim, detP, params);    
%     wt = w_in.*gauss_prob_nd_mp(cm1, tm, invPv, dim, detP, params);    
    for j = 1:num,
        cm2 = m_in(:,j);
%         cm2 = tm(:,j);
        invcP = invP(:,:,j);
        cmdiff = cm1-cm2;
        tmp = invcP*cmdiff;
        Hes(:,:,i) = Hes(:,:,i)+wt(j)*(tmp*tmp'-invcP);
    end
    IdIsNan=isnan(Hes); % edit to avoid bug in eig() function
    IdIsInf=isinf(Hes); % -----
    Hes(IdIsNan)=0;     % -----
    Hes(IdIsInf)=0;     % -----
    D = eig(Hes(:,:,i));
    if any(D>=0)
        pd = [pd i];
        P_out(:,:,i) = I;
    else
        nd = [nd i];
        invHes = Hes(:,:,i)\I;
        P_out(:,:,i) = det(-2*pi*invHes)^(-1/(dim+2))*(-invHes)*w_out(i)^(2/(dim+2));
    end
end

chk.pd = pd;
chk.nd = nd;