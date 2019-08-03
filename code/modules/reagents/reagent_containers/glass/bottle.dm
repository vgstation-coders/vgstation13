
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

/obj/item/weapon/reagent_containers/glass/bottle/New(loc,altvol=30)
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

/*
 * Hard to have colored bottles work with dynamic reagent filling
/obj/item/weapon/reagent_containers/glass/bottle/New()
	..()
	if(!icon_state)
		icon_state = "bottle[rand(1,20)]"
*/

/obj/item/weapon/reagent_containers/glass/bottle/on_reagent_change()
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
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle16"

/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline/New()
	..()
	reagents.add_reagent(INAPROVALINE, 30)

/obj/item/weapon/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle of toxins. Do not drink, it is poisonous."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle12"

/obj/item/weapon/reagent_containers/glass/bottle/toxin/New()
	..()
	reagents.add_reagent(TOXIN, 30)

/obj/item/weapon/reagent_containers/glass/bottle/charcoal
	name = "activated charcoal bottle"
	desc = "A small bottle of activated charcoal. Used for treatment of overdoses."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle-charcoal"

/obj/item/weapon/reagent_containers/glass/bottle/charcoal/New()
	..()
	reagents.add_reagent("charcoal", 30)

/obj/item/weapon/reagent_containers/glass/bottle/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide. Bitter almonds?"
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle12"

/obj/item/weapon/reagent_containers/glass/bottle/cyanide/New()
	..()
	reagents.add_reagent(CYANIDE, 30)

/obj/item/weapon/reagent_containers/glass/bottle/stoxin
	name = "sleep-toxin bottle"
	desc = "A small bottle of sleep toxins. Just the fumes make you sleepy."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle20"

/obj/item/weapon/reagent_containers/glass/bottle/stoxin/New()
	..()
	reagents.add_reagent(STOXIN, 30)

/obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate
	name = "Chloral Hydrate Bottle"
	desc = "A small bottle of Chloral Hydrate. Mickey's Favorite!"
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle20"

/obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate/New()
	..()
	reagents.add_reagent(CHLORALHYDRATE, 15)		//Intentionally low since it is so strong. Still enough to knock someone out.

/obj/item/weapon/reagent_containers/glass/bottle/antitoxin
	name = "anti-toxin bottle"
	desc = "A small bottle of Anti-toxins. Counters poisons, and repairs damage, a wonder drug."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle17"

/obj/item/weapon/reagent_containers/glass/bottle/antitoxin/New()
	..()
	reagents.add_reagent(ANTI_TOXIN, 30)

/obj/item/weapon/reagent_containers/glass/bottle/mutagen
	name = "unstable mutagen bottle"
	desc = "A small bottle of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle20"

/obj/item/weapon/reagent_containers/glass/bottle/mutagen/New()
	..()
	reagents.add_reagent(MUTAGEN, 30)

/obj/item/weapon/reagent_containers/glass/bottle/ammonia
	name = "ammonia bottle"
	desc = "A small bottle."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle20"

/obj/item/weapon/reagent_containers/glass/bottle/ammonia/New()
	..()
	reagents.add_reagent(AMMONIA, 30)

/obj/item/weapon/reagent_containers/glass/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "A small bottle."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle17"

/obj/item/weapon/reagent_containers/glass/bottle/diethylamine/New()
	..()
	reagents.add_reagent(DIETHYLAMINE, 30)

