
//override procs in children as necessary
/datum/artifact_effect
	var/effecttype = "unknown"		//purely used for admin checks ingame, not needed any more
	var/effect = ARTIFACT_EFFECT_TOUCH //Define this as a specific value if the effect only supports that one, or a list of the supported values if it supports multiple.
	var/effectrange = 4
	var/datum/artifact_trigger/trigger
	var/atom/holder
	var/activated = 0
	var/chargelevel = 0
	var/chargelevelmax = 10
	var/artifact_id = ""
	var/list/copy_for_battery  //add any effect-specific variables you need copied for anomaly batteries as a list of strings
	var/effect_type = 0
	var/isolated = 0

//0 = Unknown / none detectable
//1 = Concentrated energy
//2 = Intermittent psionic wavefront
//3 = Electromagnetic energy
//4 = Particle field
//5 = Organically reactive exotic particles
//6 = Interdimensional/bluespace? phasing
//7 = Atomic synthesis

//send 1 after location to generate a trigger for the effect, only do this on objects that have the required events!
/datum/artifact_effect/New(var/atom/location, var/generate_trigger = 0)
	..()
	holder = location
	effect = pick(effect) //If effect is defined as a list, pick one of the options from the list. If it's defined specifically, pick that.

	//this will be replaced by the excavation code later, but it's here just in case
	artifact_id = "[pick("kappa","sigma","antaeres","beta","omicron","iota","epsilon","omega","gamma","delta","tau","alpha")]-[rand(100,999)]"

	//random charge time and distance
	switch(pick(100;1, 50;2, 25;3))
		if(1)
			//short range, short charge time
			chargelevelmax = rand(3, 20)
			effectrange = rand(1, 3)
		if(2)
			//medium range, medium charge time
			chargelevelmax = rand(15, 40)
			effectrange = rand(5, 15)
		if(3)
			//large range, long charge time
			chargelevelmax = rand(20, 120)
			effectrange = rand(20, 200)

	if(generate_trigger)
		GenerateTrigger()

/datum/artifact_effect/proc/ToggleActivate(var/reveal_toggle = 1)
	//so that other stuff happens first
	spawn(0)
		if(activated)
			activated = 0
		else
			activated = 1
			isolated = 1
			spawn(20 SECONDS)
				isolated = 0

		if(reveal_toggle == 1 && holder)
			if(istype(holder, /obj/machinery/artifact))
				var/obj/machinery/artifact/A = holder
				A.icon_state = "ano[A.icon_num][activated]"
			var/display_msg
			if(activated)
				display_msg = pick("momentarily glows brightly!","distorts slightly for a moment!","flickers slightly!","vibrates!","shimmers slightly for a moment!")
			else
				display_msg = pick("grows dull!","fades in intensity!","suddenly becomes very still!","suddenly becomes very quiet!")
			var/atom/toplevelholder = get_holder_at_turf_level(holder)
			toplevelholder.visible_message("<span class='warning'>[bicon(toplevelholder)] [toplevelholder] [display_msg]</span>")
		if(reveal_toggle == 2 && holder)
			var/display_msg
			if(activated)
				display_msg = pick("rumbles slightly for a moment!","begins to shake!","blinks slightly!","starts to whirr!","sparks!")
			else
				display_msg = pick("quiets down!","settles to a stop!","lets out a single beep!","goes dark!")
			var/atom/toplevelholder = get_holder_at_turf_level(holder)
			toplevelholder.visible_message("<span class='warning'>[bicon(toplevelholder)] [toplevelholder] [display_msg]</span>")

/datum/artifact_effect/proc/DoEffectTouch(var/mob/user)
/datum/artifact_effect/proc/DoEffectAura(var/atom/holder)
/datum/artifact_effect/proc/DoEffectPulse(var/atom/holder)
/datum/artifact_effect/proc/UpdateMove()

/datum/artifact_effect/proc/process()
	if(chargelevel < chargelevelmax)
		chargelevel++

	if(activated)
		if(effect == ARTIFACT_EFFECT_AURA)
			DoEffectAura()
		else if(effect == ARTIFACT_EFFECT_PULSE && chargelevel >= chargelevelmax)
			chargelevel = 0
			DoEffectPulse()

//returns 0..1, with 1 being no protection and 0 being fully protected
proc/GetAnomalySusceptibility(var/mob/living/carbon/human/H)
	if(!H || !istype(H))
		return 1

	var/protected = 0

	//anomaly suits give best protection, but excavation suits are almost as good
	if(istype(H.wear_suit,/obj/item/clothing/suit/bio_suit/anomaly))
		protected += 0.6
	else if(istype(H.wear_suit,/obj/item/clothing/suit/storage/labcoat/rd))
		protected += 0.5
	else if(istype(H.wear_suit,/obj/item/clothing/suit/space/anomaly))
		protected += 0.5
	else if(istype(H.wear_suit,/obj/item/clothing/suit/space/rig/ror))
		protected += 0.3
	else if(istype(H.wear_suit,/obj/item/clothing/suit/space/rig/arch))
		protected += 0.3

	if(istype(H.head,/obj/item/clothing/head/bio_hood/anomaly))
		protected += 0.3
	else if(istype(H.head,/obj/item/clothing/head/helmet/space/anomaly))
		protected += 0.2
	else if(istype(H.head,/obj/item/clothing/head/helmet/space/rig/ror))
		protected += 0.1
	else if(istype(H.head,/obj/item/clothing/head/helmet/space/rig/arch))
		protected += 0.1

	//latex gloves and science goggles also give a bit of bonus protection
	if(istype(H.gloves,/obj/item/clothing/gloves/latex))
		protected += 0.1

	if(istype(H.glasses,/obj/item/clothing/glasses/science))
		protected += 0.1

	return 1 - protected

//effect does not fire and outputs a message
/datum/artifact_effect/proc/Blocked()
	var/atom/toplevelholder = get_holder_at_turf_level(holder)
	toplevelholder.visible_message("<span class='warning'>[bicon(toplevelholder)] [toplevelholder] expells energy which is blocked by the containment field!</span>")
	isolated = 1
	spawn(20 SECONDS)
		isolated = 0

/datum/artifact_effect/proc/IsPrimary()
	if(istype(holder, /obj/machinery/artifact))
		var/obj/machinery/artifact/A = holder
		if(A.primary_effect == src)
			return 1
	return 0

/datum/artifact_effect/proc/IsContained()
	if(istype(holder, /obj/machinery/artifact))
		var/obj/machinery/artifact/A = holder
		if(A.contained)
			return 1
	return 0

/datum/artifact_effect/proc/GenerateTrigger()
	if(trigger)
		qdel(trigger); trigger = null
	var/triggertype
	if(effect == ARTIFACT_EFFECT_TOUCH)
		triggertype = /datum/artifact_trigger/touch
	else
		triggertype = pick(typesof(/datum/artifact_trigger) - /datum/artifact_trigger)

	trigger = new triggertype(src)

/datum/artifact_effect/Destroy()
	if(trigger)
		qdel(trigger); trigger = null
	copy_for_battery = null
	holder = null
