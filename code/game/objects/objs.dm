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

	var/w_class

	//Should we alert about reagents that should be logged?
	var/log_reagents = 1

	var/list/mob/_using // All mobs dicking with us.

	// Shit for mechanics. (MECH_*)
	var/mech_flags=0

	plane = OBJ_PLANE

	var/defective = 0
	var/quality = B_AVERAGE //What level of quality this object is.
	var/datum/material/material_type //What material this thing is made out of
	var/sheet_type = /obj/item/stack/sheet/metal
	var/sheet_amt = 1
	var/can_take_pai = FALSE
	var/obj/item/device/paicard/integratedpai = null
	var/datum/delay_controller/pAImove_delayer
	var/pAImovement_delay = 0

	// Can we wrench/weld this to a turf with a dense /obj on it?
	var/can_affix_to_dense_turf=0

	var/list/alphas = list()
	var/impactsound
	var/current_glue_state = GLUE_STATE_NONE

	// Does this item have a slime installed?
	var/has_slime = 0

// Whether this object can appear in holomaps
/obj/proc/supports_holomap()
	return FALSE

/obj/proc/add_self_to_holomap()
	var/turf/T = loc
	if(istype(T) && ticker && ticker.current_state != GAME_STATE_PLAYING)
		T.add_holomap(src)

/obj/Destroy()
	for(var/mob/user in _using)
		user.unset_machine()

	if(src in processing_objects)
		processing_objects -= src

	if(integratedpai)
		qdel(integratedpai)
		integratedpai = null

	material_type = null //Don't qdel, they're held globally
	if(associated_forward)
		associated_forward = null
	..()

/obj/item/proc/is_used_on(obj/O, mob/user)

/obj/proc/blocks_doors()
	return 0


/obj/proc/install_pai(obj/item/device/paicard/P)
	if(!P || !istype(P))
		return 0
	P.forceMove(src)
	integratedpai = P
	verbs += /obj/proc/remove_pai
	pAImove_delayer = new(1, ARBITRARILY_LARGE_NUMBER)

/obj/attackby(obj/item/weapon/W, mob/user)
	INVOKE_EVENT(src, /event/attackby, "attacker" = user, "item" = W)

	if(handle_item_attack(W, user))
		return

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

/obj/proc/pAImove(mob/living/user, dir)								//called when integrated pAI attempts to move
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
		qdel(pAImove_delayer)
		pAImove_delayer = null
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

/obj/map_element_rotate(var/angle)
	..()
	if(req_access_dir)
		req_access_dir = turn(req_access_dir, -angle)

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

				else if(ispulsedemon(M))
					is_in_use = 1
					src.attack_pulsedemon(M)

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
			// Not robot or AI, not nearby and not pulse demon?
			if(!isAI(M) && !isrobot(M) && !(M in nearby) && !ispulsedemon(M))
				_using.Remove(M)
				continue
			is_in_use = 1
			src.interact(M)
		in_use = is_in_use

/obj/proc/interact(mob/user)
	return

//user: The mob that is suiciding
//damagetype: The type of damage the item will inflict on the user
//SUICIDE_ACT_BRUTELOSS = 1
//SUICIDE_ACT_FIRELOSS = 2
//SUICIDE_ACT_TOXLOSS = 4
//SUICIDE_ACT_OXYLOSS = 8
//Output a creative message and then return the damagetype done
/obj/proc/suicide_act(var/mob/living/user)
	if (is_hot())
		user.visible_message("<span class='danger'>[user] is immolating \himself on \the [src]! It looks like \he's trying to commit suicide.</span>")
		user.IgniteMob()
		return SUICIDE_ACT_FIRELOSS
	else if (sharpness >= 1)
		user.visible_message("<span class='danger'>[user] impales himself on \the [src]! It looks like \he's trying to commit suicide.</span>")
		return SUICIDE_ACT_BRUTELOSS
	else if (force >= 10)
		if (prob(50))
			playsound(user, 'sound/items/trayhit1.ogg', 50, 1)
		else
			playsound(user, 'sound/items/trayhit2.ogg', 50, 1)
		user.visible_message("<span class='danger'>[user] strikes his head on \the [src]! It looks like \he's trying to commit suicide.</span>")
		return SUICIDE_ACT_BRUTELOSS

