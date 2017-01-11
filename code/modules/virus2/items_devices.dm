///////////////ANTIBODY SCANNER///////////////

/obj/item/device/antibody_scanner
	name = "Antibody Scanner"
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
	var/mob/living/carbon/C = M
	if(!C.antibodies)
		to_chat(user, "<span class='notice'>Unable to detect antibodies.</span>")
		return
	var/code = antigens2string(M.antibodies)
	to_chat(user, "<span class='notice'>[src] The antibody scanner displays a cryptic set of data: [code]</span>")

///////////////VIRUS DISH///////////////

/obj/item/weapon/virusdish
	name = "Virus containment/growth dish"
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"
	var/datum/disease2/disease/virus2 = null
	var/growth = 0
	var/info = 0
	var/analysed = 0

/obj/item/weapon/virusdish/random
	name = "Virus Sample"

/obj/item/weapon/virusdish/random/New(loc)
	..(loc)
	virus2 = new /datum/disease2/disease
	virus2.makerandom()
	growth = rand(5, 50)

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
	if(virus2.infectionchance > 0)
		for(var/mob/living/carbon/target in view(1, get_turf(src)))
			if(airborne_can_reach(get_turf(src), get_turf(target)))
				if(get_infection_chance(target))
					infect_virus2(target,src.virus2, notes="([src] shattered by [key_name(user)])")
	qdel(src)

/obj/item/weapon/virusdish/examine(mob/user)
	..()
	if(src.info)
		to_chat(user, "<span class='info'>It has the following information about its contents</span>")
		to_chat(user, src.info)

///////////////GNA DISK///////////////

/obj/item/weapon/diseasedisk
	name = "Blank GNA disk"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk0"
	var/datum/disease2/effect/effect = null
	var/stage = 1

/obj/item/weapon/diseasedisk/premade/New()
	name = "Blank GNA disk (stage: [stage])"
	effect = new /datum/disease2/effect
