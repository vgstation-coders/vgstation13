/obj/item/disk/surgery/nerve_splicing
	name = "Nerve Splicing Surgery Disk"
	desc = "The disk provides instructions on how to splice the circulatory system to counter stuns and paralysis."
	surgeries = list(/datum/surgery/advanced/bioware/nerve_splicing)

/datum/surgery/advanced/bioware/nerve_splicing
	name = "nerve splicing"
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/splice_nerves,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	bioware_target = BIOWARE_NERVES

/datum/surgery_step/splice_nerves
	name = "splice nerves"
	accept_hand = TRUE
	time = 155

/datum/surgery_step/splice_nerves/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] starts splicing together [target]'s nerves.", "<span class='notice'>You start splicing together [target]'s nerves.</span>")

/datum/surgery_step/splice_nerves/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] successfully splices [target]'s nervous system!", "<span class='notice'>You successfully splice [target]'s nervous system!</span>")
	new /datum/bioware/spliced_nerves(target)
	return TRUE

/datum/bioware/spliced_nerves
	name = "Spliced Nerves"
	desc = "Nerves are connected to each other multiple times, greatly reducing the impact of stunning effects."
	mod_type = "nerves"

/datum/bioware/spliced_nerves/on_gain()
	..()
	owner.physiology.stun_mod *= 0.5

/datum/bioware/spliced_nerves/on_lose()
	..()
	owner.physiology.stun_mod *= 2