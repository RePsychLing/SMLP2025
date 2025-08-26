using CairoMakie
using MixedModels
using MixedModelsMakie
using SMLP2025: dataset

fm_sleep = lmm(@formula(reaction ~ 1 + days + (1+days|subj)),
               dataset("sleepstudy"))

shrinkageplot(fm_sleep)

# notice the ! -- we're modifying an existing figure
# (admittedly one that we created in the same line)
# the advantage to this here is that we can specify the
# figure's size manually
shrinkageplot!(Figure(;size=(600,600)), fm_sleep; ellipse=true)

# how do we save a figure?
f = shrinkageplot!(Figure(;size=(600,600)), fm_sleep; ellipse=true)

save("figure.png", f)
save("figure.pdf", f)
save("figure.svg", f)

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


# one final thing....
# Julia makes it easy to show() things in different formats

show(stdout, MIME("text/plain"), fm_max)

show(stdout, MIME("text/markdown"), fm_max)

show(stdout, MIME("text/markdown"), VarCorr(fm_max))

show(stdout, MIME("text/latex"), fm_max)

show(stdout, MIME("text/xelatex"), fm_max)

show(stdout, MIME("text/html"), fm_max)

open("mytable.md", "w") do io
    show(io,  MIME("text/markdown"), fm_max)
end
