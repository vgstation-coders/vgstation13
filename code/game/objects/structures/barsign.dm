/*
 * TODO:
 * Decide if we need fingerprints on this obj
 * Decide which other mob can use this
 * Sprite bar sign that is destroyed
 * Sprite bar sign that is unpowered
 * Add this obj to power consumers
 * Decide how much power this uses
 * Make this constructable with a decided step how to construct it
 * Make this deconstructable with a decided step how to deconstruct it
 * Decide what materials are used for this obj
 * Logic for area because it's a two tile consuming obj
 * Is this obj can be emagged? if yes what can be the trace that this obj is emagged?
 *									(I suggest broken ID authentication wiring)
 * Need more frames for existing bar signs (icons/obj/barsigns.dmi)
 * An ID scanner that will makes sound and
 *		output something that's the access has been granted
 */

/datum/barsign
	var/icon = "empty"
	var/name = "--------"
	var/desc = null
	var/pixel_x = 0
	var/pixel_y = 0

/datum/barsign/maltesefalcon
	name = "Maltese Falcon"
	icon = "maltesefalcon"
	desc = "Play it again, sam."

/obj/structure/sign/double/barsign	// The sign is 64x32, so it needs two tiles. ;3
	name = "--------"
	desc = "a bar sign"
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "empty"

	req_access = list(access_bar)

	var/sign_name = ""
	var/list/barsigns=list()
	var/cult = 0

/obj/structure/sign/double/barsign/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/sign/double/barsign/attack_hand(mob/user as mob)
	if (!src.allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	barsigns.len = 0
	for(var/bartype in typesof(/datum/barsign))
		var/datum/barsign/signinfo = new bartype
		barsigns[signinfo.name] = signinfo

	pick_sign()

/obj/structure/sign/double/barsign/proc/pick_sign()
	var/picked_name = input("Available Signage", "Bar Sign", "Cancel") as null|anything in barsigns
	if(!picked_name)
		return

	var/datum/barsign/picked = barsigns[picked_name]
	icon_state = picked.icon
	name = picked.name
	if(picked.pixel_x)
		pixel_x = picked.pixel_x * PIXEL_MULTIPLIER
	else
		pixel_x = 0
	if(picked.pixel_y)
		pixel_y = picked.pixel_y * PIXEL_MULTIPLIER
	else
		pixel_y = 0
	if(picked.desc)
		desc = picked.desc
	else
		desc = "It displays \"[name]\"."

/obj/structure/sign/double/barsign/cultify()
	if(!cult)
		icon_state = "narsiebistro"
		name = "Narsie Bistro"
		desc = "The last pub before the World's End."
		cult = 1
		pixel_x = 0 // just to make sure.
		pixel_y = 0

/obj/structure/sign/double/barsign/emp_act()
	icon_state = "empbarsign"
	name = "ERROR"
	desc = "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4#*?"
	pixel_x = 0
	pixel_y = 0
