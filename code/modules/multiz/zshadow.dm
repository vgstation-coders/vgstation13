/mob/zshadow
	plane = OVER_OPENSPACE_PLANE
	name = "shadow"
	desc = "Z-level shadow"
	status_flags = GODMODE
	anchored = 1
	density = 0
	opacity = 0					// Don't trigger lighting recalcs gah! TODO - consider multi-z lighting.
	//auto_init = FALSE 		// On Polaris, this is supposed to prevent initialization but I can't find evidence it actually works over there.
	var/mob/owner = null		// What we are a shadow of.

/mob/zshadow/acidable()
	return 0

/mob/zshadow/can_fall()
	return FALSE

/mob/zshadow/New(var/mob/L)
	if(!istype(L))
		qdel(src)
		return
	..() // I'm cautious about this, but its the right thing to do.
	owner = L
	sync_icon(L)

/mob/Destroy()
	if(zshadow)
		qdel(zshadow)
		zshadow = null
	. = ..()

/mob/zshadow/examine(mob/user, distance, infix, suffix)
	return owner.examine(user, distance, infix, suffix)

// This is the hear version used on Polaris. Keeping it here for reference.
/*/mob/zshadow/hear_say(var/message, var/verb = "says", var/datum/language/language = null, var/alt_name = "", var/italics = 0, var/mob/speaker = null, var/sound/speech_sound, var/sound_vol)
	if(speaker && speaker.z != src.z)
		return // Only relay speech on our acutal z, otherwise we might relay sounds that were themselves relayed up!
	if(isliving(owner))
		verb += " from above"
	return owner.hear_say(message, verb, language, alt_name, italics, speaker, speech_sound, sound_vol)*/

/mob/zshadow/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(speech.speaker && speech.speaker.z != src.z)
		return
	if(isliving(owner))
		//Wow, because of how our language.dm is formatted I think it would be quite troublesome to add "from above" here.
		owner.Hear(speech, rendered_speech)

/mob/zshadow/proc/sync_icon(var/mob/M)
	name = M.name
	icon = M.icon
	icon_state = M.icon_state
	//color = M.color
	color = "#848484"
	overlays = M.overlays
	transform = M.transform
	dir = M.dir
	if(zshadow)
		zshadow.sync_icon(src)

/mob/living/Move()
	. = ..()
	check_shadow()

/mob/living/forceMove(atom/destination,var/no_tp=0, var/harderforce = FALSE, glide_size_override = 0)
	. = ..()
	check_shadow()

//We don't need a separate proc for on_mob_jump because our admin jump verbs use forcemove

/mob/living/proc/check_shadow()
	var/mob/M = src
	if(isturf(M.loc))
		var/turf/simulated/open/OS = GetAbove(src)
		while(OS && istype(OS))
			if(!M.zshadow)
				M.zshadow = new /mob/zshadow(M)
			M.zshadow.forceMove(OS)
			M = M.zshadow
			OS = GetAbove(M)
	// The topmost level does not need a shadow!
	if(M.zshadow)
		qdel(M.zshadow)
		M.zshadow = null

//
// Handle cases where the owner mob might have changed its icon or overlays.
//

/mob/living/update_icons()
	. = ..()
	if(zshadow)
		zshadow.sync_icon(src)

// WARNING - the true carbon/human/update_icons does not call ..(), therefore we must sideways override this.
// But be careful, we don't want to screw with that proc.  So lets be cautious about what we do here.
/mob/living/carbon/human/update_icons()
	. = ..()
	if(zshadow)
		zshadow.sync_icon(src)

/mob/set_dir(new_dir)
	. = ..()
	if(zshadow)
		zshadow.set_dir(new_dir)

// Transfer messages about what we are doing to upstairs
//mob/visible_message(var/message, var/self_message, var/blind_message)
//we have more args on /vg/
//apparently it's okay to do this even though mob/visible_message is in mob.dm
/mob/visible_message(var/message, var/self_message, var/blind_message, var/drugged_message, var/self_drugged_message, var/blind_drugged_message, var/ignore_self = 0, var/range = 7)
	. = ..()
	if(zshadow)
		zshadow.visible_message(message, self_message, blind_message)

// This shows when someone is typing. We do not use this on /vg/.
/*/mob/set_typing_indicator(var/state)
	var/old_typing = src.typing
	. = ..()
	if(shadow && old_typing != src.typing)
		shadow.set_typing_indicator(state) // Okay the real proc changed something! That means we should handle things too

/mob/zshadow/set_typing_indicator(var/state)
	if(!typing_indicator)
		typing_indicator = new
		typing_indicator.icon = 'icons/mob/talk.dmi' // Looks better on the right with job icons.
		typing_indicator.icon_state = "typing"
	if(state && !typing)
		overlays += typing_indicator
		typing = 1
	else if(!state && typing)
		overlays -= typing_indicator
		typing = 0
	if(shadow)
		shadow.set_typing_indicator(state)*/
