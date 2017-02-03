#define CONTROLLER_VISUAL_LINK	1
#define CONTROLLER_AUDIO_LINK	2
#define CONTROLLER_NEURAL_LINK	4
#define CONTROLLER_FULL_LINK 	7

#define POD_FORCE_DAMAGE		30

/obj/machinery/controller_pod
	name = "Neural-link Control Pod"
	desc = "An enclosed capsule used for remote-control of synthetic machines compatible with the positronic standard."

	icon = 'icons/obj/machines/controller_pod.dmi'
	icon_state = "pod_open"

	density = 1
	anchored = 1

	machine_flags = WRENCHMOVE | FIXED2WORK | EMAGGABLE
	flags = HEAR

	var/mob/living/occupant = null //the mob currently in the machine
	var/mob/living/carbon/brain/brainmob = null //the mob we are connected to

	var/obj/screen/eject_button/eject_button

	var/link_flags = 0

/obj/machinery/controller_pod/New()
	..()
	eject_button = new
	eject_button.pod_master = src

/obj/machinery/controller_pod/Destroy()
	eject_mob()
	if(brainmob)
		brainmob.connected_to = null
		brainmob = null
	..()

/obj/machinery/controller_pod/wrenchAnchor(mob/user)
	if(occupant)
		user << "You can't move \the [src], it's occupied!"
		return -1
	return ..()

/obj/machinery/controller_pod/emag(mob/user)
	if(occupant)
		user.show_message("<span class='danger'>You force \the [src]'s emergency ejection procedures.</span>")
		if(link_flags & CONTROLLER_NEURAL_LINK)
			occupant.adjustBrainLoss(POD_FORCE_DAMAGE)
			occupant.Stun(5)
		eject_mob()
		return 1
	return -1

/obj/machinery/controller_pod/attackby(obj/item/I, mob/user)
	if(..())
		return 1
	if(stat & (BROKEN|NOPOWER))
		return 1

	if(istype(I, /obj/item/device/mmi/posibrain/nl_brain))
		var/obj/item/device/mmi/posibrain/nl_brain/nl_brain = I
		if(occupant && brainmob)
			user << "The safety codes prevent you from switching controls while \the [src] is in use."
			return 1
		else
			if(!nl_brain.brainmob)
				to_chat(user, "\The [nl_brain] doesn't have a usable intelligence to connect to.")
				return 1
			if(brainmob && brainmob.controlling)
				to_chat(user, "\The [src] already has a neural target, you'll have to get rid of it first.")
				return 1
			if(!anchored)
				return 1
			connect_brain(nl_brain.brainmob)
			user.visible_message("[user] links \the [nl_brain] to \the [src]", "You link \the [nl_brain] to \the [src].")
		return 1

/obj/machinery/controller_pod/attack_hand(mob/user)
	if(user == occupant)
		eject_mob()
		return 1
	else if (!occupant)
		enter_mob(user)
		return 1
	return ..()

/obj/machinery/controller_pod/Bumped(mob/M)
	if(istype(M, /mob/living) && anchored)
		var/mob/living/L = M
		if(L.dexterity_check() && !occupant)
			enter_mob(L)

/obj/machinery/controller_pod/proc/enter_mob(var/mob/living/new_occupant)
	if(!new_occupant || !istype(new_occupant))
		return

	if(!anchored)
		to_chat(new_occupant, "<span class='notice'>[src] must be anchored to enter!</span>")
		return

	if(!brainmob)
		new_occupant.show_message("\The [src] beeps: \"No intelligence connected!\"", 1)
		return

	occupant = new_occupant
	new_occupant.forceMove(src)
	icon_state = "pod_closed"
	link_flags = occupant.get_neural_flags()

	if(link_flags & CONTROLLER_NEURAL_LINK && occupant.mind)
		occupant.mind.transfer_to(brainmob)

		if(brainmob.client)
			brainmob.client.screen.Add(eject_button)
		to_chat(brainmob, "<span class='notice'>Neural link successfully established.</span>")
	else
		if(occupant.client)
			occupant.client.screen.Add(eject_button)
		if(link_flags & CONTROLLER_VISUAL_LINK)
			to_chat(occupant, "<span class='notice'>Visual link successfully established.</span>")
			occupant.reset_view(brainmob)
			occupant.set_machine(src)
		if(link_flags & CONTROLLER_AUDIO_LINK)
			to_chat(occupant, "<span class='notice'>Audio link successfully established.</span>")

