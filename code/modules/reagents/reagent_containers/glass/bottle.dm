
//Not to be confused with /obj/item/weapon/reagent_containers/food/drinks/bottle

/obj/item/weapon/reagent_containers/glass/bottle
	name = "bottle"
	desc = "A small bottle."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle"
	item_state = "atoxinbottle"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30)
	flags = FPRINT  | OPENCONTAINER
	volume = 30
	starting_materials = list(MAT_GLASS = 1000)
	w_type = RECYK_GLASS
	melt_temperature = MELTPOINT_GLASS
	origin_tech = Tc_MATERIALS + "=1"

/obj/item/weapon/reagent_containers/glass/bottle/New(loc,altvol)
	if(altvol)
		volume = altvol
	..(loc)

//JUST
/obj/item/weapon/reagent_containers/glass/bottle/mop_act(obj/item/weapon/mop/M, mob/user)
	if(..())
		if(src.reagents.total_volume >= 1)
			if(M.reagents.total_volume >= 1)
				to_chat(user, "<span class='notice'>You dip \the [M]'s tip into \the [src] but don't soak anything up.</span>")
				return 1
			else
				src.reagents.trans_to(M, 1)
				to_chat(user, "<span class='notice'>You barely manage to wet [M]</span>")
				playsound(src, 'sound/effects/slosh.ogg', 25, 1)
		else
			to_chat(user, "<span class='notice'>Nothing left to wet [M] with!</span>")
		return 1

/obj/item/weapon/reagent_containers/glass/bottle/on_reagent_change()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/bottle/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/bottle/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/bottle/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/bottle/update_icon()
	overlays.len = 0

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]5")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent) //Percentages are pretty fucked so here comes the decimal rollercoaster with halfway rounding
			if(0 to 24)
				filling.icon_state = "[icon_state]5"
			if(25 to 41)
				filling.icon_state = "[icon_state]10"
			if(42 to 58)
				filling.icon_state = "[icon_state]15"
			if(59 to 74)
				filling.icon_state = "[icon_state]20"
			if(75 to 91)
				filling.icon_state = "[icon_state]25"
			if(92 to INFINITY)
				filling.icon_state = "[icon_state]30"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)
		overlays += filling

	if(!is_open_container())
		var/image/lid = image(icon, src, "lid_[initial(icon_state)]")
		overlays += lid

/obj/item/weapon/reagent_containers/glass/bottle/unrecyclable
	starting_materials = null

/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline
	name = "inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	reagents_to_add = INAPROVALINE

/obj/item/weapon/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle of toxins. Do not drink, it is poisonous."
	reagents_to_add = TOXIN

/obj/item/weapon/reagent_containers/glass/bottle/charcoal
	name = "activated charcoal bottle"
	desc = "A small bottle of activated charcoal. Used for treatment of overdoses."
	reagents_to_add = CHARCOAL

/obj/item/weapon/reagent_containers/glass/bottle/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide. Bitter almonds?"
	reagents_to_add = CYANIDE

/obj/item/weapon/reagent_containers/glass/bottle/stoxin
	name = "sleep-toxin bottle"
	desc = "A small bottle of sleep toxins. Just the fumes make you sleepy."
	reagents_to_add = STOXIN

/obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate
	name = "Chloral Hydrate Bottle"
	desc = "A small bottle of Chloral Hydrate. Mickey's Favorite!"
	reagents_to_add = list(CHLORALHYDRATE = 15)	//Intentionally low since it is so strong. Still enough to knock someone out.

/obj/item/weapon/reagent_containers/glass/bottle/antitoxin
	name = "anti-toxin bottle"
	desc = "A small bottle of Anti-toxins. Counters poisons, and repairs damage, a wonder drug."
	reagents_to_add = ANTI_TOXIN

/obj/item/weapon/reagent_containers/glass/bottle/mutagen
	name = "unstable mutagen bottle"
	desc = "A small bottle of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	reagents_to_add = MUTAGEN

/obj/item/weapon/reagent_containers/glass/bottle/ammonia
	name = "ammonia bottle"
	desc = "A small bottle."
	reagents_to_add = AMMONIA

/obj/item/weapon/reagent_containers/glass/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "A small bottle."
	reagents_to_add = DIETHYLAMINE

