/obj/item/weapon/implant/death_alarm
	name = "death alarm implant"
	desc = "An alarm which monitors host vital signs and transmits a radio message upon death."
	var/mobname = "Will Robinson"

/obj/item/weapon/implant/death_alarm/get_data()
	return {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Nanotrasen \"Profit Margin\" Class Employee Lifesign Sensor<BR>
<b>Life:</b> Activates upon death.<BR>
<b>Important Notes:</b> Alerts crew to crewmember death.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a compact radio signaler that triggers when the host's lifesigns cease.<BR>
<b>Special Features:</b> Alerts crew to crewmember death.<BR>
<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}

/obj/item/weapon/implant/death_alarm/process()
	if (!imp_in || timestopped)
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

/obj/item/weapon/implant/death_alarm/implanted(mob/implanter)
	mobname = imp_in.real_name
	processing_objects.Add(src)

/obj/item/weapon/implant/death_alarm/handle_removal(var/mob/remover)
	makeunusable(75)
