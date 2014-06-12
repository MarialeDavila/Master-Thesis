function [post] = mixture_product(pred, pden)
% Function modified to remove circular shift
% By Maria Alejandra Davila Salazar
% April/2014
pred_num = pred.numComponents;
pred_prob = pred.weight;
pred_mean = pred.mean;
pred_P = pred.covariance;

msr_num = pden.numComponents;
msr_prob = pden.weight;
msr_mean = pden.mean;
msr_P = pden.covariance;

dim = size(pred_mean, 1);
I = eye(dim);

idx = 0;
psum = 0;
m = [];
P = [];
pr = [];
for i = 1:msr_num,
    m1 = msr_mean(:,i);
    
    % centered at m1(3)
%     r = m1(3);
%     m1(3) = 0;

    inv_P1 = msr_P(:,:,i)\I;
    for j = 1:pred_num,
        idx = idx + 1;
        
        m2 = pred_mean(:, j);
        
        % shift by m1(3)
%         m2(3) = mod(m2(3)-r, 360);
%         if m2(3)>180
%             m2(3) = m2(3)-360;
%         end
        
        inv_P2 = pred_P(:,:,j)\I;
        inv_P = (inv_P1+inv_P2)\I;
        m(:,idx) = inv_P*(inv_P1*m1+inv_P2*m2);
        P(:,:,idx) = inv_P;
        pr(idx) = pred_prob(j)*msr_prob(i)*gauss_prob_nd(m1, m2, msr_P(:,:,i)+pred_P(:,:,j), dim);
        psum = psum + pr(idx);

        % recover
%         m(3,idx) = m(3,idx)+r;
    end
end
pr = pr / psum;
tmp_num = msr_num * pred_num;

post.mean = m;
post.covariance = P;
post.weight = pr;
post.numComponents = tmp_num;

