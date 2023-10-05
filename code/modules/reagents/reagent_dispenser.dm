/obj/structure/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	flags = FPRINT
	pressure_resistance = 2*ONE_ATMOSPHERE

	var/exploded = FALSE // we gotta have a var like this now for it, akin to supermatter shards
	var/amount_per_transfer_from_this = 10
	var/possible_transfer_amounts = list(10,25,50,100)

	var/modded = 0
	var/obj/item/device/assembly_holder/rig = null

/obj/structure/reagent_dispensers/AltClick(mob/user)
	if(!user.incapacitated() && user.Adjacent(get_turf(src)) && possible_transfer_amounts)
		set_APTFT()
		return
	return ..()

/obj/structure/reagent_dispensers/examine(mob/user)
	..()
	reagents.get_examine(user)
	if (modded)
		to_chat(user, "<span class='warning'>The faucet is wrenched open, leaking the contents!</span>")
	if(rig)
		to_chat(user, "<span class='notice'>There is some kind of device rigged to the tank.</span>")


/*/obj/structure/reagent_dispensers/hear_talk(mob/living/M, text)
	if(rig)
		rig.hear_talk(M,text)
*/

/obj/structure/reagent_dispensers/attack_hand()
	if (!cookvessel && rig)
		usr.visible_message("[usr] begins to detach [rig] from \the [src].", "You begin to detach [rig] from \the [src].")
		if(do_after(usr, src, 20))
			usr.visible_message("<span class='notice'>[usr] detaches [rig] from \the [src].", "<span class='notice'>You detach [rig] from \the [src].</span>")
			if(rig)
				rig.forceMove(get_turf(usr))
				rig.master = null
				rig = null
			overlays = new/list()
	else
		. = ..()

/obj/structure/reagent_dispensers/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W.is_wrench(user))
		if(wrenchable())
			return wrenchAnchor(user, W)
		else if(!is_open_container())
			user.visible_message("[user] wrenches [src]'s faucet [modded ? "closed" : "open"].", \
				"You wrench [src]'s faucet [modded ? "closed" : "open"].")
			modded = !modded
	if (!is_open_container() && istype(W,/obj/item/device/assembly_holder))
		if (rig)
			to_chat(user, "<span class='warning'>There is another device in the way.</span>")
			return ..()
		user.visible_message("[user] begins rigging [W] to \the [src].", "You begin rigging [W] to \the [src].")
		if(do_after(user, src, 20))
			if(rig)
				to_chat(user, "<span class='warning'>Somebody already attached something to \the [src].</span>")
				return
			if(!user.drop_item(W, src))
				to_chat(user,"<span class='warning'>Oops! You can't let go of \the [W]!</span>")
				return

			user.visible_message("<span class='notice'>[user] rigs [W] to \the [src].", "<span class='notice'>You rig [W] to \the [src].</span>")

			var/obj/item/device/assembly_holder/H = W
			if (istype(H.a_left,/obj/item/device/assembly/igniter) || istype(H.a_right,/obj/item/device/assembly/igniter))
				message_admins("[key_name_admin(user)] rigged fueltank at ([loc.x],[loc.y],[loc.z]) for explosion.")
				log_game("[key_name(user)] rigged fueltank at ([loc.x],[loc.y],[loc.z]) for explosion.")

			rig = W
			rig.master = src

			var/image/test = image(W.appearance, src, "pixel_x" = 6, "pixel_y" = -1)
			overlays += test

/obj/structure/reagent_dispensers/cultify()
	new /obj/structure/reagent_dispensers/bloodkeg(get_turf(src))
	..()

/obj/structure/reagent_dispensers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in view(1)
	var/N = input("Amount per transfer from this:","[src]") as null|anything in possible_transfer_amounts
	if (N)
		amount_per_transfer_from_this = N

/obj/structure/reagent_dispensers/ex_act(severity)
	explode()
	if(src)
		switch(severity)
			if(1.0)
				qdel(src)
			if(2.0)
				if (prob(50))
					new /obj/effect/water(src.loc)
					qdel(src)
			if(3.0)
				if (prob(5))
					new /obj/effect/water(src.loc)
					qdel(src)

/obj/structure/reagent_dispensers/blob_act()
	explode()
	if(src && prob(50))
		new /obj/effect/water(src.loc)
		qdel(src)

/obj/structure/reagent_dispensers/beam_connect(var/obj/effect/beam/B)
	..()
	apply_beam_damage(B)


