/datum/clockcult_power/vanguard
	name				= "Vanguard"
	desc				= "Blesses the user with stun immunity for 30 seconds, and makes them emanate a faint golden aura. At the end of the 30 seconds, the user is hit with the equivalent of however many stuns they received while protected by Vanguard."

	invocation			= "Qr’sraq zr fubeg!"
	cast_time			= 3 SECONDS
	req_components		= list(CLOCK_VANGUARD = 1)

/var/global/icon/clock_vanguard_overlay = icon('icons/mob/clockcult.dmi', "goldenglow")

/datum/clockcult_power/vanguard/activate(var/mob/user, var/obj/item/clockslab/C, var/list/participants)
	var/datum/status_effect/clock_vanguard/S = new
	user.add_status_effect(S)
	user.visible_message("<span class='notice'>[user] engulfs in a golden light!</span>")

/datum/status_effect/clock_vanguard
	var/total_stun
	var/total_weaken

	var/stun_key
	var/weaken_key

/datum/status_effect/clock_vanguard/Destroy()
	// Let's NOT catch the stuns we're gonna apply ourselves.
	our_mob.on_stun.Remove(stun_key)
	our_mob.on_weaken.Remove(weaken_key)

	our_mob.Stun(total_stun)
	our_mob.Weaken(total_weaken)
	our_mob.overlays -= global.clock_vanguard_overlay

	if(total_weaken)
		our_mob.visible_message("<span class='notice'>[our_mob] falls down as the golden light surrounding him dissapates!</span>")
	else
		our_mob.visible_message("<span class='notice'>The golden light surrounding [our_mob] dissapates!</span>")
	
	return ..()
	
/datum/status_effect/clock_vanguard/attach(var/mob/M)
	if(!ishuman(M))
		return

	. = ..()
	spawn()
		countdown()

	var/mob/living/carbon/human/H = M

	// Register at the event handlers.
	stun_key = H.on_stun.Add(src, "mob_stun")
	weaken_key = H.on_weaken.Add(src, "mob_weaken")

	our_mob.overlays += global.clock_vanguard_overlay

/datum/status_effect/clock_vanguard/proc/mob_stun(var/list/arg)
	our_mob.stunned = 0
	total_stun += arg["amount"]
	
/datum/status_effect/clock_vanguard/proc/mob_weaken(var/list/arg)
	our_mob.weakened = 0
	total_weaken += arg["amount"]
	
/datum/status_effect/clock_vanguard/proc/countdown()
	var/t = 0
	while(t <= 30 && our_mob) // This way we can check every second if we've been deleted, to prevent GCing from failing.
		sleep(1 SECONDS)
		t++

	qdel(src)
