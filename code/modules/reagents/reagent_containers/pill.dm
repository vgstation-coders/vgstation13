////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/pill
	name = "pill"
	desc = "A small capsule of dried chemicals, used to administer medicine and poison alike in one easy serving."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	item_state = "pill"
	possible_transfer_amounts = null
	volume = 100
	starting_materials = null
//	starting_materials = list(MAT_IRON = 5) //What?
	w_type = RECYK_METAL

/obj/item/weapon/reagent_containers/pill/New()
	..()
	if(!icon_state)
		icon_state = "pill[rand(1,20)]"

/obj/item/weapon/reagent_containers/pill/attack_self(mob/user as mob)

	return attack(user, user) //Dealt with in attack code

/obj/item/weapon/reagent_containers/pill/attack(mob/M as mob, mob/user as mob, def_zone)
	// Feeding others needs time to succeed
	if (user != M && (ishuman(M) || ismonkey(M)))
		user.visible_message("<span class='warning'>[user] attempts to force [M] to swallow \the [src].</span>", "<span class='notice'>You attempt to force [M] to swallow \the [src].</span>")

		if (!do_mob(user, M))
			return 1

		user.visible_message("<span class='warning'>[user] forces [M] to swallow \the [src].</span>", "<span class='notice'>You force [M] to swallow \the [src].</span>")
		add_attacklogs(user, M, "fed", object = src, addition = "Reagents: [english_list(list(reagentlist(src)))]", admin_warn = TRUE)
	else if (user == M)
		user.visible_message("<span class='notice'>[user] swallows \the [src].</span>", "<span class='notice'>You swallow \the [src].</span>")
	else
		return 0

	user.drop_from_inventory(src) // Update icon
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.chem_flags & NO_EAT)
			src.forceMove(get_turf(H))
			H.visible_message("<span class='warning'>\The [src] falls through and onto the ground.</span>", "<span class='notice'>You hear \the [src] plinking around for a second before it hits the ground below you.</span>")
			return 0
	ingest(M)
	return 1

// Handles pill dissolving in containers
/obj/item/weapon/reagent_containers/pill/afterattack(var/obj/item/weapon/reagent_containers/target, var/mob/user, var/adjacency_flag, var/click_params)
	if (!adjacency_flag || !istype(target) || !target.is_open_container())
		return

	var/target_was_empty = (target.reagents.total_volume == 0)
	var/tx_amount = reagents.trans_to(target, reagents.total_volume, log_transfer = TRUE, whodunnit = user)

	// Show messages
	if (tx_amount > 0)
		user.visible_message("<span class='warning'>[user] puts something into \the [target], filling it.</span>")
		if (src.is_empty())
			to_chat(user, "<span class='notice'>You [target_was_empty ? "crush" : "dissolve"] the pill into \the [target].</span>")
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You [target_was_empty ? "crush partially" : "partially dissolve"] the pill into \the [target], filling it.</span>")
	else
		to_chat(user, "<span class='notice'>\The [target] is full!</span>")

//OOP, HO!
/obj/item/weapon/reagent_containers/pill/proc/ingest(mob/M as mob)
	if(!reagents)
		return
	if(!M)
		return
	if (!src.is_empty())
		reagents.reaction(M, INGEST)
		reagents.trans_to(M, reagents.total_volume)
	qdel(src)

////////////////////////////////////////////////////////////////////////////////
/// Pills. END
////////////////////////////////////////////////////////////////////////////////

//Pills
/obj/item/weapon/reagent_containers/pill/creatine
	name = "Creatine Suicide Pill (50 units)"
	desc = "WILL ALSO KILL YOU VIOLENTLY."
	icon_state = "pill5" //bright red oblong with stripe

/obj/item/weapon/reagent_containers/pill/creatine/New()
	..()
	reagents.add_reagent(CREATINE, 50)
	
/obj/item/weapon/reagent_containers/pill/laststand
	name = "Creatine \"Last Stand\" suicide pill"
	desc = "For when you really want to spend your last moments punching things to death."
	icon_state = "pill5" //bright red oblong with stripe

/obj/item/weapon/reagent_containers/pill/laststand/New()
	..()
	reagents.add_reagent(DEXALINP, 5) //STOP LAYING AROUND
	reagents.add_reagent(MEDNANOBOTS, 0.4) //GET UP
	reagents.add_reagent(HYPOZINE, 5) //GO FAST
	reagents.add_reagent(COMNANOBOTS, 4.6) //FIGHT HARD
	reagents.add_reagent(OXYCODONE, 5) //NO PAIN
	reagents.add_reagent(CREATINE, 30) //ONLY FIST

