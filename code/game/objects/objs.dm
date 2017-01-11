var/global/list/reagents_to_log = list(FUEL, PLASMA, PACID, SACID, AMUTATIONTOXIN, MINDBREAKER, SPIRITBREAKER, CYANIDE, IMPEDREZENE, LUBE)
/obj
	var/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	var/reliability = 100	//Used by SOME devices to determine how reliable they are.
	var/crit_fail = 0
	animate_movement = 2
	var/throwforce = 1
	var/siemens_coefficient = 0 // for electrical admittance/conductance (electrocution checks and shit) - 0 is not conductive, 1 is conductive - this is a range, not binary
	var/sharpness = 0 //not a binary - rough guide is 0.8 cutting, 1 cutting well, 1.2 specifically sharp (knives, etc) 1.5 really sharp (scalpels, e-weapons)
	var/sharpness_flags = 0 //Describe in which way this thing is sharp. Shouldn't sharpness be exclusive to obj/item?
	var/heat_production = 0

	var/in_use = 0 // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!

	var/damtype = "brute"
	var/force = 0

	//Should we alert about reagents that should be logged?
	var/log_reagents = 1

	var/list/mob/_using // All mobs dicking with us.

	// Shit for mechanics. (MECH_*)
	var/mech_flags=0

	var/holomap = FALSE // Whether we should be on the holomap.
	var/auto_holomap = FALSE // Whether we automatically soft-add ourselves to the holomap in New(), make sure this is false is something does it manually.
	plane = OBJ_PLANE

	var/defective = 0

	var/can_take_pai = FALSE
	var/obj/item/device/paicard/integratedpai = null
	var/datum/delay_controller/pAImove_delayer = new(1, ARBITRARILY_LARGE_NUMBER)
	var/pAImovement_delay = 0

/obj/New()
	..()
	if (auto_holomap && isturf(loc))
		var/turf/T = loc
		T.soft_add_holomap(src)
	verbs -= /obj/verb/remove_pai

/obj/Destroy()
	for(var/mob/user in _using)
		user.unset_machine()

	if(src in processing_objects)
		processing_objects -= src

	..()

/obj/item/proc/is_used_on(obj/O, mob/user)

/obj/proc/install_pai(obj/item/device/paicard/P)
	if(!P || !istype(P))
		return 0
	P.forceMove(src)
	integratedpai = P
	verbs += /obj/verb/remove_pai

/obj/attackby(obj/item/weapon/W, mob/user)
	if(can_take_pai && istype(W, /obj/item/device/paicard))
		if(user.drop_item(W))
			to_chat(user, "You insert \the [W] into a slot in \the [src].")
			install_pai(W)
			playsound(src, 'sound/misc/cartridge_in.ogg', 25)

/obj/proc/attack_integrated_pai(mob/living/silicon/pai/user)	//called when integrated pAI clicks on the object, or uses the attack_self() hotkey
	return

/obj/proc/swapkey_integrated_pai(mob/living/silicon/pai/user)	//called when integrated pAI uses the swap_hand() hotkey
	return

/obj/proc/throwkey_integrated_pai(mob/living/silicon/pai/user)	//called when integrated pAI uses the toggle_throw_mode() hotkey
	return

/obj/proc/dropkey_integrated_pai(mob/living/silicon/pai/user)	//called when integrated pAI uses the drop hotkey
	return

/obj/proc/equipkey_integrated_pai(mob/living/silicon/pai/user)	//called when integrated pAI uses the equip hotkey
	return

/obj/proc/intentright_integrated_pai(mob/living/silicon/pai/user)	//called when integrated pAI uses the cycle-intent-right hotkey
	return

/obj/proc/intentleft_integrated_pai(mob/living/silicon/pai/user)	//called when integrated pAI uses the cycle-intent-left hotkey
	return

/obj/proc/intenthelp_integrated_pai(mob/living/silicon/pai/user)	//called when integrated pAI uses the help intent hotkey
	return

/obj/proc/intentdisarm_integrated_pai(mob/living/silicon/pai/user)	//called when integrated pAI uses the disarm intent hotkey
	return

