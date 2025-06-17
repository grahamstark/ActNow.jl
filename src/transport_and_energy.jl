
using ActNow,DataFrames,CSV,StatsBase,PrettyTables,CairoMakie

const DD = "/mnt/data/ActNow/Surveys/v2/"


RENAMES_ENERGY = Dict([
    #=
    Q1.1_1
    Q1.1_2
    Q1.1_3
    =#
    "Q3.1"=>"Prolific_Id",
    #=
    C1
    C2
    C3
    C4
    C5
    C6
    C7
    C8
    C9
    C10
    C11
    C12
    C13
    C14
    C15
    =#
    "Q6.1_4"=>"Public_Ownership_Pre",
    "Q7.1_4"=>"Argument_Agreement",
    "Q7.2_4"=>"Public_Ownership_Post",
    "Q8.2"=>"Age",
    "Q8.3"=>"Gender",
    "Q8.3_3_TEXT"=>"Gender_Other",
    "Q8.4"=>"Ethnic",
    "Q8.4_5_TEXT"=>"Ethnic_White_Other",
    "Q8.4_9_TEXT"=>"Ethnic_Mixed_Other",
    "Q8.4_14_TEXT"=>"Ethnic_Asian_Other",
    "Q8.4_17_TEXT"=>"Ethnic_Black_Other",
    "Q8.4_19_TEXT"=>"Ethnic_Other_Other",

    "Q8.5"=>"Postcode4",
    "Q8.6"=>"HH_Net_Income_PA",
    "Q8.7"=>"Employment_Status",
    "Q8.7_15_TEXT"=>"Employment_Status_Other",
    "Q8.8"=>"Owner_Occupier",
    "Q8.9_1"=>"At_Risk_of_Destitution",
    "Q8.10"=>"Managing_Financially",
    "Q8.11"=>"Satisfied_With_Income",
    "Q8.12"=>"Ladder",
    "Q8.13"=>"General_Health",
    "Q8.14"=>"General_Health_12_Months",
    "Q8.15"=>"ADLS_Reduced", # NEW
    "Q8.16"=>"Depressed",
    "Q8.17"=>"Anxious",
    "Q8.18_1"=>"Left_Right",
    "Q8.19"=>"Voting",
    "Q8.20"=>"Party_Last_Election",
    "Q8.20_7_TEXT"=>"Party_Last_Election_Other",
    "Q8.21"=>"Party_Next_Election",
    "Q8.21_7_TEXT"=>"Party_Next_Election_Other",
    "Q8.22_1"=>"Politicians_All_The_Same",
    "Q8.22_2"=>"Politics_Force_For_Good",
    "Q8.22_3"=>"Party_In_Government_Doesnt_Matter",
    "Q8.22_4"=>"Politicians_Dont_Care",
    "Q8.22_5"=>"Politicians_Want_To_Make_Things_Better",
    "Q8.22_6"=>"Shouldnt_Rely_On_Government",
    "Q9.1"=>"Feedback" ])

# rename!( energy, RENAMES_ENERGY )


RENAMES_TRANSPORT=([
    #=
    "Q6.1_4"=>"Transport_General_Pre",
    "Q7.1_4"=>"Absolute_Pre",
    "Q8.1_4"=>"Absolute_Argument",
    "Q9.1_4"=>"Relative_Pre",
    "Q10.1_4"=>"Relative_Argument",
    "Q11.1_4"=>"Security_Pre",
    "Q12.1_4"=>"Security_Argument",
    =#

    "Q13.2"=>"Age",
    "Q13.3"=>"Gender",
    "Q13.3_3_TEXT"=>"Gender_Other",
    "Q13.4"=>"Ethnic",
    "Q13.4_5_TEXT"=>"Ethnic_White_Other",
    "Q13.4_9_TEXT"=>"Ethnic_Mixed_Other",
    "Q13.4_14_TEXT"=>"Ethnic_Asian_Other",
    "Q13.4_17_TEXT"=>"Ethnic_Black_Other",
    "Q13.4_19_TEXT"=>"Ethnic_Other_Other",
    "Q13.5"=>"Postcode4",
    "Q13.6"=>"HH_Net_Income_PA",
    "Q13.7"=>"Employment_Status",
    "Q13.7_15_TEXT"=>"Employment_Status_Other",
    "Q13.8"=>"Owner_Occupier",
    "Q13.9_1"=>"At_Risk_of_Destitution",
    "Q13.10"=> "Managing_Financially",
    "Q13.11"=> "Satisfied_With_Income",
    "Q13.12" =>"Ladder",
    "Q13.13"=>"General_Health",
    "Q13.14"=>"General_Health_12_Months",    
    "Q13.15"=>"ADLS_Reduced", # NEW
    "Q13.16"=>"Little_interest_in_things",
    "Q13.17"=>"Anxious",
    "Q13.18_1"=>"Left_Right",
    "Q13.19"=>"Voting",
    "Q13.20"=>"Party_Last_Election",
    "Q13.20_7_TEXT"=>"Party_Last_Election_Other",
    "Q13.21"=>"Party_Mayoral_Election",
    "Q13.22_1"=>"Politicians_All_The_Same",
    "Q13.22_2"=>"Politics_Force_For_Good",
    "Q13.22_3"=>"Party_In_Government_Doesnt_Matter",
    "Q13.22_4"=>"Politicians_Dont_Care",
    "Q13.22_5"=>"Politicians_Want_To_Make_Things_Better",
    "Q13.22_6"=>"Shouldnt_Rely_On_Government",
    "Q14.1"=>"Feedback"])

