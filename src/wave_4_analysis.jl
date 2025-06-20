#
# This script generates regressions & charts from the ActNow dataset,
#
"""
Correlation matrix for the policies
"""
function corrmatrix( df, keys, pre_or_post = "_pre" ) :: Tuple
    corrtars = Symbol.(string.(keys).*pre_or_post)
    n = length(keys)
    corrs = cor(Matrix(df[:,corrtars]))
    targets = df[:,corrtars]
    corrs = pairwise( cor, eachcol(targets); symmetric=true )
    pvals = pvalue.(pairwise(CorrelationTest, eachcol(targets); symmetric=true ))
    corrs = convert(Array{Union{Float64,Missing}},corrs)    
    pvals = convert(Array{Union{Float64,Missing}},pvals)    
    println(corrs)
    for r in 1:n
        for c in (r+1):n
            corrs[r,c] = missing
            pvals[r,c] = missing
        end
    end  
    labels = lpretty.(keys)
    cord = DataFrame( corrs, labels )
    pvals = DataFrame( pvals, labels )
    cord." " = labels
    pvals." " = labels
    degrees_of_freedom = size(df)[1] - 2
    cord, pvals, degrees_of_freedom
end

"""
Produce a single column with which treatment and the score
"""
function merge_treats!( dall :: DataFrame, label::String )
    n = size( dall )[1]
    dall[:,"$(label)_overall_score"] = zeros(n)
    dall[:,"$(label)_which_treat"] = fill("",n)
    dall[:,"$(label)_which_treat_label"] = fill("",n)
    for i in 1:n
        for t in TREATMENT_TYPES
            if ! ismissing( dall[i,"$(label)_treat_$(t)_score"])
                dall[ i, "$(label)_which_treat" ] = t
                dall[ i, "$(label)_which_treat_label" ] = TREATMENT_TYPESDICT[t]
                dall[ i, "$(label)_overall_score" ] = dall[i,"$(label)_treat_$(t)_score"]
            end
        end
    end
end

"""
This convoluted function creates a bunch or binary variables in the dataframe `dall` for some question and treatments.
    @param `labels` - for readable variable names e.g. "basic_income"
    @param `initialq` - initial opinion on the thing
    @param `finalq` - final (post explanation) opinion
    @param `treatqs` - three strings representing the 3 explanations for that thing - abs gains, rel gains, security
    adds in variables like `basic_income_treat_absgains_destitute`
"""
function create_one!( 
    dall::DataFrame; 
    label :: String, 
    initialq :: String, 
    finalq :: String, 
    treatqs :: Vector{String} )
    #
    dall[:,"$(label)_treat_absgains_v"] = dall[:,"$(treatqs[1])"]
    #
    # identify subsets who heard the absolute/relative/security arguments
    dall[:,"$(label)_treat_absgains"] = ( .! ismissing.( dall[:,"$(treatqs[1])"] ) )
    dall[:,"$(label)_treat_relgains"] = ( .! ismissing.( dall[:,"$(treatqs[2])"] ) )
    dall[:,"$(label)_treat_security"] = ( .! ismissing.( dall[:,"$(treatqs[3])"] ) )
    dall[:,"$(label)_treat_other_argument"] = ( .! ismissing.( dall[:,"$(treatqs[4])"] ) )

    dall[:,"$(label)_treat_absgains_score"] = dall[:,"$(treatqs[1])"]
    dall[:,"$(label)_treat_relgains_score"] = dall[:,"$(treatqs[2])"]
    dall[:,"$(label)_treat_security_score"] = dall[:,"$(treatqs[3])"]
    dall[:,"$(label)_treat_other_argument_score"] = dall[:,"$(treatqs[4])"]



    rename!( dall, Dict(initialq => "$(label)_pre", (finalq => "$(label)_post" )))
    # change after hearing argument
    dall[:,"$(label)_change"] = dall[:,"$(label)_post"] - dall[:,"$(label)_pre"]
    dall[:,"$(label)_strong_approve_pre"] = dall[:,"$(label)_pre"] .>= 70
    dall[:,"$(label)_strong_approve_post"] = dall[:,"$(label)_post"] .>= 70
    
    # interactions of fear of destitution and the 4 different arguments
    dall[:,"$(label)_treat_absgains_destitute"] = dall.destitute .* dall[:,"$(label)_treat_absgains"]
    dall[:,"$(label)_treat_relgains_destitute"] = dall.destitute .* dall[:,"$(label)_treat_relgains"]
    dall[:,"$(label)_treat_security_destitute"] = dall.destitute .* dall[:,"$(label)_treat_security"]
    dall[:,"$(label)_treat_other_argument_destitute"] = dall.destitute .* dall[:,"$(label)_treat_other_argument"]

    merge_treats!( dall, label )
end

"""
Hacky fix of income where some people seem to have entered in £000s rather than £s
"""
function recode_income( inc )
    oinc = if ismissing( inc )
        missing
    elseif inc < 100
        inc * 1000
    else
        inc
  end
  return oinc/1_000.0
end

#
# convoluted stuff to get RegressionTables to print p- values under the coefficients, since
# that isn't one of the defaults.
# I don't really understand this!
# See: https://jmboehm.github.io/RegressionTables.jl/stable/regression_statistics/#RegressionTables.AbstractUnderStatistic
# and the RegressionTables.jl source code.
#
# struct ConfInt <: RegressionTables.AbstractUnderStatistic
#     val::Float64
# end

# function ConfInt(rr::RegressionModel, k::Int; vargs...)
#     ConfInt(RegressionTables._ConfInt(rr)[k])
# end

function g2i( Gender )
    return if Gender .== "Male"
        1
    elseif Gender .== "Female"
        2
    else 
        rand(1:2)
    end
end

