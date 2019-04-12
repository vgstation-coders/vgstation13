/spell/targeted/balefulmutate
	name = "Baleful Mutation"
	desc = "A spell that gives its victm random limbs from different species."
	user_type = USER_TYPE_SPELLBOOK
	school = "transmutation"
	charge_max = 600
	invocation = "MAHNSTUR MACH!"
	invocation_type = SpI_SHOUT
	range = 1
	spell_flags = NEEDSCLOTHES | WAIT_FOR_CLICK
	hud_state = "wiz_bmutate"


/spell/targeted/balefulmutate/cast/(var/list/targets)
	for(var/mob/living/carbon/human/target in targets)
		target.flash_eyes(visual = 1)
		var/list/valid_species = (all_species - list("Krampus", "Horror"))
		for(var/datum/organ/external/E in target.organs)
			E.species = all_species[pick(valid_species)]
			target.regenerate_icons()
			to_chat(target, "<span class=danger><B>Powerful magic warps your body! </span></B>")