/obj/singularity_act()
	if(flags & INVULNERABLE)
		return
	ex_act(1)
	if(src)
		qdel(src)
	return 2

/obj/shuttle_act(datum/shuttle/S)
	return qdel(src)

/obj/slime_act(primarytype, mob/user)
	if(has_slime)
		to_chat(user, "\the [src] already has a slime extract attached.")
		return FALSE

/obj/singularity_pull(S, current_size, repel = FALSE)
	INVOKE_EVENT(src, /event/before_move)
	if(anchored)
		if(current_size >= STAGE_FIVE)
			anchored = 0
			if(!repel)
				step_towards(src, S)
			else
				step_away(src, S)
	else
		if(!repel)
			step_towards(src, S)
		else
			step_away(src, S)
	INVOKE_EVENT(src, /event/after_move)

/obj/proc/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	return "<b>NO MULTITOOL_MENU!</b>"

/obj/proc/linkWith(var/mob/user, var/obj/buffer, var/list/context)
	return 0

/obj/proc/shouldReInitOnMultitoolLink(var/mob/user, var/obj/buffer, var/list/context)
	return FALSE

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
	var/obj/machinery/bufRef = P.buffer?.get();
	if(P.clone && bufRef) // Cloning is on.
		if(!canClone(bufRef))
			to_chat(user, "<span class='attack'>A red light flashes on \the [P]; you cannot clone to this device!</span>")
			return

		if(!clone(bufRef))
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
		if(bufRef)
			var/id = null
			if(istype(bufRef, /obj/machinery/telecomms))
				var/obj/machinery/telecomms/buffer = bufRef//Casting is better than using colons
				id = buffer.id
			else if(bufRef.vars["id_tag"])//not doing in vars here incase the var is empty, it'd show ()
				id = bufRef:id_tag//sadly, : is needed

			dat += "<p><b>MULTITOOL BUFFER:</b> [bufRef] [id ? "([id])" : ""]"//If you can't into the ? operator, that will make it not display () if there's no ID.

			dat += linkMenu(bufRef)

			if(bufRef)
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
/obj/proc/wrenchAnchor(var/mob/user, var/obj/item/I, var/time_to_wrench = 3 SECONDS) //proc to wrench an object that can be secured
	if(!canAffixHere(user))
		return FALSE
	if(!anchored)
		if(!istype(src.loc, /turf/simulated/floor)) //Prevent from anchoring shit to shuttles / space
			if(isshuttleturf(src.loc) && !can_wrench_shuttle()) //If on the shuttle and not wrenchable to shuttle
				to_chat(user, "<span class = 'notice'>You can't secure \the [src] to this!</span>")
				return FALSE
			if(istype(src.loc, /turf/space)) //if on a space tile
				to_chat(user, "<span class = 'notice'>You can't secure \the [src] to space!</span>")
				return FALSE
	user.visible_message(	"[user] begins to [anchored ? "unbolt" : "bolt"] \the [src] [anchored ? "from" : "to" ] the floor.",
							"You begin to [anchored ? "unbolt" : "bolt"] \the [src] [anchored ? "from" : "to" ] the floor.")
	if(I)
		I.playtoolsound(loc, 50)
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
		return (M_CLUMSY in user.mutations) || user.reagents.has_reagent(INCENSE_BANANA) || user.reagents.has_reagent(HONKSERUM)
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
				src.throw_at(T, 8, 20, TRUE, 2)
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

