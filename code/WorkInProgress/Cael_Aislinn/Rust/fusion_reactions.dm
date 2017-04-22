/datum/fusion_reaction
	var/primary_reactant = ""
	var/secondary_reactant = ""
	var/energy_consumption = 0
	var/energy_production = 0
	var/radiation = 0
	var/list/products = list()


/proc/get_fusion_reaction(var/primary_reactant, var/secondary_reactant)
	if (!SSrust || !SSrust.fusion_reactions)
		CRASH("Some fucker tried to get a fusion reaction before the subsystem initialized. Calm down damnit.")

	return SSrust.get_fusion_reaction(primary_reactant, secondary_reactant)


//Fake elements and fake reactions, but its nicer gameplay-wise
//Deuterium
//Tritium
//Uridium-3
//Obdurium
//Solonium
//Rodinium-6
//Dilithium
//Trilithium
//Pergium
//Stravium-7

//Primary Production Reactions

/datum/fusion_reaction/tritium_deuterium
	primary_reactant = "Tritium"
	secondary_reactant = "Deuterium"
	energy_consumption = 1
	energy_production = 5
	radiation = 0

//Secondary Production Reactions

/datum/fusion_reaction/deuterium_deuterium
	primary_reactant = "Deuterium"
	secondary_reactant = "Deuterium"
	energy_consumption = 1
	energy_production = 4
	radiation = 1
	products = list("Obdurium" = 2)

/datum/fusion_reaction/tritium_tritium
	primary_reactant = "Tritium"
	secondary_reactant = "Tritium"
	energy_consumption = 1
	energy_production = 4
	radiation = 1
	products = list("Solonium" = 2)

//Cleanup Reactions

/datum/fusion_reaction/rodinium6_obdurium
	primary_reactant = "Rodinium-6"
	secondary_reactant = "Obdurium"
	energy_consumption = 1
	energy_production = 2
	radiation = 2

/datum/fusion_reaction/rodinium6_solonium
	primary_reactant = "Rodinium-6"
	secondary_reactant = "Solonium"
	energy_consumption = 1
	energy_production = 2
	radiation = 2

//Breeder Reactions

/datum/fusion_reaction/dilithium_obdurium
	primary_reactant = "Dilithium"
	secondary_reactant = "Obdurium"
	energy_consumption = 1
	energy_production = 1
	radiation = 3
	products = list("Deuterium" = 1, "Dilithium" = 1)

/datum/fusion_reaction/dilithium_solonium
	primary_reactant = "Dilithium"
	secondary_reactant = "Solonium"
	energy_consumption = 1
	energy_production = 1
	radiation = 3
	products = list("Tritium" = 1, "Dilithium" = 1)

//Breeder Inhibitor Reactions

/datum/fusion_reaction/stravium7_dilithium
	primary_reactant = "Stravium-7"
	secondary_reactant = "Dilithium"
	energy_consumption = 2
	energy_production = 1
	radiation = 4

//Enhanced Breeder Reactions

/datum/fusion_reaction/trilithium_obdurium
	primary_reactant = "Trilithium"
	secondary_reactant = "Obdurium"
	energy_consumption = 1
	energy_production = 2
	radiation = 5
	products = list("Dilithium" = 1, "Trilithium" = 1, "Deuterium" = 1)

/datum/fusion_reaction/trilithium_solonium
	primary_reactant = "Trilithium"
	secondary_reactant = "Solonium"
	energy_consumption = 1
	energy_production = 2
	radiation = 5
	products = list("Dilithium" = 1, "Trilithium" = 1, "Tritium" = 1)

//Control Reactions

/datum/fusion_reaction/pergium_deuterium
	primary_reactant = "Pergium"
	secondary_reactant = "Deuterium"
	energy_consumption = 5
	energy_production = 0
	radiation = 5

/datum/fusion_reaction/pergium_tritium
	primary_reactant = "Pergium"
	secondary_reactant = "Tritium"
	energy_consumption = 5
	energy_production = 0
	radiation = 5

/datum/fusion_reaction/pergium_deuterium
	primary_reactant = "Pergium"
	secondary_reactant = "Obdurium"
	energy_consumption = 5
	energy_production = 0
	radiation = 5

/datum/fusion_reaction/pergium_tritium
	primary_reactant = "Pergium"
	secondary_reactant = "Solonium"
	energy_consumption = 5
	energy_production = 0
	radiation = 5
