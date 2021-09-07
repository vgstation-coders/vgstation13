/datum/artifact_effect/darkness
	effecttype = "darkness"
	valid_style_types = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_ELDRITCH)
	effect = list(ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	var/dark_level
	copy_for_battery = list("dark_level")

/datum/artifact_effect/darkness/New()
	..()
	effect_type = pick(0,3,4)
	effectrange = rand(2,12)
	dark_level = rand(2,7)

/datum/artifact_effect/darkness/ToggleActivate()
	..()
	if(holder)
		if(istype(holder, /obj/item/weapon/anobattery))
			var/obj/item/weapon/anobattery/B = holder
			if(!activated)
				B.inserted_device.set_light(effectrange, -dark_level)
			else
				B.inserted_device.kill_light()
		else
			if(!activated)
				holder.set_light(effectrange, -dark_level)
			else
				holder.kill_light()
