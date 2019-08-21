#define MALFUNCTION_TEMPORARY 1
#define MALFUNCTION_PERMANENT 2
/obj/item/weapon/implant
	name = "implant"
	icon = 'icons/obj/device.dmi'
	icon_state = "implant"
	var/implant_status = null //0 if outside body, 1 if it is inside body.
	var/mob/implanted_mob = null
	var/datum/organ/external/implanted_bodypart = null
	var/allow_reagents = 0
	var/malfunction = 0
	var/implant_color = "#65FF36" //Implanter changes color based on implant. Default is bright green.
	var/case_color = "blue" //Currently can only be red or blue
	
/obj/item/weapon/implant/proc/is_implanted()
	return implant_status

/obj/item/weapon/implant/Hear(var/datum/speech/speech, var/rendered_speech="")
	return

/obj/item/weapon/implant/proc/trigger(emote, mob/source)
	return

/obj/item/weapon/implant/proc/activate()
	return

/obj/item/weapon/implant/proc/attempt_implant(var/mob/source)
	//Return 1 if the implant is successful, 0 if it is not.
	//For example, implanting a revhead with a loyalty implant would return 0 and the implant would not be added to them.
	return 1

/obj/item/weapon/implant/proc/get_data() //Currently unused
	return "No information available."

/obj/item/weapon/implant/proc/islegal()
	return 0

/obj/item/weapon/implant/emp_act(severity)
	return

/obj/item/weapon/implant/proc/meltdown()
	to_chat(implanted_mob, "<span class = 'warning'>You feel something melting inside [implanted_bodypart ? "your [implanted_bodypart.display_name]" : "you"]!</span>")
	if(implanted_bodypart)
		implanted_bodypart.take_damage(burn = 15, used_weapon = "Electronics meltdown")
	else
		var/mob/living/M = implanted_mob
		M.apply_damage(15,BURN)
	name = "melted implant"
	desc = "A charred circuit in melted plastic case. Wonder what that used to be..."
	icon_state = "implant_melted"
	malfunction = MALFUNCTION_PERMANENT

/obj/item/weapon/implant/Destroy()
	if(implanted_bodypart)
		implanted_bodypart.implants.Remove(src)
	implanted_mob = null
	if(reagents)
		qdel(reagents)
	..()



/obj/item/weapon/implant/tracking
	name = "tracking implant"
	desc = "Allows for constant tracking of the recipient's location."
	var/id = 1.0

/obj/item/weapon/implant/tracking/New()
	..()
	tracking_implants += src

/obj/item/weapon/implant/tracking/Destroy()
	..()
	tracking_implants -= src

/obj/item/weapon/implant/tracking/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Tracking Beacon<BR>
				<b>Life:</b> 10 minutes after death of host<BR>
				<b>Important Notes:</b> None<BR>
				<HR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Continuously transmits low power signal. Useful for tracking.<BR>
				<b>Special Features:</b><BR>
				<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the chip if
				a malfunction occurs thereby securing safety of subject. The implant will melt and
				disintegrate into bio-safe elements.<BR>
				<b>Integrity:</b> Gradient creates slight risk of being overcharged and frying the
				circuitry. As a result neurotoxins can cause massive damage.<HR>
				Implant Specifics:<BR>"}
	return dat

/obj/item/weapon/implant/tracking/emp_act(severity)
	if(malfunction)
		return
	malfunction = MALFUNCTION_TEMPORARY

	var/delay = 20
	switch(severity)
		if(1)
			if(prob(60))
				meltdown()
		if(2)
			delay = rand(5 MINUTES, 15 MINUTES)

	spawn(delay)
		malfunction--



/obj/item/weapon/implant/explosive
	name = "explosive implant"
	desc = "A military grade micro bio-explosive. Highly dangerous."
	var/phrase = "supercalifragilisticexpialidocious"
	icon_state = "implant_evil"
	case_color = "red"
	implant_color = "#FFBC36"

/obj/item/weapon/implant/explosive/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
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
	var/list/replacechars = list("'" = "", "\"" = "", ">" = "", "<" = "", "(" = "", ")" = "")
	var/msg = sanitize_simple(speech.message, replacechars)
	if(findtext(msg, phrase))
		activate()

