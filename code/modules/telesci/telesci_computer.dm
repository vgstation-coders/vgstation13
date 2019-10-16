#define MAX_POFFSET 10

#define MAX_X (world.maxx + 50)
#define MIN_X -49

#define MAX_Y (world.maxy + 50)
#define MIN_Y -49

#define DIRECTION_SEND    0
#define DIRECTION_RECEIVE 1

/obj/machinery/computer/telescience
	name = "telepad control console"
	desc = "Used to teleport objects to and from the telescience telepad."
	icon_state = "teleport"
	circuit = "/obj/item/weapon/circuitboard/telesci_computer"
	var/obj/machinery/telepad/telepad = null

	// VARIABLES //
	var/teles_left       // How many teleports left until it becomes uncalibrated
	var/x_off            // X offset
	var/y_off            // Y offset
	var/x_player_off = 0 // x offset set by player
	var/y_player_off = 0 // y offset set by player
	var/x_co = 1         // X coordinate
	var/y_co = 1         // Y coordinate
	var/z_co = 1         // Z coordinate

	use_power = 1
	idle_power_usage = 10
	active_power_usage = 300
	power_channel = EQUIP
	var/obj/item/weapon/cell/cell
	var/teleport_cell_usage=1000 // 100% of a standard cell
	processing=1
	var/id_tag = "teleconsole"


	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/telescience/get_cell()
	return cell

/obj/machinery/computer/telescience/New()
	..()
	teles_left = rand(12,14)
	x_off = rand(-10,10)
	y_off = rand(-10,10)
	x_player_off = 0
	y_player_off = 0
	cell = new/obj/item/weapon/cell(src)

/obj/machinery/computer/telescience/initialize()
	..()
	for(var/obj/machinery/telepad/possible_telepad in range(src, 7))
		if(telepad)
			return //Stop checking if we are linked
		if (!possible_telepad.linked) //Check if the telepad is linked to something else
			telepad = possible_telepad
			telepad.linked = src

/obj/machinery/computer/telescience/Destroy()
	if (telepad)
		telepad.linked = null
		telepad = null

	..()


//Plagiarized cloning console multi-tool code
/obj/machinery/computer/telescience/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return ""

/obj/machinery/computer/telescience/canLink(var/obj/T)
	return (istype(T,/obj/machinery/telepad) && get_dist(src,T) < 7)

/obj/machinery/computer/telescience/isLinkedWith(var/obj/T)
	return (telepad == T)

/obj/machinery/computer/telescience/linkWith(var/mob/user, var/obj/T, var/list/context)
	if(istype(T, /obj/machinery/telepad))
		telepad = T
		telepad.linked = src
		return 1

/obj/machinery/computer/telescience/unlinkFrom(mob/user, obj/buffer)
	if(telepad.linked)
		telepad.linked = null
	if(telepad)
		telepad = null
	return 1

//Plagiarized conveyor belt multi-tool code
/obj/machinery/computer/telescience/canClone(var/obj/machinery/T)
	return (istype(T, /obj/machinery/telepad) && get_dist(src, T) < 7)

/obj/machinery/computer/telescience/clone(var/obj/machinery/T)
	if(istype(T, /obj/machinery/telepad))
		telepad = T
		telepad.linked = src
		return 1

/obj/machinery/computer/telescience/process()
	if(!cell || (stat & (BROKEN|NOPOWER)) || !anchored)
		return

	var/used = cell.give(100)
	if (used)
		use_power(used * 2) // This used to use CELLRATE, but CELLRATE is fucking awful. feel free to fix this properly!
		nanomanager.update_uis(src)

/obj/machinery/computer/telescience/attackby(obj/item/weapon/W, mob/user)
	if(..())
		return TRUE

	if(stat & BROKEN || !ispowercell(W) || !anchored)
		return FALSE

	if(cell)
		to_chat(user, "<span class='warning'>There is already a cell in \the [name].</span>")
		return TRUE

	if(user.drop_item(W, src))
		cell = W
		user.visible_message("[user] inserts a cell into \the [src].", "You insert a cell into \the [src].")
		nanomanager.update_uis(src)
	else
		to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")


