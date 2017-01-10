// Only stores fusion reactions, but I had to move this out of the master controller so...
var/datum/subsystem/rust/SSrust


/datum/subsystem/rust
	name       = "Rust"
	init_order = SS_INIT_RUST
	flags      = SS_NO_FIRE

	var/list/fusion_reactions


/datum/subsystem/rust/New()
	NEW_SS_GLOBAL(SSrust)


// Populate fusion reactions.
/datum/subsystem/rust/Initialize(timeofday)
	fusion_reactions = list()

	for (var/cur_reaction_type in typesof(/datum/fusion_reaction) - /datum/fusion_reaction)
		var/datum/fusion_reaction/cur_reaction = new cur_reaction_type()
		if (!fusion_reactions[cur_reaction.primary_reactant])
			fusion_reactions[cur_reaction.primary_reactant] = list()

		fusion_reactions[cur_reaction.primary_reactant][cur_reaction.secondary_reactant] = cur_reaction
		if (!fusion_reactions[cur_reaction.secondary_reactant])
			fusion_reactions[cur_reaction.secondary_reactant] = list()

		fusion_reactions[cur_reaction.secondary_reactant][cur_reaction.primary_reactant] = cur_reaction


/datum/subsystem/rust/proc/get_fusion_reaction(var/primary_reactant, var/secondary_reactant)
	if (fusion_reactions.Find(primary_reactant))
		var/list/secondary_reactions = fusion_reactions[primary_reactant]
		if (secondary_reactions.Find(secondary_reactant))
			return fusion_reactions[primary_reactant][secondary_reactant]