/obj/proc/make_invisible(var/source_define, var/time = 0, var/alpha_value = 1, var/invisibility_value = 0)
	//INVISIBILITY_MAXIMUM is a value of 100 for invisibility_value
	//alpha_value = 1 hides the sprite
	if(invisibility || alpha <= 1 || !source_define)
		return
	invisibility = invisibility_value
	alphas[source_define] = alpha_value
	handle_alpha()
	if(ismob(loc))
		var/mob/M = loc
		M.regenerate_icons()
	if(time > 0)
		spawn(time)
			make_visible(source_define)

/obj/proc/make_visible(var/source_define)
	if(!invisibility && alpha == 255 || !source_define)
		return
	if(src)
		invisibility = 0
		alphas.Remove(source_define)
		handle_alpha()
		if(ismob(loc))
			var/mob/M = loc
			M.regenerate_icons()

/obj/proc/handle_alpha()	//uses the lowest alpha on the mob
	if(alphas.len < 1)
		alpha = 255
	else
		sortTim(alphas, /proc/cmp_numeric_asc,1)
		alpha = alphas[alphas[1]]

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
	quality = clamp(initial_quality, B_AWFUL>min_quality?B_AWFUL:min_quality, B_LEGENDARY)
	var/processed_name = lowertext(mat? mat.processed_name : material_type.processed_name)
	var/to_icon_state = "[initial(icon_state)]_[processed_name]_[quality]"
	if(has_icon(icon, to_icon_state))
		icon_state = to_icon_state

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
	if(material_type)
		if(sharpness_flags && sharpness)
			force = initial(force)*(material_type.sharpness_mod*(quality/B_AVERAGE))
			throwforce = initial(throwforce)*(material_type.sharpness_mod*(quality/B_AVERAGE))
			sharpness = initial(sharpness)*(material_type.sharpness_mod*(quality/B_AVERAGE))
		else
			force = initial(force)*(material_type.brunt_damage_mod*(quality/B_AVERAGE))
			throwforce = initial(throwforce)*(material_type.brunt_damage_mod*(quality/B_AVERAGE))
	if(!findtext(lowertext(name), lowertext(material_type.name)))
		name = "[quality == B_AVERAGE ? "": "[lowertext(qualityByString[quality])] "][lowertext(mat.name)] [name]"

/obj/proc/check_uplink_validity()
	return TRUE

//Return true if thrown object misses
/obj/PreImpact(atom/movable/A, speed)
	if(flow_flags & ON_BORDER) //If the object should hit this, it will just by normal collision detection.
		return ..()
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
				if(foot && !H.organ_has_mutation(foot, M_STONE_SKIN) && !H.check_body_part_coverage(FEET))
					if(foot.is_organic())
						danger = TRUE

						if(!H.lying && H.feels_pain())
							H.Knockdown(knockdown)
							H.Stun(knockdown)
						if(foot.take_damage(damage, 0))
							H.UpdateDamageIcon()
						H.updatehealth()

				to_chat(AM, "<span class='[danger ? "danger" : "notice"]'>You step in \the [src]!</span>")

/**
 * This proc is used for telling whether something can pass by this object in a given direction, for use by the pathfinding system.
 *
 * Trying to generate one long path across the station will call this proc on every single object on every single tile that we're seeing if we can move through, likely
 * multiple times per tile since we're likely checking if we can access said tile from multiple directions, so keep these as lightweight as possible.
 *
 * Arguments:
 * * ID- An ID card representing what access we have (and thus if we can open things like airlocks or windows to pass through them). The ID card's physical location does not matter, just the reference
 * * to_dir- What direction we're trying to move in, relevant for things like directional windows that only block movement in certain directions
 * * caller- The movable we're checking pass flags for, if we're making any such checks
 **/
/obj/proc/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, atom/movable/caller)
	if(istype(caller) && (caller.pass_flags & pass_flags_self))
		return TRUE
	. = !density

///////////////////////
// Breakable Objects //
//   by Hinaichigo   //
///////////////////////

