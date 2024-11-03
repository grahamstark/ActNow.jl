# ActNow

This is the code and data used to create the statistics and graphs used in the Act Now papers.

Most of the results are produced using the [Julia](https://julialang.org/) language. The exception is the Stuctured Equation Model (SEM), which is implemented in R using the [Lavaan](https://cran.r-project.org/web/packages/lavaan/index.html) library - this is because the [Julia SEM Implementation](https://structuralequationmodels.github.io/StructuralEquationModels.jl/stable/) failed to converge and I don't have the time (and maybe the skill) to investigate why fully.

The analysis here produces results for a series of papers on each policy proposal and for the changes as a whole. The results reported in any one paper are not always in one place and there is a great deal of output, so finding a particular result may need some digging.

Instructions:

1) [Download and install julia](https://julialang.org/) language for your OS. I used the latest (1.11.1) Linux version.

### Clone or copy this repository. 

The code and data is packaged as a Julia package and [uploaded to GitHub](https://github.com:grahamstark/ActNow.jl).

To get everything:

If you have a Git client, execute:

    git clone git@github.com:grahamstark/ActNow.jl.git

Otherwise, download a zipfile. Click on the green "Code" button on the RHS of the [repository homepage](https://github.com:grahamstark/ActNow.jl). Unzip this somewhere.

### Instantiate and Run
  
Go to the directory you've created. Open the Julia REPL by typing `julia` at the top of the directory. 

Create everything by running:

   include("scripts/julia_driver.jl")

This may take a while on 1st run.

Alernatively, open `scripts/julia_driver.jl` with a text editor and paste the bits you need into the REPL.