/obj/structure/reagent_dispensers/beam_disconnect(var/obj/effect/beam/B)
	..()
	apply_beam_damage(B)

/obj/structure/reagent_dispensers/apply_beam_damage(var/obj/effect/beam/B)
	if(isturf(get_turf(src)) && B.get_damage() >= 15)
		explode()

/obj/structure/reagent_dispensers/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature >= AUTOIGNITION_WELDERFUEL)
		explode()

/obj/structure/reagent_dispensers/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet)||istype(Proj,/obj/item/projectile/ricochet))
		if(Proj.get_damage() && can_explode())
			log_attack("<font color='red'>[key_name(Proj.firer)] shot [src]/([formatJumpTo(src)]) with a [Proj.type]</font>")
			if(Proj.firer)//turrets don't have "firers"
				Proj.firer.attack_log += "\[[time_stamp()]\] <b>[key_name(Proj.firer)]</b> shot <b>[src]([x],[y],[z])</b> with a <b>[Proj.type]</b>"
				msg_admin_attack("[key_name(Proj.firer)] shot [src]/([formatJumpTo(src)]) with a [Proj.type] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[Proj.firer.x];Y=[Proj.firer.y];Z=[Proj.firer.z]'>JMP</a>)") //BS12 EDIT ALG
			else
				msg_admin_attack("[src] was shot by a [Proj.type] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)") //BS12 EDIT ALG
			explode(Proj.firer,TRUE)
	return ..()

/obj/structure/reagent_dispensers/suicide_act(var/mob/living/user)
	if(user.held_items.len && can_explode())
		var/hotfound = FALSE
		var/obj/item/tool/weldingtool/welder
		for(var/obj/item/I in user.held_items)
			if(I.is_hot())
				hotfound = TRUE
			if(iswelder(I))
				welder = I
		if(welder)
			welder.setWelding(1)
			if(welder.welding || welder.is_hot())
				hotfound = TRUE
		if(hotfound)
			var/message_say = user.handle_suicide_bomb_cause(src)
			if(!message_say)
				return
			to_chat(viewers(user), "<span class='danger'>[user] presses the warm lit welder against the cold body of a welding fuel tank! It looks like \he's going out with a bang!</span>")
			user.say(message_say)
			welder.afterattack(src,user,1)
			return(SUICIDE_ACT_BRUTELOSS)
	if(!is_open_container() && reagents.total_volume)
		to_chat(viewers(user), "<span class='danger'>[user] is placing \his mouth underneath the tank nozzle and drinking the contents! It looks like \he's trying to commit suicide.</span>")
		reagents.trans_to(user, amount_per_transfer_from_this)
		return(SUICIDE_ACT_TOXLOSS)

/obj/structure/reagent_dispensers/New()
	. = ..()
	create_reagents(1000)

	if (!possible_transfer_amounts)
		verbs -= /obj/structure/reagent_dispensers/verb/set_APTFT

/obj/structure/reagent_dispensers/proc/is_empty()
	return reagents.total_volume <= 0

/obj/structure/reagent_dispensers/proc/can_transfer()
	return TRUE

//Dispensers
/obj/structure/reagent_dispensers/watertank
	name = "watertank"
	desc = "A storage tank containing water."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	amount_per_transfer_from_this = 10

/obj/structure/reagent_dispensers/watertank/New()
	. = ..()
	reagents.add_reagent(WATER, 1000)

/obj/structure/reagent_dispensers/watertank/suicide_act(var/mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species == "Grey") // harms the grayys
			to_chat(viewers(user), "<span class='danger'>[user] is placing \his mouth underneath the tank nozzle and drinking the contents! It looks like \he's trying to commit suicide.</span>")
			reagents.trans_to(user, amount_per_transfer_from_this)
			return(SUICIDE_ACT_BRUTELOSS)
	else
		return ..()

/obj/structure/reagent_dispensers/fueltank
	name = "fueltank"
	desc = "A storage tank containing welding fuel."
	icon = 'icons/obj/objects.dmi'
	icon_state = "weldtank"
	amount_per_transfer_from_this = 10

/obj/structure/reagent_dispensers/fueltank/blob_act()
	explode()

/obj/structure/reagent_dispensers/fueltank/ex_act()
	explode()

/obj/structure/reagent_dispensers/fueltank/singularity_act()
	qdel(src)
	return  2


