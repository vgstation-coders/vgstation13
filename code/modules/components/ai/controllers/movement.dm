/datum/component/controller/movement
	var/walk_delay = 4

/datum/component/controller/movement/initialize()
	parent.register_event(/event/comp_ai_cmd_move, src, nameof(src::cmd_move()))
	return TRUE

/datum/component/controller/movement/Destroy()
	parent.unregister_event(/event/comp_ai_cmd_move, src, nameof(src::cmd_move()))
	..()

/datum/component/controller/movement/proc/cmd_move(target)
	CRASH("not implemented")

/datum/component/controller/movement/basic/cmd_move(target)
	var/mob/living/dude = parent
	if(isatom(target))
		dude.start_walk_to(target, 1, walk_delay)
	else if(isnum(target))
		dude.set_glide_size(DELAY2GLIDESIZE(walk_delay))
		walk(dude, target, walk_delay)
	else
		CRASH("target [target] is not an atom or a dir")
/datum/component/controller/movement/astar
	var/list/movement_nodes = list()
	var/target

/datum/component/controller/movement/astar/initialize()
	active_components += src
	return ..()

/datum/component/controller/movement/astar/Destroy()
	active_components -= src
	..()

/datum/component/controller/movement/astar/cmd_move(target)
	var/mob/living/dude = parent
	if(isatom(target))
		if(src.target == target)
			return //We're already on our way there
		src.target = target
		walk_to(dude, target, 0, walk_delay)
	else if(isnum(target))
		movement_nodes = list()
		dude.set_glide_size(DELAY2GLIDESIZE(walk_delay))
		walk(dude, target, walk_delay)
	else
		CRASH("target [target] is not an atom or a dir")

/datum/component/controller/movement/astar/process()
	if(movement_nodes && movement_nodes.len && target)
		if(movement_nodes.len > 0)
			step_to(parent, movement_nodes[1])
			movement_nodes -= movement_nodes[1]
		else if(movement_nodes.len == 1)
			step_to(parent, target)
			movement_nodes.Cut()
			return 1

/datum/component/controller/movement/astar/proc/receive_path(var/list/L)
	if(islist(L))
		movement_nodes = L
