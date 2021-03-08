/area/turret_protected
	name = "Turret Protected Area"
	turret_protected = 1

/obj/machinery/turret
	name = "turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "grey_target_prism"
	var/raised = 0
	var/enabled = 1
	anchored = 1
	invisibility = INVISIBILITY_LEVEL_TWO
	density = 1
	var/faction = null //No shooting our buddies!
	var/shootsilicons = 0 //You can make turrets that shoot those robot pricks (except AIs)! You can't toggle this at the control console
	var/lasers = 0
	var/lasertype = /obj/item/projectile/beam
	var/health = 80
	var/obj/machinery/turretcover/cover = null
	var/popping = 0
	var/wasvalid = 0
	var/lastfired = 0
	var/shot_delay = 30 //3 seconds between shots
	var/fire_twice = 0

	use_power = 1
	idle_power_usage = 50
	active_power_usage = 300
//	var/list/targets
	var/atom/movable/cur_target
	var/targeting_active = 0
	var/area/protected_area


/obj/machinery/turret/New()
//	targets = new
	..()
	return

/obj/machinery/turretcover
	name = "pop-up turret cover"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turretCover"
	anchored = 1
	layer = TURRET_COVER_LAYER
	density = 0
	var/obj/machinery/turret/host = null

/obj/machinery/turret/proc/isPopping()
	return (popping!=0)

/obj/machinery/turret/power_change()
	if(stat & BROKEN)
		icon_state = "grey_target_prism"
	else
		if( powered() )
			if (src.enabled)
				if (src.lasers)
					icon_state = "orange_target_prism"
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
	src.lasers = lethal
	src.power_change()


/obj/machinery/turret/proc/get_protected_area()
	var/area/TP = get_area(src)
	if(istype(TP) && TP.turret_protected)
		return TP
	if(TP && !TP.turret_protected)
		message_admins("DEBUG: [src] deleted itself because turret_protected var not set on area [TP].")
		qdel(src)
	return

/obj/machinery/turret/proc/check_target(var/atom/movable/T as mob|obj)
	if(T && (T in protected_area.turretTargets))
		var/area/area_T = get_area(T)
		if(!area_T || (area_T.type != protected_area.type))
			protected_area.Exited(T)
			return 0 //If the guy is somehow not in the turret's area (teleportation), get them out the damn list. --NEO
		if( ismob(T) )
			var/mob/M = T
			if((M.flags & INVULNERABLE) || M.faction == faction)
				return 0
		if( iscarbon(T) )
			var/mob/living/carbon/MC = T
			if( !MC.stat )
				if( !MC.isStunned() || lasers ) //only shoots them while they're down if set to laser mode
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
	return 0

/obj/machinery/turret/proc/get_new_target()
	var/list/new_targets = new
	var/new_target
	for(var/mob/M in protected_area.turretTargets)
		if(issilicon(M))
			if(!shootsilicons || istype(M, /mob/living/silicon/ai))
				continue
		if(!M.stat && !(M.flags & INVULNERABLE) && M.faction != faction)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.isStunned() || lasers) //only shoots them while they're down if set to laser mode
					new_targets += C
			else
				new_targets += M

	for(var/obj/mecha/M in protected_area.turretTargets)
		if(M.occupant)
			new_targets += M

	// /vg/ vehicles
	for(var/obj/structure/bed/chair/vehicle/V in protected_area.turretTargets)
		if(V.is_locking_type(/mob/living))
			new_targets += V

	if(new_targets.len)
		new_target = pick(new_targets)
	return new_target


/obj/machinery/turret/process()
	if(stat & (NOPOWER|BROKEN))
		return
	if(src.cover==null)
		src.cover = new /obj/machinery/turretcover(src.loc)
		src.cover.host = src
	protected_area = get_protected_area()
	if(!enabled || !protected_area || protected_area.turretTargets.len<=0)
		if(!isDown() && !isPopping())
			popDown()
		return
	if(!check_target(cur_target)) //if current target fails target check
		if(fire_twice)
			src.dir = get_dir(src, cur_target)
			shootAt(cur_target)
			cur_target = get_new_target()
		else
			cur_target = get_new_target()
	if(cur_target) //if it's found, proceed
//		to_chat(world, "[cur_target]")
		if(!isPopping())
			if(isDown())
				popUp()
				use_power = 2
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
	else if(!isPopping())//else, pop down
		if(!isDown())
			popDown()
			use_power = 1
	return

/obj/machinery/turret/proc/target()
	while(src && enabled && !stat && check_target(cur_target))
		src.dir = get_dir(src, cur_target)
		shootAt(cur_target)
		sleep(shot_delay)
	return

