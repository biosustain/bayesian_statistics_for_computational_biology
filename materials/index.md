# Welcome!

This is a course about Bayesian statistics, targeted at systems biologists.

There are three intended learning outcomes:

1. Understand the theoretical basis for applying Bayesian data analysis to
practical scientific problems

2. Develop a familiarity with implementing Bayesian data analysis using modern
software tools

3. Gain deep understanding of both theory and practice of elements of Bayesian
data analysis that are particularly relevant to computational biology, including
custom hierarchical models, large analyses and statistical models with embedded
ODE systems.

## General format

Each week we have a one-hour seminar. The goal is to spend the time approximately
as follows:

1. 25-35mins on 'theory', aka learning things from the book and getting more
reading material

2. 25-35mins on practical computer work

## Plan

### Week 1: [What is Bayesian inference?](introduction_to_bayesian_inference.md) 

#### Theory 

Statistical inference in general 

Bayesian statistical inference 

The big challenge: dimensionality 

#### Practice 

Set up development environment 

git basics  

Install Stan and cmdstanpy

#### Reading 

@jaynesProbabilityTheoryLogic2003 [Ch. 1]

@laplaceMemoirProbabilityCauses1986

@boxBayesianInferenceStatistical1992 [Ch. 1.1]

 
### Week 2: [MCMC and Stan](mcmc_and_stan.md)

#### Theory 

What is MCMC? 

Hamiltonian Monte Carlo 

Probabilistic programming 

#### Practice 

Run an MCMC algorithm and inspect the results 

#### Reading 

@betancourtConceptualIntroductionHamiltonian2018

### Week 3: [Metropolis-Hastings](metropolis-hastings.qmd)
 
### Week 4: [After MCMC](after_mcmc.qmd): diagnostics, and decisions  

#### Theory 

Diagnostics: convergence, divergent transitions, effective sample size 

Model evaluation as decision theory 

Why negative log likelihood is a good default loss function 

#### Practice 

Diagnose some good and bad MCMC runs 

#### Reading

@vehtariRankNormalizationFoldingLocalization2021

@vehtariPracticalBayesianModel2017

### Week 5: Regression models in biology 

#### Theory 

Generalised linear models 

Prior elicitation 

Hierarchical models 

#### Practice 

Compare some statistical models of a simulated biological dataset 

#### Reading 

@HierarchicalModeling 

### Week 6: Hierarchical models 


### Week 7: ODEs 

#### Theory 

What is an ODE? 

ODE solvers 

ODE solvers inside probabilistic programs 
 
#### Practice

Fit a model with an ODE.

#### Reading

@timonenImportanceSamplingApproach2022

### Week 8: Bayesian workflow 

#### Theory 

Parts of a statistical anlaysis (not just inference!) 

Why Bayesian workflow is complex: non-linearity and plurality 

Writing scalable statistical programming projects 

#### Practice 

Write a scalable statistical analysis with [bibat](https://docs.readthedocs.io/en/stable/config-file/v2.html ).

#### Reading 

@gelmanBayesianWorkflow2020 


### Week 9-10: Project 

Format: one hour joint feedback and help session 

