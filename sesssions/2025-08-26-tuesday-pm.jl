using CairoMakie
using MixedModels
using MixedModelsMakie
using SMLP2025: dataset

fm_sleep = lmm(@formula(reaction ~ 1 + days + (1+days|subj)),
               dataset("sleepstudy"))

shrinkageplot(fm_sleep)

shrinkageplot!(Figure(;size=(600,600)), fm_sleep; ellipse=true)

caterpillar(fm_sleep)

kb07 = dataset("kb07")
contrasts = Dict(:spkr => HelmertCoding(),
                 :prec => HelmertCoding(),
                 :load => HelmertCoding())

fm_max = lmm(@formula(rt_trunc ~ 1 + spkr * load * prec +
                                (1 + spkr * load * prec | subj) +
                                (1 + spkr * load * prec | item)),
             kb07; contrasts=contrasts)

shrinkageplot(fm_max, :subj)

fm_max.rePCA[:subj]

fm_max.PCA[:subj]