"""
Initial load and construction of v4 dataset with extra created
variables.
"""
function make_dataset_v4()::DataFrame

    dn = CSV.File("$(DATA_DIR)/national_censored.csv")|>DataFrame
    dr = CSV.File("$(DATA_DIR)/red_censored.csv")|>DataFrame
    dn.is_redwall .= false
    dr.is_redwall .= true

    dall = vcat(dn,dr)

    CSV.write( "$(DATA_DIR)/national_censored.tab", dall; delim='\t')

    # needs to be done before renaming..
    # dall.old_or_destitute = (dall."Q66.2" .>= 50) .| (dall."Q66.9_1" .>= 70)
    dall.destitute = (dall."Q66.9_1" .>= 70)

    create_one!( dall; label="basic_income", initialq="Q5.1_4", finalq="Q10.1_4", treatqs=["Q6.1_4","Q7.1_4","Q8.1_4","Q9.1_4"])
    create_one!( dall; label="green_nd", initialq="Q11.1_4", finalq="Q16.1_4", treatqs=["Q12.1_4","Q13.1_4","Q14.1_4","Q15.1_4"])
    create_one!( dall; label="utilities", initialq="Q17.1_4", finalq="Q22.1_4", treatqs=["Q18.1_4","Q19.1_4","Q20.1_4","Q21.1_4"])
    create_one!( dall; label="health", initialq="Q23.1_4", finalq="Q28.1_4", treatqs=["Q24.1_4","Q25.1_4","Q26.1_4","Q27.1_4"])
    create_one!( dall; label="childcare", initialq="Q29.1_4", finalq="Q34.1_4", treatqs=["Q30.1_4","Q31.1_4","Q32.1_4","Q33.1_4"])
    create_one!( dall; label="education", initialq="Q35.1_4", finalq="Q40.1_4", treatqs=["Q36.1_4","Q37.1_4","Q38.1_4","Q39.1_4"])
    create_one!( dall; label="housing", initialq="Q41.1_4", finalq="Q46.1_4", treatqs=["Q42.1_4","Q43.1_4","Q44.1_4","Q45.1_4"])
    create_one!( dall; label="transport", initialq="Q47.1_4", finalq="Q52.1_4", treatqs=["Q48.1_4","Q49.1_4","Q50.1_4","Q51.1_4"])
    create_one!( dall; label="democracy", initialq="Q53.1_4", finalq="Q58.1_4", treatqs=["Q54.1_4","Q55.1_4","Q56.1_4","Q57.1_4"])
    create_one!( dall; label="tax", initialq="Q59.1_4", finalq="Q64.1_4", treatqs=["Q60.1_4","Q61.1_4","Q62.1_4","Q63.1_4"])
    
    rename!( dall, RENAMES_V4 )
    # dall = dall[dall.HH_Net_income_PA .> 0,:] # skip zeto incomes 
    dall = dall[(.! ismissing.(dall.HH_Net_Income_PA )) .& (dall.HH_Net_Income_PA .> 0),:]
    n = size(dall)[1]
    dall.HH_Net_Income_PA .= recode_income.( dall.HH_Net_Income_PA)
    dall.ethnic_2 = recode_ethnic.( dall.Ethnic )

    dall.last_election = recode_party.( dall.Party_Last_Election, condensed=false )
    dall.last_election_condensed = recode_party.( dall.Party_Last_Election, condensed=true  )
    dall.next_election =  recode_party.( dall.Party_Next_Election, condensed=false )
    dall.next_election_condensed .= recode_party.( dall.Party_Next_Election, condensed=true )

    dall.employment_2 = recode_employment.(dall.Employment_Status)
    dall.log_income = log.(dall.HH_Net_Income_PA)
    dall.age_sq = dall.Age .^2
    dall.Gender= convert.(String,dall.Gender)
    dall.Gender = recode_gender.( dall.Gender )
    dall.trust_in_politics = build_trust.( eachrow( dall ))
    dall.Owner_Occupier= convert.(String,dall.Owner_Occupier)
    dall.General_Health= convert.(String,dall.General_Health)
    
    
    dall.Little_interest_in_things = convert.(String,dall.Little_interest_in_things )
    dall.age5 = dall.Age .÷ 5
    dall.poorhealth = dall.General_Health .∈ (["Bad","Very bad"],)
    dall.unsatisfied_with_income = dall.Satisfied_With_Income .∈ ( 
        ["1. Completely dissatisfied","2. Mostly dissatisfied", "3. Somewhat dissatisfied]"], )
    dall.not_managing_financially = dall.Managing_Financially .∈ ( 
        ["5. Finding it very difficult", "4.\tFinding it quite difficult"], )
    dall.down_the_ladder = dall.Ladder .<= 4
    # rename!( dall, ["last_election"=>"Party Vote Last Election"])
    dall.gad_7 = health_score.(eachrow(dall), GAD_7...)
    dall.phq_8 = health_score.(eachrow(dall), PHQ_8...)
    dall.sqrt_gad_7 = sqrt.(dall.gad_7)
    dall.sqrt_phq_8 = sqrt.(dall.phq_8)

    #
    # numeric analogs of catalogs for SEM models
    #
    dall.i_Gender = g2i.( dall.Gender ) 

    dall.i_Politicians_All_The_Same = extract_number.( dall.Politicians_All_The_Same ) .+ 1 # extract subtracys one ..
    dall.i_Politics_Force_For_Good = extract_number.( dall.Politics_Force_For_Good ) .+ 1
    dall.i_Party_In_Government_Doesnt_Matter = extract_number.( dall.Party_In_Government_Doesnt_Matter ) .+ 1
    dall.i_Politicians_Dont_Care = extract_number.( dall.Politicians_Dont_Care ) .+ 1
    dall.i_Politicians_Want_To_Make_Things_Better = extract_number.( dall.Politicians_Want_To_Make_Things_Better ) .+ 1
    dall.i_Shouldnt_Rely_On_Government = extract_number.( dall.Shouldnt_Rely_On_Government ) .+ 1
    dall.i_Satisfied_With_Income = extract_number.( dall.Satisfied_With_Income )  .+ 1
    dall.i_Managing_Financially = extract_number.( dall.Managing_Financially ) .+ 1
    dall.overall_pre = copy( dall.overall_post ) # Needed as a dummy for some crosstabs
    dall.overall_change = dall.overall_pre .- dall.overall_post # always zero
    
    #
    # Dump modified data
    #
    dall.weight = reweight( dall )
    CSV.write( joinpath( DATA_DIR, "national-w-created-vars.tab"), dall; delim='\t')
    return dall
end # make dataset

function make_labels()::Dict{String,String}
    d = Dict{String,String}()
    for policy in POLICIES
        pp = lpretty( policy )
        d["$(policy)_change"] = "$pp"
        d["$(policy)_pre"] = "$pp"
        d["$(policy)_post"] = "$pp"
        d["$(policy)_treat_relgains"] = "Shown Relative Gains Argument"
        d["$(policy)_treat_security"] = "Shown Security Argument"
        d["$(policy)_treat_absgains"] = "Shown Absolute Gains Argument"
        d["$(policy)_treat_other_argument"] = "Shown Flourishing Argument"
    end
    d["Any_Argument"] = "Influenced by any Argument (Q65.3)"
    d["Age"] = "Age (Q66.2)"
    d["Gender"] = "Gender (Q66.3)"
    d["is_redwall"] = "From Redwall Constituency"
    d["next_election"] = "Voting Intention (Q66.23)"
    # d["destitute"] = "At Risk of Destitution"
    d["log(HH_Net_Income_PA)"] = "Log of household annual net income (Q66.6)"
    d["ethnic_2: Other Ethnic"] = "Not Ethnically British (Q66.4)"
    d["Gender: In another way (please type in below)"] = "Other Gender/Gender not specified (Q66.3)"
    d["employment_2: Working/SE Inc. Part-Time"] = "Working or Self Employed (inc. part-time) (Q66.7)"
    return merge(d, MAIN_EXPLANDICT )
end

"""
Sample with > 0 and < 100 for some policy if exclude_0s_and_100s is true
"""
function possibly_restricted_sample( dall :: DataFrame, policy :: Symbol, exclude_0s_and_100s )::DataFrame
    if ! exclude_0s_and_100s
        return dall
    end
    v = dall[!,policy]
    incls = (v .> 0) .& (v .< 100) 
    # println( incls )
    return deepcopy(dall[incls,:]) # otherwise we'll progressively delete records with each policy 
end

