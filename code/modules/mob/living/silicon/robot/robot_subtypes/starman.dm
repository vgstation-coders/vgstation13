/mob/living/silicon/robot/starman
	cell_type = /obj/item/weapon/cell/super

/mob/living/silicon/robot/starman/New()
	..()
	UnlinkSelf()
	laws = new /datum/ai_laws/starman()
	pick_module(STARMAN_MODULE)
	set_module_sprites(list("Basic" = "starman"))
	src.add_spell(new /spell/targeted/starman_warp)

/spell/targeted/starman_warp
	name = "Warp"
	desc = "*Whirr* Activate phase shift engines. *Whirr*"
	abbreviation = "WRP"

	school = "evocation"
	charge_type = Sp_RECHARGE
	charge_max = 150
	invocation = "Bzzt."
	invocation_type = SpI_SHOUT
	range = 8
	max_targets = 1
	spell_flags = WAIT_FOR_CLICK
	cooldown_min = 8
	selection_type = "range"

	compatible_mobs = list(/mob/living/silicon/robot/starman)

	hud_state = "gray"


/spell/targeted/starman_warp/cast(list/targets, mob/user = user)
	..()
	for(var/turf/floor in targets)
		if(!floor.density)
			user.icon_state = "starman_phase"
			spawn(0.3 SECONDS)
				do_teleport(user, floor, 0)
				spawn(0.3 SECONDS)
					user.icon_state = "starman"
			return