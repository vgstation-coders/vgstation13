
/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "A small, low capacity gun used for non-lethal takedowns."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/Taser.ogg'
	charge_cost = 100
	projectile_type = "/obj/item/projectile/energy/electrode"
	cell_type = "/obj/item/weapon/cell/crap"

/obj/item/weapon/gun/energy/taser/isHandgun()
	return TRUE

/obj/item/weapon/gun/energy/taser/ricochet
	name = "ricochet taser gun"
	desc = "The nightmare-creation of Alcatraz IV. Who let it free?"
	projectile_type = "/obj/item/projectile/ricochet/taser"

/obj/item/weapon/gun/energy/taser/cyborg
	name = "taser gun"
	desc = "A small, low capacity gun used for non-lethal takedowns."
	icon_state = "taser"
	fire_sound = 'sound/weapons/Taser.ogg'
	charge_cost = 100
	projectile_type = "/obj/item/projectile/energy/electrode"
	cell_type = "/obj/item/weapon/cell/secborg"
	var/charge_tick = 0
	var/recharge_time = 10 //Time it takes for shots to recharge (in ticks)

/obj/item/weapon/gun/energy/taser/cyborg/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/taser/cyborg/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/weapon/gun/energy/taser/cyborg/process() //Every [recharge_time] ticks, recharge a shot for the cyborg
	charge_tick++
	if(charge_tick < recharge_time)
		return 0
	charge_tick = 0

	if(!power_supply)
		return 0 //sanity
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			R.cell.use(charge_cost) 		//Take power from the borg...
			power_supply.give(charge_cost)	//... to recharge the shot

	update_icon()
	return 1

/obj/item/weapon/gun/energy/taser/cyborg/restock()
	if(power_supply.charge < power_supply.maxcharge)
		power_supply.give(charge_cost)
		update_icon()
	else
		charge_tick = 0

/obj/item/weapon/gun/energy/taser/team_security
	name = "\improper Team Security sniper taser gun"
	icon_state = "taser"
	charge_cost = 500
	fire_sound = 'sound/effects/intervention.ogg'

/obj/item/weapon/gun/energy/stunrevolver
	name = "stun revolver"
	desc = "A high-tech revolver that fires stun cartridges. The stun cartridges can be recharged using a conventional energy weapon recharger."
	icon_state = "stunrevolver"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	fire_sound = 'sound/weapons/Gunshot.ogg'
	origin_tech = Tc_COMBAT + "=3;" + Tc_MATERIALS + "=3;" + Tc_POWERSTORAGE + "=2"
	charge_cost = 125
	projectile_type = "/obj/item/projectile/energy/electrode"
	cell_type = "/obj/item/weapon/cell"

/obj/item/weapon/gun/energy/stunrevolver/isHandgun()
	return TRUE

/obj/item/weapon/gun/energy/stunrevolver/failure_check(var/mob/living/carbon/human/M)
	if(prob(15))
		fire_delay += 2
		to_chat(M, "<span class='warning'>\The [src] buzzes.</span>")
		return 1
	if(prob(5))
		spark(src)
		M.apply_effects(3,3,,,5)
		power_supply.use(250)
		to_chat(M, "<span class='danger'>\The [src] shocks you!.</span>")
		return 0
	if(prob(1))
		to_chat(M, "<span class='danger'>\The [src] explodes!.</span>")
		explosion(get_turf(loc), 0, 0, 1)
		M.drop_item(src, force_drop = 1)
		qdel(src)
		return 0
	return ..()



/obj/item/weapon/gun/energy/crossbow
	name = "mini energy-crossbow"
	desc = "A weapon favored by many of the syndicates stealth specialists."
	icon_state = "crossbow"
	w_class = W_CLASS_SMALL
	flags = FPRINT | NO_STORAGE_MSG
	item_state = "crossbow"
	starting_materials = list(MAT_IRON = 2000)
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_COMBAT + "=2;" + Tc_MAGNETS + "=2;" + Tc_SYNDICATE + "=5"
	silenced = 1
	fire_volume = 10
	fire_sound = 'sound/weapons/ebow.ogg'
	projectile_type = "/obj/item/projectile/energy/bolt"
	cell_type = "/obj/item/weapon/cell/crap"
	rechargeable = FALSE
	non_rechargeable_reason = "<span class='notice'>Your gun's recharge port was removed to make room for a miniaturized reactor.</span>"
	var/charge_tick = 0

/obj/item/weapon/gun/energy/crossbow/isHandgun()
	return TRUE

