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
	var/source_temperature = 0
	var/price = 0

	var/in_use = 0 // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!

	var/damtype = "brute"
	var/force = 0

	//Should we alert about reagents that should be logged?
	var/log_reagents = 1

	var/list/mob/_using // All mobs dicking with us.

	// Shit for mechanics. (MECH_*)
	var/mech_flags=0

	plane = OBJ_PLANE

	var/defective = 0
	var/quality = B_AVERAGE //What level of quality this object is.
	var/datum/material/material_type //What material this thing is made out of
	var/event/on_use
	var/sheet_type = /obj/item/stack/sheet/metal
	var/sheet_amt = 1
	var/can_take_pai = FALSE
	var/obj/item/device/paicard/integratedpai = null
	var/datum/delay_controller/pAImove_delayer = new(1, ARBITRARILY_LARGE_NUMBER)
	var/pAImovement_delay = 0

	// Can we wrench/weld this to a turf with a dense /obj on it?
	var/can_affix_to_dense_turf=0

	var/has_been_invisible_sprayed = FALSE
	var/impactsound

// Whether this object can appear in holomaps
/obj/proc/supports_holomap()
	return FALSE

/obj/proc/add_self_to_holomap()
	var/turf/T = loc
	if(istype(T) && ticker && ticker.current_state != GAME_STATE_PLAYING)
		T.add_holomap(src)

/obj/New()
	..()
	on_use = new(owner=src)

/obj/Destroy()
	for(var/mob/user in _using)
		user.unset_machine()

	if(src in processing_objects)
		processing_objects -= src

	if(integratedpai)
		qdel(integratedpai)
		integratedpai = null
	if(on_use)
		on_use.holder = null
		qdel(on_use)
		on_use = null

	material_type = null //Don't qdel, they're held globally
	..()

/obj/item/proc/is_used_on(obj/O, mob/user)


/obj/proc/install_pai(obj/item/device/paicard/P)
	if(!P || !istype(P))
		return 0
	P.forceMove(src)
	integratedpai = P
	verbs += /obj/proc/remove_pai

/obj/attackby(obj/item/weapon/W, mob/user)
	if(can_take_pai && istype(W, /obj/item/device/paicard))
		if(integratedpai)
			to_chat(user, "<span class = 'notice'>There's already a Personal AI inserted.</span>")
			return

		if(user.drop_item(W))
			to_chat(user, "You insert \the [W] into a slot in \the [src].")
			install_pai(W)
			state_controls_pai(W)
			playsound(src, 'sound/misc/cartridge_in.ogg', 25)
	if(W)
		INVOKE_EVENT(W.on_use, list("user" = user, "target" = src))
		if(W.material_type)
			W.material_type.on_use(W, src, user)

/obj/proc/state_controls_pai(obj/item/device/paicard/P)			//text the pAI receives when is inserted into something. EXAMPLE: to_chat(P.pai, "Welcome to your new body")
	if(P.pai)
		return 1
	return 0

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
		user.last_movement=world.time
		return 0
	else
		delayNextpAIMove(getpAIMovementDelay())
		if (user.client.prefs.stumble && ((world.time - user.last_movement) > 5) && getpAIMovementDelay() < 2)
			delayNextpAIMove(3)	//if set, delays the second step when a mob starts moving to attempt to make precise high ping movement easier
		user.last_movement=world.time
		return 1

/obj/proc/getpAIMovementDelay()
	return pAImovement_delay

/obj/proc/delayNextpAIMove(var/delay, var/additive=0)
	pAImove_delayer.delayNext(delay,additive)

/obj/proc/on_integrated_pai_click(mob/living/silicon/pai/user, var/atom/A)
	if(istype(A,/obj/machinery)||(istype(A,/mob)&&user.secHUD))
		A.attack_pai(user)

/obj/proc/remove_pai()
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
	M.put_in_hands(eject_integratedpai_if_present())
	playsound(src, 'sound/misc/cartridge_out.ogg', 25)

/obj/proc/eject_integratedpai_if_present()
	if(integratedpai)
		integratedpai.forceMove(get_turf(src))
		verbs -= /obj/proc/remove_pai
		var/obj/item/device/paicard/P = integratedpai
		integratedpai = null
		return P
	return 0

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

/obj/proc/clockworkify()
	return

/obj/proc/wrenchable()
	return 0

