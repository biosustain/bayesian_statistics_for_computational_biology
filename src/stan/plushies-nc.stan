data {
 int<lower=1> N;
 int<lower=1> N_salesperson;
 int<lower=1> N_day;
 array[N] int<lower=1,upper=N_salesperson> salesperson;
 array[N] int<lower=1,upper=N_day> day;
 array[N] int<lower=0> sales;
 int<lower=0,upper=1> likelihood;
}
parameters {
 real log_mu;
 vector[N_salesperson] ability_z;
 vector[N_day] day_effect_z;
 real<lower=0> tau_ability;
 real<lower=0> tau_day;
}
transformed parameters {
 vector[N_salesperson] ability = ability_z * tau_ability;
 vector[N_day] day_effect = day_effect_z * tau_day;
 vector[N] log_lambda = log_mu + ability[salesperson] + day_effect[day]; 
}
model {
  log_mu ~ normal(0, 1);
  ability_z ~ normal(0, 1);
  day_effect_z ~ normal(0, 1);
  tau_ability ~ normal(0, 1);
  tau_day ~ normal(0, 1);
  if (likelihood){
    sales ~ poisson_log(log_lambda);
  }
}
generated quantities {
 real mu = exp(log_mu);
 vector[N] lambda = exp(log_lambda);
 array[N] int yrep = poisson_rng(lambda);
 vector[N] llik; 
 for (n in 1:N){
   llik[n] = poisson_lpmf(sales[n] | lambda[n]);
 }
}