/obj/proc/intentgrab_integrated_pai(mob/living/silicon/pai/user)	//called when integrated pAI uses the grab intent hotkey
	return

/obj/proc/intenthurt_integrated_pai(mob/living/silicon/pai/user)	//called when integrated pAI uses the hurt intent hotkey
	return

/obj/proc/pAImove(mob/living/silicon/pai/user, dir)					//called when integrated pAI attempts to move
	if(pAImove_delayer.blocked())
		return 0
	else
		delayNextpAIMove(getpAIMovementDelay())
		return 1

/obj/proc/getpAIMovementDelay()
	return pAImovement_delay

/obj/proc/delayNextpAIMove(var/delay, var/additive=0)
	pAImove_delayer.delayNext(delay,additive)

/obj/proc/on_integrated_pai_click(mob/living/silicon/pai/user, var/atom/A)
	if(istype(A,/obj/machinery)||(istype(A,/mob)&&user.secHUD))
		A.attack_pai(user)

/obj/verb/remove_pai()
	set name = "Remove pAI"
	set category = "Object"
	set src in range(1)

	var/mob/M = usr
	if(!M.Adjacent(src))
		return
	if(!M.dexterity_check())
		to_chat(usr, "You don't have the dexterity to do this!")
		return
	if(M.incapacitated())
		to_chat(M, "You can't do that while you're incapacitated!")
		return

	to_chat(M, "You eject \the [integratedpai] from \the [src].")
	integratedpai.forceMove(get_turf(src))
	M.put_in_hands(integratedpai)
	integratedpai = null
	playsound(src, 'sound/misc/cartridge_out.ogg', 25)
	verbs -= /obj/verb/remove_pai

/obj/recycle(var/datum/materials/rec)
	if(..())
		return 1
	return w_type

/*
/obj/melt()
	var/obj/effect/decal/slag/slag=locate(/obj/effect/decal/slag) in get_turf(src)
	if(!slag)
		slag = new(get_turf(src))
	slag.slaggify(src)
*/

/obj/proc/is_conductor(var/siemens_min = 0.5)
	if(src.siemens_coefficient >= siemens_min)
		return 1
	return

/obj/proc/cultify()
	qdel(src)

/obj/proc/wrenchable()
	return 0

/obj/proc/can_wrench_shuttle()
	return 0

/obj/proc/is_sharp()
	return sharpness

/obj/proc/is_hot()
	return heat_production

/obj/proc/process()
	set waitfor = FALSE
	processing_objects.Remove(src)

/obj/assume_air(datum/gas_mixture/giver)
	if(loc)
		return loc.assume_air(giver)
	else
		return null

/obj/remove_air(amount)
	if(loc)
		return loc.remove_air(amount)
	else
		return null

/obj/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/obj/proc/handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
	//Return: (NONSTANDARD)
	//		null if object handles breathing logic for lifeform
	//		datum/air_group to tell lifeform to process using that breath return
	//DEFAULT: Take air from turf to give to have mob process
	if(breath_request>0)
		return remove_air(breath_request)
	else
		return null

/atom/movable/proc/initialize()
	return

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		if(_using && _using.len)
			var/list/nearby = viewers(1, src) + loc //List of nearby things includes the location - allows you to call this proc on items and such
			for(var/mob/M in _using) // Only check things actually messing with us.
				if (!M || !M.client || M.machine != src)
					_using.Remove(M)
					continue

				if(!M in nearby) // NOT NEARBY
					// AIs/Robots can do shit from afar.
					if (isAI(M) || isrobot(M))
						is_in_use = 1
						src.attack_ai(M)

					// check for TK users
					if(M.mutations && M.mutations.len)
						if(M_TK in M.mutations)
							is_in_use = 1
							src.attack_hand(M, TRUE) // The second param is to make sure brain damage on the user doesn't cause the UI to not update but the action to still happen.
					else
						// Remove.
						_using.Remove(M)
						continue
				else // EVERYTHING FROM HERE DOWN MUST BE NEARBY
					is_in_use = 1
					attack_hand(M, TRUE)
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = 0
		for(var/mob/M in _using) // Only check things actually messing with us.
			// Not actually using the fucking thing?
			if (!M || !M.client || M.machine != src)
				_using.Remove(M)
				continue
			// Not robot or AI, and not nearby?
			if(!isAI(M) && !isrobot(M) && !(M in nearby))
				_using.Remove(M)
				continue
			is_in_use = 1
			src.interact(M)
		in_use = is_in_use

