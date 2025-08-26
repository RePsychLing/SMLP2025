using CairoMakie
using MixedModels
using MixedModelsMakie
using SMLP2025: datasets

kb07 = dataset("kb07")

fm_max = lmm(@formula(rt_))