function run_regressions_by_mainvar( 
    dall::DataFrame, 
    mainvar :: Symbol;
    exclude_0s_and_100s :: Bool,
    regdir = "regressions" )
    #
    # regressions: for each policy, before the explanation, do a big regression and a simple one and add them to a list
    # the convoluted `@eval(@formula( $(depvar)` bit just allows to sub in each dependent variable `$(depvar)`
    #
    prefix = exclude_0s_and_100s ?  "extremes_excluded" : "fullsample"
    labels = make_labels()
    regs=[]
    simpleregs = []
    for policy in POLICIES
        depvar = Symbol( "$(policy)_pre")
        data = possibly_restricted_sample( dall, depvar, exclude_0s_and_100s )
        if mainvar == :x
            reg = lm( @eval(@formula( $(depvar) ~ 
                Age + next_election + ethnic_2 + employment_2 + 
                log(HH_Net_Income_PA) + is_redwall + Gender )), data )
        else
            reg = lm( @eval(@formula( $(depvar) ~ 
                Age + next_election + ethnic_2 + employment_2 + 
                log(HH_Net_Income_PA) + is_redwall + Gender + 
                $(mainvar))), data )
        end
        push!( regs, reg )
        if mainvar == :x
            reg = lm( @eval(@formula( $(depvar) ~ Age + Gender )), dall)
        else 
            reg = lm( @eval(@formula( $(depvar) ~ 
                Age + Gender + $( mainvar ))), data)
        end
        push!( simpleregs, reg )
    end 
    #
    # regression of change in popularity of each policy against each explanation
    #
    diffregs=[]
    for policy in POLICIES
        depvar = Symbol( "$(policy)_change")
        relgains = Symbol( "$(policy)_treat_relgains" )
        relsec =Symbol( "$(policy)_treat_security" )
        absgains =Symbol( "$(policy)_treat_absgains" )
        depvar = Symbol( "$(policy)_pre")
        data = possibly_restricted_sample( dall, depvar, exclude_0s_and_100s )
        relflourish = 
            Symbol( "$(policy)_treat_other_argument" )
        if mainvar == :x
            reg = lm( @eval(@formula( $(depvar) ~ Gender + $(relgains) + $(relflourish) + $(relsec))), data )
        else
            reg = lm( @eval(@formula( $(depvar) ~ Gender + $(relgains) + $(relflourish) + $(relsec) + $(mainvar))), data )            
        end
        push!( diffregs, reg )
    end 
    regtable(regs...;file=joinpath("output",regdir,"actnow-$(mainvar)-$(prefix)-ols.html"),number_regressions=true, stat_below=true, render = HtmlTable(), labels=labels, below_statistic = ConfInt )
    regtable(simpleregs...;file=joinpath("output",regdir,"actnow-simple-$(mainvar)-$(prefix)-ols.html"),number_regressions=true, stat_below=true, render = HtmlTable(), labels=labels, below_statistic = ConfInt )
    regtable(diffregs...;file=joinpath("output",regdir,"actnow-change-$(mainvar)-$(prefix)-ols.html"),number_regressions=true, stat_below=true,  below_statistic = ConfInt, render = HtmlTable(), labels=labels)
    #= unneeded ascii/latex versions 
    regtable(regs...;file="output/regressions/actnow-$(mainvar)-ols.txt",number_regressions=false, stat_below=true, render=AsciiTable(), labels=labels)
    regtable(simpleregs...;file="output/regressions/actnow-simple-$(mainvar)-ols.txt",number_regressions=true, stat_below=true,  below_statistic = ConfInt, render=AsciiTable(), labels=labels)
    regtable(diffregs...;file="output/regressions/actnow-change-$(mainvar)-ols.txt",number_regressions=true, stat_below=true,  below_statistic = ConfInt, render=AsciiTable(), labels=labels)
    regtable(regs...;file="output/regressions/actnow-$(mainvar)-ols.tex",number_regressions=true, stat_below=true,  below_statistic = ConfInt, render=LatexTable(), labels=labels)
    regtable(simpleregs...;file="output/regressions/actnow-simple-$(mainvar)-ols.tex",number_regressions=true, stat_below=true,  below_statistic = ConfInt, render=LatexTable(), labels=labels)
    regtable(diffregs...;file="output/regressions/actnow-change-$(mainvar)-ols.tex",number_regressions=true, stat_below=true,  below_statistic = ConfInt, render=LatexTable(), labels=labels)
    =#
end # run_regressions_by_mainvar

"""
Take 2 - slightly different regressions and tables organised by policy
"""
function run_regressions_by_policy( 
    dall::DataFrame, 
    policy :: Symbol;
    exclude_0s_and_100s :: Bool,
    regdir = "regressions",
    do_changes = true )
    #
    # regressions: for each policy, before the explanation, do a big regression and a simple one and add them to a list
    # the convoluted `@eval(@formula( $(depvar)` bit just allows to sub in each dependent variable `$(depvar)`
    #
    prefix = exclude_0s_and_100s ?  "extremes_excluded" : "fullsample"
#
    # regressions: for each policy, before the explanation, do a big regression and a simple one and add them to a list
    # the convoluted `@eval(@formula( $(depvar)` bit just allows to sub in each dependent variable `$(depvar)`
    #
    regs=[]
    simpleregs = []
    very_simpleregs = []
    depvar = Symbol( "$(policy)_pre")
    relgains = Symbol( "$(policy)_treat_relgains" )
    relsec =Symbol( "$(policy)_treat_security" )
    absgains = Symbol( "$(policy)_treat_absgains" )
    relflourish = Symbol( "$(policy)_treat_other_argument" )
    data = possibly_restricted_sample( dall, depvar, exclude_0s_and_100s )

    reg = lm( @eval(@formula( $(depvar) ~ 
        Age + next_election + ethnic_2 + employment_2 + 
        log(HH_Net_Income_PA) + is_redwall + Gender )), data )
    push!( regs, reg )
        reg = lm( @eval(@formula( $(depvar) ~ Age + Gender )), data )
    push!( simpleregs, reg )
    nms = Symbol.(names( dall ))
    for mainvar in MAIN_EXPLANVARS
        if mainvar in nms
            reg = lm( @eval(@formula( $(depvar) ~ 
                Age + next_election + ethnic_2 + employment_2 + 
                log(HH_Net_Income_PA) + is_redwall + Gender + 
                $(mainvar))), data )
            push!( regs, reg )
            reg = lm( @eval(@formula( $(depvar) ~ 
                Age + Gender + $( mainvar ))), data )
            push!( simpleregs, reg )
            reg = lm( @eval(@formula( $(depvar) ~ 
                $( mainvar ))), data )
            push!( very_simpleregs, reg )
        end
    end 
    labels = make_labels()
    # 
    regtable(regs...;file=joinpath("output",regdir,"actnow-$(policy)-$(prefix)-ols.html"),number_regressions=true, stat_below=true,  below_statistic = ConfInt, render=HtmlTable(), labels=labels)
    regtable(simpleregs...;file=joinpath("output",regdir,"actnow-simple-$(policy)-$(prefix)-ols.html"),number_regressions=true, stat_below=true,  below_statistic = ConfInt, render=HtmlTable(), labels=labels)
    regtable(very_simpleregs...;file=joinpath("output",regdir,"actnow-very-simple-$(policy)-$(prefix)-ols.html"),number_regressions=true, stat_below=true,  below_statistic = ConfInt, render=HtmlTable(), labels=labels)
    #
    # regression of change in popularity of each policy against each explanation
    #
    if do_changes 
        diffregs=[]
        depvar = Symbol( "$(policy)_change")
        reg = lm( @eval(@formula( $(depvar) ~ Gender + $(relgains) + $(relflourish) + $(relsec))), data )
        push!( diffregs, reg )
        for mainvar in MAIN_EXPLANVARS
            if mainvar in nms
                reg = lm( @eval(@formula( $(depvar) ~ Gender + $(relgains) + $(relflourish) + $(relsec) + $(mainvar))), data )
                push!( diffregs, reg )
            end
        end 
        diffregs2=[]
        reg = lm( @eval(@formula( $(depvar) ~ $(relgains) + $(relflourish) + $(relsec))), data )
        push!( diffregs2, reg )
        for mainvar in MAIN_EXPLANVARS
            if mainvar in nms
                reg = lm( @eval(@formula( $(depvar) ~ $(relgains) + $(relflourish) + $(relsec) + $(mainvar))), data )
                push!( diffregs2, reg )
            end
        end 
        regtable(diffregs...;file=joinpath("output",regdir,"actnow-change-$(policy)-$(prefix)-ols.html"),number_regressions=true, stat_below=true,  below_statistic = ConfInt, render = HtmlTable(), labels=labels)
        regtable(diffregs2...;file=joinpath("output",regdir,"actnow-change-sexless-$(policy)-$(prefix)-ols.html"),number_regressions=true, stat_below=true,  below_statistic = ConfInt, render = HtmlTable(), labels=labels)
    end
    #
    #= ascii and latex versions of these - not needed 
    regtable(regs...;file="output/regressions/actnow-$(policy)-ols.txt",number_regressions=false, stat_below=true, render=AsciiTable(), labels=labels)
    regtable(simpleregs...;file="output/regressions/actnow-simple-$(policy)-ols.txt",number_regressions=true, stat_below=true,  below_statistic = ConfInt, render=AsciiTable(), labels=labels)
    regtable(very_simpleregs...;file="output/regressions/actnow-very-simple-$(policy)-ols.txt",number_regressions=true, stat_below=true,  below_statistic = ConfInt, render=AsciiTable(), labels=labels)
    regtable(diffregs...;file="output/regressions/actnow-change-$(policy)-ols.txt",number_regressions=true, stat_below=true,  below_statistic = ConfInt, render=AsciiTable(), labels=labels)
    regtable(diffregs2...;file="output/regressions/actnow-change-$(policy)-sexless-ols.txt",number_regressions=true, stat_below=true,  below_statistic = ConfInt, render=AsciiTable(), labels=labels)
    #    
    regtable(regs...;file="output/regressions/actnow-$(policy)-ols.tex",number_regressions=true, stat_below=true,  below_statistic = ConfInt, render=LatexTable(), labels=labels)
    regtable(simpleregs...;file="output/regressions/actnow-simple-$(policy)-ols.tex",number_regressions=true, stat_below=true,  below_statistic = ConfInt, render=LatexTable(), labels=labels)
    regtable(very_simpleregs...;file="output/regressions/actnow-very-simple-$(policy)-ols.tex",number_regressions=true, stat_below=true,  below_statistic = ConfInt, render=LatexTable(), labels=labels)
    regtable(diffregs...;file="output/regressions/actnow-change-$(policy)-ols.tex",number_regressions=true, stat_below=true,  below_statistic = ConfInt, render=LatexTable(), labels=labels)
    regtable(diffregs2...;file="output/regressions/actnow-change-sexless-$(policy)-ols.tex",number_regressions=true, stat_below=true,  below_statistic = ConfInt, render=LatexTable(), labels=labels)
    =#
