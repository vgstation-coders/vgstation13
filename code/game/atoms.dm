/atom
	layer = TURF_LAYER
	plane = GAME_PLANE
	var/level = 2

	var/flags_1 = NONE
	var/flags_2 = NONE
	var/interaction_flags_atom = NONE
	var/container_type = NONE
	var/admin_spawned = 0	//was this spawned by an admin? used for stat tracking stuff.
	var/datum/reagents/reagents = null

	//This atom's HUD (med/sec, etc) images. Associative list.
	var/list/image/hud_list = null
	//HUD images that this atom can provide.
	var/list/hud_possible

	//Value used to increment ex_act() if reactionary_explosions is on
	var/explosion_block = 0

	var/list/atom_colours	 //used to store the different colors on an atom
							//its inherent color, the colored paint applied on it, special color effect etc...
	var/initialized = FALSE

	var/list/our_overlays	//our local copy of (non-priority) overlays without byond magic. Use procs in SSoverlays to manipulate
	var/list/priority_overlays	//overlays that should remain on top and not normally removed when using cut_overlay functions, like c4.

	var/datum/proximity_monitor/proximity_monitor
	var/buckle_message_cooldown = 0
	var/fingerprintslast

/atom/New(loc, ...)
	//atom creation method that preloads variables at creation
	if(GLOB.use_preloader && (src.type == GLOB._preloader.target_path))//in case the instanciated atom is creating other atoms in New()
		GLOB._preloader.load(src)

	if(datum_flags & DF_USE_TAG)
		GenerateTag()

	var/do_initialize = SSatoms.initialized
	if(do_initialize != INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, args))
			//we were deleted
			return

	var/list/created = SSatoms.created_atoms
	if(created)
		created += src

//Called after New if the map is being loaded. mapload = TRUE
//Called from base of New if the map is not being loaded. mapload = FALSE
//This base must be called or derivatives must set initialized to TRUE
//must not sleep
//Other parameters are passed from New (excluding loc), this does not happen if mapload is TRUE
//Must return an Initialize hint. Defined in __DEFINES/subsystems.dm

//Note: the following functions don't call the base for optimization and must copypasta:
// /turf/Initialize
// /turf/open/space/Initialize

/atom/proc/Initialize(mapload, ...)
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	//atom color stuff
	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)

	if (light_power && light_range)
		update_light()

	if (opacity && isturf(loc))
		var/turf/T = loc
		T.has_opaque_atom = TRUE // No need to recalculate it in this case, it's guaranteed to be on afterwards anyways.

	ComponentInitialize()

	return INITIALIZE_HINT_NORMAL

//called if Initialize returns INITIALIZE_HINT_LATELOAD
/atom/proc/LateInitialize()
	return

// Put your AddComponent() calls here
/atom/proc/ComponentInitialize()
	return

/atom/Destroy()
	if(alternate_appearances)
		for(var/K in alternate_appearances)
			var/datum/atom_hud/alternate_appearance/AA = alternate_appearances[K]
			AA.remove_from_hud(src)

	if(reagents)
		qdel(reagents)

	LAZYCLEARLIST(overlays)
	LAZYCLEARLIST(priority_overlays)

	QDEL_NULL(light)

	return ..()

/atom/proc/handle_ricochet(obj/item/projectile/P)
	return

/atom/proc/CanPass(atom/movable/mover, turf/target)
	return !density

/atom/proc/onCentCom()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	if(is_transit_level(T.z))
		for(var/A in SSshuttle.mobile)
			var/obj/docking_port/mobile/M = A
			if(M.launch_status == ENDGAME_TRANSIT)
				for(var/place in M.shuttle_areas)
					var/area/shuttle/shuttle_area = place
					if(T in shuttle_area)
						return TRUE

	if(!is_centcom_level(T.z))//if not, don't bother
		return FALSE

	//Check for centcom itself
	if(istype(T.loc, /area/centcom))
		return TRUE

	//Check for centcom shuttles
	for(var/A in SSshuttle.mobile)
		var/obj/docking_port/mobile/M = A
		if(M.launch_status == ENDGAME_LAUNCHED)
			for(var/place in M.shuttle_areas)
				var/area/shuttle/shuttle_area = place
				if(T in shuttle_area)
					return TRUE

/atom/proc/onSyndieBase()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	if(!is_centcom_level(T.z))//if not, don't bother
		return FALSE

	if(istype(T.loc, /area/shuttle/syndicate) || istype(T.loc, /area/syndicate_mothership) || istype(T.loc, /area/shuttle/assault_pod))
		return TRUE

	return FALSE

