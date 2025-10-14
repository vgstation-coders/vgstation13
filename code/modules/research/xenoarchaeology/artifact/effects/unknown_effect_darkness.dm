/datum/artifact_effect/darkness
	effecttype = "darkness"
	valid_artifact_styles = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_ELDRITCH)
	effect = list(ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_hint = EFFECT_HINT_LOW_LEVEL_EMISSIONS
	var/dark_level
	copy_for_battery = list("dark_level")

/datum/artifact_effect/darkness/New()
	..()
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
				B.inserted_device.set_light(0)
		else
			if(!activated)
				holder.set_light(effectrange, -dark_level)
			else
				holder.set_light(0)