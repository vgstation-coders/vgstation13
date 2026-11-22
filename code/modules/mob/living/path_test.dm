/mob/living/clickbot
	name = "pathfinder"
	desc = "A small robot used for traversing derelict stations in search of valuables."
	icon = 'icons/mob/robots.dmi'
	icon_state = "spiderbot-chassis"
	var/list/path = list()

/mob/living/clickbot/ClickOn(var/atom/A, var/params)
	path = get_path_to(src, A, diagonally = TRUE) // clickbot follows with step_to, which can move diagonally
	if (!length(path))
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return
	pathers += src

/mob/living/clickbot/process_path_step()
	if(gcDestroyed || stat == DEAD || !length(path))
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

/mob/living/clickbot/drop_path()
	path.Cut()
	.=..()