/obj/structure/reagent_dispensers/Bumped(atom/movable/AM)
	..()
	if(istype(AM, /obj/structure/bed/chair/vehicle))
		var/obj/structure/bed/chair/vehicle/car = AM
		if(car.explodes_fueltanks && can_explode())
			visible_message("<span class='danger'>\The [car] crashes into \the [src]!</span>")
			if(car.occupant && istype(car.occupant, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = car.occupant
				H.audible_scream("fueltank_crash")
			explode(car.occupant,TRUE)

/obj/structure/reagent_dispensers/attempt_heating(atom/A, mob/user)
	if((A.is_hot() || ((arcanetampered || A.arcanetampered) && iswelder(A) && !A.is_hot())) && can_explode())
		if(ismob(arcanetampered))
			message_admins("[key_name_admin(arcanetampered)] caused a fueltank explosion.")
			log_game("[key_name(arcanetampered)] caused a fueltank explosion.")
		else if(ismob(A.arcanetampered))
			message_admins("[key_name_admin(A.arcanetampered)] caused a fueltank explosion.")
			log_game("[key_name(A.arcanetampered)] caused a fueltank explosion.")
		else if(!A.arcanetampered && !arcanetampered)
			message_admins("[key_name_admin(user)] triggered a fueltank explosion.")
			log_game("[key_name(user)] triggered a fueltank explosion.")
		to_chat(user, "<span class='warning'>That was stupid of you.</span>")
		explode(user,TRUE)

/obj/structure/reagent_dispensers/proc/can_explode()
	if(!reagents.has_reagent(FUEL))
		return FALSE
	return TRUE

/obj/structure/reagent_dispensers/fueltank/can_explode()
	return TRUE

/obj/structure/reagent_dispensers/cauldron/can_explode()
	return FALSE

/obj/structure/reagent_dispensers/proc/explode(var/mob/user,var/explodechecked = FALSE)
	if(exploded)
		return // already hit this proc, don't do it again
	if(!explodechecked)
		if(!can_explode())
			return
	exploded = TRUE
	if(!reagents.has_reagent(FUEL))
		explosion(src.loc,-1,1,2, whodunnit = user)
	else
		reagents.heating(received_temperature = AUTOIGNITION_WELDERFUEL)
	if(src)
		qdel(src)

/obj/structure/reagent_dispensers/fueltank/New()
	. = ..()
	reagents.add_reagent(FUEL, 1000)

/obj/structure/reagent_dispensers/peppertank
	name = "Pepper Spray Refiller"
	desc = "Refill pepper spray canisters."
	icon = 'icons/obj/objects.dmi'
	icon_state = "peppertank"
	anchored = 1
	density = 0
	amount_per_transfer_from_this = 45

/obj/structure/reagent_dispensers/peppertank/New()
	. = ..()
	reagents.add_reagent(CONDENSEDCAPSAICIN, 1000)

/obj/structure/reagent_dispensers/peppertank/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is placing \his head underneath the dispenser nozzle and spraying the contents! It looks like \he's trying to commit suicide.</span>")
	reagents.trans_to(user, amount_per_transfer_from_this)
	return(SUICIDE_ACT_TOXLOSS|SUICIDE_ACT_BRUTELOSS)

/obj/structure/reagent_dispensers/water_cooler
	name = "Water-Cooler"
	desc = "A machine that dispenses water to drink."
	amount_per_transfer_from_this = 5
	icon = 'icons/obj/vending.dmi'
	icon_state = "water_cooler"
	possible_transfer_amounts = list(5,10,30)
	anchored = 0
	var/addedliquid = 500
	var/paper_cups = 10


/obj/structure/reagent_dispensers/water_cooler/New()
	. = ..()
	reagents.add_reagent(WATER, addedliquid)
	desc = "[initial(desc)] There's [paper_cups] paper cups stored inside."

/obj/structure/reagent_dispensers/water_cooler/wrenchable()
	return 1

/obj/structure/reagent_dispensers/water_cooler/attack_hand(mob/user as mob)
	if(paper_cups > 0)
		user.put_in_hands(new/obj/item/weapon/reagent_containers/food/drinks/sillycup())
		to_chat(user, "You pick up an empty paper cup from \the [src]")
		paper_cups--
		desc = "[initial(desc)] There's [paper_cups] paper cups stored inside."

/obj/structure/reagent_dispensers/water_cooler/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/reagent_dispensers/water_cooler/attackby(obj/item/I as obj, mob/user as mob)
	if (iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(WT.remove_fuel(0, user))
			new /obj/item/stack/sheet/mineral/plastic (src.loc,4)
			qdel(src)
			return
	else
		..()

/obj/structure/reagent_dispensers/water_cooler/on_reagent_change()
	overlays.Cut()
	if(reagents.total_volume)
		var/image/reagentimg = image(src.icon, src, "wc_reagents")
		reagentimg.icon += mix_color_from_reagents(reagents.reagent_list)
		reagentimg.alpha = mix_alpha_from_reagents(reagents.reagent_list)
		var/matrix/M = matrix()
		M.Scale(1, reagents.total_volume/reagents.maximum_volume)
		reagentimg.transform = M
		reagentimg.pixel_y = 1.5 - ((reagents.total_volume/reagents.maximum_volume)*1.5)
		overlays += reagentimg

/obj/structure/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "A massive keg with a bottle of beer painted on the front."
	icon = 'icons/obj/objects.dmi'
	icon_state = "beertankTEMP"
	amount_per_transfer_from_this = 10

/obj/structure/reagent_dispensers/beerkeg/New()
	. = ..()
	reagents.add_reagent(BEER, 1000)

/obj/structure/reagent_dispensers/beerkeg/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is placing \his mouth underneath the keg nozzle and drowning \his sorrows! It looks like \he's trying to commit suicide.</span>")
	reagents.trans_to(user, amount_per_transfer_from_this)
	return(SUICIDE_ACT_TOXLOSS)

/obj/structure/reagent_dispensers/beerkeg/wrenchable()
	return 1

/obj/structure/reagent_dispensers/bloodkeg
	name = "old keg"
	desc = "A very old-looking keg. Some red liquid periodically drips from it."
	icon = 'icons/obj/objects.dmi'
	icon_state = "bloodkeg"
	amount_per_transfer_from_this = 10

/obj/structure/reagent_dispensers/bloodkeg/New()
	. = ..()
	reagents.add_reagent(BLOOD, 1000)

/obj/structure/reagent_dispensers/bloodkeg/wrenchable()
	return 1

/obj/structure/reagent_dispensers/bloodkeg/cultify()
	return

/obj/structure/reagent_dispensers/beerkeg/blob_act()
	explosion(src.loc,0,3,5,7,10)
	qdel(src)

/obj/structure/reagent_dispensers/virusfood
	name = "Virus Food Dispenser"
	desc = "A dispenser of virus food."
	icon = 'icons/obj/objects.dmi'
	icon_state = "virusfoodtank"
	amount_per_transfer_from_this = 10
	anchored = TRUE
	density = FALSE

/obj/structure/reagent_dispensers/virusfood/New()
	. = ..()
	reagents.add_reagent(VIRUSFOOD, 1000)

/obj/structure/reagent_dispensers/corn_oil_tank
	name = "oil vat"
	desc = "The greasiest place on the station, outside the captain's backroom."
	icon = 'icons/obj/objects.dmi'
	icon_state = "cornoiltank"
	amount_per_transfer_from_this = 50

/obj/structure/reagent_dispensers/corn_oil_tank/New()
	. = ..()
	reagents.add_reagent(CORNOIL, 1000)

/obj/structure/reagent_dispensers/silicate
	name = "\improper Silicate Tank"
	desc = "A tank filled with silicate."
	icon = 'icons/obj/objects.dmi'
	icon_state = "silicate tank"
	amount_per_transfer_from_this = 50

/obj/structure/reagent_dispensers/silicate/New()
	. = ..()
	reagents.add_reagent(SILICATE, 1000)

/obj/structure/reagent_dispensers/silicate/attackby(var/obj/item/W, var/mob/user)
	. = ..()
	if(.)
		return

	if(issilicatesprayer(W))
		var/obj/item/device/silicate_sprayer/S = W
		if(S.get_amount() >= S.max_silicate) // Already filled.
			to_chat(user, "<span class='notice'>\The [S] is already full!</span>")
			return

		reagents.trans_to(S, S.max_silicate)
		S.update_icon()
		to_chat(user, "<span class='notice'>Sprayer refilled.</span>")
		playsound(src, 'sound/effects/refill.ogg', 50, 1, -6)
		return 1

/obj/structure/reagent_dispensers/silicate/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is placing \his mouth underneath the tank nozzle and drinking the contents! It looks like \he's trying to commit suicide.</span>")
	reagents.trans_to(user, amount_per_transfer_from_this)
	return(SUICIDE_ACT_TOXLOSS)

/obj/structure/reagent_dispensers/sacid
	name = "\improper Sulphuric Acid Dispenser"
	desc = "A dispenser of sulphuric acid."
	icon = 'icons/obj/objects.dmi'
	icon_state = "sacidtank"
	amount_per_transfer_from_this = 50

/obj/structure/reagent_dispensers/sacid/New()
	. = ..()
	reagents.add_reagent(SACID, 1000)

/obj/structure/reagent_dispensers/sacid/attackby(var/obj/item/W, var/mob/user)
	. = ..()
	if(.)
		return

	if(issolder(W))
		var/obj/item/tool/solder/S = W
		if(S.reagents.get_reagent_amount() >= S.max_fuel) // Already filled.
			to_chat(user, "<span class='notice'>\The [S] is already full!</span>")
			return

		reagents.trans_to(S, S.max_fuel)
		S.update_icon()
		to_chat(user, "<span class='notice'>Solder refilled.</span>")
		playsound(src, 'sound/effects/refill.ogg', 50, 1, -6)
		return 1

/obj/structure/reagent_dispensers/sacid/suicide_act(var/mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species == "Grey")
			return ..() // Not harmed by this stuff, so get out
	to_chat(viewers(user), "<span class='danger'>[user] is placing \his mouth underneath the tank nozzle and drinking the contents! It looks like \he's trying to commit suicide.</span>")
	reagents.trans_to(user, amount_per_transfer_from_this)
	return(SUICIDE_ACT_BRUTELOSS)

/obj/structure/reagent_dispensers/degreaser
	name = "ethanol tank"
	desc = "A tank filled with ethanol, used in the degreasing of engines."
	icon_state = "degreasertank"
	amount_per_transfer_from_this = 5

/obj/structure/reagent_dispensers/degreaser/New()
	. = ..()
	reagents.add_reagent(ETHANOL, 1000)

/obj/structure/reagent_dispensers/degreaser/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is placing \his mouth underneath the tank nozzle and heavily drowning \his sorrows! It looks like \he's trying to commit suicide.</span>")
	reagents.trans_to(user, amount_per_transfer_from_this)
	return(SUICIDE_ACT_TOXLOSS)

/obj/structure/reagent_dispensers/spooktank
	name = "spooktank"
	desc = "A storage tank containing spook."
	icon = 'icons/obj/halloween.dmi'
	icon_state = "spooktank"
	amount_per_transfer_from_this = 10

/obj/structure/reagent_dispensers/spooktank/New()
	. = ..()
	reagents.add_reagent(MONSTERMASH, 1000)

/obj/structure/reagent_dispensers/cauldron
	name = "cauldron"
	icon_state = "cauldron"
	desc = "Double, double, toil and trouble. Fire burn, and cauldron bubble."
	flags = OPENCONTAINER

/obj/structure/reagent_dispensers/cauldron/attempt_heating()
	return // for now

/obj/structure/reagent_dispensers/cauldron/update_icon()
	overlays.len = 0

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]")

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)

		overlays += filling

/obj/structure/reagent_dispensers/cauldron/attackby(obj/item/weapon/W, mob/user)
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		to_chat(user, "<span class='notice'>You begin deconstructing \the [src].</span>")
		if(WT.do_weld(user, src, 50, 1))
			dump_reagents()
			to_chat(user, "<span class='notice'>You finish deconstructing \the [src].</span>")
			new /obj/item/stack/sheet/metal/(loc, 20)
			qdel(src)
	..()

/obj/structure/reagent_dispensers/cauldron/on_reagent_change()
	update_icon()

/obj/structure/reagent_dispensers/cauldron/wrenchable()
	return TRUE

/obj/structure/reagent_dispensers/cauldron/hide_own_reagents()
	return TRUE

/obj/structure/reagent_dispensers/cauldron/can_transfer(var/obj/item/weapon/reagent_containers/R, var/mob/user)
	if(user.a_intent != I_HELP)
		return TRUE
	return FALSE

/obj/structure/reagent_dispensers/cauldron/proc/dump_reagents()
	if(reagents?.total_volume > 10) //Beakersplashing only likes to do this sound when over 10 units
		playsound(src, 'sound/effects/slosh.ogg', 25, 1)
	usr.investigation_log(I_CHEMS, "has emptied \a [src] ([type]) containing [reagents.get_reagent_ids(1)] onto \the [usr.loc].")
	reagents.reaction(usr.loc)
	src.reagents.clear_reagents()


// BARRELS AND BARREL ACCESSORIES //
/obj/structure/reagent_dispensers/cauldron/barrel
	name = "metal barrel"
	icon_state = "metalbarrel"
	desc = "Originally used to store liquids & powder. It is now used as a source of comfort. This one is made of metal."
	layer = TABLE_LAYER
	flags = FPRINT | TWOHANDABLE | MUSTTWOHAND | OPENCONTAINER // If I end up being coherent enough to make it holdable in-hand
	var/list/exiting = list() // Manages people leaving the barrel //Turns out the flags here overwrote the new OPENCONTAINER flag so the barrels were fucked
	health = 50
	var/burning = FALSE
	is_cooktop = TRUE

/obj/structure/reagent_dispensers/cauldron/barrel/wood
	name = "wooden barrel"
	icon_state = "woodenbarrel"
	desc = "Originally used to store liquids & powder. It is now used as a source of comfort. This one is made of wood."
	health = 30
	is_cooktop = FALSE

/////////////////////Cooking stuff

/obj/structure/reagent_dispensers/cauldron/barrel/can_cook()
	return burning

/obj/structure/reagent_dispensers/cauldron/barrel/on_cook_start()
	update_icon()

/obj/structure/reagent_dispensers/cauldron/barrel/on_cook_stop()
	update_icon()

/obj/structure/reagent_dispensers/cauldron/barrel/render_cookvessel(offset_x = -1, offset_y = 6)
	..()

/obj/structure/reagent_dispensers/cauldron/barrel/cook_temperature()
	var/temperature = get_max_temperature()
	if(isnull(temperature))
		return ..() //Sanity in case the barrel runs out of fuel before this is called.
	return temperature

/obj/structure/reagent_dispensers/cauldron/barrel/cook_energy()
	var/cook_energy = get_thermal_transfer() * (SS_WAIT_FAST_OBJECTS / (2 SECONDS)) //Would be nice to change 2 SECONDS to a reference to the objects subsystem somehow.
	if(isnull(cook_energy))
		return ..() //Sanity in case the barrel runs out of fuel before this is called.
	return cook_energy

/////////////////////

/obj/structure/reagent_dispensers/cauldron/barrel/wood/attackby(obj/item/weapon/W, mob/user)
	if (iscrowbar(W))
		var/obj/item/tool/crowbar/C = W
		to_chat(user, "<span class='notice'>You begin deconstructing \the [src].</span>")
		C.playtoolsound(src, 50)
		if(do_after(user, src,50))
			to_chat(user, "<span class='notice'>You finish deconstructing \the [src].</span>")
			dump_reagents()
			new /obj/item/stack/sheet/wood(loc, 20)
			qdel(src)
		return
	..()

/obj/structure/reagent_dispensers/cauldron/barrel/attack_hand(mob/user as mob)
	if(burning && !cookvessel)
		user.visible_message("<span class = 'notice'>[user] carefully snuffs out \the [src] fire.</span>", "<span class='warning'>You carefully snuff out \the [src] fire.</span>")
		burning = FALSE
		processing_objects.Remove(src)
		update_icon()
	..()

/obj/structure/reagent_dispensers/cauldron/barrel/update_icon()
	overlays.len = 0
	if(burning)
		icon_state = "flamingmetalbarrel"
		set_light(3,4,LIGHT_COLOR_FIRE)
	else
		if(is_cooktop) //only metal barrels are cooktops
			icon_state = "metalbarrel"
		else
			icon_state = "woodenbarrel"
		set_light(0,0,LIGHT_COLOR_FIRE)
	render_cookvessel()

/obj/structure/reagent_dispensers/cauldron/barrel/take_damage(incoming_damage, damage_type, skip_break, mute, var/sound_effect = 1) //Custom take_damage() proc because of sound_effect behavior.
	health = max(0, health - incoming_damage)
	if(sound_effect)
		playsound(loc, 'sound/effects/grillehit.ogg', 75, 1)
	return try_break()

/obj/structure/reagent_dispensers/cauldron/barrel/try_break()
	if(health <= 0)
		spawn(1)
			Destroy()
		return TRUE
	else
		return FALSE

/obj/structure/reagent_dispensers/cauldron/barrel/kick_act(mob/living/carbon/human/H)
	..()
	dump_reagents()
	H.visible_message("<span class='warning'>[usr] kicks \the [src]!</span>", "<span class='notice'>You kick \the [src].</span>")
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)

