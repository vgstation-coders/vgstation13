// Assuming this is http://en.wikipedia.org/wiki/Butane
// (Autoignition temp 288°C, or 561.15°K)
// Used in fueltanks exploding.
#define AUTOIGNITION_WELDERFUEL 561.15

/obj/structure/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	flags = FPRINT
	pressure_resistance = 2*ONE_ATMOSPHERE

	var/amount_per_transfer_from_this = 10
	var/possible_transfer_amounts = list(10,25,50,100)
	var/can_attach = 0
	var/modded = 0
	var/can_open = 0
	var/open = 0
	var/obj/item/device/assembly_holder/rig = null
	var/can_refill = 0 //for lighters, welders, other tools

/obj/structure/reagent_dispensers/AltClick(mob/user)
	if(!user.incapacitated() && user.Adjacent(get_turf(src)) && possible_transfer_amounts)
		set_APTFT()
		return
	return ..()

/obj/structure/reagent_dispensers/attack_hand()
	if (rig)
		usr.visible_message("[usr] begins to detach [rig] from \the [src].", "You begin to detach [rig] from \the [src]")
		if(do_after(usr, src, 20))
			usr.visible_message("<span class='notice'>[usr] detaches [rig] from \the [src].", "<span class='notice'>You detach [rig] from \the [src]</span>")
			if(rig)
				rig.forceMove(get_turf(usr))
				rig.master = null
				rig = null
			overlays = new/list()
	..()

/obj/structure/reagent_dispensers/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (iscrowbar(W) && can_open)
		user.visible_message("[user] pries [src]'s fill cap [open ? "closed" : "open"].", \
			"You pry [src]'s fill cap [open ? "closed" : "open"].")
		open = open ? 0 : 1
		flags |= OPENCONTAINER
	if (W.is_wrench(user) && can_attach)
		user.visible_message("[user] wrenches [src]'s faucet [modded ? "closed" : "open"].", \
			"You wrench [src]'s faucet [modded ? "closed" : "open"].")
		modded = modded ? 0 : 1
	if (istype(W,/obj/item/device/assembly_holder) && can_attach)
		if (rig)
			to_chat(user, "<span class='warning'>There is another device in the way.</span>")
			return ..()
		user.visible_message("[user] begins rigging [W] to \the [src].", "You begin rigging [W] to \the [src]")
		if(do_after(user, src, 20))
			if(rig)
				to_chat(user, "<span class='warning'>Somebody already attached something to \the [src].</span>")
				return
			if(!user.drop_item(W, src))
				to_chat(user,"<span class='warning'>Oops! You can't let go of \the [W]!</span>")
				return

			user.visible_message("<span class='notice'>[user] rigs [W] to \the [src].", "<span class='notice'>You rig [W] to \the [src]</span>")

			var/obj/item/device/assembly_holder/H = W
			if (istype(H.a_left,/obj/item/device/assembly/igniter) || istype(H.a_right,/obj/item/device/assembly/igniter))
				message_admins("[key_name_admin(user)] rigged reagent tank at ([loc.x],[loc.y],[loc.z]) for explosion.")
				log_game("[key_name(user)] rigged reagent tank at ([loc.x],[loc.y],[loc.z]) for explosion.")

			rig = W
			rig.master = src

			var/image/test = image(W.appearance, src, "pixel_x" = 6, "pixel_y" = -1)
			overlays += test

	if(W.is_wrench(user) && wrenchable())
		return wrenchAnchor(user, W)

/obj/structure/reagent_dispensers/examine(mob/user)
	..()
	if(!open)
		reagents.get_examine(user)
	if (modded)
		to_chat(user, "<span class='warning'>The faucet is wrenched open, leaking the the contents of \the [src]!</span>")
	if(rig)
		to_chat(user, "<span class='notice'>There is some kind of device rigged to the tank.</span>")
	if (open)
		to_chat(user, "<span class='notice'>The tank's fill cap is open.</span>")

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
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				new /obj/effect/effect/water(src.loc)
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				new /obj/effect/effect/water(src.loc)
				qdel(src)
				return
		else
	return

/obj/structure/reagent_dispensers/blob_act()
	explode()

/obj/structure/reagent_dispensers/beam_connect(var/obj/effect/beam/B)
	..()
	apply_beam_damage(B)


/obj/structure/reagent_dispensers/beam_disconnect(var/obj/effect/beam/B)
	..()
	apply_beam_damage(B)

/obj/structure/reagent_dispensers/apply_beam_damage(var/obj/effect/beam/B)
	if(isturf(get_turf(src)) && B.get_damage() >= 15)
		explode()

