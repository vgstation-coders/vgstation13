/obj/item/weapon/switchtool
	name = "switchtool"
	icon = 'icons/obj/switchtool.dmi'
	icon_state = "switchtool"
	desc = "A multi-deployable, multi-instrument, finely crafted multi-purpose tool. The envy of engineers everywhere."
	flags = FPRINT
	siemens_coefficient = 1
	force = 3
	w_class = W_CLASS_SMALL
	var/deploy_sound = "sound/weapons/switchblade.ogg"
	var/undeploy_sound = "sound/weapons/switchblade.ogg"
	throwforce = 6.0
	throw_speed = 3
	throw_range = 6
	starting_materials = list(MAT_IRON = 15000)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	origin_tech = Tc_MATERIALS + "=9;" + Tc_BLUESPACE + "=5"
	var/hmodule = null

	//the colon separates the typepath from the name
	var/list/obj/item/stored_modules = list("/obj/item/weapon/screwdriver:screwdriver" = null,
											"/obj/item/weapon/wrench:wrench" = null,
											"/obj/item/weapon/wirecutters:wirecutters" = null,
											"/obj/item/weapon/crowbar:crowbar" = null,
											"/obj/item/weapon/chisel:chisel" = null,
											"/obj/item/device/multitool:multitool" = null)
	var/obj/item/deployed //what's currently in use
	var/removing_item = /obj/item/weapon/screwdriver //the type of item that lets you take tools out

/obj/item/weapon/switchtool/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(istype(target, /obj/item/weapon/storage)) //we place automatically
		return
	if(deployed)
		if(!deployed.preattack(target, user))
			if(proximity_flag)
				target.attackby(deployed, user)
			deployed.afterattack(target, user, proximity_flag, click_parameters)
		if(deployed.loc != src)
			for(var/module in stored_modules)
				if(stored_modules[module] == deployed)
					stored_modules[module] = null
			undeploy()
		return TRUE

/obj/item/weapon/switchtool/New()
	..()
	for(var/module in stored_modules) //making the modules
		var/new_type = text2path(get_module_type(module))
		stored_modules[module] = new new_type(src)

/obj/item/weapon/switchtool/examine(mob/user)
	..()
	to_chat(user, "This one is capable of holding [get_formatted_modules()].")

/obj/item/weapon/switchtool/attack_self(mob/user)
	if(!user)
		return

	if(deployed)
		to_chat(user, "You store \the [deployed].")
		undeploy()
	else
		choose_deploy(user)

/obj/item/weapon/switchtool/attackby(var/obj/item/used_item, mob/user)
	if(istype(used_item, removing_item) && deployed) //if it's the thing that lets us remove tools and we have something to remove
		return remove_module(user)
	if(add_module(used_item, user))
		return TRUE
	else
		return ..()

/obj/item/weapon/switchtool/proc/get_module_type(var/module)
	return copytext(module, 1, findtext(module, ":"))

/obj/item/weapon/switchtool/proc/get_module_name(var/module)
	return copytext(module, findtext(module, ":") + 1)

//makes the string list of modules ie "a screwdriver, a knife, and a clown horn"
//does not end with a full stop, but does contain commas
/obj/item/weapon/switchtool/proc/get_formatted_modules()
	var/counter = 0
	var/module_string = ""
	for(var/module in stored_modules)
		counter++
		if(counter == stored_modules.len)
			module_string += "and \a [get_module_name(module)]"
		else
			module_string += "\a [get_module_name(module)], "
	return module_string

/obj/item/weapon/switchtool/proc/add_module(var/obj/item/used_item, mob/user)
	if(!used_item || !user)
		return

	for(var/module in stored_modules)
		var/type_path = text2path(get_module_type(module))
		if(istype(used_item, type_path))
			if(stored_modules[module])
				to_chat(user, "\The [src] already has a [get_module_name(module)].")
				return
			else
				if(user.drop_item(used_item, src))
					stored_modules[module] = used_item
					to_chat(user, "You successfully load \the [used_item] into \the [src]'s [get_module_name(module)] slot.")
					return TRUE

/obj/item/weapon/switchtool/proc/remove_module(mob/user)
	deployed.cant_drop = 0
	deployed.forceMove(get_turf(user))
	for(var/module in stored_modules)
		if(stored_modules[module] == deployed)
			stored_modules[module] = null
			break
	to_chat(user, "You successfully remove \the [deployed] from \the [src].")
	playsound(get_turf(src), "sound/items/screwdriver.ogg", 10, 1)
	undeploy()
	return TRUE