/obj/item/weapon/reagent_containers/glass/bottle/virion
	name = "Flu virion culture bottle"
	desc = "A small bottle. Contains H13N1 flu virion culture in synthblood medium."
	var/diseasetype = /datum/disease/advance/flu

/obj/item/weapon/reagent_containers/glass/bottle/virion/refill()
	var/datum/disease/F = new diseasetype(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent(BLOOD, 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/virion/epiglottis
	name = "Epiglottis virion culture bottle"
	desc = "A small bottle. Contains Epiglottis virion culture in synthblood medium."
	diseasetype = /datum/disease/advance/voice_change

/obj/item/weapon/reagent_containers/glass/bottle/virion/liver_enhance
	name = "Liver enhancement virion culture bottle"
	desc = "A small bottle. Contains liver enhancement virion culture in synthblood medium."
	diseasetype = /datum/disease/advance/heal

/obj/item/weapon/reagent_containers/glass/bottle/virion/hullucigen
	name = "Hullucigen virion culture bottle"
	desc = "A small bottle. Contains hullucigen virion culture in synthblood medium."
	diseasetype = /datum/disease/advance/hullucigen

/obj/item/weapon/reagent_containers/glass/bottle/virion/pierrot_throat
	name = "Pierrot's Throat culture bottle"
	desc = "A small bottle. Contains H0NI<42 virion culture in synthblood medium."
	diseasetype = /datum/disease/pierrot_throat

/obj/item/weapon/reagent_containers/glass/bottle/virion/cold
	name = "Rhinovirus culture bottle"
	desc = "A small bottle. Contains XY-rhinovirus culture in synthblood medium."
	diseasetype = /datum/disease/advance/cold

/obj/item/weapon/reagent_containers/glass/bottle/random
	name = "unknown culture bottle"
	desc = "A small bottle. Contains an unknown disease."
	icon_state = "bottle_alt"

/obj/item/weapon/reagent_containers/glass/bottle/random/refill()
	var/virus_choice = pick(subtypesof(/datum/disease2/disease) - typesof(/datum/disease2/disease/predefined))
	var/datum/disease2/disease/new_virus = new virus_choice

	var/list/anti = list(
		ANTIGEN_BLOOD	= 1,
		ANTIGEN_COMMON	= 1,
		ANTIGEN_RARE	= 1,
		ANTIGEN_ALIEN	= 0,
		)
	var/list/bad = list(
		EFFECT_DANGER_HELPFUL	= 1,
		EFFECT_DANGER_FLAVOR	= 2,
		EFFECT_DANGER_ANNOYING	= 2,
		EFFECT_DANGER_HINDRANCE	= 2,
		EFFECT_DANGER_HARMFUL	= 2,
		EFFECT_DANGER_DEADLY	= 1,
		)

	new_virus.origin = "Random culture bottle"

	new_virus.makerandom(list(40,60),list(20,90),anti,bad)

	var/list/blood_data = list(
		"viruses" = null,
		"blood_DNA" = null,
		"blood_type" = "O-",
		"resistances" = null,
		"trace_chem" = null,
		"virus2" = list()
	)
	blood_data["virus2"]["[new_virus.uniqueID]-[new_virus.subID]"] = new_virus
	reagents.add_reagent(BLOOD, volume, blood_data)

/obj/item/weapon/reagent_containers/glass/bottle/virion/retrovirus
	name = "Retrovirus culture bottle"
	desc = "A small bottle. Contains a retrovirus culture in a synthblood medium."
	diseasetype = /datum/disease/dna_retrovirus

/obj/item/weapon/reagent_containers/glass/bottle/virion/gbs
	name = "GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS+ culture in synthblood medium."//Or simply - General BullShit
	diseasetype = /datum/disease/gbs

/obj/item/weapon/reagent_containers/glass/bottle/virion/gbs/fake
	diseasetype = /datum/disease/fake_gbs

/obj/item/weapon/reagent_containers/glass/bottle/virion/chickenpox
	name = "Chickenpox culture bottle"
	desc = "A small bottle. Contains activated chickenpox in a vox-blood medium."
	diseasetype = /datum/disease2/effect/chickenpox

/*
/obj/item/weapon/reagent_containers/glass/bottle/virion/rhumba_beat
	name = "Rhumba Beat culture bottle"
	desc = "A small bottle. Contains The Rhumba Beat culture in synthblood medium."//Or simply - General BullShit
	diseasetype = /datum/disease/rhumba_beat
*/

/obj/item/weapon/reagent_containers/glass/bottle/virion/brainrot
	name = "Brainrot culture bottle"
	desc = "A small bottle. Contains Cryptococcus Cosmosis culture in synthblood medium."
	diseasetype = /datum/disease/brainrot

var/datum/disease2/disease/magnitis = null

/obj/item/weapon/reagent_containers/glass/bottle/magnitis
	name = "Magnitis culture bottle"
	desc = "A small bottle. Contains a small dosage of Fukkos Miracos."
	icon_state = "bottle_alt"

/obj/item/weapon/reagent_containers/glass/bottle/magnitis/refill()
	if (!magnitis)
		magnitis = new
		magnitis.form = "Fukkos Miracos"
		magnitis.infectionchance = 30
		magnitis.infectionchance_base = 30
		magnitis.stageprob = 0//single-stage
		magnitis.stage_variance = 0
		magnitis.max_stage = 1
		magnitis.can_kill = list()

		var/datum/disease2/effect/magnitis/single/W = new /datum/disease2/effect/magnitis/single
		magnitis.effects += W

		magnitis.origin = "Magnitis Bottle"

		magnitis.antigen = list(pick(antigen_family(pick(ANTIGEN_RARE,ANTIGEN_ALIEN))))
		magnitis.antigen |= pick(antigen_family(pick(ANTIGEN_RARE,ANTIGEN_ALIEN)))


		magnitis.spread = SPREAD_BLOOD|SPREAD_CONTACT
		magnitis.uniqueID = rand(0,9999)
		magnitis.subID = rand(0,9999)

		magnitis.strength = rand(70,100)
		magnitis.robustness = 100

		magnitis.color = "#777777"
		magnitis.pattern = 1
		magnitis.pattern_color = "#FFFFFF"

		log_debug("Creating Magnitis #[magnitis.uniqueID]-[magnitis.subID].")
		magnitis.log += "<br />[timestamp()] Created<br>"

		magnitis.mutation_modifier = 0

		magnitis.update_global_log()

	var/list/blood_data = list(
		"viruses" = null,
		"blood_DNA" = null,
		"blood_type" = "O-",
		"resistances" = null,
		"trace_chem" = null,
		"virus2" = list()
	)
	blood_data["virus2"]["[magnitis.uniqueID]-[magnitis.subID]"] = magnitis.getcopy()
	reagents.add_reagent(BLOOD, volume, blood_data)

var/datum/disease2/disease/wizarditis = null

/obj/item/weapon/reagent_containers/glass/bottle/wizarditis
	name = "Wizarditis culture bottle"
	desc = "A small bottle. Contains a sample of Rincewindus Vulgaris."
	icon_state = "bottle_alt"

/obj/item/weapon/reagent_containers/glass/bottle/wizarditis/refill()
	if (!wizarditis)
		wizarditis = new
		wizarditis.form = "Rincewindus Vulgaris"
		wizarditis.infectionchance = 30
		wizarditis.infectionchance_base = 30
		wizarditis.stageprob = 0//single-stage
		wizarditis.stage_variance = 0
		wizarditis.max_stage = 1
		wizarditis.can_kill = list()

		var/datum/disease2/effect/wizarditis/single/W = new /datum/disease2/effect/wizarditis/single
		wizarditis.effects += W

		wizarditis.origin = "Wizarditis Bottle"

		wizarditis.antigen = list(pick(antigen_family(pick(ANTIGEN_RARE,ANTIGEN_ALIEN))))
		wizarditis.antigen |= pick(antigen_family(pick(ANTIGEN_RARE,ANTIGEN_ALIEN)))


		wizarditis.spread = SPREAD_BLOOD|SPREAD_AIRBORNE
		wizarditis.uniqueID = rand(0,9999)
		wizarditis.subID = rand(0,9999)

		wizarditis.strength = rand(70,100)
		wizarditis.robustness = 100

		wizarditis.color = "#7295DA"
		wizarditis.pattern = 5
		wizarditis.pattern_color = "#EAFC77"

		log_debug("Creating Wizarditis #[wizarditis.uniqueID]-[wizarditis.subID].")
		wizarditis.log += "<br />[timestamp()] Created<br>"

		wizarditis.mutation_modifier = 0

		wizarditis.update_global_log()

	var/list/blood_data = list(
		"viruses" = null,
		"blood_DNA" = null,
		"blood_type" = "O-",
		"resistances" = null,
		"trace_chem" = null,
		"virus2" = list()
	)
	blood_data["virus2"]["[wizarditis.uniqueID]-[wizarditis.subID]"] = wizarditis.getcopy()
	reagents.add_reagent(BLOOD, volume, blood_data)

/obj/item/weapon/reagent_containers/glass/bottle/pacid
	name = "Polytrinic Acid Bottle"
	desc = "A small bottle. Contains a small amount of polytrinic acid."
	reagents_to_add = PACID

/obj/item/weapon/reagent_containers/glass/bottle/adminordrazine
	name = "Adminordrazine Bottle"
	desc = "A small bottle. Contains the liquid essence of the gods."
	reagents_to_add = ADMINORDRAZINE

/obj/item/weapon/reagent_containers/glass/bottle/procizine
	name = "procizine bottle"
	desc = "A small bottle. Contains a liquid with effects decided on the whim of the gods."
	reagents_to_add = PROCIZINE

/obj/item/weapon/reagent_containers/glass/bottle/procizine/refill()
	for(var/procname in procizine_calls)
		if(procizine_calls[procname] in bad_procs)
			desc = "A small bottle. Contains a liquid with effects decided with the spite of the gods, this can't end well."
			return

/obj/item/weapon/reagent_containers/glass/bottle/capsaicin
	name = "Capsaicin Bottle"
	desc = "A small bottle. Contains hot sauce."
	reagents_to_add = CAPSAICIN

/obj/item/weapon/reagent_containers/glass/bottle/frostoil
	name = "Frost Oil Bottle"
	desc = "A small bottle. Contains cold sauce."
	reagents_to_add = FROSTOIL

/obj/item/weapon/reagent_containers/glass/bottle/antisocial
	//No special name or description
	reagents_to_add = BICARODYNE

/obj/item/weapon/reagent_containers/glass/bottle/hypozine
	reagents_to_add = HYPOZINE

/obj/item/weapon/reagent_containers/glass/bottle/sacid
	name = "Sulphuric Acid Bottle"
	desc = "A small bottle. Contains a small amount of Sulphuric Acid."
	reagents_to_add = SACID

/obj/item/weapon/reagent_containers/glass/bottle/rezadone
	name = "Rezadone Bottle"
	desc = "A small bottle. Contains a small amount of Rezadone."
	reagents_to_add = REZADONE

/obj/item/weapon/reagent_containers/glass/bottle/alkysine
	name = "Alkysine Bottle"
	desc = "A small bottle. Contains a small amount of Alkysine."
	reagents_to_add = ALKYSINE

/obj/item/weapon/reagent_containers/glass/bottle/alkysinesmall
	name = "Alkysine Bottle"
	desc = "A small bottle. Contains a small amount of Alkysine."
	reagents_to_add = list(ALKYSINE = 10)

/obj/item/weapon/reagent_containers/glass/bottle/peridaxon
	name = "Peridaxon Bottle"
	desc = "A small bottle. Contains peridaxon. Medicate cautiously."
	reagents_to_add = PERIDAXON

/obj/item/weapon/reagent_containers/glass/bottle/nanobotssmall
	name = "Nanobots Bottle"
	desc = "A small bottle. You hear beeps and boops."
	reagents_to_add = list(NANOBOTS = 10)

/obj/item/weapon/reagent_containers/glass/bottle/bleach
	name = "bleach bottle"
	desc = "A bottle of BLAM! Ultraclean brand bleach. Has many warning labels."
	icon_state = "bleachbottle"
	starting_materials = list(MAT_PLASTIC = 1000)
	w_type = RECYK_PLASTIC
	melt_temperature = MELTPOINT_PLASTIC
	volume = 100
	controlled_splash = TRUE
	flags = FPRINT//initially closed
	reagents_to_add = BLEACH

/obj/item/weapon/reagent_containers/glass/bottle/bleach/update_icon()
	overlays.len = 0

	if(!is_open_container())
		var/image/lid = image(icon, src, "lid_[initial(icon_state)]")
		overlays += lid

/obj/item/weapon/reagent_containers/glass/bottle/acetone
	name = "acetone bottle"
	desc = "The Dip. The enemy of all things made of paint."
	icon_state = "acetonebottle"
	starting_materials = list(MAT_PLASTIC = 1000)
	w_type = RECYK_PLASTIC
	melt_temperature = MELTPOINT_PLASTIC
	volume = 100
	controlled_splash = TRUE
	flags = FPRINT//initially closed
	reagents_to_add = ACETONE

/obj/item/weapon/reagent_containers/glass/bottle/acetone/update_icon()
	overlays.len = 0

	if(!is_open_container())
		var/image/lid = image(icon, src, "lid_[initial(icon_state)]")
		overlays += lid

/obj/item/weapon/reagent_containers/glass/bottle/pcp
	name = "Gallon of PCP"
	desc = "You had no idea it even came in liquid form."
	icon_state = "pcpjug"
	starting_materials = list(MAT_PLASTIC = 1000)
	w_type = RECYK_PLASTIC
	melt_temperature = MELTPOINT_PLASTIC
	volume = 100
	reagents_to_add = LIQUIDPCP

/obj/item/weapon/reagent_containers/glass/bottle/pcp/update_icon()
	overlays.len = 0

	if(!is_open_container())
		var/image/lid = image(icon, src, "lid_[initial(icon_state)]")
		overlays += lid

/obj/item/weapon/reagent_containers/glass/bottle/eznutrient
	name = "E-Z-Nutrient Bottle"
	desc = "A bottle of standard grade fertilizer for regular uses. The label reads 'Grow your plants E-Z P-Z with E-Z-Nutrient. Easy!'."
	reagents_to_add = EZNUTRIENT

/obj/item/weapon/reagent_containers/glass/bottle/left4zed
	name = "Left 4 Zed Bottle"
	desc = "A bottle of fertilizer specialized for plant mutation. A microtransactions coupon is attached, named after the eponymous game."
	reagents_to_add = LEFT4ZED

/obj/item/weapon/reagent_containers/glass/bottle/robustharvest
	name = "Robust Harvest Bottle"
	desc = "A bottle of fertilizer to increase plant yields and potency. You feel stronger and bolder just from looking at the liquid inside."
	reagents_to_add = ROBUSTHARVEST

/obj/item/weapon/reagent_containers/glass/bottle/insecticide
	name = "Insecticide Bottle"
	desc = "A bottle of highly toxic Insecticide. There's a small, almost unreadable label warning against consumption."
	reagents_to_add = INSECTICIDE

/obj/item/weapon/reagent_containers/glass/bottle/plantbgone
	name = "Plant-B-Gone Bottle"
	desc = "A bottle of broad spectrum herbicide. A small decal shows a diona nymph with a no symbol on top."
	reagents_to_add = PLANTBGONE

/obj/item/weapon/reagent_containers/glass/bottle/carbon
	reagents_to_add = CARBON

/obj/item/weapon/reagent_containers/glass/bottle/silicon
	reagents_to_add = SILICON

/obj/item/weapon/reagent_containers/glass/bottle/sugar
	reagents_to_add = SUGAR

/obj/item/weapon/reagent_containers/glass/bottle/oxygen
	reagents_to_add = OXYGEN

/obj/item/weapon/reagent_containers/glass/bottle/hydrogen
	reagents_to_add = HYDROGEN

/obj/item/weapon/reagent_containers/glass/bottle/nitrogen
	reagents_to_add = NITROGEN

/obj/item/weapon/reagent_containers/glass/bottle/potassium
	reagents_to_add = POTASSIUM

/obj/item/weapon/reagent_containers/glass/bottle/carppheromones
	name = "Carp Pheromones Bottle"
	desc = "A bottle filled with pheromones. It smells awful. A small decal shows a space carp giving a thumbs... err... fins up."
	reagents_to_add = CARPPHEROMONES
