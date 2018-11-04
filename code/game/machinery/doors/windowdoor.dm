/obj/machinery/door/window
	name = "window door"
	desc = "A sliding glass door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	var/base_state = "left"
	var/health = 100
	visible = 0.0
	use_power = 0
	flow_flags = ON_BORDER
	plane = ABOVE_HUMAN_PLANE //Make it so it appears above all mobs (AI included), it's a border object anyway
	layer = WINDOOR_LAYER //Below curtains
	opacity = 0
	var/obj/item/weapon/circuitboard/airlock/electronics = null
	var/secure = FALSE
	explosion_resistance = 5
	air_properties_vary_with_direction = 1
	ghost_read = 0
	machine_flags = EMAGGABLE
	soundeffect = 'sound/machines/windowdoor.ogg'
	var/shard_type = /obj/item/weapon/shard
	penetration_dampening = 2
	animation_delay = 7
	var/obj/machinery/smartglass_electronics/smartwindow
	var/window_is_opaque = TRUE //The var that helps darken the glass when the door opens/closes
	var/assembly_type = /obj/structure/windoor_assembly

/obj/machinery/door/window/New()
	..()
	if((istype(req_access) && req_access.len) || istext(req_access))
		icon_state = "[icon_state]"
		base_state = icon_state

/obj/machinery/door/window/Destroy()
	setDensity(FALSE)
	..()

/obj/machinery/door/window/proc/smart_toggle() //For "smart" windows
	animate(src, color="[window_is_opaque ? "#FFFFFF":"#222222"]", time=5) //Start with coloring the windoor. Always.

	if(density) //window is CLOSED
		if(window_is_opaque) //Is it dark?
			set_opacity(0) //Make it light.
			window_is_opaque = TRUE
		else
			set_opacity(1) // Else, make it dark.
			window_is_opaque = FALSE
	else //Window is OPEN!
		window_is_opaque = !window_is_opaque //We pass on that we've been toggled.
	return opacity

/obj/machinery/door/window/examine(mob/user as mob)
	..()
	if(smartwindow)
		to_chat(user, "It's NT-15925 SmartGlass™ compliant.")
	if(secure)
		to_chat(user, "It is a secure windoor, it is stronger and closes more quickly.")

/obj/machinery/door/window/Bumped(atom/movable/AM as mob|obj)
	if(!ismob(AM))
		var/obj/machinery/bot/bot = AM
		if(istype(bot))
			if(density && check_access(bot.botcard))
				open()
				sleep(50)
				close()
		else if(istype(AM, /obj/mecha))
			var/obj/mecha/mecha = AM
			if(density)
				if(mecha.occupant && allowed(mecha.occupant))
					open()
					sleep(50)
					close()
		else if(istype(AM, /obj/structure/bed/chair/vehicle))
			var/obj/structure/bed/chair/vehicle/vehicle = AM
			if(density)
				if(vehicle.is_locking(/datum/locking_category/buckle/chair/vehicle, subtypes=TRUE) && !operating && allowed(vehicle.get_locked(/datum/locking_category/buckle/chair/vehicle, subtypes=TRUE)[1]))
					if(istype(vehicle, /obj/structure/bed/chair/vehicle/wizmobile))
						vehicle.forceMove(get_step(vehicle,vehicle.dir))//Firebird doesn't wait for no slowpoke door to fully open before dashing through!
					open()
					sleep(50)
					close()
				else if(!operating)
					denied()
		return
	if(!(ticker))
		return
	if(operating)
		return
	if(density && allowed(AM))
		open()
		// What.
		if(check_access(null))
			sleep(50)
		else //secure doors close faster
			sleep(20)
		close()

/obj/machinery/door/window/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && (mover.checkpass(PASSDOOR|PASSGLASS)))
		return TRUE
	if(get_dir(loc, target) == dir || get_dir(loc, mover) == dir)
		if(air_group)
			return FALSE
		return !density
	else
		return TRUE

//used in the AStar algorithm to determinate if the turf the door is on is passable
/obj/machinery/door/window/CanAStarPass(var/obj/item/weapon/card/id/ID, var/to_dir)
	return !density || (dir != to_dir) || check_access(ID)

/obj/machinery/door/window/Uncross(atom/movable/mover as mob|obj, turf/target as turf)
	if(istype(mover) && (mover.checkpass(PASSDOOR|PASSGLASS)))
		return TRUE
	if(flow_flags & ON_BORDER) //but it will always be on border tho
		if(target) //Are we doing a manual check to see
			if(get_dir(loc, target) == dir)
				return !density
		else if(mover.dir == dir) //Or are we using move code
			if(density)
				mover.to_bump(src)
			return !density
	return TRUE

