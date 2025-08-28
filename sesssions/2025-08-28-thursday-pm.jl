# pkg> status --outdated

using MixedModels
using MixedModelsDatasets: dataset

fm1 = lmm(@formula(rt_trunc ~ spkr * prec * load +
                              (1 + spkr * prec * load|item) +
                              (1 + spkr * prec * load|subj)),
          dataset(:kb07))

saveoptsum("big_mod.json", fm1)

# just construct, don't fit
reloaded = LinearMixedModel(@formula(rt_trunc ~ spkr * prec * load +
                              (1 + spkr * prec * load|item) +
                              (1 + spkr * prec * load|subj)),
          dataset(:kb07))

restoreoptsum!(reloaded, "big_mod.json")

slp = lmm(@formula(reaction ~ 1 + days + (1+days|subj)), dataset(:sleepstudy))

using StandardizedPredictors

lmm(@formula(reaction ~ 1 + days + (1+days|subj)),
    dataset(:sleepstudy);
    contrasts=Dict(:days => Center()))

# we can use a precomputed value
lmm(@formula(reaction ~ 1 + days + (1+days|subj)),
    dataset(:sleepstudy);
    contrasts=Dict(:days => Center(2)))

# we can also use a function
using StatsBase
lmm(@formula(reaction ~ 1 + days + (1+days|subj)),
    dataset(:sleepstudy);
    contrasts=Dict(:days => Center(minimum)))

# there's also zscore
# (doesn't make sense for days, but whatever...)
lmm(@formula(reaction ~ 1 + days + (1+days|subj)),
    dataset(:sleepstudy);
    contrasts=Dict(:days => ZScore()))
