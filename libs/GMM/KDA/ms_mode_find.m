function [m_out, P_out, iter] = ms_mode_find(m_in, P_in, w_in, detP, params)
% [m_out, P_out, iter] = ms_mode_find(m_in, P_in, w_in, detP, params)
%
% Find the convergence point (local maximum) for each Gaussian center by
% mean-shift iteration
%
% NOTE: This code is modified to handle angles in the third dimension.

dim = params.dim;
num = params.num;
th = params.converge;

I = eye(dim);

rmn = repmat(m_in, dim, 1);
iter = zeros(1, num);

for i=1:num,
    cx = m_in(:,i);
    delta = ones(dim, 1);

%     tm = m_in;
%     tm(3,:) = mod(m_in(3,:)-cx(3), 360);
%     idx = find(tm(3,:)>180);
%     tm(3,idx) = tm(3,idx)-360;
%     r = cx(3);
%     cx(3) = 0;
%     rmn = repmat(tm, dim, 1);
    while norm(delta) > th,
        iter(i) = iter(i)+1;
        
    	probs = gauss_prob_nd_mp(cx, m_in, P_in, dim, detP, params);
%     	probs = gauss_prob_nd_mp(cx, tm, P_in, dim, detP, params);
        wsum = w_in*probs';
        if wsum==0                   % Add for fix bug caused by NaN values
            H=zeros(dim,dim);        % ---
            delta = zeros(dim, 1);   % ---
            cx =  zeros(dim, 1);     % ---
        else
    	wt = w_in.*probs/wsum;
        rwt1 = repmat(wt, dim*dim, 1);
    	rwt2 = rwt1(1:dim, :);
        tmp1 = reshape(sum(rwt1.*P_in, 2), [dim dim]);
    	tmp2 = sum(rwt2.*reshape(sum(reshape(P_in.*rmn, dim, []), 1), dim, []), 2);

        H = tmp1\I;
        delta = H*tmp2-cx;
        cx = cx+delta;
        end
    end

%     cx(3) = mod(cx(3)+r, 360);
    m_out(:,i) = cx;
    P_out(:,:,i) = H;
end