/obj/machinery/door/window/open()
	if(!density) //it's already open you silly cunt
		return FALSE
	if(operating == 1) //doors can still open when emag-disabled
		return FALSE
	if(!ticker)
		return FALSE
	if(!operating) //in case of emag
		operating = 1
	door_animate("opening")
	playsound(src, soundeffect, 100, 1)
	icon_state = "[base_state]open"
	sleep(animation_delay)

	explosion_resistance = 0
	setDensity(FALSE)
	if(smartwindow && window_is_opaque)
		set_opacity(0) //You can see through open windows
	update_nearby_tiles()

	if(operating == 1) //emag again
		operating = 0
	return TRUE

/obj/machinery/door/window/close()
	if(operating)
		return FALSE
	operating = 1
	door_animate("closing")
	playsound(src, soundeffect, 100, 1)
	icon_state = base_state

	setDensity(TRUE)
	explosion_resistance = initial(explosion_resistance)
	if(smartwindow && window_is_opaque)
		set_opacity(1)
	update_nearby_tiles()

	sleep(animation_delay)

	operating = 0
	return TRUE

/obj/machinery/door/window/proc/take_damage(var/damage)
	health = max(0, health - damage)
	if(health <= 0)
		playsound(src, "shatter", 70, 1)
		getFromPool(shard_type, loc)
		getFromPool(/obj/item/stack/cable_coil,loc,2)
		eject_electronics()
		qdel(src)

/obj/machinery/door/window/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damage)
		take_damage(round(Proj.damage / 2))
	..()

//When an object is thrown at the window
/obj/machinery/door/window/hitby(AM as mob|obj)
	. = ..()
	if(.)
		return
	visible_message("<span class='warning'>The glass door was hit by [AM].</span>", 1)
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else
		tforce = AM:throwforce
	playsound(src, 'sound/effects/Glasshit.ogg', 100, 1)
	take_damage(tforce)

