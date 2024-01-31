/obj/machinery/turret
	name = "turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "grey_target_prism"
	var/raised = 0								// if the turret cover is "open" and the turret is raised
	var/enabled = 1
	var/obj/item/weapon/gun/installed = null	// the type of weapon installed
	anchored = 1
	invisibility = INVISIBILITY_LEVEL_ONE		// the turret is invisible if it's inside its cover
	density = 1
	var/faction = null 							//No shooting our buddies!
	var/shootsilicons = 0						//You can make turrets that shoot those robot pricks (except AIs)! You can't toggle this at the control console
	health = 80									// the turret's health
	var/obj/machinery/turretcover/cover = null	// the cover that is covering this turret
	var/raising = 0								// if the turret is currently opening or closing its cover
	var/wasvalid = 0
	var/lastfired = 0							// 1: if the turret is cooling down from a shot, 0: turret is ready to fire

	var/reqpower = 350							// Amount of power per shot
	var/shot_delay = 30 						//3 seconds between shots
	var/last_shot
	var/fire_twice = 0

	use_power = MACHINE_POWER_USE_IDLE			// this turret uses and requires power
	idle_power_usage = 50						// when inactive, this turret takes up constant 50 Equipment power
	active_power_usage = 300					// when active, this turret takes up constant 300 Equipment power
//	var/list/targets
	var/atom/movable/cur_target
	var/targeting_active = 0

	hack_abilities = list(
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/turret_upgrade,
		/datum/malfhack_ability/oneuse/turret_pulse,
		/datum/malfhack_ability/oneuse/overload_loud,
		/datum/malfhack_ability/manual_control
	)

	var/mob/living/silicon/ai/controlling_malf = null

/obj/machinery/turret/New()
//	targets = new
	..()
	spawn(10)
		update_gun()

/obj/machinery/turret/proc/update_gun()
	if(!installed)
		installed = new /obj/item/weapon/gun/energy/gun(src)

/obj/machinery/turretcover
	name = "pop-up turret cover"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turretCover"
	anchored = 1
	layer = TURRET_COVER_LAYER
	density = 0
	var/obj/machinery/turret/host = null

/obj/machinery/turret/power_change()
	if(stat & BROKEN)
		icon_state = "grey_target_prism"
	else
		if( powered() )
			if (src.enabled && !(stat & FORCEDISABLE))
				if(istype(installed,/obj/item/weapon/gun/energy/gun))
					var/obj/item/weapon/gun/energy/gun/EG = installed
					if(EG.mode == 1)
						icon_state = "orange_target_prism"
					else
						icon_state = "target_prism"
				else if(istype(installed,/obj/item/weapon/gun/energy/pulse_rifle/destroyer))
					icon_state = "blue_target_prism"
				else
					icon_state = "target_prism"
			else
				icon_state = "grey_target_prism"
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "grey_target_prism"
				stat |= NOPOWER

/obj/machinery/turret/proc/setState(var/enabled, var/lethal)
	src.enabled = enabled
	if(istype(installed,/obj/item/weapon/gun/energy/gun))
		var/obj/item/weapon/gun/energy/gun/EG = installed
		switch(lethal)
			if(1)
				EG.mode = 1
				EG.charge_cost = 100
				EG.fire_sound = 'sound/weapons/Laser.ogg'
				EG.projectile_type = "/obj/item/projectile/beam"
				EG.modifystate = "energykill"
			if(0)
				EG.mode = 0
				EG.charge_cost = 100
				EG.fire_sound = 'sound/weapons/Taser.ogg'
				EG.projectile_type = "/obj/item/projectile/energy/electrode"
				EG.modifystate = "energystun"
	src.power_change()