/obj
	//Breakability:
	var/health		//Structural integrity of the object. If breakable_flags are set, at 0, the object breaks.
	var/maxHealth	//Maximum structural integrity of the object.
	var/breakable_flags 	//Flags for different situations the object can break in. See breakable_defines.dm for the full list and explanations of each.
	var/damage_armor		//Attacks of this much damage or below will glance off.
	var/damage_resist		//Attacks stronger than damage_armor will have their damage reduced by this much.
	var/list/breakable_exclude //List of objects that won't be used to hit the object even on harm intent, so as to allow for other interactions.
	//Fragmentation:
	var/list/breakable_fragments	//List of objects that will be produced when the object is broken apart. eg. /obj/item/weapon/shard.
	var/list/fragment_amounts		//List of the numbers of fragments of each object type in breakable_fragments to be dropped. Should be either null (1 each) or the same length as breakable_fragments.
	//Text:
	var/damaged_examine_text	//Addendum to the description when the object is damaged. eg. damaged_examine_text of "It is dented."
	var/take_hit_text 	//String or list of strings when the object is damaged but not fully broken. eg. "chipping" becomes "..., chipping it!"
	var/take_hit_text2	//String or list of strings for contexts like "cracks" becomes "the ... cracks!"
	var/glances_text	//String or list of strings when the object is attacked but the attack glances off. eg. "bounces" becomes "but it bounces off!"
	var/breaks_text		//Visible message when the object breaks. eg. "breaks apart"
	//Sounds:
	var/breaks_sound	//Audible sound when the object breaks apart. Defaults to damaged_sound if unset.
	var/damaged_sound	//Audible sound when the object is damaged by an attack, but not fully broken. Defaults to glanced_sound if unset.
	var/glanced_sound	//Audible sound when the object recives a glancing attack not strong enough to damage it.

/obj/New()
	..()
	if(breakable_flags)	//Initialize health and maxHealth to the same value if only one is specified.
		if(isnull(health) && maxHealth)
			health = maxHealth
		else if(isnull(maxHealth) && health)
			maxHealth = health

/obj/proc/on_broken(datum/throwparams/propelparams, atom/hit_atom) //Called right before an object breaks.
	//Drop and and propel any fragments:
	drop_fragments(propelparams)
	//Drop and propel any contents:
	drop_contents(propelparams)
	//Spill any reagents:
	spill_reagents(hit_atom)
	if(breaks_text)
		visible_message("<span class='warning'>\The [src] [breaks_text]!</span>")
	if(breaks_sound)
		playsound(src, breaks_sound, 50, 1)
	else if(damaged_sound)
		playsound(src, damaged_sound, 50, 1)

/obj/proc/drop_fragments(datum/throwparams/propelparams) //Drop the object's fragments and propel them if applicable with propelparams.
	if(breakable_fragments?.len)
		var/oneeach=(isnull(fragment_amounts) || breakable_fragments.len != fragment_amounts.len) //default to 1 of each fragment type if fragment_amounts isn't specified or there's a length mismatch
		var/numtodrop
		var/thisfragment
		for(var/frag_ind in 1 to breakable_fragments.len)
			if(oneeach)
				numtodrop=1
			else
				numtodrop=fragment_amounts[frag_ind]
			thisfragment=breakable_fragments[frag_ind]
			for(var/n in 1 to numtodrop)
				var/obj/O = new thisfragment (get_turf(src))
				//Transfer fingerprints, fibers, and bloodstains to the fragment.
				transfer_fingerprints(src,O)
				transfer_obj_blood_data(src,O)
				if(propelparams)//Propel the fragment if specified.
					if(propelparams.throw_target && propelparams.throw_range && propelparams.throw_speed)
						O.throw_at(propelparams.throw_target, propelparams.throw_range, propelparams.throw_speed, propelparams.throw_override, propelparams.throw_fly_speed)

