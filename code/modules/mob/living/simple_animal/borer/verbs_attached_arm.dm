/obj/item/verbs/borer/attached_arm/verb/borer_speak(var/message as text)
	set category = "Alien"
	set name = "Borer Speak"
	set desc = "Communicate with your bretheren"

	if(!message)
		return

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	message = capitalize(message)

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.borer_speak(message)

/obj/item/verbs/borer/attached_arm/verb/evolve()
	set category = "Alien"
	set name = "Evolve"
	set desc = "Upgrade yourself or your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.evolve()

/obj/item/verbs/borer/attached_arm/verb/secrete_chemicals()
	set category = "Alien"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.secrete_chemicals()

/obj/item/verbs/borer/attached_arm/verb/abandon_host()
	set category = "Alien"
	set name = "Abandon Host"
	set desc = "Slither out of your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.abandon_host()