/obj/machinery/turret/proc/check_target(var/atom/movable/T as mob|obj)
	if(T && (T in view(7,src)))
		if( ismob(T) )
			var/mob/M = T
			if((M.flags & INVULNERABLE) || (faction && M.faction == faction))
				return 0
		if( iscarbon(T) )
			var/mob/living/carbon/MC = T
			if(MC.mind?.assigned_role == "AI") // honk honk
				return 0
			if( !MC.stat )
				if( !MC.isStunned() )
					return 1
				if(istype(installed,/obj/item/weapon/gun/energy/gun)) //only shoots them while they're down if set to laser mode
					var/obj/item/weapon/gun/energy/gun/EG = installed
					if(EG.mode == 1)
						return 1
		if(issilicon(T))
			if(!shootsilicons || istype(T,/mob/living/silicon/ai))
				return 0
			else
				return 1
		else if( istype(T, /obj/mecha) )
			var/obj/mecha/ME = T
			if( ME.occupant )
				return 1
		// /vg/ vehicles
		else if( istype(T, /obj/structure/bed/chair/vehicle) )
			var/obj/structure/bed/chair/vehicle/V = T
			if(V.is_locking_type(/mob/living))
				return 1
		else if(istype(T,/mob/living/simple_animal))
			var/mob/living/simple_animal/A = T
			if( !A.stat )
				return 1
		else if(istype(T, /obj/effect/blob))
			return 1
	return 0

/obj/machinery/turret/proc/get_new_target()
	var/static/list/types_to_search = list(
		/mob,
		/obj/mecha,
		/obj/structure/bed/chair/vehicle,
		/obj/effect/blob
		)
	var/list/new_targets = new
	var/new_target

	for(var/atom/movable/A in view(7, src))
		if(is_type_in_list(A, types_to_search))
			if(check_target(A))
				new_targets += A
	if(new_targets.len)
		new_target = pick(new_targets)
	return new_target

/obj/machinery/turret/process()
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
		// if the turret has no power or is broken, make the turret pop down if it hasn't already
		popDown()
		return
	if(src.cover==null)
		src.cover = new /obj/machinery/turretcover(src.loc)
		src.cover.host = src
	if(!enabled)
		if(raised && !raising)
			popDown()
		return

	if(controlling_malf) // manually controlled by a malf AI
		if(!raised && !raising)
			popUp()
			use_power = 2
		return

	if(!check_target(cur_target)) //if current target fails target check
		if(fire_twice)
			shootAt(cur_target)
			cur_target = get_new_target()
		else
			cur_target = get_new_target()
	if(cur_target) //if it's found, proceed
		if(!raising)
			if(!raised)
				popUp()
				use_power = MACHINE_POWER_USE_ACTIVE
			else
				spawn()
					if(!targeting_active)
						targeting_active = 1
						target()
						targeting_active = 0

		if(prob(15))
			if(prob(50))
				playsound(src, 'sound/effects/turret/move1.wav', 60, 1)
			else
				playsound(src, 'sound/effects/turret/move2.wav', 60, 1)
	else if(!raising || raised)//else, pop down
		popDown()
		use_power = MACHINE_POWER_USE_IDLE
	return

/obj/machinery/turret/proc/target()
	while(src && enabled && !stat && check_target(cur_target))
		shootAt(cur_target)
		cur_target = get_new_target()
		sleep(shot_delay)
	return

/obj/machinery/turret/proc/shootAt(var/atom/movable/target)
	if(stat & BROKEN)
		return
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if (!istype(T) || !istype(U))
		return
	if(world.time < last_shot + shot_delay)
		return

	src.dir = get_dir(src, target)
	use_power(reqpower)

	playsound(src, installed.fire_sound, 75, 1)

	last_shot = world.time
	var/obj/item/projectile/A
	if(istype(installed, /obj/item/weapon/gun/projectile/roulette_revolver))
		var/obj/item/weapon/gun/projectile/roulette_revolver/R = installed
		R.choose_projectile()
		A = new R.in_chamber.type(loc)
	else
		var/obj/item/weapon/gun/energy/E = installed
		A = new E.projectile_type(loc)
	A.original = target
	A.starting = T
	A.shot_from = installed
	A.target = U
	A.current = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	A.OnFired()
	spawn()
		A.process()
	return

/obj/machinery/turret/proc/popUp() // pops the turret up
	if(raising || raised)
		return
	if(stat & BROKEN)
		return
	invisibility=0
	raising=1
	flick("popup",cover)
	playsound(src, 'sound/effects/turret/open.wav', 60, 1)
	sleep(5)
	sleep(5)
	raising=0
	cover.icon_state="openTurretCover"
	raised=1
	layer = TURRET_LAYER

/obj/machinery/turret/proc/popDown() // pops the turret down
	if(raising || !raised)
		return
	if(stat & BROKEN)
		return
	layer = OBJ_LAYER
	raising=1
	flick("popdown",cover)
	playsound(src, 'sound/effects/turret/open.wav', 60, 1)
	sleep(10)
	raising=0
	cover.icon_state="turretCover"
	raised=0
	invisibility = INVISIBILITY_LEVEL_ONE

