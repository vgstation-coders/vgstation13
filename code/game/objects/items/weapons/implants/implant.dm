/obj/item/weapon/implant
	name = "implant"
	icon = 'icons/obj/device.dmi'
	icon_state = "implant"
	var/implanted = null
	var/mob/imp_in = null
	var/datum/organ/external/part = null
	_color = "b"
	var/allow_reagents = 0
	var/malfunction = 0

/obj/item/weapon/implant/proc/trigger(emote, source as mob)
	return

/obj/item/weapon/implant/proc/activate()
	return

// What does the implant do when it's removed?
/obj/item/weapon/implant/proc/handle_removal(var/mob/remover)
	return

// What does the implant do upon injection?
// return 0 if the implant fails (ex. Revhead and loyalty implant.)
// return 1 if the implant succeeds (ex. Nonrevhead and loyalty implant.)
/obj/item/weapon/implant/proc/implanted(var/mob/source)
	return 1

/obj/item/weapon/implant/proc/get_data()
	return "No information available"

/obj/item/weapon/implant/proc/hear(message, source as mob)
	return

/obj/item/weapon/implant/proc/islegal()
	return 0

/obj/item/weapon/implant/proc/meltdown()	//breaks it down, making implant unrecongizible
	to_chat(imp_in, "<span class = 'warning'>You feel something melting inside [part ? "your [part.display_name]" : "you"]!</span>")
	if (part)
		part.take_damage(burn = 15, used_weapon = "Electronics meltdown")
	else
		var/mob/living/M = imp_in
		M.apply_damage(15,BURN)
	name = "melted implant"
	desc = "Charred circuit in melted plastic case. Wonder what that used to be..."
	icon_state = "implant_melted"
	malfunction = IMPLANT_MALFUNCTION_PERMANENT
	
/obj/item/weapon/implant/proc/makeunusable(var/probability=50)
	if(prob(probability))
		visible_message("<span class='warning'>\The [src] fizzles and sparks!</span>")
		name = "melted " + initial(name)
		desc = "Charred circuit in melted plastic case."
		icon_state = "implant_melted"
		malfunction = IMPLANT_MALFUNCTION_PERMANENT
	
/obj/item/weapon/implant/Destroy()
	if(part)
		part.implants.Remove(src)
	imp_in = null
	if(reagents)
		qdel(reagents)
	..()


/obj/item/weapon/implant/explosive
	name = "explosive implant"
	desc = "A military grade micro bio-explosive. Highly dangerous."
	var/phrase = "supercalifragilisticexpialidocious"
	icon_state = "implant_evil"

/obj/item/weapon/implant/explosive/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Robust Corp RX-78 Intimidation Class Implant<BR>
<b>Life:</b> Activates upon codephrase or detected death.<BR>
<b>Important Notes:</b> Explodes<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a compact, electrically detonated explosive that detonates upon receiving a specially encoded signal or upon host death.<BR>
<b>Special Features:</b> Explodes<BR>
<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
	return dat

/obj/item/weapon/implant/explosive/Hear(var/datum/speech/speech, var/rendered_speech="")
	hear(speech.message)
	return

/obj/item/weapon/implant/explosive/hear(var/msg)
	var/list/replacechars = list("'" = "", "\"" = "", ">" = "", "<" = "", "(" = "", ")" = "")
	msg = sanitize_simple(msg, replacechars)
	if(findtext(msg, phrase))
		activate()

/obj/item/weapon/implant/explosive/trigger(emote, source as mob)
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
		explosion(T, 1, 3, 4, 6)
		T.hotspot_expose(3500, 125, surfaces = 1)

		qdel(src)

/obj/item/weapon/implant/explosive/implanted(mob/source as mob)
	if(malfunction == IMPLANT_MALFUNCTION_PERMANENT)
		return 0
	phrase = input("Choose activation phrase:") as text
	var/list/replacechars = list("'" = "", "\"" = "", ">" = "", "<" = "", "(" = "", ")" = "")
	phrase = sanitize_simple(phrase, replacechars)
	usr.mind.store_memory("Explosive implant in [source] can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate.", 0, 0)
	to_chat(usr, "The implanted explosive implant in [source] can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate.")
	addHear()
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
	
/obj/item/weapon/implant/explosive/handle_removal(var/mob/remover)
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
//emp proof implant for nuclear operatives
/obj/item/weapon/implant/explosive/nuclear/emp_act(severity)
	return



/obj/item/weapon/implant/chem
	name = "chem implant"
	desc = "Injects chemicals."
	allow_reagents = 1