/atom/proc/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	SendSignal(COMSIG_ATOM_HULK_ATTACK, user)
	if(does_attack_animation)
		user.changeNext_move(CLICK_CD_MELEE)
		add_logs(user, src, "punched", "hulk powers")
		user.do_attack_animation(src, ATTACK_EFFECT_SMASH)

/atom/proc/CheckParts(list/parts_list)
	for(var/A in parts_list)
		if(istype(A, /datum/reagent))
			if(!reagents)
				reagents = new()
			reagents.reagent_list.Add(A)
			reagents.conditional_update()
		else if(ismovableatom(A))
			var/atom/movable/M = A
			if(isliving(M.loc))
				var/mob/living/L = M.loc
				L.transferItemToLoc(M, src)
			else
				M.forceMove(src)

/atom/proc/assume_air(datum/gas_mixture/giver)
	qdel(giver)
	return null

/atom/proc/remove_air(amount)
	return null

/atom/proc/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/atom/proc/check_eye(mob/user)
	return


/atom/proc/CollidedWith(atom/movable/AM)
	set waitfor = FALSE
	return

// Convenience procs to see if a container is open for chemistry handling
/atom/proc/is_open_container()
	return is_refillable() && is_drainable()

/atom/proc/is_injectable(allowmobs = TRUE)
	return reagents && (container_type & (INJECTABLE | REFILLABLE))

/atom/proc/is_drawable(allowmobs = TRUE)
	return reagents && (container_type & (DRAWABLE | DRAINABLE))

/atom/proc/is_refillable()
	return reagents && (container_type & REFILLABLE)

/atom/proc/is_drainable()
	return reagents && (container_type & DRAINABLE)


/atom/proc/AllowDrop()
	return FALSE

/atom/proc/CheckExit()
	return 1

/atom/proc/HasProximity(atom/movable/AM as mob|obj)
	return

/atom/proc/emp_act(severity)
	SendSignal(COMSIG_ATOM_EMP_ACT, severity)
	if(istype(wires) && !(flags_2 & NO_EMP_WIRES_2))
		wires.emp_pulse()

/atom/proc/bullet_act(obj/item/projectile/P, def_zone)
	SendSignal(COMSIG_ATOM_BULLET_ACT, P, def_zone)
	. = P.on_hit(src, 0, def_zone)

/atom/proc/in_contents_of(container)//can take class or object instance as argument
	if(ispath(container))
		if(istype(src.loc, container))
			return TRUE
	else if(src in container)
		return TRUE
	return FALSE

/atom/proc/get_examine_name(mob/user)
	. = "\a [src]"
	var/list/override = list(gender == PLURAL? "some" : "a" , " ", "[name]")
	if(SendSignal(COMSIG_ATOM_GET_EXAMINE_NAME, user, override) & COMPONENT_EXNAME_CHANGED)
		. = override.Join("")

/atom/proc/get_examine_string(mob/user, thats = FALSE)
	. = "[icon2html(src, user)] [thats? "That's ":""][get_examine_name(user)]"

/atom/proc/examine(mob/user)
	to_chat(user, get_examine_string(user, TRUE))

	if(desc)
		to_chat(user, desc)

	if(reagents)
		if(container_type & TRANSPARENT)
			to_chat(user, "It contains:")
			if(reagents.reagent_list.len)
				if(user.can_see_reagents()) //Show each individual reagent
					for(var/datum/reagent/R in reagents.reagent_list)
						to_chat(user, "[R.volume] units of [R.name]")
				else //Otherwise, just show the total volume
					var/total_volume = 0
					for(var/datum/reagent/R in reagents.reagent_list)
						total_volume += R.volume
					to_chat(user, "[total_volume] units of various reagents")
			else
				to_chat(user, "Nothing.")
		else if(container_type & AMOUNT_VISIBLE)
			if(reagents.total_volume)
				to_chat(user, "<span class='notice'>It has [reagents.total_volume] unit\s left.</span>")
			else
				to_chat(user, "<span class='danger'>It's empty.</span>")

	SendSignal(COMSIG_PARENT_EXAMINE, user)

/atom/proc/relaymove(mob/user)
	if(buckle_message_cooldown <= world.time)
		buckle_message_cooldown = world.time + 50
		to_chat(user, "<span class='warning'>You can't move while buckled to [src]!</span>")
	return

/atom/proc/contents_explosion(severity, target)
	return

/atom/proc/ex_act(severity, target)
	set waitfor = FALSE
	contents_explosion(severity, target)
	SendSignal(COMSIG_ATOM_EX_ACT, severity, target)

/atom/proc/blob_act(obj/structure/blob/B)
	SendSignal(COMSIG_ATOM_BLOB_ACT, B)
	return

/atom/proc/fire_act(exposed_temperature, exposed_volume)
	SendSignal(COMSIG_ATOM_FIRE_ACT, exposed_temperature, exposed_volume)
	return

