/obj/machinery/door/window
	name = "window door"
	desc = "A sliding glass door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	var/base_state = "left"
	var/health = 60
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
	var/window_is_opaque = FALSE //The var that helps darken the glass when the door opens/closes
	var/assembly_type = /obj/structure/windoor_assembly
	var/id_tag = null

/obj/machinery/door/window/New()
	..()
	if((istype(req_access) && req_access.len) || istext(req_access))
		icon_state = "[icon_state]"
		base_state = icon_state
	set_electronics()
	if(smartwindow && window_is_opaque)
		set_opacity(1)
		update_nearby_tiles()

/obj/machinery/door/window/Destroy()
	setDensity(FALSE)
	..()

/obj/machinery/door/window/proc/smart_toggle() //For "smart" windows
	// var/color = window_is_opaque ? "#FFFFFF" : "#222222" //these are backwards because we're changing window_is_opaque later
	// animate(src, color=color, time=5)

	if(density) //window is CLOSED
		if(window_is_opaque) //Is it dark?
			set_opacity(0) //Make it light.
			window_is_opaque = FALSE
			animate(src, color="#FFFFFF", time=5)
		else
			set_opacity(1) // Else, make it dark.
			window_is_opaque = TRUE
			animate(src, color="#222222", time=5)
	else //Window is OPEN!
		window_is_opaque = !window_is_opaque //We pass on that we've been toggled.
	return opacity

/obj/machinery/door/window/examine(mob/user)
	..()
	if(smartwindow)
		to_chat(user, "It is NT-15925 SmartGlass™ compliant.")
	if(secure)
		to_chat(user, "It is a secure windoor. It's stronger and closes more quickly.")

/obj/machinery/door/window/Bumped(atom/movable/AM)
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
					if(istype(vehicle, /obj/structure/bed/chair/vehicle/firebird))
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

/obj/machinery/door/window/Uncross(atom/movable/mover, turf/target)
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

	// Dark windows look silly when open
	if(smartwindow && window_is_opaque)
		animate(src, color="#FFFFFF", time=10)

	door_animate("opening")
	playsound(src, soundeffect, 100, 1)
	icon_state = "[base_state]open"
	sleep(animation_delay)

	explosion_resistance = 0
	setDensity(FALSE)
	set_opacity(0) //You can see through open windoors even if the glass is opaque
	update_nearby_tiles()

	if(operating == 1) //emag again
		operating = 0
	return TRUE

/obj/machinery/door/window/close()
	if(operating)
		return FALSE
	operating = 1

	// Re-darken the window when closed
	if(smartwindow && window_is_opaque)
		animate(src, color="#222222", time=10)

	door_animate("closing")
	playsound(src, soundeffect, 100, 1)
	icon_state = base_state

	setDensity(TRUE)
	explosion_resistance = initial(explosion_resistance)
	update_nearby_tiles()

	sleep(animation_delay)
	if(window_is_opaque) //you can't see through closed opaque windoors
		set_opacity(1)

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
/obj/machinery/door/window/hitby(atom/movable/AM)
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

/obj/machinery/door/window/attack_ai(mob/user)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/door/window/attack_paw(mob/living/user)
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

/obj/machinery/door/window/attack_animal(mob/living/user)
	if(operating)
		return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	user.do_attack_animation(src, user)
	user.delayNextAttack(8)
	playsound(src, 'sound/effects/Glasshit.ogg', 75, 1)
	visible_message("<span class='warning'>\The [M.name] [M.attacktext] against \the [name].</span>", 1)
	take_damage(M.melee_damage_upper)

/obj/machinery/door/window/attackby(obj/item/weapon/I, mob/living/user)
	// Make emagged/open doors able to be deconstructed
	if(!density && operating != 1 && iscrowbar(I))
		user.visible_message("[user] is removing \the [electronics.name] from \the [name].", "You start to remove \the [electronics.name] from \the [name].")
		playsound(src, 'sound/items/Crowbar.ogg', 100, 1)
		if(do_after(user, src, 40) && src && !density && operating != 1)
			to_chat(user, "<span class='notice'>You removed \the [electronics.name]!</span>")
			make_assembly()
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
			to_chat(user, "<span class='notice'>This [name] already has [smartwindow.name] in it.</span>")
			return FALSE
		LT.use(1)
		smartwindow = new /obj/machinery/smartglass_electronics(src)
		to_chat(user, "<span class='notice'>You add [smartwindow.name] to \the [name].</span>")
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
		visible_message("<span class='danger'>\The [name] was hit by [I].</span>")
		if(I.damtype == BRUTE || I.damtype == BURN)
			take_damage(aforce)
		return

	add_fingerprint(user)
	if(!requiresID())
		//don't care who they are or what they have, act as if they're NOTHING
		user = null

	return ..()