/obj/item/weapon/implant/chem/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Robust Corp MJ-420 Prisoner Management Implant<BR>
<b>Life:</b> Deactivates upon death but remains within the body.<BR>
<b>Important Notes: Due to the system functioning off of nutrients in the implanted subject's body, the subject<BR>
will suffer from an increased appetite.</B><BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a small capsule that can contain various chemicals. Upon receiving a specially encoded signal<BR>
the implant releases the chemicals directly into the blood stream.<BR>
<b>Special Features:</b>
<i>Micro-Capsule</i>- Can be loaded with any sort of chemical agent via the common syringe and can hold 50 units.<BR>
Can only be loaded while still in its original case.<BR>
<b>Integrity:</b> Implant will last so long as the subject is alive. However, if the subject suffers from malnutrition,<BR>
the implant may become unstable and either pre-maturely inject the subject or simply break."}
	return dat

/obj/item/weapon/implant/chem/New()
	..()
	create_reagents(50)
	chemical_implants.Add(src)

/obj/item/weapon/implant/chem/Destroy()
	chemical_implants.Remove(src)
	..()

/obj/item/weapon/implant/chem/trigger(emote, source as mob)
	if(emote == "deathgasp")
		src.activate(src.reagents.total_volume)
	return


/obj/item/weapon/implant/chem/activate(var/cause)
	if(malfunction == IMPLANT_MALFUNCTION_PERMANENT)
		return 0
	if((!cause) || (!src.imp_in))
		return 0
	var/mob/living/carbon/R = src.imp_in
	src.reagents.trans_to(R, cause)
	to_chat(R, "You hear a faint *beep*.")
	if(!src.reagents.total_volume)
		to_chat(R, "You hear a faint click from your chest.")
		spawn(0)
			qdel(src)
	return

/obj/item/weapon/implant/chem/emp_act(severity)
	if (malfunction)
		return
	malfunction = IMPLANT_MALFUNCTION_TEMPORARY

	switch(severity)
		if(1)
			if(prob(60))
				activate(20)
		if(2)
			if(prob(30))
				activate(5)

	spawn(20)
		malfunction--

/obj/item/weapon/implant/loyalty
	name = "loyalty implant"
	desc = "Induces constant thoughts of loyalty to Nanotrasen."

/obj/item/weapon/implant/loyalty/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Nanotrasen Employee Management Implant<BR>
<b>Life:</b> Ten years.<BR>
<b>Important Notes:</b> Personnel injected with this device tend to be much more loyal to the company.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a small pod of nanobots that manipulate the host's mental functions.<BR>
<b>Special Features:</b> Will prevent and cure light forms of brainwashing.<BR>
<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}
	return dat


/obj/item/weapon/implant/loyalty/implanted(mob/M)
	if(malfunction == IMPLANT_MALFUNCTION_PERMANENT)
		return 0
	if(!iscarbon(M))
		return 0
	var/mob/living/carbon/H = M
	for(var/obj/item/weapon/implant/I in H)
		if(istype(I, /obj/item/weapon/implant/traitor))
			if(I.imp_in == H)
				H.visible_message("<span class='big danger'>[H] seems to resist the implant!</span>", "<span class='danger'>You feel a strange sensation in your head that quickly dissipates.</span>")
				return 0
	if(isrevhead(H))
		H.visible_message("<span class='big danger'>[H] seems to resist the implant!</span>", "<span class='danger'>You feel the corporate tendrils of Nanotrasen try to invade your mind!</span>")
		return 0
	if(iscultist(H) && veil_thickness >= CULT_ACT_I)
		to_chat(H, "<span class='danger'>You feel the corporate tendrils of Nanotrasen trying to invade your mind!</span>")
		spawn (1)//waiting for the implant to have its loc moved inside the body
			H.implant_pop()
		return 1
	if(isrevnothead(H))
		var/datum/role/R = H.mind.GetRole(REV)
		R.Drop()

	to_chat(H, "<span class = 'notice'>You feel a surge of loyalty towards Nanotrasen.</span>")
	return 1
/obj/item/weapon/implant/loyalty/handle_removal(var/mob/remover)
	makeunusable(15)

/obj/item/weapon/implant/traitor
	name = "greytide implant"
	desc = "Greytide Station wide"
	icon_state = "implant_evil"

/obj/item/weapon/implant/traitor/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Greytide Mind-Slave Implant<BR>
<b>Life:</b> ??? <BR>
<b>Important Notes:</b> Any humanoid injected with this implant will become loyal to the injector and the greytide, unless of course the host is already loyal to someone else.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a small pod of nanobots that manipulate the host's mental functions.<BR>
<b>Special Features:</b> Glory to the Greytide!<BR>
<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}
	return dat

