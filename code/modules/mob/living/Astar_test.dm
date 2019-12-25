/mob/living/clickbot
	name = "pathfinder"
	desc = "A small robot. used for traversing derelict stations in search of valuables"
	icon = 'icons/mob/robots.dmi'
	icon_state = "spiderbot-chassis"
	var/list/path = list()

/mob/living/clickbot/ClickOn(var/atom/A, var/params)
	path = make_astar_path(A)
	to_chat(world, "path [path.len]")

/mob/living/clickbot/process_astar_path()
	to_chat(world, "process astar path called.")
	if(gcDestroyed || stat == DEAD)
		to_chat(world, "we're dead")
		return FALSE
	to_chat(world, "[path[1]]")
	step_to(src, path[1])
	to_chat(world, "we stepped")
	path.Remove(path[1])
	if(!path.len)
		playsound(loc, 'sound/machines/ping.ogg', 50, 0)
		return FALSE
	return TRUE


/mob/living/clickbot/drop_astar_path()
	to_chat(world, "astar path dropped.")
	path.Cut()
	.=..()