/obj/machinery/turret/bullet_act(var/obj/item/projectile/Proj)
	src.health -= Proj.damage
	. = ..()
	if(prob(45) && Proj.damage > 0)
		spark(src, 5, FALSE)

	if (src.health <= 0)
		src.die()

/obj/machinery/turret/attackby(obj/item/weapon/W, mob/living/user)//I can't believe no one added this before/N
	user.do_attack_animation(src, W)
	user.delayNextAttack(10)
	if(..())
		return 1
	playsound(src, 'sound/weapons/smash.ogg', 60, 1)
	spark(src, 5, FALSE)
	src.health -= W.force * 0.5
	if(W.attack_verb && W.attack_verb.len)
		user.visible_message("<span class='warning'><B>[user] [pick(W.attack_verb)] \the [src] with \the [W]!</span>", \
					"<span class='warning'>You attack \the [src] with \the [W]!</span>", \
					"<span class='warning'>You hear a clang!</span>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>[pick(W.attack_verb)] [src] with [W]</font>")
	else
		user.visible_message("<span class='warning'><B>[user] attacks \the [src] with \the [W]!</span>", \
					"<span class='warning'>You attack \the [src] with \the [W]!</span>", \
					"<span class='warning'>You hear a clang!</span>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src] with [W]</font>")
	if (W.force >= 2)
		src.health -= W.force * 0.5
		if (src.health <= 0)
			src.die()
	return

/obj/machinery/turret/attack_animal(mob/living/simple_animal/M)
	if(M.melee_damage_upper == 0)
		return
	if(!(stat & BROKEN))
		M.do_attack_animation(src, M)
		visible_message("<span class='danger'>[M] [M.attacktext] [src]!</span>")
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name]</font>")
		//src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		src.health -= M.melee_damage_upper
		if (src.health <= 0)
			src.die()
	else
		to_chat(M, "<span class='warning'>That object is useless to you.</span>")

/obj/machinery/turret/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(!(stat & BROKEN))
		M.do_attack_animation(src, M)
		playsound(src, 'sound/weapons/slash.ogg', 25, 1, -1)
		visible_message("<span class='danger'>[M] has slashed at [src]!</span>")
		src.health -= 15
		if (src.health <= 0)
			src.die()
	else
		to_chat(M, "<span class='good'>That object is useless to you.</span>")

/obj/machinery/turret/emp_act(severity)
	switch(severity)
		if(1)
			setState(0,0)
			power_change()
	..()

/obj/machinery/turret/ex_act(severity)
	if(severity < 3)
		src.die()

/obj/machinery/turret/proc/die() // called when the turret dies, ie, health <= 0
	src.health = 0
	setDensity(FALSE)
	src.stat |= BROKEN // enables the BROKEN bit
	src.icon_state = "destroyed_target_prism"
	invisibility = 0
	spawn(3)
		flick("explosion", src)
		src.setDensity(TRUE)
		if (cover!=null) // deletes the cover - no need on keeping it there!
			QDEL_NULL(cover)


/obj/machinery/turret/proc/malf_take_control(mob/living/silicon/ai/A)
	if(!A.eyeobj)
		A.make_eyeobj()
	A.eyeobj.forceMove(get_turf(src))
	A.current = src
	controlling_malf = A
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
		return
	if(!enabled)
		return
	popUp()

/obj/machinery/turret/proc/malf_release_control()
	if(controlling_malf)
		controlling_malf.current = null
		controlling_malf = null

/obj/machinery/turretid
	name = "turret control switchboard"
	desc = "A card reader attached to a small switchboard with a big status light. The button labelled 'lethal' has a post-it note under it, showing a skull and crossbones."
	icon = 'icons/obj/device.dmi'
	icon_state = "turretid_stun"
	anchored = 1
	density = 0
	var/enabled = 1
	var/lethal = 0
	var/locked = 1
	var/area/control_area //Can be area name, path or nothing.
	var/ailock = 0 //AI cannot use this
	req_access = list(access_ai_upload)

	ghost_read = 0

	machine_flags = EMAGGABLE