/obj/item/weapon/switchtool/proc/undeploy()
	playsound(get_turf(src), undeploy_sound, 10, 1)
	deployed.cant_drop = 0
	deployed = null
	overlays.len = 0
	w_class = initial(w_class)
	update_icon()

/obj/item/weapon/switchtool/proc/deploy(var/module)
	if(!(module in stored_modules))
		return FALSE

	if(!stored_modules[module])
		return FALSE
	if(deployed)
		return FALSE

	playsound(get_turf(src), deploy_sound, 10, 1)
	deployed = stored_modules[module]
	hmodule = get_module_name(module)
	deployed.cant_drop = 1
	overlays += get_module_name(module)
	w_class = max(w_class, deployed.w_class)
	update_icon()
	return TRUE

/obj/item/weapon/switchtool/proc/choose_deploy(mob/user)
	var/list/potential_modules = list()
	for(var/module in stored_modules)
		if(stored_modules[module])
			potential_modules += get_module_name(module)

	if(!potential_modules.len)
		to_chat(user, "No modules to deploy.")
		return

	else if(potential_modules.len == 1)
		deploy(potential_modules[1])
		to_chat(user, "You deploy \the [potential_modules[1]]")
		return TRUE

	else
		var/chosen_module = input(user,"What do you want to deploy?", "[src]", "Cancel") as anything in potential_modules
		if(chosen_module != "Cancel")
			var/true_module = ""
			for(var/checkmodule in stored_modules)
				if(get_module_name(checkmodule) == chosen_module)
					true_module = checkmodule
					break
			if(deploy(true_module))
				to_chat(user, "You deploy \the [deployed].")
			return TRUE
		return

/obj/item/weapon/switchtool/surgery
	name = "surgeon's switchtool"

	icon_state = "surg_switchtool"
	desc = "A switchtool containing most of the necessary items for impromptu surgery. For the surgeon on the go."

	origin_tech = Tc_MATERIALS + "=4;" + Tc_BLUESPACE + "=3;" + Tc_BIOTECH + "=3"
	stored_modules = list("/obj/item/weapon/scalpel:scalpel" = null,
						"/obj/item/weapon/circular_saw:circular saw" = null,
						"/obj/item/weapon/surgicaldrill:surgical drill" = null,
						"/obj/item/weapon/cautery:cautery" = null,
						"/obj/item/weapon/hemostat:hemostat" = null,
						"/obj/item/weapon/retractor:retractor" = null,
						"/obj/item/weapon/bonesetter:bonesetter" = null)

/obj/item/weapon/switchtool/swiss_army_knife
	name = "swiss army knife"

	icon_state = "s_a_k"
	desc = "Crafted by the Space Swiss for everyday use in military campaigns. Nonpareil."

	stored_modules = list("/obj/item/weapon/screwdriver:screwdriver" = null,
						"/obj/item/weapon/wrench:wrench" = null,
						"/obj/item/weapon/wirecutters:wirecutters" = null,
						"/obj/item/weapon/crowbar:crowbar" = null,
						"/obj/item/weapon/kitchen/utensil/knife/large:knife" = null,
						"/obj/item/weapon/kitchen/utensil/fork:fork" = null,
						"/obj/item/weapon/hatchet:hatchet" = null,
						"/obj/item/weapon/lighter/zippo:zippo lighter" = null,
						"/obj/item/weapon/match/strike_anywhere:match" = null,
						"/obj/item/weapon/pen:pen" = null)

