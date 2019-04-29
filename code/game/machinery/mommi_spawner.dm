/obj/machinery/mommi_spawner
	name = "\improper MoMMI fabricator"
	desc = "A large pad sunk into the ground."
	icon = 'icons/obj/robotics.dmi'
	icon_state = "mommispawner-idle"
	density = TRUE
	anchored = TRUE
	var/building = FALSE
	var/metal = 0
	var/const/metalPerMoMMI = 10
	var/const/metalPerTick = 1
	var/mommi_type = /mob/living/silicon/robot/mommi/soviet
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 5000
	var/recharge_time = 60 SECONDS
	var/locked_to_zlevel = TRUE // Whether to lock the spawned MoMMIs to the z-level
	var/locked_law = "You belong to the station where you were created; do not leave it."
	var/dorf = FALSE

/obj/machinery/mommi_spawner/dorf
	name = "dorf fabricator"
	mommi_type = /mob/living/silicon/robot/mommi/nt
	locked_to_zlevel = FALSE

/obj/machinery/mommi_spawner/dorf/PostMoMMIMaking(var/mob/living/silicon/robot/mommi/M)
	..()
	M.laws = new /datum/ai_laws/dorf
	M.keeper = FALSE

/obj/machinery/mommi_spawner/clockwork
	name = "clockwork fabricator"
	mommi_type = /mob/living/silicon/robot/mommi/cogspider
	locked_to_zlevel = FALSE

/obj/machinery/mommi_spawner/clockwork/PostMoMMIMaking(var/mob/living/silicon/robot/mommi/M)
	..()
	var/datum/role/clockwork/gravekeeper/GK = new
	GK.AssignToRole(M.mind,1)
	var/datum/faction/clockwork/clockwork = find_active_faction_by_type(/datum/faction/clockwork)
	if(!clockwork)
		clockwork = ticker.mode.CreateFaction(/datum/faction/clockwork)
	clockwork.HandleRecruitedRole(GK)

/obj/machinery/mommi_spawner/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	update_icon()

/obj/machinery/mommi_spawner/proc/canSpawn()
	return !(stat & NOPOWER) && !building && metal >= metalPerMoMMI

/obj/machinery/mommi_spawner/process()
	if(stat & NOPOWER || building || metal >= metalPerMoMMI)
		return
	metal += metalPerTick
	if(metal >= metalPerMoMMI)
		update_icon()

/obj/machinery/mommi_spawner/proc/is_valid_user(var/mob/user)
	if(!user)
		return FALSE

	if(building)
		to_chat(user, "<span class='warning'>\The [src] is busy building something already.</span>")
		return FALSE
	
	if(metal < metalPerMoMMI)
		to_chat(user, "<span class='warning'>\The [name] doesn't have enough metal to complete this task.</span>")
		return FALSE
	
	if(user.client)
		var/timedifference = world.time - user.client.time_died_as_mouse
		if(user.client.time_died_as_mouse && timedifference <= mouse_respawn_time * 600)
			var/timedifference_text
			timedifference_text = time2text(mouse_respawn_time * 600 - timedifference,"mm:ss")
			to_chat(user, "<span class='warning'>You may only spawn again as a mouse or MoMMI more than [mouse_respawn_time] minutes after your death. You have [timedifference_text] left.</span>")
			return FALSE
	
	if(jobban_isbanned(user, "Mobile MMI"))
		to_chat(user, "<span class='warning'>\The [name] lets out an annoyed buzz.</span>")
		return FALSE
	
	return TRUE

/obj/machinery/mommi_spawner/attack_ghost(var/mob/dead/observer/user)
	if(is_valid_user(user))
		if(alert(user, "Do you wish to be turned into a MoMMI at this position?", "Confirm", "Yes", "No") != "Yes")
			return
		makeMoMMI(user)

/obj/machinery/mommi_spawner/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(!..())
		if(istype(O,/obj/item/device/mmi))
			var/obj/item/device/mmi/mmi = O
			if(!mmi.brainmob)
				to_chat(user, "<span class='warning'>\The [mmi] appears to be devoid of any soul.</span>")
				return TRUE

			if(!mmi.brainmob.key)
				if(!mind_can_reenter(mmi.brainmob.mind))
					to_chat(user, "<span class='notice'>\The [src] indicates that [O.name]'s mind is completely unresponsive; there's no point.</span>")
					return TRUE
			
			if(mmi.brainmob.stat == DEAD)
				to_chat(user, "<span class='warning'>Yeah, good idea. Give something deader than the pizza in your fridge legs.  Mom would be so proud.</span>")
				return TRUE

			if(!is_valid_user(mmi.brainmob))
				return TRUE

			if(user.drop_item(O, src))
				makeMoMMI(mmi.brainmob, mmi)
				return TRUE

/obj/machinery/mommi_spawner/proc/makeMoMMI(var/mob/user, var/obj/item/device/mmi/use_mmi)
	building = TRUE
	update_icon()

	if(!user || !istype(user) || !user.client)
		// Player has already been made into another mob before this one spawned, so let's reset the spawner
		building = FALSE
		update_icon()
		return FALSE

	spawn(50)
		if(!user || !istype(user) || !user.client)
			// Player disappeared between clicking on the spawner and now, so we have no one to give a MoMMI to!
			building = FALSE
			update_icon()
			return FALSE

		// Make the MoMMI!
		var/mob/living/silicon/robot/mommi/M = new mommi_type(loc)
		M.key = user.key

		PostMoMMIMaking(M)

		if(use_mmi)
			M.mmi = use_mmi
			use_mmi.forceMove(M)
		else
			qdel(user)

		metal = 0
		building = FALSE
		update_icon()
		

/obj/machinery/mommi_spawner/proc/PostMoMMIMaking(var/mob/living/silicon/robot/mommi/M)
	if(!M)
		return

	M.invisibility = 0

	if(M.mind.special_role)
		M.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting.") //>signing your shit

	if(locked_to_zlevel)
		M.add_ion_law("[locked_law]")
		var/turf/T = get_turf(src)
		M.locked_to_z = T.z

	spawn()
		M.Namepick()

/obj/machinery/mommi_spawner/update_icon()
	if(stat & NOPOWER)
		icon_state="mommispawner-nopower"
	else if(metal < metalPerMoMMI)
		icon_state="mommispawner-recharging"
	else if(building)
		icon_state="mommispawner-building"
	else
		icon_state="mommispawner-idle"
