/datum/component/controller/mob
	var/walk_delay=4

/datum/component/controller/mob/Initialize()
	..()
	RegisterSignal(parent, COMSIG_CLICKON, .proc/on_clickon)
	RegisterSignal(parent, COMSIG_STEP, .proc/on_step)

/datum/component/controller/mob/proc/on_clickon(var/atom/A, var/def_zone)
	var/params
	if(def_zone)
		params = list2params(list("def_zone" = def_zone))
	var/mob/parent = src.parent
	parent.ClickOn(A, params)

/datum/component/controller/mob/proc/on_step(var/dir)
	step(parent, dir, walk_delay)