end # run_regressions_by_policy

function edit_table( io, tablename )
    lines = readlines(tablename)
    table = lines[15:end]
    insert!(table, 1, "<table class='table table-sm table-striped  table-responsive'>")
    for t in table
        t = replace(t, r"<td .*?style=.*?>(.*?)</td>" => s"<th>\1</th>")
        println( io, t)
    end
end

"""

Creates `all_results_by_explanvar.html` with most results broken
down by risk of destitution, health, life ladder, etc.
-See `MAIN_EXPLANDICT` for the whole list.

"""
function make_big_file_by_explanvar(
    ; 
    regdir="regressions",
    prefix :: String,
    out_file_name="all_results_by_explanvar")

    io = open( joinpath("output","$(out_file_name)-$(prefix).html"), "w")
    header = """
    <!DOCTYPE html>
    <html>
    <title>Act Now Main Regression Library</title>
    <link rel="stylesheet" href="css/bisite-bootstrap.css"/>
    <body class='text-primary p-2'>
    <h1>Act Now Main Regression Library</h1>
    """
    footer = """
    <footer>

    </footer>
    </body>
    </html>
    """
    println(io, header)

    for (mainvar,exvar) in MAIN_EXPLANDICT
        # exvar = MAIN_EXPLANDICT[Symbol(mainvar)]
        notes1 = """
        <p>
        Results are relative to:
        </p>
        <ul>
            <li>vote next election: Conservative;</li>
            <li>Not Working;</li>
            <li>Female;</li>
            <li><strong>Not</strong> $exvar</li>
        </ul>
        """
        notes2 = """
        Results are Relative to:
        <ul>
            <li>Shown Absolute Gains Argument;</li>
            <li><strong>Not</strong> $exvar.</li>
        </ul>
        """    
        println( io, "<section>")
        println( io, "<h2>Regressions - Main Explanatory Variable: $exvar </h2>")
        println( io, "<h3>Popularity of Each Policy: 1) Full Regression</h3>")
        fn = joinpath("output",regdir,"actnow-$(mainvar)-$(prefix)-ols.html")
        edit_table( io, fn )
        println( io, notes1 )
        #
        println( io, "<h3>Popularity of Each Policy: 2): Short Regressions</h3>")
        fn = joinpath("output",regdir,"actnow-simple-$(mainvar)-$(prefix)-ols.html")
        edit_table( io, fn )
        # 
        println( io, "<h3>Change in Popularity Of Each Policy: By Argument</h3>")
        fn = joinpath("output",regdir,"actnow-change-$(mainvar)-$(prefix)-ols.html")
        edit_table( io, fn )    
        println(io, notes2 )    
        println( io, "</section>")
    end
    println(io, "<section>")
    println( io, "<h3>Image Gallery</h3>")
    lines = readlines("output/image-index.html")
    for l in lines
        println( io, l )
    end
    println(io,"</section>")
    println( io, footer )
    close(io)
end

"""

Makes `output/all_results_by_policy.html`, a big file summarising
main wave 4 results, organised by each policy area.

`run_regressions()` and `make_and_print_summarystats()` need to
have been run beforehand and the `output` directory filled with regressiona
and graph files. 

"""
function make_big_file_by_policy(
    ;
    regdir="regressions",
    prefix::String,
    out_file_name="all_results_by_policy")

    io = open( joinpath("output","$(out_file_name)-$(prefix).html"), "w")
    header = """
    <!DOCTYPE html>
    <html>
    <title>Act Now Main Regression Library</title>
    <link rel="stylesheet" href="css/bisite-bootstrap.css"/>
    <body class='text-primary p-2'>
    <h1>Act Now Main Regression Library</h1>
    <p>
    These are .. 
    </p>
    <p>
    NOTE: The summary statistics use weighted data. Regressions use unweighted data.
    </p>
    <h3>Contents</h3>
    <ul>
        <li><a href='#summary'>Summary Statistics</a>
        <li><a href='#regressions'>Regressions</a>
        <li><a href='#chart-gallery'>Charts of Popularity of each policy</a>
    </ul>
    """
    footer = """
    <footer>

    </footer>
    </body>
    </html>
    """
    println(io, header)

    println(io, "<section id='summary'>")
    println( io, "<h2>Summary Statistics</h2>")
    lines = readlines("output/summary_stats.html")
    for l in lines
        println( io, l )
    end
    println(io,"</section'>")
    println(io, "<h2 id='regressions'>Regressions: by Policy</h2>")
    for policy in POLICIES 
        prettypol = lpretty( policy )
        exvar = prettypol * " (Before Explanation)"
        # exvar = MAIN_EXPLANDICT[Symbol(mainvar)]
        notes1 = """
        <p>p- values in parenthesis.
        Results are relative to:
        </p>
        <ul>
            <li>vote next election: Conservative;</li>
            <li>Not Working;</li>
            <li>Female;</li>
            <li>Main explanatory variable (last variable in each regression)<strong>False</strong></li>
        </ul>
        """
        notes2 = """
        <p>p- values in parenthesis. 
        Results are Relative to:
        <ul>
            <li>Shown Absolute Gains Argument;</li>
            <li>Main explanatory variable (last variable in each regression)<strong>False</strong></li>
        </ul>
        """    
        println( io, "<section>")
        println( io, "<h2>Regressions - Policy: $exvar </h2>")
        println( io, "<h3>Popularity of $prettypol: 1) Full Regression</h3>")
        fn = joinpath("output",regdir,"actnow-$(policy)-$(prefix)-ols.html")
        edit_table( io, fn )
        println( io, notes1 )
        #
        println( io, "<h3>Popularity of $prettypol: 2): Short Regressions</h3>")
        fn = joinpath("output",regdir,"actnow-simple-$(policy)-$(prefix)-ols.html")
        edit_table( io, fn )
        #
        println( io, "<h3>Popularity of $prettypol: 3): Very Short Regressions</h3>")
        fn = joinpath("output",regdir,"actnow-very-simple-$(policy)-$(prefix)-ols.html")
        edit_table( io, fn )
        #
        println( io, "<h3>Change in Popularity of $prettypol: By Argument</h3>")
        fn = joinpath("output",regdir,"actnow-change-$(policy)-$(prefix)-ols.html")
        edit_table( io, fn )    
        println(io, notes2 )    
        println( io, "<h3>Change in Popularity of $prettypol: Genderless By Argument</h3>")
        fn = joinpath("output",regdir,"actnow-change-sexless-$(policy)-$(prefix)-ols.html")
        edit_table( io, fn )    
        println(io, notes2 )    
        println( io, "</section>")
    end
    println(io, "<section id='chart-gallery'>")
    println( io, "<h2>Image Gallery</h2>")
    lines = readlines("output/image-index.html")
    for l in lines
        println( io, l )
    end
    println(io,"</section>")
    println( io, footer )
    close(io)
