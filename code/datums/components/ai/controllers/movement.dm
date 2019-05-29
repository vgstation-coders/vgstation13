/datum/component/controller/movement
	var/walk_delay = 4

/datum/component/controller/movement/Initialize()
	..()
	if(!isatommovable(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOVE, .proc/on_command_move)

/datum/component/controller/movement/proc/on_command_move(var/atom/where, var/direction)
	if(!isnull(where))
		walk_to(parent, where, 1, walk_delay)
	if(!isnull(direction))
		walk(parent, direction, walk_delay)

/datum/component/controller/movement/astar
	var/list/movement_nodes = list()
	var/target

/datum/component/controller/movement/astar/Initialize()
	. = ..()
	if(.)
		return
	RegisterSignal(parent, COMSIG_LIFE, .proc/on_life)

/datum/component/controller/movement/astar/on_command_move(var/atom/where, var/direction)
	var/mob/living/M = parent
	if(!isnull(where))
		if(where == target)
			return // We're already on our way there
		target = where
		movement_nodes = AStar(M, target, /turf/proc/AdjacentTurfsSpace, /turf/proc/Distance, 0, 30, id=M.get_visible_id())
	if(!isnull(direction))
		movement_nodes.Cut()
		walk(M, direction, walk_delay)

/datum/component/controller/movement/astar/proc/on_life()
	if(movement_nodes.len && target && (target != null))
		if(movement_nodes.len > 0)
			step_to(parent, movement_nodes[1])
			movement_nodes -= movement_nodes[1]
		else if(movement_nodes.len == 1)
			step_to(src, target)
			movement_nodes.Cut()
			return 1
