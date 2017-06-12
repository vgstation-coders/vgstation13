#define MAX_POFFSET 10

#define MAX_X (world.maxx + 50)
#define MIN_X -49

#define MAX_Y (world.maxy + 50)
#define MIN_Y -49

/obj/machinery/computer/telescience
	name = "telepad control console"
	desc = "Used to teleport objects to and from the telescience telepad."
	icon_state = "teleport"
	circuit = "/obj/item/weapon/circuitboard/telesci_computer"
	var/sending = 1
	var/obj/machinery/telepad/telepad = null

	// VARIABLES //
	var/teles_left	// How many teleports left until it becomes uncalibrated
	var/x_off	// X offset
	var/y_off	// Y offset
	var x_player_off // x offset set by player
	var y_player_off // y offset set by player
	var/x_co = 1	// X coordinate
	var/y_co = 1	// Y coordinate
	var/z_co = 1	// Z coordinate

	use_power = 1
	idle_power_usage = 10
	active_power_usage = 300
	power_channel = EQUIP
	var/obj/item/weapon/cell/cell
	var/teleport_cell_usage=1000 // 100% of a standard cell
	processing=1

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/telescience/New()
	..()
	teles_left = rand(12,14)
	x_off = rand(-10,10)
	y_off = rand(-10,10)
	x_player_off = 0
	y_player_off = 0
	if(ticker)
		initialize()

/obj/machinery/computer/telescience/initialize()
	..()
	if(!ticker)
		cell=new/obj/item/weapon/cell(src)
		cell.charge = 0
	telepad = locate() in range(src, 7)

/obj/machinery/computer/telescience/process()
	if(!cell || (stat & (BROKEN|NOPOWER)) || !anchored)
		return
	if(cell.give(100))
		use_power(200)		//this used to use CELLRATE, but CELLRATE is fucking awful. feel free to fix this properly!
	src.updateUsrDialog()

/obj/machinery/computer/telescience/attackby(obj/item/weapon/W, mob/user)
	if(..())
		return 1

	if(stat & BROKEN)
		return

	if(istype(W, /obj/item/weapon/cell) && anchored)
		if(cell)
			to_chat(user, "<span class='warning'>There is already a cell in \the [name].</span>")
			return
		else
			if(areaMaster.power_equip == 0) // There's no APC in this area, don't try to cheat power!
				to_chat(user, "<span class='warning'>\The [name] blinks red as you try to insert the cell!</span>")
				return

			if(user.drop_item(W, src))
				cell = W
				user.visible_message("[user] inserts a cell into the [src].", "You insert a cell into the [src].")
			else
				user << "<span class='warning'>You can't let go of \the [W]!</span>"
		update_icon()

/obj/machinery/computer/telescience/update_icon()
	if(stat & BROKEN)
		icon_state = "teleportb"
	else
		if(stat & NOPOWER)
			src.icon_state = "teleport0"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER

 /**
  * The ui_interact proc is used to open and update Nano UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  *
  * @return nothing
  */
/obj/machinery/computer/telescience/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(stat & (BROKEN|NOPOWER))
		return
	if(user.stat || user.restrained())
		return

	// this is the data which will be sent to the ui
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
		// the ui does not exist, so we'll create a new one
		ui = new(user, src, ui_key, "telescience_console.tmpl", name, 380, 210)
		// When the UI is first opened this is the data it will use
		ui.set_initial_data(data)
		// Open the new ui window.
		ui.open()
		// Auto update every Master Controller tick.
		ui.set_auto_update(1)

/obj/machinery/computer/telescience/attack_paw(mob/user)
	to_chat(user, "You are too primitive to use this computer.")
	return

/obj/machinery/computer/telescience/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/machinery/computer/telescience/attack_hand(mob/user as mob)
	if(user.client && user.client.prefs.usenanoui)//Check if the player is using nanoUI or not.
		ui_interact(user)
		return
	else
		interact(user)