end


"""
Draw our scatter plots with the parties colo[u]red in.
"""
function draw_pol_scat( scatter, title )
    axis = (width = 1200, height = 800, title=title)
    return draw(scatter, 
        scales( Color=(; palette=[:blue,:red,:orange,:green,:grey,:purple] )),
        axis=axis, 
        legend=(; title="Party Vote Last Election"))
end

function draw_density( density, title )
    axis = (width = 1200, height = 800, title=title)
    return draw(density; axis=axis )
end

"""
Drawing all our charts using the marginally less mad AlgebraOfGraphics lib.
"""
function draw_policies2( df::DataFrame, pol1 :: Symbol, pol2 :: Symbol ) :: Tuple
    policy1 = Symbol("$(pol1)_pre")
    policy2 = Symbol("$(pol2)_pre")
    label1 = "Preference for "*lpretty( pol1 )
    label2 = "Preference for "*lpretty( pol2 )
    title = "$(label1) vs $(label2) (before treatment)"
    vote_label = "Voting Intention (January 2024)"
    # FIXME some neat way of doing this with mapping
    # pol_w = Symbol("$(pol)_weighted")
    # df[:,pol_w] = df[:,policy] .* df.weight
    ddf = data(df)
    
    spec1 = ddf * 
        mapping( 
            policy1=>label1, #:democracy_pre=>"Preference for Democratic Reform",
            policy2=>label2 ) * 
        mapping(  color=:next_election=>vote_label) *
        visual(Scatter)
    spec2 = ddf * 
        mapping( 
            policy1=>label1, #:democracy_pre=>"Democracy",
            policy2=>label2 ) * 
        mapping(  color=:next_election=>vote_label) *
        (visual(Scatter) + linear(interval = nothing)) # interval = nothing 

    spec3 = ddf * 
        mapping( 
            policy1=>label1, #:democracy_pre=>"Democracy",
            policy2=>label2 ) * 
        mapping( layout=:next_election=>vote_label) *
        mapping( color=:next_election=>vote_label) * 
        (linear() + visual(Scatter))

    s1 = draw_pol_scat( spec1, title )
    s2 = draw_pol_scat( spec2, title )
    s3 = draw_pol_scat( spec3, "" )
    f = Figure()
    s1,s2,s3 
end

"""
Draw our scatter plots with the parties colo[u]red in.
"""
function draw_change_scat( scatter, title )
    axis = (width = 1200, height = 800, title=title)
    return draw(scatter, 
        scales( Color=(; palette=[:firebrick4,:orangered3,:teal,:grey,:darkorchid4] )),
        axis=axis, 
        legend=(; title="Argument Presented"))
end

function draw_change_vs_score( df::DataFrame, pol :: Symbol ) :: Tuple
    # dall = df[df]
    policy = Symbol("$(pol)_change")
    treat = Symbol("$(pol)_which_treat_label")
    score = Symbol("$(pol)_overall_score")
    ppre = Symbol("$(pol)_pre")
    vpre = df[!,ppre]
    dall = df[ vpre .< 95, : ]

    label1 = "Change in Preference for "*lpretty( pol )
    label2 = "Rating of argument"
    title = "$(label1) vs $(label2) - Pre Scores of < 95 only"
    arg_label = "Which Argument"
    ddf = data(dall)
    spec1 = ddf * 
        mapping( 
            score=>label2,
            policy=>label1 ) * 
        mapping( color=treat=>arg_label) *
        visual(Scatter)
    spec2 = ddf * 
        mapping( 
            score=>label2,
            policy=>label1 ) * 
        mapping( color=treat=>arg_label) *
        (visual(Scatter) + linear(interval = nothing))
    spec3 = ddf * 
        mapping( 
            score=>label2,
            policy=>label1 ) * 
        mapping( layout=treat=>arg_label) *
        mapping( color=treat=>arg_label) * 
        (linear() + visual(Scatter))

    s1 = draw_change_scat( spec1, title )
    s2 = draw_change_scat( spec2, title )
    s3 = draw_change_scat( spec3, title )
    s1,s2,s3
end

"""

Make a bunch of scatterplots for each policy - see `draw_policies2`
Written to `output/img` as both `.svg` and `.png`

"""
function make_all_graphs( dall::DataFrame )
    io = open( "output/image-index.html","w")
    for p1 in POLICIES 
        println( io, "<section>")
        pp1 = lpretty( p1 )
        println( io, "<h3>$pp1</h3>" )
        println( io, "<table class='table'>")
        println( io, "<thead></thead><tbody>")
        for p2 in POLICIES 
            pp2 = lpretty( p2 )
            if p1 !== p2 
                cp1,cp2,cp3 = draw_policies2( dall, p1, p2 )
                save( "output/img/actnow-$(p1)-$(p2)-scatter.svg", cp1 )
                save( "output/img/actnow-$(p1)-$(p2)-scatter-linear.svg", cp2 )
                save( "output/img/actnow-$(p1)-$(p2)-facet.svg", cp3 )
                save( "output/img/actnow-$(p1)-$(p2)-scatter.png", cp1 )
                save( "output/img/actnow-$(p1)-$(p2)-scatter-linear.png", cp2 )
                save( "output/img/actnow-$(p1)-$(p2)-facet.png", cp3 )
                println( io, "<tr><th>Vs: $pp2</th>")
                println( io, "<td><img src='img/actnow-$(p1)-$(p2)-scatter.svg' width='300' height='300' class='img-thumbnail' alt='...'/></td>")
                println( io, "<td>Combined Scatter Plot</td><td><a href='img/actnow-$(p1)-$(p2)-scatter.png'>PNG</a><td><a href='img/actnow-$(p1)-$(p2)-scatter.svg'>SVG</a> </td>")
                println( io, "<td>Combined Scatter Plot With Regressions</td><td><a href='img/actnow-$(p1)-$(p2)-scatter-linear.png'>PNG</a></td><td><a href='img/actnow-$(p1)-$(p2)-scatter-linear.svg'>SVG</a></td>")
                println( io, "<td>Facet Plot With Regression Lines</a></td><td><a href='img/actnow-$(p1)-$(p2)-facet.png'>PNG</a></td><td><a href='img/actnow-$(p1)-$(p2)-facet.svg'>SVG</a></td>")
                println( io, "</tr>")
            end
            println( io, "</tr>")
        end
        println( io, "</tbody></table>")
        println( io, "</section>")
    end
    for p1 in POLICIES 
        println( io, "<section>")
        pp1 = lpretty( p1 )
        println( io, "<h3>Change in Score vs Rating of Argument $pp1</h3>" )
        println( io, "<table class='table'>")
        println( io, "<thead></thead><tbody>")
        cp1,cp2,cp3 = draw_change_vs_score( dall, p1 )
        save( "output/img/actnow-change-$(p1)-scatter.svg", cp1 )
        save( "output/img/actnow-change-$(p1)-scatter-linear.svg", cp2 )
        save( "output/img/actnow-change-$(p1)-facet.svg", cp3 )
        save( "output/img/actnow-change-$(p1)-scatter.png", cp1 )
        save( "output/img/actnow-change-$(p1)-scatter-linear.png", cp2 )
        save( "output/img/actnow-change-$(p1)-facet.png", cp3 )
        println( io, "<td><img src='img/actnow-change-$(p1)-scatter.svg' width='300' height='300' class='img-thumbnail' alt='...'/></td>")
        println( io, "<td>Combined Scatter Plot</td><td><a href='img/actnow-change-$(p1)-scatter.png'>PNG</a><td><a href='img/actnow-$(p1)-scatter.svg'>SVG</a> </td>")
        println( io, "<td>Combined Scatter Plot With Regressions</td><td><a href='img/actnow-change-$(p1)-scatter-linear.png'>PNG</a></td><td><a href='img/actnow-change-$(p1)-scatter-linear.svg'>SVG</a></td>")
        println( io, "<td>Facet Plot With Regression Lines</a></td><td><a href='img/actnow-change-$(p1)-facet.png'>PNG</a></td><td><a href='img/actnow-change-$(p1)-facet.svg'>SVG</a></td>")
        println( io, "</tr>")
        println( io, "</tbody></table>")
        println( io, "</section>")
    end
    close(io)
