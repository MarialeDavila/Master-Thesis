function [prior_mean, prior_P, prior_prob, num_of_modes] = merge_gaussians_nd(mn, P, prior, num)

num_of_modes = 1;
delta = 1;

prior_mean(:, 1) = mn(:, 1);
prior_P(:, :, 1) = P(:, :, 1);
prior_prob(1) = prior(1);

for i=2:num,
    flag = 0;
    for j=1:num_of_modes,
        diff_mean = sum((mn(:, i) - prior_mean(:, j)).^2);
        % diff_P = sum(sum((P(:, :, i) - prior_P(:, :, j)).^2));
        % if diff_mean < delta & diff_P < delta,
        if diff_mean < delta,
            % fprintf('%f %f %f %f\n', mn(i), prior_mean(i), diff_mean, delta);
            prior_prob(j) = prior_prob(j) + prior(i);
            flag = 1;
        end;
    end;

    if flag == 0,
        num_of_modes = num_of_modes + 1;
        prior_mean(:, num_of_modes) = mn(:, i);
        prior_P(:, :, num_of_modes) = P(:, :, i);
        prior_prob(num_of_modes) = prior(i);
    end;
end;
