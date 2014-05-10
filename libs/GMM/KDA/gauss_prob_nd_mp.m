function prob = gauss_prob_nd_mp(x, m, P, d, detP, params)

dim = params.dim;
num = params.num;

dd = repmat(x, 1, num)-m;

maha = sum(dd.*reshape(sum(reshape(P.*repmat(dd, dim, 1), dim, []), 1), dim, []), 1);
prob = exp(-0.5*maha)/(2*pi)^(d/2)./sqrt(abs(detP));
