using MixedModels, MixedModelsExtras, DataFrames
using MixedModelsDatasets: dataset
using GLM

# fm0 = lm(@formula(reaction ~ 1 + days), dataset(:sleepstudy))
# fm1 = lmm(@formula(reaction ~ 1 + days + (1 | subj)), dataset(:sleepstudy))

a = lmm(@formula(reaction ~ 1 + days + (1 | subj)), dataset(:sleepstudy))
b = lmm(@formula(reaction ~ 1 + days + (1 + days | subj)), dataset(:sleepstudy))
c = lmm(@formula(reaction ~ 1 + (1 | subj)), dataset(:sleepstudy))
d = lmm(@formula(reaction ~ 1 + (1 + days | subj)), dataset(:sleepstudy))

tbl = DataFrame(ictable(a, b, c, d))
tbl = DataFrame(ictable(a, b, c, d; label=["x", "y", "turkey", "duck"]))
transform(tbl, Not(:model) .=> ByRow(x -> round(Int, x)); renamecols=false)

# ran the models from glmm.qmd
using StableRNGs
pb3 = parametricbootstrap(StableRNG(20250829), 1000, gm3)
confint(pb3)
confint(pb3; method=:equaltail)

# in julia you can use _ to separate big numbers
1_000
10_00
# it's just ignored

# plz use iso-formatted dates! 2025-08-29

using CSV, DataFrames
dat = CSV.read(filename, DataFrame)

# alternative: use Arrow
using Arrow
Arrow.write("table.arrow", df)
Arrow.write("table.arrow", df)
@time DataFrame(Arrow.Table("table.arrow"))

CSV.write("table.csv", df)
@time CSV.read("table.", DataFrame)
