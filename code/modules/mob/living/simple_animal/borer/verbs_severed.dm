
/obj/item/verbs/borer/severed/verb/abandon_host()
	set category = "Alien"
	set name = "Abandon Host"
	set desc = "Slither out of your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B))
		return
	B.abandon_host()

/obj/item/verbs/borer/severed/verb/borer_speak(var/message as text)
	set category = "Alien"
	set name = "Borer Speak"
	set desc = "Communicate with your brethren."

	if(!message)
		return

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	message = capitalize(message)

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B))
		return
	B.borer_speak(message)