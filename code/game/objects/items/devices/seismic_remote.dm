/obj/item/device/seismic_remote
	name = "\improper suspicious radio"
	desc = "Press the button to feel station structure shake all around you!"
	icon = 'icons/obj/device.dmi'
	icon_state = "seismic_remote"
	w_class = W_CLASS_TINY
	flags = FPRINT
	var/cooldown = 0
	mech_flags = MECH_SCAN_FAIL

/obj/item/device/seismic_remote/New()
	processing_objects.Add(src)

/obj/item/device/seismic_remote/process()
	update_icon()

/obj/item/device/seismic_remote/update_icon()
	icon_state = "seismic_remote[cooldown-world.time < 0 ? "" : "_off"]"

/obj/item/device/seismic_remote/examine(mob/user)
	..()
	if(cooldown-world.time < 0)
		to_chat(user, "<span class='notice'>It is ready to fire.</span>")
	else
		to_chat(user, "<span class='notice'>The bluespace artillery piece can fire again in [altFormatTimeDuration(cooldown-world.time)].</span>")

/obj/item/device/seismic_remote/attack_self(var/mob/user)
	if(cooldown - world.time > 0)
		to_chat(user, "<span class='notice'>The bluespace artillery is still being reloaded.</span>")
		return
	if(alert(user, "A cryptic message appears on the screen: \"Fire the Orbital Intercept?\".", name, "Yes", "No") != "Yes")
		return
	var/power = clamp(input(user,"How strong to make the impact?","Orbital Impact",MAX_EXPLOSION_RANGE/4) as num,0,MAX_EXPLOSION_RANGE/4)
	if(user.incapacitated() || !Adjacent(user))
		return
	if(cooldown - world.time > 0)	//check again for the cooldown in case people prep a bunch of popups
		to_chat(user, "<span class='notice'>The bluespace artillery is still being reloaded.</span>")
		return

	var/turf/epicenter = get_turf(src)
	explosion_effect(epicenter,power,power*2,power*4)
	var/datum/sensed_explosion/sensed = new(epicenter.x, epicenter.y, epicenter.z, power, power*2, power*4)
	sensed.paint(epicenter)
	sensed.ready(power*4)

	cooldown = world.time + power MINUTES
