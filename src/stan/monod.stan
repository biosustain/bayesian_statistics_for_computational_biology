functions {
  real get_mu_at_t(real mu_max, real ks, real S_at_t) {
    return (mu_max * S_at_t) / (ks + S_at_t);
  }
  vector ddt(real t, vector species, real mu_max, real ks, real gamma) {
    real mu_at_t = get_mu_at_t(mu_max, ks, species[2]);
    vector[2] out;
    out[1] = mu_at_t * species[1];
    out[2] = -gamma * mu_at_t * species[1];
    return out;
  }
}
data {
  int<lower=1> N_measurement;
  int<lower=1> N_timepoint;
  int<lower=1> N_tube;
  int<lower=1> N_strain;
  array[N_measurement] int<lower=1, upper=N_tube> tube;
  array[N_measurement] int<lower=1, upper=N_timepoint> measurement_timepoint;
  array[N_measurement] int<lower=1, upper=2> measured_species;
  vector<lower=0>[N_measurement] y;
  array[N_tube] int<lower=1, upper=N_strain> strain;
  array[N_timepoint] real<lower=0> timepoint_time;
  array[N_tube, 2] vector[2] prior_species_zero;
  array[2] vector[2] prior_sigma_y;
  vector[2] prior_a_mu_max;
  vector[2] prior_a_ks;
  vector[2] prior_a_gamma;
  vector[2] prior_t_mu_max;
  vector[2] prior_t_gamma;
  vector[2] prior_t_ks;
  real<lower=0> abs_tol;
  real<lower=0> rel_tol;
  int<lower=1> max_num_steps;
  int<lower=0, upper=1> likelihood;
}
parameters {
  vector[N_strain] ln_mu_max_z;
  vector[N_strain] ln_ks_z;
  vector[N_strain] ln_gamma_z;
  real a_mu_max;
  real a_ks;
  real a_gamma;
  real<lower=0> t_mu_max;
  real<lower=0> t_ks;
  real<lower=0> t_gamma;
  array[N_tube] vector<lower=0>[2] species_zero;
  vector<lower=0>[2] sigma_y;
}
transformed parameters {
  vector[N_strain] mu_max = exp(a_mu_max + ln_mu_max_z * t_mu_max);
  vector[N_strain] ks = exp(a_ks + ln_ks_z * t_ks);
  vector[N_strain] gamma = exp(a_gamma + ln_gamma_z * t_gamma);
  array[N_tube, N_timepoint] vector[2] abundance;
  for (tube_t in 1 : N_tube) {
    abundance[tube_t] = ode_bdf_tol(ddt, species_zero[tube_t], 0,
                                    timepoint_time,
                                    abs_tol, rel_tol, max_num_steps,
                                    mu_max[strain[tube_t]],
                                    ks[strain[tube_t]], gamma[strain[tube_t]]);
  }
}
model {
  // priors
  ln_mu_max_z ~ std_normal();
  ln_ks_z ~ std_normal();
  ln_gamma_z ~ std_normal();
  a_mu_max ~ normal(prior_a_mu_max[1], prior_a_mu_max[2]);
  a_ks ~ normal(prior_a_ks[1], prior_a_ks[2]);
  a_gamma ~ normal(prior_a_gamma[1], prior_a_gamma[2]);
  t_mu_max ~ normal(prior_t_mu_max[1], prior_t_mu_max[2]);
  t_ks ~ normal(prior_t_ks[1], prior_t_ks[2]);
  t_gamma ~ normal(prior_t_gamma[1], prior_t_gamma[2]);
  for (s in 1 : 2) {
    sigma_y[s] ~ lognormal(prior_sigma_y[s, 1], prior_sigma_y[s, 2]);
    for (t in 1 : N_tube){
      species_zero[t, s] ~ lognormal(prior_species_zero[t, s, 1],
                                     prior_species_zero[t, s, 2]);
    }
  }
  // likelihood
  if (likelihood) {
    for (m in 1 : N_measurement) {
      real yhat = abundance[tube[m], measurement_timepoint[m], measured_species[m]];
      y[m] ~ lognormal(log(yhat), sigma_y[measured_species[m]]);
    }
  }
}
generated quantities {
  vector[N_measurement] yrep;
  vector[N_measurement] llik;
  for (m in 1 : N_measurement){
    real yhat = abundance[tube[m], measurement_timepoint[m], measured_species[m]];
    yrep[m] = lognormal_rng(log(yhat), sigma_y[measured_species[m]]);
    llik[m] = lognormal_lpdf(y[m] | log(yhat), sigma_y[measured_species[m]]);
  }
}

