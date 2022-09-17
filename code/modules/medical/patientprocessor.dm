/obj/machinery/patient_processor
	name = "patient processor"
	desc = "A device that uses advanced AutoDoc technology to heal patients."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = 1
	anchored = 1
	var/input_dir = 1
	output_dir = 2

/obj/machinery/patient_processor/proc/notify_ghost(var/mob/M)
	if(!M.client)
		var/mob/dead/observer/ghost = mind_can_reenter(M.mind)
		if(ghost)
			var/mob/ghostmob = ghost.get_top_transmogrification()
			if(ghostmob)
				ghostmob << 'sound/effects/adminhelp.ogg'
				to_chat(ghostmob, "<span class='interface big'><span class='bold'>You've been healed by the patient processor! Return to your body to get back into the round like you deserve.</span> \
					(Verbs -> Ghost -> Re-enter corpse, or <a href='?src=\ref[ghost];reentercorpse=1'>click here!</a>)</span>")

/obj/machinery/patient_processor/process()
	if((!(output_dir in cardinal) || !(input_dir in cardinal)) || output_dir == input_dir || !anchored)
		return
	var/input = get_step(src, input_dir)
	var/output = get_step(src, output_dir)
	var/mob/living/M = locate(/mob/living, input)
	if(M)
		notify_ghost(M)
		M.forceMove(output)
		M.rejuvenate(animation = TRUE)
		return

	//if we didn't fix a mob, we'll fix a head/brain
	var/mob/living/carbon/brain/brainmob
	var/obj/item/organ/O = locate(/obj/item/organ/, input)
	if(!O)
		return
	var/obj/item/organ/external/head/head = O
	var/obj/item/organ/internal/brain/brain = O
	if(istype(head))
		brainmob = head.brainmob
	else if(istype(brain))
		brainmob = brain.brainmob
	if(!brainmob)
		return
	notify_ghost(brainmob)

	//produce a new body
	var/datum/dna/new_dna = brainmob.dna.Clone()
	var/mob/living/carbon/human/new_body = new /mob/living/carbon/human(src, new_dna.species, delay_ready_dna = TRUE)
	new_body.dna = new_dna
	new_body.real_name = new_dna.real_name
	new_body.flavor_text = new_dna.flavor_text
	new_body.ckey = brainmob.ckey
	brainmob.ckey = null
	brainmob.mind?.transfer_to(new_body)
	to_chat(new_body, "<span class='notice'><b>You suddenly awaken inside some strange machine.</b></span>")
	if(new_body.mind?.miming) //yes I know I'm using the forbidden operator
		new_body.add_spell(new /spell/aoe_turf/conjure/forcewall/mime, "grey_spell_ready")
		if(new_body.mind.miming == MIMING_OUT_OF_CHOICE)
			new_body.add_spell(new /spell/targeted/oathbreak/)
	new_body.UpdateAppearance()
	for(var/datum/language/L in brainmob.languages)
		new_body.add_language(L.name)
	qdel(O)
	new_body.forceMove(output)
	new_body.rejuvenate(animation = TRUE)
