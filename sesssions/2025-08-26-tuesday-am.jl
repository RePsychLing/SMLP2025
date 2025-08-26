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

bs2 = parametricbootstrap(StableRNG(666), 200, fm2; 
                          progress=true)   

ridgeplot(bs2; show_intercept=false)                       
ridge2d(bs2)
