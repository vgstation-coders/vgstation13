/spell/targeted/disintegrate
	name = "Disintegrate"
	desc = "This spell instantly kills somebody adjacent to you with the vilest of magick."
	abbreviation = "DG"
	user_type = USER_TYPE_SPELLBOOK

	school = "evocation"
	charge_max = 600
	spell_flags = NEEDSCLOTHES
	invocation = "EI NATH"
	invocation_type = SpI_SHOUT
	range = 1
	cooldown_min = 200 //100 deciseconds reduction per rank

	sparks_spread = 1
	sparks_amt = 4

	hud_state = "wiz_disint"

/spell/targeted/disintegrate/cast(var/list/targets)
	..()
	var/mob/living/L = holder
	for(var/mob/living/target in targets)
		if (L.is_pacified(VIOLENCE_DEFAULT,target))
			return
		if(ishuman(target) || ismonkey(target))
			var/mob/living/carbon/C = target
			if(!C.has_brain()) // Their brain is already taken out
				var/obj/item/organ/internal/brain/B = new(C.loc)
				B.transfer_identity(C)
		target.gib()
	return