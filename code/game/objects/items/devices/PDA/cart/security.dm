/obj/item/weapon/cartridge/security
	name = "\improper R.O.B.U.S.T. Cartridge"
	icon_state = "cart-s"
	radio_type = /obj/item/radio/integrated/signal/bot/beepsky
	starting_apps = list(
		/datum/pda_app/cart/security_records,
		/datum/pda_app/cart/scanner/hailer,
		/datum/pda_app/cart/secbot,
	)

/datum/pda_app/cart/security_records
	name = "Security Records"
	desc = "Access the crew security records history."
	category = "Security Functions"
	icon = "pda_cuffs"
	var/datum/data/record/active1 = null //General
	var/datum/data/record/active2 = null //Security

/datum/pda_app/cart/security_records/get_dat(var/mob/user)
	var/menu = ""
	switch(mode)
		if (0)
			menu = "<h4><span class='pda_icon pda_cuffs'></span> Security Record List</h4>"
			if(!isnull(data_core.general))
				for (var/datum/data/record/R in sortRecord(data_core.general))
					menu += "<a href='byond://?src=\ref[src];Security Records=\ref[R]'>[R.fields["id"]]: [R.fields["name"]]<br>"

			menu += "<br>"
		if(1)
			menu = "<h4><span class='pda_icon pda_cuffs'></span> Security Record</h4>"

			if (istype(active1, /datum/data/record) && (active1 in data_core.general))

				menu += {"Name: [active1.fields["name"]] ID: [active1.fields["id"]]<br>
					Sex: [active1.fields["sex"]]<br>
					Age: [active1.fields["age"]]<br>
					Rank: [active1.fields["rank"]]<br>
					Fingerprint: [active1.fields["fingerprint"]]<br>
					Physical Status: [active1.fields["p_stat"]]<br>
					Mental Status: [active1.fields["m_stat"]]<br>"}
			else
				menu += "<b>Record Lost!</b><br>"


			menu += {"<br>
				<h4><span class='pda_icon pda_cuffs'></span> Security Data</h4>"}
			if (istype(active2, /datum/data/record) && (active2 in data_core.security))

				menu += {"Criminal Status: [active2.fields["criminal"]]<br>
					Important Notes:<br>
					[active2.fields["notes"]]
					Comments/Log:<br>"}
				var/counter = 1
				while(active2.fields["com_[counter]"])
					menu += "[active2.fields["com_[counter]"]]<BR>"
					counter++

			else
				menu += "<b>Record Lost!</b><br>"

			menu += "<br>"
	return menu

/datum/pda_app/cart/security_records/Topic(href, href_list)
	if(..())
		return
	if(href_list["Security Records"])
		var/datum/data/record/R = locate(href_list["Security Records"])
		var/datum/data/record/S = locate(href_list["Security Records"])
		mode = 1
		if (R in data_core.general)
			for (var/datum/data/record/E in data_core.security)
				if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
					S = E
					break
			active1 = R
			active2 = S
	refresh_pda()

/datum/pda_app/cart/scanner/hailer
	base_name = "Integrated Hailer"
	desc = "Used to hail a criminal to a you."
	category = "Security Functions"
	icon = "pda_signaler"

/datum/pda_app/cart/scanner/hailer/afterattack(atom/A, mob/user, proximity_flag)
	if(!cart_device.integ_hailer)
		return
	cart_device.integ_hailer.cant_drop = 1
	cart_device.integ_hailer.afterattack(A, user, proximity_flag)

/datum/pda_app/cart/secbot
	name = "Security Bot Access"
	desc = "Used to control a secbot."
	category = "Security Functions"
	icon = "pda_cuffs"

/datum/pda_app/cart/secbot/get_dat(var/mob/user)
	var/dat = ""
	if (!cart_device)
		dat += {"<span class='pda_icon pda_cuffs'></span> Could not find radio peripheral connection <br/>"}
		return
	if (!istype(cart_device.radio, /obj/item/radio/integrated/signal/bot/beepsky))
		dat += {"<span class='pda_icon pda_cuffs'></span> Commlink bot error <br/>"}
		return
	dat += {"<span class='pda_icon pda_cuffs'></span><b>Securitron Interlink</b><br/>"}
	dat += {"<ul>"}
	for (var/obj/machinery/bot/secbot/seccie in bots_list)
		if (seccie.z != user.z)
			continue
		dat += {"<li>
				<i>[seccie]</i>: [seccie.return_status()] in [get_area_name(seccie)] <br/>
				<a href='?src=\ref[cart_device.radio];bot=\ref[seccie];command=summon;user=\ref[user]'>[seccie.summoned ? "Halt" : "Summon"]</a> <br/>
				<a href='?src=\ref[cart_device.radio];bot=\ref[seccie];command=switch_power;user=\ref[user]'>Turn [seccie.on ? "off" : "on"]</a> <br/>
				Auto-patrol: <a href='?src=\ref[cart_device.radio];bot=\ref[seccie];command=auto_patrol;user=\ref[user]'>[seccie.auto_patrol ? "Enabled" : "Disabled"]</a> <br/>
				Arrest for no ID: <a href='?src=\ref[cart_device.radio];bot=\ref[seccie];command=arrest_for_ids;user=\ref[user]'>[seccie.idcheck ? "Yes" : "No"]</a> <br/>
				</li>"}
	for (var/obj/machinery/bot/ed209/seccie in bots_list)
		dat += {"<li>
				<i>[seccie]</i>: [seccie.return_status()] in [get_area_name(seccie)] <br/>
				<a href='?src=\ref[cart_device.radio];bot=\ref[seccie];command=summon;user=\ref[user]'>[seccie.summoned ? "Halt" : "Summon"]</a> <br/>
				Auto-patrol: <a href='?src=\ref[cart_device.radio];bot=\ref[seccie];command=auto_patrol;user=\ref[user]'>[seccie.auto_patrol ? "Enabled" : "Disabled"]</a> <br/>
				Arrest for no ID: <a href='?src=\ref[cart_device.radio];bot=\ref[seccie];command=arrest_for_ids;user=\ref[user]'>[seccie.idcheck ? "Yes" : "No"]</a> <br/>
				</li>"}
	dat += {"</ul>"}
	return dat

/obj/item/weapon/cartridge/detective
	name = "\improper D.E.T.E.C.T. Cartridge"
	icon_state = "cart-s"
	starting_apps = list(
		/datum/pda_app/cart/medical_records,
		/datum/pda_app/cart/scanner/medical,
        /datum/pda_app/cart/medbot,
		/datum/pda_app/cart/security_records,
		/datum/pda_app/cart/scanner/hailer,
		/datum/pda_app/cart/secbot,
	)

/*/datum/pda_app/cart/scanner/detective
	base_name = "Forensic Scanner"
	desc = "Used to detect fingerprints or DNA on items."
	category = "Security Functions"
	var/list/stored_data = list()

/datum/pda_app/cart/scanner/detective/attack(mob/living/carbon/C, mob/living/user as mob)
	if (istype(C))
		if (!istype(C:dna, /datum/dna))
			to_chat(user, "<span class='notice'>No fingerprints found on [C]</span>")
		else if(!istype(C, /mob/living/carbon/monkey))
			if(!isnull(C:gloves))
				to_chat(user, "<span class='notice'>No fingerprints found on [C]</span>")
		else
			to_chat(user, text("<span class='notice'>[C]'s Fingerprints: [md5(C.dna.uni_identity)]</span>"))
		if ( !(C:blood_DNA) )
			to_chat(user, "<span class='notice'>No blood found on [C]</span>")
			if(C:blood_DNA)
				QDEL_NULL(C:blood_DNA)
		else
			to_chat(user, "<span class='notice'>Blood found on [C]. Analysing...</span>")
			spawn(15)
				for(var/blood in C:blood_DNA)
					to_chat(user, "<span class='notice'>Blood type: [C:blood_DNA[blood]]\nDNA: [blood]</span>")*/

/obj/item/weapon/cartridge/lawyer
	name = "\improper P.R.O.V.E. Cartridge"
	icon_state = "cart-s"
	fax_pings = TRUE
	starting_apps = list(
		/datum/pda_app/cart/security_records,
		/datum/pda_app/cart/scanner/hailer,
		/datum/pda_app/cart/secbot,
	)
