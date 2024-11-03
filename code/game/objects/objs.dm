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
	var/smoking = FALSE //is the obj emitting smoke particles
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

	//Can we wrench/weld this to a turf with a dense /obj on it?
	var/can_affix_to_dense_turf=0

	var/list/alphas_obj = list()
	var/impactsound
	var/current_glue_state = GLUE_STATE_NONE
	var/last_glue_application = 0

	//Does this item have slimes installed? Bitflag for each type.
	var/has_slimes = 0
	var/slimeadd_message = "You add the slime extract to SRCTAG"
	var/slimeadd_success_message
	var/slimes_accepted = 0

	var/on_armory_manifest = FALSE // Does this get included in the armory manifest paper?
	var/holds_armory_items = FALSE // Does this check inside the object for stuff to include?

	//Cooking stuff:
	var/is_cooktop //If true, the object can be used in conjunction with a cooking vessel, eg. a frying pan, to cook food.
	var/obj/item/weapon/reagent_containers/pan/cookvessel //The vessel being used to cook food in. If generalized out to other types of vessels, make sure to also generalize the frying pan's cook_start(), etc. as well.

	//Is the object covered in ash?
	var/ash_covered = FALSE

/obj/New()
	..()
	if(breakable_flags)
		breakable_init()
	if(is_cooktop)
		add_component(/datum/component/cooktop)
	if(!thermal_mass)
		switch(w_class)
			if(W_CLASS_TINY, W_CLASS_SMALL)
				thermal_mass = 0.1
			if(W_CLASS_MEDIUM)
				thermal_mass = 1.0
			if(W_CLASS_LARGE)
				thermal_mass = 5.0
			if(W_CLASS_HUGE)
				thermal_mass = 20.0
			if(W_CLASS_GIANT)
				thermal_mass = 50.0
	if(thermal_mass)
		initial_thermal_mass = thermal_mass
	if(flammable)
		var/turf/simulated/T = get_turf(src)
		if(istype(T))
			T.zone?.burnable_atoms |= src

//More cooking stuff:
/obj/proc/can_cook() //Returns true if object is currently in a state that would allow for food to be cooked on it (eg. the grill is currently powered on). Can (and generally should) be overriden to check for more specific conditions.
	if(is_cooktop)
		return TRUE
	return FALSE

/obj/proc/can_receive_cookvessel() //Returns true if object is currently in a state that would allow for a cooking vessel to be placed on or in it (eg. there's not already something being grilled). Can (and generally should) be overriden to check for more specific conditions.
	//Doesn't need to check for there already being a cooking vessel, as that is already handled separately by the cooktop component.
	return TRUE

/obj/proc/on_cook_start() //Anything that needs to be done when we start cooking something.
	return

/obj/proc/on_cook_stop() //Anything that needs to be done when we stop cooking something.
	return

/obj/proc/render_cookvessel(offset_x, offset_y) //Called whenever we want to visibly render the cooking vessel.
	if(cookvessel)
		var/image/cookvesselimage = image(cookvessel)
		cookvesselimage.pixel_x = offset_x
		cookvesselimage.pixel_y = offset_y
		overlays += cookvesselimage
		adjust_particles(PVAR_POSITION, list(offset_x,offset_y))
	else
		adjust_particles(PVAR_POSITION, 0)

/obj/proc/cook_temperature() //Returns the temperature the object cooks at.
	return COOKTEMP_DEFAULT

/obj/proc/cook_energy() //Returns the energy transferred to the reagents in the cooking vessel per process() tick of the cooking vessel. Cooking vessels use the fast objects subsystem.
	return 500 //Half that of fire_act().

/obj/proc/generate_available_recipes(flags = COOKABLE_WITH_ALL)
	var/list/recipes = list()
	for(var/type in (typesof(/datum/recipe) - /datum/recipe))
		var/datum/recipe/thisrecipe = new type
		if((thisrecipe.cookable_with & flags) && ispath(thisrecipe.result)) //Check that the recipe is cookable with the given method, and also that the recipe isn't a base type with no result.
			recipes += thisrecipe
	return recipes

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
		QDEL_NULL(integratedpai)

	material_type = null //Don't qdel, they're held globally
	if(associated_forward)
		associated_forward = null
	..()

/obj/item/proc/is_used_on(obj/O, mob/user)

/obj/proc/blocks_doors(var/obj/machinery/door/D)
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
	
	if(emag_check(W,user))
		. = 1
			
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
		QDEL_NULL(pAImove_delayer)
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

/obj/clean_act(var/cleanliness)
	..()
	if (cleanliness >= CLEANLINESS_WATER)
		unglue()
		ash_covered = FALSE

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

/obj/item/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		if(usr)
			_using |= usr
		if(_using && _using.len)
			for(var/mob/M in _using) // Only check things actually messing with us.
				if (!M || !M.client || !in_range(loc,M))  // NOT ON MOB
					_using.Remove(M)
					continue
				is_in_use = 1
				src.attack_self(M)

		// check for TK users
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

/obj/suicide_act(var/mob/living/user)
	if (is_hot())
		user.visible_message("<span class='danger'>[user] is immolating \himself on \the [src]! It looks like \he's trying to commit suicide.</span>")
		user.ignite()
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

/obj/ignite()
	if(..())
		ash_covered = TRUE
		remove_particles(PS_SMOKE)

/obj/item/checkburn()
	if(!flammable)
		CRASH("[src] tried to burn despite not being flammable!")
	if(on_fire)
		return
	if(!smoking)
		checksmoke()
	..()