/obj/proc/can_wrench_shuttle()
	return 0

/obj/proc/is_sharp()
	return sharpness

/obj/is_hot() //This returns the temperature of the object if possible
	return source_temperature

/obj/thermal_energy_transfer()
	if(is_hot())
		return heat_production
	return 0

/obj/proc/process()
	set waitfor = FALSE
	processing_objects.Remove(src)

//At some point, this proc should be changed to work like remove_air() below does.
//However, this would likely cause problems, such as CO2 buildup in mechs and spacepods, so I'm not doing it right now.
/obj/assume_air(datum/gas_mixture/giver)
	if(loc)
		return loc.assume_air(giver)
	else
		return null

/obj/remove_air(amount)
	var/datum/gas_mixture/my_air = return_air()
	return my_air?.remove(amount)

/obj/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/obj/proc/handle_internal_lifeform(mob/lifeform_inside_me, breath_vol)
	if(breath_vol > 0)
		var/datum/gas_mixture/G = return_air()
		return G.remove_volume(breath_vol)
	else
		return null

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		if(_using && _using.len)
			var/list/nearby = viewers(1, src) + loc //List of nearby things includes the location - allows you to call this proc on items and such
			for(var/mob/M in _using) // Only check things actually messing with us.
				if (!M || !M.client)
					_using.Remove(M)
					continue

				// AIs/Robots can do shit from afar.
				if (isAI(M) || isrobot(M) || isAdminGhost(M))
					is_in_use = 1
					src.attack_ai(M)

				else if(!(M in nearby)) // NOT NEARBY
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

/obj/proc/linkWith(var/mob/user, var/obj/buffer, var/list/context)
	return 0

/obj/proc/unlinkFrom(var/mob/user, var/obj/buffer)
	return 0

/obj/proc/canLink(var/obj/O, var/list/context)
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

/** Returns 1 or 0 depending on whether the machine can be affixed to this position.
 * Used to determine whether other density=1 things are on this tile.
 * @param user Tool user
 * @return bool Can affix here
 */
/obj/proc/canAffixHere(var/mob/user)
	if(density==0 || can_affix_to_dense_turf)
		return TRUE// Non-dense things just don't care. Same with can_affix_to_dense_turf=TRUE objects.
	for(var/obj/other in loc) //ensure multiple things aren't anchored in one place
		if(other.anchored == 1 && other.density == 1 && density && !anchored && !(other.flow_flags & ON_BORDER) && !(istype(other,/obj/structure/table)))
			to_chat(user, "\The [other] is already anchored in this location.")
			return FALSE // NOPE
	return TRUE

/** Anchors shit to the deck via wrench.
 * @param user The mob doing the wrenching
 * @param time_to_wrench The time to complete the wrenchening
 * @returns TRUE on success, FALSE on fail
 */
/obj/proc/wrenchAnchor(var/mob/user, var/time_to_wrench = 3 SECONDS) //proc to wrench an object that can be secured
	if(!canAffixHere(user))
		return FALSE
	if(!anchored)
		if(!istype(src.loc, /turf/simulated/floor)) //Prevent from anchoring shit to shuttles / space
			if(istype(src.loc, /turf/simulated/shuttle) && !can_wrench_shuttle()) //If on the shuttle and not wrenchable to shuttle
				to_chat(user, "<span class = 'notice'>You can't secure \the [src] to this!</span>")
				return FALSE
			if(istype(src.loc, /turf/space)) //if on a space tile
				to_chat(user, "<span class = 'notice'>You can't secure \the [src] to space!</span>")
				return FALSE
	user.visible_message(	"[user] begins to [anchored ? "unbolt" : "bolt"] \the [src] [anchored ? "from" : "to" ] the floor.",
							"You begin to [anchored ? "unbolt" : "bolt"] \the [src] [anchored ? "from" : "to" ] the floor.")
	playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
	if(do_after(user, src, time_to_wrench))
		if(!canAffixHere(user))
			return FALSE
		anchored = !anchored
		user.visible_message(	"<span class='notice'>[user] [anchored ? "wrench" : "unwrench"]es \the [src] [anchored ? "in place" : "from its fixture"]</span>",
								"<span class='notice'>[bicon(src)] You [anchored ? "wrench" : "unwrench"] \the [src] [anchored ? "in place" : "from its fixture"].</span>",
								"<span class='notice'>You hear a ratchet.</span>")
		return TRUE
	return FALSE

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
		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			return HAS_MODULE_QUIRK(R, MODULE_IS_A_CLOWN)
		return (M_CLUMSY in user.mutations) || user.reagents.has_reagent(INCENSE_BANANA)
	return 0