/obj/machinery/turretid/New()
	..()
	if(!control_area)
		control_area = get_area(src)
	else if(ispath(control_area))
		control_area = locate(control_area)
	else if(istext(control_area))
		var/path = text2path(control_area)
		if(path)
			control_area = locate(path)
		else
			for(var/area/A in areas)
				if(cmptext(A.name, control_area))
					control_area = A
					break

	ASSERT(isarea(control_area))
	updateTurrets() //Updates the turrets and the icon if an instance is made that is not set to stun by default

/obj/machinery/turretid/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		locked = 0
		if(user)
			to_chat(user, "<span class='warning'>You short out [src]'s access analysis and threat indicator module.</span>")
			if(user.machine == src)
				attack_hand(user)
			update_icon() //Update the icon immediately since emagging removes the turret threat indicator
		return 1
	return

/obj/machinery/turretid/attackby(obj/item/weapon/W, mob/user)
	if(stat & (BROKEN|FORCEDISABLE))
		return
	if(issilicon(user))
		return attack_hand(user)

	..()

	if(user.Adjacent(src))
		if(allowed(user))
			if(emagged)
				to_chat(user, "<span class='warning'>[src]'s card reader is totally unresponsive.</span>")
				return

			locked = !locked
			user.visible_message("<span class='notice'>[user] [locked ? "locks" : "unlocks"] the switchboard panel.</span>",
			"<span class='notice'>You [locked ? "lock" : "unlock"] the switchboard panel.</span>")
			if(locked)
				if (user.machine == src)
					user.unset_machine()
					user << browse(null, "window=turretid")
			else
				if(user.machine == src)
					src.attack_hand(user)
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

/obj/machinery/turretid/attack_ai(mob/user as mob)
	add_hiddenprint(user)
	if(!ailock || isAdminGhost(user) || is_malf_owner(user))
		return attack_hand(user)
	else
		to_chat(user, "<span class='notice'>There seems to be a firewall preventing you from accessing [src].</span>")

/obj/machinery/turretid/attack_hand(mob/user as mob)
	if(!user.Adjacent(src))
		if(!issilicon(user) && !isAdminGhost(user))
			to_chat(user, "<span class='notice'>You are too far away.</span>")
			user.unset_machine()
			user << browse(null, "window=turretid")
			return

	user.set_machine(src)
	// Oh god what
	var/loc = src.loc
	if(istype(loc, /turf))
		loc = loc:loc
	if(!istype(loc, /area))
		to_chat(user, "<span class='warning'>The turret control switchboard flashes a network disconnection error. The area plan might not be registering properly.</span>") //Debug message
		return
	var/area/area = loc
	var/t = "<TT><B>Turret Control Panel</B> ([area.name])<HR>"

	if(!isAdminGhost(user) && src.locked && (!istype(user, /mob/living/silicon)))
		t += "<I>(Swipe ID card to unlock control panel)</I><BR>"
	else
		t += "Turrets [enabled ? "activated":"deactivated"] - <A href='?src=\ref[src];toggleOn=1'>[enabled ? "Disable":"Enable"]?</a><br>\n"
		t += "Currently set to [lethal ? "lethal":"stun"] - <A href='?src=\ref[src];toggleLethal=1'>Change to [lethal ? "Stun":"Lethal"]?</a><br>\n"

	user << browse(t, "window=turretid")
	onclose(user, "turretid")

/obj/machinery/turretid/npc_tamper_act(mob/living/L)
	enabled = rand(0, 1)
	lethal = rand(0, 1)
	updateTurrets()

/obj/machinery/turretid/Topic(href, href_list)
	if(..())
		return 1
	if(locked)
		if(!issilicon(usr) && !isAdminGhost(usr))
			to_chat(usr, "<span class='warning'>Control panel is locked!</span>")
			return
	if(usr.Adjacent(src) || issilicon(usr) || isAdminGhost(usr))
		if(href_list["toggleOn"])
			enabled = !enabled
			usr.visible_message("<span class='warning'>[usr] [enabled ? "enables":"disables"] the turrets.</span>",
			"<span class='notice'>You [enabled ? "enable":"disable"] the turrets.</span>")
			updateTurrets()
		else if(href_list["toggleLethal"])
			lethal = !lethal
			usr.visible_message("<span class='warning'>[usr] switches the turrets to [lethal ? "lethal":"stun"].</span>",
			"<span class='notice'>You switch the turrets to [lethal ? "lethal":"stun"].</span>")
			updateTurrets()
	attack_hand(usr)