end

"""
Run an absurd number of regressions. 

*
* 
*  exclude_0s_and_100s

"""
function run_regressions( dall :: DataFrame;
    regdir = "regressions",
    exclude_0s_and_100s :: Bool  )

    run_regressions_by_mainvar( dall, :x;  exclude_0s_and_100s = exclude_0s_and_100s )
    for mainvar in MAIN_EXPLANVARS
        println( "on mainvar $mainvar")
        run_regressions_by_mainvar( 
            dall, 
            mainvar; 
            regdir=regdir, 
            exclude_0s_and_100s = exclude_0s_and_100s )
    end

    for policy in POLICIES
        println( "on policy $policy")
        run_regressions_by_policy( dall, policy; regdir=regdir, exclude_0s_and_100s = exclude_0s_and_100s )
    end
end


function score_summarystats( dall :: DataFrame, policies, treatments = TREATMENT_TYPES ) :: DataFrame
    n = length( policies )*3
    df = DataFrame(
        name = fill("",n),
        subname = fill("",n))
    for t in treatments
        ak = Symbol( "$(t)_mean")
        mk = Symbol( "$(t)_median")
        df[!,ak] = zeros(n)
        df[!,mk] = zeros(n)
    end
    #=
        relgains_mean ,
        relgains_median = zeros(n),
        security_mean= zeros(n),
        security_median = zeros(n),
        absgains_mean= zeros(n),
        absgains_median = zeros(n),
        other_argument_mean= zeros(n),
        other_argument_median = zeros(n))
    =#
    i = 0
    for p in policies
        for group in ["All","Lovers","Haters"]
            i += 1
            ppre = Symbol("$(p)_pre")
            vpre = dall[!,ppre]
            ppost = Symbol("$(p)_post")
            vpost = dall[!,ppost]                
            dallg = if group == "All"
                dall
            elseif group == "Lovers"
                dall[vpre .> 70, : ]
            elseif group == "Haters"
                dall[vpre .< 30, : ]
            end
            for t in treatments
                k = Symbol( "$(p)_treat_$(t)_score" ) # e.g. :basic_income_treat_absgains_score
                subd = dallg[ .! ismissing.(dallg[!,k]),[k,:probability_weight]] # e.g. just those reporting a score for politics, absgains argument, and so on
                subd.probability_weight = ProbabilityWeights( subd.probability_weight )
                a = mean( subd[!,k], subd.probability_weight )
                println( "$k = a=$a")
                m = median( Float64.(subd[!,k]), subd.probability_weight )
                println( "m = $m")
                ak = Symbol( "$(t)_mean")
                mk = Symbol( "$(t)_median")
                df[i,:name] = lpretty(p) 
                df[i,:subname] = group
                df[i,ak] = a
                df[i,mk] = m
            end
        end
    end
    rename!( df, lpretty.( names( df )))
    df
end

"""
Make a pile of summary statistics and histograms
"""
function make_summarystats( dall :: DataFrame, policies = POLICIES, treatments = TREATMENTS ) :: NamedTuple
    n = 100
    # haters - scoring pre below 30; lovers scoring over 70 pre
    df = DataFrame( 
        name = fill("",n), 
        mean_pre=zeros(n), 
        median_pre=zeros(n), 
        std = zeros(n),
        mean_post=zeros(n), 
        median_post=zeros(n), 

        average_change = zeros(n),
        overall_p = zeros(n),

        avlove_pre = zeros(n),
        avhate_pre = zeros(n),

        nlovers_pre = zeros(n),
        nhaters_pre = zeros(n),

        nlovers_post = zeros(n),
        nhaters_post = zeros(n),

        avlove_post = zeros(n),
        avhate_post = zeros(n),
        
        change_amongst_lovers = zeros(n),
        lovers_p = zeros(n),
        change_amongst_haters = zeros(n),
        haters_p = zeros(n),
        nzeros_pre = zeros(n),
        nhundreds_pre = zeros(n),
        nzeros_post = zeros(n),
        nhundreds_post = zeros(n))
    i = 0
    w = ProbabilityWeights(dall.probability_weight)
    plots = Dict()
    hists = Dict()
    algdata = AlgebraOfGraphics.data(dall)
    for p in policies # add an overall col 
        i += 1
        ppost = Symbol("$(p)_post")
        vpost = dall[!,ppost]                
        # no 'pre' for the overall score, so... 
        df.nhundreds_post[i] = sum( dall[vpost .== 100,:probability_weight])*100
        df.nzeros_post[i] = sum( dall[vpost .== 0,:probability_weight])*100

        haters_post = dall[vpost .< 30, : ] 
        lovers_post = dall[vpost .> 70, : ]
        nhaters_post = sum( haters_post.probability_weight )*100
        nlovers_post = sum( lovers_post.probability_weight )*100

        #=
        println( "plotting $p")
        hsp = AlgebraOfGraphics.plot( hs )
        =# 
        df.name[i] = lpretty(p)
        # @show w vpre
        df.mean_post[i] = mean( vpost, w )        
        df.median_post[i] = median( vpost, w )

        ppre = Symbol("$(p)_pre")
        vpre = dall[!,ppre]
        df.std[i] = std( vpre, w )
        haters_pre = dall[vpre .< 30, : ]
        lovers_pre = dall[vpre .> 70, : ]
        nhaters_pre = sum( haters_pre.probability_weight )*100
        nlovers_pre = sum( lovers_pre.probability_weight )*100
        # 
        # change in love/hate among the top 30/bottom 30 of those who loved/hated pre
        # so the post columns from the pre-sub
        avlove_post = 100*sum( lovers_pre[!,ppost] .* lovers_pre.probability_weight ) / nlovers_pre
        avhate_post = 100*sum( haters_pre[!,ppost] .* haters_pre.probability_weight ) / nhaters_pre
        avlove_pre = 100*sum( lovers_pre[!,ppre] .* lovers_pre.probability_weight ) / nlovers_pre
        avhate_pre = 100*sum( haters_pre[!,ppre] .* haters_pre.probability_weight ) / nhaters_pre        
        df.nhundreds_pre[i] = sum( dall[vpre .== 100,:probability_weight])*100
        df.nzeros_pre[i] = sum( dall[vpre .== 0,:probability_weight])*100
        df.mean_pre[i] = mean( vpre, w )
        df.median_pre[i] = median( vpre, w )
        df.avlove_pre[i] = avlove_pre
        df.avhate_pre[i] = avhate_pre
        df.nhaters_pre[i] = nhaters_pre
        df.nlovers_pre[i] = nlovers_pre
        df.change_amongst_lovers[i] = avlove_post - avlove_pre
        df.change_amongst_haters[i] = avhate_post - avhate_pre
        # OneSampleTTest
        df.overall_p[i] = # ConfInt(
            pvalue( EqualVarianceTTest( dall[ !, ppost ], dall[!, ppre ] )) # paired t-test
        df.lovers_p[i] = # ConfInt(
            pvalue(EqualVarianceTTest( lovers_pre[ !, ppost ], lovers_pre[!, ppre ] )) # paired t-test
        df.haters_p[i] = # ConfInt(
            pvalue(EqualVarianceTTest( haters_pre[ !, ppost ], haters_pre[!, ppre ] )) # paired t-test
        hs = fit(Histogram, vpre, w )
        hsp = AlgebraOfGraphics.plot( hs )
        hsp = algdata * 
            mapping(ppre,weights=:probability_weight) * 
            AlgebraOfGraphics.density() |> AlgebraOfGraphics.draw
        plots[p] = hsp
        hists[p] = hs
        df.avlove_post[i] = avlove_post
        df.avhate_post[i] = avhate_post
        df.nhaters_post[i] = nhaters_post
        df.nlovers_post[i] = nlovers_post
    end
    println( policies)
    df.average_change = df.mean_post - df.mean_pre
    #
    # hacked overall summary - set pre vars all to zero
    #
    df[df.name .== "Overall",
        [:nhundreds_pre,:nzeros_pre,:mean_pre,:median_pre,:avlove_pre,
        :avhate_pre, :nhaters_pre, :nlovers_pre, :average_change]] .= 0.0
    discretevars = []
    non_discretevars = []
    nms = intersect( SUMMARY_VARS, names(dall))
    for p in nms
        sp = Symbol(p)
        v = dall[!,sp]
        if eltype( v ) <: Number
            push!( non_discretevars, p )
            i += 1
            hs = fit(Histogram, v, w )
            hsp = plot( hs )
            plots[p] = hsp
            hists[p] = hs
            df.name[i] = lpretty(p)
            df.mean_pre[i] = mean( v, w )
            df.median_pre[i] = median( v, w )
            df.std[i] = std( v, w )
        else
            push!( discretevars, p )
            c = countmap( v, w )
            hists[p] = c
            barc = data( dall ) * frequency() * mapping(Symbol(p) => lpretty(p))
            plots[p] = draw(barc)
        end
    end
    correlations, pvals, degrees_of_freedom = corrmatrix( dall, policies )
    scores = score_summarystats( dall, policies, treatments )
    (; summarystats = df[1:i,:], plots, hists, correlations, discretevars, non_discretevars, pvals, degrees_of_freedom, scores )