"""
return 30 (most) .. 1 least 
"""
function i_build_trust( r :: DataFrameRow )::Int
    trust = 0
    for t in ActNow.TRUST_POL
        tl = r[t]
        @assert typeof( tl ) <: Integer "type not int $(typeof(tl)) col = $t"
        if t in ["Politics_Force_For_Good","Politicians_Want_To_Make_Things_Better"]
            tl = 5 - tl
        end
        trust += tl 
    end
    trust = 30-trust
    @assert trust in 1:30 "trust out of range $trust"
    return trust  # 24 (4x6) is most trusting ... 
end

# NOT USED
function i_health_score( p :: DataFrameRow, keys... )::Union{Int,Missing}

    function map_one( s :: AbstractString )::Int
        findfirst(x->x==s,DEPLEVELS) - 1 
    end

    i = 0
    for k in keys
        if ismissing(p[k])
            return missing
        end
        i += map_one( p[k])
    end
    return i
end

function recode_mayoral( party :: Integer; condensed :: Bool ) :: String
    d = if ismissing( party )
        ("No Vote/DK/Refused","Other")
    elseif party in [1] # ["Conservative Party"]
        ("Conservative", "Conservative")
    elseif party in [4] # ["Green Party", "Plaid Cymru", "Scottish National Party"]
        ("Nat/Green","Other")
    elseif party in [12] # ["Labour Party"]
        ("Labour","Labour")
    elseif party in [5] # ["Liberal Democrats"]
        ("LibDem","Other")
    elseif party in [2] # ["Other (please name below)", "Independent candidate","Brexit Party"]
        ("Other/Brexit","Other")
    elseif party in [3]
        ("Driscoll","Other")
    elseif party in [9,13,11,10] 
        ("No Vote/DK/Refused","Other")
    else
        @assert false "unassigned party $party"
    end
    return condensed ? d[2] : d[1]

end

"""
FIXME mess
"""
function recode_party( party :: Integer; condensed :: Bool ) :: String
    d = if ismissing( party )
        ("No Vote/DK/Refused","Other")
    elseif party in [2] # ["Conservative Party"]
        ("Conservative", "Conservative")
    elseif party in [11,3,12] # ["Green Party", "Plaid Cymru", "Scottish National Party"]
        ("Nat/Green","Other")
    elseif party in [4] # ["Labour Party"]
        ("Labour","Labour")
    elseif party in [5] # ["Liberal Democrats"]
        ("LibDem","Other")
    elseif party in [1,6] # ["Other (please name below)", "Independent candidate","Brexit Party"]
        ("Other/Brexit","Other")
    elseif party in [7,8,9,10] 
        ("No Vote/DK/Refused","Other")
    else
        @assert false "unassigned party $party"
    end
    return condensed ? d[2] : d[1]
end


function recode_employment( employment :: Integer ) :: String
    return if employment in [5,6,7,8,12]
        "Working/SE Inc. Part-Time"
    elseif employment in [1,4,9,10,11,13,14,15]
        "Not Working, Inc. Retired/Caring/Student"
    else
        @assert false "unmapped employment $employment"
    end
end

function load_energy()
    energy = CSV.File("$(DD)/energy-conjoint.tab";delim='\t', skipto=3)|>DataFram
    rename!( energy, RENAMES_ENERGY)
end 

