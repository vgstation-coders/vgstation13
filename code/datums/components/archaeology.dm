/datum/component/archaeology
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/archdrops
	var/prob2drop
	var/dug
	var/datum/callback/callback

/datum/component/archaeology/Initialize(_prob2drop, list/_archdrops = list(), datum/callback/_callback)
	prob2drop = CLAMP(_prob2drop, 0, 100)
	archdrops = _archdrops
	callback = _callback
	RegisterSignal(COMSIG_PARENT_ATTACKBY,.proc/Dig)
	RegisterSignal(COMSIG_ATOM_EX_ACT, .proc/BombDig)
	RegisterSignal(COMSIG_ATOM_SING_PULL, .proc/SingDig)

/datum/component/archaeology/InheritComponent(datum/component/archaeology/A, i_am_original)
	var/list/other_archdrops = A.archdrops
	var/list/_archdrops = archdrops
	for(var/I in other_archdrops)
		_archdrops[I] += other_archdrops[I]

/datum/component/archaeology/proc/Dig(obj/item/I, mob/living/user)
	if(dug)
		to_chat(user, "<span class='notice'>Looks like someone has dug here already.</span>")
		return

	if(!isturf(user.loc))
		return

	if(I.tool_behaviour == TOOL_SHOVEL || I.tool_behaviour == TOOL_MINING)
		to_chat(user, "<span class='notice'>You start digging...</span>")

		if(I.use_tool(parent, user, 40, volume=50))
			to_chat(user, "<span class='notice'>You dig a hole.</span>")
			gets_dug()
			dug = TRUE
			SSblackbox.record_feedback("tally", "pick_used_mining", 1, I.type)
			return COMPONENT_NO_AFTERATTACK

/datum/component/archaeology/proc/gets_dug()
	if(dug)
		return
	else
		var/turf/open/OT = get_turf(parent)
		for(var/thing in archdrops)
			var/maxtodrop = archdrops[thing]
			for(var/i in 1 to maxtodrop)
				if(prob(prob2drop)) // can't win them all!
					new thing(OT)

		if(isopenturf(OT))
			if(OT.postdig_icon_change)
				if(istype(OT, /turf/open/floor/plating/asteroid/) && !OT.postdig_icon)
					var/turf/open/floor/plating/asteroid/AOT = parent
					AOT.icon_plating = "[AOT.environment_type]_dug"
					AOT.icon_state = "[AOT.environment_type]_dug"
				else
					if(isplatingturf(OT))
						var/turf/open/floor/plating/POT = parent
						POT.icon_plating = "[POT.postdig_icon]"
						POT.icon_state = "[OT.postdig_icon]"

			if(OT.slowdown) //Things like snow slow you down until you dig them.
				OT.slowdown = 0
	dug = TRUE
	if(callback)
		callback.Invoke()

/datum/component/archaeology/proc/SingDig(S, current_size)
	switch(current_size)
		if(STAGE_THREE)
			if(prob(30))
				gets_dug()
		if(STAGE_FOUR)
			if(prob(50))
				gets_dug()
		else
			if(current_size >= STAGE_FIVE && prob(70))
				gets_dug()

/datum/component/archaeology/proc/BombDig(severity, target)
	switch(severity)
		if(3)
			return
		if(2)
			if(prob(20))
				gets_dug()
		if(1)
			gets_dug()