/obj/machinery/turret/proc/shootAt(var/atom/movable/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	var/fire_sound = 'sound/weapons/Laser.ogg'
	if (!T || !U)
		return
	var/obj/item/projectile/A
	if (src.lasers)
		A = new lasertype(loc)
		use_power(500)
	else
		A = new /obj/item/projectile/energy/electrode( loc )
		fire_sound = 'sound/weapons/Taser.ogg'
		use_power(200)

	A.original = target
	A.target = U
	A.current = T
	A.starting = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	playsound(T, fire_sound, 50, 1)
	A.OnFired()
	A.process()
	return


/obj/machinery/turret/proc/isDown()
	return (invisibility!=0)

/obj/machinery/turret/proc/popUp()
	if ((!isPopping()) || src.popping==-1)
		invisibility = 0
		popping = 1
		playsound(src, 'sound/effects/turret/open.wav', 60, 1)
		if (src.cover!=null)
			flick("popup", src.cover)
			src.cover.icon_state = "openTurretCover"
		spawn(10)
			if (popping==1)
				popping = 0

/obj/machinery/turret/proc/popDown()
	if ((!isPopping()) || src.popping==1)
		popping = -1
		playsound(src, 'sound/effects/turret/open.wav', 60, 1)
		if (src.cover!=null)
			flick("popdown", src.cover)
			src.cover.icon_state = "turretCover"
		spawn(10)
			if (popping==-1)
				invisibility = INVISIBILITY_LEVEL_TWO
				popping = 0

/obj/machinery/turret/bullet_act(var/obj/item/projectile/Proj)
	src.health -= Proj.damage
	. = ..()
	if(prob(45) && Proj.damage > 0)
		spark(src, 5, FALSE)

	if (src.health <= 0)
		src.die()
	return

/obj/machinery/turret/attackby(obj/item/weapon/W, mob/living/user)//I can't believe no one added this before/N
	user.do_attack_animation(src, W)
	user.delayNextAttack(10)
	if(..())
		return 1
	playsound(src, 'sound/weapons/smash.ogg', 60, 1)
	spark(src, 5, FALSE)
	src.health -= W.force * 0.5
	visible_message("<span class='danger'>[user] attacked \the [src] with \the [W]!</span>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src] with [W]</font>")
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
			enabled = 0
			lasers = 0
			power_change()
	..()

/obj/machinery/turret/ex_act(severity)
	if(severity < 3)
		src.die()

/obj/machinery/turret/proc/die()
	src.health = 0
	setDensity(FALSE)
	src.stat |= BROKEN
	src.icon_state = "destroyed_target_prism"
	if (cover!=null)
		qdel(cover)
		cover = null
	sleep(3)
	flick("explosion", src)
	spawn(13)
		qdel(src)

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

/obj/machinery/turretid/emag(mob/user)
	if(!emagged)
		emagged = 1
		locked = 0
		if(user)
			to_chat(user, "<span class='warning'>You short out [src]'s access analysis and threat indicator module.</span>")
			if(user.machine == src)
				attack_hand(user)
			update_icons() //Update the icon immediately since emagging removes the turret threat indicator
		return 1
	return

/obj/machinery/turretid/attackby(obj/item/weapon/W, mob/user)
	if(stat & BROKEN)
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
	if(!ailock || isAdminGhost(user))
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

//All AI shortcuts. Basing this on what airlocks do, so slight clash with user (Alt is dangerous so toggle stun/lethal, Ctrl is bolts so lock, Shift is 'open' so toggle turrets)
/obj/machinery/turretid/AIAltClick() //Stun/lethal toggle
	if(!ailock)
		lethal = !lethal
		to_chat(usr, "<span class='notice'>You switch the turrets to [lethal ? "lethal":"stun"].</span>")
		updateTurrets()

/obj/machinery/turretid/AICtrlClick() //Lock the device
	if(!ailock)
		locked = !locked
		to_chat(usr, "<span class='notice'>You [locked ? "lock" : "unlock"] the switchboard panel.</span>")

/obj/machinery/turretid/AIShiftClick()  //Toggle the turrets on/off
	if(!ailock)
		enabled = !enabled
		to_chat(usr, "<span class='notice'>You [enabled ? "enable":"disable"] the turrets.</span>")
		updateTurrets()

/obj/machinery/turretid/proc/updateTurrets()
	if(control_area)
		for(var/obj/machinery/turret/aTurret in control_area.contents)
			aTurret.setState(enabled, lethal)
	update_icons()

/obj/machinery/turretid/proc/update_icons()
	if(enabled && !emagged) //Emagged turret controls are always disguised as disabled
		if(lethal)
			icon_state = "turretid_lethal"
		else
			icon_state = "turretid_stun"
	else
		icon_state = "turretid_safe"

/obj/structure/turret/gun_turret
	name = "Gun Turret"
	density = 1
	anchored = 1
	var/cooldown = 20
	var/projectiles = 100
	var/projectiles_per_shot = 2
	var/deviation = 0.3
	var/list/exclude = list()
	var/atom/cur_target
	var/scan_range = 7
	var/health = 40
	var/list/scan_for = list("human"=0,"cyborg"=0,"mecha"=0,"alien"=1)
	var/on = 0
	icon = 'icons/obj/turrets.dmi'
	icon_state = "gun_turret"


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

/obj/structure/turret/gun_turret/proc/take_damage(damage)
	src.health -= damage
	if(src.health<=0)
		qdel (src)
	return


/obj/structure/turret/gun_turret/bullet_act(var/obj/item/projectile/Proj)
	src.take_damage(Proj.damage)
	return ..()

/obj/structure/turret/gun_turret/attack_hand(mob/user as mob)
	user.set_machine(src)
	var/dat = {"<html>
					<head><title>[src] Control</title></head>
					<body>
					<b>Power: </b><a href='?src=\ref[src];power=1'>[on?"on":"off"]</a><br>
					<b>Scan Range: </b><a href='?src=\ref[src];scan_range=-1'>-</a> [scan_range] <a href='?src=\ref[src];scan_range=1'>+</a><br>
					<b>Scan for: </b>"}
	for(var/scan in scan_for)
		dat += "<div style=\"margin-left: 15px;\">[scan] (<a href='?src=\ref[src];scan_for=[scan]'>[scan_for[scan]?"Yes":"No"]</a>)</div>"

	dat += {"<b>Ammo: </b>[max(0, projectiles)]<br>
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
		var/obj/item/projectile/A = new /obj/item/projectile(curloc)
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

/obj/machinery/turret/Destroy()
	if(cover)
		qdel(cover)
		cover = null
	..()
