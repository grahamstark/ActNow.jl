var documenterSearchIndex = {"docs":
[{"location":"index.html","page":"Home","title":"Home","text":"CurrentModule = ActNow","category":"page"},{"location":"index.html#Act-Now-Julia","page":"Home","title":"Act Now Julia","text":"","category":"section"},{"location":"index.html","page":"Home","title":"Home","text":"\nModules = [ActNow] \nOrder   = [:function, :type]\n","category":"page"},{"location":"index.html#ActNow.analyse_w3_w4_changes-Tuple{DataFrames.DataFrame, DataFrames.DataFrame, DataFrames.DataFrame}","page":"Home","title":"ActNow.analyse_w3_w4_changes","text":"Create a bunch of summaries of the differences between wave 3 and wave4 data\n\njoined - hcat of common wave3 and wave4 data\nwave3 - wave3 data\nwave4 - wave4 data\nreturn dict of images and summary stats for the stacked data and counts for w3 and w4\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.build_trust-Tuple{DataFrames.DataFrameRow}","page":"Home","title":"ActNow.build_trust","text":"return 24 (most) .. 0 least \n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.corrmatrix","page":"Home","title":"ActNow.corrmatrix","text":"Correlation matrix for the policies\n\n\n\n\n\n","category":"function"},{"location":"index.html#ActNow.create_all_crosstabs-Tuple{}","page":"Home","title":"ActNow.create_all_crosstabs","text":"Writes images of each crosstab to e.g. img/crosstab-[policyname]-by-gender.svg\n\nindex_filename - index file for all the links to images\ndall - one of w4 or w3 processed datasets (see metaload for steps)\n\nTODO: more breakdowns - switch between .png .svg\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.create_one!-Tuple{DataFrames.DataFrame}","page":"Home","title":"ActNow.create_one!","text":"This convoluted function creates a bunch or binary variables in the dataframe dall for some question and treatments.     @param labels - for readable variable names e.g. \"basicincome\"     @param initialq - initial opinion on the thing     @param finalq - final (post explanation) opinion     @param treatqs - three strings representing the 3 explanations for that thing - abs gains, rel gains, security     adds in variables like `basicincometreatabsgains_destitute`\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.do_basic_pca_w-Tuple{DataFrames.DataFrame}","page":"Home","title":"ActNow.do_basic_pca_w","text":"See: https://juliastats.org/MultivariateStats.jl/dev/pca/#Linear-Principal-Component-Analysis See: https://www.youtube.com/watch?v=FgakZw6K1QQ\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.do_fixed_effects-Tuple{DataFrames.DataFrame}","page":"Home","title":"ActNow.do_fixed_effects","text":"W3->4 Fixed effect regs written to: output/fixed-effect-regs.html\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.draw_change_scat-Tuple{Any, Any}","page":"Home","title":"ActNow.draw_change_scat","text":"Draw our scatter plots with the parties colo[u]red in.\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.draw_pol_scat-Tuple{Any, Any}","page":"Home","title":"ActNow.draw_pol_scat","text":"Draw our scatter plots with the parties colo[u]red in.\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.draw_policies2-Tuple{DataFrames.DataFrame, Symbol, Symbol}","page":"Home","title":"ActNow.draw_policies2","text":"Drawing all our charts using the marginally less mad AlgebraOfGraphics lib.\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.joinv3v4-Tuple{DataFrames.DataFrame, DataFrames.DataFrame}","page":"Home","title":"ActNow.joinv3v4","text":"Merge wave3 and wave4 data on PROLIFIC_ID. return horizontally joined, vertically stacked and a list of items to skip in subsequent regressions if log incomes are NaNs Also, add in_both_waves field to wave4 as a by-product.\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.make_all_graphs-Tuple{DataFrames.DataFrame}","page":"Home","title":"ActNow.make_all_graphs","text":"Make a bunch of scatterplots for each policy - see draw_policies2 Written to output/img as both .svg and .png\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.make_big_file_by_explanvar-Tuple{}","page":"Home","title":"ActNow.make_big_file_by_explanvar","text":"Creates all_results_by_explanvar.html with most results broken down by risk of destitution, health, life ladder, etc. -See MAIN_EXPLANDICT for the whole list.\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.make_big_file_by_policy-Tuple{}","page":"Home","title":"ActNow.make_big_file_by_policy","text":"Makes output/all_results_by_policy.html, a big file summarising main wave 4 results, organised by each policy area.\n\nrun_regressions() and make_and_print_summarystats() need to have been run beforehand and the output directory filled with regressiona and graph files. \n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.make_dataset_v4-Tuple{}","page":"Home","title":"ActNow.make_dataset_v4","text":"Initial load and construction of v4 dataset with extra created variables.\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.make_summarystats-Tuple{DataFrames.DataFrame}","page":"Home","title":"ActNow.make_summarystats","text":"Make a pile of summary statistics and histograms\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.merge_treats!-Tuple{DataFrames.DataFrame, String}","page":"Home","title":"ActNow.merge_treats!","text":"Produce a single column with which treatment and the score\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.pform-Tuple{Any, Any, Any}","page":"Home","title":"ActNow.pform","text":"Hacky p-values cols in stats tables.\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.policies_as_matrix-Tuple{DataFrames.DataFrame, String}","page":"Home","title":"ActNow.policies_as_matrix","text":"dall -  extension - pre or post normalise - \n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.recode_income-Tuple{Any}","page":"Home","title":"ActNow.recode_income","text":"Hacky fix of income where some people seem to have entered in £000s rather than £s\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.recode_party-Tuple{Union{Missing, AbstractString}}","page":"Home","title":"ActNow.recode_party","text":"FIXME mess\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.reweight","page":"Home","title":"ActNow.reweight","text":"Create weights based on voting intention and age/sex groups. NOTE: 0.6-2.8 are the closesy weights I can find that converge using constrainedchisquare.\n\n\n\n\n\n","category":"function"},{"location":"index.html#ActNow.run_regressions_by_policy-Tuple{DataFrames.DataFrame, Symbol}","page":"Home","title":"ActNow.run_regressions_by_policy","text":"Take 2 - slightly different regressions and tables organised by policy\n\n\n\n\n\n","category":"method"},{"location":"index.html#ActNow.summarise_pca","page":"Home","title":"ActNow.summarise_pca","text":"Summary of one of our Principal Components\n\ndall - wave3 or 4 dataset (always 4 in practice)\nM - output from one PCA analysys (?? type ??)\nextension - one of 'pre' or 'change' \nregdir - where to save regressions \n\n\n\n\n\n","category":"function"}]
}