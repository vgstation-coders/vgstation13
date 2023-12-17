/* Using the HUD procs is simple. Call these procs in the life.dm of the intended mob.
Use the regular_hud_updates() proc before process_med_hud(mob) or process_sec_hud(mob) so
the HUD updates properly! */

/proc/process_med_hud(var/mob/M)
	return

/proc/process_sec_hud(var/mob/M, var/advanced = 0)
	return

/proc/process_diagnostic_hud(var/mob/M)
	return

//Artificer HUD
/proc/process_construct_hud(var/mob/M, var/mob/eye)
	return