/obj/item/weapon/implant/explosive/trigger(emote, mob/source)
	if(emote == "deathgasp")
		activate()

/obj/item/weapon/implant/explosive/activate()
	if(malfunction == MALFUNCTION_PERMANENT)
		return
	if(iscarbon(implanted_mob))
		var/mob/M = implanted_mob

		message_admins("Explosive implant triggered in [M] ([M.key]). (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>) ")
		log_game("Explosive implant triggered in [M] ([M.key]).")

		var/turf/T = get_turf(M)

		M.gib()
		explosion(T, 1, 3, 4, 6)
		T.hotspot_expose(3500, 125, surfaces = 1)

		qdel(src)

/obj/item/weapon/implant/explosive/attempt_implant(mob/source as mob)
	phrase = input("Choose activation phrase:") as text
	var/list/replacechars = list("'" = "", "\"" = "", ">" = "", "<" = "", "(" = "", ")" = "")
	phrase = sanitize_simple(phrase, replacechars)
	usr.mind.store_memory("Explosive implant in [source] can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate.", 0, 0)
	to_chat(usr, "The explosive implant in [source] can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate.")
	addHear()
	return 1

/obj/item/weapon/implant/explosive/emp_act(severity)
	if(malfunction)
		return
	malfunction = MALFUNCTION_TEMPORARY
	switch(severity)
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
	spawn(20)
		malfunction--

/obj/item/weapon/implant/explosive/islegal()
	return 0

/obj/item/weapon/implant/explosive/proc/small_boom()
	if(iscarbon(implanted_mob))
		implanted_mob.visible_message("<span class='warning'>Something beeps inside [implanted_mob][implanted_bodypart ? "'s [implanted_bodypart.display_name]" : ""]!</span>")
		playsound(loc, 'sound/items/countdown.ogg', 75, 1, -3)
		spawn(25)
			if(ishuman(implanted_mob) && implanted_bodypart)
				//No tearing off these parts since it's pretty much killing
				//and you can't replace groins
				if(istype(implanted_bodypart, /datum/organ/external/chest) || istype(implanted_bodypart, /datum/organ/external/groin) || istype(implanted_bodypart, /datum/organ/external/head))
					implanted_bodypart.createwound(BRUISE, 60) //Mangle them instead
				else
					implanted_bodypart.droplimb(1)
			explosion(get_turf(implanted_mob), -1, -1, 2, 3, 3)
			qdel(src)

/obj/item/weapon/implant/explosive/nuclear/emp_act(severity)
	return



/obj/item/weapon/implant/chem
	name = "chem implant"
	desc = "Injects chemicals into the bloodstream after receiving a special encoded signal."
	allow_reagents = 1

/obj/item/weapon/implant/chem/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
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
	chemical_implants.Add(src)

/obj/item/weapon/implant/chem/Destroy()
	chemical_implants.Remove(src)
	..()

/obj/item/weapon/implant/chem/trigger(emote, mob/source)
	if(emote == "deathgasp")
		src.activate(src.reagents.total_volume)
	return


/obj/item/weapon/implant/chem/activate(var/tranfer_amount)
	if(!tranfer_amount || !src.implanted_mob)
		return 0
	var/mob/living/carbon/implanted_carbon = src.implanted_mob
	src.reagents.trans_to(implanted_carbon, tranfer_amount)
	if(src.reagents.total_volume)
		to_chat(implanted_carbon, "You hear a faint *beep*.")
	else
		to_chat(implanted_carbon, "You hear a faint click.")
		spawn(0)
			qdel(src)
	return

/obj/item/weapon/implant/chem/emp_act(severity)
	if (malfunction)
		return
	malfunction = MALFUNCTION_TEMPORARY

	switch(severity)
		if(1)
			if(prob(60))
				activate(20)
		if(2)
			if(prob(30))
				activate(5)

	spawn(20)
		malfunction--

/obj/item/weapon/implant/chem/New()
	. = ..()
	create_reagents(50)

/obj/item/weapon/implant/loyalty
	name = "loyalty implant"
	desc = "Makes the recipient somewhat loyal to Nanotrasen. Mostly used to prevent brainwashing."
	implant_color = "#21FF55"

/obj/item/weapon/implant/loyalty/get_data()
		var/dat = {"<b>Implant Specifications:</b><BR>
					<b>Name:</b> Nanotrasen Employee Management Implant<BR>
					<b>Life:</b> Ten years.<BR>
					<b>Important Notes:</b> Personnel injected with this device tend to be much more loyal to the company.<BR>
					<HR>
					<b>Implant Details:</b><BR>
					<b>Function:</b> Contains a small pod of nanobots that manipulate the host's mental functions.<BR>
					<b>Special Features:</b> Will prevent and cure most forms of brainwashing.<BR>
					<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}
		return dat

/obj/item/weapon/implant/loyalty/attempt_implant(mob/target)
	if(!iscarbon(target))
		return 0
	var/mob/living/carbon/carbon_target = target
	for(var/obj/item/weapon/implant/implant in carbon_target)
		if(istype(implant, /obj/item/weapon/implant/traitor) && implant.implanted_mob == carbon_target)
			carbon_target.visible_message("<span class='big danger'>[carbon_target] seems to resist the implant!</span>", "<span class='danger'>You feel a strange sensation in your head that quickly dissipates.</span>")
			return 0
	if(isrevhead(carbon_target) || (iscultist(carbon_target) && veil_thickness >= CULT_ACT_II))
		carbon_target.visible_message("<span class='big danger'>[carbon_target] seems to resist the implant!</span>", "<span class='danger'>You feel the corporate tendrils of Nanotrasen try to invade your mind!</span>")
		return 0
	if(isrevnothead(carbon_target))
		var/datum/role/R = carbon_target.mind.GetRole(REV)
		R.Drop()
	if(carbon_target.mind && carbon_target.mind.GetRole(IMPLANTSLAVE))
		var/datum/role/R = carbon_target.mind.GetRole(IMPLANTSLAVE)
		R.Drop()

	to_chat(carbon_target, "<span class = 'notice'>You feel a surge of loyalty towards Nanotrasen. However, you don't really feel obligated to act any differently than before.</span>")
	return 1



/obj/item/weapon/implant/traitor
	name = "greytide implant"
	desc = "Greytide, Station Wide."
	icon_state = "implant_evil"
	case_color = "red"
	implant_color = "#DEDEDE"

/obj/item/weapon/implant/traitor/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Greytide Mind-Slave Implant<BR>
				<b>Life:</b> ??? <BR>
				<b>Important Notes:</b> Any humanoid injected with this implant will become loyal to the injector and the Greytide, unless of course the host is already loyal to someone else.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small pod of nanobots that manipulate the host's mental functions.<BR>
				<b>Special Features:</b> Glory to the Greytide!<BR>
				<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}
	return dat

