/mob/living/clickbot
	name = "pathfinder"
	desc = "A small robot used for traversing derelict stations in search of valuables."
	icon = 'icons/mob/robots.dmi'
	icon_state = "spiderbot-chassis"
	var/list/path = list()

/mob/living/clickbot/ClickOn(var/atom/A, var/params)
	make_astar_path(A)

/mob/living/clickbot/make_astar_path(var/atom/target, var/receiving_proc = .get_astar_path)
	AStar(src, receiving_proc, get_turf(src), target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 30, 30, debug = TRUE)


/mob/living/clickbot/get_astar_path(var/list/L)
	.=..()
	if(.)
		path = .

/mob/living/clickbot/process_astar_path()
	if(gcDestroyed || stat == DEAD)
		return FALSE
	step_to(src, path[1])
	if(get_turf(src) != path[1])
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return FALSE
	path.Remove(path[1])
	if(!path.len)
		playsound(loc, 'sound/machines/ping.ogg', 50, 0)
		return FALSE
	return TRUE


/mob/living/clickbot/drop_astar_path()
	path.Cut()
	.=..()
