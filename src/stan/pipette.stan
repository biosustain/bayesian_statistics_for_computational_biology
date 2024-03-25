functions {
  vector standardise(vector v, real m, real s) {
    return (v - m) / s;
  }
  real standardise(real v, real m, real s) {
    return (v - m) / s;
  }
  vector unstandardise(vector u, real m, real s) {
    return m + u * s;
  }
  real unstandardise(real u, real m, real s) {
    return m + u * s;
  }
}
data {
  int<lower=1> N;
  int<lower=0> N_cal;
  vector<lower=0>[N] target_volume;
  vector<lower=0>[N_cal] y;
  array[N_cal] int<lower=1, upper=N> measurement_ix;
  real<lower=0> cal_error;
  int<lower=0, upper=1> likelihood;
}
transformed data {
  vector[N_cal] y_ls = standardise(log(y), mean(log(y)), sd(log(y)));
  vector[N] target_volume_ls = standardise(log(target_volume), mean(log(y)),
                                           sd(log(y)));
  real cal_error_s = cal_error / sd(log(y));
}
parameters {
  real<lower=0> volume_noise_s;
  real bias_factor_l;
  vector[N] volume_ls;
}
model {
  volume_noise_s ~ lognormal(log(0.1), 0.5);
  bias_factor_l ~ normal(0, 0.15);
  volume_ls ~ normal(target_volume_ls + bias_factor_l, volume_noise_s);
  if (likelihood) {
    for (i in 1 : N_cal) {
      y_ls[i] ~ normal(volume_ls[measurement_ix[i]], cal_error_s);
    }
  }
}
generated quantities {
  real bias_factor = exp(bias_factor_l);
  real volume_noise = volume_noise_s * sd(log(y));
  vector[N] volume = exp(unstandardise(volume_ls, mean(log(y)), sd(log(y))));
  vector[N_cal] y_rep;
  vector[N_cal] llik;
  for (i in 1 : N_cal) {
    int ms_ix = measurement_ix[i];
    y_rep[i] = lognormal_rng(log(volume[ms_ix]), cal_error);
    llik[i] = lognormal_lpdf(y[i] | log(volume[ms_ix]), cal_error);
  }
}

