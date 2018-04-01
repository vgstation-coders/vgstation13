/obj/item/paperplane
	name = "paper plane"
	desc = "Paper, folded in the shape of a plane."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paperplane"
	throw_range = 7
	throw_speed = 1
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_integrity = 50

	var/obj/item/paper/internalPaper

/obj/item/paperplane/Initialize(mapload, obj/item/paper/newPaper)
	. = ..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
	if(newPaper)
		internalPaper = newPaper
		flags_1 = newPaper.flags_1
		color = newPaper.color
		newPaper.forceMove(src)
	else
		internalPaper = new /obj/item/paper(src)
	update_icon()

/obj/item/paperplane/Destroy()
	if(internalPaper)
		qdel(internalPaper)
		internalPaper = null
	return ..()

/obj/item/paperplane/suicide_act(mob/living/user)
	user.Stun(200)
	user.visible_message("<span class='suicide'>[user] jams [src] in [user.p_their()] nose. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	user.adjust_blurriness(6)
	user.adjust_eye_damage(rand(6,8))
	sleep(10)
	return (BRUTELOSS)

/obj/item/paperplane/update_icon()
	cut_overlays()
	var/list/stamped = internalPaper.stamped
	if(stamped)
		for(var/S in stamped)
			add_overlay("paperplane_[S]")

/obj/item/paperplane/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You unfold [src].</span>")
	var/atom/movable/internal_paper_tmp = internalPaper
	internal_paper_tmp.forceMove(loc)
	internalPaper = null
	qdel(src)
	user.put_in_hands(internal_paper_tmp)

/obj/item/paperplane/attackby(obj/item/P, mob/living/carbon/human/user, params)
	..()
	if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		to_chat(user, "<span class='notice'>You should unfold [src] before changing it.</span>")
		return

	else if(istype(P, /obj/item/stamp)) 	//we don't randomize stamps on a paperplane
		internalPaper.attackby(P, user) //spoofed attack to update internal paper.
		update_icon()

	else if(P.is_hot())
		if(user.has_trait(TRAIT_CLUMSY) && prob(10))
			user.visible_message("<span class='warning'>[user] accidentally ignites themselves!</span>", \
				"<span class='userdanger'>You miss [src] and accidentally light yourself on fire!</span>")
			user.dropItemToGround(P)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return

		if(!(in_range(user, src))) //to prevent issues as a result of telepathically lighting a paper
			return
		user.dropItemToGround(src)
		user.visible_message("<span class='danger'>[user] lights [src] ablaze with [P]!</span>", "<span class='danger'>You light [src] on fire!</span>")
		fire_act()

	add_fingerprint(user)


/obj/item/paperplane/throw_at(atom/target, range, speed, mob/thrower, spin=FALSE, diagonals_first = FALSE, datum/callback/callback)
	. = ..(target, range, speed, thrower, FALSE, diagonals_first, callback)

/obj/item/paperplane/throw_impact(atom/hit_atom)
	if(..() || !ishuman(hit_atom))//if the plane is caught or it hits a nonhuman
		return
	var/mob/living/carbon/human/H = hit_atom
	if(prob(2))
		if((H.head && H.head.flags_cover & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags_cover & MASKCOVERSEYES) || (H.glasses && H.glasses.flags_cover & GLASSESCOVERSEYES))
			return
		visible_message("<span class='danger'>\The [src] hits [H] in the eye!</span>")
		H.adjust_blurriness(6)
		H.adjust_eye_damage(rand(6,8))
		H.Knockdown(40)
		H.emote("scream")

/obj/item/paper/AltClick(mob/living/carbon/user, obj/item/I)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	to_chat(user, "<span class='notice'>You fold [src] into the shape of a plane!</span>")
	user.temporarilyRemoveItemFromInventory(src)
	I = new /obj/item/paperplane(user, src)
	user.put_in_hands(I)