/obj/item/weapon/switchtool/swiss_army_knife/undeploy()
	if(istype(deployed, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/lighter = deployed
		lighter.lit = 0
	..()

/obj/item/weapon/switchtool/swiss_army_knife/deploy(var/module)
	..()
	if(istype(deployed, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/lighter = deployed
		lighter.lit = 1
		..()

#define BT 1
#define ENGI 2
#define CB 4
#define SYNDI 8
#define NT 16
#define PS 32

//Unique RD switchtool, modules cannot be removed nor inserted to upgrade, but require techdisks to aquire new modules.
/obj/item/weapon/switchtool/holo
	name = "holo switchtool"
	icon = 'icons/obj/Htool_cyan.dmi'
	icon_state = "holo_switchtool"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/HTool_cyan.dmi', "right_hand" = 'icons/mob/in-hand/right/HTool_cyan.dmi')
	item_state = "Hswitchtool"
	desc = "A switchtool that can take on the form of nearly any tool. Its experimental hardlight emitter requires tech disks to help define its shape."
	var/brightness_max = 4
	var/brightness_min = 2
	deploy_sound = "sound/weapons/switchsound.ogg"
	undeploy_sound = "sound/weapons/switchsound.ogg"
	light_color =  LIGHT_COLOR_CYAN
	mech_flags = MECH_SCAN_ILLEGAL
	removing_item = null
	var/has_tech = 0
	var/hcolor = "CYAN"
	starting_materials = null

	stored_modules = list(//scalpel and flashlight are available to start and the scalpel is logically a laser one but the basic kind.
						"/obj/item/device/flashlight:Light" = null,
						"/obj/item/weapon/scalpel/laser:Scalpel" = null)

//Checks the research type and level for the respective field, then adds them all to the stored modules while also filling the slot with that tool.
/obj/item/weapon/switchtool/holo/add_module(var/obj/item/D, mob/user)
	if(istype(D, /obj/item/weapon/disk/tech_disk))
		var/alreadyhas
		var/obj/item/weapon/disk/tech_disk/T = D
		var/datum/tech/disk_tech = T.stored
		if(istype(disk_tech, /datum/tech/biotech) && disk_tech.level >= 3)
			if(!(has_tech & BT))
				stored_modules["/obj/item/weapon/circular_saw:Circular saw"] = new /obj/item/weapon/circular_saw(src)
				stored_modules["/obj/item/weapon/surgicaldrill:Surgical drill"] = new /obj/item/weapon/surgicaldrill(src)
				stored_modules["/obj/item/weapon/cautery/laser:Cautery"] = new /obj/item/weapon/cautery(src)
				stored_modules["/obj/item/weapon/hemostat:Hemostat"] = new /obj/item/weapon/hemostat(src)
				stored_modules["/obj/item/weapon/retractor:Retractor"] = new /obj/item/weapon/retractor(src)
				stored_modules["/obj/item/weapon/bonesetter:Bonesetter"] = new /obj/item/weapon/bonesetter(src)
				to_chat(user, "The holo switchtool has medical designs now!")
				has_tech |= BT
				return TRUE
			alreadyhas = "Biotech"
		if(istype(disk_tech, /datum/tech/engineering) && disk_tech.level >= 3)
			if(!(has_tech & ENGI))
				stored_modules["/obj/item/weapon/screwdriver:Screwdriver"] = new /obj/item/weapon/screwdriver(src)
				stored_modules["/obj/item/weapon/wrench:Wrench"] = new /obj/item/weapon/wrench(src)
				stored_modules["/obj/item/weapon/wirecutters:Wirecutters"] = new /obj/item/weapon/wirecutters(src)
				stored_modules["/obj/item/weapon/crowbar:Crowbar"] = new /obj/item/weapon/crowbar(src)
				stored_modules["/obj/item/device/multitool:Multitool"] = new /obj/item/device/multitool(src)
				stored_modules["/obj/item/weapon/weldingtool/experimental:Weldingtool"] = new /obj/item/weapon/weldingtool/experimental(src)
				to_chat(user, "The holo switchtool has engineering designs now!")
				has_tech |= ENGI
				return TRUE
			alreadyhas = "Engineering"
		if(istype(disk_tech, /datum/tech/combat) && disk_tech.level >= 5)
			if(!(has_tech & CB))
				stored_modules["/obj/item/weapon/shield/energy:Shield"] = new /obj/item/weapon/shield/energy(src)
				to_chat(user, "The holo switchtool has a defensive design now!")
				has_tech |= CB
				return TRUE
			alreadyhas = "Combat"
		if(istype(disk_tech, /datum/tech/syndicate) && disk_tech.level >= 3)
			if(!(has_tech & SYNDI))
				stored_modules["/obj/item/weapon/melee/energy/sword/activated:Sword"] = new /obj/item/weapon/melee/energy/sword/activated(src)
				to_chat(user, "The holo switchtool has an offensive design now!")
				has_tech |= SYNDI
				return TRUE
			alreadyhas = "Syndicate"
		if(istype(disk_tech, /datum/tech/nanotrasen) && disk_tech.level >= 5)
			if(!(has_tech & NT))
				stored_modules["/obj/item/weapon/melee/energy/hfmachete/activated:Sharper sword"] = new /obj/item/weapon/melee/energy/hfmachete/activated(src)
				to_chat(user, "The holo switchtool has a secret offensive design now!")
				has_tech |= NT
				return TRUE
			alreadyhas = "Nanotrasen"
	//Joke module about power[clean/creep], this is dumb but exists.
	//How does a UV light clean even? It just sterilizes. I guess it works because it's like suit storages with their UV suit cleaner.
		if(istype(disk_tech, /datum/tech/powerstorage) && disk_tech.level >= 4)
			if(!(has_tech & PS))
				stored_modules["/obj/item/weapon/soap/holo:UV sterilizer"] = new /obj/item/weapon/soap/holo(src)
				to_chat(user, "The holo switchtool has a power clean design now!")
				has_tech |= PS
				return TRUE
			alreadyhas = "Power Storage"

		if(alreadyhas)
			to_chat(user, "The holo switchtool already has [alreadyhas] technology!")

#undef BT
#undef ENGI
#undef CB
#undef SYNDI
#undef NT
#undef PS

/obj/item/weapon/switchtool/holo/verb/togglecolor()
	set name = "Toggle Color"
	set category = "Object"

	if(hcolor == "CYAN")
		hcolor = "PINK"
		colorchange()
	else if(hcolor == "PINK")
		hcolor = "GREEN"
		colorchange()
	else if(hcolor == "GREEN")
		hcolor = "ORANGE"
		colorchange()
	else if(hcolor == "ORANGE")
		hcolor = "CYAN"
		colorchange()

/obj/item/weapon/switchtool/holo/proc/colorchange()
	if(hcolor == "CYAN")
		icon = 'icons/obj/Htool_cyan.dmi'
		inhand_states = list("left_hand" = 'icons/mob/in-hand/left/HTool_cyan.dmi', "right_hand" = 'icons/mob/in-hand/right/HTool_cyan.dmi')
		light_color =  LIGHT_COLOR_CYAN
	else if(hcolor == "PINK")
		icon = 'icons/obj/Htool_pink.dmi'
		inhand_states = list("left_hand" = 'icons/mob/in-hand/left/HTool_pink.dmi', "right_hand" = 'icons/mob/in-hand/right/HTool_pink.dmi')
		light_color =  LIGHT_COLOR_PINK
	else if(hcolor == "GREEN")
		icon = 'icons/obj/Htool_green.dmi'
		inhand_states = list("left_hand" = 'icons/mob/in-hand/left/HTool_green.dmi', "right_hand" = 'icons/mob/in-hand/right/HTool_green.dmi')
		light_color =  LIGHT_COLOR_GREEN
	else if(hcolor == "ORANGE")
		icon = 'icons/obj/Htool_orange.dmi'
		inhand_states = list("left_hand" = 'icons/mob/in-hand/left/HTool_orange.dmi', "right_hand" = 'icons/mob/in-hand/right/HTool_orange.dmi')
		light_color =  LIGHT_COLOR_ORANGE

	if(istype(loc, /mob))
		var/mob/M = loc
		M.update_inv_hands()
	update_icon()
	set_light()

//for the inhand sprite changes
/obj/item/weapon/switchtool/holo/update_icon()
	if(deployed)
		item_state = "[hmodule]"
		deployed.appearance = appearance
	else
		item_state = "Hswitchtool"

	if(istype(loc, /mob))
		var/mob/M = loc
		M.update_inv_hands()

/obj/item/weapon/switchtool/holo/IsShield()
	if(istype(deployed, /obj/item/weapon/shield/energy))
		return TRUE
	else
		return 0

//All modules make small amounts of light, flashlight making more.
/obj/item/weapon/switchtool/holo/deploy(var/module)
	if(!..())
		return FALSE
	set_light(brightness_min)
	overlays += "[hmodule]"
	if(istype(deployed, /obj/item/device/flashlight))
		set_light(brightness_max)

	//Since you can't turn off the welder inside the tool, I'm using the unused welder that very slowly regens fuel, looks like 1u per 5 byond seconds, thanks byond.
//It can be refulled manually, but since it starts active you will blow up welder tanks if deployed and then put to a tank.
	if(istype(deployed, /obj/item/weapon/weldingtool/experimental))
		var/obj/item/weapon/weldingtool/experimental/weldingtool = deployed
		weldingtool.welding = 1
		weldingtool.status = 1
		weldingtool.max_fuel = 50
		weldingtool.start_fueled = 1

/obj/item/weapon/switchtool/holo/undeploy()
	..()
	set_light(0)


//switchtools maxed out intended for testing/spawning and maybe as loot. Don't forget to add any more tools added to these lists later
/obj/item/weapon/switchtool/holo/maxed
	stored_modules = list(
						"/obj/item/device/flashlight:Light" = null,
						"/obj/item/weapon/scalpel/laser:Scalpel" = null,
						"/obj/item/weapon/circular_saw:Circular saw" = null,
						"/obj/item/weapon/surgicaldrill:Surgical drill" = null,
						"/obj/item/weapon/cautery/laser:Cautery" = null,
						"/obj/item/weapon/hemostat:Hemostat" = null,
						"/obj/item/weapon/retractor:Retractor" = null,
						"/obj/item/weapon/bonesetter:Bonesetter" = null,
						"/obj/item/weapon/screwdriver:Screwdriver" = null,
						"/obj/item/weapon/wrench:Wrench" = null,
						"/obj/item/weapon/wirecutters:Wirecutters" = null,
						"/obj/item/weapon/crowbar:Crowbar" = null,
						"/obj/item/device/multitool:Multitool" = null,
						"/obj/item/weapon/weldingtool/experimental:Weldingtool" = null,
						"/obj/item/weapon/soap/holo:UV sterilizer" = null,
						"/obj/item/weapon/shield/energy:Shield" = null,
						"/obj/item/weapon/melee/energy/sword/activated:Sword" = null,
						"/obj/item/weapon/melee/energy/hfmachete/activated:Sharper sword" = null
						)

/obj/item/weapon/switchtool/holo/maxed/add_module()
	return

/obj/item/weapon/switchtool/surgery/maxed
	stored_modules = list(
						"/obj/item/weapon/scalpel/laser/tier2:scalpel" = null,
						"/obj/item/weapon/circular_saw/plasmasaw:circular saw" = null,
						"/obj/item/weapon/surgicaldrill/diamond:surgical drill" = null,
						"/obj/item/weapon/cautery/laser/tier2:cautery" = null,
						"/obj/item/weapon/hemostat/pico:hemostat" = null,
						"/obj/item/weapon/retractor/manager:retractor" = null,
						"/obj/item/weapon/bonesetter/bone_mender:bonesetter" = null
						)

/obj/item/weapon/switchtool/engineering
	name = "\improper Engineering switchtool"
	desc = "A switchtool designed specifically to be the perfect companion for an Engineer."
	stored_modules = list(
		"/obj/item/weapon/crowbar:crowbar" = null,
		"/obj/item/weapon/screwdriver:screwdriver" = null,
		"/obj/item/weapon/weldingtool/hugetank:welding tool" = null,
		"/obj/item/weapon/wirecutters:wirecutters" = null,
		"/obj/item/weapon/wrench:wrench" = null,
		"/obj/item/device/multitool:multitool" = null,
		"/obj/item/stack/cable_coil/persistent:cable" = null,
		"/obj/item/device/t_scanner:T-ray scanner" = null,
		"/obj/item/device/analyzer/scope:atmospheric analysis scope" = null,
		"/obj/item/weapon/solder/pre_fueled:soldering iron" = null,
		"/obj/item/device/silicate_sprayer:silicate sprayer" = null
		)

/obj/item/weapon/switchtool/engineering/deploy(var/module)
	if(!..())
		return FALSE
	if(istype(deployed, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = deployed
		W.welding = 1
		W.status = 1
	if(istype(deployed, /obj/item/device/t_scanner))
		var/obj/item/device/t_scanner/T = deployed
		T.attack_self()

/obj/item/weapon/switchtool/engineering/undeploy()
	if(istype(deployed, /obj/item/device/t_scanner))
		var/obj/item/device/t_scanner/T = deployed
		T.attack_self()
	..()

/obj/item/weapon/switchtool/engineering/mech
	stored_modules = list(
		"/obj/item/weapon/crowbar:crowbar" = null,
		"/obj/item/weapon/screwdriver:screwdriver" = null,
		"/obj/item/weapon/weldingtool/hugetank/mech:welding tool" = null,
		"/obj/item/weapon/wirecutters:wirecutters" = null,
		"/obj/item/weapon/wrench:wrench" = null,
		"/obj/item/device/multitool:multitool" = null,
		"/obj/item/stack/cable_coil/persistent:cable" = null,
		"/obj/item/device/t_scanner:T-ray scanner" = null,
		"/obj/item/device/analyzer/scope:atmospheric analysis scope" = null,
		"/obj/item/weapon/solder/pre_fueled:soldering iron" = null,
		"/obj/item/device/silicate_sprayer:silicate sprayer" = null
		)