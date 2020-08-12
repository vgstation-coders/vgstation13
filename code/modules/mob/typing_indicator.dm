/*Typing indicators, when a mob uses the F3/F4 keys to bring the say/emote input boxes up this little buddy is
made and follows them around until they are done (or something bad happens), helps tell nearby people that 'hey!
I IS TYPIN'!'
*/

// Ported from Baystation12 : https://github.com/Baystation12/Baystation12

/mob
	var/atom/movable/overlay/typing_indicator/typing_indicator = null

/atom/movable/overlay/typing_indicator
	icon = 'icons/mob/talk.dmi'
	icon_state = "talking"

/atom/movable/overlay/typing_indicator/New()
	. = ..()
	if(!istype(master, /mob))
		CRASH("Master of typing_indicator has invalid type: [master.type].")

/atom/movable/overlay/typing_indicator/Destroy()
	var/mob/M = master
	M.typing_indicator = null
	. = ..()

/mob/proc/create_typing_indicator()
	if(client && !stat && client.prefs.typing_indicator && src.is_visible() && isturf(src.loc))
		if(!typing_indicator)
			typing_indicator = new(src)
		typing_indicator.invisibility = 0

/mob/proc/remove_typing_indicator() // A bit excessive, but goes with the creation of the indicator I suppose
	if(typing_indicator)
		typing_indicator.invisibility = INVISIBILITY_MAXIMUM

/mob/Logout()
	remove_typing_indicator()
	. = ..()

/mob/verb/say_wrapper()
	set name = ".Say"
	set hidden = 1
	create_typing_indicator()
	spawn(1 MINUTES)
		remove_typing_indicator()

/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = 1
	create_typing_indicator()
	spawn(1 MINUTES)
		remove_typing_indicator()
