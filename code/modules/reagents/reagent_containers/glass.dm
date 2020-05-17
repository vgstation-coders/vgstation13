
////////////////////////////////////////////////////////////////////////////////
/// (Mixing) Glass.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/glass
	name = " "
	desc = " "
	icon = 'icons/obj/chemical.dmi'
	icon_state = "null"
	item_state = "null"
	w_type = RECYK_GLASS
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50)
	volume = 50
	flags = FPRINT  | OPENCONTAINER
	layer = ABOVE_OBJ_LAYER
	var/opaque = FALSE //when true no reagent filling overlay is applied to the icon.
	//This is absolutely terrible
	// TODO To remove this, return 1 on every attackby() that handles reagent_containers.
	var/list/can_be_placed_into = list(
		/obj/machinery/chem_master/,
		/obj/machinery/chem_dispenser/,
		/obj/machinery/reagentgrinder,
		/obj/structure/table,
		/obj/structure/closet,
		/obj/structure/sink,
		/obj/structure/centrifuge,
		/obj/item/weapon/storage,
		/obj/item/weapon/solder,
		/obj/machinery/atmospherics/unary/cryo_cell,
		/obj/machinery/dna_scannernew,
		/obj/item/weapon/grenade/chem_grenade,
		/obj/item/weapon/electrolyzer,
		/obj/machinery/bot/medbot,
		/obj/item/weapon/storage/secure/safe,
		/obj/machinery/iv_drip,
		/obj/machinery/disease2/incubator,
		/obj/machinery/disease2/centrifuge,
		/obj/machinery/disposal,
		/obj/machinery/apiary,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/hostile/retaliate/goat,
		/obj/machinery/cooking/icemachine,
		/obj/machinery/sleeper,
		/obj/machinery/anomaly,
		/obj/machinery/bunsen_burner,
		/obj/item/weapon/sword/venom,
		/obj/item/weapon/cylinder,
		/obj/item/clothing/gloves/powerfist,
		)

/obj/item/weapon/reagent_containers/glass/get_rating()
	return volume / 50

/obj/item/weapon/reagent_containers/glass/New()
	..()
	update_icon() //Used by all subtypes for reagent filling, and allows roundstart lids

/obj/item/weapon/reagent_containers/glass/mop_act(obj/item/weapon/mop/M, mob/user)
	return is_open_container()

/obj/item/weapon/reagent_containers/glass/examine(mob/user)
	..()
	if(!is_open_container())
		to_chat(user, "<span class='info'>An airtight lid seals it completely.</span>")

/obj/item/weapon/reagent_containers/glass/attack_self()
	..()
	if(is_open_container())
		to_chat(usr, "<span class = 'notice'>You put the lid on \the [src].")
		flags ^= OPENCONTAINER
	else
		to_chat(usr, "<span class = 'notice'>You take the lid off \the [src].")
		flags |= OPENCONTAINER
	update_icon()

/obj/item/weapon/reagent_containers/glass/afterattack(var/atom/target, var/mob/user, var/adjacency_flag, var/click_params)
	if (!adjacency_flag)
		return

	if (is_type_in_list(target, can_be_placed_into))
		return

	if(ishuman(target) || iscorgi(target)) //Splashing handled in attack now
		return

	var/transfer_result = transfer(target, user, splashable_units = -1) // Potentially splash with everything inside

	if((transfer_result > 10) && (isturf(target) || istype(target, /obj/machinery/portable_atmospherics/hydroponics)))	//if we're splashing a decent amount of reagent on the floor
		playsound(target, 'sound/effects/slosh.ogg', 25, 1)													//or in an hydro tray, then we make some noise.

/obj/item/weapon/reagent_containers/glass/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/pen) || istype(W, /obj/item/device/flashlight/pen))
		set_tiny_label(user)
	attempt_heating(W, user)

/obj/item/weapon/reagent_containers/glass/fits_in_iv_drip()
	return 1

/obj/item/weapon/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker. Can hold up to 50 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	starting_materials = list(MAT_GLASS = 500)
	origin_tech = Tc_MATERIALS + "=1"
	layer = ABOVE_OBJ_LAYER //So it always gets layered above pills and bottles

/obj/item/weapon/reagent_containers/glass/beaker/attackby(obj/item/weapon/W, mob/user)
	if(src.type == /obj/item/weapon/reagent_containers/glass/beaker && istype(W, /obj/item/weapon/surgicaldrill)) //regular beakers only
		to_chat(user, "You begin drilling holes into the bottom of \the [src].")
		playsound(user, 'sound/machines/juicer.ogg', 50, 1)
		if(do_after(user, src, 60))
			to_chat(user, "You drill six holes through the bottom of \the [src].")
			if(src.loc == user)
				user.drop_item(src, force_drop = 1)
				var/obj/item/weapon/cylinder/I = new (get_turf(user))
				user.put_in_hands(I)
			else
				new /obj/item/weapon/cylinder(get_turf(src.loc))
			qdel(src)
		return
	return ..()

