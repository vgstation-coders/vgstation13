/datum/clockcult_power/belligerent
	name				= "Belligerent"
	desc				= "The user begins chanting loudly, forcing non-cultists in earshot to walk. The user may not do anything aside from chant while this is being done. Enemy cultists receive slight damage in addition to the debuff. After ending the chant, the user is knocked down for two seconds."

	invocation			= "Chav�fu urn�gura y�vtug!"
	cast_time			= 0 SECONDS
	loudness			= CLOCK_CHANTED
	req_components		= list(CLOCK_BELLIGERENT = 1)

/datum/clockcult_power/belligerent/activate(var/mob/user, var/obj/item/clockslab/C, var/list/participants)
    // Make it so other people can't bump the user, so you don't have derps fucking up the do_after().
    user.mob_bump_flags = 0
    user.anchored       = 0

    // Sure we'll use do_after, and after every tick of do_after we'll make sure everybody's slow.
    while(do_after(user, delay = 1))
        for(var/mob/living/carbon/C in hearers(user))
            if(isclockcult(C))
                continue

            var/datum/status_effect/belligerent_slowdown/B = locate() in C.status_effects
            if(B)
                B.