end

"""

"""
function make_and_print_summarystats( dall :: DataFrame )
    d = make_summarystats( dall, vcat(POLICIES,:overall) )
    io = open( "output/summary_stats.html", "w")
    println( io, "<h3>Summary Statistics</h3>")
    t = pretty_table( 
        io,
        d.summarystats; 
        formatters=( pform, form ), 
        header = ( [
            "Variable",
            "Mean (Before)",
            "Median (Before)",
            "Standard Deviation (Before)",
            "Mean (After)",
            "Median (After)",
            "Average Change In Score",   
            "(p)", 
            "Policy Lovers (Before Score Over 70): Av Score",        
            "Policy Haters (Before Score Under 30): Av Score",        
            "Lovers - % (Before)",
            "Haters - % (Before)",
            "Lovers - % (After)",
            "Haters - % (After)",
            "Lovers Average Score (After)",
            "Haters Average Score (After)",
            "Lovers - Average Change in Score",
            "(p)", 
            "Haters - Average Change in Score",
            "(p)",
            "0 scores % (Before)",
            "100 scores % (Before)",
            "0 scores % (After)",
            "100 scores % (After)"] ),
        table_class="table table-sm table-striped table-responsive", 
        backend = Val(:html))
    println( io, "<p><em>Note - p-values are for difference in pre-post mean scores - pairwise tests give smaller p- values.</em></p>")    
    #=
    ,
    "Principal Component #1 (PC1)",
    "PC2",
    "PC3"
    =#
    println( io, "<h3>Scores for Each Policy Argument</h3>")    
    t = pretty_table( 
        io,
        d.scores; 
        formatters=( form ), 
        table_class="table table-sm table-striped  table-responsive", 
        backend = Val(:html))
    #
    println( io, "<h3>Correlations between Popularity of Policies</h3>")    
    t = pretty_table( 
        io,
        d.correlations; 
        header = (["Basic Income","Green New Deal", "Utilities", "Health", "Childcare", "Education", "Housing", "Transport", "Democracy", "Tax", ""]),
        formatters=( form ), 
        table_class="table table-sm table-striped  table-responsive", 
        backend = Val(:html))
    println( io, "<h3>P-Values for The Correlations</h3>")
    t = pretty_table( 
        io,
        d.pvals; 
        header = (["Basic Income","Green New Deal", "Utilities", "Health", "Childcare", "Education", "Housing", "Transport", "Democracy", "Tax", ""]),
        formatters=( form ), 
        table_class="table table-sm table-striped  table-responsive", 
        backend = Val(:html))
    println( io, "<p>Correlation Degrees of Freedom: (just sample size - 2) <b>$(d.degrees_of_freedom)</b></p>")
    println( io, "<div class='row border border-primary'>")
    c = 0
    for v in d.discretevars 
        c += 1
        pv = lpretty(v)
        println( io, "<div class='col p-2 border border-2'>")
        println( io, "<h4>$pv</h4>")
        
        t = pretty_table( 
            io,
            d.hists[v],
            formatters=( form ), 
            sortkeys=true,
            header = ( ["","Proportion"]),
            table_class="table table-sm table-striped table-responsive",
            backend = Val(:html))
        println( io, "</div>")
        if c == 3
            c = 0
            println( io, "</div>")
            println( io, "<div class='row'>")
        end
    end 
   
    println( io, "</div>")
    c = 0
    println( io, "<div class='row border border-primary'>")
    for v in d.non_discretevars
        c += 1
        pv = lpretty(v)
        println( io, "<div class='col p-2  border border-2'>")
        println( io, "<h4>$pv</h4>")
        fname = "output/img/actnow-$(v)-bar.svg"
        save( fname, d.plots[v] )
        fname = "img/actnow-$(v)-bar.svg"
        println( io, "<p><img src='$fname'/><p>")
        println( io, "</div>")
        if c == 3
            c = 0
            println( io, "</div>")
            println( io, "<div class='row'>")
        end
    end
    println( io, "</div>")    
    close( io )
end # make and print summarystats

"""
dall - 
extension - pre or post
normalise - 
"""
function policies_as_matrix( dall :: DataFrame, extension::String; normalise=true )::Matrix
    # FIXME next 2 are dups
    pol = Symbol.(string.(POLICIES) .* extension ) #"_pre")
    println( "pol=$(pol) ")
    n = length(pol)
    d = Matrix{Float64}( dall[!,pol] )'
    # normalize
    for i in 1:n
        m = mean(d[i,:])
        s = std(d[i,:])
        if normalise 
            d[i,:] = (d[i,:] .- m)/s
            @assert isapprox(sum(d[i,:]), 0.0, atol=0.00001) "sum is $(sum(d[i,:]))"
            @assert std(d[i,:]) ≈ 1.0  "std is $(std(d[i,:]))"
        end
    end
    d 
end

