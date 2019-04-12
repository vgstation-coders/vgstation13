#define NAMETYPE_NORMAL  0
#define NAMETYPE_SILLY   1

/obj/machinery/transformer
	name = "Automatic Robotic Factory 5000"
	desc = "A large metallic machine with an entrance and an exit. A sign on the side reads 'human goes in, robot comes out'. Human must be lying down and alive. Has to cooldown between each use."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "separator-AO1"
	plane = ABOVE_HUMAN_PLANE
	anchored = 1
	density = 1
	var/transform_dead = 0 //This variable doesn't seem to do anything
	var/transform_standing = 0
	var/cooldown_duration = 900 // 1.5 minutes
	var/cooldown_time = 0
	var/cooldown_state = 0 // Just for icons.
	var/robot_cell_charge = 5000
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 5000

	// /vg/
	var/force_borg_module=null
	var/name_type=NAMETYPE_NORMAL
	var/enable_namepick=TRUE
	var/belongstomalf=null //malf AI that owns autoborger

/obj/machinery/transformer/New()
	// On us
	..()
	new /obj/machinery/conveyor/auto(loc, WEST)

/obj/machinery/transformer/power_change()
	..()
	update_icon()

/obj/machinery/transformer/update_icon()
	..()
	if(stat & (BROKEN|NOPOWER) || cooldown_time > world.time)
		icon_state = "separator-AO0"
	else
		icon_state = initial(icon_state)

/obj/machinery/transformer/Bumped(var/atom/movable/AM)
	if(cooldown_state)
		return

	// Crossed didn't like people lying down.
	if(ishuman(AM))
		// Only humans can enter from the west side, while lying down.
		var/move_dir = get_dir(loc, AM.loc)
		var/mob/living/carbon/human/H = AM
		if((transform_standing || H.lying) && move_dir == EAST)// || move_dir == WEST)
			AM.forceMove(src.loc)
			do_transform(AM)
	//Shit bugs out if theres too many items on the enter side conveyer
	else if(istype(AM, /obj/item))
		var/move_dir = get_dir(loc, AM.loc)
		if(move_dir == EAST)
			AM.forceMove(src.loc)

/obj/machinery/transformer/proc/do_transform(var/mob/living/carbon/human/H)
	if(stat & (BROKEN|NOPOWER))
		return
	if(cooldown_state)
		return

	if(!transform_dead && H.stat == DEAD)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return

	if(jobban_isbanned(H, "Cyborg"))
		src.visible_message("<span class='danger'>\The [src.name] throws an exception. Lifeform not compatible with factory.</span>")
		return

	playsound(src, 'sound/items/Welder.ogg', 50, 1)
	H.audible_scream() // It is painful
	H.adjustBruteLoss(max(0, 80 - H.getBruteLoss())) // Hurt the human, don't try to kill them though.
	H.handle_regular_hud_updates() // Make sure they see the pain.

	// Sleep for a couple of ticks to allow the human to see the pain
	sleep(5)

	// Delete the items or they'll all pile up in a single tile and lag
	// skipnaming disables namepick on New(). It's annoying as fuck on malf.  Later on, we enable or disable namepick.
	var/mob/living/silicon/robot/R = H.Robotize(1, skipnaming=TRUE, malfAI=belongstomalf)
	if(R)
		R.cell.maxcharge = robot_cell_charge
		R.cell.charge = robot_cell_charge

	 	// So he can't jump out the gate right away.
		R.SetKnockdown(5)

		// /vg/: Force borg module, if needed.
		R.pick_module(force_borg_module)

		// /vg/: Select from various name lists.
		if(name_type == NAMETYPE_SILLY)
			R.custom_name = pick(autoborg_silly_names)
			R.custom_name = replacetext(R.custom_name, "{AINAME}", (!isnull(R.connected_ai) ? R.connected_ai.name : "AI"))
			if(findtext(R.custom_name, "{###}"))
				R.custom_name = replacetext(R.custom_name, "{###}", num2text(R.ident))
			else
				R.custom_name += "-[num2text(R.ident)]"


		// /vg/: Allow AI to disable namepick.
		R.namepick_uses=enable_namepick
		if(enable_namepick)
			to_chat(R, "<span class='info'><b>The AI has chosen to let you choose your name via the <em>Namepick</em> command.</b></span>")
		else
			to_chat(R, "<span class='danger'><b>The AI has chosen to disable your access to the <em>Namepick</em> command.</b></span>")
		R.updateicon()
		R.updatename()

	spawn(50)
		playsound(src, 'sound/machines/ding.ogg', 50, 0)
		if(R)
			R.SetKnockdown(0)

	// Activate the cooldown
	cooldown_time = world.time + cooldown_duration
	cooldown_state = 1
	update_icon()