/obj/proc/interact(mob/user)
	return

/obj/singularity_act()
	if(flags & INVULNERABLE)
		return
	ex_act(1)
	if(src)
		qdel(src)
	return 2

/obj/shuttle_act(datum/shuttle/S)
	return qdel(src)

/obj/singularity_pull(S, current_size)
	if(anchored)
		if(current_size >= STAGE_FIVE)
			anchored = 0
			step_towards(src, S)
	else
		step_towards(src, S)

/obj/proc/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	return "<b>NO MULTITOOL_MENU!</b>"

/obj/proc/linkWith(var/mob/user, var/obj/buffer, var/link/context)
	return 0

/obj/proc/unlinkFrom(var/mob/user, var/obj/buffer)
	return 0

/obj/proc/canLink(var/obj/O, var/link/context)
	return 0

/obj/proc/isLinkedWith(var/obj/O)
	return 0

/obj/proc/getLink(var/idx)
	return null

/obj/proc/canClone(var/obj/O)
	return 0

/obj/proc/clone(var/obj/O)
	return 0

/obj/proc/linkMenu(var/obj/O)
	var/dat=""
	if(canLink(O, list()))
		dat += " <a href='?src=\ref[src];link=1'>\[Link\]</a> "
	return dat

/obj/proc/format_tag(var/label,var/varname, var/act="set_tag")
	var/value = vars[varname]
	if(!value || value=="")
		value="-----"
	return "<b>[label]:</b> <a href=\"?src=\ref[src];[act]=[varname]\">[value]</a>"


