/obj/effect/sigil/submission
	name = "ominous sigil"
	desc =  "An ominous golden sigil. Something about it really bothers you."
	icon_state = "submission"
	alpha = 50
	actcolor = "#FF00FF"
	culttrigger = 1


/obj/effect/sigil/submission/activation(var/mob/M as mob)
	if(..())
		return 1

	if(!M.mind)
		return 1

	/*if(istype(mode_ticker) && (M.mind == mode_ticker.harvest_target)) NOT IMPLEMENTED YET -velardamakar
		M.visible_message("<span class='warning'>The sigil glows, but it's as if [M] is being rejected.</span>", \
		"<span class='clockwork'>\"No.\"</span>", \
		"<span class='warning'>Something feels wrong.</span>")
		return*/

	if(isclockcult(M))
		M.visible_message("<span class='warning'>As the sigil glows, a golden light fills [M]'s eyes.</span>", \
		"<span class='clockwork'>\"You're already a follower! I hope you know what you're doing.\"</span>", \
		"<span class='warning'>Something feels wrong.</span>")
		return
	else
		M.visible_message("<span class='warning'>As the sigil glows, a golden light fills [M]'s eyes.</span>", \
		"<span class='clockwork'>\"You belong to me now.\"</span>", \
		"<span class='warning'>Something feels wrong.</span>")

	if(is_convertable_to_cult(M.mind) && !jobban_isbanned(M, "cultist"))//putting jobban check here because is_convertable uses mind as argument
		ticker.mode.add_clockcultist(M.mind)
		M.mind.special_role = "Machinegod"
		M << "<span class='clockwork'>Your mind is racing! Your body feels incredibly light! Your world glows a brilliant yellow! All at once everything connects to you. The clockwork justiciar lies in exile, derelict and forgotten in an unseen realm.</span>"
		M << "<span class='clockwork'>Assist your new compatriots in their righteous efforts. Their goal is yours, and yours is theirs. You serve the Justiciar above all else. Bring Him back.</span>"
		log_admin("[M]([ckey(M.key)]) was converted to Ratvar's cult at [M.loc.x], [M.loc.y], [M.loc.z]")

	else
		M << "<span class='clockwork'>Your mind is racing! Your body feels incredibly light! Your world glows a brilliant yellow! All at once everything connects to you. The clockwork justiciar lies in exile, derelict and forgotten in an unseen realm.</span>"
		M << "<span class='danger'>And you were able to force it out of your mind. You now know the truth, there's something horrible out there, stop it and its minions at all costs.</span>"

		// Make them defenseless for a whole minute, to prevent a jobbanned guy ruining a round.
		M.Weaken(60)
		M.Silence(60)