/obj/machinery/transformer/process()
	..()
	var/old_cooldown_state=cooldown_state
	cooldown_state = cooldown_time > world.time
	if(cooldown_state!=old_cooldown_state)
		update_icon()
		if(!cooldown_state)
			playsound(src, 'sound/machines/ping.ogg', 50, 0)

/obj/machinery/transformer/conveyor/New()
	..()
	var/turf/T = loc
	if(T)
		// Spawn Conveyour Belts

		//East
		var/turf/east = locate(T.x + 1, T.y, T.z)
		if(istype(east, /turf/simulated/floor))
			new /obj/machinery/conveyor/auto(east, WEST)

		// West
		var/turf/west = locate(T.x - 1, T.y, T.z)
		if(istype(west, /turf/simulated/floor))
			new /obj/machinery/conveyor/auto(west, WEST)

/obj/machinery/transformer/attack_ai(var/mob/user)
	interact(user)

/obj/machinery/transformer/interact(var/mob/user)
	var/data=""
	if(cooldown_state)
		data += {"<b>Recalibrating.</b> Time left: [(cooldown_time - world.time)/10] seconds."}
	else
		data += {"<p style="color:red;font-weight:bold;"><blink>ROBOTICIZER ACTIVE.</blink></p>"}
	data += {"
		<h2>Settings</h2>
		<ul>
			<li>
				<b>Next Borg's Module:</b>
				<a href="?src=\ref[src];act=force_class">[isnull(force_borg_module)?"Not Forced":force_borg_module]</a>
			</li>
			<li>
				<b>Borg Names:</b>
				<a class="link[name_type==NAMETYPE_NORMAL ? "On" : "Off"]" href="?src=\ref[src];act=names;nametype=[NAMETYPE_NORMAL]">Default</a>
				<a class="link[name_type==NAMETYPE_SILLY ? "On" : "Off"]" href="?src=\ref[src];act=names;nametype=[NAMETYPE_SILLY]">Silly (OBVIOUS)</a>
			</li>
			<li>
				<b>Permit Name Picking:</b>
				<a href="?src=\ref[src];act=enable_namepick">[enable_namepick ? "On":"Off"]</a>
			</li>
		</ul>
	"}

	var/datum/browser/popup = new(user, "transformer", src.name, 400, 300)
	popup.set_content(data)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/obj/machinery/transformer/Topic(href, href_list)
	if(!isAI(usr))
		to_chat(usr, "<span class='warning'>This machine is way above your pay-grade.</span>")
		return 0
	if(!("act" in href_list))
		return 0
	switch(href_list["act"])
		if("names")
			var/newnametype = text2num(href_list["nametype"])
			if(!(newnametype in list(NAMETYPE_NORMAL, NAMETYPE_SILLY)))
				to_chat(usr, "<span class='warning'>Invalid newnametype. Stop trying to make href exploits happen.</span>")
				return 0
			name_type=newnametype
		if("enable_namepick")
			enable_namepick=!enable_namepick
		if("force_class")
			var/list/modules = list("(Robot's Choice)")
			modules += getAvailableRobotModules()
			var/sel_mod = input("Please, select a module!", "Robot", null, null) as null|anything in modules
			if(!sel_mod)
				return
			if(sel_mod == "(Robot's Choice)")
				force_borg_module = null
			else
				force_borg_module = sel_mod
	interact(usr)
	return 1