/obj/item/weapon/implant/traitor/attempt_implant(mob/target, mob/user)
	if(!iscarbon(target))
		to_chat(user, "<span class='danger'>The implant doesn't seem to be compatible with [target]!</span>")
		return 0
	if(!target.mind)
		to_chat(user, "<span class='danger'>[target] lacks a mind to affect!</span>")
		return 0
	var/mob/living/carbon/carbon_target = target
	if(carbon_target == user)
		to_chat(user, "<span class='notice'>You feel quite stupid for doing that.</span>")
		if(isliving(user))
			user:brainloss += 10
		return 0
	for(var/obj/item/weapon/implant/implant in carbon_target)
		if(istype(implant, /obj/item/weapon/implant/traitor) || istype(implant, /obj/item/weapon/implant/loyalty))
			if(implant.implanted_mob == carbon_target)
				carbon_target.visible_message("<span class='big danger'>[carbon_target] seems to resist the implant!</span>", "<span class='danger'>You feel a strange sensation in your head that quickly dissipates.</span>")
				return 0
	if(istraitor(carbon_target))
		carbon_target.visible_message("<span class='big danger'>[carbon_target] seems to resist the implant!</span>", "<span class='danger'>You feel a familiar sensation in your head that quickly dissipates.</span>")
		return 0
	carbon_target.implanting = 1
	to_chat(carbon_target, "<span class = 'notice'>You feel an undeniable surge of loyalty towards [user.name].</span>")

	var/datum/faction/greytide_faction = find_active_faction_by_typeandmember(/datum/faction/syndicate/greytide, null, user.mind)
	if(!greytide_faction)
		greytide_faction = ticker.mode.CreateFaction(/datum/faction/syndicate/greytide, 0, 1)
		greytide_faction.HandleNewMind(user.mind)

	if(!greytide_faction.HandleRecruitedMind(carbon_target.mind))
		visible_message("<span class = 'warning'>[carbon_target]'s head begins to glow a deep red - it looks like it's going to explode!</span>")
		spawn(3 SECONDS)
			var/datum/organ/external/head/head_organ = carbon_target.get_organ(LIMB_HEAD)
			head_organ.explode()
			log_admin("[ckey(user.key)] has just exploded [ckey(carbon_target.key)] after the attempt to mind-slave them using a Greytide implant failed.")
		return 0
	to_chat(carbon_target, "<B><span class = 'big warning'>You've been shown the ways of the Greytide by [user.name]!</B> You now must lay down your life to protect them and assist in their goals at any cost.</span>")
	greytide_faction.forgeObjectives()
	update_faction_icons()
	log_admin("[ckey(user.key)] has mind-slaved [ckey(carbon_target.key)] using a Greytide implant.")
	return 1

