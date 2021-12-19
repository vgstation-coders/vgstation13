/obj/item/device/paicard
	name = "personal AI device"
	icon = 'icons/obj/pda.dmi'
	icon_state = "pai"
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	flags = FPRINT
	slot_flags = SLOT_BELT
	origin_tech = Tc_PROGRAMMING + "=2"
	var/looking_for_personality = FALSE
	var/mob/living/silicon/pai/pai
	var/last_ping_time = 0
	var/ping_cooldown = 5 SECONDS

/obj/item/device/paicard/New()
	..()
	paicard_list.Add(src)

#ifdef DEBUG_ROLESELECT
/obj/item/device/paicard/test/New()
	looking_for_personality = TRUE
	paiController.findPAI(src, usr)
#endif

/obj/item/device/paicard/Destroy()
	paicard_list.Remove(src)
	//Will stop people throwing friend pAIs into the singularity so they can respawn
	if(!isnull(pai))
		pai.death(0)
	..()

/obj/item/device/paicard/attack_self(mob/user)
	if(!in_range(src, user))
		return
	user.set_machine(src)
	var/dat = "<TT><B>Personal AI Device</B><BR>"
	if(pai && (!pai.dna || !pai.master))
		dat += "<a href='byond://?src=\ref[src];setdna=1'>Imprint Master DNA</a><br>"
	if(pai)
		dat += {"Installed Personality: [pai.name]<br>
			Prime directive: <br>[pai.pai_law0]<br>
			Additional directives: <br>[pai.pai_laws]<br>
			<a href='byond://?src=\ref[src];setlaws=1'>Configure Directives</a><br>
			<br>
			<h3>Device Settings</h3><br>"}
		if(pai.radio)
			dat += "<b>Radio Uplink</b><br>"
			dat += "Transmit: <A href='byond://?src=\ref[src];wires=[WIRE_TRANSMIT]'>[(pai.radio.wires.IsIndexCut(WIRE_TRANSMIT)) ? "Disabled" : "Enabled"]</A><br>"
			dat += "Receive: <A href='byond://?src=\ref[src];wires=[WIRE_RECEIVE]'>[(pai.radio.wires.IsIndexCut(WIRE_RECEIVE)) ? "Disabled" : "Enabled"]</A><br>"
		else
			dat += {"<b>Radio Uplink</b><br>
				<font color=red><i>Radio firmware not loaded. Please install a pAI personality to load firmware.</i></font><br>"}
		dat += "<A href='byond://?src=\ref[src];wipe=1'>\[Wipe current pAI personality\]</a><br>"
	else
		if(looking_for_personality)
			dat += {"Searching for a personality...
				<A href='byond://?src=\ref[src];request=1'>\[View available personalities\]</a><br>"}
		else
			dat += {"No personality is installed.<br>
				<A href='byond://?src=\ref[src];request=1'>\[Request personal AI personality\]</a><br>
				Each time this button is pressed, a request will be sent out to any available personalities. Check back often and alot time for personalities to respond. This process could take anywhere from 15 seconds to several minutes, depending on the available personalities' timeliness."}
	user << browse(dat, "window=paicard")
	onclose(user, "paicard")

/obj/item/device/paicard/attack_ghost(var/mob/dead/observer/O)
	if(looking_for_personality&&paiController.check_recruit(O))
		paiController.recruitWindow(O)
	else
		if(last_ping_time + ping_cooldown <= world.time)
			last_ping_time = world.time
			visible_message(message = "<span class='notice'>\The [src] pings softly.</span>", blind_message = "<span class='danger'>You hear what you think is a microwave finishing.</span>")
		else
			to_chat(O, "[src] is recharging. Try again in a few moments.")

/obj/item/device/paicard/Topic(href, href_list)
	if(!usr || usr.incapacitated() || !in_range(src, usr))
		return

	if(href_list["setdna"])
		if(pai.dna)
			return
		var/mob/NewMaster = usr
		if(!iscarbon(NewMaster))
			to_chat(NewMaster, "<font color=blue>You don't have any DNA, or your DNA is incompatible with this device.</font>")
		else
			pai.master = NewMaster.real_name
			pai.dna = NewMaster.dna
			to_chat(pai, "<font color = red><h3>You have been bound to a new master: [pai.master].</h3></font>")
		attack_self(usr)
	if(href_list["request"])
		usr << browse(null, "window=paicard")
		looking_for_personality = TRUE
		paiController.findPAI(src, usr)
	if(href_list["wipe"])
		var/confirm = input("Are you CERTAIN you wish to delete the current personality? This action cannot be undone.", "Personality Wipe") in list("Yes", "No")
		if(confirm == "Yes")
			to_chat(pai, "<font color = #ff0000><h2>You feel yourself slipping away from reality.</h2></font>")
			to_chat(pai, "<font color = #ff4d4d><h3>Byte by byte you lose your sense of self.</h3></font>")
			to_chat(pai, "<font color = #ff8787><h4>Your mental faculties leave you.</h4></font>")
			to_chat(pai, "<font color = #ffc4c4><h5>oblivion... </h5></font>")
			pai.death(0)
			removePersonality()
		attack_self(usr)
	if(href_list["wires"])
		var/t1 = text2num(href_list["wires"])
		if(pai.radio)
			pai.radio.wires.CutWireIndex(t1)
		attack_self(usr)
	if(href_list["setlaws"])
		var/newlaws = copytext(sanitize(input("Enter any additional directives you would like your pAI personality to follow. Note that these directives will not override the personality's allegiance to its imprinted master. Conflicting directives will be ignored.", "pAI Directive Configuration", pai.pai_laws) as message),1,MAX_MESSAGE_LEN)
		if(newlaws)
			pai.pai_laws = newlaws
			to_chat(pai, "Your supplemental directives have been updated. Your new directives are:")
			to_chat(pai, "Prime Directive : <br>[pai.pai_law0]")
			to_chat(pai, "Supplemental Directives: <br>[pai.pai_laws]")
		attack_self(usr)

// 		WIRE_SIGNAL = 1
//		WIRE_RECEIVE = 2
//		WIRE_TRANSMIT = 4

/obj/item/device/paicard/proc/setPersonality(mob/living/silicon/pai/personality)
	pai = personality
	overlays.Cut()
	overlays += image(icon=icon, icon_state = "pai-happy")

/obj/item/device/paicard/proc/removePersonality()
	pai = null
	overlays.Cut()

/obj/item/device/paicard/examine(mob/user)
	..()
	if(pai)
		pai.examine(user)

/obj/item/device/paicard/proc/setEmotion(var/emotion)

	var/static/list/possible_choices = list(
		"Happy" = "pai-happy",
		"Cat" = "pai-cat",
		"Extremely happy" = "pai-extremely-happy",
		"Face" = "pai-face",
		"Off" = "pai-off",
		"Sad" = "pai-sad",
		"Angry" = "pai-angry",
		"What" = "pai-what",
		"Longface" = "pai-longface",
		"Sick" = "pai-sick",
		"High" = "pai-high",
		"Love" = "pai-love",
		"Electric" = "pai-electric",
		"Pissed" = "pai-pissed",
		"Nose" = "pai-nose",
		"Kawaii" = "pai-kawaii",
		"Cry" = "pai-cry",
		"Thinking" = "pai-thinking",
	)

	var/selected = input(pai, "Select your new display image:", "Display image", "Happy") in null|possible_choices
	if(!selected)
		return
	var/chosen_icon_state = possible_choices[selected]
	ASSERT(chosen_icon_state)

	var/image/new_overlay = image(icon = icon, icon_state = chosen_icon_state)
	overlays.Cut()
	overlays += new_overlay
	var/mutable_appearance/pai_icon = new(src) //we also update the mob's appearance so it appears properly on the scoreboard.
	pai_icon.name = pai.name //But don't override their name
	pai_icon.verbs = pai.verbs //THANKS, LUMMOX
	pai.appearance = pai_icon

/obj/item/device/paicard/proc/alertUpdate()
	visible_message("<span class='notice'>[src] flashes a message across its screen, \"Additional personalities available for download.\"</span>", 1, "<span class='notice'>[src] bleeps electronically.</span>", 2)
	playsound(loc, 'sound/machines/paistartup.ogg', 50, 1)
	overlays += image(icon=icon, icon_state = "pai-off-notify")

/obj/item/device/paicard/proc/removeNotification()
	overlays.Cut()

/obj/item/device/paicard/emp_act(severity)
	pai?.emp_act(severity)
	..()

/obj/item/device/paicard/dropped(mob/user)
	if(pai && pai.holomap_device)
		pai.holomap_device.stopWatching()
