using MixedModels, MixedModelsExtras, DataFrames

using MixedModelsDatasets: dataset
using GLM

fm0 = lm(@formula(reaction ~ 1 + days), dataset(:sleepstudy))


fm1 = lmm(@formula(reaction ~ 1 + days + (1 | subj)), dataset(:sleepstudy))




a = lmm(@formula(reaction ~ 1 + days + (1 | subj)), dataset(:sleepstudy))
b = lmm(@formula(reaction ~ 1 + days + (1 + days | subj)), dataset(:sleepstudy))
c = lmm(@formula(reaction ~ 1 + (1 | subj)), dataset(:sleepstudy))
d = lmm(@formula(reaction ~ 1 + (1 + days | subj)), dataset(:sleepstudy))

# tbl = ictable(a, b, c, d)