/obj/item/weapon/reagent_containers/glass/bottle/flu_virion
	name = "Flu virion culture bottle"
	desc = "A small bottle. Contains H13N1 flu virion culture in synthblood medium."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/flu_virion/New()
	..()
	var/datum/disease/F = new /datum/disease/advance/flu(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent(BLOOD, 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/epiglottis_virion
	name = "Epiglottis virion culture bottle"
	desc = "A small bottle. Contains Epiglottis virion culture in synthblood medium."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle3"
/obj/item/weapon/reagent_containers/glass/bottle/epiglottis_virion/New()
	..()
	var/datum/disease/F = new /datum/disease/advance/voice_change(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent(BLOOD, 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/liver_enhance_virion
	name = "Liver enhancement virion culture bottle"
	desc = "A small bottle. Contains liver enhancement virion culture in synthblood medium."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle3"
/obj/item/weapon/reagent_containers/glass/bottle/liver_enhance_virion/New()
	..()
	var/datum/disease/F = new /datum/disease/advance/heal(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent(BLOOD, 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/hullucigen_virion
	name = "Hullucigen virion culture bottle"
	desc = "A small bottle. Contains hullucigen virion culture in synthblood medium."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle3"
/obj/item/weapon/reagent_containers/glass/bottle/hullucigen_virion/New()
	..()
	var/datum/disease/F = new /datum/disease/advance/hullucigen(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent(BLOOD, 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/pierrot_throat
	name = "Pierrot's Throat culture bottle"
	desc = "A small bottle. Contains H0NI<42 virion culture in synthblood medium."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle3"
/obj/item/weapon/reagent_containers/glass/bottle/pierrot_throat/New()
	..()
	var/datum/disease/F = new /datum/disease/pierrot_throat(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent(BLOOD, 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/cold
	name = "Rhinovirus culture bottle"
	desc = "A small bottle. Contains XY-rhinovirus culture in synthblood medium."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle3"
/obj/item/weapon/reagent_containers/glass/bottle/cold/New()
	..()
	var/datum/disease/advance/F = new /datum/disease/advance/cold(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent(BLOOD, 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/random
	name = "Random culture bottle"
	desc = "A small bottle. Contains a random disease."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle3"
/obj/item/weapon/reagent_containers/glass/bottle/random/New()
	..()
	var/datum/disease/advance/F = new(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent(BLOOD, 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/retrovirus
	name = "Retrovirus culture bottle"
	desc = "A small bottle. Contains a retrovirus culture in a synthblood medium."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/retrovirus/New()
	..()
	var/datum/disease/F = new /datum/disease/dna_retrovirus(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent(BLOOD, 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/gbs
	name = "GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS+ culture in synthblood medium."//Or simply - General BullShit
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle3"
	amount_per_transfer_from_this = 5

/obj/item/weapon/reagent_containers/glass/bottle/gbs/New()
	var/datum/reagents/R = new/datum/reagents(20)
	reagents = R
	R.my_atom = src
	var/datum/disease/F = new /datum/disease/gbs
	var/list/data = list("virus"= F)
	R.add_reagent(BLOOD, 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/fake_gbs
	name = "GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS- culture in synthblood medium."//Or simply - General BullShit
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/fake_gbs/New()
	..()
	var/datum/disease/F = new /datum/disease/fake_gbs(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent(BLOOD, 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/chickenpox
	name = "Chickenpox culture bottle"
	desc = "A small bottle. Contains activated chickenpox in a vox-blood medium."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/chickenpox/New()
	..()
	var/datum/disease/F = new /datum/disease2/effect/chickenpox(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent(BLOOD, 20, data)

/*
/obj/item/weapon/reagent_containers/glass/bottle/rhumba_beat
	name = "Rhumba Beat culture bottle"
	desc = "A small bottle. Contains The Rhumba Beat culture in synthblood medium."//Or simply - General BullShit
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle3"
	amount_per_transfer_from_this = 5

/obj/item/weapon/reagent_containers/glass/bottle/rhumba_beat/New()
	var/datum/reagents/R = new/datum/reagents(20)
	reagents = R
	R.my_atom = src
	var/datum/disease/F = new /datum/disease/rhumba_beat
	var/list/data = list("virus"= F)
	R.add_reagent(BLOOD, 20, data)
*/

/obj/item/weapon/reagent_containers/glass/bottle/brainrot
	name = "Brainrot culture bottle"
	desc = "A small bottle. Contains Cryptococcus Cosmosis culture in synthblood medium."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/brainrot/New()
	..()
	var/datum/disease/F = new /datum/disease/brainrot(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent(BLOOD, 20, data)

var/datum/disease2/disease/magnitis = null

/obj/item/weapon/reagent_containers/glass/bottle/magnitis
	name = "Magnitis culture bottle"
	desc = "A small bottle. Contains a small dosage of Fukkos Miracos."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle_alt"
	//icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/magnitis/New()
	..()
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
		"donor" = null,
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
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle_alt"
	//icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/wizarditis/New()
	..()
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
		"donor" = null,
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
	desc = "A small bottle. Contains a small amount of Polytrinic Acid"
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle17"

/obj/item/weapon/reagent_containers/glass/bottle/pacid/New()
	..()
	reagents.add_reagent(PACID, 30)

/obj/item/weapon/reagent_containers/glass/bottle/adminordrazine
	name = "Adminordrazine Bottle"
	desc = "A small bottle. Contains the liquid essence of the gods."
	icon = 'icons/obj/drinks.dmi'
	//icon_state = "holyflask"

/obj/item/weapon/reagent_containers/glass/bottle/adminordrazine/New()
	..()
	reagents.add_reagent(ADMINORDRAZINE, 30)

/obj/item/weapon/reagent_containers/glass/bottle/capsaicin
	name = "Capsaicin Bottle"
	desc = "A small bottle. Contains hot sauce."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/capsaicin/New()
	..()
	reagents.add_reagent(CAPSAICIN, 30)

/obj/item/weapon/reagent_containers/glass/bottle/frostoil
	name = "Frost Oil Bottle"
	desc = "A small bottle. Contains cold sauce."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle17"

/obj/item/weapon/reagent_containers/glass/bottle/frostoil/New()
	..()
	reagents.add_reagent(FROSTOIL, 30)

/obj/item/weapon/reagent_containers/glass/bottle/antisocial
	//No special name or description

/obj/item/weapon/reagent_containers/glass/bottle/antisocial/New()
	..()
	reagents.add_reagent(BICARODYNE, 30)

/obj/item/weapon/reagent_containers/glass/bottle/hypozine


/obj/item/weapon/reagent_containers/glass/bottle/hypozine/New()
	..()
	reagents.add_reagent(HYPOZINE, 30)

/obj/item/weapon/reagent_containers/glass/bottle/sacid
	name = "Sulphuric Acid Bottle"
	desc = "A small bottle. Contains a small amount of Sulphuric Acid."
	icon = 'icons/obj/chemical.dmi'

/obj/item/weapon/reagent_containers/glass/bottle/sacid/New()
	..()
	reagents.add_reagent(SACID, 30)

/obj/item/weapon/reagent_containers/glass/bottle/rezadone
	name = "Rezadone Bottle"
	desc = "A small bottle. Contains a small amount of Rezadone."
	icon = 'icons/obj/chemical.dmi'

/obj/item/weapon/reagent_containers/glass/bottle/rezadone/New()
	..()
	reagents.add_reagent(REZADONE, 30)

/obj/item/weapon/reagent_containers/glass/bottle/alkysine
	name = "Alkysine Bottle"
	desc = "A small bottle. Contains a small amount of Alkysine."
	icon = 'icons/obj/chemical.dmi'

/obj/item/weapon/reagent_containers/glass/bottle/alkysine/New()
	..()
	reagents.add_reagent(ALKYSINE, 30)

/obj/item/weapon/reagent_containers/glass/bottle/alkysinesmall
	name = "Alkysine Bottle"
	desc = "A small bottle. Contains a small amount of Alkysine."
	icon = 'icons/obj/chemical.dmi'

/obj/item/weapon/reagent_containers/glass/bottle/alkysinesmall/New()
	..()
	reagents.add_reagent(ALKYSINE, 10)

/obj/item/weapon/reagent_containers/glass/bottle/peridaxon
	name = "Peridaxon Bottle"
	desc = "A small bottle. Contains peridaxon. Medicate cautiously."
	icon = 'icons/obj/chemical.dmi'

/obj/item/weapon/reagent_containers/glass/bottle/peridaxon/New()
	..()
	reagents.add_reagent(PERIDAXON, 30)

/obj/item/weapon/reagent_containers/glass/bottle/nanobotssmall
	name = "Nanobots Bottle"
	desc = "A small bottle. You hear beeps and boops."
	icon = 'icons/obj/chemical.dmi'

/obj/item/weapon/reagent_containers/glass/bottle/nanobotssmall/New()
	..()
	reagents.add_reagent(NANOBOTS, 10)

/obj/item/weapon/reagent_containers/glass/bottle/bleach
	name = "Bleach Bottle"
	desc = "A bottle of BLAM! Ultraclean brand bleach. Has many warning labels."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bleachbottle"
	starting_materials = list(MAT_PLASTIC = 1000)
	w_type = RECYK_MISC
	melt_temperature = MELTPOINT_PLASTIC

/obj/item/weapon/reagent_containers/glass/bottle/bleach/update_icon()
	overlays.len = 0

	if(!is_open_container())
		var/image/lid = image(icon, src, "lid_[initial(icon_state)]")
		overlays += lid

/obj/item/weapon/reagent_containers/glass/bottle/bleach/New()
	..()
	reagents.add_reagent(BLEACH, 15)

/obj/item/weapon/reagent_containers/glass/bottle/eznutrient
	name = "E-Z-Nutrient Bottle"
	desc = "A bottle of standard grade fertilizer for regular uses. The label reads 'Grow your plants E-Z P-Z with E-Z-Nutrient. Easy!'."
	icon = 'icons/obj/chemical.dmi'

/obj/item/weapon/reagent_containers/glass/bottle/eznutrient/New()
	..()
	reagents.add_reagent(EZNUTRIENT, 30)

/obj/item/weapon/reagent_containers/glass/bottle/left4zed
	name = "Left 4 Zed Bottle"
	desc = "A bottle of fertilizer specialized for plant mutation. A microtransactions coupon is attached, named after the eponymous game."
	icon = 'icons/obj/chemical.dmi'

/obj/item/weapon/reagent_containers/glass/bottle/left4zed/New()
	..()
	reagents.add_reagent(LEFT4ZED, 30)

/obj/item/weapon/reagent_containers/glass/bottle/robustharvest
	name = "Robust Harvest Bottle"
	desc = "A bottle of fertilizer to increase plant yields and potency. You feel stronger and bolder just from looking at the liquid inside."
	icon = 'icons/obj/chemical.dmi'

/obj/item/weapon/reagent_containers/glass/bottle/robustharvest/New()
	..()
	reagents.add_reagent(ROBUSTHARVEST, 30)

/obj/item/weapon/reagent_containers/glass/bottle/carbon/New()
	..()
	reagents.add_reagent(CARBON, 30)

/obj/item/weapon/reagent_containers/glass/bottle/silicon/New()
	..()
	reagents.add_reagent(SILICON, 30)

/obj/item/weapon/reagent_containers/glass/bottle/sugar/New()
	..()
	reagents.add_reagent(SUGAR, 30)

/obj/item/weapon/reagent_containers/glass/bottle/oxygen/New()
	..()
	reagents.add_reagent(OXYGEN, 30)

/obj/item/weapon/reagent_containers/glass/bottle/hydrogen/New()
	..()
	reagents.add_reagent(HYDROGEN, 30)

/obj/item/weapon/reagent_containers/glass/bottle/nitrogen/New()
	..()
	reagents.add_reagent(NITROGEN, 30)

/obj/item/weapon/reagent_containers/glass/bottle/potassium/New()
	..()
	reagents.add_reagent(POTASSIUM, 30)
