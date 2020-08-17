
//chemistry stuff here so that it can be easily viewed/modified
datum/reagent/tungsten
	name = "Tungsten"
	id = TUNGSTEN
	description = "A chemical element, and a strong oxidising agent."
	reagent_state = REAGENT_STATE_SOLID
	color = "#DCDCDC"  // rgb: 220, 220, 220, silver
	density = 19.25

datum/reagent/lithiumsodiumtungstate
	name = "Lithium Sodium Tungstate"
	id = LITHIUMSODIUMTUNGSTATE
	description = "A reducing agent for geological compounds."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C0C0C0"  // rgb: 192, 192, 192, darker silver
	density = 3.29
	specheatcap = 3.99

datum/reagent/ground_rock
	name = "Ground Rock"
	id = GROUND_ROCK
	description = "A fine dust made of ground up rock."
	reagent_state = REAGENT_STATE_SOLID
	color = "#A0522D"   //rgb: 160, 82, 45, brown

datum/reagent/analysis_sample
	name = "Analysis liquid"
	id = ANALYSIS_SAMPLE
	description = "A watery paste used in chemical analysis."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#F5FFFA"   //rgb: 245, 255, 250, almost white
	density = 4.74
	specheatcap = 3.99

datum/reagent/chemical_waste
	name = "Chemical Waste"
	id = CHEMICAL_WASTE
	description = "A viscous, toxic liquid left over from many chemical processes."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#ADFF2F"   //rgb: 173, 255, 47, toxic green

/datum/chemical_reaction/lithiumsodiumtungstate	//LiNa2WO4, not the easiest chem to mix
	name = "Lithium Sodium Tungstate"
	id = LITHIUMSODIUMTUNGSTATE
	result = LITHIUMSODIUMTUNGSTATE
	required_reagents = list(LITHIUM = 1, SODIUM = 2, TUNGSTEN = 1, OXYGEN = 4)
	result_amount = 8

/datum/chemical_reaction/analysis_liquid
	name = "Analysis sample"
	id = ANALYSIS_SAMPLE
	result = ANALYSIS_SAMPLE
	secondary_results = list(CHEMICAL_WASTE = 1)
	required_reagents = list(GROUND_ROCK = 1, LITHIUMSODIUMTUNGSTATE = 2)
	result_amount = 2

/obj/item/weapon/reagent_containers/glass/solution_tray
	name = "solution tray"
	desc = "A small, open-topped glass container for delicate research samples. It sports a re-useable strip for labelling with a pen."
	icon = 'icons/obj/device.dmi'
	icon_state = "solution_tray"
	starting_materials = list(MAT_GLASS = 20)
	w_type = RECYK_GLASS
	w_class = W_CLASS_TINY
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(1, 2)
	volume = 2
	flags = FPRINT | OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/solution_tray/mop_act(obj/item/weapon/mop/M, mob/user)
	return 1
obj/item/weapon/reagent_containers/glass/solution_tray/attackby(obj/item/weapon/W as obj, mob/living/user as mob)
	if(istype(W, /obj/item/weapon/pen) || istype(W, /obj/item/device/flashlight/pen))
		set_tiny_label(user)
	else
		..(W, user)

/obj/item/weapon/storage/box/solution_trays
	name = "solution tray box"
	icon_state = "solution_trays"

/obj/item/weapon/storage/box/solution_trays/New()
	..()
	for(var/i = 1 to 7)
		new /obj/item/weapon/reagent_containers/glass/solution_tray( src )


/obj/item/weapon/reagent_containers/glass/beaker/tungsten
	name = "beaker 'tungsten'"

/obj/item/weapon/reagent_containers/glass/beaker/tungsten/New()
	..()
	reagents.add_reagent(TUNGSTEN,50)
	update_icon()


/obj/item/weapon/reagent_containers/glass/beaker/oxygen
	name = "beaker 'oxygen'"

/obj/item/weapon/reagent_containers/glass/beaker/oxygen/New()
	..()
	reagents.add_reagent(OXYGEN,50)
	update_icon()


/obj/item/weapon/reagent_containers/glass/beaker/sodium
	name = "beaker 'sodium'"

/obj/item/weapon/reagent_containers/glass/beaker/sodium/New()
	..()
	reagents.add_reagent(SODIUM,50)
	update_icon()


/obj/item/weapon/reagent_containers/glass/beaker/lithium
	name = "beaker 'lithium'"

/obj/item/weapon/reagent_containers/glass/beaker/lithium/New()
	..()
	reagents.add_reagent(LITHIUM,50)
	update_icon()


/obj/item/weapon/reagent_containers/glass/beaker/water
	name = "beaker 'water'"

/obj/item/weapon/reagent_containers/glass/beaker/water/New()
	..()
	reagents.add_reagent(WATER,50)
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/fuel
	name = "beaker 'fuel'"

/obj/item/weapon/reagent_containers/glass/beaker/fuel/New()
	..()
	reagents.add_reagent(FUEL,50)
	update_icon()