function load_transport()
    transport = CSV.File("$(DD)/Transport Act Now Conjoint_23 February 2024_13.39_numeric_values.csv";delim=',', skipto=4)|>DataFrame
    transport.destitute = transport."Q13.9_1".>= 70                
    ActNow.create_one!( transport; 
        label="transport", 
        initialq="Q6.1_4", 
        finalq="Q12.1_4", 
        treatqs=["Q7.1_4","Q8.1_4","Q9.1_4","Q10.1_4", "Q11.1_4"])
    rename!( transport, RENAMES_TRANSPORT)
    transport = transport[transport.Finished .== 1,:] # 2 missing
    transport = transport[(.! ismissing.(transport.transport_pre )),:] # 2 missing
    transport = transport[(.! ismissing.(transport.HH_Net_Income_PA )) .& (transport.HH_Net_Income_PA .> 0),:]
    transport = transport[(.! ismissing.(transport.Politicians_All_The_Same )),:] # 2 missing
    transport = transport[(.! ismissing.(transport.Employment_Status )),:] # 2 missing
    transport = transport[(.! ismissing.(transport.transport_post )),:] # 2 missing
    transport = transport[(.! ismissing.(transport.transport_pre )),:] # 2 missing
    n = size(transport)[1]
    transport.HH_Net_Income_PA .= ActNow.recode_income.( transport.HH_Net_Income_PA)
    transport.ethnic_2 = ActNow.recode_ethnic.( transport.Ethnic )
    transport.last_election = recode_party.( transport.Party_Last_Election, condensed=false )
    transport.last_election = recode_party.( transport.Party_Last_Election, condensed=false )
    transport.last_election_condensed = recode_party.( transport.Party_Last_Election, condensed=true  )
    transport.mayoral_election = recode_mayoral.( transport.Party_Mayoral_Election, condensed=false )
    transport.mayoral_election_condensed = recode_mayoral.( transport.Party_Mayoral_Election, condensed=true )
    transport.next_election = transport.mayoral_election 
    transport.poorhealth = transport.General_Health .∈ ([6,7],)
    transport.unsatisfied_with_income = transport.Satisfied_With_Income .∈ ([1,2,3],)
    transport.Owner_Occupier = transport.Owner_Occupier .== 1
    transport.down_the_ladder = transport.Ladder .<= 4
    transport.not_managing_financially = transport.Managing_Financially  .∈ ([4,5],)
    # transport.gad_7 = i_health_score.(eachrow(transport), ActNow.GAD_7...) <- GAD_7 vars missing
    # transport.phq_8  =  i_health_score.(eachrow(transport), ActNow.PHQ_8...)
    transport.weight = ones( n )
    transport.probability_weight = ProbabilityWeights(transport.weight./sum(transport.weight))
    transport.is_redwall .= false

    transport.employment_2 = recode_employment.(transport.Employment_Status)
    transport.log_income = log.(transport.HH_Net_Income_PA)
    transport.age_sq = transport.Age .^2
    transport.Gender = ActNow.recode_gender.( transport.Gender )
    transport.trust_in_politics = i_build_trust.( eachrow( transport ))
    transport.transport_pre = Real.( transport.transport_pre )
    transport.transport_post = Real.( transport.transport_post )
    CSV.write( joinpath( DD, "transport-w-created-vars.tab"), transport; delim='\t')
    return transport
end

function do_all()
    transport = load_transport()
    ActNow.run_regressions_by_policy(
        transport,
        :transport;
        exclude_0s_and_100s = false,
        regdir = "v2/regressions/")
    summdf = score_summarystats( transport ) 
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
    lines = readlines("output/v2/summary_stats.html")
    for l in lines
        println( io, l )
    end
    println(io,"</section'>")
    println(io, "<h2 id='regressions'>Regressions: by Policy</h2>")
    for policy in [:transport]
        prettypol = lpretty( policy )
        exvar = prettypol * " (Before Explanation)"
        # exvar = MAIN_EXPLANDICT[Symbol(mainvar)]
        notes1 = """
        <p>p- values in parenthesis.
        Results are relative to:
        </p>
        <ul>
            <li>vote Mayoral election: Conservative;</li>
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
        fn = joinpath("output","v2",regdir,"actnow-$(policy)-$(prefix)-ols.html")
        edit_table( io, fn )
        println( io, notes1 )
        #
        println( io, "<h3>Popularity of $prettypol: 2): Short Regressions</h3>")
        fn = joinpath("output","v2",regdir,"actnow-simple-$(policy)-$(prefix)-ols.html")
        edit_table( io, fn )
        #
        println( io, "<h3>Popularity of $prettypol: 3): Very Short Regressions</h3>")
        fn = joinpath("output","v2",regdir,"actnow-very-simple-$(policy)-$(prefix)-ols.html")
        edit_table( io, fn )
        #
        println( io, "<h3>Change in Popularity of $prettypol: By Argument</h3>")
        fn = joinpath("output","v2",regdir,"actnow-change-$(policy)-$(prefix)-ols.html")
        edit_table( io, fn )    
        println(io, notes2 )    
        println( io, "<h3>Change in Popularity of $prettypol: Genderless By Argument</h3>")
        fn = joinpath("output","v2",regdir,"actnow-change-sexless-$(policy)-$(prefix)-ols.html")
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


function tra_make_and_print_summarystats( dall :: DataFrame )
    d = ActNow.make_summarystats( dall, [:transport] )
    io = open( "output/v2/summary_stats.html", "w")
    println( io, "<h3>Summary Statistics</h3>")
    t = pretty_table( 
        io,
        d.summarystats; 
        formatters=( ActNow.pform, ActNow.form ), 
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
        formatters=( ActNow.form ), 
        table_class="table table-sm table-striped  table-responsive", 
        backend = Val(:html))
    #
    #=
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
    =#
    c = 0
    for v in d.discretevars 
        c += 1
        pv = ActNow.lpretty(v)
        println( io, "<div class='col p-2 border border-2'>")
        println( io, "<h4>$pv</h4>")
        
        t = pretty_table( 
            io,
            d.hists[v],
            formatters=( ActNow.form ), 
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
        pv = ActNow.lpretty(v)
        println( io, "<div class='col p-2  border border-2'>")
        println( io, "<h4>$pv</h4>")
        fname = "output/v2/img/transport-$(v)-bar.svg"
        save( fname, d.plots[v] )
        fname = "v2/img/transport-$(v)-bar.svg"
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
