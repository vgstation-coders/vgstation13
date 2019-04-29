/obj/item/organ/internal/brain
	name = "brain"
	health = 400 //They need to live awhile longer than other organs.
	desc = "A piece of juicy meat found in a person's head."
	icon_state = "brain2"
	flags = 0
	force = 1.0
	w_class = W_CLASS_TINY
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = Tc_BIOTECH + "=3"
	attack_verb = list("attacks", "slaps", "whacks")
	prosthetic_name = "cyberbrain"
	prosthetic_icon = "brain-prosthetic"
	organ_tag = "brain"
	organ_type = /datum/organ/internal/brain
	//nonplant_seed_type = /obj/item/seeds/synthbrainseed

	var/mob/living/carbon/brain/brainmob = null

/obj/item/organ/internal/brain/New()
	..()
	spawn(5)
		if(brainmob && brainmob.client)
			brainmob.client.screen.len = null //clear the hud

/obj/item/organ/internal/brain/proc/transfer_identity(var/mob/living/carbon/H)
	name = "[H.real_name]'s brain"
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	if(istype(H) && H.dna)
		brainmob.dna = H.dna.Clone()
	brainmob.timeofhostdeath = H.timeofdeath
	if(H.mind)
		H.mind.transfer_to(brainmob)

	to_chat(brainmob, "<span class='notice'>You feel slightly disoriented. That's normal when you're just a brain.</span>")
	callHook("debrain", list(brainmob))

/obj/item/organ/internal/brain/examine(mob/user)
	..()
	if(brainmob)
		if(brainmob.client)
			to_chat(user, "<span class='notice'>You can feel the small spark of life still left in this one.</span>")
			return
		var/mob/dead/observer/ghost = mind_can_reenter(brainmob.mind)
		if(ghost)
			var/mob/ghostmob = ghost.get_top_transmogrification()
			if(ghostmob)
				to_chat(user, "<span class='deadsay'>It seems particularly lifeless, but not yet gone. Perhaps it will regain some of its luster later...</span>")
				return
			to_chat(user, "<span class='deadsay'>This one seems unresponsive.</span>")// Should probably make this more realistic, but this message ties it in with MMI errors.
			return

/obj/item/organ/internal/brain/removed(var/mob/living/target,var/mob/living/user)

	..()

	var/mob/living/carbon/human/H = target
	H.dropBorers()
	var/obj/item/organ/internal/brain/B = src
	if(istype(B) && istype(H))
		B.transfer_identity(target)

/obj/item/organ/internal/brain/replaced(var/mob/living/target)

	if(target.key)
		target.ghostize()

	if(brainmob)
		if(brainmob.mind)
			brainmob.mind.transfer_to(target)
		else
			target.key = brainmob.key

/obj/item/organ/internal/brain/ash/removed(var/mob/living/target,var/mob/living/user)
	..()
	visible_message("<span class = 'sinister'>\The [src] suddenly turns to ash, unable to exist detached from its host.</span>")
	new /obj/effect/decal/cleanable/ash(loc)
	qdel(src)

/obj/item/organ/internal/brain/slime_core
	name = "crystallized slime core"
	desc = "The crystallized core of a slime person."
	icon_state = "slime_person_core"
	organ_type = /datum/organ/internal/brain/slime_core

/obj/item/organ/internal/brain/slime_core/process()
	processing_objects -= src

/obj/item/organ/internal/brain/mushroom
	name = "plump helmet brain"
	desc = "At first glance, it looks like a popular miner delicacy, but is in fact the primary function of thought for a mushroom person."
	icon_state = "plump_pie"
	icon = 'icons/obj/food.dmi'
	health = 600
	origin_tech = Tc_BIOTECH + "=4"