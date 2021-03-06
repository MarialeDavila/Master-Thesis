function [m_out, w_out, n_out, assoc] = merge_gaussians(tm, w, params)
% [m_out, w_out, n_out, assoc] = merge_gaussians(tm, w, params)
%
% Merge Gaussians converged to the same location. The decision is based
% on the threshold that is specified in "params.merge" parameter.

dim = params.dim;
num = params.num;
th = params.merge;

mask = ones(1, num);
n_out = 0;
for i=1:num
    if ~any(mask)
        break;
    end
    if mask(i) == 1
        dm = sum(abs(repmat(tm(:,i), 1, num)-tm).^2, 1);
        idx = find(dm<th & mask==1);
        if ~isempty(idx)
            n_out = n_out+1;
            np = w(idx)/sum(w(idx));
            if any(isnan(np))
                np=zeros(1,numel(idx));
            end
            m_out(:,n_out) = sum(tm(:,idx).*repmat(np, dim, 1), 2);
            w_out(n_out) = sum(w(idx));
            assoc{n_out} = idx;
            mask(idx) = 0;
        end
    end
end

if n_out==0
    n_out=1;
    np = w/sum(w);
    m_out = sum(tm.*repmat(np, dim, 1), 2);
    w_out = sum(w);
    assoc{1} = 1:num;
end