/obj/proc/drop_contents(datum/throwparams/propelparams) //Drop the contents of the object and propel them if the object itself received a propulsive blow.
	if(contents.len)
		for(var/obj/item/thiscontent in contents)
			thiscontent.forceMove(src.loc)
			if(propelparams)
				if(propelparams.throw_target && propelparams.throw_range && propelparams.throw_speed) //Propel the content if specified.
					thiscontent.throw_at(propelparams.throw_target, propelparams.throw_range, propelparams.throw_speed, propelparams.throw_override, propelparams.throw_fly_speed)

/obj/proc/spill_reagents(atom/hit_atom) //Spill any reagents contained within the object onto the floor, and the atom it hit when it broke, if applicable.
	if(!isnull(reagents))
		if(!isnull(hit_atom) && hit_atom != get_turf(src)) //If it hit something other than the floor, spill it onto that.
			reagents.reaction(hit_atom, TOUCH)
		reagents.reaction(get_turf(src), TOUCH) //Then spill it onto the floor.

/obj/proc/take_damage(incoming_damage, damage_type = BRUTE, skip_break = FALSE, mute = TRUE)
	var/thisdmg = (incoming_damage > max(damage_armor, damage_resist)) * (incoming_damage - damage_resist) //damage is 0 if the incoming damage is less than either damage_armor or damage_resist, to prevent negative damage by weak attacks
	health -= thisdmg
	play_hit_sounds(thisdmg)
	if(thisdmg)
		if(health > 0) //Only if the object isn't ready to break.
			message_take_hit(mute)
		damaged_updates()
		if(!skip_break)
			try_break()
	return thisdmg //return the amount of damage taken

/obj/proc/play_hit_sounds(thisdmg, hear_glanced = TRUE, hear_damaged = TRUE) //Plays any relevant sounds whenever the object is hit. glanced_sound overrides damaged_sound if the latter is not set or hear_damaged is set to FALSE.
	if(health <= 0) //Don't play a sound here if the object is ready to break, because sounds are also played by on_broken().
		return
	if(thisdmg && damaged_sound && hear_damaged)
		playsound(src, damaged_sound, 50, 1)
	else if(glanced_sound && hear_glanced)
		playsound(src, glanced_sound, 50, 1)

/obj/proc/message_take_hit(mute = FALSE) //Give a visible message when the object takes damage.
	if(!isnull(take_hit_text2) && !mute)
		visible_message("<span class='warning'>\The [src] [pick(take_hit_text2)]!</span>")

/obj/proc/damaged_updates() //Put any damage-related updates to the object here.
	return

/obj/examine(mob/user, size = "", show_name = TRUE, show_icon = TRUE)
	..()
	if(health<maxHealth && damaged_examine_text)
		user.simple_message("<span class='info'>[damaged_examine_text]</span>",\
			"<span class='notice'>It seems kinda messed up somehow.</span>")

/obj/proc/transfer_obj_blood_data(obj/A, obj/B)	//Transfers blood data from one object to another.
	if(!A || !B)
		return
	if(A.had_blood)
		B.blood_color = A.blood_color
		B.blood_DNA = A.blood_DNA
		B.had_blood = TRUE

/obj/item/transfer_obj_blood_data(obj/item/A, obj/item/B)
	..()
	if(!blood_overlays[B.type]) //If there isn't a precreated blood overlay make one
		B.generate_blood_overlay()
	if(B.blood_overlay != null) // Just if(blood_overlay) doesn't work.  Have to use isnull here.
		B.overlays.Remove(B.blood_overlay)
	else
		B.blood_overlay = blood_overlays[B.type]
	B.blood_overlay.color = B.blood_color
	B.overlays += B.blood_overlay

/obj/proc/generate_break_text(glanced = FALSE, suppress_glance_text) //Generates text for when an object is hit.
	if(glanced)
		if(suppress_glance_text)
			return "!"
		else if(glances_text)
			return ", but it [pick(glances_text)] off!"
		else
			return ", but it glances off!"
	else if(health > 0 && take_hit_text)
		return ", [pick(take_hit_text)] it!"
	else
		return "!" //Don't say "cracking it" if it breaks because on_broken() will subsequently say "The object shatters!"

