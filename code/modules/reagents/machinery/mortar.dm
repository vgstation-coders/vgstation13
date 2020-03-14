/obj/item/weapon/reagent_containers/glass/mortar
	name = "mortar"
	desc = "This is a reinforced bowl, used for crushing stuff into reagents."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mortar"
	flags = FPRINT  | OPENCONTAINER
	volume = 50
	amount_per_transfer_from_this = 5
	//We want the all-in-one grinder audience

	var/list/blend_items = list (
		/obj/item/stack/sheet/metal           = list(IRON,20),
		/obj/item/stack/sheet/mineral/plasma  = list(PLASMA,20),
		/obj/item/stack/sheet/mineral/uranium = list(URANIUM,20),
		/obj/item/stack/sheet/mineral/clown   = list(BANANA,20),
		/obj/item/stack/sheet/mineral/silver  = list(SILVER,20),
		/obj/item/stack/sheet/mineral/gold    = list(GOLD,20),
		/obj/item/weapon/grown/nettle         = list(FORMIC_ACID,10),
		/obj/item/weapon/grown/deathnettle    = list(PHENOL,10),
		/obj/item/stack/sheet/charcoal        = list("charcoal",20),
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans   = list(SOYMILK,1),
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato     = list(KETCHUP,2),
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn       = list(CORNOIL,3),
		/obj/item/weapon/reagent_containers/food/snacks/grown/wheat      = list(FLOUR,5),
		/obj/item/weapon/reagent_containers/food/snacks/grown/ricestalk  = list(RICE,5),
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherries   = list(CHERRYJELLY,1),
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans        = list(ALUMINUM,10),
		/obj/item/trash/soda_cans										 = list(ALUMINUM,10),
		/obj/item/seeds	                      = list(BLACKPEPPER,5),
		/obj/item/device/flashlight/flare     = list(SULFUR,10),
		/obj/item/stack/cable_coil            = list(COPPER, 10),
		/obj/item/weapon/cell                 = list(LITHIUM, 10),
		/obj/item/clothing/head/butt          = list(MERCURY, 10),
		/obj/item/weapon/rocksliver           = list(GROUND_ROCK,30),
		/obj/item/weapon/match                = list(PHOSPHORUS, 2),

		//Recipes must include both variables!
		/obj/item/weapon/reagent_containers/food = list("generic",0),
		/obj/item/ice_crystal                = list(ICE, 10),
	)


	var/obj/item/crushable = null

/obj/item/weapon/reagent_containers/glass/mortar/Destroy()
	qdel(crushable)
	crushable = null
	. = ..()

/obj/item/weapon/reagent_containers/glass/mortar/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if (O.is_screwdriver(user))
		if(crushable)
			crushable.forceMove(user.loc)
		new /obj/item/stack/sheet/metal(user.loc)
		new /obj/item/trash/bowl(user.loc)
		qdel(src) //Important detail
		return
	if (crushable)
		to_chat(user, "<span class ='warning'>There's already something inside!</span>")
		return 1
	if (!is_type_in_list(O, blend_items) && !is_type_in_list(O, juice_items))
		to_chat(user, "<span class ='warning'>You can't grind that!</span>")
		return ..()

	if(istype(O, /obj/item/stack/))
		var/obj/item/stack/N = new O.type(src, amount=1)
		var/obj/item/stack/S = O
		S.use(1)
		crushable = N
		to_chat(user, "<span class='notice'>You place \the [N] in \the [src].</span>")
		return 0
	else if(!user.drop_item(O, src))
		to_chat(user, "<span class='warning'>You can't let go of \the [O]!</span>")
		return

	crushable = O
	to_chat(user, "<span class='notice'>You place \the [O] in \the [src].</span>")
	return 0

/obj/item/weapon/reagent_containers/glass/mortar/attack_hand(mob/user as mob)
	add_fingerprint(user)
	if(user.get_inactive_hand() != src)
		return ..()
	if(crushable)
		crushable.forceMove(user.loc)
		user.put_in_active_hand(crushable)
		crushable = null
	return

/obj/item/weapon/reagent_containers/glass/mortar/attack_self(mob/user as mob)
	if(!crushable)
		to_chat(user, "<span class='notice'>There is nothing to be crushed.</span>")
		return
	if (reagents.total_volume >= volume)
		to_chat(user, "<span class='warning'>There is no more space inside!</span>")
		return
	if(is_type_in_list(crushable, juice_items))
		to_chat(user, "<span class='notice'>You smash the contents into juice!</span>")
		var/id = null
		for(var/i in juice_items)
			if(istype(crushable, i))
				id = juice_items[i]
		if(!id)
			return
		var/obj/item/weapon/reagent_containers/food/snacks/grown/juiceable = crushable
		if(juiceable.potency == -1)
			juiceable.potency = 0
		reagents.add_reagent(id[1], min(round(5*sqrt(juiceable.potency)), volume - reagents.total_volume))
	else if(is_type_in_list(crushable, blend_items))
		to_chat(user, "<span class='notice'>You grind the contents into dust!</span>")
		var/id = null
		var/space = volume - reagents.total_volume
		for(var/i in blend_items)
			if(istype(crushable, i))
				id = blend_items[i]
				break
		if(!id)
			return
		if(istype(crushable, /obj/item/weapon/reagent_containers/food/snacks)) //Most growable food
			if(id[1] == "generic")
				crushable.reagents.trans_to(src,crushable.reagents.total_volume)
			else
				reagents.add_reagent(id[1],min(id[2], space))
		else if(istype(crushable, /obj/item/stack/sheet) || istype(crushable, /obj/item/seeds) || /obj/item/device/flashlight/flare || /obj/item/stack/cable_coil || /obj/item/weapon/cell || /obj/item/clothing/head/butt) //Generic processes
			reagents.add_reagent(id[1],min(id[2], space))
		else if(istype(crushable, /obj/item/weapon/grown)) //Nettle and death nettle
			crushable.reagents.trans_to(src,crushable.reagents.total_volume)
		else if(istype(crushable, /obj/item/weapon/rocksliver)) //Xenoarch
			var/obj/item/weapon/rocksliver/R = crushable
			reagents.add_reagent(id[1],min(id[2], space), R.geological_data)
		else
			to_chat(user, "<span class ='warning'>An error was encountered. Report this message.</span>")
			return
	else
		to_chat(user, "<span class='notice'>You smash the contents into nothingness.</span>")
	qdel(crushable)
	crushable = null
	return

/obj/item/weapon/reagent_containers/glass/mortar/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It has [crushable ? "an unground [crushable] inside." : "nothing to be crushed."]</span>")