//Proc that handles NPCs (gremlins) "tampering" with this object.
//Return NPC_TAMPER_ACT_FORGET if there's no interaction (the NPC won't try to tamper with this again)
//Return NPC_TAMPER_ACT_NOMSG if you don't want to create a visible_message
/obj/proc/npc_tamper_act(mob/living/L)
	return NPC_TAMPER_ACT_FORGET

/obj/actual_send_to_future(var/duration)
	var/turf/current_turf = get_turf(src)
	var/datum/current_loc = loc
	forceMove(null)

	..()

	if(!current_loc.gcDestroyed)
		forceMove(current_loc)
	else
		forceMove(current_turf)

/obj/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"sharpness",
		"integratedpai")

	reset_vars_after_duration(resettable_vars, duration)

//Called when a mob in our locked atoms list kicks another object. Return 1 if successful, to abort the rest of the kicking action.
/obj/proc/onBuckledUserKick(var/mob/living/user, var/atom/A)
	if(!anchored && !user.incapacitated() && user.has_limbs) //if you're buckled onto a non-anchored object (like office chairs) you harmlessly push yourself away with your legs
		spawn() //return 1 first thing
			var/movementdirection = turn(get_dir(src,A),180)
			if(user.get_strength() > 1) //hulk KICK!
				user.visible_message("<span class='danger'>[user] puts \his foot to \the [A] and kicks \himself away!</span>", \
					"<span class='warning'>You put your foot to \the [A] and kick as hard as you can! [pick("RAAAAAAAARGH!", "HNNNNNNNNNGGGGGGH!", "GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", "AAAAAAARRRGH!")]</span>")
				var/turf/T = get_edge_target_turf(src, movementdirection)
				src.throw_at(T,8,20,fly_speed = 2)
			else
				user.visible_message("<span class='warning'>[user] kicks \himself away from \the [A].</span>", "<span class='notice'>You kick yourself away from \the [A]. Wee!</span>")
				for(var/i in list(2,2,3,3))
					set_glide_size(DELAY2GLIDESIZE(i))
					if(!step(src, movementdirection))
						change_dir(turn(movementdirection, 180)) //stop, but don't turn around when hitting a wall
						break
					change_dir(turn(movementdirection, 180)) //face away from where we're going
					sleep(i)
		return 1

/obj/make_invisible(var/source_define, var/time, var/include_clothing)
	if(..() || !source_define)
		return
	alpha = 1
	if(source_define == INVISIBLESPRAY)
		has_been_invisible_sprayed = TRUE
	if(ismob(loc))
		var/mob/M = loc
		M.regenerate_icons()
	if(time > 0)
		spawn(time)
			alpha = initial(alpha)
			has_been_invisible_sprayed = FALSE
			if(ismob(loc))
				var/mob/M = loc
				M.regenerate_icons()

/obj/proc/gen_quality(var/modifier = 0, var/min_quality = 0, var/datum/material/mat)
	var/material_mod = mat ? mat.quality_mod : material_type ? material_type.quality_mod : 1
	var/surrounding_mod = 1
	/* - Probably better we find a better way of checking the quality of a room, like an area-level variable for room quality, and cleanliness
	var/turf/T = get_turf(src)
	for(var/dir in alldirs)
		for(var/obj/I in get_step(T, dir))
			if(I.quality > NORMAL || I.quality < NORMAL)
				surrounding_mod *= I.quality/rand(1,3)
	*/
	var/initial_quality = round(((rand(1,3)*surrounding_mod)*material_mod)+modifier)
	quality = Clamp(initial_quality, B_AWFUL>min_quality?B_AWFUL:min_quality, B_LEGENDARY)

