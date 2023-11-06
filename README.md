# Evaluating Gender Inequality Policies

## Project Overview

This project aims to evaluate the effectiveness of gender pay gap reduction policies introduced in parts of the United States. The policies include:

1. Internal salary disclosure
2. Encouraging salary negotiations
3. Providing childcare services

The dataset used contains information about treated workers (subject to these policies) and untreated workers, spanning the years 2005 and 2010.

## Data Description

The analysis is based on the "genderinequality" dataset, containing information about individuals in the U.S. The key variables in the dataset include:

- `year`: Either 2005 or 2010
- `wage`: Weekly wage
- `emp`: Employment (1=employed and 0=unemployed)
- `treat`: Treatment indicator (1=treated worker and 0=untreated worker)
- `female`: Gender (1=female and 0=male)
- Other socio-economic and demographic variables.

## Analysis Methods

The analysis employs two main methods: AIPW (Augmented Inverse Probability Weighting) and double lasso. These techniques allow us to assess the impact of the policy interventions on gender inequality in wages and employment while accounting for potential confounders and selection bias.

1. **Double Lasso:**

   - The double lasso technique is employed to select relevant covariates that affect the outcomes of interest.
   - It helps in reducing model complexity by selecting only the most important variables.
   - This approach aids in ensuring the robustness of the analysis by avoiding overfitting.
2. **AIPW (Augmented Inverse Probability Weighting):**

   - AIPW is a statistical method used to estimate causal effects in observational data.
   - It calculates weights based on the propensity of individuals being treated (i.e., subjected to the policy changes).
   - These weights are used to estimate the causal effects of the policy on wage and employment outcomes, particularly with a focus on gender differences.
3. **CATE (Conditional Average Treatment Effect):**

It identifies which segments of the population are expected to benefit more from the new policies, providing insights for targeted interventions and policy decisions.