/obj/item/weapon/implant/adrenalin
	name = "adrenalin implant"
	desc = "When activated, this implant removes all stuns and knockdowns."
	case_color = "red"
	var/uses

/obj/item/weapon/implant/adrenalin/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
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
	if(src.uses < 1)
		return 0
	if(emote == "pale")
		src.uses--
		to_chat(source, "<span class = 'notice'>You feel a sudden surge of energy!</span>")
		source.SetStunned(0)
		source.SetKnockdown(0)
		source.SetParalysis(0)


/obj/item/weapon/implant/adrenalin/attempt_implant(mob/source)
	source.mind.store_memory("The adrenalin implant can be activated by using the pale emote, <B>say *pale</B> to attempt to activate.", 0, 0)
	to_chat(source, "The adrenalin implant can be activated by using the pale emote, <B>say *pale</B> to attempt to activate.")
	return 1




/obj/item/weapon/implant/death_alarm
	name = "death alarm implant"
	desc = "An alarm which monitors host vital signs and transmits a radio message upon death."
	var/mobname = "Will Robinson"

/obj/item/weapon/implant/death_alarm/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
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
	if(!implant_status || !implanted_mob || timestopped)
		return

	if(isnull(implanted_mob)) // If the mob got gibbed
		if(loc && loc:timestopped)
			return
		activate()
	else if(implanted_mob.isDead())
		if(implanted_mob.timestopped)
			return
		activate("death")

/obj/item/weapon/implant/death_alarm/activate(var/cause) //God I don't know what the fuck this is, let's just let this thing lie
	if(!implanted_mob)
		return
	var/area/t = get_area(implanted_mob)
	src.name = "\improper [mobname]'s death alarm"
	var/datum/speech/speech = create_speech("[mobname] has died in",1459,src)
	speech.name="[mobname]'s Death Alarm"
	speech.job="Death Alarm"
	speech.set_language(LANGUAGE_GALACTIC_COMMON)
	switch(cause)
		if("death")
			if(!announcement_intercom || !istype(announcement_intercom))
				announcement_intercom = new(null)

			if(istype(t, /area/syndicate_station) || istype(t, /area/syndicate_mothership) || istype(t, /area/shuttle/syndicate_elite))
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
	returnToPool(speech)

/obj/item/weapon/implant/death_alarm/emp_act(severity)
	if(malfunction)
		return
	malfunction = MALFUNCTION_TEMPORARY

	activate("emp")
	if(severity == 1)
		if(prob(40))
			meltdown()
		else if(prob(60))
			malfunction = MALFUNCTION_PERMANENT
		processing_objects.Remove(src)

	spawn(20)
		malfunction--

/obj/item/weapon/implant/death_alarm/attempt_implant(mob/source as mob)
	mobname = source.real_name
	processing_objects.Add(src)
	return 1



/obj/item/weapon/implant/compressed
	name = "compressed matter implant"
	desc = "The recipient is capable of storing a single item within this bluespace-compressed implant."
	icon_state = "implant_evil"
	case_color = "red"
	var/activation_emote = "sigh"
	var/obj/item/scanned = null
	implant_color = "#94593A"