/obj/item/weapon/implant/traitor/implanted(mob/M, mob/user)
	if(malfunction == IMPLANT_MALFUNCTION_PERMANENT)
		return 0
	if(!iscarbon(M))
		to_chat(user, "<span class='danger'>The implant doesn't seem to be compatible with [M]!</span>")
		return 0
	if(!M.mind)
		to_chat(user, "<span class='danger'>[M] lacks a mind to affect!</span>")
		return 0
	var/mob/living/carbon/H = M
	if(M == user)
		to_chat(user, "<span class='notice'>You feel quite stupid for doing that.</span>")
		if(isliving(user))
			user:brainloss += 10
		return
	for(var/obj/item/weapon/implant/I in H)
		if(istype(I, /obj/item/weapon/implant/traitor) || istype(I, /obj/item/weapon/implant/loyalty))
			if(I.imp_in == H)
				H.visible_message("<span class='big danger'>[H] seems to resist the implant!</span>", "<span class='danger'>You feel a strange sensation in your head that quickly dissipates.</span>")
				return 0
	if(istraitor(H))
		H.visible_message("<span class='big danger'>[H] seems to resist the implant!</span>", "<span class='danger'>You feel a familiar sensation in your head that quickly dissipates.</span>")
		return 0
	H.implanting = 1
	to_chat(H, "<span class = 'notice'>You feel a surge of loyalty towards [user.name].</span>")

	var/datum/faction/F = find_active_faction_by_typeandmember(/datum/faction/syndicate/greytide, null, user.mind)
	if(!F)
		F = ticker.mode.CreateFaction(/datum/faction/syndicate/greytide, 0, 1)
		F.HandleNewMind(user.mind)

	var/success = F.HandleRecruitedMind(H.mind)
	if(!success)
		visible_message("<span class = 'warning'>The head of \the [H] begins to glow a deep red. It is going to explode!</span>")
		spawn(3 SECONDS)
			var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
			head_organ.explode()
		return 0
	to_chat(H, "<B><span class = 'big warning'>You've been shown the Greytide by [user.name]!</B> You now must lay down your life to protect them and assist in their goals at any cost.</span>")
	F.forgeObjectives()
	update_faction_icons()
	log_admin("[ckey(user.key)] has mind-slaved [ckey(H.key)].")
	return 1

/obj/item/weapon/implant/traitor/handle_removal(var/mob/remover)
	if (!imp_in.mind)
		return
	var/datum/role/R = imp_in.mind.GetRole(IMPLANTSLAVE)
	if (!R)
		return
	log_admin("[key_name(remover)] has removed a greytide implant from [key_name(imp_in)].")
	R.Drop(FALSE)
	
	makeunusable(90)

/obj/item/weapon/implant/adrenalin
	name = "adrenalin implant"
	desc = "Removes all stuns and knockdowns."
	var/uses

/obj/item/weapon/implant/adrenalin/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Cybersun Industries Adrenalin Implant<BR>
<b>Life:</b> Five days.<BR>
<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
<HR>
<b>Implant Details:</b> Subjects injected with implant can activate a massive injection of adrenalin.<BR>
<b>Function:</b> Contains nanobots to stimulate body to mass-produce Adrenalin.<BR>
<b>Special Features:</b> Will prevent and cure most forms of brainwashing.<BR>
<b>Integrity:</b> Implant can only be used three times before the nanobots are depleted."}
	return dat

/obj/item/weapon/implant/adrenalin/trigger(emote, mob/source as mob)
	if(malfunction == IMPLANT_MALFUNCTION_PERMANENT)
		return 0
	if (src.uses < 1)
		return 0
	if (emote == "pale")
		src.uses--
		to_chat(source, "<span class = 'notice'>You feel a sudden surge of energy!</span>")
		source.SetStunned(0)
		source.SetKnockdown(0)
		source.SetParalysis(0)

	return

/obj/item/weapon/implant/adrenalin/implanted(mob/source)
		source.mind.store_memory("A implant can be activated by using the pale emote, <B>say *pale</B> to attempt to activate.", 0, 0)
		to_chat(source, "The implanted freedom implant can be activated by using the pale emote, <B>say *pale</B> to attempt to activate.")
		return 1

/obj/item/weapon/implant/adrenalin/handle_removal(var/mob/remover)
	makeunusable(75)

/obj/item/weapon/implant/death_alarm
	name = "death alarm implant"
	desc = "An alarm which monitors host vital signs and transmits a radio message upon death."
	var/mobname = "Will Robinson"