/obj/machinery/door/window/emag(mob/user)
	..()
	hackOpen(user)

/obj/machinery/door/window/door_animate(var/animation)
	flick("[base_state][animation]", src)

/obj/machinery/door/window/proc/hackOpen(mob/user)
	operating = -1

	if(electronics)
		electronics.icon_state = "door_electronics_smoked"

	door_animate("spark")
	sleep(6)
	open()
	add_fingerprint(user)
	return TRUE

/obj/machinery/door/window/npc_tamper_act(mob/living/L)
	hackOpen(L)

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
/obj/machinery/door/window/proc/make_assembly()
	// Windoor assembly
	var/obj/structure/windoor_assembly/WA = new assembly_type(loc)
	transfer_fingerprints_to(WA)
	set_assembly(WA)
	return WA

/obj/machinery/door/window/proc/set_assembly(var/obj/structure/windoor_assembly/WA)
	WA.dir = dir
	WA.anchored = TRUE
	WA.wired = TRUE
	WA.facing = (is_left_opening() ? "l" : "r")
	WA.update_name()
	WA.update_icon()
	eject_electronics() // Pop out electronics

/obj/machinery/door/window/proc/set_electronics()
	if(!electronics)
		electronics = new /obj/item/weapon/circuitboard/airlock(src)
		electronics.installed = TRUE
	if(req_access && req_access.len > 0)
		electronics.conf_access = req_access
	else if(req_one_access && req_one_access.len > 0)
		electronics.conf_access = req_one_access
		electronics.one_access = 1

/obj/machinery/door/window/proc/eject_electronics()
	if(electronics)
		electronics.installed = FALSE
		electronics.forceMove(loc)
		electronics = null

/obj/machinery/door/window/clockworkify()
	GENERIC_CLOCKWORK_CONVERSION(src, /obj/machinery/door/window/clockwork, BRASS_WINDOOR_GLOW)

/obj/machinery/door/window/brigdoor
	name = "secure window door"
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "leftsecure"
	base_state = "leftsecure"
	req_access = list(access_security)
	secure = TRUE
	health = 100
	assembly_type = /obj/structure/windoor_assembly/secure
	penetration_dampening = 4

/obj/machinery/door/window/plasma
	name = "plasma window door"
	desc = "A sliding glass door strengthened by plasma."
	icon = 'icons/obj/doors/plasmawindoor.dmi'
	health = 150
	assembly_type = /obj/structure/windoor_assembly/plasma
	shard_type = /obj/item/weapon/shard/plasma
	penetration_dampening = 6

/obj/machinery/door/window/plasma/secure
	name = "secure plasma window door"
	icon_state = "leftsecure"
	base_state = "leftsecure"
	health = 200
	secure = TRUE
	assembly_type = /obj/structure/windoor_assembly/plasma
	penetration_dampening = 8

// Used on Packed ; smartglassified roundstart
// TODO: Remove this snowflake stuff.
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

// Smartglass for mappers, smartglassified on roundstart.
// the frequency and id_tag (shared by the windoor itself) get passed on to the smartglass electronics
// sharing the id_tag is alright because airlocks don't use radio frequency mechanics like smartglass
/obj/machinery/door/window/smartglass
	var/frequency = 1449

/obj/machinery/door/window/smartglass/initialize()
	smartwindow = new(src)
	smartwindow.id_tag = id_tag
	smartwindow.frequency = frequency

/obj/machinery/door/window/brigdoor/smartglass
	var/frequency = 1449

/obj/machinery/door/window/brigdoor/smartglass/initialize()
	smartwindow = new(src)
	smartwindow.id_tag = id_tag
	smartwindow.frequency = frequency

/obj/machinery/door/window/plasma/smartglass
	var/frequency = 1449

/obj/machinery/door/window/plasma/smartglass/initialize()
	smartwindow = new(src)
	smartwindow.id_tag = id_tag
	smartwindow.frequency = frequency

/obj/machinery/door/window/plasma/secure/smartglass
	var/frequency = 1449

/obj/machinery/door/window/plasma/secure/smartglass/initialize()
	smartwindow = new(src)
	smartwindow.id_tag = id_tag
	smartwindow.frequency = frequency