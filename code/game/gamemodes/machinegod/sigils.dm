/obj/effect/sigil
	name = "sigil"
	desc = "An odd circle."
	anchored = 1
	icon = 'icons/obj/clockwork/sigils.dmi'
	icon_state = "ritual"
	color = "#B39700"
	var/actcolor = ""
	var/visibility = 0
	unacidable = 1
	layer = TURF_LAYER

	var/dead=0 // For cascade and whatnot.

	var/atom/movable/overlay/h_animation = null
	var/culttrigger = 0 //Can Ratvar cultists trigger this?


/obj/effect/sigil/Crossed(AM as mob|obj)
	Bumped(AM)


/obj/effect/sigil/Bumped(mob/M as mob|obj)
	if(iscarbon(M) || issilicon(M))
		if(culttrigger && isclockcult(M))
			activation(M)
		else
			activation(M)


/obj/effect/sigil/cultify() //PURGE
	qdel(src)


/obj/effect/sigil/proc/activation(var/mob/M as mob) //What does it do when it's triggered?
	if(M.stat==DEAD)
		return
	var/nullblock = 0
	for(var/turf/TR in range(src,1))
		if(findNullRod(TR))
			nullblock = 1
			break
	if(nullblock)
		M << "<span class='warning'>The null rod negates the sigil's power.</span>"
		return

	var/turf/T = get_turf(M)
	T.turf_animation('icons/obj/clockwork/sigils.dmi',"pulse",0, 0, 5, 'sound/machines/notify.ogg', actcolor)
	color = actcolor
	spawn(10)
		color = initial(color)


/obj/effect/sigil/transgression
	name = "dull sigil"
	desc =  "A dull golden sigil. It's almost like light was carved into the floor."
	icon_state = "transgression"
	alpha = 160
	actcolor = "#FF0000"


/obj/effect/sigil/transgression/activation(var/mob/M as mob)
	..()
	if(iscultist(M))
		M << "<span class='sinister'>\"Watch your step, wretch.\"</span>"
		M.Weaken(3)
		M.Stun(4)
	else
		M.Stun(4)
		M << "<span class='warning'>An unseen force renders you motionless!</span>"


/obj/effect/sigil/transmission
	name = "faint sigil"
	desc =  "A faint golden sigil. It's rather hard to notice these!"
	icon_state = "transmission"
	alpha = 50
	actcolor = "#FFFF00"


/obj/effect/sigil/transmission/activation(var/mob/M as mob)
	..()
	if(iscultist(M))
		if(electrocute_mob(M, get_area(src), src, 1))
			M << "<span class='sinister'>\"Watch your step, dog.\"</span>"
		else
			M << "<span class='warning'>The sigil lights up, but nothing happens...</span>"
	else
		if(electrocute_mob(M, get_area(src), src, 0.5))
			M << "<span class='danger'>You are suddenly electrocuted!</span>"
		else
			M << "<span class='warning'>The sigil lights up, but nothing happens...</span>"


/obj/effect/sigil/submission
	name = "ominous sigil"
	desc =  "An ominous golden sigil. Something about it really bothers you."
	icon_state = "submission"
	alpha = 50
	actcolor = "#FF00FF"
	culttrigger = 1


/obj/effect/sigil/submission/activation(var/mob/M as mob)
	..()
	if(!M.mind)
		return

	/*if(istype(mode_ticker) && (M.mind == mode_ticker.harvest_target)) NOT IMPLEMENTED YET -velardamakar
		M.visible_message("<span class='warning'>The sigil glows, but it's as if [M] is being rejected.</span>", \
		"<span class='sinister'>\"No.\"</span>", \
		"<span class='warning'>Something feels wrong.</span>")
		return*/

	if(isclockcult(M))
		M.visible_message("<span class='warning'>As the sigil glows, a golden light fills [M]'s eyes.</span>", \
		"<span class='sinister'>\"You're already a follower! I hope you know what you're doing.\"</span>", \
		"<span class='warning'>Something feels wrong.</span>")
		return
	else
		M.visible_message("<span class='warning'>As the sigil glows, a golden light fills [M]'s eyes.</span>", \
		"<span class='sinister'>\"You belong to me now.\"</span>", \
		"<span class='warning'>Something feels wrong.</span>")

	if(is_convertable_to_cult(M.mind) && !jobban_isbanned(M, "cultist"))//putting jobban check here because is_convertable uses mind as argument
		ticker.mode.add_clockcultist(M.mind)
		M.mind.special_role = "Machinegod"
		M << "<span class='sinister'>Your mind is racing! Your body feels incredibly light! Your world glows a brilliant yellow! All at once everything connects to you. The clockwork justiciar lies in exile, derelict and forgotten in an unseen realm.</span>"
		M << "<span class='sinister'>Assist your new compatriots in their righteous efforts. Their goal is yours, and yours is theirs. You serve the Justiciar above all else. Bring Him back.</span>"
		log_admin("[M]([ckey(M.key)]) was converted to Ratvar's cult at [M.loc.x], [M.loc.y], [M.loc.z]")
		return
	else
		M << "<span class='sinister'>Your mind is racing! Your body feels incredibly light! Your world glows a brilliant yellow! All at once everything connects to you. The clockwork justiciar lies in exile, derelict and forgotten in an unseen realm.</span>"
		M << "<span class='danger'>And you were able to force it out of your mind. You now know the truth, there's something horrible out there, stop it and its minions at all costs.</span>"
		return