/obj/structure/reagent_dispensers/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet)||istype(Proj,/obj/item/projectile/ricochet))
		if(Proj.get_damage())
			log_attack("<font color='red'>[key_name(Proj.firer)] shot [src]/([formatJumpTo(src)]) with a [Proj.type]</font>")
			if(Proj.firer)//turrets don't have "firers"
				Proj.firer.attack_log += "\[[time_stamp()]\] <b>[key_name(Proj.firer)]</b> shot <b>[src]([x],[y],[z])</b> with a <b>[Proj.type]</b>"
				msg_admin_attack("[key_name(Proj.firer)] shot [src]/([formatJumpTo(src)]) with a [Proj.type] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[Proj.firer.x];Y=[Proj.firer.y];Z=[Proj.firer.z]'>JMP</a>)") //BS12 EDIT ALG
			else
				msg_admin_attack("[src] was shot by a [Proj.type] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)") //BS12 EDIT ALG
			explode()
	return ..()

/obj/structure/reagent_dispensers/ex_act()
	explode()

/obj/structure/reagent_dispensers/singularity_act()
	qdel(src)
	return  2

/obj/structure/reagent_dispensers/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature >= AUTOIGNITION_WELDERFUEL)
		explode()

/obj/structure/reagent_dispensers/bumped_by_firebird(var/obj/structure/bed/chair/vehicle/firebird/F)
	visible_message("<span class='danger'>\the [F] crashes into \the [src]!</span>")
	explode()

/obj/structure/reagent_dispensers/proc/explode()
	var/fuel_amount
	if(reagents.get_reagent_amount(PLASMA))
		fuel_amount = reagents.get_reagent_amount(PLASMA)
		if (fuel_amount > 500)
			explosion(src.loc,2,4,6)
		else if (fuel_amount > 100)
			explosion(src.loc,1,2,4)
		else
			explosion(src.loc,0,1,2)
		if(src)
			qdel(src)
		return 1

	else if(reagents.get_reagent_amount(FUEL))
		fuel_amount = reagents.get_reagent_amount(FUEL)
		if (fuel_amount > 500)
			explosion(src.loc,1,2,4)
		else if (fuel_amount > 100)
			explosion(src.loc,0,1,3)
		else
			explosion(src.loc,-1,1,2)
		if(src)
			qdel(src)
		return 1

	else if(reagents.get_reagent_amount(ETHANOL))
		fuel_amount = reagents.get_reagent_amount(ETHANOL)
		if (fuel_amount > 500)
			explosion(src.loc,0,1,3)
		else if (fuel_amount > 100)
			explosion(src.loc,-1,1,2)
		else
			explosion(src.loc,-1,0,2)
		if(src)
			qdel(src)
		return 1

	else if(reagents.get_reagent_amount(CORNOIL))
		fuel_amount = reagents.get_reagent_amount(CORNOIL)
		if (fuel_amount > 500)
			explosion(src.loc,-1,1,2)
		else if (fuel_amount > 100)
			explosion(src.loc,-1,0,1)
		else
			explosion(src.loc,-1,0,1)
		if(src)
			qdel(src)
		return 1

	else
		return 0

/obj/structure/reagent_dispensers/New()
	. = ..()
	create_reagents(1000)

	if (!possible_transfer_amounts)
		verbs -= /obj/structure/reagent_dispensers/verb/set_APTFT

/obj/structure/reagent_dispensers/proc/is_empty()
	return reagents.total_volume <= 0

/obj/structure/reagent_dispensers/proc/can_transfer()
	if(!open)
		return TRUE
	return FALSE

/obj/structure/reagent_dispensers/proc/can_fill_tools()
	if(can_refill)
		return TRUE
	return FALSE

//Dispensers
/obj/structure/reagent_dispensers/watertank
	name = "watertank"
	desc = "A storage tank containing water."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	amount_per_transfer_from_this = 10
	can_attach = 1
	can_open = 1
	can_refill = 1

/obj/structure/reagent_dispensers/watertank/New()
	. = ..()
	reagents.add_reagent(WATER, 1000)

/obj/structure/reagent_dispensers/fueltank
	name = "fueltank"
	desc = "A storage tank containing welding fuel."
	icon = 'icons/obj/objects.dmi'
	icon_state = "weldtank"
	amount_per_transfer_from_this = 10
	can_attach = 1
	can_open = 1
	can_refill = 1

/*/obj/structure/reagent_dispensers/fueltank/hear_talk(mob/living/M, text)
	if(rig)
		rig.hear_talk(M,text)
*/

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
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.remove_fuel(0, user))
			new /obj/item/stack/sheet/mineral/plastic (src.loc,4)
			qdel(src)
			return
	else
		..()

/obj/structure/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "A massive keg with a bottle of beer painted on the front."
	icon = 'icons/obj/objects.dmi'
	icon_state = "beertankTEMP"
	amount_per_transfer_from_this = 10

/obj/structure/reagent_dispensers/beerkeg/New()
	. = ..()
	reagents.add_reagent(BEER, 1000)

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
	can_attach = 1
	can_open = 1
	can_refill = 1