/obj/item/weapon/reagent_containers/glass/beaker/mop_act(obj/item/weapon/mop/M, mob/user)
	if(..())
		if (src.reagents.total_volume >= 1)
			switch(src.reagents.total_volume)
				if(1 to 30)
					if(M.reagents.total_volume >= 3)
						to_chat(user, "<span class='notice'>You dip \the [M]'s head into \the [src] but don't soak anything up.</span>")
						return 1
					src.reagents.trans_to(M, 1)
					to_chat(user, "<span class='notice'>You barely manage to wet [M]</span>")
					playsound(src, 'sound/effects/slosh.ogg', 25, 1)
				if(30 to 100)
					if(M.reagents.total_volume >= 5)
						to_chat(user, "<span class='notice'>You dip \the [M]'s head into \the [src] but don't soak anything up.</span>")
						return 1
					src.reagents.trans_to(M, 2)
					to_chat(user, "<span class='notice'>You manage to wet [M]</span>")
					playsound(src, 'sound/effects/slosh.ogg', 25, 1)
				if(100 to INFINITY)
					if(M.reagents.total_volume >= 10)
						to_chat(user, "<span class='notice'>You dip \the [M]'s head into \the [src] but don't soak anything up.</span>")
						return 1
					src.reagents.trans_to(M, 5)
					to_chat(user, "<span class='notice'>You manage to soak [M]</span>")
					playsound(src, 'sound/effects/slosh.ogg', 25, 1)
				else
					to_chat(user, "What")
					return 1
		else
			to_chat(user, "<span class='notice'>Nothing left to wet [M] with!</span>")
		return 1

/obj/item/weapon/reagent_containers/glass/beaker/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/update_icon()
	overlays.len = 0

	if(!opaque && reagents && reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)
				filling.icon_state = "[icon_state]-10"
			if(10 to 24)
				filling.icon_state = "[icon_state]10"
			if(25 to 49)
				filling.icon_state = "[icon_state]25"
			if(50 to 74)
				filling.icon_state = "[icon_state]50"
			if(75 to 79)
				filling.icon_state = "[icon_state]75"
			if(80 to 90)
				filling.icon_state = "[icon_state]80"
			if(91 to INFINITY)
				filling.icon_state = "[icon_state]100"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)

		overlays += filling

	if(!is_open_container())
		var/image/lid = image(icon, src, "lid_[initial(icon_state)]")
		overlays += lid

/obj/item/weapon/reagent_containers/glass/beaker/erlenmeyer
	name = "small erlenmeyer flask"
	desc = "It's like a cute little snub-nosed beaker. Can hold up to 50 units."
	icon_state = "erlenmeyersmall"

/obj/item/weapon/reagent_containers/glass/beaker/large/erlenmeyer
	name = "erlenmeyer flask"
	desc = "Colloquially known as the 'long beaker'. Can hold up to 100 units."
	icon_state = "erlenmeyerlarge"

/obj/item/weapon/reagent_containers/glass/beaker/large
	name = "large beaker"
	desc = "A large beaker. Can hold up to 100 units."
	icon_state = "beakerlarge"
	starting_materials = list(MAT_GLASS = 1500)
	volume = 100
	possible_transfer_amounts = list(5,10,15,25,30,50,100)

/obj/item/weapon/reagent_containers/glass/beaker/large/plasma
	name = "plasma beaker"
	desc = "A beaker with plasma lining, designed to act as a catalyst for some particular reactions."
	icon_state = "beakerplasma"
	origin_tech = Tc_PLASMATECH + "=4;" + Tc_MATERIALS + "=4"

/obj/item/weapon/reagent_containers/glass/beaker/large/supermatter
	name = "supermatter beaker"
	desc = "A beaker with a supermatter sliver. It heats fluids inside, but holding it makes your hand feel strange..."
	icon_state = "beakersupermatter"
	origin_tech = Tc_POWERSTORAGE + "=4;" + Tc_MATERIALS + "=4"

/obj/item/weapon/reagent_containers/glass/beaker/large/supermatter/New()
	..()
	processing_objects += src

/obj/item/weapon/reagent_containers/glass/beaker/large/supermatter/Destroy()
	processing_objects -= src
	..()

/obj/item/weapon/reagent_containers/glass/beaker/large/supermatter/process()
	if(reagents.total_volume)
		reagents.heating(9000, TEMPERATURE_PLASMA)
	if(ishuman(loc))
		//held or in pocket of a human
		var/mob/living/L = loc
		L.apply_radiation(3, RAD_EXTERNAL)

