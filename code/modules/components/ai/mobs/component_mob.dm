/**
 * Component-driven mob.
 *
 * See /datum/component and /datum/component_container.
 */
/mob/living/component
	var/datum/component_container/container

/mob/living/component/New()
	..()
	container = new (src)
	InitializeComponents()

/mob/living/component/proc/InitializeComponents()
	// Set up components here
	//var/datum/component/.../ref = container.AddComponent(/datum/component/...)

/mob/living/component/Life()
	..()
	container.SendSignal(COMSIG_LIFE,list())


/mob/living/component/Destroy()
	qdel(container)
	..()
