# ActNow

This is the code and data used to create the statistics and graphs used in the Act Now papers.

Most of the results are produced using the [Julia](https://julialang.org/) language. The exception is the Stuctured Equation Model (SEM), which is implemented in R using the [Lavaan](https://cran.r-project.org/web/packages/lavaan/index.html) library - this is because the [Julia SEM Implementation](https://structuralequationmodels.github.io/StructuralEquationModels.jl/stable/) failed to converge and I don't have the time (and maybe the skill) to investigate why fully.

The analysis here produces results for a series of papers on each policy proposal and for the changes as a whole. The results reported in any one paper are not always in one place and there is a great deal of output, so finding a particular result may need some digging.

Instructions:

1) [Download and install julia](https://julialang.org/) language for your OS. I used the latest (1.11.1) Linux version.

### Clone or copy this repository. 

The code and data is packaged as a Julia package and [uploaded to GitHub](https://github.com:grahamstark/ActNow.jl).

To get everying:

If you have a Git client, execute:

    git clone git@github.com:grahamstark/ActNow.jl.git

Otherwise, download a zipfile. Click on the green "Code" button on the RHS of the [repository homepage](https://github.com:grahamstark/ActNow.jl). 

3) Instantiate
  - 
  -


[![Build Status](https://github.com/grahamstark/ActNow.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/grahamstark/ActNow.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/grahamstark/ActNow.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/grahamstark/ActNow.jl)