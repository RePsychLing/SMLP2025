using SMLP2025
using SMLP2025: dataset

using MixedModels

lmm(@formula(reaction ~ 1 + days + (1 + days| subject)), dataset(:sleepstudy))
