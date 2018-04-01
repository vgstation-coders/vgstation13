/obj/item/reagent_containers/glass
	name = "glass"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50)
	volume = 50
	container_type = OPENCONTAINER
	spillable = TRUE
	resistance_flags = ACID_PROOF


/obj/item/reagent_containers/glass/attack(mob/M, mob/user, obj/target)
	if(!canconsume(M, user))
		return

	if(!spillable)
		return

	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return

	if(istype(M))
		if(user.a_intent == INTENT_HARM)
			var/R
			M.visible_message("<span class='danger'>[user] splashes the contents of [src] onto [M]!</span>", \
							"<span class='userdanger'>[user] splashes the contents of [src] onto [M]!</span>")
			if(reagents)
				for(var/datum/reagent/A in reagents.reagent_list)
					R += A.id + " ("
					R += num2text(A.volume) + "),"
			if(isturf(target) && reagents.reagent_list.len && thrownby)
				add_logs(thrownby, target, "splashed [english_list(reagents.reagent_list)]", "at [target][COORD(target)]")
				log_game("[key_name(thrownby)] splashed [english_list(reagents.reagent_list)] at [COORD(target)].")
				message_admins("[key_name_admin(thrownby)] splashed [english_list(reagents.reagent_list)] at [ADMIN_COORDJMP(target)].")
			reagents.reaction(M, TOUCH)
			add_logs(user, M, "splashed", R)
			reagents.clear_reagents()
		else
			if(M != user)
				M.visible_message("<span class='danger'>[user] attempts to feed something to [M].</span>", \
							"<span class='userdanger'>[user] attempts to feed something to you.</span>")
				if(!do_mob(user, M))
					return
				if(!reagents || !reagents.total_volume)
					return // The drink might be empty after the delay, such as by spam-feeding
				M.visible_message("<span class='danger'>[user] feeds something to [M].</span>", "<span class='userdanger'>[user] feeds something to you.</span>")
				add_logs(user, M, "fed", reagents.log_list())
			else
				to_chat(user, "<span class='notice'>You swallow a gulp of [src].</span>")
			var/fraction = min(5/reagents.total_volume, 1)
			reagents.reaction(M, INGEST, fraction)
			addtimer(CALLBACK(reagents, /datum/reagents.proc/trans_to, M, 5), 5)
			playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)

/obj/item/reagent_containers/glass/afterattack(obj/target, mob/user, proximity)
	if((!proximity) || !check_allowed_items(target,target_self=1))
		return

	if(target.is_refillable()) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty!</span>")
			return

		if(target.reagents.holder_full())
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] unit\s of the solution to [target].</span>")

	else if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty and can't be refilled!</span>")
			return

		if(reagents.holder_full())
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] unit\s of the contents of [target].</span>")

	else if(reagents.total_volume)
		if(user.a_intent == INTENT_HARM)
			user.visible_message("<span class='danger'>[user] splashes the contents of [src] onto [target]!</span>", \
								"<span class='notice'>You splash the contents of [src] onto [target].</span>")
			reagents.reaction(target, TOUCH)
			reagents.clear_reagents()

/obj/item/reagent_containers/glass/attackby(obj/item/I, mob/user, params)
	var/hotness = I.is_hot()
	if(hotness && reagents)
		reagents.expose_temperature(hotness)
		to_chat(user, "<span class='notice'>You heat [name] with [I]!</span>")

	if(istype(I, /obj/item/reagent_containers/food/snacks/egg)) //breaking eggs
		var/obj/item/reagent_containers/food/snacks/egg/E = I
		if(reagents)
			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, "<span class='notice'>[src] is full.</span>")
			else
				to_chat(user, "<span class='notice'>You break [E] in [src].</span>")
				E.reagents.trans_to(src, E.reagents.total_volume)
				qdel(E)
			return
	..()


/obj/item/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker. It can hold up to 50 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	materials = list(MAT_GLASS=500)

/obj/item/reagent_containers/glass/beaker/Initialize()
	. = ..()
	update_icon()

/obj/item/reagent_containers/glass/beaker/get_part_rating()
	return reagents.maximum_volume

/obj/item/reagent_containers/glass/beaker/on_reagent_change(changetype)
	update_icon()

/obj/item/reagent_containers/glass/beaker/update_icon()
	cut_overlays()

	if(reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "[icon_state]10")

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

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)

/obj/item/reagent_containers/glass/beaker/jar
	name = "honey jar"
	desc = "A jar for honey. It can hold up to 50 units of sweet delight."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "vapour"

/obj/item/reagent_containers/glass/beaker/large
	name = "large beaker"
	desc = "A large beaker. Can hold up to 100 units."
	icon_state = "beakerlarge"
	materials = list(MAT_GLASS=2500)
	volume = 100
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100)