/obj/item/weapon/implant/death_alarm/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Nanotrasen \"Profit Margin\" Class Employee Lifesign Sensor<BR>
<b>Life:</b> Activates upon death.<BR>
<b>Important Notes:</b> Alerts crew to crewmember death.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a compact radio signaler that triggers when the host's lifesigns cease.<BR>
<b>Special Features:</b> Alerts crew to crewmember death.<BR>
<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
	return dat

/obj/item/weapon/implant/death_alarm/process()
	if (!implanted || timestopped)
		return
	var/mob/M = imp_in

	if(isnull(M)) // If the mob got gibbed
		if(loc)
			if(loc:timestopped)
				return
		activate()
	else if(M.isDead())
		if(M.timestopped)
			return
		activate("death")

/obj/item/weapon/implant/death_alarm/activate(var/cause)
	var/mob/M = imp_in
	var/area/t = get_area(M)
	src.name = "\improper [mobname]'s death alarm"
	var/datum/speech/speech = create_speech("[mobname] has died in",1459,src)
	speech.name="[mobname]'s Death Alarm"
	speech.job="Death Alarm"
	speech.set_language(LANGUAGE_GALACTIC_COMMON)
	switch (cause)
		if("death")
			if(!announcement_intercom || !istype(announcement_intercom))
				announcement_intercom = new(null)

			if(istype(t, /area/shuttle/nuclearops) || istype(t, /area/syndicate_mothership) || istype(t, /area/shuttle/syndicate_elite) )
				//give the syndies a bit of stealth
				speech.message="[mobname] has died in Space!"
			else
				speech.message="[mobname] has died in [t.name]!"
			processing_objects.Remove(src)
		if ("emp")
			var/name = prob(50) ? t.name : pick(teleportlocs)
			speech.message="[mobname] has died in [name]!"
		else
			speech.message="[mobname] has died-zzzzt in-in-in..."
			processing_objects.Remove(src)
	Broadcast_Message(speech, vmask=0, data=0, compression=0, level=list(0,1))
	qdel(speech)

/obj/item/weapon/implant/death_alarm/emp_act(severity)			//for some reason alarms stop going off in case they are emp'd, even without this
	if (malfunction)		//so I'm just going to add a meltdown chance here
		return
	malfunction = IMPLANT_MALFUNCTION_TEMPORARY

	activate("emp")	//let's shout that this dude is dead
	if(severity == 1)
		if(prob(40))	//small chance of obvious meltdown
			meltdown()
		else	//but more likely it will just quietly die
			malfunction = IMPLANT_MALFUNCTION_PERMANENT
		processing_objects.Remove(src)
		return

	spawn(20)
		malfunction--

/obj/item/weapon/implant/death_alarm/implanted(mob/source as mob)
	mobname = source.real_name
	processing_objects.Add(src)
	return 1

/obj/item/weapon/implant/death_alarm/handle_removal(var/mob/remover)
	makeunusable(75)

/obj/item/weapon/implant/compressed
	name = "compressed matter implant"
	desc = "Based on compressed matter technology, can store a single item."
	icon_state = "implant_evil"
	var/activation_emote = "sigh"
	var/obj/item/scanned = null

/obj/item/weapon/implant/compressed/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Nanotrasen \"Profit Margin\" Class Employee Lifesign Sensor<BR>
<b>Life:</b> Activates upon death.<BR>
<b>Important Notes:</b> Alerts crew to crewmember death.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a compact radio signaler that triggers when the host's lifesigns cease.<BR>
<b>Special Features:</b> Alerts crew to crewmember death.<BR>
<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
	return dat

/obj/item/weapon/implant/compressed/trigger(emote, mob/source as mob)
	if(malfunction == IMPLANT_MALFUNCTION_PERMANENT)
		return 0
		
	if (src.scanned == null)
		return 0

	if (emote == src.activation_emote)
		to_chat(source, "The air glows as \the [src.scanned.name] uncompresses.")
		activate()

/obj/item/weapon/implant/compressed/activate()
	var/turf/t = get_turf(src)
	if (imp_in)
		imp_in.put_in_hands(scanned)
	else
		scanned.forceMove(t)
	qdel (src)

