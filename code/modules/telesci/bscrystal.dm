// Bluespace crystals, used in telescience and when crushed it will blink you to a random turf.

/obj/item/bluespace_crystal
	name = "bluespace crystal"
	desc = "A glowing bluespace crystal, not much is known about how they work. It looks very delicate."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "bluespace_crystal"
	w_class = W_CLASS_TINY
	origin_tech = Tc_BLUESPACE + "=4;" + Tc_MATERIALS + "=3"
	var/blink_range = 8 // The teleport range when crushed/thrown at someone.
	var/blueChargeValue = 3	//For things like mind machine
	toolsounds = list('sound/weapons/blaster.ogg')

/obj/item/bluespace_crystal/New()
	..()
	pixel_x = rand(-5, 5) * PIXEL_MULTIPLIER
	pixel_y = rand(-5, 5) * PIXEL_MULTIPLIER

/obj/item/bluespace_crystal/attack_self(var/mob/user)
	var/datum/zLevel/L = get_z_level(src)
	if(L && !L.teleJammed)
		user.visible_message("<span class='notice'>[user] crushes the [src]!</span>")
		blink_mob(user)
	else
		user.visible_message("<span class='notice'>[user] crushes the [src], but nothing happens!</span>")

	user.drop_item(src, force_drop = 1)
	qdel(src)

/obj/item/bluespace_crystal/proc/blink_mob(var/mob/living/L)
	var/area/A = get_area(src)

	if(A.flags & NO_TELEPORT)
		to_chat(L, "<span class='notice'>You feel strange.</span>")
		return

	do_teleport(L, get_turf(L), blink_range, asoundin = 'sound/effects/phasein.ogg')

/obj/item/bluespace_crystal/throw_impact(atom/hit_atom)
	if(..())
		return
	var/datum/zLevel/L = get_z_level(src)

	if(isliving(hit_atom) && L && !L.teleJammed)
		blink_mob(hit_atom)

	qdel(src)

/obj/item/bluespace_crystal/singularity_act(var/current_size,var/obj/machinery/singularity/S)
	if(istype(src,/obj/item/bluespace_crystal/artificial))
		return ..()
	if(istype(src,/obj/item/bluespace_crystal/flawless) || prob(10))
		if(S.wormhole_out || S.wormhole_in)
			S.unlink_wormholes()
		else if(white_hole_candidates.len > 1)
			S.link_a_wormhole()
		if(istype(src,/obj/item/bluespace_crystal/flawless) && S.wormhole_out)
			var/turf/T = get_turf(S.wormhole_out)
			do_teleport(src, T)
			return 2
	return ..()

// Artifical bluespace crystal, doesn't give you much research.

/obj/item/bluespace_crystal/artificial
	name = "artificial bluespace crystal"
	desc = "An artificially made bluespace crystal, it looks delicate."
	origin_tech = Tc_BLUESPACE + "=2"
	blink_range = 4 // Not as good as the organic stuff!
	blueChargeValue = 1

/obj/item/bluespace_crystal/flawless //Specifically for use with the subspace tunneler
	name = "flawless bluespace crystal"
	desc = "A glowing bluespace crystal, not much is known about how they work. This one appears to be of particularly high quality."
	var/infinite = 1 //Infinite uses by default.
	var/uses = 50 //Can be varedited to any finite number of uses.
	blueChargeValue = 300
	toolsounds = list('sound/weapons/blaster-storm.ogg')