/obj/item/reagent_containers/glass/beaker/plastic
	name = "x-large beaker"
	desc = "An extra-large beaker. Can hold up to 120 units."
	icon_state = "beakerwhite"
	materials = list(MAT_GLASS=2500, MAT_PLASTIC=3000)
	volume = 120
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10,15,20,25,30,60,120)

/obj/item/reagent_containers/glass/beaker/plastic/update_icon()
	icon_state = "beakerlarge" // hack to lets us reuse the large beaker reagent fill states
	..()
	icon_state = "beakerwhite"

/obj/item/reagent_containers/glass/beaker/meta
	name = "metamaterial beaker"
	desc = "A large beaker. Can hold up to 180 units."
	icon_state = "beakergold"
	materials = list(MAT_GLASS=2500, MAT_PLASTIC=3000, MAT_GOLD=1000, MAT_TITANIUM=1000)
	volume = 180
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10,15,20,25,30,60,120,180)

/obj/item/reagent_containers/glass/beaker/noreact
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without \
		reactions. Can hold up to 50 units."
	icon_state = "beakernoreact"
	materials = list(MAT_METAL=3000)
	volume = 50
	amount_per_transfer_from_this = 10

/obj/item/reagent_containers/glass/beaker/noreact/Initialize()
	. = ..()
	reagents.set_reacting(FALSE)

/obj/item/reagent_containers/glass/beaker/bluespace
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology \
		and Element Cuban combined with the Compound Pete. Can hold up to \
		300 units."
	icon_state = "beakerbluespace"
	materials = list(MAT_GLASS=3000)
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100,300)

/obj/item/reagent_containers/glass/beaker/cryoxadone
	list_reagents = list("cryoxadone" = 30)

/obj/item/reagent_containers/glass/beaker/sulphuric
	list_reagents = list("sacid" = 50)

/obj/item/reagent_containers/glass/beaker/slime
	list_reagents = list("slimejelly" = 50)

/obj/item/reagent_containers/glass/beaker/large/styptic
	name = "styptic reserve tank"
	list_reagents = list("styptic_powder" = 50)

/obj/item/reagent_containers/glass/beaker/large/silver_sulfadiazine
	name = "silver sulfadiazine reserve tank"
	list_reagents = list("silver_sulfadiazine" = 50)

/obj/item/reagent_containers/glass/beaker/large/charcoal
	name = "charcoal reserve tank"
	list_reagents = list("charcoal" = 50)

/obj/item/reagent_containers/glass/beaker/large/epinephrine
	name = "epinephrine reserve tank"
	list_reagents = list("epinephrine" = 50)

/obj/item/reagent_containers/glass/beaker/synthflesh
	list_reagents = list("synthflesh" = 50)

/obj/item/reagent_containers/glass/bucket
	name = "bucket"
	desc = "It's a bucket."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	materials = list(MAT_METAL=200)
	w_class = WEIGHT_CLASS_NORMAL
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10,15,20,25,30,50,70)
	volume = 70
	flags_inv = HIDEHAIR
	slot_flags = SLOT_HEAD
	resistance_flags = NONE
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 75, "acid" = 50) //Weak melee protection, because you can wear it on your head
	slot_equipment_priority = list( \
		slot_back, slot_wear_id,\
		slot_w_uniform, slot_wear_suit,\
		slot_wear_mask, slot_head, slot_neck,\
		slot_shoes, slot_gloves,\
		slot_ears, slot_glasses,\
		slot_belt, slot_s_store,\
		slot_l_store, slot_r_store,\
		slot_generic_dextrous_storage
	)

/obj/item/reagent_containers/glass/bucket/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/mop))
		if(reagents.total_volume < 1)
			to_chat(user, "<span class='warning'>[src] is out of water!</span>")
		else
			reagents.trans_to(O, 5)
			to_chat(user, "<span class='notice'>You wet [O] in [src].</span>")
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
	else if(isprox(O))
		to_chat(user, "<span class='notice'>You add [O] to [src].</span>")
		qdel(O)
		qdel(src)
		user.put_in_hands(new /obj/item/bot_assembly/cleanbot)
	else
		..()

/obj/item/reagent_containers/glass/bucket/equipped(mob/user, slot)
	..()
	if(slot == slot_head && reagents.total_volume)
		to_chat(user, "<span class='userdanger'>[src]'s contents spill all over you!</span>")
		reagents.reaction(user, TOUCH)
		reagents.clear_reagents()

/obj/item/reagent_containers/glass/bucket/equip_to_best_slot(var/mob/M)
	if(reagents.total_volume) //If there is water in a bucket, don't quick equip it to the head
		var/index = slot_equipment_priority.Find(slot_head)
		slot_equipment_priority.Remove(slot_head)
		. = ..()
		slot_equipment_priority.Insert(index, slot_head)
		return
	return ..()

