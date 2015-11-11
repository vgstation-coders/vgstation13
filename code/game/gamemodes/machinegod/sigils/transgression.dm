/obj/effect/sigil/transgression
	name = "dull sigil"
	desc =  "A dull golden sigil. It's almost like light was carved into the floor."
	icon_state = "transgression"
	alpha = 160
	actcolor = "#FF0000"


/obj/effect/sigil/transgression/activation(var/mob/living/L as mob)
	if(..())
		return 1

	if(iscultist(L))
		L << "<span class='sinister'>\"Watch your step, wretch.\"</span>"
	else
		L << "<span class='warning'>An unseen force renders you motionless!</span>"

	L.Stun(4)
	if(prob(iscultist(L) ? 65 : 35))
		L.adjustBruteLoss(10)
		L << "<span class='danger'>It hurts.</span>"