/obj/proc/try_break(datum/throwparams/propelparams, hit_atom) //Breaks the object if its health is 0 or below. Passes throw-related parameters to on_broken() to allow for an object's fragments to be propelled upon breaking.
	if(!isnull(health) && health <= 0)
		on_broken(propelparams, hit_atom)
		qdel(src)
		return TRUE //Return TRUE if the object was broken
	else if(propelparams)
		throw_at(propelparams.throw_target, propelparams.throw_range, propelparams.throw_speed, propelparams.throw_override, propelparams.throw_fly_speed)
	return FALSE //Return FALSE if the object wasn't broken

/datum/throwparams //throw_at() input parameters as a datum to make function inputs neater
	var/throw_target
	var/throw_range
	var/throw_speed
	var/throw_override
	var/throw_fly_speed

/datum/throwparams/New(target, range, speed, override, fly_speed)
	throw_target = target
	throw_range = range
	throw_speed = speed
	throw_override = override
	throw_fly_speed = fly_speed

/obj/proc/get_total_scaled_w_class(scalepower=3) //Returns a scaled sum of the weight class of the object itself and all of its contents, if any.
	//scalepower raises the w_class of each object to that exponent before adding it to the total. This helps avoid things like a container full of tiny objects being heavier than it should.
	var/total_w_class = (isnull(w_class) ? W_CLASS_MEDIUM : w_class) ** scalepower
	if(!isnull(contents) && contents.len)
		for(var/obj/item/thiscontent in contents)
			total_w_class += (thiscontent.w_class ** scalepower)
	return total_w_class

/obj/proc/breakable_check_weapon(obj/item/this_weapon) //Check if a weapon isn't excluded from being used to attempt to break an object.
	if(breakable_exclude)
		for(var/obj/item/this_excl in breakable_exclude)
			if(istype(this_weapon, this_excl))
				return FALSE
	return TRUE

/obj/proc/valid_item_attack(obj/item/this_weapon, mob/user) //Check if an object is in valid circumstances to be attacked with a wielded weapon.
	if(user.a_intent == I_HURT && breakable_flags & BREAKABLE_WEAPON && breakable_check_weapon(this_weapon) && isturf(loc)) //Smash objects on the ground, but not in your inventory.
		return TRUE
	else
		return FALSE

/obj/proc/get_obj_kick_damage(mob/living/carbon/human/kicker, datum/organ/external/kickingfoot)
	if(!kickingfoot)
		kickingfoot = kicker.pick_usable_organ(LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT)
	var/damage = kicker.get_strength() * 5
	if(kicker.reagents && kicker.reagents.has_reagent(GYRO))
		damage += 5
	damage *= 1 + min(0,(kicker.size - SIZE_NORMAL)) //The bigger the kicker, the more damage
	var/obj/item/clothing/shoes/S = kicker.shoes
	if(istype(S))
		damage += S.bonus_kick_damage
	else if(kicker.organ_has_mutation(kickingfoot, M_TALONS)) //Not wearing shoes and having talons = bonus damage
		damage += 3
	return damage

/////////////////////

//Breaking objects:

//Attacking the object with a wielded weapon or other item

/obj/proc/handle_item_attack(obj/item/W, mob/user)
	if(isobserver(user) || !Adjacent(user) || user.is_in_modules(src))
		return FALSE
	if(valid_item_attack(W, user))
		user.do_attack_animation(src, W)
		user.delayNextAttack(1 SECONDS)
		add_fingerprint(user)
		var/glanced=!take_damage(W.force, skip_break = TRUE)
		if(W.hitsound)
			playsound(src, W.hitsound, 50, 1)
		user.visible_message("<span class='warning'>\The [user] [pick(W.attack_verb)] \the [src] with \the [W][generate_break_text(glanced,TRUE)]</span>","<span class='notice'>You hit \the [src] with \the [W][generate_break_text(glanced)]<span>")
		try_break()
		//Break the weapon as well, if applicable, based on its own force.
		if(W.breakable_flags & BREAKABLE_AS_MELEE)
			W.take_damage(min(W.force, BREAKARMOR_MEDIUM), skip_break = FALSE, mute = FALSE) //Cap it at BREAKARMOR_MEDIUM to avoid a powerful weapon also needing really strong armor to avoid breaking apart when used.
		return TRUE
	else
		return FALSE

