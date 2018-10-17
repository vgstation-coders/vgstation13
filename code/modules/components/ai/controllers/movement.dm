/datum/component/controller/movement
	var/walk_delay = 4

/datum/component/controller/movement/basic/RecieveSignal(var/message_type, var/list/args)
	if(isliving(container.holder))
		var/mob/living/M=container.holder
		if(COMSIG_MOVE)
			if("loc" in args)
				M.start_walk_to(args["loc"], 1, walk_delay)
			if("dir" in args)
				M.set_glide_size(DELAY2GLIDESIZE(walk_delay))
				walk(M, args["dir"], walk_delay)

/datum/component/controller/movement/astar
	var/list/movement_nodes = list()
	var/target

/datum/component/controller/movement/astar/RecieveSignal(var/message_type, var/list/args)
	if(isliving(container.holder))
		var/mob/living/M=container.holder
		if(message_type == COMSIG_MOVE)
			if("loc" in args)
				if(args["loc"] == target)
					return //We're already on our way there
				target = args["loc"]
				movement_nodes = AStar(M, target, /turf/proc/AdjacentTurfsSpace, /turf/proc/Distance, 0, 30, id=M.get_visible_id())
			if("dir" in args)
				movement_nodes = list()
				walk(M, args["dir"], walk_delay)
		if(message_type == COMSIG_LIFE)
			if(movement_nodes && movement_nodes.len && target && (target != null))
				if(movement_nodes.len > 0)
					step_to(M, movement_nodes[1])
					movement_nodes -= movement_nodes[1]
				else if(movement_nodes.len == 1)
					step_to(src, target)
					movement_nodes.Cut()
					return 1