/obj/item/weapon/reagent_containers/glass/beaker/noreact
	name = "stasis beaker"
	desc = "A beaker powered by experimental bluespace technology. Chemicals are held in stasis and do not react inside of it. Can hold up to 50 units."
	icon_state = "beakernoreact"
	starting_materials = list(MAT_GLASS = 500)
	volume = 50
	flags = FPRINT  | OPENCONTAINER | NOREACT
	origin_tech = Tc_BLUESPACE + "=3;" + Tc_MATERIALS + "=4"
	opaque = TRUE

/obj/item/weapon/reagent_containers/glass/beaker/noreact/large
	name = "large stasis beaker"
	desc = "A beaker powered by experimental bluespace technology. Chemicals are held in stasis and do not react inside of it. Can hold up to 100 units."
	icon_state = "beakernoreactlarge"
	starting_materials = list(MAT_GLASS = 1500)
	volume = 100
	origin_tech = Tc_BLUESPACE + "=4;" + Tc_MATERIALS + "=6"

/obj/item/weapon/reagent_containers/glass/beaker/bluespace
	name = "bluespace beaker"
	desc = "A newly-developed high-capacity beaker that uses advances in bluespace research. Can hold up to 200 units."
	icon_state = "beakerbluespace"
	starting_materials = list(MAT_GLASS = 2000)
	volume = 200
	w_type = RECYK_GLASS
	possible_transfer_amounts = list(5,10,15,25,30,50,100,200)
	flags = FPRINT  | OPENCONTAINER
	origin_tech = Tc_BLUESPACE + "=2;" + Tc_MATERIALS + "=3"
	opaque = TRUE

/obj/item/weapon/reagent_containers/glass/beaker/bluespace/large
	name = "large bluespace beaker"
	desc = "A prototype ultra-capacity beaker that uses advances in bluespace research. Can hold up to 300 units."
	icon_state = "beakerbluespacelarge"
	starting_materials = list(MAT_GLASS = 5000)
	volume = 300
	possible_transfer_amounts = list(5,10,15,25,30,50,100,150,200,300)
	origin_tech = Tc_BLUESPACE + "=3;" + Tc_MATERIALS + "=5"

/obj/item/weapon/reagent_containers/glass/beaker/vial
	name = "vial"
	desc = "A small glass vial. Can hold up to 25 units."
	icon_state = "vial"
	starting_materials = list(MAT_GLASS = 250)
	volume = 25
	possible_transfer_amounts = list(5,10,15,25)

/obj/item/weapon/reagent_containers/glass/beaker/vial/mop_act(obj/item/weapon/mop/M, mob/user)
	return 0

/obj/item/weapon/reagent_containers/glass/beaker/vial/on_reagent_change()
	..()
	if (istype(loc,/obj/item/weapon/storage/fancy/vials) || istype(loc,/obj/item/weapon/storage/lockbox/vials))
		var/obj/item/weapon/storage/S = loc
		S.update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/vial/uranium/New()
	..()
	reagents.add_reagent(URANIUM, 25)

/obj/item/weapon/reagent_containers/glass/beaker/vial/tencarbon/New()
	..()
	reagents.add_reagent(CARBON, 10)

/obj/item/weapon/reagent_containers/glass/beaker/vial/tenwater/New()
	..()
	reagents.add_reagent(WATER, 10)

/obj/item/weapon/reagent_containers/glass/beaker/vial/tenantitox/New()
	..()
	reagents.add_reagent(ANTI_TOXIN, 10)

/obj/item/weapon/reagent_containers/glass/beaker/erlenmeyer/lemonlime/New()
	..()
	reagents.add_reagent(LEMON_LIME, 30)

/obj/item/weapon/reagent_containers/glass/beaker/erlenmeyer/sodawater/New()
	..()
	reagents.add_reagent(SODAWATER, 30)

/obj/item/weapon/reagent_containers/glass/beaker/cryoxadone/New()
	..()
	reagents.add_reagent(CRYOXADONE, 30)

/obj/item/weapon/reagent_containers/glass/beaker/sulphuric/New()
	..()
	reagents.add_reagent(SACID, 50)

/obj/item/weapon/reagent_containers/glass/beaker/slime/New()
	..()
	reagents.add_reagent(SLIMEJELLY, 50)

/obj/item/weapon/reagent_containers/glass/beaker/mednanobots
	name = "beaker 'nanobots'"

/obj/item/weapon/reagent_containers/glass/beaker/mednanobots/New()
	..()
	reagents.add_reagent("mednanobots", 25)
	update_icon()

