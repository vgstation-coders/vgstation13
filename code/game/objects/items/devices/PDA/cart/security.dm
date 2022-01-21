/obj/item/weapon/cartridge/security
	name = "\improper R.O.B.U.S.T. Cartridge"
	icon_state = "cart-s"
	access_security = 1
	radio_type = /obj/item/radio/integrated/signal/bot/beepsky
	starting_apps = list(/datum/pda_app/cart/security_records,/datum/pda_app/cart/scanner/hailer)

/datum/pda_app/cart/security_records
	name = "Security Records"
	desc = "Access the crew security records history."
	category = "Security Functions"
	icon = "pda_cuffs"
	var/mode = 0
	var/datum/data/record/active1 = null //General
	var/datum/data/record/active2 = null //Security

/datum/pda_app/cart/security_records/get_dat()
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

/datum/pda_app/cart/scanner/hailer
	name = "Enable Integrated Hailer"
	base_name = "Integrated Hailer"
	desc = "Used to hail a secbot to a location."
	category = "Security Functions"
	icon = "pda_signaler"
	app_scanmode = SCANMODE_HAILER

/obj/item/weapon/cartridge/detective
	name = "\improper D.E.T.E.C.T. Cartridge"
	icon_state = "cart-s"
	access_security = 1
	access_medical = 1
	access_manifest = 1
	starting_apps = list(
		/datum/pda_app/cart/medical_records,
		/datum/pda_app/cart/scanner/medical,
		/datum/pda_app/cart/security_records,
		/datum/pda_app/cart/scanner/hailer,
		)

/obj/item/weapon/cartridge/lawyer
	name = "\improper P.R.O.V.E. Cartridge"
	icon_state = "cart-s"
	fax_pings = TRUE
	access_security = 1
	starting_apps = list(/datum/pda_app/cart/security_records,/datum/pda_app/cart/scanner/hailer)