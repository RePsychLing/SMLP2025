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

lmm(@formula(reaction ~ 1 + days + (1 + days| subj)), 
    dataset(:sleepstudy);
    progress)    
