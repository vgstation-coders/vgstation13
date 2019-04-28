///////////////ANTIBODY SCANNER///////////////

/obj/item/device/antibody_scanner
	name = "antibody scanner"
	desc = "Used to scan living beings for antibodies in their blood."
	icon_state = "antibody"
	w_class = W_CLASS_SMALL
	item_state = "electronic"
	flags = FPRINT
	siemens_coefficient = 1


/obj/item/device/antibody_scanner/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!istype(M))
		to_chat(user, "<span class='notice'>Incompatible object, scan aborted.</span>")
		return
	/* var/mob/living/carbon/C = M
	TODO: VIRO REWRITE PART 2
	if(!C.antibodies)
		to_chat(user, "<span class='notice'>Unable to detect antibodies.</span>")
		return
	var/code = antigens2string(M.antibodies)
	to_chat(user, "<span class='notice'>[bicon(src)] \The [src] displays a cryptic set of data: [code]</span>")
	*/

///////////////VIRUS DISH///////////////

/obj/item/weapon/virusdish
	name = "virus containment/growth dish"
	icon = 'icons/obj/virology.dmi'
	icon_state = "virusdish"
	w_class = W_CLASS_SMALL
	var/growth = 0
	var/info = 0
	var/analysed = 0
	var/datum/disease2/disease/contained_virus
	var/open = FALSE

	var/cloud_delay = 8 SECONDS//similar to a mob's breathing
	var/last_cloud_time = 0
	var/mob/last_openner


/obj/item/weapon/virusdish/Destroy()
	contained_virus = null
	processing_objects.Remove(src)
	..()

/obj/item/weapon/virusdish/clean_blood()
	..()
	if (open)
		contained_virus = null
		update_icon()

/obj/item/weapon/virusdish/update_icon()
	overlays.len = 0
	if (!contained_virus)
		if (open)
			icon_state = "virusdish1"
		else
			icon_state = "virusdish"
		return
	icon_state = "virusdish-outline"
	var/image/I1 = image(icon,src,"virusdish-bottom")
	I1.color = contained_virus.color
	var/image/I2 = image(icon,src,"pattern-[contained_virus.pattern]")
	I2.color = contained_virus.pattern_color
	var/image/I3 = image(icon,src,"virusdish-[open?"open":"closed"]")
	I3.color = contained_virus.color
	overlays += I1
	if (open)
		overlays += I3
		I2.alpha = growth*255/200+127
		overlays += I2
	else
		overlays += I2
		overlays += I3
		I2.alpha = (growth*255/200+127)*60/100
		overlays += I2
		var/image/I4 = image(icon,src,"virusdish-reflection")
		overlays += I4

/obj/item/weapon/virusdish/attack_hand(var/mob/user)
	..()
	infection_attempt(user)

/obj/item/weapon/virusdish/attack_self(var/mob/user)
	open = !open
	update_icon()
	to_chat(user,"<span class='notice'>You [open?"open":"close"] dish's lid.</span>")
	if (open)
		last_openner = user
		if (contained_virus)
			contained_virus.log += "<br />[timestamp()] Containment Dish openned by [key_name(user)]."
		processing_objects.Add(src)
	else
		if (contained_virus)
			contained_virus.log += "<br />[timestamp()] Containment Dish closed by [key_name(user)]."
		processing_objects.Remove(src)
	infection_attempt(user)

/obj/item/weapon/virusdish/process()
	if (!contained_virus || !(contained_virus.spread & SPREAD_AIRBORNE))
		processing_objects.Remove(src)
		return
	if(world.time - last_cloud_time >= cloud_delay)
		last_cloud_time = world.time
		var/list/L = list()
		L["[contained_virus.uniqueID]"] = contained_virus
		getFromPool(/obj/effect/effect/pathogen_cloud/core,get_turf(src), last_openner, virus_copylist(L))
		return 1
	return 0

/obj/item/weapon/virusdish/random
	name = "virus sample"

/obj/item/weapon/virusdish/random/New(loc)
	..(loc)
	var/virus_choice = pick(typesof(/datum/disease2/disease))
	contained_virus = new virus_choice
	contained_virus.makerandom()
	growth = rand(5, 50)
	update_icon()

/obj/item/weapon/virusdish/attackby(var/obj/item/weapon/W as obj,var/mob/living/carbon/user as mob)
	..()
	if(istype(W,/obj/item/weapon/hand_labeler) || istype(W,/obj/item/weapon/reagent_containers/syringe))
		return
	if(user.a_intent == I_HURT)
		visible_message("<span class='danger'>The virus dish is smashed to bits!</span>")
		shatter(user)

