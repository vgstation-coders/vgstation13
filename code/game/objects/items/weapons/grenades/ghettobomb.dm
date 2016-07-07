//improvised explosives//

//iedcasing assembly crafting//
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/attackby(var/obj/item/I, mob/user as mob)
    if(istype(I, /obj/item/device/assembly/igniter))
        var/obj/item/device/assembly/igniter/G = I
        var/obj/item/weapon/grenade/iedcasing/W = new /obj/item/weapon/grenade/iedcasing
        user.before_take_item(G)
        user.before_take_item(src)
        user.put_in_hands(W)
        to_chat(user, "<span  class='notice'>You stuff the [I] into the [src], emptying the contents beforehand.</span>")
        W.underlays += image(src.icon, icon_state = src.icon_state)
        qdel(I)
        I = null
        qdel(src)


/obj/item/weapon/grenade/iedcasing
	name = "improvised explosive assembly"
	desc = "An igniter stuffed into an aluminum shell."
	w_class = W_CLASS_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "improvised_grenade"
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	var/assembled = 0
	active = 1
	det_time = 50



/obj/item/weapon/grenade/iedcasing/afterattack(atom/target, mob/user , flag) //Filling up the can
	if(assembled == 0)
		if(istype(target, /obj/structure/reagent_dispensers/fueltank) && target.Adjacent(user))
			if(target.reagents.total_volume < 50)
				to_chat(user, "<span  class='notice'>There's not enough fuel left to work with.</span>")
				return
			var/obj/structure/reagent_dispensers/fueltank/F = target
			F.reagents.remove_reagent(FUEL, 50, 1)//Deleting 50 fuel from the welding fuel tank,
			assembled = 1
			to_chat(user, "<span  class='notice'>You've filled the makeshift explosive with welding fuel.</span>")
			playsound(get_turf(src), 'sound/effects/refill.ogg', 50, 1, -6)
			desc = "An improvised explosive assembly. Filled to the brim with 'Explosive flavor'"
			overlays += image('icons/obj/grenade.dmi', icon_state = "improvised_grenade_filled")
			return


/obj/item/weapon/grenade/iedcasing/attackby(var/obj/item/I, mob/user as mob) //Wiring the can for ignition
	if(istype(I, /obj/item/stack/cable_coil))
		if(assembled == 1)
			var/obj/item/stack/cable_coil/C = I
			C.use(1)
			assembled = 2
			to_chat(user, "<span  class='notice'>You wire the igniter to detonate the fuel.</span>")
			desc = "A weak, improvised explosive."
			overlays += image('icons/obj/grenade.dmi', icon_state = "improvised_grenade_wired")
			name = "improvised explosive"
			active = 0
			det_time = rand(30,80)

/obj/item/weapon/grenade/iedcasing/attack_self(mob/user as mob) //Activating the IED
	if(!active)
		if(clown_check(user))
			to_chat(user, "<span class='warning'>You light the [name]!</span>")
			active = 1
			overlays -= image('icons/obj/grenade.dmi', icon_state = "improvised_grenade_filled")
			icon_state = initial(icon_state) + "_active"
			assembled = 3
			add_fingerprint(user)
			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)
			var/log_str = "[key_name(usr)]<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> has primed a [name] for detonation at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>."
			message_admins(log_str)
			log_game(log_str)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()
			spawn(det_time)
				prime()

/obj/item/weapon/grenade/iedcasing/prime() //Blowing that can up
	update_mob()
	explosion(get_turf(src.loc),-1,0,2)

	if(istype(loc, /obj/item/weapon/legcuffs/beartrap))
		var/obj/item/weapon/legcuffs/beartrap/boomtrap = loc
		if(istype(boomtrap.loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = loc.loc
			if(H.legcuffed == boomtrap)
				var/datum/organ/external/leg = H.get_organ("[pick("l","r")]_leg") //Either left or right leg
				if(leg && !(leg.status & ORGAN_DESTROYED))
					leg.droplimb(1,0)

				qdel(H.legcuffed)
				H.legcuffed = null
	qdel(src)

/obj/item/weapon/grenade/iedcasing/examine(mob/user)
	..()
	if(assembled == 3)
		to_chat(user, "<span class='info'>You can't tell when it will explode!</span>")//Stops you from checking the time to detonation unlike regular grenades