/obj/item/weapon/reagent_containers/pill/antitox
	name = "Anti-toxins pill"
	desc = "Neutralizes many common toxins."
	icon_state = "pill14" //green round plain

/obj/item/weapon/reagent_containers/pill/antitox/New()
	..()
	reagents.add_reagent(ANTI_TOXIN, 25)

/obj/item/weapon/reagent_containers/pill/tox
	name = "Toxins pill"
	desc = "Highly toxic."
	icon_state = "pill5" //bright red oblong with stripe

/obj/item/weapon/reagent_containers/pill/tox/New()
	..()
	reagents.add_reagent(TOXIN, 50)

/obj/item/weapon/reagent_containers/pill/cyanide
	name = "Cyanide pill"
	desc = "Don't swallow this."
	icon_state = "pill5" //bright red oblong with stripe

/obj/item/weapon/reagent_containers/pill/cyanide/New()
	..()
	reagents.add_reagent(CYANIDE, 50)

/obj/item/weapon/reagent_containers/pill/adminordrazine
	name = "Adminordrazine pill"
	desc = "It's magic. We don't have to explain it."
	icon_state = "pill6" //cyan-brown oblong

/obj/item/weapon/reagent_containers/pill/adminordrazine/New()
	..()
	reagents.add_reagent(ADMINORDRAZINE, 50)

/obj/item/weapon/reagent_containers/pill/stox
	name = "Sleeping pill"
	desc = "Commonly used to treat insomnia."
	icon_state = "pill11" //light blue round

/obj/item/weapon/reagent_containers/pill/stox/New()
	..()
	reagents.add_reagent(STOXIN, 30)

/obj/item/weapon/reagent_containers/pill/kelotane
	name = "Kelotane pill"
	desc = "Used to treat burns."
	icon_state = "pill12" //yellow round

/obj/item/weapon/reagent_containers/pill/kelotane/New()
	..()
	reagents.add_reagent(KELOTANE, 30)

/obj/item/weapon/reagent_containers/pill/tramadol
	name = "Tramadol pill"
	desc = "A simple painkiller."
	icon_state = "pill11" //light blue round

/obj/item/weapon/reagent_containers/pill/tramadol/New()
	..()
	reagents.add_reagent(TRAMADOL, 15)

/obj/item/weapon/reagent_containers/pill/citalopram
	name = "Citalopram pill"
	desc = "Mild anti-depressant."
	icon_state = "pill11" //light blue round

/obj/item/weapon/reagent_containers/pill/citalopram/New()
	..()
	reagents.add_reagent(CITALOPRAM, 15)

/obj/item/weapon/reagent_containers/pill/inaprovaline
	name = "Inaprovaline pill"
	desc = "Used to stabilize patients."
	icon_state = "pill9" //magenta/yellow oblong

/obj/item/weapon/reagent_containers/pill/inaprovaline/New()
	..()
	reagents.add_reagent(INAPROVALINE, 30)

/obj/item/weapon/reagent_containers/pill/dexalin
	name = "Dexalin pill"
	desc = "Used to treat oxygen deprivation."
	icon_state = "pill19" //dark blue/blue round

/obj/item/weapon/reagent_containers/pill/dexalin/New()
	..()
	reagents.add_reagent(DEXALIN, 30)

/obj/item/weapon/reagent_containers/pill/bicaridine
	name = "Bicaridine pill"
	desc = "Used to treat physical injuries."
	icon_state = "pill15" //red round

/obj/item/weapon/reagent_containers/pill/bicaridine/New()
	..()
	reagents.add_reagent(BICARIDINE, 30)

/obj/item/weapon/reagent_containers/pill/happy
	name = "Happy pill"
	desc = "Happy happy joy joy!"
	icon_state = "pill7" //grey oblong

/obj/item/weapon/reagent_containers/pill/happy/New()
	..()
	reagents.add_reagent(SPACE_DRUGS, 15)
	reagents.add_reagent(SUGAR, 15)

/obj/item/weapon/reagent_containers/pill/zoom
	name = "Zoom pill"
	desc = "Zoooom!"
	icon_state = "pill7" //grey oblong

