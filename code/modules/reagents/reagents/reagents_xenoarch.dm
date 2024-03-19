//Xenoarchaeology-related Chems

/datum/reagent/tungsten
	name = "Tungsten"
	id = TUNGSTEN
	description = "A chemical element, and a strong oxidising agent."
	reagent_state = REAGENT_STATE_SOLID
	color = "#DCDCDC"  // rgb: 220, 220, 220, silver
	density = 19.25

/datum/reagent/lithiumsodiumtungstate
	name = "Lithium Sodium Tungstate"
	id = LITHIUMSODIUMTUNGSTATE
	description = "A reducing agent for geological compounds."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C0C0C0"  // rgb: 192, 192, 192, darker silver
	density = 3.29
	specheatcap = 3.99

/datum/reagent/ground_rock
	name = "Ground Rock"
	id = GROUND_ROCK
	description = "A fine dust made of ground up rock. Adding a reducing agent would separate the waste from the useful elements."
	reagent_state = REAGENT_STATE_SOLID
	color = "#A0522D"   //rgb: 160, 82, 45, brown

/datum/reagent/analysis_sample
	name = "Analysis liquid"
	id = ANALYSIS_SAMPLE
	description = "A watery paste used in chemical analysis."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#F5FFFA"   //rgb: 245, 255, 250, almost white
	density = 4.74
	specheatcap = 3.99

/datum/reagent/analysis_sample/handle_additional_data(var/list/additional_data=null)
	if (GROUND_ROCK in additional_data)
		data = additional_data[GROUND_ROCK]

/datum/reagent/chemical_waste
	name = "Chemical Waste"
	id = CHEMICAL_WASTE
	description = "A viscous, toxic liquid left over from many chemical processes."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#ADFF2F"   //rgb: 173, 255, 47, toxic green
