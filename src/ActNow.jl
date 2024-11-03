module ActNow

using 
    AlgebraOfGraphics,
    ArgCheck,
    Base.Unicode,
    CairoMakie,
    CategoricalArrays,
    Colors,
    ColorSchemes,
    CSV,
    DataFrames,
    FixedEffectModels,
    Format,
    GLM,
    HypothesisTests,
    Luxor,
    Luxor,
    Makie,
    MixedModels,
    MultivariateStats,
    PrettyTables,
    RegressionTables,
    StatsBase,
    StructuralEquationModels,
    SurveyDataWeighting,
    Tidier

import Luxor:Point # disambiguation
import Luxor:Table

export DATA_DIR,
    analyse_w3_w4_changes,
    create_all_crosstabs,
    do_fixed_effects,
    joinv3v4,
    load_dall_v3,
    load_dall_v4,
    make_all_graphs,
    make_and_print_summarystats,
    make_big_file_by_explanvar,
    make_big_file_by_policy,
    make_w3_w4_change_page,
    run_regressions,
    summarise_pca

const DATA_DIR="data/"
# const WAVE4 = CSV.File("data/wave-4-national-w-created-vars.tab") |> DataFrame
# const WAVE3 = CSV.File("data/wave-3-national-w-created-vars.tab") |> DataFrame

include("common.jl")
include("wave_4_analysis.jl")
include("wave_4_crosstabs.jl")
include("wave_3_4_change_analysis.jl")

end