/atom/proc/hitby(atom/movable/AM, skipcatch, hitpush, blocked)
	if(density && !has_gravity(AM)) //thrown stuff bounces off dense stuff in no grav, unless the thrown stuff ends up inside what it hit(embedding, bola, etc...).
		addtimer(CALLBACK(src, .proc/hitby_react, AM), 2)

/atom/proc/hitby_react(atom/movable/AM)
	if(AM && isturf(AM.loc))
		step(AM, turn(AM.dir, 180))

/atom/proc/handle_slip(mob/living/carbon/C, knockdown_amount, obj/O, lube)
	return

//returns the mob's dna info as a list, to be inserted in an object's blood_DNA list
/mob/living/proc/get_blood_dna_list()
	if(get_blood_id() != "blood")
		return
	return list("ANIMAL DNA" = "Y-")

/mob/living/carbon/get_blood_dna_list()
	if(get_blood_id() != "blood")
		return
	var/list/blood_dna = list()
	if(dna)
		blood_dna[dna.unique_enzymes] = dna.blood_type
	else
		blood_dna["UNKNOWN DNA"] = "X*"
	return blood_dna

/mob/living/carbon/alien/get_blood_dna_list()
	return list("UNKNOWN DNA" = "X*")

//to add a mob's dna info into an object's blood_DNA list.
/atom/proc/transfer_mob_blood_dna(mob/living/L)
	// Returns 0 if we have that blood already
	var/new_blood_dna = L.get_blood_dna_list()
	if(!new_blood_dna)
		return FALSE
	var/old_length = blood_DNA_length()
	add_blood_DNA(new_blood_dna)
	if(blood_DNA_length() == old_length)
		return FALSE
	return TRUE

//to add blood from a mob onto something, and transfer their dna info
/atom/proc/add_mob_blood(mob/living/M)
	var/list/blood_dna = M.get_blood_dna_list()
	if(!blood_dna)
		return FALSE
	return add_blood_DNA(blood_dna)

/atom/proc/wash_cream()
	return TRUE

/atom/proc/isinspace()
	if(isspaceturf(get_turf(src)))
		return TRUE
	else
		return FALSE

/atom/proc/handle_fall()
	return

/atom/proc/singularity_act()
	return

/atom/proc/singularity_pull(obj/singularity/S, current_size)
	SendSignal(COMSIG_ATOM_SING_PULL, S, current_size)

/atom/proc/acid_act(acidpwr, acid_volume)
	SendSignal(COMSIG_ATOM_ACID_ACT, acidpwr, acid_volume)

/atom/proc/emag_act()
	SendSignal(COMSIG_ATOM_EMAG_ACT)

/atom/proc/rad_act(strength)
	SendSignal(COMSIG_ATOM_RAD_ACT, strength)

/atom/proc/narsie_act()
	SendSignal(COMSIG_ATOM_NARSIE_ACT)

/atom/proc/ratvar_act()
	SendSignal(COMSIG_ATOM_RATVAR_ACT)

/atom/proc/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	return FALSE

/atom/proc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	SendSignal(COMSIG_ATOM_RCD_ACT, user, the_rcd, passed_mode)
	return FALSE

/atom/proc/storage_contents_dump_act(obj/item/storage/src_object, mob/user)
	return 0

/atom/proc/get_dumping_location(obj/item/storage/source,mob/user)
	return null

//This proc is called on the location of an atom when the atom is Destroy()'d
/atom/proc/handle_atom_del(atom/A)

//called when the turf the atom resides on is ChangeTurfed
/atom/proc/HandleTurfChange(turf/T)
	for(var/a in src)
		var/atom/A = a
		A.HandleTurfChange(T)

//the vision impairment to give to the mob whose perspective is set to that atom (e.g. an unfocused camera giving you an impaired vision when looking through it)
/atom/proc/get_remote_view_fullscreens(mob/user)
	return

//the sight changes to give to the mob whose perspective is set to that atom (e.g. A mob with nightvision loses its nightvision while looking through a normal camera)
/atom/proc/update_remote_sight(mob/living/user)
	return

/atom/proc/add_vomit_floor(mob/living/carbon/M, toxvomit = 0)
	if(isturf(src))
		var/obj/effect/decal/cleanable/vomit/V = new /obj/effect/decal/cleanable/vomit(src, M.get_static_viruses())
		// Make toxins vomit look different
		if(toxvomit)
			V.icon_state = "vomittox_[pick(1,4)]"
		if(M.reagents)
			clear_reagents_to_vomit_pool(M,V)

