
using ActNow,DataFrames,CSV

const DD = "/mnt/data/ActNow/Surveys/v2/"
energy = CSV.File("$(DD)/energy-conjoint.tab";delim='\t')|>DataFram
transport = CSV.File("$(DD)/Transport Act Now Conjoint_23 February 2024_13.39_numeric_values.csv";delim=',')|>DataFrame


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

rename!( energy, RENAMES_ENERGY )


RENAMES_TRANSPORT=([
    "Q6.1_4"=>"Transport_General_Pre",
    "Q7.1_4"=>"Absolute_Pre",
    "Q8.1_4"=>"Absolute_Argument",
    "Q9.1_4"=>"Relative_Pre",
    "Q10.1_4"=>"Relative_Argument",
    "Q11.1_4"=>"Security_Pre",
    "Q12.1_4"=>"Security_Argument",
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
    "Q13.21"=>"Party_Next_Election",
    "Q13.22_1"=>"Politicians_All_The_Same",
    "Q13.22_2"=>"Politics_Force_For_Good",
    "Q13.22_3"=>"Party_In_Government_Doesnt_Matter",
    "Q13.22_4"=>"Politicians_Dont_Care",
    "Q13.22_5"=>"Politicians_Want_To_Make_Things_Better",
    "Q13.22_6"=>"Shouldnt_Rely_On_Government",
    "Q14.1"=>"Feedback"])

rename!( transport, RENAMES_TRANSPORT)