//Simple animals attacking the object

/obj/attack_animal(mob/living/simple_animal/M)
	if(M.melee_damage_upper && M.a_intent == I_HURT && breakable_flags & BREAKABLE_UNARMED)
		M.do_attack_animation(src, M)
		M.delayNextAttack(1 SECONDS)
		var/glanced=!take_damage(rand(M.melee_damage_lower,M.melee_damage_upper), skip_break = TRUE)
		if(M.attack_sound)
			playsound(src, M.attack_sound, 50, 1)
		M.visible_message("<span class='warning'>\The [M] [M.attacktext] \the [src][generate_break_text(glanced,TRUE)]</span>","<span class='notice'>You hit \the [src][generate_break_text(glanced)]</span>")
		try_break()
	else
		. = ..()

//Object ballistically colliding with something

/obj/throw_impact(atom/impacted_atom, speed, mob/user)
	..()
	if(!(breakable_flags & BREAKABLE_AS_THROWN))
		return
	if(!(breakable_flags & BREAKABLE_MOB) && istype(impacted_atom, /mob)) //Don't break when it hits a mob if it's not flagged with BREAKABLE_MOB
		return
	if(isturf(loc)) //Don't take damage if it was caught mid-flight.
		//Unless the object falls to the floor unobstructed, impacts happens twice, once when it hits the target, and once when it falls to the floor.
		var/thisdmg = 5 * get_total_scaled_w_class(1) / (speed ? speed : 1) //impact damage scales with the weight class and speed of the object. since a smaller speed is faster, it's a divisor.
		if(istype(impacted_atom, /turf/simulated/floor))
			take_damage(thisdmg/2, skip_break = TRUE)
		else
			take_damage(thisdmg, skip_break = TRUE, mute = FALSE) //Be verbose about the object taking damage.
		try_break(null, impacted_atom)

//Something ballistically colliding with the object

/obj/hitby(atom/movable/AM)
	. = ..()
	if(.)
		return
	if(breakable_flags & BREAKABLE_HIT)
		var/thisdmg = 0
		if(ismob(AM))
			if(!(breakable_flags & BREAKABLE_MOB))
				return
			var/mob/thismob = AM
			thisdmg = thismob.size * 3 + 1
		else if(isobj(AM))
			var/obj/thisobj = AM
			thisdmg = max(thisobj.throwforce, thisobj.get_total_scaled_w_class(2) + 1)
		take_damage(thisdmg)

//Object being hit by a projectile

/obj/bullet_act(obj/item/projectile/proj)
	. = ..()
	var/impact_power = max(0,round((proj.damage_type == BRUTE) * (proj.damage / 3 - (get_total_scaled_w_class(3))))) //The range of the impact-throw is increased by the damage of the projectile, and decreased by the total weight class of the object.
	var/turf/T = get_edge_target_turf(loc, get_dir(proj.starting, proj.target))
	var/thispropel = new /datum/throwparams(T, impact_power, proj.projectile_speed)
	if(breakable_flags & BREAKABLE_WEAPON)
		take_damage(proj.damage, skip_break = TRUE)
	//Throw the object in the direction the projectile was traveling
		if(try_break(impact_power ? thispropel : null))
			return
	if(impact_power && !anchored)
		throw_at(T, impact_power, proj.projectile_speed)

//Kicking the object

