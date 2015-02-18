/datum/chemical_reaction/lithiumsodiumtungstate
	name = "Lithium Sodium Tungstate"
	id = "lithiumsodiumtungstate"
	required_reagents = list("lithium" = 1, "sodium" = 2, "tungsten" = 1, "oxygen" = 4)
	results = list("lithiumsodiumtungstate" = 8)

/datum/chemical_reaction/density_separated_liquid
	name = "Density separated sample"
	id = "density_separated_sample"
	required_reagents = list("ground_rock" = 1, "lithiumsodiumtungstate" = 2)
	results = list("density_separated_sample" = 2)

/datum/chemical_reaction/analysis_liquid
	name = "Analysis sample"
	id = "analysis_sample"
	required_reagents = list("density_separated_sample" = 5)
	requires_heating = 1
	results = list("analysis_sample" = 4)

