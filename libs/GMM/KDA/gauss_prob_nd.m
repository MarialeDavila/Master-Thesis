function prob = gauss_prob_nd(x, m, P, d)

dd = x-m;

prob = exp(-0.5 * dd' * (P \ dd)) / (2 * pi)^(d / 2) / sqrt(abs(det(P)));