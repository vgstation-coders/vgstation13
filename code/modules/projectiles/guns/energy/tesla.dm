/obj/item/weapon/gun/tesla
	name = "\improper Telsa Cannon"
	desc = "It's a tesla cannon."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "teslacannon_ready"
	item_state = "gravitywell"
	slot_flags = SLOT_BELT
	origin_tech = Tc_MATERIALS + "=7;" + Tc_POWERSTORAGE + "=7;" + Tc_MAGNETS + "=5" + Tc_SYNDICATE + "=4;"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 0
	flags = FPRINT
	w_class = W_CLASS_MEDIUM
	fire_delay = 0
	fire_sound = 'sound/weapons/wave.ogg'

	var/connected = 0
	var/charging = 0
	var/charge = MEGAWATT
	var/maxcharge = 5 * GIGAWATT
	var/min_to_fire = MEGAWATT

/obj/item/weapon/gun/tesla/examine(mob/user, size, show_name)
	..()
	to_chat(user, "<span class='notice'>\The [src.name] is charged to [round(charge / MEGAWATT, 0.01)] MW.</span>")
	if(charge >= min_to_fire)
		to_chat(user, "<span class='notice'>\The [src.name] is ready to fire!</span>")

/obj/item/weapon/gun/tesla/process_chambered()
	if(in_chamber)
		return 1
	if(charge < min_to_fire)
		return 0
	var/obj/item/projectile/teslaball/T 
	if(charge >= GIGAWATT)
		T = new /obj/item/projectile/teslaball/yellow()
	else
		T = new /obj/item/projectile/teslaball()
	in_chamber = T
	T.charge = charge
	charge = 0
	return 1

/obj/item/weapon/gun/tesla/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	A = get_turf(A)
	..()

/obj/item/weapon/gun/tesla/attackby(obj/item/weapon/W, mob/user)
	if(W.is_wrench(user))
		if(!anchored)
			if(!istype(src.loc, /turf))
				to_chat(user, "<span class='warning'>\The [src] needs to be on the ground to be secured.</span>")
				return
			if(!istype(src.loc, /turf/simulated/floor)) //Prevent from anchoring this to shuttles / space
				to_chat(user, "<span class='notice'>You can't secure \the [src] to [istype(src.loc,/turf/space) ? "space" : "this"]!</span>")
				return
			var/obj/structure/cable/C = AttemptConnect()
			if(C)
				to_chat(user, "You discharge \the [src] and secure it to the floor.")
				anchored = 1
				charge = 0
				W.playtoolsound(src, 50)
				Charge(C)	
		else
			to_chat(user, "You unsecure \the [src].")
			W.playtoolsound(src, 50)
			anchored = 0
			connected = 0
			update_icon()

/obj/item/weapon/gun/tesla/proc/AttemptConnect()
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	var/datum/powernet/P = C.get_powernet()
	if(!C || !P)
		visible_message("<span class='warning'>\The [src.name] buzzes. It won't charge if it's not secured to a wire knot.</span>","<span class='warning'>You hear a buzz.</span>")
		return 
	if(P.avail <= 0)
		visible_message("<span class='warning'>\The [src.name] buzzes. There doesn't seem to be any power in the wire.</span>","<span class='warning'>You hear a buzz.</span>")
		return
	connected = 1
	return C

//nearly identical to capacitor charging code
/obj/item/weapon/gun/tesla/proc/Charge(var/obj/structure/cable/C)
	var/list/power_states = list()
	if(!connected || !anchored)
		return 0

	charging = 1
	update_icon()
	while(power_states.len < 10)
		power_states += C.avail()

		var/total = 0
		for(var/i = 1; i <= power_states.len; i++)
			total += power_states[i]

		if(!connected || !anchored)
			charging = 0
			return 0

		charge = round((total/power_states.len) * (power_states.len/10))

		if(power_states.len >= 10 || charge > maxcharge)
			if(charge > maxcharge)
				charge = maxcharge
			visible_message("<span class='notice'>[bicon(src)] \The [src] pings.</span>")
			playsound(src, 'sound/machines/notify.ogg', 50, 0)
			charging = 0
			update_icon()
			return 1

		sleep(1.5 SECONDS)


/obj/item/weapon/gun/tesla/update_icon()
	if(anchored)
		if(charging)
			icon_state = "teslacannon_charging"
		else
			if(charge >= GIGAWATT && icon_state != "teslacannon_strong_wrenched")
				flick("teslacannon_powerup", src)
				spawn(5)
					icon_state = "teslacannon_strong_wrenched"
			else
				icon_state = "teslacannon_wrenched"
	else		
		if(charge >= min_to_fire)
			if(charge >= GIGAWATT)
				icon_state = "teslacannon_strong_ready"
			else
				icon_state = "teslacannon_ready"
		else
			icon_state = "teslacannon"