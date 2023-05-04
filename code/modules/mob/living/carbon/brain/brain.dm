/mob/living/carbon/brain
	var/obj/item/container = null
	var/timeofhostdeath = 0
	var/emp_damage = 0//Handles a type of MMI damage
	var/alert = null
	can_butcher = 0
	use_me = 0 //Can't use the me verb, it's a freaking immobile brain
	hasmouth=0 // Can't feed it.
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain1"
	universal_speak = 1
	universal_understand = 1

/mob/living/carbon/brain/New()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src
	..()
	verbs -= /mob/living/carbon/verb/mob_sleep

/mob/living/carbon/brain/Destroy()
	if(key)				//If there is a mob connected to this thing. Have to check key twice to avoid false death reporting.
		if(stat!=DEAD)	//If not dead.
			death(1)	//Brains can die again. AND THEY SHOULD AHA HA HA HA HA HA
	..()

/mob/living/carbon/brain/update_canmove()
	if(in_contents_of(/obj/mecha))
		canmove = 1
		use_me = 1 //If it can move, let it emote
	else
		canmove = 0
	return canmove

/mob/living/carbon/brain/say(var/message)
	if (container && istype(container, /obj/item/device/mmi))
		if(istype(container.loc,/obj/item/weapon/storage/belt/silicon))
			RenderBeltChat(container.loc,src,message)
			return 1
		else
			return ..(message, "R")
	return ..(message)

/mob/living/carbon/brain/say_understands(var/atom/movable/other)//Goddamn is this hackish, but this say code is so odd
	if(other)
		other = other.GetSource()
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

/mob/living/carbon/brain/teleport_to(var/atom/A)
	container.forceMove(get_turf(A))

/mob/living/carbon/brain/proc/brain_dead_chat()
	return !(container && (istype(container, /obj/item/device/mmi)))

/mob/living/carbon/brain/dexterity_check()
	return 1 //This is so certain mech tools work for MMIs and posibrains.

/mob/living/carbon/brain/proc/can_ai_click()
	if(container && istype(container.loc,/obj/machinery/camera))
		var/obj/machinery/camera/C = container.loc
		if(container in C.assembly.upgrades)
			return TRUE
	return FALSE

/mob/living/carbon/brain/ClickOn(var/atom/A, params)
	if(can_ai_click())
		A.add_hiddenprint(src)
		A.attack_ai(src)
	else
		return ..()

/mob/living/carbon/brain/ShiftClickOn(var/atom/A)
	if(can_ai_click())
		A.AIShiftClick(src)
	else
		return ..()
/mob/living/carbon/brain/CtrlClickOn(var/atom/A)
	if(can_ai_click())
		A.AICtrlClick(src)
	else
		return ..()
/mob/living/carbon/brain/AltClickOn(var/atom/A)
	if(can_ai_click())
		A.AIAltClick(src)
	else
		return ..()
/mob/living/carbon/brain/MiddleShiftClickOn(var/atom/A)
	if(can_ai_click())
		A.AIMiddleShiftClick(src)
	else
		return ..()
/mob/living/carbon/brain/RightClickOn(var/atom/A)
	if(can_ai_click())
		A.AIRightClick(src)
	else
		return ..()

/mob/living/carbon/brain/GetAccess()
	return can_ai_click() ? container.camera_access : ..()