/obj/item/weapon/implant/compressed/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Nanotrasen \"Profit Margin\" Class Employee Lifesign Sensor<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Alerts crew to crewmember death.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a compact radio signaler that triggers when the host's lifesigns cease.<BR>
				<b>Special Features:</b> Alerts crew to crewmember death.<BR>
				<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
	return dat

/obj/item/weapon/implant/compressed/trigger(emote, mob/source)
	if(!scanned)
		return 0

	if(emote == src.activation_emote)
		to_chat(source, "The air glows as \the [scanned.name] uncompresses.")
		activate()

/obj/item/weapon/implant/compressed/activate()
	if(implanted_mob)
		implanted_mob.put_in_hands(scanned)
	else
		scanned.forceMove(get_turf(src))
	qdel(src)

/obj/item/weapon/implant/compressed/attempt_implant(mob/source)
	src.activation_emote = input("Choose activation emote:") in list("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
	if (source.mind)
		source.mind.store_memory("Compressed matter implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
	to_chat(source, "The compressed matter implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.")
	return 1

/obj/item/weapon/implant/compressed/islegal()
	return 0



/obj/item/weapon/implant/cortical
	name = "cortical stack"
	desc = "A fist-sized mass of biocircuits and chips. Not very useful."



/obj/item/weapon/implant/peace
	name = "pax implant"
	desc = "A bean-shaped implant with a single embossed word - PAX - on it."
	var/pax_active = 0

/obj/item/weapon/implant/peace/Destroy()
	..()
	processing_objects.Remove(src)

/obj/item/weapon/implant/peace/meltdown()
	visible_message("<span class='warning'>\The [src] releases a dying hiss as it denatures!</span>")
	name = "denatured implant"
	desc = "A dead, hollow implant. Wonder what it used to be..."
	icon_state = "implant_melted"
	malfunction = MALFUNCTION_PERMANENT

/obj/item/weapon/implant/peace/process()
	var/mob/living/carbon/host = implanted_mob
	if(!istype(host))
		return

	if(host.isDead())
		malfunction = MALFUNCTION_PERMANENT

	if(malfunction == MALFUNCTION_PERMANENT)
		meltdown()
		processing_objects.Remove(src)
		return

	if(host.nutrition <= 0 || host.reagents.has_reagent(METHYLIN, 15))
		malfunction = MALFUNCTION_TEMPORARY
	else
		malfunction = 0

	if(malfunction == MALFUNCTION_TEMPORARY && pax_active)
		to_chat(host, "<span class = 'warning'>Your rage bubbles, \the [src] inside you is being suppressed!</span>")
		pax_active = 0

	if(!malfunction)
		if(!pax_active)
			to_chat(host, "<span class = 'warning'>Your rage cools, \the [src] inside you is active!</span>")
			pax_active = 1
		host.nutrition = max(host.nutrition - 0.15,0)


/obj/item/weapon/implant/peace/attempt_implant(mob/target)
	var/mob/living/carbon/carbon_target = target
	if(istype(carbon_target) && !malfunction)
		processing_objects.Add(src)
		to_chat(target, "<span class = 'warning'>You feel your desire to harm anyone slowly drift away...</span>")
		return 1
	else
		return 0

/obj/item/weapon/implant/peace/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Pax Implant<BR>
				<b>Manufacturer:</b> Ouroboros Medical<BR>
				<b>Effect:</b> Makes the host incapable of committing violent acts.
				<b>Important Notes:</b> Effect accomplished by paralyzing parts of the brain. This effect is neutralized by 15u or greater of Methylin.<BR>
				<b>Life:</b> Sustained as long as it remains within a host. Survives on the host's nutrition. Dies upon removal.<BR>"}
	return dat

/obj/item/weapon/implant/health
	name = "health implant"
	desc = "Monitors th ."
	var/healthstring = ""

/obj/item/weapon/implant/health/proc/sensehealth()
	if(!implant_status)
		return "ERROR"
	else
		if(isliving(implanted_mob))
			var/mob/living/target = implanted_mob
			healthstring = "[round(target.getOxyLoss())] - [round(target.getFireLoss())] - [round(target.getToxLoss())] - [round(target.getBruteLoss())]"
		if(!healthstring)
			healthstring = "ERROR"
		return healthstring
