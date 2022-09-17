//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/hsboxspawn = 1
var/list
		hrefs = list(
					"hsbsuit" = "Suit Up (Space Travel Gear)",
					"hsbmetal" = "Spawn 50 Metal",
					"hsbglass" = "Spawn 50 Glass",
					"hsbplasma" = "Spawn 50 Plasma",
					"phazon" = "Spawn 50 Phazon",
					"hsbregulator" = "Spawn Air Regulator",
					"hsbfilter" = "Spawn Air Filter",
					"hsbcanister" = "Spawn Canister",
					"hsbfueltank" = "Spawn Welding Fuel Tank",
					"hsbwater	tank" = "Spawn Water Tank",
					"hsbtoolbox" = "Spawn Toolbox",
					"hsbmedkit" = "Spawn Medical Kit",
					"revive" = "Rejuvenate")

/mob/var/datum/hSB/sandbox = null
/mob/proc/CanBuild()
	if(ticker.mode.name == "sandbox")
		sandbox = new/datum/hSB
		sandbox.owner = src.ckey
		if(src.client.holder)
			sandbox.admin = 1
		verbs += /mob/proc/sandbox_panel
		verbs += /mob/proc/sandbox_spawn_atom

/mob/proc/sandbox_panel()
	set name = "Sandbox Panel"
	set category = "Sandbox"

	if(sandbox)
		sandbox.update()

var/global/list/banned_sandbox_types=list(
	// /obj/item/weapon/gun,
	// /obj/item/assembly,
	// /obj/item/device/camera,
	// /obj/item/weapon/cloaking_device,
	// /obj/item/weapon/dummy,
	// /obj/item/weapon/melee/energy/sword,
	// /obj/item/weapon/veilrender,
	/obj/item/weapon/reagent_containers/glass/bottle/wizarditis,
	// /obj/item/weapon/spellbook,
	/obj/machinery/singularity,
	// /obj/item/weapon/gun/energy/staff
	)

/proc/is_banned_type(typepath)
	for(var/btype in banned_sandbox_types)
		if(findtext("[typepath]", "[btype]")!=0)
			return 1
	return 0

/mob/proc/sandbox_spawn_atom(var/object as text)
	set category = "Sandbox"
	set desc = "Spawn any item or machine"
	set name = "Sandbox Spawn"

	var/list/types = typesof(/obj/item) + typesof(/obj/machinery)
	for(var/type in types)
		if(is_banned_type(type))
			types -= type
	var/list/matches = new()

	for(var/path in types)
		if(is_banned_type(path))
			continue
		if(findtext("[path]", object)!=0)
			matches += path

	if(matches.len==0)
		return

	var/chosen
	if(matches.len==1)
		chosen = matches[1]
	else
		chosen = input("Select an atom type", "Spawn Atom", matches[1]) as null|anything in matches
		if(!chosen)
			return
	if(is_banned_type(chosen))
		to_chat(src, "<span class='warning'>Denied.</span>")
		return
	new chosen(usr.loc)

	message_admins("\[SANDBOX\] [key_name(usr)] spawned [chosen] at ([usr.x],[usr.y],[usr.z])")
	//send2adminirc("\[SANDBOX\] [key_name(usr)] spawned [chosen] at ([usr.x],[usr.y],[usr.z])")
	feedback_add_details("admin_verb","hSBSA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/hSB
	var/owner = null
	var/admin = 0

/datum/hSB/proc/update()
	var/hsbpanel = "<center><b>h_Sandbox Panel</b></center><hr>"
	if(admin)

		hsbpanel += {"<b>Administration Tools:</b><br>
			- <a href=\"?\ref[src];hsb=hsbtobj\">Toggle Object Spawning</a><br><br>"}
	hsbpanel += "<b>Regular Tools:</b><br>"
	for(var/T in hrefs)
		hsbpanel += "- <a href=\"?\ref[src];hsb=[T]\">[hrefs[T]]</a><br>"
	if(hsboxspawn)
		hsbpanel += "- <a href=\"?\ref[src];hsb=hsbobj\">Spawn Object</a><br><br>"
	usr << browse(hsbpanel, "window=hsbpanel")

/datum/hSB/Topic(href, href_list)
	if(!(src.owner == usr.ckey))
		return
	if(!usr)
		return //I guess this is possible if they log out or die with the panel open? It happened.
	if(href_list["hsb"])
		switch(href_list["hsb"])
			if("revive")
				if(istype(usr,/mob/living))
					var/mob/living/M = usr
					M.revive()
			if("hsbtobj")
				if(!admin)
					return
				if(hsboxspawn)
					to_chat(world, "<b>Sandbox:  [usr.key] has disabled object spawning!</b>")
					hsboxspawn = 0
					return
				if(!hsboxspawn)
					to_chat(world, "<b>Sandbox:  [usr.key] has enabled object spawning!</b>")
					hsboxspawn = 1
					return
			if("hsbsuit")
				var/mob/living/carbon/human/P = usr
				P.drop_all()
				P.wear_suit = new/obj/item/clothing/suit/space/nasavoid(P)
				P.wear_suit.hud_layerise()
				P.head = new/obj/item/clothing/head/helmet/space/nasavoid(P)
				P.head.hud_layerise()
				P.wear_mask = new/obj/item/clothing/mask/gas(P)
				P.wear_mask.hud_layerise()
				P.back = new/obj/item/weapon/tank/jetpack/void(P)
				P.back.hud_layerise()
				P.regenerate_icons()
			if("hsbmetal")
				var/obj/item/stack/sheet/hsb = new /obj/item/stack/sheet/metal(get_turf(usr))
				hsb.amount = 50
				hsb.forceMove(usr.loc)
			if("hsbglass")
				var/obj/item/stack/sheet/hsb = new/obj/item/stack/sheet/glass/glass
				hsb.amount = 50
				hsb.forceMove(usr.loc)
			if("hsbplasma")
				var/obj/item/stack/sheet/hsb = new/obj/item/stack/sheet/mineral/plasma
				hsb.amount = 50
				hsb.forceMove(usr.loc)
			if("phazon")
				var/obj/item/stack/sheet/hsb = new/obj/item/stack/sheet/mineral/phazon
				hsb.amount = 50
				hsb.forceMove(usr.loc)
			if("hsbcanister")
				var/list/hsbcanisters = typesof(/obj/machinery/portable_atmospherics/canister/) - /obj/machinery/portable_atmospherics/canister/
//					hsbcanisters -= /obj/machinery/portable_atmospherics/canister/sleeping
				var/hsbcanister = input(usr, "Choose a canister to spawn.", "Sandbox:") in hsbcanisters + "Cancel"
				if(!(hsbcanister == "Cancel"))
					new hsbcanister(usr.loc)
			if("hsbfueltank")
				new /obj/structure/reagent_dispensers/fueltank(usr.loc)
			if("hsbwatertank")
				new /obj/structure/reagent_dispensers/watertank(usr.loc)
			if("hsbtoolbox")
				var/obj/item/weapon/storage/hsb = new/obj/item/weapon/storage/toolbox/mechanical
				for(var/obj/item/device/radio/T in hsb)
					qdel(T)
				new/obj/item/tool/crowbar (hsb)
				hsb.forceMove(usr.loc)
			if("hsbmedkit")
				var/obj/item/weapon/storage/firstaid/hsb = new/obj/item/weapon/storage/firstaid/regular
				hsb.forceMove(usr.loc)