/obj/proc/gen_description(mob/user)
	var/material_mod = quality-B_GOOD>1 ? quality-B_GOOD : 0
	var/additional_description
	if(material_mod)
		additional_description = "On \the [src] is a carving, it depicts:\n"
		var/list/characters = list()
		for(var/i = 1 to material_mod)
			if(prob(50)) //We're gonna use an atom
				var/atom/AM = pick(existing_typesof(/mob/living/simple_animal))
				characters |= initial(AM.name)
			else
				var/strangething = pick("captain","clown","mime","\improper CMO","cargo technician","medical doctor","[user ? user : "stranger"]","octopus","changeling","\improper Nuclear Operative", "[pick("greyshirt", "greytide", "assistant")]", "xenomorph","catbeast","[user && user.mind && user.mind.heard_before.len ? pick(user.mind.heard_before) : "strange thing"]","Central Command","\improper Ian","[ticker.Bible_deity_name]","Nar-Sie","\improper Poly the Parrot","\improper Wizard","vox")
				characters |= strangething
			additional_description += "[i == material_mod ? " & a " : "[i > 1 ? ", a ": " A "]"][characters[i]]"
		additional_description += ". They are in \the [pick("captains office","Space","mining outpost","vox outpost","a space station","[station_name()]","bar","kitchen","library","Science","void","Bluespace","Hell","Central Command")]"
		if(material_mod > 2)
			additional_description += ". They are [pick("[pick("fighting","robusting","attacking","beating up", "abusing")] [pick("each other", pick(characters))]","playing cards","firing lasers at [pick("something",pick(characters))]","crying","laughing","blank faced","screaming","cooking [pick("something", pick(characters))]", "eating [pick("something", pick(characters))]")]. "
		if(characters.len > 1)
			for(var/i in characters)
				additional_description += "\The [i] is [pick("laughing","crying","screaming","naked","very naked","angry","jovial","manical","melting","fading away","making a plaintive gesture")]. "
		additional_description += "The scene gives off a feeling of [pick("unease","empathy","fear","malice","dread","happiness","strangeness","insanity","drol")]. "
		additional_description += "It is accented in hues of [pick("red","orange","yellow","green","blue","indigo","violet","white","black","cinnamon")]. "
	if(additional_description)
		desc = "[initial(desc)] \n [additional_description]"

/obj/proc/dorfify(var/datum/material/mat, var/additional_quality, var/min_quality)
	if(mat)
		/*var/icon/original = icon(icon, icon_state) Icon operations keep making mustard gas
		if(mat.color)
			original.ColorTone(mat.color)
			var/obj/item/I = src
			if(istype(I))
				var/icon/t_state
				for(var/hand in list("left_hand", "right_hand"))
					t_state = icon(I.inhand_states[hand], I.item_state)
					t_state.ColorTone(mat.color)
					I.inhand_states[hand] = t_state
		else if(mat.color_matrix)
			color = mat.color_matrix
		icon = original*/
		alpha = mat.alpha
		material_type = mat
		sheet_type = mat.sheettype
	gen_quality(additional_quality, min_quality)
	if(quality > B_SUPERIOR)
		gen_description()
	if(!findtext(lowertext(name), lowertext(mat.name)))
		name = "[quality == B_AVERAGE ? "": "[lowertext(qualityByString[quality])] "][lowertext(mat.name)] [name]"

/obj/proc/check_uplink_validity()
	return TRUE

//Return true if thrown object misses
/obj/PreImpact(atom/movable/A, speed)
	if(density && !throwpass)
		return FALSE
	return TRUE

/obj/proc/FeetStab(mob/living/AM,var/soundplay = 'sound/effects/glass_step.ogg',var/damage = 5,var/knockdown = 3)
	if(istype(AM))
		if(AM.locked_to) //Mob is locked to something, so it's not actually stepping on the glass
			playsound(src, soundplay, 50, 1)
			return
		if(AM.flying)
			return
		else //Stepping on the glass
			playsound(src, soundplay, 50, 1)
			if(ishuman(AM))
				var/mob/living/carbon/human/H = AM
				var/danger = FALSE

				var/datum/organ/external/foot = H.pick_usable_organ(LIMB_LEFT_FOOT, LIMB_RIGHT_FOOT)
				if(!H.organ_has_mutation(foot, M_STONE_SKIN) && !H.check_body_part_coverage(FEET))
					if(foot.is_organic())
						danger = TRUE

						if(!H.lying && H.feels_pain())
							H.Knockdown(knockdown)
							H.Stun(knockdown)
						if(foot.take_damage(damage, 0))
							H.UpdateDamageIcon()
						H.updatehealth()

				to_chat(AM, "<span class='[danger ? "danger" : "notice"]'>You step in \the [src]!</span>")