/obj/item/weapon/reagent_containers/glass/bucket
	desc = "It's a bucket."
	name = "bucket"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	starting_materials = list(MAT_IRON = 200)
	w_type = RECYK_METAL
	w_class = W_CLASS_MEDIUM
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10,20,25,30,50,100,150)
	volume = 150
	flags = FPRINT | OPENCONTAINER
	slot_flags = SLOT_HEAD

/obj/item/weapon/reagent_containers/glass/bucket/mop_act(obj/item/weapon/mop/M, mob/user)
	if(..())
		if (src.reagents.total_volume >= 1)
			switch(src.reagents.total_volume)
				if(1 to 30)
					if(M.reagents.total_volume >= 5)
						to_chat(user, "<span class='notice'>You dip \the [M]'s head into \the [src] but don't soak anything up.</span>")
						return 1
					src.reagents.trans_to(M, 1)
					to_chat(user, "<span class='notice'>You barely manage to wet [M]</span>")
					playsound(src, 'sound/effects/slosh.ogg', 25, 1)
				if(30 to 100)
					if(M.reagents.total_volume >= 5)
						to_chat(user, "<span class='notice'>You dip \the [M]'s head into \the [src] but don't soak anything up.</span>")
						return 1
					src.reagents.trans_to(M, 2)
					to_chat(user, "<span class='notice'>You manage to wet [M]</span>")
					playsound(src, 'sound/effects/slosh.ogg', 25, 1)
				if(100 to INFINITY)
					if(M.reagents.total_volume >= 10)
						to_chat(user, "<span class='notice'>You dip \the [M]'s head into \the [src] but don't soak anything up.</span>")
						return 1
					src.reagents.trans_to(M, 5)
					to_chat(user, "<span class='notice'>You manage to soak [M]</span>")
					playsound(src, 'sound/effects/slosh.ogg', 25, 1)
				else
					to_chat(user, "What")
					return 1
		else
			to_chat(user, "<span class='notice'>Nothing left to wet [M] with!</span>")
		return 1

/obj/item/weapon/reagent_containers/glass/bucket/attackby(var/obj/D, mob/user as mob)
	if(isprox(D))
		to_chat(user, "You add \the [D] to \the [src].")
		qdel(D)
		D = null
		user.put_in_hands(new /obj/item/weapon/bucket_sensor)
		user.drop_from_inventory(src)
		qdel(src)
		return
	attempt_heating(D, user)

/obj/item/weapon/reagent_containers/glass/bucket/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/glass/bucket/update_icon()
	overlays.len = 0

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]")

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)

		overlays += filling

/obj/item/weapon/reagent_containers/glass/bucket/water_filled/New()
	..()
	reagents.add_reagent(WATER, 150)
	update_icon()

/*
/obj/item/weapon/reagent_containers/glass/blender_jug
	name = "Blender Jug"
	desc = "A blender jug, part of a blender."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "blender_jug_e"
	volume = 100

	on_reagent_change()
		switch(src.reagents.total_volume)
			if(0)
				icon_state = "blender_jug_e"
			if(1 to 75)
				icon_state = "blender_jug_h"
			if(76 to 100)
				icon_state = "blender_jug_f"

/obj/item/weapon/reagent_containers/glass/canister		//not used apparantly
	desc = "It's a canister. Mainly used for transporting fuel."
	name = "canister"
	icon = 'icons/obj/tank.dmi'
	icon_state = "canister"
	item_state = "canister"
	m_amt = 300
	g_amt = 0
	w_class = W_CLASS_LARGE

	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10,20,30,60)
	volume = 120
	flags = FPRINT

/obj/item/weapon/reagent_containers/glass/dispenser
	name = "reagent glass"
	desc = "A reagent glass."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker0"
	amount_per_transfer_from_this = 10
	flags = FPRINT  | OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/dispenser/surfactant
	name = "reagent glass (surfactant)"
	icon_state = "liquid"

/obj/item/weapon/reagent_containers/glass/dispenser/surfactant/New()
	..()
	reagents.add_reagent(FLUOROSURFACTANT, 20)

*/

//No idea if this actually works anymore. Please handle carefully
/obj/item/weapon/reagent_containers/glass/kettle
	name = "Kettle"
	desc = "A pot made for holding hot drinks. Can hold up to 75 units."
	icon_state = "kettle"
	starting_materials = list(MAT_IRON = 200)
	volume = 75
	w_type = RECYK_GLASS
	amount_per_transfer_from_this = 10
	flags = FPRINT  | OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/kettle/red
	icon_state = "kettle_red"

/obj/item/weapon/reagent_containers/glass/kettle/blue
	icon_state = "kettle_blue"

/obj/item/weapon/reagent_containers/glass/kettle/purple
	icon_state = "kettle_purple"

/obj/item/weapon/reagent_containers/glass/kettle/green
	icon_state = "kettle_green"