/obj/item/weapon/implant/compressed/implanted(mob/source as mob)
	src.activation_emote = input("Choose activation emote:") in list("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
	if (source.mind)
		source.mind.store_memory("Compressed matter implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
	to_chat(source, "The implanted compressed matter implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.")
	return 1

/obj/item/weapon/implant/compressed/islegal()
	return 0

/obj/item/weapon/implant/compressed/handle_removal(var/mob/remover)
	makeunusable(75)

/obj/item/weapon/implant/cortical
	name = "cortical stack"
	desc = "A fist-sized mass of biocircuits and chips."



/obj/item/weapon/implant/peace
	name = "pax implant"
	desc = "A bean-shaped implant with a single embossed word - PAX - on it."
	var/imp_alive = 0
	var/imp_msg_debounce = 0

/obj/item/weapon/implant/peace/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Pax Implant<BR>
<b>Manufacturer:</b> Ouroboros Medical<BR>
<b>Effect:</b> Makes the host incapable of committing violent acts.
<b>Important Notes:</b> Effect accomplished by paralyzing parts of the brain. This effect is neutralized by 15u or greater of Methylin.<BR>
<b>Life:</b> Sustained as long as it remains within a host. Survives on the host's nutrition. Dies upon removal.<BR>
"}
	return dat

/obj/item/weapon/implant/peace/meltdown()
	visible_message("<span class='warning'>\The [src] releases a dying hiss as it denatures!</span>")
	name = "denatured implant"
	desc = "A dead, hollow implant. Wonder what it used to be..."
	icon_state = "implant_melted"
	malfunction = IMPLANT_MALFUNCTION_PERMANENT

/obj/item/weapon/implant/peace/process()
	var/mob/living/carbon/host = imp_in

	if (isnull(host) && imp_alive)
		malfunction = IMPLANT_MALFUNCTION_PERMANENT

	if (malfunction == IMPLANT_MALFUNCTION_PERMANENT)
		meltdown()
		processing_objects.Remove(src)
		return

	if (!isnull(host) && !imp_alive)
		imp_alive = 1

	if (host.nutrition <= 0 || host.reagents.has_reagent(METHYLIN, 15))
		malfunction = IMPLANT_MALFUNCTION_TEMPORARY
	else
		malfunction = 0

	if (!imp_msg_debounce && malfunction == IMPLANT_MALFUNCTION_TEMPORARY)
		imp_msg_debounce = 1
		to_chat(host, "<span class = 'warning'>Your rage bubbles, \the [src] inside you is being suppressed!</span>")

	if (imp_msg_debounce && !malfunction)
		imp_msg_debounce = 0
		to_chat(host, "<span class = 'warning'>Your rage cools, \the [src] inside you is active!</span>")

	if (!malfunction)
		host.nutrition = max(host.nutrition - 0.15,0)


/obj/item/weapon/implant/peace/implanted(mob/host)
	if (!imp_alive && !malfunction)
		processing_objects.Add(src)
		to_chat(host, "<span class = 'warning'>You feel your desire to harm anyone slowly drift away...</span>")
		return 1
	else
		return 0

/obj/item/weapon/implant/peace/handle_removal(var/mob/remover)
	meltdown()

/obj/item/weapon/implant/holy
	name = "holy implant"
	desc = "Subjects its user to the chants of a thousand chaplains."

/obj/item/weapon/implant/holy/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Holy Dogmatic Interference Implant<BR>
<b>Life:</b> Anywhere from ten days to ten years depending on the strain placed upon the implant by the subject.<BR>
<b>Important Notes:</b> This device was commissioned by Nanotrasen after it proved able to distract occult practitioners, making them unable to practice their dark arts.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Submits its subject to the chants of a thousand chaplains.<BR>
<b>Special Features:</b> Prevents cultists from using their runes and talismans, or from being the target of some of their peers' rituals.<BR>
<b>Integrity:</b> Implant anchors itself against the subject's bones to prevent blood pressure induced ejections."}
	return dat

/obj/item/weapon/implant/holy/implanted(mob/M)
	if(malfunction == IMPLANT_MALFUNCTION_PERMANENT)
		return 0
	if(!iscarbon(M))
		return 0
	var/mob/living/carbon/H = M
	H << sound('sound/ambience/ambicha1.ogg')
	H << sound('sound/ambience/ambicha2.ogg')
	H << sound('sound/ambience/ambicha3.ogg')
	H << sound('sound/ambience/ambicha4.ogg')
	if(iscultist(H))
		to_chat(H, "<span class='danger'>You feel uneasy as you suddenly start hearing a cacophony of religious chants. You find yourself unable to perform any ritual.</span>")
	else
		to_chat(H, "<span class = 'notice'>You hear the soothing millennia-old Gregorian chants of the clergy.</span>")
	return 1
	
/obj/item/weapon/implant/holy/handle_removal(var/mob/remover)
	makeunusable(15)
