/obj/item/weapon/gun/gatling
	name = "gatling gun"
	desc = "Ya-ta-ta-ta-ta-ta-ta-ta ya-ta-ta-ta-ta-ta-ta-ta do-de-da-va-da-da-dada! Kaboom-Kaboom!"
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "minigun"
	item_state = "minigun0"
	var/base_icon_state = "minigun"
	origin_tech = Tc_MATERIALS + "=4;" + Tc_COMBAT + "=6"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 1
	slot_flags = null
	flags = FPRINT | TWOHANDABLE | SLOWDOWN_WHEN_CARRIED
	slowdown = MINIGUN_SLOWDOWN_NONWIELDED
	w_class = W_CLASS_HUGE//we be fuckin huge maaan
	fire_delay = 0
	fire_sound = 'sound/weapons/gatling_fire.ogg'
	var/gatlingbullet = /obj/item/projectile/bullet/gatling
	var/max_shells = 200
	var/current_shells = 200
	var/rounds_per_burst = 4
	var/casing_type = /obj/item/ammo_casing_gatling

/obj/item/weapon/gun/gatling/New()
	base_icon_state = icon_state
	..()

/obj/item/weapon/gun/gatling/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>Has [current_shells] round\s remaining.</span>")

/obj/item/weapon/gun/gatling/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	if(flag)
		return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.

		return
	if(wielded)
		Fire(A,user,params, "struggle" = struggle)
	else
		to_chat(user, "<span class='warning'>You must dual-wield \the [src] before you can fire it!</span>")

/obj/item/weapon/gun/gatling/Fire(atom/target, mob/living/user, params, reflex = 0, struggle = 0, var/use_shooter_turf = FALSE)
	..()
	var/list/turf/possible_turfs = list()
	for(var/turf/T in orange(target,1))
		possible_turfs += T
	spawn()
		for(var/i = 1; i < rounds_per_burst; i++)
			sleep(1)
			var/newturf = pick(possible_turfs)
			..(newturf,user,params,reflex,struggle)

/obj/item/weapon/gun/gatling/update_wield(mob/user)
	item_state = "[base_icon_state][wielded ? 1 : 0]"
	if(wielded)
		slowdown = MINIGUN_SLOWDOWN_WIELDED
	else
		slowdown = MINIGUN_SLOWDOWN_NONWIELDED

/obj/item/weapon/gun/gatling/process_chambered()
	if(in_chamber)
		return 1
	if(current_shells)
		current_shells--
		update_icon()
		in_chamber = new gatlingbullet()//We create bullets as we are about to fire them. No other way to remove them.
		if (casing_type)
			new casing_type(get_turf(src))
		return 1
	return 0

/obj/item/weapon/gun/gatling/can_discharge() //Why is this gun not a child of gun/projectile?
	if (current_shells && wielded)
		return 1

/obj/item/weapon/gun/gatling/update_icon()
	if(current_shells)
		icon_state = "[base_icon_state][Ceiling(current_shells/max_shells*100,25)]"
	else
		icon_state = "[base_icon_state]0"

/obj/item/weapon/gun/gatling/attack_self(mob/user)
	if(wielded)
		unwield(user)
	else
		wield(user)

/obj/item/ammo_casing_gatling
	name = "large bullet casing"
	desc = "An oversized bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "gatling-casing"
	flags = FPRINT
	siemens_coefficient = 1
	throwforce = 1
	w_class = W_CLASS_TINY
	w_type = RECYK_METAL

/obj/item/ammo_casing_gatling/New()
	..()
	pixel_x = rand(-10.0, 10) * PIXEL_MULTIPLIER
	pixel_y = rand(-10.0, 10) * PIXEL_MULTIPLIER
	dir = pick(cardinal)

/obj/item/weapon/gun/gatling/beegun
	name = "bee gun"
	desc = "The apocalypse hasn't even bee-gun!"//I'm not even sorry
	icon_state = "beegun"
	item_state = "beegun0"
	origin_tech = Tc_MATERIALS + "=4;" + Tc_COMBAT + "=6;" + Tc_BIOTECH + "=5"
	recoil = 0
	gatlingbullet = /obj/item/projectile/bullet/beegun
	casing_type = null

/obj/item/weapon/gun/gatling/beegun/chillgun
	name = "chill gun"
	desc = "Rapid chill-pill dispenser"
	icon_state = "chillgun"
	item_state = "chillgun0"
	gatlingbullet = /obj/item/projectile/bullet/beegun/chillbug

/obj/item/weapon/gun/gatling/beegun/hornetgun
	name = "hornet gun"
	desc = "Doesn't actually use .22 Hornet cartridges."
	icon_state = "hornetgun"
	item_state = "hornetgun0"
	gatlingbullet = /obj/item/projectile/bullet/beegun/hornet
	
	
/obj/item/weapon/gun/gatling/beegun/ss_visceratorgun
	name = "viscerator gun"
	desc = "THE HAAAAAAACKS!"
	icon_state = "ss_visceratorgun"
	item_state = "ss_visceratorgun0"	
	gatlingbullet = /obj/item/projectile/bullet/beegun/ss_viscerator

/obj/item/weapon/gun/gatling/batling
	name = "batling gun"
	desc = "Batter up!"
	icon_state = "batlinggun"
	item_state = "batlinggun0"
	gatlingbullet = /obj/item/projectile/bullet/baton
	max_shells = 100
	current_shells = 100
	rounds_per_burst = 5
	casing_type = /obj/item/ammo_casing_gatling/batling
	var/list/rigged_shells = list()

/obj/item/weapon/gun/gatling/batling/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/thebaton = W
		if(user.drop_item(thebaton) && thebaton.canbehonkified())
			if(!thebaton.bcell)
				to_chat(user, "<span class='warning'>\The [thebaton] doesn't have a cell.</span>")
				..()
				return
			if(!thebaton.bcell.maxcharge > thebaton.hitcost)
				to_chat(user, "<span class='warning'>\The [thebaton] doesn't have enough charge.</span>")
				..()
				return
			if(current_shells >= max_shells)
				to_chat(user, "<span class='warning'>\The [src] is already filled to capacity.</span>")
				..()
				return
			to_chat(user, "<span class='notice'>You load \the [thebaton] into \the [src].</span>")
			current_shells = min(current_shells+20,max_shells)  //Yup, 5 batons for max ammo.
			if(thebaton.bcell.rigged)
				rigged_shells.Add(current_shells) //this one's gonna be a blast
			qdel(W)
			update_icon()
	..()

/obj/item/weapon/gun/gatling/batling/process_chambered()
	if(in_chamber)
		return 1
	var/riggedshot = FALSE
	if(current_shells)
		if(current_shells in rigged_shells)
			riggedshot = TRUE
			rigged_shells.Remove(current_shells)
		current_shells--
		update_icon()
		var/obj/item/projectile/bullet/baton/shootbaton = new gatlingbullet()
		shootbaton.rigged = riggedshot
		in_chamber = shootbaton
		if (casing_type)
			new casing_type(get_turf(src))
		return 1
	return 0

/obj/item/weapon/gun/gatling/batling/update_icon()
	if(current_shells)
		icon_state = "[base_icon_state][Ceiling(current_shells/max_shells*100,20)]"
	else
		icon_state = "[base_icon_state]0"

/obj/item/ammo_casing_gatling/batling
	name = "baton casing"
	desc = "The remains of a stun baton."
	icon_state = "batling-casing"