/obj/item/reagent_containers/glass/beaker/waterbottle
	name = "bottle of water"
	desc = "A bottle of water filled at an old Earth bottling facility."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "smallbottle"
	item_state = "bottle"
	list_reagents = list("water" = 49.5, "fluorine" = 0.5)//see desc, don't think about it too hard
	materials = list(MAT_GLASS=0)
	volume = 50
	amount_per_transfer_from_this = 10

/obj/item/reagent_containers/glass/beaker/waterbottle/empty
	list_reagents = list()

/obj/item/reagent_containers/glass/beaker/waterbottle/large
	desc = "A fresh commercial-sized bottle of water."
	icon_state = "largebottle"
	materials = list(MAT_GLASS=0)
	list_reagents = list("water" = 100)
	volume = 100
	amount_per_transfer_from_this = 20

/obj/item/reagent_containers/glass/beaker/waterbottle/large/empty
	list_reagents = list()

/obj/item/reagent_containers/glass/beaker/large/hydrogen
	name = "hydrogen beaker"
	list_reagents = list("hydrogen" = 50)

/obj/item/reagent_containers/glass/beaker/large/lithium
	name = "lithium beaker"
	list_reagents = list("lithium" = 50)

/obj/item/reagent_containers/glass/beaker/large/carbon
	name = "carbon beaker"
	list_reagents = list("carbon" = 50)

/obj/item/reagent_containers/glass/beaker/large/nitrogen
	name = "nitrogen beaker"
	list_reagents = list("nitrogen" = 50)

/obj/item/reagent_containers/glass/beaker/large/oxygen
	name = "oxygen beaker"
	list_reagents = list("oxygen" = 50)

/obj/item/reagent_containers/glass/beaker/large/fluorine
	name = "fluorine beaker"
	list_reagents = list("fluorine" = 50)

/obj/item/reagent_containers/glass/beaker/large/sodium
	name = "sodium beaker"
	list_reagents = list("sodium" = 50)

/obj/item/reagent_containers/glass/beaker/large/aluminium
	name = "aluminium beaker"
	list_reagents = list("aluminium" = 50)

/obj/item/reagent_containers/glass/beaker/large/silicon
	name = "silicon beaker"
	list_reagents = list("silicon" = 50)

/obj/item/reagent_containers/glass/beaker/large/phosphorus
	name = "phosphorus beaker"
	list_reagents = list("phosphorus" = 50)

/obj/item/reagent_containers/glass/beaker/large/sulfur
	name = "sulfur beaker"
	list_reagents = list("sulfur" = 50)

/obj/item/reagent_containers/glass/beaker/large/chlorine
	name = "chlorine beaker"
	list_reagents = list("chlorine" = 50)

/obj/item/reagent_containers/glass/beaker/large/potassium
	name = "potassium beaker"
	list_reagents = list("potassium" = 50)

/obj/item/reagent_containers/glass/beaker/large/iron
	name = "iron beaker"
	list_reagents = list("iron" = 50)

/obj/item/reagent_containers/glass/beaker/large/copper
	name = "copper beaker"
	list_reagents = list("copper" = 50)

/obj/item/reagent_containers/glass/beaker/large/mercury
	name = "mercury beaker"
	list_reagents = list("mercury" = 50)

/obj/item/reagent_containers/glass/beaker/large/radium
	name = "radium beaker"
	list_reagents = list("radium" = 50)

/obj/item/reagent_containers/glass/beaker/large/water
	name = "water beaker"
	list_reagents = list("water" = 50)

/obj/item/reagent_containers/glass/beaker/large/ethanol
	name = "ethanol beaker"
	list_reagents = list("ethanol" = 50)

/obj/item/reagent_containers/glass/beaker/large/sugar
	name = "sugar beaker"
	list_reagents = list("sugar" = 50)

/obj/item/reagent_containers/glass/beaker/large/sacid
	name = "sulphuric acid beaker"
	list_reagents = list("sacid" = 50)

/obj/item/reagent_containers/glass/beaker/large/welding_fuel
	name = "welding fuel beaker"
	list_reagents = list("welding_fuel" = 50)

/obj/item/reagent_containers/glass/beaker/large/silver
	name = "silver beaker"
	list_reagents = list("silver" = 50)

/obj/item/reagent_containers/glass/beaker/large/iodine
	name = "iodine beaker"
	list_reagents = list("iodine" = 50)

/obj/item/reagent_containers/glass/beaker/large/bromine
	name = "bromine beaker"
	list_reagents = list("bromine" = 50)
