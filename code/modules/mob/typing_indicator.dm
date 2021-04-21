/*Typing indicators, when a mob uses the F3/F4 keys to bring the say/emote input boxes up this little buddy is
made and follows them around until they are done (or something bad happens), helps tell nearby people that 'hey!
I IS TYPIN'!'
*/

// Ported from Baystation12 : https://github.com/Baystation12/Baystation12

var/atom/movable/typing_indicator/typing_indicator

/atom/movable/typing_indicator
	icon = 'icons/mob/talk.dmi'
	icon_state = "talking"
	vis_flags = VIS_INHERIT_ID

/atom/movable/typing_indicator/Destroy()
	stack_trace("Something deleted the global typing indicator. Probably not intended.")
	return ..()

/mob/proc/create_typing_indicator()
	if(client && !stat && client.prefs.typing_indicator && src.is_visible() && isturf(src.loc))
		vis_contents |= typing_indicator

/mob/proc/remove_typing_indicator()
	vis_contents -= typing_indicator

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
