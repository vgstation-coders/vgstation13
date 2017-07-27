/spell/targeted/balefulmutate
	name = "Baleful Mutation"
	desc = "A spell that gives its victm random limbs from different species."

	school = "transmutation"
	charge_max = 600
	invocation = "MAHNSTUR MACH!"
	invocation_type = SpI_SHOUT
	range = 1
	spell_flags = WAIT_FOR_CLICK //SELECTABLE hinders you here, since the spell has a range of 1 and only works on adjacent guys. Having the TARGETTED flag here makes it easy for your target to run away from you!

	hud_state = "b_mutate"


/spell/targeted/balefulmutate/cast/(var/list/targets)
	for(var/mob/living/carbon/human/target in targets)
		var/list/valid_species = (all_species - list("Krampus", "Horror"))
		for(var/datum/organ/external/E in target.organs)
			E.species = all_species[pick(valid_species)]
			target.regenerate_icons()
			to_chat(target, "<span class=danger><B>The baleful mutation warps your body! </span></B>")