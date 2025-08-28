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

using CairoMakie, MixedModelsMakie
caterpillar(slp)
caterpillar(slp;
            vline_at_zero=true,
            # dotcolor=(:cyan, 1.0),
            # barcolor=:yellow,
            orderby=2)

qqcaterpillar(slp)
qqcaterpillar(fm1, cols=["(Intercept)"])

# saving bootstrap results
using StableRNGs

pb_slp = parametricbootstrap(StableRNG(12321), 1000, slp)

# how many fits were singular?
count(issingular(pb_slp))
savereplicates("bootstrap.arrow", pb_slp)
# like restoreoptsum, restorereplicates requires a model
# but this model does not have to be fitted

slp2 = LinearMixedModel(@formula(reaction ~ 1 + days + (1+days|subj)), dataset(:sleepstudy))

savereplicates("bootstrap.arrow", slp2)