/obj/machinery/door/window/attack_ai(mob/user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/door/window/attack_paw(mob/living/user as mob)
	if(istype(user, /mob/living/carbon/alien/humanoid) || istype(user, /mob/living/carbon/slime/adult))
		if(operating)
			return
		user.delayNextAttack(8)
		user.do_attack_animation(src, user)
		playsound(src, 'sound/effects/Glasshit.ogg', 75, 1)
		visible_message("<span class='warning'>\The [user] smashes against \the [name].</span>", 1)
		take_damage(25)
	else
		return attack_hand(user)

/obj/machinery/door/window/attack_animal(mob/living/user as mob)
	if(operating)
		return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	user.do_attack_animation(src, user)
	user.delayNextAttack(8)
	playsound(src, 'sound/effects/Glasshit.ogg', 75, 1)
	visible_message("<span class='warning'>\The [M] [M.attacktext] against \the [name].</span>", 1)
	take_damage(M.melee_damage_upper)

/obj/machinery/door/window/attackby(obj/item/weapon/I as obj, mob/living/user as mob)
	// Make emagged/open doors able to be deconstructed
	if(!density && operating != 1 && iscrowbar(I))
		user.visible_message("[user] removes [electronics] from [src].", "You start to remove [electronics] from [src].")
		playsound(src, 'sound/items/Crowbar.ogg', 100, 1)
		if(do_after(user, src, 40) && src && !density && operating != 1)
			to_chat(user, "<span class='notice'>You removed [electronics]!</span>")
			make_assembly(user)
			if(smartwindow)
				qdel(smartwindow)
				smartwindow = null
				if(window_is_opaque)
					window_is_opaque = !window_is_opaque
					smart_toggle()
				drop_stack(/obj/item/stack/light_w, get_turf(src), 1, user)
			qdel(src)
		return

	//If it's in the process of opening/closing or emagged, ignore the click
	if(operating)
		return

	//If it's Smartglass shit, smartglassify it.
	if(istype(I, /obj/item/stack/light_w) && !operating)
		var/obj/item/stack/light_w/LT = I
		if(smartwindow)
			to_chat(user, "<span class='notice'>This [name] already has electronics in it.</span>")
			return FALSE
		LT.use(1)
		to_chat(user, "<span class='notice'>You add some electronics to [src].</span>")
		smartwindow = new /obj/machinery/smartglass_electronics(src)
		return smartwindow

	//If its a multitool and our windoor is smart, open the menu
	if(ismultitool(I) && smartwindow)
		smartwindow.update_multitool_menu(user)
		return

	//If it's a weapon, smash windoor. Unless it's an id card, agent card, ect.. then ignore it (Cards really shouldnt damage a door anyway)
	if(density && istype(I, /obj/item/weapon) && !istype(I, /obj/item/weapon/card))
		var/aforce = I.force
		user.do_attack_animation(src, I)
		user.delayNextAttack(8)
		playsound(src, 'sound/effects/Glasshit.ogg', 75, 1)
		visible_message("<span class='danger'>[src] was hit by [I].</span>")
		if(I.damtype == BRUTE || I.damtype == BURN)
			take_damage(aforce)
		return

	add_fingerprint(user)
	if(!requiresID())
		//don't care who they are or what they have, act as if they're NOTHING
		user = null

	return ..()

/obj/machinery/door/window/emag(mob/user)
	if(user)
		var/used_emag = (/obj/item/weapon/card/emag in user.contents) //TODO: Find a better way of checking this
		return hackOpen(used_emag, user)

/obj/machinery/door/window/door_animate(var/animation)
	flick("[base_state][animation]", src)

/obj/machinery/door/window/proc/hackOpen(obj/item/I, mob/user)
	operating = -1

	if(electronics)
		electronics.icon_state = "door_electronics_smoked"

	door_animate("spark")
	sleep(6)
	open()
	return 1

/obj/machinery/door/window/npc_tamper_act(mob/living/L)
	hackOpen(null, L)

/**
 * Returns whether the door opens to the left. This is counter-clockwise
 * w.r.t. the tile it is on.
 */
/obj/machinery/door/window/proc/is_left_opening()
	return base_state == "left" || base_state == "leftsecure"

/**
 * Deconstructs a windoor properly. You probably want to delete
 * the windoor after calling this.
 * @return The new /obj/structure/windoor_assembly created.
 */
/obj/machinery/door/window/proc/make_assembly(mob/user as mob)
	// Windoor assembly
	var/obj/structure/windoor_assembly/WA = new assembly_type(loc)
	set_assembly(user, WA)
	return WA

/obj/machinery/door/window/proc/set_assembly(mob/user as mob, var/obj/structure/windoor_assembly/WA)
	WA.dir = dir
	WA.anchored = TRUE
	WA.wired = TRUE
	WA.facing = (is_left_opening() ? "l" : "r")
	WA.update_name()
	WA.update_icon()

	WA.fingerprints += fingerprints
	WA.fingerprintshidden += fingerprints
	WA.fingerprintslast = user.ckey

	// Pop out electronics
	eject_electronics()

/obj/machinery/door/window/proc/eject_electronics()
	var/obj/item/weapon/circuitboard/airlock/AE = (electronics ? electronics : new /obj/item/weapon/circuitboard/airlock(loc))
	if(electronics)
		electronics = null
		AE.installed = FALSE
	else
		if(operating == -1)
			AE.icon_state = "door_electronics_smoked"
		// Straight from /obj/machinery/door/airlock/attackby()
		if(req_access && req_access.len > 0)
			AE.conf_access = req_access
		else if(req_one_access && req_one_access.len > 0)
			AE.conf_access = req_one_access
			AE.one_access = 1
	AE.forceMove(loc)

/obj/machinery/door/window/clockworkify()
	GENERIC_CLOCKWORK_CONVERSION(src, /obj/machinery/door/window/clockwork, BRASS_WINDOOR_GLOW)

/obj/machinery/door/window/brigdoor
	name = "secure window door"
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "leftsecure"
	base_state = "leftsecure"
	req_access = list(access_security)
	secure = TRUE
	var/id_tag = null
	health = 200
	assembly_type = /obj/structure/windoor_assembly/secure
	penetration_dampening = 4

/obj/machinery/door/window/plasma
	name = "plasma window door"
	desc = "A sliding glass door strengthened by plasma."
	icon = 'icons/obj/doors/plasmawindoor.dmi'
	health = 300
	assembly_type = /obj/structure/windoor_assembly/plasma
	shard_type = /obj/item/weapon/shard/plasma
	penetration_dampening = 6

/obj/machinery/door/window/plasma/secure
	name = "secure plasma window door"
	icon_state = "leftsecure"
	base_state = "leftsecure"
	health = 400
	secure = TRUE
	assembly_type = /obj/structure/windoor_assembly/plasma
	penetration_dampening = 8

// Used on Packed ; smartglassified roundstart
/obj/machinery/door/window/plasma/secure/interogation_room/initialize()
	smartwindow = new(src)
	smartwindow.id_tag = "InterogationRoomIDTag"

/obj/machinery/door/window/clockwork
	name = "brass window door"
	desc = "A thin door with translucent brass paneling."
	icon_state = "clockwork"
	base_state = "clockwork"
	health = 250
	penetration_dampening = 5
	assembly_type = /obj/structure/windoor_assembly/clockwork
	shard_type = /obj/item/stack/sheet/ralloy

/obj/machinery/door/window/clockwork/cultify()
	return

/obj/machinery/door/window/clockwork/clockworkify()
	return