/obj/structure/reagent_dispensers/cauldron/barrel/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W.is_wrench(user) || (istype(W, /obj/item/weapon/reagent_containers) && !W.is_cookvessel)) //what did irradiation mean by this
		return

	else if(W.is_hot() || W.sharpness_flags & (HOT_EDGE))
		if(start_fire(user))
			user.visible_message("<span class='notice'>[user] ignites \the [src]'s contents with \the [W].</span>")
		return

	else if(istype(W,/obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = W
		var/mob/living/target = G.affecting
		user.visible_message("<span class='danger'>[user] begins to drag [target] into the barrel!</span>")
		if(do_after_many(user,list(target,src),10)) //Twice the normal time
			enter_barrel(target)

	//Everything below here could probably be desnowflaked. As all parents of src except /obj/ itself lack INVOKE_EVENT on attackby, and there isn't a continuous supercall chain, we'll handle cooking vessels like this for now.
	else if(is_cooktop)
		INVOKE_EVENT(src, /event/attackby, "attacker" = user, "item" = W)

	else
		take_damage(W.force)
		user.delayNextAttack(10)
		..()

/obj/structure/reagent_dispensers/cauldron/barrel/proc/enter_barrel(mob/user)
	user.forceMove(src)
	update_icon()
	user.reset_view()
	to_chat(user,"<span class='notice'>You enter \the [src].</span>")

/obj/structure/reagent_dispensers/cauldron/barrel/MouseDropTo(atom/movable/O, mob/user)
	if(O.loc == user || !isturf(O.loc) || !isturf(user.loc) || !user.Adjacent(O)) //no you can't pull things out of your ass
		return
	if(user.incapacitated() || user.lying) //are you cuffed, dying, lying, stunned or other
		return
	if(!Adjacent(user) || !user.Adjacent(src)) // is the mob too far away from you, or are you too far away from the source
		return
	if(O.locked_to)
		return
	else if(O.anchored)
		return
	if(burning)
		return
	if(issilicon(O)) //robutts dont fit
		return
	if(!ishigherbeing(user) && !isrobot(user)) //No ghosts or mice putting people into the barrel
		return
	var/mob/living/target = O
	if(!istype(target))
		return
	for(var/mob/living/carbon/slime/M in range(1,target))
		if(M.Victim == target)
			to_chat(user, "[target.name] will not fit into \the [src] because they have a slime latched onto their head.")
			return

	if(target == user)
		to_chat(user,"<span class='notice'>You begin to climb into the barrel.</span>")
		if(do_after(target,src,10))
			enter_barrel(target)
	else
		user.visible_message("<span class='danger'>[user] begins to drag [target] into the barrel!</span>")
		if(do_after_many(user,list(target,src),10)) //Twice the normal time
			enter_barrel(target)

/obj/structure/reagent_dispensers/cauldron/barrel/container_resist(mob/user)
	if (exiting.Remove(user))
		to_chat(user,"<span class='warning'>You stop climbing free of \the [src].</span>")
		return
	visible_message("<span class='warning'>[user] begins to climb free of the \the [src]!</span>")
	exiting += user
	spawn(3 SECONDS)
		if(loc && exiting.Remove(user))
			if(burning)
				if(istype(user,/mob/living))
					var/mob/living/L = user
					L.adjustFireLoss(10)
					L.adjust_fire_stacks(1)
					to_chat(L,"<span class='notice'>You set yourself on fire exiting the barrel!</span>")
			user.forceMove(loc)
			update_icon()
			to_chat(user,"<span class='notice'>You climb free of the barrel.</span>")

/obj/structure/reagent_dispensers/cauldron/barrel/Destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
	..()

/obj/structure/reagent_dispensers/cauldron/barrel/bullet_act(var/obj/item/projectile/Proj)
	. = ..()
	if(Proj.damage)
		take_damage(Proj.damage)

/obj/structure/reagent_dispensers/cauldron/barrel/ex_act(severity)
	switch(severity)
		if(1)
			Destroy()
		if(2)
			Destroy()
		if(3)
			take_damage(rand(15,45), sound_effect = 0)

/obj/structure/reagent_dispensers/cauldron/barrel/attack_animal(var/mob/living/simple_animal/M)
	if(take_damage(rand(M.melee_damage_lower, M.melee_damage_upper)))
		M.visible_message("<span class='danger'>[M] tears open \the [src]!</span>")
	else
		M.visible_message("<span class='danger'>[M] [M.attacktext] \the [src]!</span>")
	M.delayNextAttack(10)
	return 1

/obj/structure/reagent_dispensers/cauldron/barrel/attack_alien(mob/user)
	user.visible_message("<span class='danger'>[user] rips \the [src] apart!</span>")
	Destroy()

/obj/structure/reagent_dispensers/cauldron/barrel/examine(mob/user)
	..()
	if(burning)
		to_chat(user, "<span class='info'>The contents of \the [src] are burning.</span>")

/obj/structure/reagent_dispensers/cauldron/barrel/proc/start_fire(mob/user)
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/G = T.return_air()
	if(!G || G.molar_density(GAS_OXYGEN) < 0.1 / CELL_VOLUME)
		visible_message("<span class = 'warning'>\The [src] fails to ignite due to lack of oxygen.</span>")
		return 0
	for(var/possible_fuel in possible_fuels)
		if(reagents.has_reagent(possible_fuel))
			burning = TRUE
			processing_objects.Add(src)
			update_icon()
			return 1
	visible_message("<span class = 'warning'>\The [src] fails to ignite due to lack of fuel.</span>")
	return 0

/obj/structure/reagent_dispensers/cauldron/barrel/process()
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/G = T.return_air()
	if(!G || G.molar_density(GAS_OXYGEN) < 0.1 / CELL_VOLUME)
		visible_message("<span class = 'warning'>\The [src] splutters out from lack of oxygen.</span>","<span class = 'warning'>You hear something cough.</span>")
		burning = FALSE
		processing_objects.Remove(src)
		update_icon()
		return

	var/max_temperature
//	var/thermal_energy_transfer to be used later if barrels should heat the room they're in
	var/consumption_rate
	var/unsafety = 0 //Possibility it lights things on its turf
	var/o2_consumption
	var/co2_consumption

	playsound(src, pick(comfyfire), G.molar_density(GAS_OXYGEN)/MOLES_CELLSTANDARD,1)

	for(var/possible_fuel in possible_fuels)
		if(reagents.has_reagent(possible_fuel))
			burning = TRUE
			var/list/fuel_stats = possible_fuels[possible_fuel]
			max_temperature = fuel_stats["max_temperature"]
//			thermal_energy_transfer = fuel_stats["thermal_energy_transfer"] to be used later if barrels should heat the room they're in
			consumption_rate = fuel_stats["consumption_rate"]
			unsafety = fuel_stats["unsafety"]
			o2_consumption = fuel_stats["o2_cons"]
			co2_consumption = fuel_stats["co2_cons"]

			reagents.remove_reagent(possible_fuel, consumption_rate)
			G.adjust_multi(
				GAS_OXYGEN, -o2_consumption,
				GAS_CARBON, -co2_consumption)
			if(prob(unsafety) && T)
				T.hotspot_expose(max_temperature, 5)
			break

	if(!max_temperature)
		visible_message("<span class = 'warning'>\The [src] splutters out from lack of fuel.</span>","<span class = 'warning'>You hear something cough.</span>")
		burning = FALSE
		processing_objects.Remove(src)
		update_icon()
		return

/obj/structure/reagent_dispensers/cauldron/barrel/proc/get_max_temperature()
	var/max_temperature
	for(var/possible_fuel in possible_fuels)
		if(reagents.has_reagent(possible_fuel))
			var/list/fuel_stats = possible_fuels[possible_fuel]
			max_temperature = fuel_stats["max_temperature"]
			break
	return max_temperature

/obj/structure/reagent_dispensers/cauldron/barrel/proc/get_thermal_transfer()
	var/thermal_transfer
	for(var/possible_fuel in possible_fuels)
		if(reagents.has_reagent(possible_fuel))
			var/list/fuel_stats = possible_fuels[possible_fuel]
			thermal_transfer = fuel_stats["thermal_transfer"]
			break
	return thermal_transfer

/obj/structure/reagent_dispensers/cauldron/barrel/wood/start_fire(mob/user)
	return 0 //nice try!
