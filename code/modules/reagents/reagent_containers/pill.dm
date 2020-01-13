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
	w_type = RECYK_METAL
	attack_delay = 0 //so you don't get a delay after pilling someone. as of the time of writing, this only applies to mobs, remove if in the future this allows you to kenshiro windows

/obj/item/weapon/reagent_containers/pill/New()
	..()
	if(!icon_state)
		icon_state = "pill[rand(1,20)]"

/obj/item/weapon/reagent_containers/pill/attack_self(mob/user as mob)
	return attack(user, user) //Dealt with in attack code

/obj/item/weapon/reagent_containers/pill/attack(mob/M as mob, mob/user as mob, def_zone)
	return try_feed(M, user)

// Handles pill dissolving in containers
/obj/item/weapon/reagent_containers/pill/afterattack(var/obj/item/weapon/reagent_containers/target, var/mob/user, var/adjacency_flag, var/click_params)
	if(!adjacency_flag || !istype(target) || !target.is_open_container())
		return

	if(src.is_empty())
		to_chat(user, "<span class='notice'>\The [src] seems to be empty, somehow. It dissolves away.</span>")
		qdel(src)

	if(target.is_full())
		to_chat(user, "<span class='notice'>\The [target] is full!</span>")
		return

	var/tx_amount = reagents.trans_to(target, reagents.total_volume, log_transfer = TRUE, whodunnit = user)
	if(tx_amount <= 0)
		to_chat(user, "<span class='warning'>You can't seem to be able to crush \the [src] into \the [target]. Make a bug report!</span>")
		return

	if(src.is_empty())
		user.visible_message("<span class='warning'>[user] crushes a pill into \the [target].</span>", \
			self_message = "<span class='notice'>You crush \the [src] into \the [target].[target.is_full()? " It is now full." : ""]</span>", range = 2)
		qdel(src)
	else
		user.visible_message("<span class='warning'>[user] crushes a pill into \the [target].</span>", \
			self_message = "<span class='notice'>You partially crush \the [src] into \the [target].[target.is_full()? " It is now full." : ""]</span>", range = 2)

/obj/item/weapon/reagent_containers/pill/proc/try_feed(mob/target, mob/user)
	// Feeding others needs time to succeed
	if (user != target && (ishuman(target) || ismonkey(target)))
		user.visible_message("<span class='warning'>[user] attempts to force [target] to swallow \the [src].</span>", "<span class='notice'>You attempt to force [target] to swallow \the [src].</span>")

		if (!do_mob(user, target))
			return 1

		user.visible_message("<span class='warning'>[user] forces [target] to swallow \the [src].</span>", "<span class='notice'>You force [target] to swallow \the [src].</span>")
		add_attacklogs(user, target, "fed", object = src, addition = "Reagents: [english_list(list(reagentlist(src)))]", admin_warn = TRUE)
	else if (user == target)
		user.visible_message("<span class='notice'>[user] swallows \the [src].</span>", "<span class='notice'>You swallow \the [src].</span>")
	else
		return 0

	user.drop_from_inventory(src) // Update icon
	if (ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.species.chem_flags & NO_EAT)
			src.forceMove(get_turf(H))
			H.visible_message("<span class='warning'>\The [src] falls through and onto the ground.</span>", "<span class='notice'>You hear \the [src] plinking around for a second before it hits the ground below you.</span>")
			return
	ingest(target)

/obj/item/weapon/reagent_containers/pill/bite_act(mob/user)
	try_feed(user, user)

//OOP, HO!
/obj/item/weapon/reagent_containers/pill/proc/ingest(mob/M as mob)
	if(!reagents)
		return
	if(!M)
		return
	if(!src.is_empty())
		reagents.reaction(M, INGEST)
		reagents.trans_to(M, reagents.total_volume)
	qdel(src)

/obj/item/weapon/reagent_containers/pill/fits_in_iv_drip()
	return 1

/obj/item/weapon/reagent_containers/pill/should_qdel_if_empty() //If you remove the reagents from this thing via smoke or IV drip or something, it shouldn't like it.
	return 1													//This isn't an on_reagent_change() because so many things runtime if it is.

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
	/* Possible choices:
	Good: Hyperzine, Oxycodone, Doctor's Delight, Leporazine
	Neutral: Corn Oil, Ryetalyn, Tonio, Space Drugs
	Bad: Mutagen, Polytrinic Acid, Lexorin, Zombie Powder
	*/
	var/list/possible_combinations = list(
		list(HYPERZINE = 10),
		list(OXYCODONE = 10),
		list(DOCTORSDELIGHT = 10),
		list(LEPORAZINE = 10),
		list(CORNOIL = 10),
		list(RYETALYN = 10),
		list(TONIO = 10),
		list(SPACE_DRUGS = 10),
		list(MUTAGEN = 10),
		list(PACID = 10),
		list(LEXORIN = 10),
		list(ZOMBIEPOWDER = 10)
	)

/obj/item/weapon/reagent_containers/pill/random/New()
	. = ..()
	var/list/to_spawn = pickweight(possible_combinations)
	for(var/index in to_spawn)
		reagents.add_reagent(index, to_spawn[index])