"""
See: https://juliastats.org/MultivariateStats.jl/dev/pca/#Linear-Principal-Component-Analysis
See: https://www.youtube.com/watch?v=FgakZw6K1QQ
"""
function do_basic_pca_w( dall :: DataFrame; extension::String, maxoutdim = 3 )::Tuple
    data =policies_as_matrix( dall, extension )
    M = fit(PCA, data; maxoutdim=maxoutdim)
    prediction = DataFrame( predict(M,data)',["PC1$(extension)","PC2$(extension)","PC3$(extension)"])
    M, data, prediction
end

function do_basic_pca( dall :: DataFrame )::Tuple
    MPre, data_pre, prediction_pre =  do_basic_pca_w( dall; extension="_pre" )
    M_change, data_change, prediction_change =  do_basic_pca_w( dall; extension="_change" )
    MPre, data_pre, prediction_pre, M_change, data_change, prediction_change
end

function one_pca( dall :: DataFrame, which :: Symbol, colours :: Dict, extension::String )
    f = Figure(fontsize=12, size = (640, 640))
    ax = Axis3(f[1,1],xlabel="PC1",ylabel="PC2", zlabel="PC3", title=pretty( string(which)))
    for (k, colour) in colours
        # hack for Bools 
        label = if k === false
             "No"
        elseif k === true
            "Yes"
        else 
            pretty("$k")
        end
        k1 = Symbol( "PC1$(extension)")
        k2 = Symbol( "PC2$(extension)")
        k3 = Symbol( "PC3$(extension)")
        println( "k1=$k1 k2=$k2 k3=$k3")
        subset = dall[dall[!,which] .== k,[k1,k2,k3]]
        sc = scatter!( 
            ax, 
            subset[!,k1], 
            subset[!,k2], 
            subset[!,k3];
            label=label,
            markersize=5,
            color=colour)
    end
    Legend(f[1,2], ax )
    f
end

function make_pca_graphs( dall :: DataFrame, extension::String )
    graphs = Dict()
    graphs[:last_election] = one_pca(dall,:last_election,POL_MAP, extension)
    graphs[:Owner_Occupier] = one_pca(dall,:Owner_Occupier,BOOL_MAP, extension)
    graphs[:Gender] = one_pca(dall,:Gender, GENDER_MAP, extension)
    graphs[:ethnic_2] = one_pca(dall,:ethnic_2, ETHNIC_MAP, extension )
    graphs[:destitute] = one_pca(dall,:destitute,BOOL_MAP_2, extension)
    graphs[:not_managing_financially] = one_pca(dall,:not_managing_financially,BOOL_MAP_2, extension)
    graphs
end

#=
The Kaiser–Meyer–Olkin test.

From the ever-reliable Wikipedia: https://en.wikipedia.org/wiki/Kaiser%E2%80%93Meyer%E2%80%93Olkin_test

m : A matrix with the variables are in the rows and obs in the cols.
=#
function kmo_test( m :: AbstractMatrix )

    function parcor( i::Int, j::Int, first::Int, last::Int )::AbstractFloat
        # matrix indexes not = i or j
        not_i_or_j = filter( k -> ! (k in [i,j]), first:last )
        return partialcor( m[i,:], m[j,:], m[not_i_or_j,:]')
    end
    ps = 0.0
    cs = 0.0
    # The m[:,begin] bits are just sillyness for non 1-based arrays.
    first = firstindex(m[:,begin])
    last = lastindex( m[:,begin])
    for i in eachindex(m[:,first])
        for j in eachindex(m[:,first])
            if i != j
                ps += parcor( i, j, first, last )^2
                cs += cor( m[i,:], m[j,:])^2
            end
        end
    end
    return cs / (ps+cs)
end
#
function make_pc_crosstabs( dall::DataFrame, extension::String )::Dict
    cts = Dict()
    k1 = Symbol( "PC1$(extension)")
    k2 = Symbol( "PC2$(extension)")
    k3 = Symbol( "PC3$(extension)")
    for col in PCA_BREAKDOWNS
        gd = groupby( dall, col )
        ct = combine( gd,
            nrow,
            proprow,
            (k1=>mean),
            (k1=>std),
            (k2=>mean),
            (k2=>std),
            (k3=>mean),
            (k3=>std)) 
        cts[col] = ct
    end
    cts
end

function screeplot( xdata :: AbstractMatrix )  
    M = fit(PCA, xdata; maxoutdim=10)
    eigs = eigvals(M)
    f = Figure(fontsize=12, size = (640, 480))
    ax = Axis(f[1,1], xlabel="Factor",ylabel="Eigenvalue", title="Scree Plot")
    lines!( ax, eigs )
    f
end

"""
Summary of one of our Principal Components

- `dall` - wave3 or 4 dataset (always 4 in practice)
- M - output from one PCA analysys (?? type ??)
- extension - one of '_pre' or '_change' 
- regdir - where to save regressions 

"""
function summarise_pca( 
    dall :: DataFrame, 
    M, 
    extension :: String,
    regdir="regressions" )
    crosstabs = make_pc_crosstabs( dall, extension )
    graphs = make_pca_graphs( dall, extension )
    # pca_text = read("output/pca$(extension).md", String)
    xdata = policies_as_matrix( dall, extension )
    kmo = fmt(kmo_test( xdata ))
    scp = screeplot( xdata )
    save( "output/img/scree-plot$(extension).svg", scp )
    save( "output/img/scree-plot$(extension).png", scp )
    loads = loadings(M)
    # reverse the sign of the 1st set of loads to match
    # what Julia prints - no idea whatsoever.
    loads[:,1] .= loads[:,1] .* -1
    pcf = DataFrame( names=pretty.( string.(POLICIES)),
        PC1=loads[:,1],
        PC2=loads[:,2],
        PC3=loads[:,3])
    depvar = Symbol( "PC1$(extension)")
    regs = []
    push!( regs, lm( @eval( @formula( $depvar ~ At_Risk_of_Destitution)), dall ))
    push!( regs, lm( @eval( @formula( $depvar ~ Satisfied_With_Income)), dall ))
    for mainvar in MAIN_EXPLANVARS
        reg = lm( @eval(@formula( $(depvar) ~ 
            Age + next_election + ethnic_2 + employment_2 + 
            log(HH_Net_Income_PA) + is_redwall + Gender + 
            $(mainvar))), dall )
        push!( regs, reg )
    end 
    
    regtable(
        regs...;
        file=joinpath("output",regdir,"pca-1$(extension).html"),
        number_regressions=true, 
        stat_below=true,  
        below_statistic = ConfInt, 
        render=HtmlTable())
    regstr = read(joinpath("output",regdir,"pca-1$(extension).html"), String)

    open("output/pca$(extension).md", "w") do io
        println( io, "# Act Now: Initial Principal Component Attempt")
        println( io, "Kaiser-Meyer-Olkin (KMO) test: $kmo\n")
        # println(io, pca_text)
        println(io, "![Scree Plot](img/scree-plot$(extension).png)")
        println(io, "## Loadings\n");
        pretty_table(io, pcf, formatters=( form ), 
                backend = Val(:markdown))
        for col in PCA_BREAKDOWNS
            s = pretty(string(col))
            picname = "$(col)$(extension)-pca"
            save( "output/img/$(picname).svg", graphs[col])
            save( "output/img/$(picname).png", graphs[col])
            println( io, "\n\n## Principal Component Breakdown: by $s\n")
            pretty_table(io, 
                crosstabs[col], 
                formatters=( form ), 
                backend = Val(:markdown),
                header = [
                    "",
                    "N (unweighted)",
                    "proportion",
                    "1st Principal Component (PC): mean",
                    "1st PC: std. dev",
                    "2nd PC: mean",
                    "2nd PC: std. dev",
                    "3rd PC: mean",
                    "3rd PC: std. dev"
                ])
            println(io, "\n ![Graph of Principal Components Of $s](img/$(picname).png)")
        end # each breakdown 
        println( io, regstr )
    end # file open
end


function load_dall_v4()::Tuple
    dall = CSV.File( joinpath( DATA_DIR, "wave-4-national-w-created-vars.tab")) |> DataFrame 
    #
    # Cast weights to StatsBase weights type.
    #
    dall.weight = Weights(dall.weight)
    dall.probability_weight = ProbabilityWeights(dall.weight./sum(dall.weight))
    # factor cols
    M_pre, data_pre, prediction_pre, M_change, data_change, prediction_change = do_basic_pca(dall)
    dall = hcat( dall, prediction_pre, prediction_change; makeunique=true )
    dall, M_pre, data_pre, prediction_pre, M_change, data_change, prediction_change
end