/obj/machinery/controller_pod/proc/eject_mob()
	for(var/atom/movable/AM in src.contents)
		AM.forceMove(get_turf(src))

	if(brainmob)
		if(brainmob.mind)
			brainmob.client.screen.Remove(eject_button)
			brainmob.mind.transfer_to(occupant)
		else if(brainmob.controlling && istype(brainmob.controlling, /mob))
			var/mob/M = brainmob.controlling
			if(M.mind)
				brainmob.client.screen.Remove(eject_button)
				M.mind.transfer_to(occupant)

	if(occupant && occupant.client)
		occupant.client.screen.Remove(eject_button)

	occupant.unset_machine()
	occupant.reset_view()

	occupant = null
	icon_state = "pod_open"

	link_flags = 0

/obj/machinery/controller_pod/proc/mob_death(wearer) //the brain died or the occupant died
	if(wearer == occupant)
		if(link_flags & CONTROLLER_NEURAL_LINK && brainmob)
			brainmob.connected_to = null

			var/mob/target = brainmob
			if(istype(brainmob.controlling, /mob))
				target = brainmob.controlling

			if(target.client)
				target.client.screen.Remove(eject_button)

			target << "<span class='danger' class='big'>Your neural connection shuts off!</span>"

			brainmob = null
		eject_mob() //kick the dead bastard out
	else if (wearer == brainmob)
		if(occupant && link_flags & CONTROLLER_NEURAL_LINK)
			occupant.adjustBrainLoss(20)
			brainmob << "<span class='danger' class='big'>Your neural connection feedbacks!</span>" //have to show the brainmob, because the client is there
			eject_mob()

/obj/machinery/controller_pod/proc/connect_brain(var/mob/living/carbon/brain/new_brain)
	if(!new_brain || !istype(new_brain))
		return

	brainmob = new_brain
	new_brain.connected_to = src

/obj/machinery/controller_pod/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(speech.speaker == occupant && !speech.frequency && link_flags & CONTROLLER_AUDIO_LINK) //if we're speaking, no radio, with an earpiece
		if(brainmob)
			if(brainmob.controlling)
				brainmob.controlling.say(speech.message)
			else
				brainmob.say(speech.message)
	else
		..()
/obj/machinery/controller_pod/relaymove(mob/user, step_dir)
	if(user == occupant)
		if(brainmob)
			if(istype(brainmob.controlling, /mob)) //We have to fiddle manually
				if(istype(brainmob.controlling.loc, /turf))
					step(brainmob.controlling, step_dir)
			else
				brainmob.Move(Dir = step_dir) //let relaymove handle it
			if(link_flags & CONTROLLER_VISUAL_LINK)
				occupant.reset_view(brainmob)
			return 1
	eject_mob()

/obj/machinery/controller_pod/check_eye(var/mob/user = occupant)
	link_flags = occupant.get_neural_flags()
	if (!(link_flags & CONTROLLER_VISUAL_LINK))
		return null
	user.reset_view(brainmob)
	return 1

////// THE BUTTON

/obj/screen/eject_button
	icon = 'icons/obj/machines/controller_pod.dmi'
	icon_state = "eject_button"

	screen_loc = "14:0,14:16"

	var/obj/machinery/controller_pod/pod_master = null

/obj/screen/eject_button/Click()
	if(pod_master)
		pod_master.eject_mob()

/*/obj/screen/eject_button/pool_on_reset()
	. = 0
*/