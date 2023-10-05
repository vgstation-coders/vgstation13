/obj/item/weapon/implant/explosive
	name = "explosive implant"
	desc = "A military grade micro bio-explosive. Highly dangerous."
	var/phrase = "supercalifragilisticexpialidocious"
	icon_state = "implant_evil"

/obj/item/weapon/implant/explosive/get_data()
	return {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Robust Corp RX-78 Intimidation Class Implant<BR>
<b>Life:</b> Activates upon codephrase or detected death.<BR>
<b>Important Notes:</b> Explodes<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a compact, electrically detonated explosive that detonates upon receiving a specially encoded signal or upon host death.<BR>
<b>Special Features:</b> Explodes<BR>
<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}

/obj/item/weapon/implant/explosive/Hear(var/datum/speech/speech, var/rendered_speech="")
	var/static/list/replacechars = list("'" = "", "\"" = "", ">" = "", "<" = "", "(" = "", ")" = "")
	var/msg = sanitize_simple(speech.message, replacechars)
	if(findtext(msg, phrase))
		activate()

/obj/item/weapon/implant/explosive/trigger(emote, mob/source)
	if(emote == "deathgasp")
		activate()

/obj/item/weapon/implant/explosive/activate()
	if(malfunction == IMPLANT_MALFUNCTION_PERMANENT)
		return
	if(iscarbon(imp_in))
		var/mob/M = imp_in

		message_admins("Explosive implant triggered in [M] ([M.key]). (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>) ")
		log_game("Explosive implant triggered in [M] ([M.key]).")

		var/turf/T = get_turf(M)

		M.gib()
		explosion(T, 1, 3, 4, 6, whodunnit = M)
		T.hotspot_expose(3500, 125, surfaces = 1)

		qdel(src)

/obj/item/weapon/implant/explosive/implanted(mob/source)
	if(malfunction == IMPLANT_MALFUNCTION_PERMANENT)
		return 0
	phrase = input("Choose activation phrase:") as text
	var/static/list/replacechars = list("'" = "", "\"" = "", ">" = "", "<" = "", "(" = "", ")" = "")
	phrase = sanitize_simple(phrase, replacechars)
	usr.mind.store_memory("Explosive implant in [imp_in] can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate.", 0, 0)
	to_chat(usr, "The implanted explosive implant in [imp_in] can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate.")
	addHear()
	source.register_event(/event/emote, src, nameof(src::trigger()))
	score.implant_phrases += "[usr.real_name] ([get_key(usr)]) rigged [imp_in.real_name] to explode on the phrase <font color='red'>\"[phrase]\"</font>!"
	return 1

/obj/item/weapon/implant/explosive/emp_act(severity)
	if(malfunction)
		return
	malfunction = IMPLANT_MALFUNCTION_TEMPORARY
	switch (severity)
		if(2.0)	//Weak EMP will make implant tear limbs off.
			if(prob(50))
				small_boom()
		if(1.0)	//Strong EMP will melt implant either making it go off, or disarming it
			if(prob(70))
				if(prob(50))
					small_boom()
				else
					if(prob(50))
						activate()		//50% chance of bye bye
					else
						meltdown()		//50% chance of implant disarming
						return
	spawn(20)
		malfunction--

/obj/item/weapon/implant/explosive/islegal()
	return 0

/obj/item/weapon/implant/explosive/handle_removal(mob/remover)
	imp_in?.unregister_event(/event/emote, src, nameof(src::trigger()))
	makeunusable(75)

/obj/item/weapon/implant/explosive/proc/small_boom()
	if(iscarbon(imp_in))
		imp_in.visible_message("<span class='warning'>Something beeps inside [imp_in][part ? "'s [part.display_name]" : ""]!</span>")
		playsound(loc, 'sound/items/countdown.ogg', 75, 1, -3)
		spawn(25)
			if(ishuman(imp_in) && part)
				//No tearing off these parts since it's pretty much killing
				//and you can't replace groins
				if(istype(part, /datum/organ/external/chest) || istype(part, /datum/organ/external/groin) || istype(part, /datum/organ/external/head))
					part.createwound(BRUISE, 60) //Mangle them instead
				else
					part.droplimb(1)
			explosion(get_turf(imp_in), -1, -1, 2, 3, 3)
			qdel(src)

/obj/item/weapon/implant/explosive/nuclear/implanted(mob/source)
	imp_in.register_event(/event/emote, src, nameof(src::trigger()))

//emp proof implant for nuclear operatives
/obj/item/weapon/implant/explosive/nuclear/emp_act(severity)
	return

/obj/item/weapon/implant/explosive/remote
	name = "chem implant"
	desc = "Injects \"chemicals\"."
	icon_state = "implant"

/obj/item/weapon/implant/explosive/remote/New()
	..()
	remote_implants.Add(src)

/obj/item/weapon/implant/explosive/remote/Destroy()
	remote_implants.Remove(src)
	..()

/obj/item/weapon/implant/explosive/remote/get_data()
	return {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Robust Corp RX-78 Prisoner Intimidation Implant<BR>
<b>Life:</b> Activates upon remote function.<BR>
<b>Important Notes:</b> Explodes<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a small, compact, electrically detonated explosive that detonates upon receiving a specially encoded signal.<BR>
<b>Special Features:</b> Explodes<BR>
<b>Integrity:</b> Implant will last so long as the subject is alive. However, if the subject suffers from malnutrition,<BR>
the implant may become unstable and either pre-maturely inject the subject or simply break."}

/obj/item/weapon/implant/explosive/remote/Hear()
	return

/obj/item/weapon/implant/explosive/remote/activate(mob/user)
	if(malfunction == IMPLANT_MALFUNCTION_PERMANENT)
		return
	if(iscarbon(imp_in))
		var/mob/M = imp_in

		message_admins("Remote explosive implant triggered in [M] ([M.key])[user ? "by [user] ([user.key])": ""]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>) ")
		log_game("Remote explosive implant triggered in [M] ([M.key])[user ? "by [user] ([user.key])": ""].")

		to_chat(M, "You hear a faint *beep*.")

		var/turf/T = get_turf(M)

		M.gib()
		explosion(T, 1, 1, 3, 4, whodunnit = user)
		T.hotspot_expose(3500, 125, surfaces = 1)

		qdel(src)

/obj/item/weapon/implant/explosive/remote/implanted(mob/implanter)
	return