/obj/machinery/computer/telescience/interact(mob/user)
	if(stat & BROKEN)
		user.unset_machine(src)
		return


	var/out = {"
		<div class='item'>
			<div class='itemLabel'>
				Offsets:
			</div>
			<div class='itemContent'>
				<a href='?src=\ref[src];setPOffsetX=1'>X offset: [x_player_off]</a>
				<a href='?src=\ref[src];setPOffsetY=1'>Y offset: [y_player_off]</a>
			</div>
		</div>
		<div class='item'>
			<div class='itemLabel'>
				Coordinates:
			</div>
			<div class='itemContent'>
				<a href='?src=\ref[src];setx=1'>X: [x_co]</a>
				<a href='?src=\ref[src];sety=1'>Y: [y_co]</a>
				<a href='?src=\ref[src];setz=1'>Z: [z_co]</a>
			</div>
		</div>
		<div class='item'>
			<div class='itemLabel'>
				Controls:
			</div>
			<div class='itemContent'>
				<a href='?src=\ref[src];send=1' [x_co && y_co && z_co ? "" : "class='linkOff'"]>Send</a>
				<a href='?src=\ref[src];receive=1' [x_co && y_co && z_co ? "" : "class='linkOff'"]>Receive</a>
				<a href='?src=\ref[src];recal=1'>Recalibrate</a>
			</div>
		</div>
		"}
	if(!cell)
		out += {"
		<div class="notice">No power cell detected.</div>
		"}
	else
		out += {"
		<div class='statusDisplay'>
			<div class='line'>
				<div class='statusLabel'>
					[cell.charge]/[cell.maxcharge]
					<a href='?src=\ref[src];eject_cell=1'>Eject</a>
				</div>
			</div>
		</div>
		"}

	user.set_machine(src)
	var/datum/browser/browserdatum = new(user, "telescience", name, 380, 210, src)
	browserdatum.add_stylesheet("shared", 'nano/css/shared.css')
	browserdatum.set_content(out)
	browserdatum.open()

/obj/machinery/computer/telescience/proc/sparks(var/atom/target)
	if(!target)
		if(telepad && get_turf(telepad))
			target = telepad
		else
			return
	var/L = get_turf(target)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, L)
	s.start()

/obj/machinery/computer/telescience/proc/telefail()
	if(prob(95))
		sparks()
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='warning'>The telepad weakly fizzles.</span>", 2)
		return
	if(prob(5))
		// Irradiate everyone in telescience!
		for(var/obj/machinery/telepad/E in machines)
			var/L = get_turf(E)
			sparks(target = L)
			for(var/mob/living/carbon/human/M in viewers(L, null))
				M.apply_radiation((rand(10, 20)), RAD_INTERNAL)
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
		sparks()
		return
	if(prob(5))
		// HOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOONK
		for(var/mob/living/carbon/M in hearers(src, null))
			M << sound('sound/items/AirHorn.ogg')
			if(istype(M, /mob/living/carbon/human))
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
			sparks(target = M)
		return
	if(prob(1))
		// They did the mash! (They did the monster mash!) The monster mash! (It was a graveyard smash!)
		sparks()
		for(var/obj/machinery/telepad/E in machines)
			var/L = get_turf(E)
			var/blocked = list(/mob/living/simple_animal/hostile,
				/mob/living/simple_animal/hostile/alien/queen/large,
				/mob/living/simple_animal/hostile/retaliate,
				/mob/living/simple_animal/hostile/retaliate/clown,
				/mob/living/simple_animal/hostile/giant_spider/nurse)
			var/list/hostiles = typesof(/mob/living/simple_animal/hostile) - blocked
			playsound(L, 'sound/effects/phasein.ogg', 100, 1, extrarange = 3, falloff = 5)
			for(var/mob/living/carbon/human/M in viewers(L, null))
				M.flash_eyes(visual = 1)
			var/chosen = pick(hostiles)
			var/mob/living/simple_animal/hostile/H = new chosen
			H.forceMove(L)
			return
		return
	return
var/global/list/telesci_warnings = list(/obj/machinery/power/supermatter,
										/obj/machinery/the_singularitygen,
										/obj/item/weapon/grenade,
										/obj/item/device/transfer_valve,
										/obj/item/device/fuse_bomb,
										/obj/item/device/onetankbomb,
										/obj/machinery/portable_atmospherics/canister)
/obj/machinery/computer/telescience/proc/doteleport(mob/user)
	var/trueX = x_co + x_off - x_player_off + WORLD_X_OFFSET[z_co]
	var/trueY = y_co + y_off - y_player_off + WORLD_Y_OFFSET[z_co]
	trueX = Clamp(trueX, 1, world.maxx)
	trueY = Clamp(trueY, 1, world.maxy)
	if(telepad)
		var/turf/target = locate(trueX, trueY, z_co)
		var/area/A=target.loc
		if(A && A.jammed)
			if(!telepad.amplifier || A.jammed==SUPER_JAMMED)
				src.visible_message("<span class='warning'>[bicon(src)] [src] turns on and the lights dim.  You can see a faint shape, but it loses focus and the telepad shuts off with a buzz.  Perhaps you need more signal strength?", "[bicon(src)]<span class='warning'>You hear something buzz.</span></span>")
				return
			if(prob(25))
				qdel(telepad.amplifier)
				telepad.amplifier = null
				src.visible_message("[bicon(src)]<span class='notice'>You hear something shatter.</span>","[bicon(src)]<span class='notice'>You hear something shatter.</span>")
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, telepad)
		s.start()
		flick("pad-beam", telepad)
		to_chat(user, "<span class='caution'>Teleport successful.</span>")
		var/sparks = get_turf(target)
		var/datum/effect/effect/system/spark_spread/y = new /datum/effect/effect/system/spark_spread
		y.set_up(5, 1, sparks)
		y.start()
		var/turf/source = target
		var/turf/dest = get_turf(telepad)
		if(sending)
			source = dest
			dest = target
		var/things=0
		for(var/atom/movable/ROI in source)
			if(ROI.anchored || things>=10)
				continue
			if(is_type_in_list(ROI,telesci_warnings))
				message_admins("[user.real_name]/([formatPlayerPanel(user,user.ckey)]) teleported a [ROI] to [formatJumpTo(dest)] from [formatJumpTo(source)]")
			log_admin("[user.real_name]/([formatPlayerPanel(user,user.ckey)]) teleported a [ROI] to [formatJumpTo(dest)] from [formatJumpTo(source)]")
			do_teleport(ROI, dest, 0)
			things++
		return
	return

/obj/machinery/computer/telescience/proc/teleport(mob/user)
	if(x_co == null || y_co == null || z_co == null)
		to_chat(user, "<span class='caution'>Error: coordinates not set.</span>")
		telefail()
		return
	if(cell && cell.charge<teleport_cell_usage)
		to_chat(user, "<span class='caution'>Error: not enough energy.</span>")
		return
	cell.use(teleport_cell_usage)
	if(teles_left > 0)
		teles_left -= 1
		doteleport(user)
	else
		telefail()
		return
	return

/obj/machinery/computer/telescience/npc_tamper_act(mob/living/L)
	x_player_off = rand(-MAX_POFFSET, MAX_POFFSET)
	y_player_off = rand(-MAX_POFFSET, MAX_POFFSET)

	x_co = rand(MIN_X, MAX_X)
	y_co = rand(MIN_Y, MAX_Y)
	var/new_z = rand(1, map.zLevels.len)
	if(new_z != map.zCentcomm)
		z_co = new_z

	if(prob(50)) //Send
		if(cell && cell.charge>=teleport_cell_usage)
			sending = 1
			teleport(usr)
		src.updateUsrDialog()
	else //Receive
		if(cell && cell.charge>=teleport_cell_usage)
			sending = 0
			teleport(usr)
		src.updateUsrDialog()

/obj/machinery/computer/telescience/Topic(href, href_list)
	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1

	if(..())
		return 1

	if(href_list["setPOffsetX"])
		var/new_x = input("Please input desired X offset.", name, x_player_off) as num
		if(new_x < -MAX_POFFSET || new_x > MAX_POFFSET)
			to_chat(usr, "<span class='caution'>Error: Invalid X offset (-10 to 10)</span>")
		else
			x_player_off = new_x
		src.updateUsrDialog()
		return 1

	if(href_list["setPOffsetY"])
		var/new_y = input("Please input desired X offset.", name, y_player_off) as num
		if(new_y < -MAX_POFFSET || new_y > MAX_POFFSET)
			to_chat(usr, "<span class='caution'>Error: Invalid Y offset (-10 to 10)</span>")
		else
			y_player_off = new_y
		src.updateUsrDialog()
		return 1


	if(href_list["setx"])
		var/new_x = input("Please input desired X coordinate.", name, x_co) as num
		var/x_validate=new_x+x_off
		if(x_validate < MIN_X || x_validate > MAX_X)
			to_chat(usr, "<span class='caution'>Error: Invalid X coordinate.</span>")
		else
			x_co = new_x
		src.updateUsrDialog()
		return 1

	if(href_list["sety"])
		var/new_y = input("Please input desired Y coordinate.", name, y_co) as num
		var/y_validate=new_y+y_off
		if(y_validate < MIN_Y || y_validate > MAX_Y)
			to_chat(usr, "<span class='caution'>Error: Invalid Y coordinate.</span>")
		else
			y_co = new_y
		src.updateUsrDialog()
		return 1

	if(href_list["setz"])
		var/new_z = input("Please input desired Z coordinate.", name, z_co) as num
		if(new_z == map.zCentcomm || new_z < 1 || new_z > map.zLevels.len)
			to_chat(usr, "<span class='caution'>Error: Invalid Z coordinate.</span>")
		else
			z_co = new_z
		src.updateUsrDialog()
		return 1

	if(href_list["send"])
		if(cell && cell.charge>=teleport_cell_usage)
			sending = 1
			teleport(usr)
		src.updateUsrDialog()
		return 1

	if(href_list["receive"])
		if(cell && cell.charge>=teleport_cell_usage)
			sending = 0
			teleport(usr)
		src.updateUsrDialog()
		return 1

	if(href_list["eject_cell"])
		if(cell)
			usr.put_in_hands(cell)
			cell.add_fingerprint(usr)
			cell.updateicon()
			src.cell = null
			usr.visible_message("[usr] removes the cell from \the [name].", "You remove the cell from \the [name].")
			update_icon()
		src.updateUsrDialog()
		return 1

	if(href_list["recal"])
		teles_left = rand(12,14)
		x_off = rand(-10,10)
		y_off = rand(-10,10)
		sparks()
		to_chat(usr, "<span class='caution'>Calibration successful.</span>")
		src.updateUsrDialog()
		return 1
	return 0
