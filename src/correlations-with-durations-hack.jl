using StatsBase, PrettyTables, HypothesisTests,CSV,DataFrames,ActNow
using CairoMakie

function lovelevel( i :: Int )
    return if i >= 70
        "Lovers"
    elseif i <= 30
        "Haters"
    else
        "Middle"
    end
end 

colour = Dict(["Middle"=>:darkgrey,"Lovers"=>:green,"Haters"=>:red])
pols = ActNow.POLICIES
n = length(pols)
rename!(wave4, "Duration (in seconds)"=>"Duration_Secs")
wave4.duration  = wave4.Duration_Secs ./ 60

for truncate in [false,true]
    out = DataFrame( 
        policies=fill("",n), 
        correlation=zeros(n),
        corr_pvalue = zeros(n), 
        mean_Haters_duration = zeros(n),
        mean_Middle_duration = zeros(n),
        mean_Lovers_duration = zeros(n), 
        p_hate_love_duration_eq = zeros(n))
    i = 0
    w4 = deepcopy(wave4)
    ts = "full"
    tsl = "All Observations"
    if truncate
        w4 = w4[w4.duration .<= 100, : ]
        ts = "truncated"
        tsl = "Durations <= 100 mins"
    end
    for pol in pols
        f = Figure(; fontsize=10)
        i += 1
        mxd = -1
        out.policies[i] = "$pol"
        ppost = Symbol("$(pol)_post")
        pol_score = w4[!,ppost]
        out.correlation[i] = cor( pol_score, w4.duration)
        out.corr_pvalue[i] = pvalue( HypothesisTests.CorrelationTest( pol_score, w4.duration))
        # out.hatelove = lovelevel.( pol_score )
        ax = Axis(f[1,1]; title=ActNow.pretty("$ppost")*" : "*tsl,xlabel="Duration (mins)", ylabel="Score")
        w4_grouped = Dict()
        for group in ["Middle","Lovers","Haters"]
                w4_grouped[group] = if group == "Lovers"
                    w4[pol_score .> 70, : ]
                elseif group == "Haters"
                    w4[pol_score .< 30, : ]
                else
                    w4[(pol_score .>= 30) .& (pol_score .<= 70), : ]
                end
        end
        for group in ["Middle","Lovers","Haters"]
            sc = scatter!( ax, w4_grouped[group].duration, w4_grouped[group][!,ppost]; color=colour[group], markersize=3)
            mxd = max(maximum( w4_grouped[group].duration), mxd)
            k = Symbol("mean_$(group)_duration")
            out[i,k]= mean(w4_grouped[group].duration, Weights( w4_grouped[group].weight )) # ??? weight, given ttest is unweighted ???
        end
        lines!(ax, [0,mxd],[30,30]; color=:red, linestyle=:dash, label="Haters")
        lines!(ax, [0,mxd],[70,70]; color=:green, linestyle=:dash, label="Lovers")
        out.p_hate_love_duration_eq[i] = pvalue(EqualVarianceTTest( w4_grouped["Haters"].duration, w4_grouped["Lovers"].duration))
        f[1, 2] = Legend(f, ax, "", framevisible = false)
        save( "output/durations-vs-scores-$(pol)-$(ts).svg", f )
    end
    outf = open("output/durations-vs-scores-$(ts).txt", "w")
    # rename!( out, ["correlation" => "Correlation Approval (post) vs Duration", "corr_pvalue" => "P. Value"])
    pretty_table(outf, out)
    close(outf)
end # truncate
