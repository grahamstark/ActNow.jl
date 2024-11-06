# Act Now Replication Code and Data.

This repository contains the code and data used to create the statistics and graphs used in the Act Now series of papers.

Most of the results are produced using the [Julia](https://julialang.org/) language. The exception is the Stuctured Equation Model (SEM), which is implemented in R using the [Lavaan](https://cran.r-project.org/web/packages/lavaan/index.html) library - this is because the [Julia SEM Implementation](https://structuralequationmodels.github.io/StructuralEquationModels.jl/stable/) failed to converge and I don't have the time (and maybe the skill) to investigate why fully.

The code here produces results for a series of papers on each policy proposal and for the changes as a whole. There's a lot of output, and the output isn't organised in a way that neatly matches the papers. Consequently, finding a particular result may need some digging.

Instructions:

### Install Julia and R

[Download and install julia](https://julialang.org/downloads) language for your OS. I used the latest (1.11.1) Linux version. Please don't install in any other way e.g. via a Unix package manager or a software centre.

Install R 4.xx if needed - via [Cran](https://cran.r-project.org/), your institute's software centre, or a package manager.

### Clone or copy this repository. 

The code and data is packaged as a Julia package and [uploaded to GitHub](https://github.com:grahamstark/ActNow.jl).

To get everything:

If you have a [Git client](https://git-scm.com/downloads), execute:

    git clone git@github.com:grahamstark/ActNow.jl.git

Otherwise, download a zipfile. Click on the green "Code" button on the RHS of the [repository homepage](https://github.com:grahamstark/ActNow.jl) and select "Download Zip". Unpack the zipfile  somewhere.

The repository should contain:

* `src` - Julia source code - there are several source 'include files' and a main file ActNow.jl which just consolidates everything;
* `data` - the main act now survey files and edited versions with various created files - e.g. recoded responses.
* `R` - a single R file with the SEM analysis
*  

### Julia Code - Instantiate and Run
  
Start the Julia REPL (Read–eval–print loop). On Windows, you can navigate to the ActNow directory with (e.g.):

    cd( "c:\\users\\gwdv3\\ActNow.jl")

Or, if you're using the command line on Mac/Linux, you can do (e.g.):

    cd /home/graham_s/ActNow.jl

(Or whatever the Powershell equivalent is).   

You can download all the needed libraries and create all the output by running:

    include("scripts/julia_driver.jl")

This may take a while on 1st run as there are a good few libraries to compile.

Alernatively, open `scripts/julia_driver.jl` with a text editor and paste the bits you need into the REPL. There are quite a lot of comments in the file.

Output goes to `output`, not unreasonably. Subdirs 

* `img`
* `regressions`
* `regressions_w3_w4`

## R SEM Model

Is in `R`. Should install packages and run with any R 4.xxx. 