/obj/proc/update_multitool_menu(mob/user as mob)
	var/obj/item/device/multitool/P = get_multitool(user)

	if(!istype(P))
		return 0

	// Cloning stuff goes here.
	if(P.clone && P.buffer) // Cloning is on.
		if(!canClone(P.buffer))
			to_chat(user, "<span class='attack'>A red light flashes on \the [P]; you cannot clone to this device!</span>")
			return

		if(!clone(P.buffer))
			to_chat(user, "<span class='attack'>A red light flashes on \the [P]; something went wrong when cloning to this device!</span>")
			return

		to_chat(user, "<span class='confirm'>A green light flashes on \the [P], confirming the device was cloned to.</span>")
		return

	var/dat = {"<html>
	<head>
		<title>[name] Configuration</title>
		<style type="text/css">
html,body {
	font-family:courier;
	background:#999999;
	color:#333333;
}

a {
	color:#000000;
	text-decoration:none;
	border-bottom:1px solid black;
}
		</style>
	</head>
	<body>
		<h3>[name]</h3>
"}
	dat += multitool_menu(user,P)
	if(P)
		if(P.buffer)
			var/id = null
			if(istype(P.buffer, /obj/machinery/telecomms))
				var/obj/machinery/telecomms/buffer = P.buffer//Casting is better than using colons
				id = buffer.id
			else if(P.buffer.vars["id_tag"])//not doing in vars here incase the var is empty, it'd show ()
				id = P.buffer:id_tag//sadly, : is needed

			dat += "<p><b>MULTITOOL BUFFER:</b> [P.buffer] [id ? "([id])" : ""]"//If you can't into the ? operator, that will make it not display () if there's no ID.

			dat += linkMenu(P.buffer)

			if(P.buffer)
				dat += "<a href='?src=\ref[src];flush=1'>\[Flush\]</a>"
			dat += "</p>"
		else
			dat += "<p><b>MULTITOOL BUFFER:</b> <a href='?src=\ref[src];buffer=1'>\[Add Machine\]</a></p>"
	dat += "</body></html>"
	user << browse(dat, "window=mtcomputer")
	user.set_machine(src)
	onclose(user, "mtcomputer")

/obj/update_icon()
	return

/mob/proc/unset_machine()
	if(machine)
		if(machine._using)
			machine._using -= src

			if(!machine._using.len)
				machine._using = null

		machine = null

/mob/proc/set_machine(const/obj/O)
	unset_machine()

	if(istype(O))
		machine = O

		if(!machine._using)
			machine._using = new

		machine._using += src
		machine.in_use = 1

/obj/proc/wrenchAnchor(var/mob/user, var/time_to_wrench=30) //proc to wrench an object that can be secured
	for(var/obj/other in loc) //ensure multiple things aren't anchored in one place
		if(other.anchored == 1 && other.density == 1 && density && !anchored && !(other.flags & ON_BORDER))
			to_chat(user, "\The [other] is already anchored in this location.")
			return -1
	if(!anchored)
		if(!istype(src.loc, /turf/simulated/floor)) //Prevent from anchoring shit to shuttles / space
			if(istype(src.loc, /turf/simulated/shuttle) && !can_wrench_shuttle()) //If on the shuttle and not wrenchable to shuttle
				to_chat(user, "<span class = 'notice'>You can't secure \the [src] to this!</span>")
				return -1
			if(istype(src.loc, /turf/space)) //if on a space tile
				to_chat(user, "<span class = 'notice'>You can't secure \the [src] to space!</span>")
				return -1
	user.visible_message(	"[user] begins to [anchored ? "unbolt" : "bolt"] \the [src] [anchored ? "from" : "to" ] the floor.",
							"You begin to [anchored ? "unbolt" : "bolt"] \the [src] [anchored ? "from" : "to" ] the floor.")
	playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
	if(do_after(user, src, time_to_wrench))
		anchored = !anchored
		user.visible_message(	"<span class='notice'>[user] [anchored ? "wrench" : "unwrench"]es \the [src] [anchored ? "in place" : "from its fixture"]</span>",
								"<span class='notice'>[bicon(src)] You [anchored ? "wrench" : "unwrench"] \the [src] [anchored ? "in place" : "from its fixture"].</span>",
								"<span class='notice'>You hear a ratchet.</span>")
		return 1
	return -1

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)


/obj/proc/alter_health()
	return 1

/obj/proc/hide(h)
	return

/obj/proc/container_resist()
	return

/obj/proc/can_pickup(mob/living/user)
	return 0

/obj/proc/verb_pickup(mob/living/user)
	return 0

/obj/proc/can_quick_store(var/obj/item/I) //proc used to check that the current object can store another through quick equip
	return 0

/obj/proc/quick_store(var/obj/item/I) //proc used to handle quick storing
	return 0

/**
 * Called when a mob inside this obj's contents logs out.
 */
/obj/proc/on_logout(var/mob/M)
	if(isobj(loc))
		var/obj/location = loc
		location.on_logout(M)

/**
 * Called when a mob inside this obj's contents logs in.
 */
/obj/proc/on_login(var/mob/M)
	if(isobj(loc))
		var/obj/location = loc
		location.on_login(M)

// Dummy to give items special techlist for the purposes of the Device Analyser, in case you'd ever need them to give them different tech levels depending on special checks.
/obj/proc/give_tech_list()
	return null

/obj/acidable()
	return !(flags & INVULNERABLE)

/obj/proc/t_scanner_expose()
	if (level != LEVEL_BELOW_FLOOR)
		return

	if (invisibility == 101)
		invisibility = 0

		spawn(1 SECONDS)
			var/turf/U = loc
			if(istype(U) && U.intact)
				invisibility = 101

/obj/proc/become_defective()
	if(!defective)
		defective = 1
		desc += "\nIt doesn't look to be in the best shape."

/obj/proc/clumsy_check(var/mob/living/user)
	if(istype(user))
		return (M_CLUMSY in user.mutations)
	return 0