/obj/machinery/computer/telescience/update_icon()
	if(stat & BROKEN)
		icon_state = "teleportb"
		return

	if(stat & NOPOWER)
		src.icon_state = "teleport0"

	else
		icon_state = initial(icon_state)

/obj/machinery/computer/telescience/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	if(stat & (BROKEN|NOPOWER))
		return
	if(!isAdminGhost(user) && (user.stat || user.restrained()))
		return

	var/list/cell_data=null
	if(cell)
		cell_data = list(
			"charge" = cell.charge,
			"maxcharge" = cell.maxcharge
		)
	var/list/data=list(
		"pOffsetX" = x_player_off,
		"pOffsetY" = y_player_off,
		"coordx" = x_co,
		"coordy" = y_co,
		"coordz" = z_co,
		"cell" = cell_data
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "telescience_console.tmpl", name, 380, 210)
		ui.set_initial_data(data)
		ui.open()
		// Disable auto updating.
		// This UI doesn't change often except when the cell gets extra charge.
		ui.set_auto_update(FALSE)

/obj/machinery/computer/telescience/attack_paw(mob/user)
	to_chat(user, "You are too primitive to use this computer.")

/obj/machinery/computer/telescience/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/machinery/computer/telescience/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/telescience/proc/fizzle()
	if (!telepad)
		return

	spark(telepad)
	visible_message("\The [telepad] weakly fizzles.", "you hear a weak fizzle", "\The [telepad] catches on fire!!!")

/obj/machinery/computer/telescience/proc/telefail()
	if(prob(95))
		fizzle()
		return

	if(prob(5))
		// Irradiate everyone in telescience!
		for(var/obj/machinery/telepad/E in machines)
			var/L = get_turf(E)
			spark(L)
			for(var/mob/living/carbon/human/M in viewers(L, null))
				M.apply_radiation(rand(10, 20), RAD_INTERNAL)
				to_chat(M, "<span class='warning'>You feel strange.</span>")
		return

	/* Lets not, for now.  - N3X
	if(prob(1))
		// AI CALL SHUTTLE I SAW RUNE, SUPER LOW CHANCE, CAN HARDLY HAPPEN
		for(var/mob/living/carbon/O in viewers(src, null))
			var/datum/game_mode/cult/temp = new
			O.show_message("<span class='warning'>The telepad flashes with a strange light, and you have a sudden surge of allegiance toward the true dark one!</span>", 2)
			O.mind.make_Cultist()
			temp.grant_runeword(O)
			sparks()
		return
	if(prob(1))
		// VIVA LA FUCKING REVOLUTION BITCHES, SUPER LOW CHANCE, CAN HARDLY HAPPEN
		for(var/mob/living/carbon/O in viewers(src, null))
			O.show_message("<span class='warning'>The telepad flashes with a strange light, and you see all kind of images flash through your mind, of murderous things Nanotrasen has done, and you decide to rebel!</span>", 2)
			O.mind.make_Rev()
			sparks()
		return
	*/

	if(prob(1))
		// The OH SHIT FUCK GOD DAMN IT LYNCH THE SCIENTISTS event.
		visible_message("<span class='warning'>The telepad changes colors rapidly, and opens a portal, and you see what your mind seems to think is the very threads that hold the pattern of the universe together, and a eerie sense of paranoia creeps into you.</span>")
		for(var/mob/living/carbon/O in viewers(src, null)) //I-IT'S A FEEEEATUUUUUUUREEEEE
			spacevine_infestation()
		spark(telepad)
		return

	if(prob(5))
		// HOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOONK
		for(var/mob/living/carbon/M in hearers(src, null))
			M << sound('sound/items/AirHorn.ogg')
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.earprot())
					continue
			to_chat(M, "<font color='red' size='7'>HONK</font>")
			M.sleeping = 0
			M.stuttering += 20
			M.ear_deaf += 30
			M.Knockdown(3)
			if(prob(30))
				M.Stun(10)
				M.Paralyse(4)
			else
				M.Jitter(500)
			spark(M)
		return

	if(prob(1))
		// They did the mash! (They did the monster mash!) The monster mash! (It was a graveyard smash!)
		spark(telepad)
		for(var/obj/machinery/telepad/E in machines)
			var/L = get_turf(E)
			var/static/list/blocked = list(
				/mob/living/simple_animal/hostile,
				/mob/living/simple_animal/hostile/alien/queen/large,
				/mob/living/simple_animal/hostile/retaliate,
				/mob/living/simple_animal/hostile/retaliate/clown,
				/mob/living/simple_animal/hostile/giant_spider/nurse
			)
			var/list/hostiles = existing_typesof(/mob/living/simple_animal/hostile) - blocked
			playsound(L, 'sound/effects/phasein.ogg', 100, 1, extrarange = 3, falloff = 5)
			for(var/mob/living/carbon/human/M in viewers(L, null))
				M.flash_eyes(visual = 1)
			var/chosen = pick(hostiles)
			var/mob/living/simple_animal/hostile/H = new chosen
			H.forceMove(L)
		return

	// If nothing got chosen after all still fizzle,
	// feedback is good.
	fizzle()

