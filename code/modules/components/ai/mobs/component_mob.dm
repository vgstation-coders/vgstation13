/**
 * Component-driven mob.
 *
 * See /datum/component and /datum/component_container.
 */
/mob/living/component

/mob/living/component/New()
	..()
	BrainContainer = new (src)
	InitializeComponents()

/mob/living/component/proc/InitializeComponents()
	// Set up components here
	//var/datum/component/.../ref = container.AddComponent(/datum/component/...)