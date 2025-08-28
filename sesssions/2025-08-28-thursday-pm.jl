# pkg> status --outdated

using MixedModels
using MixedModelsDatasets: dataset

fm1 = lmm(@formula(rt_trunc ~ spkr * prec * load +
                              (1 + spkr * prec * load|item) +
                              (1 + spkr * prec * load|subj)),
          dataset(:kb07))