/obj/structure/reagent_dispensers/corn_oil_tank/New()
	. = ..()
	reagents.add_reagent(CORNOIL, 1000)

/obj/structure/reagent_dispensers/silicate
	name = "\improper Silicate Tank"
	desc = "A tank filled with silicate."
	icon = 'icons/obj/objects.dmi'
	icon_state = "silicate tank"
	amount_per_transfer_from_this = 50
	can_attach = 1
	can_open = 1
	can_refill = 1

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

/obj/structure/reagent_dispensers/degreaser
	name = "ethanol tank"
	desc = "A tank filled with ethanol, used in the degreasing of engines."
	icon_state = "degreasertank"
	amount_per_transfer_from_this = 5
	can_attach = 1
	can_open = 1
	can_refill = 1

/obj/structure/reagent_dispensers/degreaser/New()
	. = ..()
	reagents.add_reagent(ETHANOL, 1000)

/obj/structure/reagent_dispensers/spooktank
	name = "spooktank"
	desc = "A storage tank containing spook."
	icon = 'icons/obj/halloween.dmi'
	icon_state = "spooktank"
	amount_per_transfer_from_this = 10
	can_attach = 1
	can_open = 1
	can_refill = 1

/obj/structure/reagent_dispensers/spooktank/New()
	. = ..()
	reagents.add_reagent(MONSTERMASH, 1000)

/obj/structure/reagent_dispensers/cauldron
	name = "cauldron"
	icon_state = "cauldron"
	desc = "Double, double, toil and trouble. Fire burn, and cauldron bubble."

/obj/structure/reagent_dispensers/cauldron/update_icon()
	overlays.len = 0

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]")

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)

		overlays += filling

/obj/structure/reagent_dispensers/cauldron/on_reagent_change()
	update_icon()

/obj/structure/reagent_dispensers/cauldron/wrenchable()
	return TRUE

/obj/structure/reagent_dispensers/cauldron/is_open_container()
	return TRUE

/obj/structure/reagent_dispensers/cauldron/hide_own_reagents()
	return TRUE

/obj/structure/reagent_dispensers/cauldron/can_transfer(var/obj/item/weapon/reagent_containers/R, var/mob/user)
	if(user.a_intent != I_HELP)
		return TRUE
	return FALSE

// BARRELS AND BARREL ACCESSORIES //
/obj/structure/reagent_dispensers/cauldron/barrel
	name = "metal barrel"
	icon_state = "metalbarrel"
	desc = "Originally used to store liquids & powder. It is now used as a source of comfort. This one is made of metal."
	layer = TABLE_LAYER
	flags = FPRINT | TWOHANDABLE | MUSTTWOHAND // If I end up being coherent enough to make it holdable in-hand
	var/list/exiting = list() // Manages people leaving the barrel
	throwforce = 40 // Ends up dealing 20~ brute when thrown because thank you, based throw damage formula
	var/health = 50

/obj/structure/reagent_dispensers/cauldron/barrel/wood
	name = "wooden barrel"
	icon_state = "woodenbarrel"
	desc = "Originally used to store liquids & powder. It is now used as a source of comfort. This one is made of wood."
	health = 30

/obj/structure/reagent_dispensers/cauldron/barrel/update_icon()
	return

/obj/structure/reagent_dispensers/cauldron/barrel/proc/take_damage(var/damage, var/sound_effect = 1)
	health = max(0, health - damage)
	if(sound_effect)
		playsound(loc, 'sound/effects/grillehit.ogg', 75, 1)
	if(health <= 0)
		spawn(1)
			Destroy()
		return 1
	return 0

/obj/structure/reagent_dispensers/cauldron/barrel/kick_act(mob/living/carbon/human/H)
	..()
	if (!reagents)
		return 1
	if(reagents.total_volume > 10) //Beakersplashing only likes to do this sound when over 10 units
		playsound(src, 'sound/effects/slosh.ogg', 25, 1)
	H.investigation_log(I_CHEMS, "has emptied \a [src] ([type]) containing [reagents.get_reagent_ids(1)] onto \the [usr.loc].")
	reagents.reaction(usr.loc)
	src.reagents.clear_reagents()
	H.visible_message("<span class='warning'>[usr] kicks \the [src]!</span>", "<span class='notice'>You kick \the [src].</span>")
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)

/obj/structure/reagent_dispensers/cauldron/barrel/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W.is_wrench(user) || istype(W,/obj/item/weapon/reagent_containers))
		return
	if(istype(W,/obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = W
		var/mob/living/target = G.affecting
		user.visible_message("<span class='danger'>[user] begins to drag [target] into the barrel!</span>")
		if(do_after_many(user,list(target,src),10)) //Twice the normal time
			enter_barrel(target)
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
			take_damage(rand(15,45), 0)

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