//Regular Alt Click (not AI) allows users to immediately turn the turrets on or off, assuming the rest of the steps are done (notably interface unlocked)
/obj/machinery/turretid/AltClick(mob/user)
	if(!usr.incapacitated() && Adjacent(user) && usr.dexterity_check() && !locked)
		enabled = !enabled
		usr.visible_message("<span class='warning'>[usr] [enabled ? "enables":"disables"] the turrets.</span>",
		"<span class='notice'>You [enabled ? "enable":"disable"] the turrets.</span>")
		updateTurrets()
		return
	return ..()

/obj/machinery/turretid/CtrlClick(mob/user) //Lock the device
	if(!(user) || !isliving(user)) //BS12 EDIT
		return FALSE
	if(user.incapacitated() || !Adjacent(user))
		return FALSE

	if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
		return
	if(allowed(user))
		locked = !locked
		to_chat(usr, "<span class='notice'>You [locked ? "lock" : "unlock"] the switchboard panel.</span>")

//All AI shortcuts. Basing this on what airlocks do, so slight clash with user (Alt is dangerous so toggle stun/lethal, Ctrl is bolts so lock, Shift is 'open' so toggle turrets)
/obj/machinery/turretid/AIAltClick(mob/living/silicon/ai/user) //Stun/lethal toggle
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
		return
	if(!ailock || is_malf_owner(user))
		lethal = !lethal
		to_chat(usr, "<span class='notice'>You switch the turrets to [lethal ? "lethal":"stun"].</span>")
		updateTurrets()

/obj/machinery/turretid/AICtrlClick(mob/living/silicon/ai/user) //Lock the device
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
		return
	if(!ailock || is_malf_owner(user))
		locked = !locked
		to_chat(usr, "<span class='notice'>You [locked ? "lock" : "unlock"] the switchboard panel.</span>")

/obj/machinery/turretid/AIShiftClick(mob/living/silicon/ai/user)  //Toggle the turrets on/off
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
		return
	if(!ailock || is_malf_owner(user))
		enabled = !enabled
		to_chat(usr, "<span class='notice'>You [enabled ? "enable":"disable"] the turrets.</span>")
		updateTurrets()

/obj/machinery/turretid/proc/updateTurrets()
	if(control_area)
		for(var/obj/machinery/turret/aTurret in control_area.contents)
			aTurret.setState(enabled, lethal)
	update_icon()

/obj/machinery/turretid/update_icon()
	if(stat & (BROKEN|FORCEDISABLE))
		icon_state = "turretid_off"
	else if(enabled && !emagged) //Emagged turret controls are always disguised as disabled
		if(lethal)
			icon_state = "turretid_lethal"
		else
			icon_state = "turretid_stun"
	else
		icon_state = "turretid_safe"

/obj/structure/turret/gun_turret
	name = "gun turret"
	desc = "A break-away from traditional design, this turret always has its hulking gun exposed. It looks menacing."
	density = 1
	anchored = 1
	var/cooldown = 20
	var/projectiles = 100
	var/projectiles_per_shot = 2
	var/deviation = 0.3
	var/list/exclude = list()
	var/atom/cur_target
	var/scan_range = 7
	var/projectile_type = /obj/item/projectile
	var/firing_delay = 2
	var/admin_only = 0 //Can non-admins interface with this turret's controls?
	var/roulette_mode = FALSE
	var/list/available_projectiles = list()

	health = 40
	var/list/scan_for = list("human"=0,"cyborg"=0,"mecha"=0,"alien"=1)
	var/on = 0
	icon = 'icons/obj/turrets.dmi'
	icon_state = "gun_turret"

/obj/structure/turret/gun_turret/New()
	..()
	available_projectiles = existing_typesof(/obj/item/projectile)

/obj/structure/turret/gun_turret/examine(mob/user)
	..()
	if(admin_only)
		to_chat(user, "<span class='warning'>This turret's control panel is glowing red and appears to be remotely locked down.</span>")

/obj/structure/turret/gun_turret/ex_act()
	qdel (src)
	return

/obj/structure/turret/gun_turret/emp_act()
	qdel (src)
	return

/obj/structure/turret/gun_turret/proc/update_health()
	if(src.health<=0)
		qdel (src)
	return