/obj/item/weapon/virusdish/throw_impact(atom/hit_atom, var/speed, mob/user)
	..()
	if(isturf(hit_atom))
		visible_message("<span class='danger'>The virus dish shatters on impact!</span>")
		shatter(user)

/obj/item/weapon/virusdish/proc/shatter(var/mob/user)
	var/obj/effect/decal/cleanable/virusdish/dish = new(get_turf(src))
	dish.pixel_x = pixel_x
	dish.pixel_y = pixel_y
	if (contained_virus)
		dish.contained_virus = contained_virus.getcopy()
	dish.last_openner = key_name(user)
	src.transfer_fingerprints_to(dish)
	playsound(get_turf(src), "shatter", 70, 1)
	var/image/I1
	var/image/I2
	if (contained_virus)
		I1 = image(icon,src,"brokendish-color")
		I1.color = contained_virus.color
		I2 = image(icon,src,"pattern-[contained_virus.pattern]b")
		I2.color = contained_virus.pattern_color
	else
		I1 = image(icon,src,"brokendish")
	dish.overlays += I1
	if (contained_virus)
		dish.overlays += I2
		contained_virus.log += "<br />[timestamp()] Containment Dish shattered by [key_name(user)]."
		if (contained_virus.spread & SPREAD_AIRBORNE)
			var/strength = contained_virus.infectionchance
			var/list/L = list()
			L["[contained_virus.uniqueID]"] = contained_virus
			while (strength > 0)
				getFromPool(/obj/effect/effect/pathogen_cloud/core,get_turf(src), user, virus_copylist(L))
				strength -= 40
	qdel(src)

/obj/item/weapon/virusdish/examine(mob/user)
	..()
	if(open)
		to_chat(user, "<span class='notice'>Its lid is open!</span>")
	else
		to_chat(user, "<span class='notice'>Its lid is closed!</span>")
	if(src.info)
		to_chat(user, "<span class='info'>It has the following information about its contents</span>")
		to_chat(user, src.info)


/obj/item/weapon/virusdish/infection_attempt(var/mob/living/perp,var/datum/disease2/disease/D)
	if (open)//If the dish is open, we may get infected by the disease inside on top of those that might be stuck on it.
		var/block = 0
		var/bleeding = 0
		if (src in perp.held_items)
			block = perp.check_contact_sterility(HANDS)
			bleeding = perp.check_bodypart_bleeding(HANDS)
			if (!block)
				if (contained_virus.spread & SPREAD_CONTACT)
					perp.infect_disease2(contained_virus, notes="(Contact, from picking up \a [src])")
				else if (bleeding && (contained_virus.spread & SPREAD_BLOOD))
					perp.infect_disease2(contained_virus, notes="(Blood, from picking up \a [src])")
		else if (isturf(loc) && loc == perp.loc)//is our perp standing over the open dish?
			if (perp.lying)
				block = perp.check_contact_sterility(FULL_TORSO)
				bleeding = perp.check_bodypart_bleeding(FULL_TORSO)
			else
				block = perp.check_contact_sterility(FEET)
				bleeding = perp.check_bodypart_bleeding(FEET)
			if (!block)
				if (contained_virus.spread & SPREAD_CONTACT)
					perp.infect_disease2(contained_virus, notes="(Contact, from [perp.lying?"lying":"standing"] over a virus dish[last_openner ? " openned by [key_name(last_openner)]" : ""])")
				else if (bleeding && (contained_virus.spread & SPREAD_BLOOD))
					perp.infect_disease2(contained_virus, notes="(Blood, from [perp.lying?"lying":"standing"] over a virus dish[last_openner ? " openned by [key_name(last_openner)]" : ""])")
	..(perp,D)

///////////////GNA DISK///////////////

/obj/item/weapon/disk/disease
	name = "blank GNA disk"
	desc = "A disk for storing the structure of a pathogen's Glycol Nucleic Acid pertaining to a specific symptom."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "disk_virus"
	var/datum/disease2/effect/effect = null
	var/stage = 1

/obj/item/weapon/disk/disease/premade/New()
	name = "blank GNA disk (stage: [stage])"
	effect = new /datum/disease2/effect

/obj/item/weapon/disk/disease/zombie
	name = "\improper Stubborn Brain Syndrome (Stage 4)"
	effect = new /datum/disease2/effect/zombie
	stage = 4
