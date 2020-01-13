spell/targeted/parrotmorph
	name = "Poly-Morph"
	desc = "This spell turns the victim into a harmless and near-invincible parrot for a short amount of time."
	abbreviation = "PM"
	user_type = USER_TYPE_SPELLBOOK

	school = "evocation"
	charge_type = Sp_RECHARGE
	charge_max = 600
	invocation = "'P'Y W'NT A CRAC'K'R!"
	invocation_type = SpI_SHOUT
	range = 7
	max_targets = 1
	spell_flags = WAIT_FOR_CLICK
	cooldown_min = 200
	selection_type = "range"


	compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey)

	hud_state = "wiz_parrotmorph"

spell/targeted/parrotmorph/cast(var/list/targets)
	..()
	for(var/mob/living/target in targets)
		target.flash_eyes(visual = 1)
		var/mob/M = target.transmogrify(/mob/living/simple_animal/parrot/polymorph) //"invincible" parrot
		M.name = target.name
		spawn(2 MINUTES)
			M.transmogrify()
			to_chat(M, "<span class=sinister><B>The spell has worn off! You are no longer a parrot!</span></B>")

/mob/living/simple_animal/parrot/polymorph //here be parrots
	health = INFINITY //immunity to gun wizards
	maxHealth = INFINITY
	has_headset = 0