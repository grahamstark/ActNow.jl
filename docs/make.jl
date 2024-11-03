using ActNow
using Documenter

makedocs(;
    modules=[ActNow],
    authors="Graham Stark, Elliot Johnson Matthew Johnson Daniel Nettle",
    # checkdocs=:exports,
    repo="https://github.com/grahamstark/ActNow.jl/blob/{commit}{path}#L{line}",
    sitename="ActNow.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://grahamstark.github.io/ScottishTaxBenefitModel.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md"
    ],
)

deploydocs(;
    repo="github.com/grahamstark/ActNowl.jl",
)
