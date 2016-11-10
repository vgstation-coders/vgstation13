//For spells designed to be inherent abilities given to mobs via their species datum

/spell/racial
	panel = "Racial Abilities"
	override_base = "racial"

/spell/racial/swallow_light	//Grue
	name = "Swallow Light"
	abbreviation = "SL"
	desc = "Create a void of darkness around yourself."
	spell_flags = INCLUDEUSER
	charge_type = Sp_GRADUAL
	charge_max = 600
	minimum_charge = 100
	range = SELFCAST
	cast_sound = 'sound/misc/grue_growl.ogg'
	still_recharging_msg = "<span class='notice'>You're still regaining your strength.</span>"
	hud_state = "racial_dark"

/spell/racial/swallow_light/cast(list/targets, mob/user)
	user.set_light(8,-20)
	playsound(user, cast_sound, 50, 1)
	playsound(user, 'sound/misc/grue_ambience.ogg', 50, channel = CHANNEL_GRUE)

/spell/racial/swallow_light/stop_casting(list/targets, mob/user)
	user.set_light(0)
	playsound(user, null, 50, channel = CHANNEL_GRUE)

/spell/racial/swallow_light/choose_targets(mob/user = usr)
	var/list/targets = list()
	targets += user
	return targets

/spell/racial/swallow_light/is_valid_target(var/target, mob/user, options)
	return(target == user)