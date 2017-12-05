/spell/targeted/fist
	name = "Fist"
	desc = "This spell punches everyone in view."
	abbreviation = "FS"

	price = Sp_BASE_PRICE/2
	charge_max = 50
	cooldown_min = 10
	invocation = "I CAST FIST"
	invocation_type = SpI_SHOUT
	max_targets = 0

	compatible_mobs = list(/mob/living)

	hud_state = "wiz_fist"

/spell/targeted/fist/cast(var/list/targets)
	var/mob/living/L = holder
	if(istype(L))
		for(var/mob/living/target in targets)
			L.unarmed_attack_mob(target)