var/list/telesci_warnings = list(
	/obj/machinery/power/supermatter,
	/obj/machinery/the_singularitygen,
	/obj/item/weapon/grenade,
	/obj/item/device/transfer_valve,
	/obj/item/device/fuse_bomb,
	/obj/item/device/onetankbomb,
	/obj/machinery/portable_atmospherics/canister
)

/obj/machinery/computer/telescience/proc/doteleport(mob/user, var/direction)
	if (!telepad)
		return

	var/trueX = x_co + x_off - x_player_off + WORLD_X_OFFSET[z_co]
	var/trueY = y_co + y_off - y_player_off + WORLD_Y_OFFSET[z_co]
	trueX = Clamp(trueX, 1, world.maxx)
	trueY = Clamp(trueY, 1, world.maxy)

	var/turf/target = locate(trueX, trueY, z_co)
	var/area/A=target.loc
	if(A && A.jammed)
		if(!telepad.amplifier || A.jammed==SUPER_JAMMED)
			src.visible_message("<span class='warning'>[bicon(src)] \The [src] turns on and the lights dim. You can see a faint shape, but it loses focus and the telepad shuts off with a buzz.  Perhaps you need more signal strength?", "<span class='warning'>You hear something buzz.</span></span>")
			return

		if(prob(25))
			qdel(telepad.amplifier)
			telepad.amplifier = null
			src.visible_message("[bicon(src)]<span class='notice'>You hear something shatter.</span>","[bicon(src)]<span class='notice'>You hear something shatter.</span>")

	spark(telepad, 5)
	flick("pad-beam", telepad)
	to_chat(user, "<span class='caution'>Teleport successful.</span>")
	spark(target, 5)
	var/turf/source = target
	var/turf/dest = get_turf(telepad)
	if(direction == DIRECTION_SEND)
		source = dest
		dest = target

	var/things = 0
	for(var/atom/movable/ROI in source)
		if(ROI.anchored)
			continue

		var/log = "[key_name(user)] teleported a [ROI] to [formatJumpTo(dest)] from [formatJumpTo(source)]"
		if(is_type_in_list(ROI,telesci_warnings))
			message_admins(log)

		log_admin(log)
		do_teleport(ROI, dest, 0)
		if (++things > 10)
			break


/obj/machinery/computer/telescience/proc/teleport(mob/user, var/direction)
	if(x_co == null || y_co == null || z_co == null)
		to_chat(user, "<span class='caution'>Error: coordinates not set.</span>")
		telefail()
		return

	if (!cell)
		to_chat(user, "<span class='caution'>Error: no cell inserted.</span>")
		return

	if(cell.charge < teleport_cell_usage)
		to_chat(user, "<span class='caution'>Error: not enough buffer energy.</span>")
		return

	if(telepad && (!telepad.linked == src))
		to_chat(user, "<span class='caution'>Error: No telepad linked.</span>")
		return

	cell.use(teleport_cell_usage)
	if(teles_left > 0)
		teles_left -= 1
		doteleport(user, direction)
	else
		telefail()

