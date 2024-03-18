# What to do after MCMC

Plan for today:

- After MCMC: [diagnostics](#mcmc-diagnostics), [model evaluation](#model-evaluation), [results](#Results)

Recap from last week:

**[MCMC](week2.md#MCMC)**: Monte Carlo Integration using Markov Chains

**[Stan](week2.md#Stan)**: A probabilistic programming framework

# MCMC diagnostics

Overall aim: do my samples really come from my target probability distribution?

General rules of thumb:

- Run plenty of chains
- Adopt a pessimistic mindset: one bad diagnostic is enough! 

## $\hat{R}$

$\hat{R}$ is a number that tells you:

- Do my chains agree with each other?
- Are my chains stationary?

$\hat{R}$ should be close to 1. If not, you need to change something!

Find out more: @vehtariRankNormalizationFoldingLocalization2021

## Divergent transitions

This diagnostic is specific to HMC.

It answers the question *did the trajectory ODE solver fail?*

Usually the reason for the failure is a target distribution with very varying
optimal step sizes.

Sometimes the location of the divergent transitions gives clues about the reason
for the failure.

Find out more:
[@betancourtDiagnosingBiasedInference2017](https://betanalpha.github.io/assets/case_studies/divergences_and_bias.html).

# Model evaluation

## Retrospective 'predictive' checks

**Predictive distribution**: what a model that can replicate its measurements
says about those measurements, i.e. $p(y^{rep})$.

It's very useful to check these things:

- The prior predictive distribution should not allocate much probability mass to
  replicated measurements that are obviously impossible.

- If any actual measurements lie in a region with low prior predictive
  probability (e.g. if measurement $i$ is too low so that $p(y^rep_i>y_i) =
  0.99$), that shows that the prior model is inconsistent with the measurements.

- If there are systematic differences between the posterior predictive
  distribution and the observed measurements, that is a sign that the model is
  inconsistent with the measurements.

Since predictive checking depends on pattern-matching it is often a good idea to
use graphs for it.

## Scoring models with loss functions

**Loss function**: If the observation is $y$ and the model says $p(y) = z$, how
bad is that?

To choose a model, choose a loss function, then try to minimise estimated
expected loss.

:::{.callout-important}

Which loss function is best depends on the problem!

:::

To estimate expected loss, make some predictions.

:::{.callout-important}

In order to be useful for estimating model performance, predictions must be
relevant to the evaluation context that matters.

i.e. not from the training data, not from an already-observed sample, not from
the past, etc...

:::

Find out more: @vehtariSurveyBayesianPredictive2012

## Log likelihood

A good default loss function:

$$
loss(y, p(y)) = -\ln{p(y)}
$$

Out of sample log likelihood can often be approximated cheaply: see
@vehtariPracticalBayesianModel2017.

Find out more: [@landesObjectiveBayesianismMaximum2013, section 2.3] 

# Results

Some useful summary statistics:

Statistic | Answers the question
-------- | --------------------
Mean | "What does the model think is the most likely value"
Standard deviation | "How sure is my model about this?"
Quantile n | "What is x s.t. my model is n% sure that the quantity is at least x?"

Do I have enough samples? To find out, calculate the [Monte Carlo standard error](https://mc-stan.org/docs/reference-manual/effective-sample-size.html#estimation-of-mcmc-standard-error).

:::{.callout-important}
Monte Carlo standard error can vary for different statistics relating to the same quantity
:::

# Example

We'll go through some diagnostics using [arviz](https://python.arviz.org).

Step one is to load some data. Rather than going through a whole modelling
workflow, we'll just take one of the example MCMC outputs that arviz provides
via the function [`load_arviz_data`](https://python.arviz.org/en/stable/api/
generated/arviz.load_arviz_data.html).

This particular MCMC output has to do with measurements of soil radioactivity in
the USA. You can read more about it [here](https://docs.pymc.io/notebooks/multilevel_modeling.html).

```{python}
import arviz as az
import numpy as np  # numpy is for numerical programming
import xarray as xr  # xarray is for manipulating n dimensional tables; arviz uses it a lot! 

idata = az.load_arviz_data("radon")
idata
```

Arviz provides a data structure called [`InferenceData`](https://
python.arviz.org/en/latest/api/inference_data.html) which it uses for storing
MCMC outputs. It's worth getting to know it: there is some helpful explanation
[here](https://python.arviz.org/en/latest/schema/schema.html). 

At a high level, an `InferenceData` is a container for several xarray
`Dataset` objects called 'groups'. Each group contains xarray [`DataArray`]
(https:// docs.xarray.dev/ en/stable/generated/xarray.DataArray.html) objects
called 'variables'. Each variable contains a rectangular array of values,
plus the shape of the values ('dimensions') and labels for the dimensions
('coordinates').

For example, if you click on the dropdown arrows above you will see that
the group `posterior` contains a variable called `a_county` that has three
dimensions called `chain`, `draw` and `County`. There are 85 counties and the
first one is labelled `'AITKIN'`.

The function [`az.summary`](https://python.arviz.org/en/latest/api/generated/arviz.summary.html) lets us look at some useful summary statistics,
including $\hat{R}$, divergent transitions and MCSE.

The variable `lp`, which you can find in the group `sample_stats` is the
model's total log probability density. It's not very meaningful on its own,
but is useful for judging overall convergence. `diverging` counts the number of
divergent transitions.

```{python}
az.summary(idata.sample_stats, var_names=["lp", "diverging"])
```

In this case there were no post-warmup diverging transitions, and the $\hat{R}$
statistic for the `lp` variable is pretty close to 1: great!

Sometimes it's useful to summarise individual parameters. This can be done by
pointing `az.summary` at the group where the parameters of interest live. In
this case the group is called `posterior`.

```{python}
az.summary(idata.posterior, var_names=["sigma", "g"])
```

Now we can start evaluating the model. First we check to see whether replicated
measurements from the model's posterior predictive distribution broadly agree
with the observed measurements, using the arviz function [`plot_lm`](https://python.arviz.org/en/latest/api/generated/arviz.plot_lm.html#arviz.plot_lm):

```{python}
az.style.use("arviz-doc")
az.plot_lm(
    y=idata.observed_data["y"],
    x=idata.observed_data["obs_id"],
    y_hat=idata.posterior_predictive["y"],
    figsize=[12, 5],
    grid=False
);
```

The function `az.loo` can quickly estimate a model's out of sample log
likelihood (which we saw above is a nice default loss function), allowing a nice
numerical comparison between models. 

Watch out for the `warning` column, which can tell you if the estimation is
likely to be incorrect. It's usually a good idea to set the `pointwise` argument
to `True`, as this allows for more detailed analysis at the per-observation
level.

```{python}
az.loo(idata, var_name="y", pointwise=True)
```

The function `az.compare` is useful for comparing different out of sample log
likelihood estimates.

```{python}

idata.log_likelihood["fake"] = xr.DataArray(
    # generate some fake log likelihoods
    np.random.normal(0, 2, [4, 500, 919]),
    coords=idata.log_likelihood.coords,
    dims=idata.log_likelihood.dims
)
comparison = az.compare(
    {
        "real": az.loo(idata, var_name="y"), 
        "fake": az.loo(idata, var_name="fake")
    }
)
comparison

```

The function [`az.plot_compare`](https://python.arviz.org/en/latest/api/generated/arviz.plot_compare.html) shows these results on a nice graph:

```{python}
az.plot_compare(comparison);
    
```
