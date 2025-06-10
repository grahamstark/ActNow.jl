using StatsBase, PrettyTables, HypothesisTests,CSV,DataFrames

pols = [:basic_income_post,:green_nd_post,:utilities_post,:health_post,:childcare_post,:education_post,:housing_post,:transport_post,:democracy_post,:tax_post,:overall_post]
n = length(pols)
out = DataFrame( policies=fill("",n), correlation=zeros(n), pvalue = zeros(n))
i = 0
for pol in pols
    i += 1
    out.policies[i] = "$pol"
    out.correlation[i] = cor( wave4[!,pol], wave4.var"Duration (in seconds)")
    out.pvalue[i] = pvalue( HypothesisTests.CorrelationTest(wave4[!,pol], wave4.var"Duration (in seconds)"))
end

rename!( out, ["correlation" => "Correlation Approval (post) vs Duration", "pvalue" => "P. Value"])
pretty_table(out)