/atom/proc/clear_reagents_to_vomit_pool(mob/living/carbon/M, obj/effect/decal/cleanable/vomit/V)
	M.reagents.trans_to(V, M.reagents.total_volume / 10)
	for(var/datum/reagent/R in M.reagents.reagent_list)                //clears the stomach of anything that might be digested as food
		if(istype(R, /datum/reagent/consumable))
			var/datum/reagent/consumable/nutri_check = R
			if(nutri_check.nutriment_factor >0)
				M.reagents.remove_reagent(R.id,R.volume)


//Hook for running code when a dir change occurs
/atom/proc/setDir(newdir)
	SendSignal(COMSIG_ATOM_DIR_CHANGE, dir, newdir)
	dir = newdir

/atom/proc/mech_melee_attack(obj/mecha/M)
	return

//If a mob logouts/logins in side of an object you can use this proc
/atom/proc/on_log(login)
	if(loc)
		loc.on_log(login)


/*
	Atom Colour Priority System
	A System that gives finer control over which atom colour to colour the atom with.
	The "highest priority" one is always displayed as opposed to the default of
	"whichever was set last is displayed"
*/


/*
	Adds an instance of colour_type to the atom's atom_colours list
*/
/atom/proc/add_atom_colour(coloration, colour_priority)
	if(!atom_colours || !atom_colours.len)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(!coloration)
		return
	if(colour_priority > atom_colours.len)
		return
	atom_colours[colour_priority] = coloration
	update_atom_colour()


/*
	Removes an instance of colour_type from the atom's atom_colours list
*/
/atom/proc/remove_atom_colour(colour_priority, coloration)
	if(!atom_colours)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(colour_priority > atom_colours.len)
		return
	if(coloration && atom_colours[colour_priority] != coloration)
		return //if we don't have the expected color (for a specific priority) to remove, do nothing
	atom_colours[colour_priority] = null
	update_atom_colour()


/*
	Resets the atom's color to null, and then sets it to the highest priority
	colour available
*/
/atom/proc/update_atom_colour()
	if(!atom_colours)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	color = null
	for(var/C in atom_colours)
		if(islist(C))
			var/list/L = C
			if(L.len)
				color = L
				return
		else if(C)
			color = C
			return

/atom/vv_edit_var(var_name, var_value)
	if(!GLOB.Debug2)
		admin_spawned = TRUE
	. = ..()
	switch(var_name)
		if("color")
			add_atom_colour(color, ADMIN_COLOUR_PRIORITY)

/atom/vv_get_dropdown()
	. = ..()
	. += "---"
	var/turf/curturf = get_turf(src)
	if (curturf)
		.["Jump to"] = "?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[curturf.x];Y=[curturf.y];Z=[curturf.z]"
	.["Modify Transform"] = "?_src_=vars;[HrefToken()];modtransform=[REF(src)]"
	.["Add reagent"] = "?_src_=vars;[HrefToken()];addreagent=[REF(src)]"
	.["Trigger EM pulse"] = "?_src_=vars;[HrefToken()];emp=[REF(src)]"
	.["Trigger explosion"] = "?_src_=vars;[HrefToken()];explode=[REF(src)]"

/atom/proc/drop_location()
	var/atom/L = loc
	if(!L)
		return null
	return L.AllowDrop() ? L : get_turf(L)

/atom/Entered(atom/movable/AM, atom/oldLoc)
	SendSignal(COMSIG_ATOM_ENTERED, AM, oldLoc)

/atom/Exited(atom/movable/AM)
	SendSignal(COMSIG_ATOM_EXITED, AM)

/atom/proc/return_temperature()
	return

// Tool behavior procedure. Redirects to tool-specific procs by default.
// You can override it to catch all tool interactions, for use in complex deconstruction procs.
// Just don't forget to return ..() in the end.
/atom/proc/tool_act(mob/living/user, obj/item/I, tool_type)
	switch(tool_type)
		if(TOOL_CROWBAR)
			return crowbar_act(user, I)
		if(TOOL_MULTITOOL)
			return multitool_act(user, I)
		if(TOOL_SCREWDRIVER)
			return screwdriver_act(user, I)
		if(TOOL_WRENCH)
			return wrench_act(user, I)
		if(TOOL_WIRECUTTER)
			return wirecutter_act(user, I)
		if(TOOL_WELDER)
			return welder_act(user, I)

// Tool-specific behavior procs. To be overridden in subtypes.
/atom/proc/crowbar_act(mob/living/user, obj/item/I)
	return

/atom/proc/multitool_act(mob/living/user, obj/item/I)
	return

/atom/proc/screwdriver_act(mob/living/user, obj/item/I)
	return

/atom/proc/wrench_act(mob/living/user, obj/item/I)
	return

/atom/proc/wirecutter_act(mob/living/user, obj/item/I)
	return

/atom/proc/welder_act(mob/living/user, obj/item/I)
	return

/atom/proc/GenerateTag()
	return
