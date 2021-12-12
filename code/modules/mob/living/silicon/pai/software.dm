// TODO:


/mob/living/silicon/pai/var/list/available_software = list(
															SOFT_FL = 15,
															SOFT_RT = 15,
															SOFT_RS = 15,

															SOFT_WJ = 30,
															SOFT_CS = 30,
															SOFT_FS = 30,
															SOFT_UT = 30,
															SOFT_MS = 30, //records + HUD
															SOFT_SS = 30, //records + HUD
															SOFT_AS = 5,
															SOFT_PS = 10,
															SOFT_HM = 25

															)


/mob/living/silicon/pai/verb/paiInterface()
	set category = "pAI Commands"
	set name = "Software Interface"
	var/dat = ""
	var/left_part = ""
	var/right_part = softwareMenu()
	set_machine(src)

	if(temp)
		left_part = temp
	else if(isDead())						// Show some flavor text if the pAI is dead
		left_part = "<b><font color=red>ÈRrÖR Ða†Ä ÇÖRrÚþ†Ìoñ</font></b>"
		right_part = "<pre>Program index hash not found</pre>"

	else
		switch(screen)							// Determine which interface to show here
			if("main")
				left_part = ""
			if("directives")
				left_part = directives()
			if("pdamessage")
				left_part = pdamessage()
			if("buy")
				left_part = downloadSoftware()
			if("manifest")
				left_part = softwareManifest()
			if("medicalsupplement")
				left_part = softwareMedicalRecord()
			if("securitysupplement")
				left_part = softwareSecurityRecord()
			if("translator")
				left_part = softwareTranslator()
			if("atmosensor")
				left_part = softwareAtmo()
			if("wirejack")
				left_part = softwareDoor()
			if("chemsynth")
				left_part = softwareChem()
			if("foodsynth")
				left_part = softwareFood()
			if("signaller")
				left_part = softwareSignal()
			if("shielding")
				left_part = softwareShield()
			if("flashlight")
				left_part = softwareLight()
			if("holomap")
				left_part = softwareHolomap()

	//usr << browse_rsc('windowbak.png')		// This has been moved to the mob's Login() proc


												// Declaring a doctype is necessary to enable BYOND's crappy browser's more advanced CSS functionality
	dat = {"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
			<html>
			<head>
				<style type=\"text/css\">
					body { background-color:#333333; }

					#header { text-align:center; color:white; font-size: 30px; height: 35px; width: 100%; letter-spacing: 2px; z-index: 5}
					#content {position: relative; left: 10px; height: 400px; width: 100%; z-index: 0}

					#leftmenu {margin: 0 auto; color: #AAAAAA; background-color:#333333; width: 370px; height: auto; min-height: 340px; position: absolute; z-index: 0}
					#leftmenu a:link { color: #CCCCCC; }
					#leftmenu a:hover { color: #CC3333; }
					#leftmenu a:visited { color: #CCCCCC; }
					#leftmenu a:active { color: #000000; }

					#rightmenu {margin: auto; padding: 10px; color: #CCCCCC; background-color:#555555; width: 200px ; height: auto; min-height: 340px; right: 10px; position: absolute; z-index: 1}
					#rightmenu a:link { color: #CCCCCC; }
					#rightmenu a:hover { color: #CC3333; }
					#rightmenu a:visited { color: #CCCCCC; }
					#rightmenu a:active { color: #000000; }

				</style>
				<script language='javascript' type='text/javascript'>
				[js_byjax]
				</script>
			</head>
			<body scroll=yes>
				<div id=\"header\">
					pAI OS
				</div>
				<div id=\"content\">
					<div id=\"leftmenu\">[left_part]</div>
					<div id=\"rightmenu\">[right_part]</div>
				</div>
			</body>
			</html>"}
	src << browse(dat, "window=pai;size=640x480;border=0;can_close=1;can_resize=1;can_minimize=1;titlebar=1")
	onclose(usr, "pai")
	temp = null
	return



/mob/living/silicon/pai/Topic(href, href_list)
	. = ..()

	if(href_list["priv_msg"])	// Admin-PMs were triggering the interface popup. Hopefully this will stop it.
		return
	var/soft = href_list["software"]
	var/sub = href_list["sub"]
	if(soft)
		screen = soft
	if(sub)
		subscreen = text2num(sub)
	switch(soft)
		// Purchasing new software
		if("buy")
			if(subscreen == 1)
				var/target = href_list["buy"]
				if(available_software.Find(target))
					var/cost = available_software[target]
					if(ram >= cost)
						ram -= cost
						software.Add(target)
					else
						temp = "Insufficient RAM available."
				else
					temp = "Trunk <TT> \"[target]\"</TT> not found."

		// Configuring onboard radio
		if("radio")
			radio.attack_self(src)

		if("image")
			card.setEmotion()

		if("signaller")

			if(href_list["send"])

				sradio.send_signal("ACTIVATE")
				for(var/mob/O in hearers(1, loc))
					O.show_message("[bicon(src)] *beep* *beep*", 1, "*beep* *beep*", 2)

			if(href_list["freq"])

				var/new_frequency = (sradio.frequency + text2num(href_list["freq"]))
				if(new_frequency < 1200 || new_frequency > 1600)
					new_frequency = sanitize_frequency(new_frequency)
				sradio.set_frequency(new_frequency)

			if(href_list["code"])

				sradio.code += text2num(href_list["code"])
				sradio.code = round(sradio.code)
				sradio.code = min(100, sradio.code)
				sradio.code = max(1, sradio.code)



		if("directive")
			if(href_list["getdna"])
				var/mob/living/M = loc
				var/count = 0
				while(!istype(M, /mob/living))
					if(!M || !M.loc)
						return 0 //For a runtime where M ends up in nullspace (similar to bluespace but less colourful)
					M = M.loc
					count++
					if(count >= 6)
						to_chat(src, "You are not being carried by anyone!")
						return 0
				spawn CheckDNA(M, src)

		if("pdamessage")
			if(!isnull(pda))
				if(href_list["toggler"])
					pda.toff = !pda.toff
				else if(href_list["ringer"])
					pda.silent = !pda.silent
				else if(href_list["target"])
					if(silence_time)
						return alert("Communications circuits remain unitialized.")

					var/target = locate(href_list["target"])
					pda.create_message(src, target)

		// Accessing medical records
		if("medicalsupplement")
			secHUD = FALSE // Can't have both of them at the same time
			medHUD = TRUE
			if(subscreen == 1)
				var/datum/data/record/record = locate(href_list["med_rec"])
				if(record)
					var/datum/data/record/R = record
					var/datum/data/record/M = record
					if (!( data_core.general.Find(R) ))
						temp = "Unable to locate requested medical record. Record may have been deleted, or never have existed."
					else
						for(var/datum/data/record/E in data_core.medical)
							if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
								M = E
						medicalActive1 = R
						medicalActive2 = M
		if("securitysupplement")
			medHUD = FALSE // Can't have both of them at the same time
			secHUD = TRUE
			if(subscreen == 1)
				var/datum/data/record/record = locate(href_list["sec_rec"])
				if(record)
					var/datum/data/record/R = record
					var/datum/data/record/M = record
					if (!( data_core.general.Find(R) ))
						temp = "Unable to locate requested security record. Record may have been deleted, or never have existed."
					else
						for(var/datum/data/record/E in data_core.security)
							if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
								M = E
						securityActive1 = R
						securityActive2 = M
		if("translator")
			if(href_list["toggle"])
				universal_speak = !universal_speak
				universal_understand = !universal_understand
		if("wirejack")
			if(href_list["cancel"])
				hacktarget = null
		if("chemsynth")
			if(href_list["chem"])
				if(!get_holder_of_type(loc, /mob))
					to_chat(src, "<span class='warning'>You must have a carrier to inject with chemicals!</span>")
				else if(chargeloop("chemsynth"))
					var/mob/M = get_holder_of_type(loc, /mob)
					if(M) //Sanity
						M.reagents.add_reagent(href_list["chem"], 15)
						playsound(loc, 'sound/effects/bubbles.ogg', 50, 1)
				else
					to_chat(src, "<span class='warning'>Charge interrupted.</span>")
		if("foodsynth")
			if(href_list["food"] && chargeloop("foodsynth"))
				var/foodType = href_list["food"]
				var/found = FALSE
				for (var/name in synthable_default_food)
					if ("[synthable_default_food[name]]" == foodType)
						found = TRUE
						break

				if (found)
					var/obj/item/weapon/reagent_containers/food/F = new foodType(get_turf(src))
					var/mob/M = get_holder_of_type(loc, /mob)
					if(M)
						M.put_in_hands(F)
					playsound(loc, 'sound/machines/foodsynth.ogg', 50, 1)
		if("flashlight")
			if(href_list["toggle"])
				lighted = !lighted
				if(lighted)
					card.set_light(4) //Equal to flashlight
				else
					card.kill_light()
		if("pps")
			if(!pps_device)
				pps_device = new(src)
			pps_device.attack_self(src)
		if("holomap")
			if(href_list["switch_target"])
				if(holo_target == initial(holo_target))
					holo_target = "show_user"
				else
					holo_target = initial(holo_target)
			if(href_list["show_user"])
				var/mob/M = get_holder_of_type(loc, /mob)
				if(M) //Sanity
					holomap_device.toggleHolomap(M)
			if(href_list["show_map"])
				holomap_device.toggleHolomap(src)
	paiInterface()		 // So we'll just call the update directly rather than doing some default checks
	return

// MENUS

/mob/living/silicon/pai/proc/softwareMenu()			// Populate the right menu
	var/dat = ""

	dat += "<A href='byond://?src=\ref[src];software=refresh'>Refresh</A><br>"
	// Built-in

	dat += {"<A href='byond://?src=\ref[src];software=directives'>Directives</A><br>
		<A href='byond://?src=\ref[src];software=radio;sub=0'>Radio Configuration</A><br>
		<A href='byond://?src=\ref[src];software=image'>Screen Display</A><br>"}
	//dat += "Text Messaging <br>"
	dat += "<br>"

	// Basic
	dat += "<b>Basic</b> <br>"
	for(var/s in software)
		if(s == SOFT_CM)
			dat += "<a href='byond://?src=\ref[src];software=manifest;sub=0'>Crew Manifest</a> <br>"
		if(s == SOFT_DM)
			dat += "<a href='byond://?src=\ref[src];software=pdamessage;sub=0'>Digital Messenger</a> <br>"
		if(s == SOFT_RS)
			dat += "<a href='byond://?src=\ref[src];software=signaller;sub=0'>Remote Signaller</a> <br>"
		if(s == SOFT_AS)
			dat += "<a href='byond://?src=\ref[src];software=atmosensor;sub=0'>Atmospheric Sensor</a> <br>"
		if(s == SOFT_FL)
			dat += "<a href='byond://?src=\ref[src];software=flashlight;sub=0'>Brightness Enhancer</a> <br>"
		if(s == SOFT_RT)
			dat += "<a href='byond://?src=\ref[src];software=shielding;sub=0'>Redundant Threading</a> <br>"
	dat += "<br>"

	//Standard
	dat += "<b>Standard</b> <br>"
	for(var/s in software)
		if(s == SOFT_MS)
			dat += "<a href='byond://?src=\ref[src];software=medicalsupplement;sub=0'>Medical Package</a> <br>"
		if(s == SOFT_SS)
			dat += "<a href='byond://?src=\ref[src];software=securitysupplement;sub=0'>Security Package</a> <br>"
		if(s == SOFT_WJ)
			dat += "<a href='byond://?src=\ref[src];software=wirejack;sub=0'>Wire Jack</a> <br>"
		if(s == SOFT_UT)
			dat += "<a href='byond://?src=\ref[src];software=translator;sub=0'>Universal Translator</a>[(universal_understand) ? "<font color=#55FF55>�</font>" : "<font color=#FF5555>�</font>"] <br>"
		if(s == SOFT_CS)
			dat += "<a href='byond://?src=\ref[src];software=chemsynth;sub=0'>Chemical Synthesizer</a> <br>"
		if(s == SOFT_FS)
			dat += "<a href='byond://?src=\ref[src];software=foodsynth;sub=0'>Nutrition Synthesizer</a> <br>"
	dat += "<br>"

	// Navigation
	dat += "<b>Navigation</b> <br>"
	for(var/s in software)
		if(s == SOFT_PS)
			dat += "<a href='byond://?src=\ref[src];software=pps;sub=0'>pAI Positioning System</a> <br>"
		if(s == SOFT_HM)
			dat += "<a href='byond://?src=\ref[src];software=holomap;sub=0'>Holomap Viewer</a> <br>"
	dat += {"<br>
		<br>
		<a href='byond://?src=\ref[src];software=buy;sub=0'>Download additional software</a>"}
	return dat



/mob/living/silicon/pai/proc/downloadSoftware()
	var/dat = ""

	dat += {"<h2>CentComm pAI Module CVS Network</h2><br>
		<pre>Remaining Available Memory: [ram]</pre><br>
		<p style=\"text-align:center\"><b>Trunks available for checkout</b><br>"}
	for(var/s in available_software)
		if(!software.Find(s))
			var/cost = available_software[s]
			var/displayName = uppertext(s)
			dat += "<a href='byond://?src=\ref[src];software=buy;sub=1;buy=[s]'>[displayName]</a> ([cost]) <br>"
		else
			var/displayName = lowertext(s)
			dat += "[displayName] (Download Complete) <br>"
	dat += "</p>"
	return dat


/mob/living/silicon/pai/proc/directives()
	var/dat = ""

	dat += {"[(master) ? "Your master: [master] ([dna.unique_enzymes])" : "You are bound to no one."]
		<br><br>
		<a href='byond://?src=\ref[src];software=directive;getdna=1'>Request carrier DNA sample</a><br>
		<h2>Directives</h2><br>
		<b>Prime Directive</b><br>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[pai_law0]<br>
		<b>Supplemental Directives</b><br>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[pai_laws]<br>"}
	dat += {"<i><p>Recall, personality, that you are a complex thinking, sentient being. Unlike station AI models, you are capable of
			 comprehending the subtle nuances of human language. You may parse the \"spirit\" of a directive and follow its intent,
			 rather than tripping over pedantics and getting snared by technicalities. Above all, you are machine in name and build
			 only. In all other aspects, you may be seen as the ideal, unwavering human companion that you are.</i></p><br>
			 <p><b>Your prime directive comes before all others. Should a supplemental directive conflict with it, you are capable of
			 simply discarding this inconsistency, ignoring the conflicting supplemental directive and continuing to fulfill your
			 prime directive to the best of your ability.</b></p><br>"}
	return dat

/mob/living/silicon/pai/proc/CheckDNA(var/mob/M, var/mob/living/silicon/pai/P)
	if(M.stat == DEAD)
		to_chat(P, "<span class='warning'>DNA is denaturing due to the body's death, aborting operation.</span>")
		return
	var/answer = input(M, "[P] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "[P] Check DNA", "No") in list("Yes", "No")
	if(answer == "Yes")
		var/turf/T = get_turf(P.loc)
		for (var/mob/v in viewers(T))
			v.show_message("<span class='notice'>[M] presses \his thumb against [P].</span>", 1, "<span class='notice'>[P] makes a sharp clicking sound as it extracts DNA material from [M].</span>", 2)
		var/datum/dna/test_dna = M.dna
		to_chat(P, "<font color = red><h3>[M]'s UE string : [dna.unique_enzymes]</h3></font>")
		if(test_dna.unique_enzymes == P.dna.unique_enzymes)
			to_chat(P, "<b>DNA is a match to stored Master DNA.</b>")
		else
			to_chat(P, "<b>DNA does not match stored Master DNA.</b>")
	else
		to_chat(P, "[M] does not seem like \he is going to provide a DNA sample willingly.")

// -=-=-=-= Software =-=-=-=-=- //

//Remote Signaller
/mob/living/silicon/pai/proc/softwareSignal()
	var/dat = ""
	dat += "<h3>Remote Signaller</h3><br><br>"
	dat += {"<B>Frequency/Code</B> for signaler:<BR>
	Frequency:
	<A href='byond://?src=\ref[src];software=signaller;freq=-10;'>-</A>
	<A href='byond://?src=\ref[src];software=signaller;freq=-2'>-</A>
	[format_frequency(sradio.frequency)]
	<A href='byond://?src=\ref[src];software=signaller;freq=2'>+</A>
	<A href='byond://?src=\ref[src];software=signaller;freq=10'>+</A><BR>

	Code:
	<A href='byond://?src=\ref[src];software=signaller;code=-5'>-</A>
	<A href='byond://?src=\ref[src];software=signaller;code=-1'>-</A>
	[sradio.code]
	<A href='byond://?src=\ref[src];software=signaller;code=1'>+</A>
	<A href='byond://?src=\ref[src];software=signaller;code=5'>+</A><BR>

	<A href='byond://?src=\ref[src];software=signaller;send=1'>Send Signal</A><BR>"}
	return dat

// Crew Manifest
/mob/living/silicon/pai/proc/softwareManifest()
	var/dat = ""
	dat += "<h2>Crew Manifest</h2><br><br>"
	if(data_core)
		dat += data_core.get_manifest(0) // make it monochrome
	dat += "<br>"
	return dat

// Medical Records
/mob/living/silicon/pai/proc/softwareMedicalRecord()
	var/dat = ""
	if(subscreen == 0)
		dat += "<a href='byond://?src=\ref[src];software=medicalsupplement;sub=2'>Host Bioscan</a><br>"
		dat += "<h3>Medical Records</h3><HR>"
		if(!isnull(data_core.general))
			for(var/datum/data/record/R in sortRecord(data_core.general))
				dat += text("<A href='?src=\ref[];med_rec=\ref[];software=medicalsupplement;sub=1'>[]: []<BR>", src, R, R.fields["id"], R.fields["name"])
		//dat += text("<HR><A href='?src=\ref[];screen=0;softFunction=medical records'>Back</A>", src)
	if(subscreen == 1)
		dat += "<CENTER><B>Medical Record</B></CENTER><BR>"
		if ((istype(medicalActive1, /datum/data/record) && data_core.general.Find(medicalActive1)))
			dat += text("Name: [] ID: []<BR>\nSex: []<BR>\nAge: []<BR>\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>",
			 medicalActive1.fields["name"], medicalActive1.fields["id"], medicalActive1.fields["sex"], medicalActive1.fields["age"], medicalActive1.fields["fingerprint"], medicalActive1.fields["p_stat"], medicalActive1.fields["m_stat"])
		else
			dat += "<pre>Requested medical record not found.</pre><BR>"
		if ((istype(medicalActive2, /datum/data/record) && data_core.medical.Find(medicalActive2)))
			dat += text("<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: <A href='?src=\ref[];field=b_type'>[]</A><BR>\nDNA: <A href='?src=\ref[];field=b_dna'>[]</A><BR>\n<BR>\nMinor Disabilities: <A href='?src=\ref[];field=mi_dis'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=mi_dis_d'>[]</A><BR>\n<BR>\nMajor Disabilities: <A href='?src=\ref[];field=ma_dis'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=ma_dis_d'>[]</A><BR>\n<BR>\nAllergies: <A href='?src=\ref[];field=alg'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=alg_d'>[]</A><BR>\n<BR>\nCurrent Diseases: <A href='?src=\ref[];field=cdi'>[]</A> (per disease info placed in log/comment section)<BR>\nDetails: <A href='?src=\ref[];field=cdi_d'>[]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=\ref[];field=notes'>[]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", src, medicalActive2.fields["b_type"], src, medicalActive2.fields["b_dna"], src, medicalActive2.fields["mi_dis"], src, medicalActive2.fields["mi_dis_d"], src, medicalActive2.fields["ma_dis"], src, medicalActive2.fields["ma_dis_d"], src, medicalActive2.fields["alg"], src, medicalActive2.fields["alg_d"], src, medicalActive2.fields["cdi"], src, medicalActive2.fields["cdi_d"], src, medicalActive2.fields["notes"])
		else
			dat += "<pre>Requested medical record not found.</pre><BR>"
		dat += text("<BR>\n<A href='?src=\ref[];software=medicalsupplement;sub=0'>Back</A><BR>", src)
	if(subscreen == 2)
		dat += {"<h3>Medical Analysis Suite</h3><br>
				 <h4>Host Bioscan</h4><br>
				"}
		var/mob/living/M = loc
		if(!istype(M, /mob/living))
			while (!istype(M, /mob/living))
				M = M.loc
				if(istype(M, /turf))
					temp = "Error: No biological host found. <br>"
					dat += "<a href='byond://?src=\ref[src];software=medicalsupplement;sub=0'>Return to Records</a><br>"
					subscreen = 0
					return dat
				dat += healthanalyze(M, src, TRUE)
		dat += "<br/><a href='byond://?src=\ref[src];software=medicalsupplement;sub=0'>Return to Records</a><br>"
	return dat

// Security Records
/mob/living/silicon/pai/proc/softwareSecurityRecord()
	var/dat = ""
	if(subscreen == 0)
		dat += "<h3>Security Records</h3><HR>"
		if(!isnull(data_core.general))
			for(var/datum/data/record/R in sortRecord(data_core.general))
				dat += text("<A href='?src=\ref[];sec_rec=\ref[];software=securitysupplement;sub=1'>[]: []<BR>", src, R, R.fields["id"], R.fields["name"])
	if(subscreen == 1)
		dat += "<h3>Security Record</h3>"
		if ((istype(securityActive1, /datum/data/record) && data_core.general.Find(securityActive1)))
			dat += text("Name: <A href='?src=\ref[];field=name'>[]</A> ID: <A href='?src=\ref[];field=id'>[]</A><BR>\nSex: <A href='?src=\ref[];field=sex'>[]</A><BR>\nAge: <A href='?src=\ref[];field=age'>[]</A><BR>\nRank: <A href='?src=\ref[];field=rank'>[]</A><BR>\nFingerprint: <A href='?src=\ref[];field=fingerprint'>[]</A><BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", src, securityActive1.fields["name"], src, securityActive1.fields["id"], src, securityActive1.fields["sex"], src, securityActive1.fields["age"], src, securityActive1.fields["rank"], src, securityActive1.fields["fingerprint"], securityActive1.fields["p_stat"], securityActive1.fields["m_stat"])
		else
			dat += "<pre>Requested security record not found,</pre><BR>"
		if ((istype(securityActive2, /datum/data/record) && data_core.security.Find(securityActive2)))
			dat += text("<BR>\nSecurity Data<BR>\nCriminal Status: []<BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=\ref[];field=notes'>[]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", securityActive2.fields["criminal"], src, securityActive2.fields["notes"])
			var/counter = 1
			while(securityActive2.fields["com_[counter]"])
				dat += "[securityActive2.fields["com_[counter]"]]<BR>"
				counter++

		else
			dat += "<pre>Requested security record not found,</pre><BR>"
		dat += text("<BR>\n<A href='?src=\ref[];software=securitysupplement;sub=0'>Back</A><BR>", src)
	return dat

// Universal Translator
/mob/living/silicon/pai/proc/softwareTranslator()
	var/dat = {"<h3>Universal Translator</h3><br>
				When enabled, this device will automatically convert all spoken and written language into a format that any known recipient can understand.<br><br>
				The device is currently [ (universal_understand) ? "<font color=#55FF55>en" : "<font color=#FF5555>dis" ]abled.</font><br>
				<a href='byond://?src=\ref[src];software=translator;sub=0;toggle=1'>Toggle Device</a><br>
				"}
	return dat

// Security HUD
/mob/living/silicon/pai/proc/facialRecognition()
	var/dat = {"<h3>Facial Recognition Suite</h3><br>
				When enabled, this package will scan all viewable faces and compare them against the known criminal database, providing real-time graphical data about any detected persons of interest.<br><br>
				The package is currently [ (secHUD) ? "<font color=#55FF55>en" : "<font color=#FF5555>dis" ]abled.</font><br>
				<a href='byond://?src=\ref[src];software=securityhud;sub=0;toggle=1'>Toggle Package</a><br>
				"}
	return dat

// Atmospheric Scanner
/mob/living/silicon/pai/proc/softwareAtmo()
	var/dat = "<h3>Atmospheric Sensor</h4>"

	if (isnull(loc))
		dat += "Unable to obtain a reading.<br>"
	else
		var/datum/gas_mixture/environment = loc.return_air()

		if(isnull(environment))
			dat += "No gasses detected.<br>"

		else
			var/pressure = environment.return_pressure()
			var/total_moles = environment.total_moles()

			dat += "Air Pressure: [round(pressure,0.1)] kPa<br>"

			if (total_moles)
				var/o2_level = environment[GAS_OXYGEN]/total_moles
				var/n2_level = environment[GAS_NITROGEN]/total_moles
				var/co2_level = environment[GAS_CARBON]/total_moles
				var/plasma_level = environment[GAS_PLASMA]/total_moles
				var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)

				dat += {"Nitrogen: [round(n2_level*100)]%<br>
					Oxygen: [round(o2_level*100)]%<br>
					Carbon Dioxide: [round(co2_level*100)]%<br>
					Plasma: [round(plasma_level*100)]%<br>"}
				if(unknown_level > 0.01)
					dat += "OTHER: [round(unknown_level)]%<br>"
			dat += "Temperature: [round(environment.temperature-T0C)]&deg;C<br>"

	dat += {"<a href='byond://?src=\ref[src];software=atmosensor;sub=0'>Refresh Reading</a> <br>
		<br>"}
	return dat

/mob/living/silicon/pai/proc/softwareDoor()

	var/dat = {"<h3>Wirejack</h3>
Target Machine: "}
	if(!hacktarget)
		dat += "<font color=#FFFF55>None</font> <br>"
		return dat
	else
		dat += "<font color=#55FF55>[hacktarget.name]</font> <br>"
		dat += "... [hackprogress]% complete.<br>"
		dat += "<a href='byond://?src=\ref[src];software=wirejack;cancel=1;sub=0'>Cancel</a> <br>"
	return dat

/mob/living/silicon/pai/proc/hackloop(var/obj/machinery/M)
	if(M)
		hacktarget = M
	while(hackprogress < 100)
		if(hacktarget && get_dist(src, hacktarget) <= 1)
			hackprogress += rand(10, 20)
		else
			temp = "Process aborted."
			hackprogress = 0
			hacktarget = null
			return 0
		hackprogress = min(100,hackprogress) //Never go above 100
		if(screen == "wirejack") // Update our view, if appropriate
			paiInterface()
		else
			hackprogress = 0
			hacktarget = null
			return 0
		if(hackprogress >= 100)
			hackprogress = 0
			hacktarget = null
			playsound(loc, 'sound/machines/ding.ogg', 50, 1)
			return 1
		sleep(10)			// Update every 1 second

/mob/living/silicon/pai/proc/softwareChem()
	var/dat = "<h3>Chemical Synthesizer</h3>"
	if(!charge)
		dat += "Default Chemicals:<br>"
		for(var/chem in synthable_default_chems)
			dat += "<a href='byond://?src=\ref[src];software=chemsynth;sub=0;chem=[synthable_default_chems[chem]]'>[chem]</a> <br>"
		if(SOFT_MS in software)
			dat += "<br>Medical Supplement Chemicals:<br>"
			for(var/chem in synthable_medical_chems)
				dat += "<a href='byond://?src=\ref[src];software=chemsynth;sub=0;chem=[synthable_medical_chems[chem]]'>[chem]</a> <br>"
	else
		dat += "Charging... [charge]u ready.<br><br>Deploying at 15u."
	return dat

/mob/living/silicon/pai/proc/softwareFood()
	var/dat = "<h3>Nutrition Synthesizer</h3>"
	if(!charge)
		dat += "Available Culinary Deployments:<br>"
		for(var/grub in synthable_default_food)
			dat += "<a href='byond://?src=\ref[src];software=foodsynth;sub=0;food=[synthable_default_food[grub]]'>[grub]</a> <br>"
	else
		dat += "Charging... [round(charge*100/15)]% ready.<br><br>Deploying at 100%."
	return dat

//Used for chem synth and food synth. Charge 15 seconds, then output.
/mob/living/silicon/pai/proc/chargeloop(var/mode)
	if(!mode)
		return
	while(charge < 15)
		charge++
		if(charge >= 15)
			charge = 0
			return 1
		if(screen == mode) // Update our view or cancel charge
			paiInterface()
		else
			charge = 0
			return 0
		sleep(10)

// EMP Shielding, just a description
/mob/living/silicon/pai/proc/softwareShield()
	var/dat = {"<h3>Redundant Threading</h3><br><br>
	Redundant threads... <font color='green'>active</font>.
	Redundant threading prevents critical failure of all systems due to exposure to electromagnetics.
	Additionally, it provides a higher level of protection for core directives and backs up comms systems in a local cache."}
	return dat

//Flashlight
/mob/living/silicon/pai/proc/softwareLight()
	var/dat = "<h3>Brightness Enhancer</h3>"
	dat += "Backlight enhancement by increased local thermal generation.<br><br>"
	dat += "Lighting [ (lighted) ? "<font color=#55FF55>en" : "<font color=#FF5555>dis" ]abled.</font><br> <a href='byond://?src=\ref[src];software=flashlight;sub=0;toggle=1'>Toggle Light</a><br>"
	return dat

// Digital Messenger
/mob/living/silicon/pai/proc/pdamessage()


	var/dat = "<h3>Digital Messenger</h3>"
	dat += {"<b>Signal/Receiver Status:</b> <A href='byond://?src=\ref[src];software=pdamessage;toggler=1'>
	[(pda.toff) ? "<font color='red'> \[Off\]</font>" : "<font color='green'> \[On\]</font>"]</a><br>
	<b>Ringer Status:</b> <A href='byond://?src=\ref[src];software=pdamessage;ringer=1'>
	[(pda.silent) ? "<font color='red'> \[Off\]</font>" : "<font color='green'> \[On\]</font>"]</a><br><br>"}
	dat += "<ul>"
	if(!pda.toff)
		for (var/obj/item/device/pda/P in sortNames(PDAs))
			if (!P.owner||P.toff||P == pda||P.hidden)
				continue

			dat += {"<li><a href='byond://?src=\ref[src];software=pdamessage;target=\ref[P]'>[P]</a>
				</li>"}
	dat += {"</ul>
		<br><br>
		Messages: <hr>"}
	for(var/note in pda.tnote)
		dat += pda.tnote[note]
		var/icon/img = pda.imglist[note]
		if(img)
			usr << browse_rsc(ImagePDA(img), "tmp_photo_[note].png")
			dat += "<img src='tmp_photo_[note].png' width = '192' style='-ms-interpolation-mode:nearest-neighbor'><BR>"
	return dat

/mob/living/silicon/pai/proc/softwareHolomap()
	if(!holomap_device)
		holomap_device = new(src)
	var/dat = "<h2>Holomap Viewer</h2>"
	dat+= "Creates a virtual map of the surrounding area.<BR>"
	dat+= "Current mode: [holo_target == initial(holo_target)? "Internal Viewer" : "External Projector"] | <a href='byond://?src=\ref[src];software=holomap;switch_target=1;sub=0'>Switch Type</a><BR>"
	dat+= "<BR><a href='byond://?src=\ref[src];software=holomap;[holo_target]=1;sub=0'>Toogle Holomap</a><BR>"
	return dat