/obj/kick_act/(mob/living/carbon/human/kicker)
	if(breakable_flags & BREAKABLE_UNARMED && kicker.can_kick(src))
		//Pick a random usable foot to perform the kick with
		var/datum/organ/external/foot_organ = kicker.pick_usable_organ(LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT)
		kicker.delayNextAttack(2 SECONDS) //Kicks are slow
		if((M_CLUMSY in kicker.mutations) && prob(20)) //Kicking yourself (or being clumsy) = stun
			kicker.visible_message("<span class='notice'>\The [kicker] trips while attempting to kick \the [src]!</span>", "<span class='userdanger'>While attempting to kick \the [src], you trip and fall!</span>")
			var/incapacitation_duration = rand(1,10)
			kicker.Knockdown(incapacitation_duration)
			kicker.Stun(incapacitation_duration)
			return
		var/attack_verb = "kick"
		var/recoil_damage = BREAKARMOR_FLIMSY
		if(kicker.reagents && kicker.reagents.has_reagent(GYRO))
			attack_verb = "roundhouse kick"
			recoil_damage = 0
		if(M_HULK in kicker.mutations)
			recoil_damage = 0
		//Handle shoes
		var/obj/item/clothing/shoes/S = kicker.shoes
		if(istype(S))
			S.on_kick(kicker, src)
		playsound(loc, "punch", 30, 1, -1)
		kicker.do_attack_animation(src, kicker)
		var/glanced = !take_damage(get_obj_kick_damage(kicker, foot_organ), skip_break = TRUE, mute = TRUE)
		kicker.visible_message("<span class='warning'>\The [kicker] [attack_verb]s \the [src][generate_break_text(glanced,TRUE)]</span>",
		"<span class='notice'>You [attack_verb] \the [src][generate_break_text(glanced)]</span>")
		var/kick_dir = get_dir(kicker, src)
		if(kicker.loc == loc)
			kick_dir = kicker.dir
		var/turf/T = get_edge_target_turf(loc, kick_dir)
		var/kick_power = max((kicker.get_strength() * 10 - (get_total_scaled_w_class(2))), 1) //The range of the kick is (strength)*10. Strength ranges from 1 to 3, depending on the kicker's genes. Range is reduced by w_class^2, and can't be reduced below 1.
		var/thispropel = new /datum/throwparams(T, kick_power, 1)
		if(kick_power < 6)
			kick_power = 0
			thispropel = null
		if(try_break(thispropel))
			recoil_damage = 0 //Don't take recoil damage if the item broke.
		else if(kick_power && !anchored)
			throw_at(T, kick_power, 1)
		if(recoil_damage) //Recoil damage to the foot.
			kicker.foot_impact(src, recoil_damage, ourfoot = foot_organ)
		Crossed(kicker)
	else
		. = ..()

//Biting the object

/obj/bite_act(mob/living/carbon/human/biter)
	if(breakable_flags & BREAKABLE_UNARMED && biter.can_bite(src))
		var/thisdmg = BREAKARMOR_FLIMSY
		var/attacktype = "bite"
		var/attacktype2 = "bites"
		if(biter.organ_has_mutation(LIMB_HEAD, M_BEAK)) //Beaks = stronger bites
			thisdmg += 4
		else
			var/datum/butchering_product/teeth/T = locate(/datum/butchering_product/teeth) in biter.butchering_drops
			if(!T?.amount)
				attacktype = "gum"
				attacktype2 = "gums"
				thisdmg = 1
		biter.do_attack_animation(src, biter)
		biter.delayNextAttack(1 SECONDS)
		var/glanced=!take_damage(thisdmg, skip_break = TRUE)
		biter.visible_message("<span class='warning'>\The [biter] [loc == biter ? "[attacktype2] down on" : "leans over and [attacktype2]"] \the [src]!</span>",
		"<span class='notice'>You [loc == biter ? "[attacktype] down on" : "lean over and [attacktype]"] \the [src][glanced ? "... ouch!" : "[generate_break_text()]"]</span>")
		try_break()
		if(glanced)
			//Damage the biter's mouth.
			biter.apply_damage(BREAKARMOR_FLIMSY, BRUTE, TARGET_MOUTH)
	else
		. = ..()

/////////////////////
