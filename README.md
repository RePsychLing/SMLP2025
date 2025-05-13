# SMLP2025

SMLP2025: Advanced methods in frequentist statistics with Julia

The rendered website version of the course materials is available [here](https://repsychling.github.io/SMLP2025/).

This repository uses [Quarto](https://quarto.org) with the Julia code execution supplied by [QuartoNotebookRunner.jl](https://github.com/PumasAI/QuartoNotebookRunner.jl/).

```sh
~/SMLP2025$ julia

julia> using Pkg

julia> Pkg.activate(".")
  Activating project at `~/SMLP2025`

julia> Pkg.instantiate()
< lots of output >

julia> exit()

~/SMLP2025$ quarto preview

< lots of output >
```