/obj/item/weapon/reagent_containers/pill/zoom/New()
	..()
	reagents.add_reagent(IMPEDREZENE, 10)
	reagents.add_reagent(SYNAPTIZINE, 1)
	reagents.add_reagent(HYPERZINE, 10)

/obj/item/weapon/reagent_containers/pill/hyperzine
	name = "Hyperzine pill"
	desc = "Gotta go fast!"

	icon_state = "pill7" //grey oblong
/obj/item/weapon/reagent_containers/pill/hyperzine/New()
	..()
	reagents.add_reagent(HYPERZINE, 10)

/obj/item/weapon/reagent_containers/pill/creatine_safe
	name = "Creatine Pill (26 units)"
	desc = "Become the boss of this Gym."
	icon_state = "pill5" //bright red oblong with stripe

/obj/item/weapon/reagent_containers/pill/creatine_safe/New()
	..()
	reagents.add_reagent(CREATINE, 26)

/obj/item/weapon/reagent_containers/pill/creatine_supplement
	name = "Creatine Supplement (5 units)"
	desc = "Maintain those massive gains!"
	icon_state = "pill6" //cyan/brown oblong

/obj/item/weapon/reagent_containers/pill/creatine_supplement/New()
	..()
	reagents.add_reagent(CREATINE, 5)


/obj/item/weapon/storage/pill_bottle/time_release
	name = "controlled release pill bottle"
	desc = "A bottle containing special pills which can be calibrated for delayed release with sugar."

/obj/item/weapon/storage/pill_bottle/time_release/New()
	..()
	for(var/i=1 to 7)
		new /obj/item/weapon/reagent_containers/pill/time_release(src)

/obj/item/weapon/reagent_containers/pill/time_release
	name = "time release pill"
	desc = "A pill which will not be metabolized until all of the sugar inside metabolizes. By extension, the chemicals inside do not react with one another until entering the body. Unlike other pills, it is specially designed to be compatible with droppers and syringes."
	icon_state = "pill7" //grey oblong
	flags = FPRINT | NOREACT

/obj/item/weapon/reagent_containers/pill/time_release/ingest(mob/M as mob)
	if(!reagents)
		return
	if(!M)
		return
	var/timer = round(reagents.get_reagent_amount(SUGAR),1)
	forceMove(M)
	spawn(timer*30)
		reagents.del_reagent(SUGAR)
		reagents.reaction(M, INGEST)
		reagents.trans_to(M, reagents.total_volume)
		qdel(src)

/obj/item/weapon/storage/pill_bottle/random
	name = "trail mix"
	desc = "Just what the assistant ordered."

/obj/item/weapon/storage/pill_bottle/random/New()
	..()
	for(var/i=1 to 14)
		new /obj/item/weapon/reagent_containers/pill/random(src)

/obj/item/weapon/reagent_containers/pill/random
	name = "unknown pill"
	desc = "Dare you enter my chemical realm?"

/obj/item/weapon/reagent_containers/pill/random/New()
	..()
	var/chemical = pick(HYPERZINE, OXYCODONE, DOCTORSDELIGHT, LEXORIN, LEPORAZINE, MUTAGEN, RYETALYN, PACID, CORNOIL, TONIO, SPACE_DRUGS,ZOMBIEPOWDER)
	reagents.add_reagent(chemical, 10)
	/* Possible choices:
	Good: Hyperzine, Oxycodone, Doctor's Delight, Leporazine
	Neutral: Corn Oil, Ryetalyn, Tonio, Space Drugs
	Bad: Mutagen, Polytrinic Acid, Lexorin, Zombie Powder
	*/

/obj/item/weapon/reagent_containers/pill/nanobot
	name = "nanobot pill"
	desc = "Experimental medication."
	icon_state = "pill7" //grey oblong

/obj/item/weapon/reagent_containers/pill/nanobot/New()
	..()
	reagents.add_reagent(NANOBOTS, 1)

/obj/item/weapon/reagent_containers/pill/hyronalin
	name = "hyronalin pill"
	desc = "Radiation poisoning treatment."
	icon_state = "pill14" //green round plain

/obj/item/weapon/reagent_containers/pill/hyronalin/New()
	..()
	reagents.add_reagent(HYRONALIN, 20)

/obj/item/weapon/reagent_containers/pill/arithrazine
	name = "arithrazine pill"
	desc = "Extreme radiation sickness treatment."
	icon_state = "pill6"

/obj/item/weapon/reagent_containers/pill/arithrazine/New()
	..()
	reagents.add_reagent(ARITHRAZINE, 10)