/obj/item/proc/checksmoke()
	var/datum/gas_mixture/G = return_air()
	if(!G)
		return
	while(G.temperature >= (autoignition_temperature * 0.75))
		if(!G)
			break
		if(!smoking)
			add_particles(PS_SMOKE)
			smoking = TRUE
		var/rate = clamp(lerp(G.temperature,autoignition_temperature * 0.75,autoignition_temperature,0.1,1),0.1,1)
		adjust_particles(PVAR_SPAWNING,rate,PS_SMOKE)
		sleep(10 SECONDS)
		G = return_air()
	remove_particles(PS_SMOKE)
	smoking = FALSE

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
	if(has_slimes & primarytype)
		to_chat(user, "\the [src] already has this kind of slime extract attached.")
		return FALSE
	has_slimes |= primarytype
	slimeadd_message = replacetext(slimeadd_message,"SRCTAG","\the [src]")
	to_chat(user, "[slimeadd_message][slimeadd_success_message && (slimes_accepted & primarytype) ? ". [slimeadd_success_message]" : ""].")
	return TRUE

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
	if(ash_covered)
		cut_overlay(charred_overlay)
		process_charred_overlay()
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

/client
	var/last_quick_stored = 0

/obj/proc/quick_store(var/obj/item/I,mob/user) //proc used to handle quick storing
	if(user?.client)
		user.client.last_quick_stored = world.time
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

/obj/dissolvable()
	if (flags & INVULNERABLE)
		return FALSE
	else
		return PACID

/obj/proc/t_scanner_expose()
	//don't reveal docking ports or spawns
	if(invisibility > 0 && invisibility < INVISIBILITY_OBSERVER || alpha < 255)
		var/old_invisibility = invisibility
		var/old_alpha = alpha
		invisibility = 0
		alpha = 255

		spawn(1 SECONDS)
			var/turf/U = loc
			if(istype(U) && U.intact)
				invisibility = old_invisibility
				alpha = old_alpha

/obj/proc/become_defective()
	if(!defective)
		defective = 1
		desc += "\nIt doesn't look to be in the best shape."

/obj/proc/clumsy_check(var/mob/living/user)
	if(istype(user))
		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			return HAS_MODULE_QUIRK(R, MODULE_IS_A_CLOWN)
		return (M_CLUMSY in user.mutations) || (user.reagents?.has_reagent(INCENSE_BANANA)) || (user.reagents?.has_reagent(HONKSERUM)) || arcanetampered
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
	alphas_obj[source_define] = alpha_value
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
	if(src && alphas_obj[source_define])
		invisibility = 0
		alphas_obj.Remove(source_define)
		handle_alpha()
		if(ismob(loc))
			var/mob/M = loc
			M.regenerate_icons()

/obj/proc/handle_alpha()	//uses the lowest alpha on the mob
	if(alphas_obj.len < 1)
		alpha = 255
	else
		sortTim(alphas_obj, /proc/cmp_numeric_asc,1)
		alpha = alphas_obj[alphas_obj[1]]

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

/obj/proc/dorfify(var/datum/material/mat, var/additional_quality, var/min_quality = 0)
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
				var/datum/organ/external/foot = H.has_vulnerable_foot()
				if(foot)
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

/obj/proc/build_list_of_contents() //used by microwaves and frying pans
	var/dat = ""
	var/list/items_counts = new
	var/list/items_measures = new
	var/list/items_measures_p = new
	for (var/obj/O in contents)
		var/display_name = O.name
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/meat)) //any meat
			items_measures[display_name] = "slab of meat"
			items_measures_p[display_name] = "slabs of meat"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat))
			items_measures[display_name] = "fillet of fish"
			items_measures_p[display_name] = "fillets of fish"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg))
			items_measures[display_name] = "egg"
			items_measures_p[display_name] = "eggs"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/tofu))
			items_measures[display_name] = "tofu chunk"
			items_measures_p[display_name] = "tofu chunks"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/donkpocket))
			display_name = "Turnovers"
			items_measures[display_name] = "turnover"
			items_measures_p[display_name] = "turnovers"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans))
			items_measures[display_name] = "soybean"
			items_measures_p[display_name] = "soybeans"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown/grapes))
			display_name = "Grapes"
			items_measures[display_name] = "bunch of grapes"
			items_measures_p[display_name] = "bunches of grapes"
		if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes))
			display_name = "Green Grapes"
			items_measures[display_name] = "bunch of green grapes"
			items_measures_p[display_name] = "bunches of green grapes"
		if (istype(O,/obj/item/weapon/kitchen/utensil)) //any spoons, forks, knives, etc
			items_measures[display_name] = "utensil"
			items_measures_p[display_name] = "utensils"
		items_counts[display_name]++
	for (var/O in items_counts)
		var/N = items_counts[O]
		if (!(O in items_measures))
			dat += {"<B>[capitalize(O)]:</B> [N] [lowertext(O)]\s<BR>"}
		else
			if (N==1)
				dat += {"<B>[capitalize(O)]:</B> [N] [items_measures[O]]<BR>"}
			else
				dat += {"<B>[capitalize(O)]:</B> [N] [items_measures_p[O]]<BR>"}

	for (var/datum/reagent/R in reagents.reagent_list)
		var/display_name = R.name
		if (R.id == CAPSAICIN)
			display_name = "Hotsauce"
		if (R.id == FROSTOIL)
			display_name = "Coldsauce"
		dat += {"<B>[display_name]:</B> [R.volume] unit\s<BR>"}
	return dat

/obj/get_heat_conductivity() //So keeping something in a closet can have an insulating effect.
	return 0.5

//This subtype is used by stuff that should generally not be disturbed by those procs
/obj/abstract
	anchored = TRUE
/obj/abstract/cultify()
	return
/obj/abstract/ex_act()
	return
/obj/abstract/emp_act()
	return
/obj/abstract/blob_act()
	return
/obj/abstract/singularity_act()
	return
