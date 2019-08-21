/spell/targeted/disorient
	name = "Disorient"
	desc = "This spell temporarily disorients a target."
	abbreviation = "SJ"
	user_type = USER_TYPE_WIZARD
	specialization = OFFENSIVE

	school = "transmutation"
	charge_max = 300
	invocation = "DII ODA BAJI"
	invocation_type = SpI_WHISPER
	message = "<span class='danger'>You suddenly feel completely overwhelmed!<span>"
	level_max = list(Sp_TOTAL = 5, Sp_SPEED = 4, Sp_POWER = 1)

	max_targets = 1

	amt_dizziness = 86
	amt_confused = 86 // 2.1 seconds per = 180.6s
	amt_stuttering = 86

	compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	spell_flags = WAIT_FOR_CLICK

	hud_state = "wiz_disorient"

/spell/targeted/disorient/cast(var/list/targets)
	..()
	if(spell_levels[Sp_POWER] >= 1)
		for(var/mob/target in targets)
			var/angle = pick(90, 180, 270)
			var/client/C = target.client
			if(C)
				C.dir = turn(C.dir, angle)
				spawn(30 SECONDS) //This will confuse someone for a while and end up very annoying
					if(C)
						C.dir = turn(C.dir, -angle)

/spell/targeted/disorient/empower_spell()
	spell_levels[Sp_POWER]++
	name = "Empowered Disorient"
	desc = "This spell will very thoroughly disorient a target for 30 seconds."
	return "You have upgraded the spell to turn the target's perception in another direction, further debilitating them."

/spell/targeted/disorient/get_upgrade_info(upgrade_type, level)
	if(upgrade_type == Sp_POWER)
		return "Gives an additional effect to the spell that turns the target's view of reality in a direction, debilitating them a lot."
	return ..()