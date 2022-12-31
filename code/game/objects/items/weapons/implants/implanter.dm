/obj/item/weapon/implanter
	name = "implanter"
	desc = "A small device used to apply implants to people."
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	var/obj/item/weapon/implant/imp = null
	var/imp_type = null

/obj/item/weapon/implanter/proc/update()
	desc = initial(desc)
	icon_state = "implanter[imp? 1:0]"
	if(imp)
		desc += "<br>It is loaded with a [imp.name]."

/obj/item/weapon/implanter/attack(atom/target, mob/user)
	if(!user)
		return
	var/mob/living/carbon/M = target
	if(!istype(target))
		return
	if(!imp)
		if(istype(target, /obj/item/weapon/implant))
			var/obj/item/weapon/implant/timp = target
			timp.forceMove(src)
			user.show_message("<span class='warning'>You load \the [timp] into \the [src].</span>")
			imp = timp
			update()
			return
		if(ismob(target))
			user.show_message("<span class='warning'>There is no implant in \the [src].</span>")
			return
	if(M)
		M.visible_message("<span class='warning'>[user] is attempting to implant [M].</span>")
		add_attacklogs(user, M, "attempted to implant", imp)
		if(M == user || do_after(user, M, 5 SECONDS))
			if(imp)
				if(imp.insert(M, user.zone_sel.selecting, user))
					add_attacklogs(user, M, "implanted", imp)
					M.visible_message("<span class='warning'>[user] implants [M].</span>")
					imp = null
				else
					add_attacklogs(user, M, "failed to implant", imp)
					M.visible_message("<span class='warning'>[user] fails to implant [M].</span>")
				update()


/obj/item/weapon/implanter/New()
	..()
	if(imp_type)
		imp = new imp_type(src)
		update()

/obj/item/weapon/implanter/spesstv
	name = "promotional Spess.TV implanter"
	desc = "Does anyone know where the implanter went? I have a lockbox full of loyalty implants here..."

/obj/item/weapon/implanter/traitor
	name = "greytide conversion kit"
	desc = "Any humanoid injected with this implant will become loyal to the injector and the greytide, unless of course the host is already loyal to someone else."
	imp_type = /obj/item/weapon/implant/traitor

/obj/item/weapon/implanter/loyalty
	name = "implanter-loyalty"
	desc = "Any humanoid injected with this implant will become somewhat loyal to Nanotrasen and the local Heads of Staff."
	imp_type = /obj/item/weapon/implant/loyalty

/obj/item/weapon/implanter/freedom
	imp_type = /obj/item/weapon/implant/freedom

/obj/item/weapon/implanter/uplink
	imp_type = /obj/item/weapon/implant/uplink

/obj/item/weapon/implanter/explosive
	name = "implanter (E)"
	desc = "A small device used to apply implants to people. This one has a microphone and some circuitry attached for some reason."
	imp_type = /obj/item/weapon/implant/explosive

/obj/item/weapon/implanter/adrenalin
	name = "implanter-adrenalin"
	desc = "A small device used to apply implants to people. This one has a microphone and some circuitry attached for some reason."
	imp_type = /obj/item/weapon/implant/adrenalin

/obj/item/weapon/implanter/peace
	name = "implanter-pax"
	desc = "Any humanoid injected with this implant will become unable to perform most physical acts of aggression."
	imp_type = /obj/item/weapon/implant/peace

/obj/item/weapon/implanter/holy
	name = "implanter-holy"
	desc = "This microscripture implanter helps those affected by the Occult from manifesting unwanted abilities."
	imp_type = /obj/item/weapon/implant/holy

/obj/item/weapon/implanter/compressed
	name = "implanter (C)"
	icon_state = "cimplanter1"
	desc = "A small device used to apply implants to people. This one has a microphone and some circuitry attached for some reason."
	imp_type = /obj/item/weapon/implant/compressed

	var/list/forbidden_types = list()

/obj/item/weapon/implanter/compressed/update()
	if(imp)
		var/obj/item/weapon/implant/compressed/c = imp
		if(!c.scanned)
			icon_state = "cimplanter1"
		else
			icon_state = "cimplanter2"
	else
		icon_state = "cimplanter0"

/obj/item/weapon/implanter/compressed/attack(mob/M, mob/user)
	// Attacking things in your hands tends to make this fuck up.
	if(!istype(M))
		return
	var/obj/item/weapon/implant/compressed/c = imp
	if(!c)
		return
	if(c.scanned == null)
		to_chat(user, "Please scan an object with the implanter first.")
		return
	..()

/obj/item/weapon/implanter/compressed/afterattack(obj/item/I, mob/user)
	if(is_type_in_list(I, forbidden_types))
		to_chat(user, "<span class='warning'>A red light flickers on the implanter.</span>")
		return
	if(istype(I) && imp)
		var/obj/item/weapon/implant/compressed/c = imp
		if(c.scanned)
			if(istype(I,/obj/item/weapon/storage))
				..()
				return
			to_chat(user, "<span class='warning'>Something is already scanned inside the implant!</span>")
			return
		if(user)
			user.u_equip(I,0)
			user.update_icons()	//update our overlays
		c.scanned = I
		c.scanned.forceMove(c)
		update()

/obj/item/weapon/implanter/vocal
	name = "implanter (V)"
	desc = "A small device used to apply implants to people."
	imp_type = /obj/item/weapon/implant/vocal
	var/storedcode = ""			// code stored

/obj/item/weapon/implanter/vocal/attack_self(mob/user)
	if(istype(imp,imp_type))
		var/uselevel = alert(user, "Which level of complexity do you want to work with? Basic is a simple word replacement with regex, advanced is an implementation of NTSL as found in telecomms servers.", "Level of vocal manipulation", "Basic", "Advanced")
		if(uselevel == "Basic")
			var/obj/item/weapon/implant/vocal/V = imp
			var/input = html_encode(input(user, "Enter an input phrase, regex works here:", "Input phrase") as text)
			if(!input)
				return
			var/keepgoing = FALSE
			var/list/outputs = list()
			do
				var/output =  html_encode(input(user, "Enter an output phrase:", "Output phrase") as text)
				if(!output)
					return
				outputs.Add(output)
				keepgoing = alert(user, "Add another output?", "Output phrase", "Yes", "No") == "Yes"
			while(keepgoing)
			var/casesense = alert(user, "Case sensitive?", "Case sensitivity","Yes","No") == "Yes"
			if(input && outputs.len)
				V.filter.addPickReplacement(input,outputs,casesense)
		else if(uselevel == "Advanced")
			winshow(user, "Vocal Implant IDE", 1) // show the IDE
			winset(user, "vicode", "is-disabled=false")
			winset(user, "vicode", "text=\"\"")
			var/showcode = replacetext(storedcode, "\\\"", "\\\\\"")
			showcode = replacetext(storedcode, "\"", "\\\"")
			winset(user, "vicode", "text=\"[showcode]\"")