/obj/item/weapon/reagent_containers/pill/random/maintenance
	flags = FPRINT | NOREACT
	possible_combinations = list(
		list(SYNTHOCARISOL = 10, BICARIDINE = 10) = 2, // = 2 means 2 times as common, = 0.5 means 50% as common
		list(KELOTANE = 10, DERMALINE = 10) = 2,
		list(COCAINE = 14),
		list(TRICORDRAZINE = 30) = 2,
		list(DOCTORSDELIGHT = 30),
		list(REZADONE = 7),
		list(IMIDAZOLINE = 10),
		list(OXYCODONE = 15),
		list(NUKA_COLA = 15),
		list(HOLYWATER = 30),
		list(PHAZON = 10),
		list(LITHOTORCRAZINE = 20, GREYVODKA = 20),
		list(MINDBREAKER = 10, SPACE_DRUGS = 10) = 3,
		list(ANTHRACENE = 25),
		list(CHILLWAX = 20),
		list(DISCOUNT = 50),
		list(CORNOIL = 50),
		list(BAD_TOUCH = 15, STOXIN = 10), // hallucination damage!
		list(SUICIDE = 20, DISCOUNT = 30), // makes you vomit a lot
		list(LIPOZINE = 25), // makes you hungry as hell
		list(DANS_WHISKEY = 30),
		list(CRYPTOBIOLIN = 10),
		list(SILENCER = 20),
		list(ZOMBIEPOWDER = 10),
		list(NEUROTOXIN = 15),
		list(STOXIN = 20),
		list(HEMOSCYANINE = 20),
		list(MUTAGEN = 10),
		list(FROSTOIL = 15), // makes you freeze and pass out, but not lethal
		list(HELL_RAMEN = 2, CONDENSEDCAPSAICIN = 15), // seriously burns your shit up but hopefully doesn't kill. feel free to replace with a reagent that does this better if one is added in the future
		list(RADIUM = 10),
		list(IMPEDREZENE = 10),
		list(AMINOCYPRINIDOL = 1, NUTRIMENT = 10),
		list(SPIDERS = 20),
		list(IRON = 25, URANIUM = 25),
		list(PHOSPHORUS = 10, POTASSIUM = 10, SUGAR = 10),
		list(LUBE = 10, FLUOROSURFACTANT = 10, WATER = 10),
		list(DETCOFFEE = 5) = 0.5, // you can hear it just by reading this
		list(FISHBLEACH = 5) = 0.25,
		list(POTASSIUM = 15, WATER = 15) = 0.25,
		list(BLEACH = 10, AMMONIA = 10) = 0.25,
		list(DANBACCO = 5) = 0.25, // uh ohh
		list(DEGENERATECALCIUM = 2) = 0.25 // he he
	)

/obj/item/weapon/reagent_containers/pill/random/maintenance/New()
	. = ..()
	name = "\improper [pick( \
		3000;"floor", 1000;"funny", 1000;"mystery", 1000;"adventure", 1000;"double-dog dare", 1000;"suspicious", 1000;"happy happy", 500;"heal", 500;"handmade", \
		"the cure part 1", "Werewolf Serum (10 units)", "help me", "5u Of Everything", "Quadcordrazine", "Delicious candy", "EAT IF YOU", "Anticarisol (10 units)", "Fix And Fun", \
		"FUN TIME - ONLY TAKE 1", "violent suicide", "STRONG BONES PILL CONSULT YOUR DOCTOR BEFORE USING", "SKELETON+3 arms (CAUTION!!!)", "Tricordrazine (1.5 units)", \
		"pill for big mistakes", "ANTIBODIES 5 OH GOD OG FUCK", "Antibodies for the Horrible Spider Plague", "Antibodies for beard growing disease pill", "antibodies for the beneficial virus", \
		"antibodies for virus that makes your legs go bad please take one", "antibodies for weird disease thing", "Antibodies for your body disintegrating (1 units)", "antibodies hopefully", \
		"Antibodies to being vegan (5 mg)", "Cure for  Optimism", "IT FUCKING CURES THE VIRUS BUDDY, EAT IT NOW", "The Doctor", "Bleach (HIGHLY USELESS AND TOXIC)", \
		"Blood Of Unknown Type (49.9996 units)", "crayo mix", "Drift to Sleep. (THIS IS GOING TO KILL YOU PLEASE DO NOT EAT UNLESS YOU WANT TO DIE)", "dude (16.3333 units)", \
		"get well soon(15.1667 units with antitoxin)", "I want to die", "If you want to suffer, eat this (10.8889 units)", "Just eat these until you feel better (4.5911 units)", \
		"now i cant even fucking see (10.7919 units)", "Problem Fixer(5 units)", "Rapid Limb Regrowth", "Runfast (29.8817 units)", "Sleeping Dragon Suicide Pill", \
		"Special pill only for You", "Test Batch #001 (25 units)", "The Utlimate trip", "Tumor and Cancer (5 units)", "turns you into a slime", "Unfuck me pill", \
		"Unstable mutagen (0 units)", "VERY FUN DO NOT CONSUME", "Very Healthy!(may cause side effects)", "Wild Ride enhancer", "MORE TAN 1 IS DEADLY", "Oh Fuck My Blood pills", \
		"Emergency Pain Relief", "Blood Strengthening Pill (10 units)", "Literal Death", "Makes You Into The Captain", "plese send help stuck in chemistry", \
		"antiubodies for the disease that makes you scream.", "Xenomicrobes (1 unit)", "Miracle butt heal", "lesser death", "All-Natural", "still fucking hurts doc")] pill"
	desc = pick(300;"A strange pill found in the depths of maintenance.", "Just what the doctor ordered.", "Hey, look! Free healthcare!", "For best results, take one as close to noon as possible.")
	icon_state = "pill[rand(20,40)]"

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


/obj/item/weapon/reagent_containers/pill/nanofloxacin
	name = "nanofloxacin pill"
	desc = "Extremely powerful antipathogenic, one dose is enough to cure almost any diseases."
	icon_state = "pill30"

/obj/item/weapon/reagent_containers/pill/nanofloxacin/New()
	..()
	reagents.add_reagent(NANOFLOXACIN, 1)