/obj/item/weapon/gun/energy/crossbow/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/crossbow/Destroy()
	processing_objects.Remove(src)
	..()


/obj/item/weapon/gun/energy/crossbow/process()
	charge_tick++
	if(charge_tick < 4)
		return 0
	charge_tick = 0
	if(!power_supply)
		return 0
	power_supply.give(100)
	return 1


/obj/item/weapon/gun/energy/crossbow/update_icon()
	return


/obj/item/weapon/gun/energy/crossbow/largecrossbow
	name = "Energy Crossbow"
	desc = "A weapon favored by syndicate infiltration teams."
	w_class = W_CLASS_LARGE
	force = 10
	starting_materials = list(MAT_IRON = 200000)
	w_type = RECYK_ELECTRONIC
	projectile_type = "/obj/item/projectile/energy/bolt/large"

/obj/item/weapon/gun/energy/crossbow/failure_check(var/mob/living/carbon/human/M)
	if(silenced && prob(50))
		silenced = 0
		to_chat(M, "<span class='warning'>\The [src] makes a noise.</span>")
		return 1
	if(prob(15))
		M.apply_radiation(rand(15,30), RAD_EXTERNAL)
		to_chat(M, "<span class='warning'>\The [src] feels warm for a moment.</span>")
		return 1
	if(prob(10))
		power_supply.maxcharge = 0
		power_supply.charge = 0
		in_chamber = null
		processing_objects.Remove(src)
		to_chat(M, "<span class='warning'>\The [src] fizzles.</span>")
		return 0
	return ..()

#define SPEEDMODE 0
#define SCATTERMODE 1
/obj/item/weapon/gun/energy/shotgun
	name = "energy shotgun"
	desc = "An experimental energy shotgun from Alcatraz IV. It has two modes that fire experimental stun electrodes codenamed HUNTER and SWEEPER."
	icon_state = "eshotgun"
	item_state = "shotgun"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	origin_tech = Tc_COMBAT + "=5;" + Tc_MATERIALS + "=2"
	projectile_type = "/obj/item/projectile/energy/electrode/fast"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	charge_cost = 100
	cell_type = "/obj/item/weapon/cell/crap"
	w_class = W_CLASS_LARGE
	var/pumped = FALSE
	var/mode = SPEEDMODE

/obj/item/weapon/gun/energy/shotgun/process_chambered()
	if(!pumped)
		return FALSE
	else
		return ..()

/obj/item/weapon/gun/energy/shotgun/Fire(atom/target, mob/living/user, params, reflex, struggle, use_shooter_turf)
	if(..()) //gun successfully fired
		pumped = FALSE
		update_icon()
		return TRUE

/obj/item/weapon/gun/energy/shotgun/proc/pump(mob/M as mob)
	if(world.time > pumped + 1 SECONDS)
		if(power_supply.charge >= charge_cost)
			playsound(src, 'sound/weapons/shotgunpump.ogg', 60, 1)
			pumped = world.time
			update_icon()
		else
			click_empty(M)

/obj/item/weapon/gun/energy/shotgun/examine(mob/user)
	..()
	if(is_holder_of(user, src) && !user.incapacitated())
		to_chat(user,"<span class='info'>It is in the [mode ? "SWEEPER" : "HUNTER"] mode. Toggle with alt-click.</span>")

/obj/item/weapon/gun/energy/shotgun/attack_self(mob/user)
	if(is_holder_of(user, src) && !user.incapacitated())
		pump()

/obj/item/weapon/gun/energy/shotgun/AltClick(mob/user)
	if(is_holder_of(user, src) && !user.incapacitated())
		mode = !mode
		var/freq = 30000 + mode * 25000
		user.playsound_local(user, 'sound/misc/click.ogg', 30, mode, freq, 0, 0, 0)
		to_chat(user,"<span class='notice'>You flick the toggle into the [mode ? "SWEEPER" : "HUNTER"] position.</span>")
		if(!mode)
			projectile_type = "/obj/item/projectile/energy/electrode/fast"
		else
			projectile_type = "/obj/item/projectile/energy/electrode/scatter"
			
/obj/item/weapon/gun/energy/shotgun/update_icon()
	..()
	if(pumped)
		var/image/pump_overlay = image("icon" = 'icons/obj/gun.dmi', "icon_state" = "eshotgun-pumped")
		overlays += pump_overlay
		gun_part_overlays += pump_overlay
	else
		for(var/image/ol in gun_part_overlays)
			if(ol.icon_state == "eshotgun-pumped")
				overlays -= ol
				gun_part_overlays -= ol