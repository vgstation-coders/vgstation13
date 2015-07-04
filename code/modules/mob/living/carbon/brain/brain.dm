//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/brain
	var/obj/item/container = null
	var/timeofhostdeath = 0
	var/emp_damage = 0//Handles a type of MMI damage
	var/alert = null
	immune_to_ssd = 1
	use_me = 0 //Can't use the me verb, it's a freaking immobile brain
	hasmouth=0 // Can't feed it.
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain1"
	universal_speak = 1
	universal_understand = 1

	#define CONTROLLED_ROBOT_EYE	"#CF00EF"
	var/atom/connected_to = null //if we're being controlled by something
	var/atom/movable/controlling = null  //if we're controlling something

/mob/living/carbon/brain/New()
		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src
		..()

/mob/living/carbon/brain/Destroy()
	if(key)				//If there is a mob connected to this thing. Have to check key twice to avoid false death reporting.
		if(stat!=DEAD)	//If not dead.
			death(1)	//Brains can die again. AND THEY SHOULD AHA HA HA HA HA HA
		ghostize()		//Ghostize checks for key so nothing else is necessary.
	..()

/mob/living/carbon/brain/update_canmove()
	if(src.controlling)
		canmove = 1
		use_me = 1 //If it can move, let it emote
	else							canmove = 0
	return canmove

/mob/living/carbon/brain/Hear(message, atom/movable/speaker, var/datum/language/speaking, raw_message, radio_freq)
	if(connected_to)
		if(istype(connected_to, /obj/machinery/controller_pod))
			var/obj/machinery/controller_pod/pod = connected_to
			if(pod.occupant && pod.link_flags & CONTROLLER_AUDIO_LINK)
				return pod.occupant.Hear("<i>[message]</i>", speaker, speaking, raw_message, radio_freq)
	return ..()

/mob/living/carbon/brain/say_understands(var/atom/movable/other)//Goddamn is this hackish, but this say code is so odd
	if(other) other = other.GetSource()
	if (istype(other, /mob/living/silicon/ai))
		if(!(container && istype(container, /obj/item/device/mmi)))
			return 0
		else
			return 1
	if (istype(other, /mob/living/silicon/decoy))
		if(!(container && istype(container, /obj/item/device/mmi)))
			return 0
		else
			return 1
	if (istype(other, /mob/living/silicon/pai))
		if(!(container && istype(container, /obj/item/device/mmi)))
			return 0
		else
			return 1
	if (istype(other, /mob/living/silicon/robot))
		if(!(container && istype(container, /obj/item/device/mmi)))
			return 0
		else
			return 1
	if (istype(other, /mob/living/carbon/human))
		return 1
	if (istype(other, /mob/living/carbon/slime))
		return 1
	return ..()

/mob/living/carbon/brain/delayNextMove(var/delay, var/additive=0)
	if(!client && connected_to)
		if(istype(connected_to, /obj/machinery/controller_pod))
			var/obj/machinery/controller_pod/pod = connected_to
			if(pod.occupant)
				pod.occupant.delayNextMove(delay, additive)
	else
		..()

