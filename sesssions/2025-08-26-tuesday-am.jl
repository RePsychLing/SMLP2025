using SMLP2025
using SMLP2025: dataset

using MixedModels

lmm(@formula(reaction ~ 1 + days + (1 + days| subj)),
    dataset(:sleepstudy);
    progress=false)

progress = false

lmm(@formula(reaction ~ 1 + days + (1 + days| subj)),
    dataset(:sleepstudy);
    progress=progress)

# after the semicolon, you can just write the keyword/named argument
# instead of kwarg=kwarg -- e.g., you can write "progress" instead of "progress=progress"
lmm(@formula(reaction ~ 1 + days + (1 + days| subj)),
    dataset(:sleepstudy);
    progress)

# doesn't work -- positional arguments have a particular position :D
lmm(dataset(:sleepstudy), @formula(reaction ~ 1 + days + (1 + days| subj)))

# julia distinguishes between characters (single quotes) and strings (double quotes)
# you'll almost always want double quotes

# one other weird thing about strings
# string concatenation is with *
"a" * "b"

# as a corollary, string repetition is done with exponentiation, i.e. ^
"ab"^3

# julia also supports string interpolation
x = 3
"hey look, x = $(x)"

# one bit of magic...

@__FILE__
@__DIR__
pwd()


### time for the the bootstrap

using MixedModels
using SMLP2025: dataset
using Random # core random number functionality in Julia
using StableRNGs # guaranteed reproducibility

# gives a different result every time
rand()

# but we can also specify a random number generator (RNG) with a seed
rand(StableRNG(1))
rand(StableRNG(1))

rng = StableRNG(1)
rand(rng)
rand(rng)

# stream

fm1 = lmm(@formula(reaction ~ 1 + days + (1 + days| subj)),
          dataset(:sleepstudy))

bs1 = parametricbootstrap(StableRNG(42), 1000, fm1; progress=true)

using DataFrames
DataFrame(bs1.coefpvalues)

# let's plot some stuff
using CairoMakie
using AlgebraOfGraphics

df = DataFrame(bs1.β)

plt = data(df) * # specify the table
    mapping(:β; row=:coefname) * # like aes in ggplot
    AlgebraOfGraphics.density() # like the geom_/stat_ in ggplot

draw(plt)

# there is an easier way to do this very common plot
using MixedModelsMakie


ridgeplot(bs1)
coefplot(fm1)
coefplot(bs1)

ridgeplot(bs1; show_intercept=false)

ridge2d(bs1)

# simple RE to make this a little bit faster for demo
contrasts = Dict(:spkr => EffectsCoding(), # same as contr.sum in R
                 :prec => EffectsCoding(),
                 :load => EffectsCoding())

fm2 = lmm(@formula(rt_trunc ~ 1 + spkr * prec * load +
                             (1 + spkr + prec + load |subj) +
                             (1 + spkr + prec + load|item)),
          dataset(:kb07);
          contrasts=contrasts)
# don't ever do a bootstrap with just 200 replicates
# this is only to speed things along for the live demonstration
bs2 = parametricbootstrap(StableRNG(666), 200, fm2;
                          progress=true)

ridgeplot(bs2; show_intercept=false)
ridge2d(bs2)

# Wald confidence intervals --
# based on normal approximation and standard errors
confint(fm1)

confint(bs1)
# same as
confint(bs1; method=:shortest) # highest density
confint(bs1; method=:equaltail)

# in lme4, you specify profile/bootstrap/wald
# as part of the call to confint
# in julia, the method is picked based on whether
# you pass a model, a bootstrap or a profile object

# post-coffee break

# trading off replicate quality for quantity -- make sure to look at the docs for more info!
bs2 = parametricbootstrap(StableRNG(666), 100, fm2;
                           progress=true, optsum_overrides=(;ftol_rel=1e-8))

# simulate some new data
bs1_alt = parametricbootstrap(StableRNG(42), 1000, fm1; β=[300, -10], progress=true)

# now let's simulate from scratch
# this comes from `power_simulation.qmd`

using MixedModelsSim

subj_n = 20
item_n = 20
subj_btwn = Dict(:age => ["old", "young"])
item_btwn = Dict(:frequency => ["low", "high"])
const RNG = StableRNG(42)
dat = simdat_crossed(RNG, subj_n, item_n;
                     subj_btwn, item_btwn)

simmod = fit(MixedModel,
             @formula(dv ~ 1 + age * frequency +
                          (1 + frequency | subj) +
                          (1 + age | item)), dat)

contrasts = Dict(:age => EffectsCoding(),
                 :frequency => EffectsCoding())
simmod = lmm(@formula(dv ~ 1 + age * frequency +
                          (1 + frequency | subj) +
                          (1 + age | item)), dat;
                          contrasts)

# let's add in some fixed effects

β = [250.0, -25.0, 10, 0.0]
simulate!(RNG, simmod; β)
fit!(simmod)

# let's add in some residual noise
σ = 25.0
fit!(simulate!(RNG, simmod; β, σ))

# random effect stddevs are expressed relative
# to the residual stddev
subj_re = create_re(2.0, 1.3)
item_re = create_re(1.3, 2.0)

# convert all the RE to the theta representation
θ = createθ(simmod; subj=subj_re, item=item_re)

fit!(simulate!(RNG, simmod; β, σ, θ))

samp = parametricbootstrap(RNG, 1000, simmod;
                           β, σ, θ, progress=true)

using StatsBase

coefpvalues = DataFrame()
@showprogress for subj_n in [20, 40, 60, 80],  item_n in [40, 60, 80]
    dat = simdat_crossed(RNG, subj_n, item_n;
                         subj_btwn, item_btwn)
    simmod = MixedModel(@formula(dv ~ 1 + age * frequency +
                                     (1 + frequency | subj) +
                                     (1 + age | item)),
                        dat)

    θ = createθ(simmod; subj=subj_re, item=item_re)showprogress
    simboot = parametricbootstrap(RNG, 100, simmod;
                                  β, σ, θ,
                                  optsum_overrides=(;ftol_rel=1e-8),
                                  progress=false)
    df = DataFrame(simboot.coefpvalues)
    df[!, :subj_n] .= subj_n
    df[!, :item_n] .= item_n
    append!(coefpvalues, df)
end


# combine is like summarize in tidy-lingo
# transform is like mutate in tidy-lingo
power = combine(groupby(coefpvalues, [:coefname, :subj_n, :item_n]),
                :p => (p -> mean(p .< 0.05)) => :power)

# let's add in SEMs to power estimates
power = combine(groupby(coefpvalues,
                        [:coefname, :subj_n, :item_n]),
                :p => (p -> mean(p .< 0.05)) => :power,
                :p => (p -> sem(p .< 0.05)) => :power_se)

# now how about CIs too?
select!(power, :coefname, :subj_n, :item_n, :power,
        [:power, :power_se] =>
            ByRow((p, se) -> [p - 1.96*se, p + 1.96*se]) =>
            [:lower, :upper])

data(power) *
    mapping(:subj_n, :item_n, :power; layout=:coefname) *
    visual(Heatmap) |> draw
