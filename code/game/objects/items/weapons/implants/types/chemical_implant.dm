/obj/item/weapon/implant/chem
	name = "chem implant"
	desc = "Injects chemicals."
	allow_reagents = 1

/obj/item/weapon/implant/chem/New()
	..()
	create_reagents(50)
	chemical_implants.Add(src)

/obj/item/weapon/implant/chem/Destroy()
	chemical_implants.Remove(src)
	..()

/obj/item/weapon/implant/chem/get_data()
	return {"
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

/obj/item/weapon/implant/chem/trigger(emote, mob/source)
	if(emote == "deathgasp")
		src.activate(src.reagents.total_volume)

/obj/item/weapon/implant/chem/implanted(mob/implanter)
	imp_in.register_event(/event/emote, src, nameof(src::trigger()))

/obj/item/weapon/implant/chem/handle_removal(mob/remover)
	imp_in?.unregister_event(/event/emote, src, nameof(src::trigger()))
	makeunusable(75)

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