/obj/machinery/computer/telescience/npc_tamper_act(mob/living/L)
	x_player_off = rand(-MAX_POFFSET, MAX_POFFSET)
	y_player_off = rand(-MAX_POFFSET, MAX_POFFSET)

	x_co = rand(MIN_X, MAX_X)
	y_co = rand(MIN_Y, MAX_Y)
	var/new_z = rand(1, map.zLevels.len)
	if(new_z != map.zCentcomm)
		z_co = new_z

	if (cell && cell.charge < teleport_cell_usage)
		var/direction = pick(DIRECTION_RECEIVE, DIRECTION_SEND)
		teleport(L, direction)

	nanomanager.update_uis(src)

/obj/machinery/computer/telescience/Topic(href, href_list)
	if(..())
		return TRUE

	if(href_list["setPOffsetX"])
		var/new_x = input("Please input desired X offset.", name, x_player_off) as num
		if(new_x < -MAX_POFFSET || new_x > MAX_POFFSET)
			to_chat(usr, "<span class='caution'>Error: Invalid X offset (-10 to 10)</span>")
		else
			x_player_off = new_x
		return TRUE

	if(href_list["setPOffsetY"])
		var/new_y = input("Please input desired X offset.", name, y_player_off) as num
		if(new_y < -MAX_POFFSET || new_y > MAX_POFFSET)
			to_chat(usr, "<span class='caution'>Error: Invalid Y offset (-10 to 10)</span>")
		else
			y_player_off = new_y
		return TRUE


	if(href_list["setx"])
		var/new_x = input("Please input desired X coordinate.", name, x_co) as num
		var/x_validate=new_x+x_off
		if(x_validate < MIN_X || x_validate > MAX_X)
			to_chat(usr, "<span class='caution'>Error: Invalid X coordinate.</span>")
		else
			x_co = new_x
		return TRUE

	if(href_list["sety"])
		var/new_y = input("Please input desired Y coordinate.", name, y_co) as num
		var/y_validate=new_y+y_off
		if(y_validate < MIN_Y || y_validate > MAX_Y)
			to_chat(usr, "<span class='caution'>Error: Invalid Y coordinate.</span>")
		else
			y_co = new_y
		return TRUE

	if(href_list["setz"])
		var/new_z = input("Please input desired Z coordinate.", name, z_co) as num
		if(new_z == map.zCentcomm || new_z < 1 || new_z > map.zLevels.len)
			to_chat(usr, "<span class='caution'>Error: Invalid Z coordinate.</span>")
		else
			z_co = new_z
		return TRUE

	if(href_list["send"])
		if(cell && cell.charge>=teleport_cell_usage)
			teleport(usr, DIRECTION_SEND)
		return TRUE

	if(href_list["receive"])
		if(cell && cell.charge>=teleport_cell_usage)
			teleport(usr, DIRECTION_RECEIVE)
		return TRUE

	if(href_list["eject_cell"])
		if(cell)
			if (usr.put_in_hands(cell))
				usr.visible_message("<span class='notice'>[usr] removes the cell from \the [src].</span>", "<span class='notice'>You remove the cell from \the [src].</span>")
			else 
				visible_message("<span class='notice'>\The [src] beeps as its cell is removed.</span>")
				cell.forceMove(get_turf(src))
			cell.add_fingerprint(usr)
			cell.updateicon()
			src.cell = null
			update_icon()
		return TRUE

	if(href_list["recal"])
		teles_left = rand(12,14)
		x_off = rand(-10,10)
		y_off = rand(-10,10)
		spark(telepad)
		to_chat(usr, "<span class='caution'>Calibration successful.</span>")
		return TRUE
	return FALSE

#undef DIRECTION_SEND
#undef DIRECTION_RECEIVE