/obj/structure/turret/gun_turret/bullet_act(var/obj/item/projectile/Proj)
	src.take_damage(Proj.damage)
	return ..()

/obj/structure/turret/gun_turret/attack_hand(mob/user as mob)
	if(admin_only && !check_rights(R_ADMIN))
		to_chat(user, "<span class='warning'> The turret's control panel is glowing red and appears to be remotely locked down.</span>")
		return
	user.set_machine(src)
	var/dat = {"<html>
					<head><title>[src] control</title></head>
					<body>
					<b>Power: </b><a href='?src=\ref[src];power=1'>[on?"on":"off"]</a><br>
					<b>Scan Range: </b><a href='?src=\ref[src];scan_range=-1'>-</a> [scan_range] <a href='?src=\ref[src];scan_range=1'>+</a><br>
					<b>Scan for: </b>"}
	for(var/scan in scan_for)
		dat += "<div style=\"margin-left: 15px;\">[scan] (<a href='?src=\ref[src];scan_for=[scan]'>[scan_for[scan]?"Yes":"No"]</a>)</div>"

	dat += "<b>Ammo: </b>[max(0, projectiles)]<br>"
	if(check_rights(R_ADMIN))
		dat += {"<br><b><font color="red">Admin Options:</font></b><br>
				<b>Admin-only mode:</b> <a href='?src=\ref[src];admin_only=1'>[admin_only?"ON":"OFF"]</a><br>
				<b>Roulette mode:</b> <a href='?src=\ref[src];roulette_mode=0'>[roulette_mode?"ON":"OFF"]</a><br>
				"}
		if(!roulette_mode)
			dat += {"<b>Projectile type:</b> <a href='?src=\ref[src];projectile_type=1'>[projectile_type]</a><br>"}
		dat += {"<b>Projectiles per burst:</b> <a href='?src=\ref[src];projectile_burst=1'>[projectiles_per_shot]</a><br>
				<b>Firing delay:</b> <a href='?src=\ref[src];firing_delay=1'>[cooldown] deci-seconds</a><br>
				<b>Set ammo #:</b> <a href='?src=\ref[src];force_ammo_amt=1'>[projectiles]</a><br>


				</body>
				</html>"}
	user << browse(dat, "window=turret")
	onclose(user, "turret")
	return

/obj/structure/turret/gun_turret/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)


/obj/structure/turret/gun_turret/attack_alien(mob/living/user as mob)
	user.do_attack_animation(src, user)
	user.visible_message("[user] slashes at [src]", "You slash at [src]")
	src.take_damage(15)
	return

/obj/structure/turret/gun_turret/Topic(href, href_list)
	if(href_list["power"])
		src.on = !src.on
		if(src.on)
			spawn(50)
				if(src)
					src.process()
	if(href_list["scan_range"])
		src.scan_range = clamp(src.scan_range + text2num(href_list["scan_range"]), 1, 8)
	if(href_list["scan_for"])
		if(href_list["scan_for"] in scan_for)
			scan_for[href_list["scan_for"]] = !scan_for[href_list["scan_for"]]
	if(href_list["admin_only"])
		if(!check_rights(R_ADMIN))
			return
		src.admin_only = !src.admin_only
	if(href_list["roulette_mode"])
		if(!check_rights(R_ADMIN))
			return
		roulette_mode = !roulette_mode
	if(href_list["projectile_type"])
		if(!check_rights(R_ADMIN))
			return
		var/list/valid_turret_projectiles = existing_typesof(/obj/item/projectile/bullet) + existing_typesof(/obj/item/projectile/energy)
		var/userinput = filter_list_input("New projectile typepath", "You can only pick one!", valid_turret_projectiles)
		if(!userinput)
			to_chat(usr, "<span class='warning'><b>No projetile typepath entered. The turret's projectile remains unchanged.</b></span>")
			return
		projectile_type = userinput

	if(href_list["projectile_burst"])
		if(!check_rights(R_ADMIN))
			return
		var/userinput = input("Enter new # of projectiles in a burst-fire", "RATATATTATATA", 2) as num
		if(userinput > 5)
			projectiles_per_shot = 5
			to_chat(usr, "<span class='warning'><b>Error: Max burst-fire exceeded. Burst-fire set to 5.</b></span>")
			return
		projectiles_per_shot = max(1, userinput)
	if(href_list["firing_delay"])
		if(!check_rights(R_ADMIN))
			return
		var/userinput = input("Enter new firing delay (as tenths of a second)", "RATATATTATATA", 20) as num
		if(userinput <= 0)
			cooldown = 1
			to_chat(usr, "<span class='warning'><b>Error: Firing cooldown floor reached. Cooldown set to 1/10th of a second.</b></span>")
			return
		cooldown = userinput
	if(href_list["force_ammo_amt"])
		if(!check_rights(R_ADMIN))
			return
		var/userinput = input("Enter new # of projectiles left in the turret", "RATATATTATATA", 100) as num
		if(userinput < 0)
			projectiles = 0
			to_chat(usr, "<span class='warning'><b>Error: Setting negative projectiles is a bad idea, okay? <u>Don't do that<u/>. Projectiles reset to 0.</b></span>")
			return
		projectiles = userinput
	src.updateUsrDialog()
	return


/obj/structure/turret/gun_turret/proc/validate_target(atom/target)
	if(get_dist(target, src)>scan_range)
		return 0
	if(istype(target, /mob))
		var/mob/M = target
		if(!M.stat && !M.lying)//ninjas can't catch you if you're lying
			return 1
	else if(istype(target, /obj/mecha))
		return 1
	return 0


/obj/structure/turret/gun_turret/process()
	spawn while(on)
		if(projectiles<=0)
			on = 0
			return
		if(cur_target && !validate_target(cur_target))
			cur_target = null
		if(!cur_target)
			cur_target = get_target()
		fire(cur_target)
		sleep(cooldown)
	return

/obj/structure/turret/gun_turret/proc/get_target()
	var/list/pos_targets = list()
	var/target = null
	if(scan_for["human"])
		for(var/mob/living/carbon/human/M in oview(scan_range,src))
			if(M.stat || M.isStunned() || (M in exclude))
				continue
			pos_targets += M
	if(scan_for["cyborg"])
		for(var/mob/living/silicon/M in oview(scan_range,src))
			if(M.stat || M.lying || (M in exclude))
				continue
			pos_targets += M
	if(scan_for["mecha"])
		for(var/obj/mecha/M in oview(scan_range, src))
			if(M in exclude)
				continue
			pos_targets += M
	if(scan_for["alien"])
		for(var/mob/living/carbon/alien/M in oview(scan_range,src))
			if(M.stat || M.lying || (M in exclude))
				continue
			pos_targets += M
		for(var/obj/effect/blob/B in oview(scan_range, src))
			pos_targets += B
		for(var/mob/living/simple_animal/hostile/blobspore/BS in oview(scan_range,src))
			if(BS.stat || BS.lying || (BS in exclude))
				continue
			pos_targets += BS
	if(pos_targets.len)
		target = pick(pos_targets)
	return target


/obj/structure/turret/gun_turret/proc/fire(atom/target)
	if(!target)
		cur_target = null
		return
	src.dir = get_dir(src,target)
	spawn	for(var/i=1 to min(projectiles, projectiles_per_shot))
		if(!src || !target)
			break
		var/turf/curloc = get_turf(src)
		var/turf/targloc = get_turf(target)
		if (!targloc || !curloc)
			continue
		if (targloc == curloc)
			continue
		playsound(src, 'sound/weapons/Gunshot.ogg', 50, 1)
		if(roulette_mode)
			projectile_type = pick(available_projectiles - restricted_roulette_projectiles)
		var/obj/item/projectile/A = new projectile_type(curloc)
		src.projectiles--
		A.original = target
		A.current = curloc
		A.target = targloc
		A.starting = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		A.OnFired()
		A.process()
		sleep(2)
	return

/obj/structure/turret/gun_turret/admin
	admin_only = 1

/obj/machinery/turret/Destroy()
	// deletes its own cover with it
	if(cover)
		QDEL_NULL(cover)
	..()

/obj/machinery/turret/centcomm
	name = "turret"

/obj/machinery/turret/centcomm/update_gun()
	if(!installed)
		installed = new /obj/item/weapon/gun/energy/laser/cannon(src)

/obj/machinery/turretcover/hack_interact(var/mob/living/silicon/ai/malf)
	host.hack_interact(malf)

/obj/machinery/turretcover/malf_disrupt(var/duration, var/bypassafter = FALSE)
	return

/obj/machinery/turret/centcomm/syndie
	faction = "syndicate"
